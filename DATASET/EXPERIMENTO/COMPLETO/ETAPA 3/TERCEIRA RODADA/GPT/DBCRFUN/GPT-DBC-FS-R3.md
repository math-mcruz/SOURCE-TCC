1\. Regra: Se a conta bancária informada não for encontrada, a operação não é realizada e é sinalizada como malsucedida com o código de falha '1'.\
Condição: a consulta da conta bancária retorna SQLCODE = +100.\
Consequência: a operação não é realizada; indicador de sucesso 'N' e código de falha '1'.\
Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2).

2\. Regra: Uma operação de débito com tipo de facilidade 496 não é permitida em contas dos tipos MORTGAGE ou LOAN, sendo rejeitada com o código de falha '4'.\
Condição: valor da operação negativo (COMM-AMT < 0), tipo de facilidade igual a 496 (COMM-FACILTYPE = 496) e tipo de conta MORTGAGE ou LOAN.\
Consequência: a operação não é realizada; indicador de sucesso 'N' e código de falha '4'.\
Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2).

3\. Regra: Uma operação de débito com tipo de facilidade 496 é rejeitada por insuficiência de saldo quando seu valor fizer o saldo disponível da conta ficar negativo, com código de falha '3'.\
Condição: valor da operação negativo, tipo de facilidade igual a 496, conta diferente de MORTGAGE e LOAN, e soma do saldo disponível com o valor da operação inferior a zero.\
Consequência: a operação não é realizada; indicador de sucesso 'N' e código de falha '3'.\
Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2).

4\. Regra: Uma operação de valor zero ou positivo com tipo de facilidade 496 não é permitida em contas dos tipos MORTGAGE ou LOAN, sendo rejeitada com o código de falha '4'.\
Condição: valor da operação maior ou igual a zero (COMM-AMT >= 0), tipo de facilidade igual a 496 e tipo de conta MORTGAGE ou LOAN.\
Consequência: a operação não é realizada; indicador de sucesso 'N' e código de falha '4'.\
Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2).

5\. Regra: Uma operação de valor negativo com tipo de facilidade diferente de 496 é classificada como débito de retirada no caixa, com o tipo 'DEB' e a descrição 'COUNTER WTHDRW'.\
Condição: valor da operação negativo (COMM-AMT < 0) e tipo de facilidade diferente de 496.\
Consequência: a transação é registrada com o tipo 'DEB' e a descrição 'COUNTER WTHDRW'.\
Parágrafo: WTPD010 (WRITE-TO-PROCTRAN-DB2).

6\. Regra: Uma operação de valor negativo com tipo de facilidade 496 é classificada como débito do tipo 'PDR', utilizando como descrição os primeiros 14 caracteres da origem informada.\
Condição: valor da operação negativo (COMM-AMT < 0) e tipo de facilidade igual a 496.\
Consequência: a transação é registrada com o tipo 'PDR' e a descrição obtida dos primeiros 14 caracteres de COMM-ORIGIN.\
Parágrafo: WTPD010 (WRITE-TO-PROCTRAN-DB2).

7\. Regra: Uma operação de valor zero ou positivo com tipo de facilidade diferente de 496 é classificada como crédito recebido no caixa, com o tipo 'CRE' e a descrição 'COUNTER RECVED'.\
Condição: valor da operação maior ou igual a zero (COMM-AMT >= 0) e tipo de facilidade diferente de 496.\
Consequência: a transação é registrada com o tipo 'CRE' e a descrição 'COUNTER RECVED'.\
Parágrafo: WTPD010 (WRITE-TO-PROCTRAN-DB2).

8\. Regra: Uma operação de valor zero ou positivo com tipo de facilidade 496 é classificada como crédito do tipo 'PCR', utilizando como descrição os primeiros 14 caracteres da origem informada.\
Condição: valor da operação maior ou igual a zero (COMM-AMT >= 0) e tipo de facilidade igual a 496.\
Consequência: a transação é registrada com o tipo 'PCR' e a descrição obtida dos primeiros 14 caracteres de COMM-ORIGIN.\
Parágrafo: WTPD010 (WRITE-TO-PROCTRAN-DB2).