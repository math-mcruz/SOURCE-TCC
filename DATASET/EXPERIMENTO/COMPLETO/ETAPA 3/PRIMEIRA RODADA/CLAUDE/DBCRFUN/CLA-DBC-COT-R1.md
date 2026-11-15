## Análise

**1. Parágrafos e fluxo principal**

- PREMIERE (A010): inicia com sucesso = 'N' e código de falha = '0', registra o tratador de ABEND, define o sort code e chama UPDATE-ACCOUNT-DB2. Depois chama GET-ME-OUT-OF-HERE.
- UPDATE-ACCOUNT-DB2 (UAD010): lê a conta, valida o movimento, aplica o valor aos saldos disponível e real, atualiza a conta e chama WRITE-TO-PROCTRAN.
- WRITE-TO-PROCTRAN (WTP010): apenas chama WRITE-TO-PROCTRAN-DB2.
- WRITE-TO-PROCTRAN-DB2 (WTPD010): monta e grava o registro da transação (PROCTRAN) com tipo e descrição conforme o movimento. Em falha de gravação faz rollback e sinaliza erro.
- GET-ME-OUT-OF-HERE (GMOOH010): retorna o controle ao chamador.
- CHECK-FOR-STORM-DRAIN-DB2 (CFSDD010): detecta perda de conexão com o DB2 (SQLCODE 923) e emite mensagem.
- ABEND-HANDLING (AH010): trata ABENDs (deadlock DB2 e falhas VSAM), com rollback e registro de diagnóstico.
- POPULATE-TIME-DATE (PTD10): obtém data e hora para o registro de abend.

Fluxo principal: ler a conta, depois validar (conta existente, tipo de conta/facilidade, saldo suficiente), atualizar os saldos, gravar a transação e retornar sucesso ('Y') ou o código de falha.

**2. Estruturas de decisão e classificação**

| Parágrafo | Estrutura | Classificação |
|---|---|---|
| UAD010 | `IF SQLCODE NOT = 0` após o SELECT da conta | Intermediário; leva a outro teste |
| UAD010 | `IF SQLCODE = +100` (aninhado ao anterior) | Negócio: conta não encontrada, falha '1' |
| UAD010 | ELSE do teste acima (outros SQLCODE), falha '2' | Infraestrutura (falha técnica de banco) |
| UAD010 | `IF COMM-AMT < 0` (movimento negativo) | Intermediário; leva a outros testes |
| UAD010 | `IF` MORTGAGE/LOAN e COMM-FACILTYPE = 496 dentro do bloco de valor negativo, falha '4' | Negócio |
| UAD010 | `IF WS-DIFFERENCE < 0 AND COMM-FACILTYPE = 496`, falha '3' | Negócio |
| UAD010 | `IF` MORTGAGE/LOAN e COMM-FACILTYPE = 496 fora do bloco, falha '4' | Negócio (repetição da regra anterior) |
| UAD010 | `IF SQLCODE NOT = 0` após o UPDATE, falha '2' | Infraestrutura |
| WTPD010 | `IF COMM-AMT < 0` e `IF COMM-FACILTYPE = 496` aninhado (quatro caminhos) | Negócio (classificação do movimento) |
| WTPD010 | `IF SQLCODE NOT = 0` após o INSERT em PROCTRAN, com rollback e abend 'HROL' | Infraestrutura |
| WTPD010 | `IF WS-CICS-RESP NOT = DFHRESP(NORMAL)` | Infraestrutura |
| CFSDD010 | `EVALUATE SQLCODE` (923) e `IF STORM-DRAIN-CONDITION` | Infraestrutura |
| AH010 | `EVALUATE MY-ABEND-CODE` (AD2Z, AFCR, AFCS, AFCT), testes de RESP e `IF WS-STORM-DRAIN = 'N'` | Infraestrutura |

**3. Condição e consequência das estruturas de negócio**

- Conta não encontrada (SQLCODE = +100): operação recusada, com código de falha '1'.
- Débito (valor negativo) em conta MORTGAGE ou LOAN com facilidade 496: operação recusada, com código de falha '4'.
- Débito com facilidade 496 em que saldo disponível + valor fica negativo: operação recusada, com código de falha '3'. O teste usa o saldo disponível e não considera o limite de cheque especial. Para facilidade diferente de 496, o código não verifica saldo, então débitos que deixam a conta negativa são aceitos.
- Conta MORTGAGE ou LOAN com facilidade 496, testada novamente fora do bloco de débito: operação recusada, com código de falha '4'. Na prática só é alcançada por valores não negativos, pois os negativos já foram recusados antes.
- Classificação do movimento na transação gravada: depende do sinal do valor e de a facilidade ser 496. O valor zero é tratado como crédito. O significado de "facilidade 496" não está definido no código.
- Observação de fidelidade: o código de falha de gravação é '02' em WTPD010 e '2' em UAD010. Isso é uma inconsistência técnica e não gera regra de negócio.

## Regras de negócio

1. Regra: Uma operação sobre conta inexistente é recusada (SQLCODE = +100).
   Condição: A conta (sort code e número) não é encontrada no cadastro de contas.
   Consequência: A operação não é realizada e retorna falha com código '1' (conta não encontrada).
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)

2. Regra: Débitos de facilidade 496 não são permitidos em contas de hipoteca ou empréstimo.
   Condição: O valor do movimento é negativo (COMM-AMT < 0), o tipo da conta é 'MORTGAGE' ou 'LOAN' e o tipo de facilidade é 496 (COMM-FACILTYPE).
   Consequência: A operação é recusada, sem alterar saldos, com código de falha '4'.
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)

3. Regra: Débitos de facilidade 496 são recusados quando o saldo disponível não cobre o valor.
   Condição: O valor do movimento é negativo, o tipo de facilidade é 496 e saldo disponível + valor do movimento resulta em valor negativo (WS-DIFFERENCE < 0). O teste usa o saldo disponível e não considera o limite de cheque especial. Para facilidade diferente de 496 não há verificação de saldo.
   Consequência: A operação é recusada, sem alterar saldos, com código de falha '3' (fundos insuficientes).
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)

4. Regra: Movimentos de facilidade 496 não são permitidos em contas de hipoteca ou empréstimo (segunda ocorrência da regra 2, fora do bloco de débito).
   Condição: O tipo da conta é 'MORTGAGE' ou 'LOAN' e o tipo de facilidade é 496. Na prática só chega a este teste quando o valor do movimento não é negativo, pois os valores negativos já foram recusados pela regra 2.
   Consequência: A operação é recusada, sem alterar saldos, com código de falha '4'.
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)

5. Regra: Um débito comum é registrado como saque de balcão.
   Condição: O valor do movimento é negativo (COMM-AMT < 0) e o tipo de facilidade não é 496.
   Consequência: A transação é registrada com tipo 'DEB' e descrição 'COUNTER WTHDRW'.
   Parágrafo: WRITE-TO-PROCTRAN-DB2 (WTPD010)

6. Regra: Um débito de facilidade 496 é registrado como débito de pagamento, com a origem informada.
   Condição: O valor do movimento é negativo e o tipo de facilidade é 496.
   Consequência: A transação é registrada com tipo 'PDR' e descrição igual aos 14 primeiros caracteres da origem (COMM-ORIGIN).
   Parágrafo: WRITE-TO-PROCTRAN-DB2 (WTPD010)

7. Regra: Um crédito comum é registrado como valor recebido no balcão.
   Condição: O valor do movimento não é negativo (zero ou positivo) e o tipo de facilidade não é 496.
   Consequência: A transação é registrada com tipo 'CRE' e descrição 'COUNTER RECVED'.
   Parágrafo: WRITE-TO-PROCTRAN-DB2 (WTPD010)

8. Regra: Um crédito de facilidade 496 é registrado como crédito de pagamento, com a origem informada.
   Condição: O valor do movimento não é negativo (zero ou positivo) e o tipo de facilidade é 496.
   Consequência: A transação é registrada com tipo 'PCR' e descrição igual aos 14 primeiros caracteres da origem (COMM-ORIGIN).
   Parágrafo: WRITE-TO-PROCTRAN-DB2 (WTPD010)