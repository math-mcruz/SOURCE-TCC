## Análise

**1. Parágrafos e fluxo principal**

- **PREMIERE (A010)**: inicializa o retorno como falha, registra o tratador de ABEND, define o código de agência (sort code) e chama UPDATE-ACCOUNT-DB2. Depois chama GET-ME-OUT-OF-HERE.
- **UPDATE-ACCOUNT-DB2 (UAD010)**: lê a conta, valida o débito ou crédito, atualiza os saldos disponível e atual e chama WRITE-TO-PROCTRAN.
- **WRITE-TO-PROCTRAN (WTP010)**: apenas chama WRITE-TO-PROCTRAN-DB2.
- **WRITE-TO-PROCTRAN-DB2 (WTPD010)**: monta e grava o registro da movimentação na tabela PROCTRAN e define o sucesso ou falha final.
- **GET-ME-OUT-OF-HERE (GMOOH010)**: devolve o controle ao chamador (CICS RETURN).
- **CHECK-FOR-STORM-DRAIN-DB2 (CFSDD010)**: identifica perda de conexão com o DB2.
- **ABEND-HANDLING (AH010)**: trata ABENDs (deadlock, erros de VSAM).
- **POPULATE-TIME-DATE (PTD10)**: obtém data e hora.

Fluxo principal: A010 → UAD010 (lê a conta → valida → atualiza saldos → WTPD010 grava a movimentação) → GMOOH010.

**2 e 3. Estruturas de decisão e classificação**

| # | Estrutura | Parágrafo | Classificação |
|---|---|---|---|
| 1 | `IF SQLCODE NOT = 0` após o SELECT | UAD010 | Infraestrutura, com uma ramificação de negócio |
| 1a | Interna: `IF SQLCODE = +100` | UAD010 | Negócio (conta inexistente) |
| 1b | Interna: ELSE (outros SQLCODE) | UAD010 | Infraestrutura (falha técnica de banco, código 2) |
| 2 | `IF COMM-AMT < 0` (débito) | UAD010 | Negócio, mas apenas como teste intermediário que leva aos testes 2a e 2b |
| 2a | MORTGAGE/LOAN com `COMM-FACILTYPE = 496` | UAD010 | Negócio |
| 2b | `WS-DIFFERENCE < 0 AND COMM-FACILTYPE = 496` | UAD010 | Negócio |
| 3 | Repetição do teste MORTGAGE/LOAN com 496, fora do teste de débito | UAD010 | Negócio |
| 4 | `IF SQLCODE NOT = 0` após o UPDATE | UAD010 | Infraestrutura |
| 5 | `IF COMM-AMT < 0` e `IF COMM-FACILTYPE = 496` internos | WTPD010 | Negócio (tipo da movimentação), com ressalva abaixo |
| 6 | `IF SQLCODE NOT = 0` após o INSERT, rollback e teste de `WS-CICS-RESP` | WTPD010 | Infraestrutura |
| 7 | `EVALUATE SQLCODE` e `IF STORM-DRAIN-CONDITION` | CFSDD010 | Infraestrutura |
| 8 | `EVALUATE MY-ABEND-CODE`, `IF WS-CICS-RESP` e `IF WS-STORM-DRAIN` | AH010 | Infraestrutura |

**4. Condição e consequência das estruturas de negócio**

- **1a**: a conta não existe (SQLCODE +100). A operação é recusada com código de falha '1'.
- **2a**: débito (valor negativo) em conta MORTGAGE ou LOAN com facilidade 496. A operação é recusada com código '4'.
- **2b**: débito com facilidade 496 em que saldo disponível mais valor fica negativo. A operação é recusada com código '3'.
- **3**: conta MORTGAGE ou LOAN com facilidade 496, fora do teste de débito. A operação é recusada com código '4'. Para débitos, este teste é inalcançável, porque 2a já recusou. Na prática só atinge valores zero ou positivos (créditos).
- **5**: define o tipo da movimentação registrada. Débito vira DEB ("COUNTER WTHDRW") e débito com 496 vira PDR. Crédito vira CRE ("COUNTER RECVED") e crédito com 496 vira PCR. Valor zero é tratado como crédito.

**Observações de fidelidade**

- O significado de `COMM-FACILTYPE = 496` não está no código, então é citado apenas pelo valor.
- Para débitos sem facilidade 496, o programa não verifica saldo nem limite de cheque especial (`HV-ACCOUNT-OVERDRAFT-LIM` é lido mas não usado nesta decisão). Não há regra a listar para esse caso.
- A classificação do item 5 é ambígua. A gravação em PROCTRAN poderia ser vista como registro de log ou auditoria (excluído), mas os tipos DEB, PDR, CRE e PCR distinguem tipos de movimentação que a área de negócio entende. Optei por listá-los.

## Regras de negócio

1. Regra: Não é possível movimentar uma conta que não existe no cadastro.
   Condição: A conta (código de agência e número da conta) não é encontrada na tabela de contas (SQLCODE = +100).
   Consequência: A operação é recusada e retorna falha com código '1' (conta não encontrada).
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)

2. Regra: Débitos pela facilidade 496 não são permitidos em contas de hipoteca ou de empréstimo.
   Condição: O valor é negativo (COMM-AMT < 0), a facilidade é 496 e o tipo da conta é MORTGAGE ou LOAN.
   Consequência: A operação é recusada e retorna falha com código '4'. Os saldos não são alterados.
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)

3. Regra: Débito pela facilidade 496 não é permitido quando o saldo disponível ficaria negativo.
   Condição: O valor é negativo (COMM-AMT < 0), a facilidade é 496 e o saldo disponível mais o valor do débito resulta em valor menor que zero. O limite de cheque especial não é considerado.
   Consequência: A operação é recusada por saldo insuficiente, com código de falha '3'. Os saldos não são alterados.
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)

4. Regra: Operações pela facilidade 496 não são permitidas em contas de hipoteca ou de empréstimo (segunda ocorrência do teste, fora do bloco de débito).
   Condição: A facilidade é 496 e o tipo da conta é MORTGAGE ou LOAN, depois de passar pelo bloco de débito. Para débitos o teste nunca é alcançado, porque a regra 2 já recusou. Na prática só atinge valores zero ou positivos.
   Consequência: A operação é recusada e retorna falha com código '4'. Os saldos não são alterados.
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)

5. Regra: Um débito comum é registrado como saque de balcão.
   Condição: O valor é negativo (COMM-AMT < 0) e a facilidade não é 496.
   Consequência: A movimentação é registrada com tipo 'DEB' e descrição "COUNTER WTHDRW".
   Parágrafo: WRITE-TO-PROCTRAN-DB2 (WTPD010)

6. Regra: Um débito pela facilidade 496 é registrado como débito de pagamento.
   Condição: O valor é negativo (COMM-AMT < 0) e a facilidade é 496.
   Consequência: A movimentação é registrada com tipo 'PDR' e descrição igual aos 14 primeiros caracteres da origem (COMM-ORIGIN).
   Parágrafo: WRITE-TO-PROCTRAN-DB2 (WTPD010)

7. Regra: Um crédito comum é registrado como recebimento de balcão.
   Condição: O valor não é negativo (zero ou positivo) e a facilidade não é 496.
   Consequência: A movimentação é registrada com tipo 'CRE' e descrição "COUNTER RECVED".
   Parágrafo: WRITE-TO-PROCTRAN-DB2 (WTPD010)

8. Regra: Um crédito pela facilidade 496 é registrado como crédito de pagamento.
   Condição: O valor não é negativo (zero ou positivo) e a facilidade é 496.
   Consequência: A movimentação é registrada com tipo 'PCR' e descrição igual aos 14 primeiros caracteres da origem (COMM-ORIGIN).
   Parágrafo: WRITE-TO-PROCTRAN-DB2 (WTPD010)