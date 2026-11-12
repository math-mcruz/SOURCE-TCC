1. Regra: Se a conta informada não existe, a operação de débito/crédito é recusada.
   Condição: A consulta da conta pelo código da agência e número da conta não encontra registro (SQLCODE = +100).
   Consequência: A operação não é concluída (COMM-SUCCESS = 'N') e retorna o código de falha '1' (conta não encontrada).
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)

2. Regra: Débitos de facilidade tipo 496 não são permitidos em contas de hipoteca ou de empréstimo.
   Condição: Valor da operação negativo (COMM-AMT < 0), tipo da conta 'MORTGAGE' ou 'LOAN' e tipo de facilidade igual a 496 (COMM-FACILTYPE).
   Consequência: A operação é recusada (COMM-SUCCESS = 'N') com o código de falha '4' e o saldo não é alterado.
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)

3. Regra: Débitos de facilidade tipo 496 são recusados quando o saldo disponível não cobre o valor.
   Condição: Valor da operação negativo, tipo de facilidade igual a 496 e saldo disponível mais o valor da operação menor que zero (WS-DIFFERENCE < 0). O teste usa apenas o saldo disponível; o limite de cheque especial (overdraft) não é considerado. Para outros tipos de facilidade, o código não faz esse teste de saldo.
   Consequência: A operação é recusada (COMM-SUCCESS = 'N') com o código de falha '3' (fundos insuficientes) e o saldo não é alterado.
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)

4. Regra: Operações de facilidade tipo 496 não são permitidas em contas de hipoteca ou de empréstimo, também quando o valor não é um débito.
   Condição: Tipo da conta 'MORTGAGE' ou 'LOAN' e tipo de facilidade igual a 496. O teste é repetido depois da checagem de débito e não depende do sinal do valor. Para débitos ele é redundante com a regra 2; na prática, só alcança operações de valor não negativo (créditos).
   Consequência: A operação é recusada (COMM-SUCCESS = 'N') com o código de falha '4' e o saldo não é alterado.
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)

5. Regra: Um débito comum no balcão é registrado no histórico de transações como saque no balcão.
   Condição: Valor da operação negativo (COMM-AMT < 0) e tipo de facilidade diferente de 496.
   Consequência: A transação é registrada com tipo 'DEB' e descrição 'COUNTER WTHDRW'. (Ambíguo: o código não deixa claro se esse registro de histórico é considerado informação de negócio ou apenas registro técnico.)
   Parágrafo: WRITE-TO-PROCTRAN-DB2 (WTPD010)

6. Regra: Um débito de facilidade tipo 496 é registrado como pagamento de débito, com a origem informada na operação.
   Condição: Valor da operação negativo e tipo de facilidade igual a 496.
   Consequência: A transação é registrada com tipo 'PDR' e a descrição recebe os 14 primeiros caracteres da origem (COMM-ORIGIN).
   Parágrafo: WRITE-TO-PROCTRAN-DB2 (WTPD010)

7. Regra: Um crédito comum no balcão é registrado no histórico de transações como valor recebido no balcão.
   Condição: Valor da operação não negativo (COMM-AMT >= 0) e tipo de facilidade diferente de 496.
   Consequência: A transação é registrada com tipo 'CRE' e descrição 'COUNTER RECVED'.
   Parágrafo: WRITE-TO-PROCTRAN-DB2 (WTPD010)

8. Regra: Um crédito de facilidade tipo 496 é registrado como pagamento de crédito, com a origem informada na operação.
   Condição: Valor da operação não negativo e tipo de facilidade igual a 496.
   Consequência: A transação é registrada com tipo 'PCR' e a descrição recebe os 14 primeiros caracteres da origem (COMM-ORIGIN).
   Parágrafo: WRITE-TO-PROCTRAN-DB2 (WTPD010)

9. Regra: A operação só é confirmada como bem-sucedida se o registro da transação for gravado com sucesso.
   Condição: A gravação da transação no histórico retorna SQLCODE = 0.
   Consequência: A operação é confirmada (COMM-SUCCESS = 'Y') com código de falha '0'.
   Parágrafo: WRITE-TO-PROCTRAN-DB2 (WTPD010)