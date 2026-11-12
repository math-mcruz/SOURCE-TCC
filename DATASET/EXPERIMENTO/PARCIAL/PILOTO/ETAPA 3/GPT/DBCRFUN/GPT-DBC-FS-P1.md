1\. Regra: Se a conta bancária informada não for encontrada, a operação não é realizada e é sinalizada como malsucedida com o código de falha '1'.

&#x20;  Condição: a conta identificada pelo código bancário e número da conta não é encontrada (SQLCODE = +100).

&#x20;  Consequência: a operação não é realizada; indicador de sucesso 'N' e código de falha '1'.

&#x20;  Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2).

2\. Regra: Uma operação de débito com tipo de facilidade 496 não é permitida em contas do tipo MORTGAGE ou LOAN, sendo recusada com o código de falha '4'.

&#x20;  Condição: valor da operação negativo (COMM-AMT < 0), tipo de facilidade igual a 496 (COMM-FACILTYPE = 496) e tipo de conta MORTGAGE ou LOAN.

&#x20;  Consequência: a operação é recusada, sem alteração dos saldos; indicador de sucesso 'N' e código de falha '4'.

&#x20;  Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2).

3\. Regra: Uma operação de débito com tipo de facilidade 496 não pode deixar o saldo disponível da conta negativo, sendo recusada com o código de falha '3'.

&#x20;  Condição: valor da operação negativo (COMM-AMT < 0), tipo de facilidade igual a 496 e soma do saldo disponível com o valor da operação inferior a zero, desde que a operação não tenha sido recusada anteriormente por envolver uma conta MORTGAGE ou LOAN.

&#x20;  Consequência: a operação é recusada, sem alteração dos saldos; indicador de sucesso 'N' e código de falha '3'.

&#x20;  Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2).

4\. Regra: Uma operação de valor positivo ou zero com tipo de facilidade 496 não é permitida em contas do tipo MORTGAGE ou LOAN, sendo recusada com o código de falha '4'.

&#x20;  Condição: valor da operação maior ou igual a zero (COMM-AMT >= 0), tipo de facilidade igual a 496 e tipo de conta MORTGAGE ou LOAN.

&#x20;  Consequência: a operação é recusada, sem alteração dos saldos; indicador de sucesso 'N' e código de falha '4'.

&#x20;  Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2).

5\. Regra: Uma operação de valor negativo cujo tipo de facilidade seja diferente de 496 é registrada como retirada no caixa, com tipo de transação 'DEB' e descrição 'COUNTER WTHDRW'.

&#x20;  Condição: valor da operação negativo (COMM-AMT < 0) e tipo de facilidade diferente de 496.

&#x20;  Consequência: a transação é classificada como 'DEB', com descrição 'COUNTER WTHDRW'.

&#x20;  Parágrafo: WTPD010 (WRITE-TO-PROCTRAN-DB2).

6\. Regra: Uma operação de valor negativo com tipo de facilidade 496 é registrada como débito do tipo 'PDR', utilizando a origem da operação como descrição.

&#x20;  Condição: valor da operação negativo (COMM-AMT < 0) e tipo de facilidade igual a 496.

&#x20;  Consequência: a transação é classificada como 'PDR', com descrição formada pelos primeiros 14 caracteres da origem informada (COMM-ORIGIN).

&#x20;  Parágrafo: WTPD010 (WRITE-TO-PROCTRAN-DB2).

7\. Regra: Uma operação de valor positivo ou zero cujo tipo de facilidade seja diferente de 496 é registrada como recebimento no caixa, com tipo de transação 'CRE' e descrição 'COUNTER RECVED'.

&#x20;  Condição: valor da operação maior ou igual a zero (COMM-AMT >= 0) e tipo de facilidade diferente de 496.

&#x20;  Consequência: a transação é classificada como 'CRE', com descrição 'COUNTER RECVED'.

&#x20;  Parágrafo: WTPD010 (WRITE-TO-PROCTRAN-DB2).

8\. Regra: Uma operação de valor positivo ou zero com tipo de facilidade 496 é registrada como crédito do tipo 'PCR', utilizando a origem da operação como descrição.

&#x20;  Condição: valor da operação maior ou igual a zero (COMM-AMT >= 0) e tipo de facilidade igual a 496.

&#x20;  Consequência: a transação é classificada como 'PCR', com descrição formada pelos primeiros 14 caracteres da origem informada (COMM-ORIGIN).

&#x20;  Parágrafo: WTPD010 (WRITE-TO-PROCTRAN-DB2).

9\. Regra: Quando o registro da transação financeira é concluído com sucesso, a operação é confirmada como bem-sucedida.

&#x20;  Condição: a inclusão da transação financeira é concluída com sucesso (SQLCODE = 0).

&#x20;  Consequência: indicador de sucesso 'Y' e código de falha '0'.

&#x20;  Parágrafo: WTPD010 (WRITE-TO-PROCTRAN-DB2).