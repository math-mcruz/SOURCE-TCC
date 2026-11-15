## Análise

**1. Parágrafos e fluxo principal**

O programa DBCRFUN aplica um débito ou crédito (COMM-AMT) a uma conta, identificada pelo código de agência e pelo número da conta. O fluxo é:

- **PREMIERE (A010)**: inicia o indicador de sucesso como "N" e o código de falha como "0". Registra o tratamento de abend, define a agência e chama UPDATE-ACCOUNT-DB2. Depois chama GET-ME-OUT-OF-HERE.
- **UPDATE-ACCOUNT-DB2 (UAD010)**:
  - Lê a conta.
  - Valida o tipo de conta e a facilidade (COMM-FACILTYPE) e o saldo disponível.
  - Soma o valor aos saldos disponível e atual.
  - Atualiza a conta e chama WRITE-TO-PROCTRAN.
- **WRITE-TO-PROCTRAN (WTP010)**: apenas chama WRITE-TO-PROCTRAN-DB2.
- **WRITE-TO-PROCTRAN-DB2 (WTPD010)**: monta e grava o registro da movimentação na tabela PROCTRAN (histórico de transações). Define o tipo e a descrição conforme o sinal do valor e a facilidade. Se a gravação falha, faz rollback. Se a gravação funciona, marca sucesso "Y".
- **GET-ME-OUT-OF-HERE (GMOOH010)**: devolve o controle ao chamador.
- **CHECK-FOR-STORM-DRAIN-DB2 (CFSDD010)**: detecta perda de conexão com o DB2 (SQLCODE 923) e emite mensagem.
- **ABEND-HANDLING (AH010)**: trata abends (deadlock DB2, falhas VSAM RLS) com mensagens, rollback e novo abend.
- **POPULATE-TIME-DATE (PTD10)**: obtém data e hora para o registro de abend.

**2. Estruturas de decisão e classificação**

| # | Estrutura | Parágrafo | Classificação |
|---|---|---|---|
| 1 | IF SQLCODE NOT = 0 após o SELECT | UAD010 | Intermediária. Leva ao teste seguinte. |
| 1a | IF SQLCODE = +100 (conta não encontrada) → falha "1" | UAD010 | **Negócio** |
| 1b | ELSE (outro SQLCODE) → falha "2" | UAD010 | Infraestrutura |
| 2 | IF COMM-AMT < 0 | UAD010 | Intermediária. Agrupa os dois testes de débito abaixo. |
| 2a | IF tipo de conta MORTGAGE ou LOAN e COMM-FACILTYPE = 496 → falha "4" | UAD010 | **Negócio** |
| 2b | IF WS-DIFFERENCE < 0 e COMM-FACILTYPE = 496 → falha "3" | UAD010 | **Negócio** |
| 3 | IF tipo de conta MORTGAGE ou LOAN e COMM-FACILTYPE = 496 → falha "4", fora do bloco de débito | UAD010 | **Negócio** (repetição do teste 2a) |
| 4 | IF SQLCODE NOT = 0 após o UPDATE → falha "2" | UAD010 | Infraestrutura |
| 5 | IF COMM-AMT < 0 / IF COMM-FACILTYPE = 496 (tipo e descrição da movimentação) | WTPD010 | **Negócio** (classificação da movimentação) |
| 6 | IF SQLCODE NOT = 0 após o INSERT (rollback, abend e falha "02"); ELSE sucesso | WTPD010 | Infraestrutura |
| 7 | IF WS-CICS-RESP NOT = DFHRESP(NORMAL) | WTPD010, AH010 | Infraestrutura |
| 8 | EVALUATE SQLCODE (923) e IF STORM-DRAIN-CONDITION | CFSDD010 | Infraestrutura |
| 9 | EVALUATE MY-ABEND-CODE (AD2Z, AFCR, AFCS, AFCT) e IF WS-STORM-DRAIN | AH010 | Infraestrutura |

**3. Condição e consequência das estruturas de negócio**

- **1a**
  - Condição: a conta (agência e número) não existe (SQLCODE = +100).
  - Consequência: operação sem sucesso, com código de falha "1".
- **2a**
  - Condição: valor negativo (débito), conta do tipo MORTGAGE ou LOAN e facilidade 496.
  - Consequência: operação rejeitada, com código de falha "4".
- **2b**
  - Condição: valor negativo, facilidade 496 e saldo disponível mais o valor menor que zero.
  - Consequência: operação rejeitada, com código de falha "3".
  - Observação: o limite de cheque especial (HV-ACCOUNT-OVERDRAFT-LIM) é lido, mas não é usado no cálculo. Para facilidades diferentes de 496, o programa não testa saldo insuficiente.
- **3**
  - Condição: conta do tipo MORTGAGE ou LOAN e facilidade 496, alcançada quando o valor não é negativo.
  - Consequência: operação rejeitada, com código de falha "4".
- **5**
  - Condição: sinal do valor (negativo ou não) combinado com facilidade 496 ou outra.
  - Consequência: define o tipo da movimentação no histórico (DEB, PDR, CRE ou PCR) e a descrição.
  - Observação: PROCTRAN pode ser entendida como registro de auditoria, o que a excluiria. Foi tratada como histórico de movimentações porque o tipo de movimentação é um conceito que a área de negócio reconhece.

Se nenhuma rejeição ocorre e o INSERT em PROCTRAN funciona, os saldos disponível e atual são atualizados com o valor e a operação termina com sucesso. Esse caminho não tem decisão de negócio própria e não é listado como regra.

## Regras de negócio

1. Regra: Uma operação sobre uma conta que não existe é recusada com o código de falha "1" (conta não encontrada).
   Condição: a consulta da conta pela agência e pelo número não encontra registro (SQLCODE = +100).
   Consequência: a operação não é concluída (COMM-SUCCESS = "N") e retorna o código de falha "1".
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)

2. Regra: Um débito com a facilidade 496 não é permitido em conta de financiamento imobiliário (MORTGAGE) ou de empréstimo (LOAN).
   Condição: o valor é negativo (COMM-AMT < 0), o tipo da conta é MORTGAGE ou LOAN e o tipo de facilidade é 496 (COMM-FACILTYPE).
   Consequência: a operação é recusada (COMM-SUCCESS = "N") com o código de falha "4", sem alterar os saldos.
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)

3. Regra: Um débito com a facilidade 496 é recusado por saldo insuficiente quando o saldo disponível não cobre o valor.
   Condição: o valor é negativo, o tipo de facilidade é 496 e o saldo disponível somado ao valor (WS-DIFFERENCE) fica menor que zero.
   Consequência: a operação é recusada (COMM-SUCCESS = "N") com o código de falha "3", sem alterar os saldos. O limite de cheque especial não entra no cálculo. Para outras facilidades, o programa não faz esse teste.
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)

4. Regra: Uma operação com a facilidade 496 não é permitida em conta de financiamento imobiliário (MORTGAGE) ou de empréstimo (LOAN), mesmo quando o valor não é negativo.
   Condição: o tipo da conta é MORTGAGE ou LOAN e o tipo de facilidade é 496. Para valores negativos, o programa já recusou a operação antes, pela regra 2. Este teste só tem efeito sobre valores iguais a zero ou positivos.
   Consequência: a operação é recusada (COMM-SUCCESS = "N") com o código de falha "4", sem alterar os saldos. Este teste repete a regra 2 em outro ponto do mesmo parágrafo.
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)

5. Regra: Um débito comum (sem a facilidade 496) é registrado no histórico como saque no balcão.
   Condição: o valor é negativo (COMM-AMT < 0) e o tipo de facilidade não é 496.
   Consequência: a movimentação é registrada com o tipo "DEB" e a descrição "COUNTER WTHDRW".
   Parágrafo: WRITE-TO-PROCTRAN-DB2 (WTPD010)

6. Regra: Um débito com a facilidade 496 é registrado no histórico como débito de pagamento, com a descrição vinda da origem informada.
   Condição: o valor é negativo e o tipo de facilidade é 496.
   Consequência: a movimentação é registrada com o tipo "PDR" e a descrição recebe os 14 primeiros caracteres da origem (COMM-ORIGIN).
   Parágrafo: WRITE-TO-PROCTRAN-DB2 (WTPD010)

7. Regra: Um crédito comum (sem a facilidade 496) é registrado no histórico como recebimento no balcão.
   Condição: o valor não é negativo (COMM-AMT >= 0) e o tipo de facilidade não é 496.
   Consequência: a movimentação é registrada com o tipo "CRE" e a descrição "COUNTER RECVED".
   Parágrafo: WRITE-TO-PROCTRAN-DB2 (WTPD010)

8. Regra: Um crédito com a facilidade 496 é registrado no histórico como crédito de pagamento, com a descrição vinda da origem informada.
   Condição: o valor não é negativo e o tipo de facilidade é 496.
   Consequência: a movimentação é registrada com o tipo "PCR" e a descrição recebe os 14 primeiros caracteres da origem (COMM-ORIGIN). Na prática, este caminho é difícil de alcançar em contas MORTGAGE ou LOAN, porque a regra 4 já recusou a operação antes.
   Parágrafo: WRITE-TO-PROCTRAN-DB2 (WTPD010)