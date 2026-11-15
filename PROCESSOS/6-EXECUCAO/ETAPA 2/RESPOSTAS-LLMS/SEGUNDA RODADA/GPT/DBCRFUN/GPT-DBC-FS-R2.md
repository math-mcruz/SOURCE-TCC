1\. Regra: Se a conta bancária informada não for encontrada, a operação financeira não é realizada e é sinalizada como malsucedida com o código de falha '1'.\
Condição: a consulta da conta bancária retorna código +100 (conta não encontrada).\
Consequência: a operação não é realizada; indicador de sucesso 'N' e código de falha '1'.\
Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)

2\. Regra: Uma operação de valor negativo não é permitida em contas do tipo MORTGAGE ou LOAN quando o tipo de facilidade é 496.\
Condição: valor da operação negativo (COMM-AMT < 0), tipo de conta MORTGAGE ou LOAN e tipo de facilidade igual a 496 (COMM-FACILTYPE = 496).\
Consequência: a operação é rejeitada, sem alteração dos saldos; indicador de sucesso 'N' e código de falha '4'.\
Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)

3\. Regra: Uma operação de valor negativo com tipo de facilidade 496 não é permitida quando seu valor faz o saldo disponível da conta ficar negativo.\
Condição: valor da operação negativo, tipo de facilidade igual a 496, conta não rejeitada pela restrição anterior e soma do saldo disponível com o valor da operação inferior a zero.\
Consequência: a operação é rejeitada por insuficiência de saldo disponível, sem alteração dos saldos; indicador de sucesso 'N' e código de falha '3'.\
Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)

4\. Regra: Uma operação de valor zero ou positivo não é permitida em contas do tipo MORTGAGE ou LOAN quando o tipo de facilidade é 496.\
Condição: valor da operação maior ou igual a zero, tipo de conta MORTGAGE ou LOAN e tipo de facilidade igual a 496.\
Consequência: a operação é rejeitada, sem alteração dos saldos; indicador de sucesso 'N' e código de falha '4'.\
Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)

5\. Regra: Uma operação financeira de valor negativo, com tipo de facilidade diferente de 496, é classificada como débito de retirada no caixa (DEB), com a descrição 'COUNTER WTHDRW'.\
Condição: valor da operação negativo (COMM-AMT < 0) e tipo de facilidade diferente de 496, após a atualização da conta.\
Consequência: a transação é registrada com tipo 'DEB', descrição 'COUNTER WTHDRW' e o valor da operação.\
Parágrafo: WTPD010 (WRITE-TO-PROCTRAN-DB2)

6\. Regra: Uma operação financeira de valor negativo, com tipo de facilidade 496, é classificada como débito do tipo PDR, utilizando a origem informada na operação como descrição.\
Condição: valor da operação negativo (COMM-AMT < 0) e tipo de facilidade igual a 496, após a aprovação e atualização da conta.\
Consequência: a transação é registrada com tipo 'PDR', descrição correspondente aos 14 primeiros caracteres da origem informada (COMM-ORIGIN) e o valor da operação.\
Parágrafo: WTPD010 (WRITE-TO-PROCTRAN-DB2)

7\. Regra: Uma operação financeira de valor zero ou positivo, com tipo de facilidade diferente de 496, é classificada como crédito de recebimento no caixa (CRE), com a descrição 'COUNTER RECVED'.\
Condição: valor da operação maior ou igual a zero (COMM-AMT >= 0) e tipo de facilidade diferente de 496, após a atualização da conta.\
Consequência: a transação é registrada com tipo 'CRE', descrição 'COUNTER RECVED' e o valor da operação.\
Parágrafo: WTPD010 (WRITE-TO-PROCTRAN-DB2)

8\. Regra: Uma operação financeira de valor zero ou positivo, com tipo de facilidade 496, é classificada como crédito do tipo PCR, utilizando a origem informada na operação como descrição.\
Condição: valor da operação maior ou igual a zero (COMM-AMT >= 0) e tipo de facilidade igual a 496, após a aprovação e atualização da conta.\
Consequência: a transação é registrada com tipo 'PCR', descrição correspondente aos 14 primeiros caracteres da origem informada (COMM-ORIGIN) e o valor da operação.\
Parágrafo: WTPD010 (WRITE-TO-PROCTRAN-DB2)