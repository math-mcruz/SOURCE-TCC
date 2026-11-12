## Análise

**1. Parágrafos e fluxo principal**

- PREMIERE (A010): inicializa o retorno (sucesso = 'N', código de falha = '0'), registra o tratador de abend, define o sortcode e chama UPDATE-ACCOUNT-DB2. Depois chama GET-ME-OUT-OF-HERE.
- UPDATE-ACCOUNT-DB2 (UAD010): lê a conta, valida o movimento, atualiza os saldos disponível e real e chama WRITE-TO-PROCTRAN.
- WRITE-TO-PROCTRAN (WTP010): apenas delega para WRITE-TO-PROCTRAN-DB2.
- WRITE-TO-PROCTRAN-DB2 (WTPD010): monta e grava o registro de movimento (PROCTRAN), com tipo e descrição, e define o resultado final (sucesso ou falha '02').
- GET-ME-OUT-OF-HERE (GMOOH010): devolve o controle ao chamador.
- CHECK-FOR-STORM-DRAIN-DB2 (CFSDD010): identifica perda de conexão com o DB2 (SQLCODE 923) e registra mensagem.
- ABEND-HANDLING (AH010): trata abends (deadlock, falhas de VSAM), faz rollback e encerra.
- POPULATE-TIME-DATE (PTD10): obtém data e hora para registro de abend.

Fluxo principal: A010 → UAD010 (leitura da conta → validações → atualização de saldos) → WTPD010 (gravação do movimento) → retorno.

**2 e 3. Estruturas de decisão e classificação**

| # | Parágrafo | Estrutura | Classificação |
|---|---|---|---|
| 1 | UAD010 | `IF SQLCODE NOT = 0` após o SELECT | Misto (ver itens 1a e 1b) |
| 1a | UAD010 | `IF SQLCODE = +100` aninhado | Negócio (conta inexistente) |
| 1b | UAD010 | ramo `ELSE` (outro SQLCODE) | Infraestrutura (falha técnica do DB2, código '2') |
| 1c | UAD010 | `PERFORM CHECK-FOR-STORM-DRAIN-DB2` | Infraestrutura |
| 2 | UAD010 | `IF COMM-AMT < 0` (débito) | Teste intermediário que só leva aos testes 3 e 4 |
| 3 | UAD010 | `IF` MORTGAGE/LOAN e COMM-FACILTYPE = 496 (dentro do débito) | Negócio |
| 4 | UAD010 | `IF WS-DIFFERENCE < 0 AND COMM-FACILTYPE = 496` | Negócio |
| 5 | UAD010 | `IF` MORTGAGE/LOAN e COMM-FACILTYPE = 496 (fora do bloco de débito) | Negócio (segunda ocorrência da regra 3) |
| 6 | UAD010 | `IF SQLCODE NOT = 0` após o UPDATE | Infraestrutura |
| 7 | WTPD010 | `IF COMM-AMT < 0` / `ELSE`, com `IF COMM-FACILTYPE = 496` em cada ramo | Negócio (define o tipo de movimento) |
| 8 | WTPD010 | `IF SQLCODE NOT = 0` após o INSERT | Infraestrutura (rollback, abend 'HROL', código '02') |
| 9 | WTPD010 | `IF WS-CICS-RESP NOT = DFHRESP(NORMAL)` | Infraestrutura |
| 10 | CFSDD010 | `EVALUATE SQLCODE` e `IF STORM-DRAIN-CONDITION` | Infraestrutura |
| 11 | AH010 | `EVALUATE MY-ABEND-CODE`, `IF WS-CICS-RESP`, `IF WS-STORM-DRAIN = 'N'` | Infraestrutura |

Não há estruturas de interface (sem telas ou teclas de função). O programa também não valida formato de campo nem obrigatoriedade.

**4. Condição e consequência das estruturas de negócio**

- 1a: SELECT retorna SQLCODE +100 (conta não encontrada). A operação é recusada com código de falha '1'.
- 3: débito (valor negativo), conta do tipo MORTGAGE ou LOAN e facilidade 496. A operação é recusada com código '4'.
- 4: débito com facilidade 496 em que saldo disponível mais valor fica negativo. A operação é recusada com código '3'.
- 5: conta MORTGAGE ou LOAN com facilidade 496, sem ser débito. Como os débitos já saem no teste 3, na prática só chegam aqui valores zero ou positivos. A operação é recusada com código '4'.
- 7: o movimento é classificado conforme o sinal do valor e a facilidade 496:
  - DEB: débito comum.
  - PDR: débito com facilidade 496.
  - CRE: crédito comum.
  - PCR: crédito com facilidade 496.

Observações de fidelidade:

- O código não considera o limite de cheque especial (HV-ACCOUNT-OVERDRAFT-LIM) na verificação de saldo.
- O teste de saldo insuficiente só vale para a facilidade 496. Débitos com outras facilidades não passam por essa verificação.
- O código não explica o significado de 496.
- A gravação do movimento (PROCTRAN) é classificada como negócio porque define a natureza do lançamento (débito, crédito, pagamento). Também poderia ser lida como registro técnico, o que é ambíguo.
- O resultado de sucesso ('Y') depende apenas do SQLCODE do INSERT, então foi tratado como infraestrutura.

## Regras de negócio

1. Regra: Não é possível movimentar uma conta que não existe.
   Condição: A conta (sortcode + número) não é encontrada na leitura (SQLCODE = +100).
   Consequência: A operação não é realizada e retorna falha com código '1' (sucesso = 'N').
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)

2. Regra: Débitos em contas de hipoteca ou empréstimo feitos pela facilidade 496 são recusados.
   Condição: Valor negativo (débito), tipo de conta 'MORTGAGE' ou 'LOAN' e COMM-FACILTYPE = 496.
   Consequência: A operação é recusada com falha código '4' e os saldos não são alterados.
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)

3. Regra: Débito pela facilidade 496 que deixaria o saldo disponível negativo é recusado.
   Condição: Valor negativo, COMM-FACILTYPE = 496 e saldo disponível mais o valor menor que zero (WS-DIFFERENCE < 0). O limite de cheque especial não entra nessa verificação, e débitos com outras facilidades não passam por ela.
   Consequência: A operação é recusada por fundos insuficientes, com falha código '3'.
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)

4. Regra: Movimentos que não são débito (crédito ou valor zero) em contas de hipoteca ou empréstimo feitos pela facilidade 496 também são recusados.
   Condição: Valor não negativo, tipo de conta 'MORTGAGE' ou 'LOAN' e COMM-FACILTYPE = 496. É uma segunda ocorrência da regra 2, desta vez fora do bloco de débito.
   Consequência: A operação é recusada com falha código '4' e os saldos não são alterados.
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)

5. Regra: Um débito comum é registrado no histórico como saque de balcão.
   Condição: Valor negativo (COMM-AMT < 0) e COMM-FACILTYPE diferente de 496.
   Consequência: O movimento é registrado com tipo 'DEB' e descrição 'COUNTER WTHDRW'.
   Parágrafo: WRITE-TO-PROCTRAN-DB2 (WTPD010)

6. Regra: Um débito feito pela facilidade 496 é registrado como débito de pagamento, com a origem informada como descrição.
   Condição: Valor negativo e COMM-FACILTYPE = 496.
   Consequência: O movimento é registrado com tipo 'PDR' e descrição igual aos 14 primeiros caracteres de COMM-ORIGIN.
   Parágrafo: WRITE-TO-PROCTRAN-DB2 (WTPD010)

7. Regra: Um crédito comum é registrado no histórico como valor recebido no balcão.
   Condição: Valor não negativo (COMM-AMT >= 0) e COMM-FACILTYPE diferente de 496.
   Consequência: O movimento é registrado com tipo 'CRE' e descrição 'COUNTER RECVED'.
   Parágrafo: WRITE-TO-PROCTRAN-DB2 (WTPD010)

8. Regra: Um crédito feito pela facilidade 496 é registrado como crédito de pagamento, com a origem informada como descrição.
   Condição: Valor não negativo e COMM-FACILTYPE = 496. Na prática, só é alcançável para contas que não sejam MORTGAGE ou LOAN, pois a regra 4 as recusa antes.
   Consequência: O movimento é registrado com tipo 'PCR' e descrição igual aos 14 primeiros caracteres de COMM-ORIGIN.
   Parágrafo: WRITE-TO-PROCTRAN-DB2 (WTPD010)