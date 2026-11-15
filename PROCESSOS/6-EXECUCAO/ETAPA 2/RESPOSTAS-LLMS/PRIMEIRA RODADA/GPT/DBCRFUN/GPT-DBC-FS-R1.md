1\. Regra: Se a conta bancária informada não for encontrada, a operação é recusada com o código de falha '1'.\
Condição: a consulta da conta retorna código +100 (conta não encontrada).\
Consequência: a operação é considerada malsucedida, com indicador de sucesso 'N' e código de falha '1'.\
Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)

2\. Regra: Não é permitido realizar operações em contas do tipo MORTGAGE ou LOAN quando o tipo de facilidade informado é 496 e o valor da operação é negativo.\
Condição: valor da operação negativo (COMM-AMT < 0), tipo de facilidade igual a 496 e conta do tipo MORTGAGE ou LOAN.\
Consequência: a operação é recusada, com indicador de sucesso 'N' e código de falha '4'.\
Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)

3\. Regra: Uma operação de débito do tipo de facilidade 496 não é permitida quando seu valor faz o saldo disponível da conta ficar negativo.\
Condição: valor da operação negativo, tipo de facilidade igual a 496 e soma do saldo disponível com o valor da operação inferior a zero, desde que a conta não tenha sido recusada pela regra anterior.\
Consequência: a operação é recusada, com indicador de sucesso 'N' e código de falha '3'.\
Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)

4\. Regra: Não é permitido realizar operações em contas do tipo MORTGAGE ou LOAN quando o tipo de facilidade informado é 496, mesmo que a operação não tenha sido recusada nas verificações anteriores.\
Condição: conta do tipo MORTGAGE ou LOAN e tipo de facilidade igual a 496, após as verificações aplicáveis ao valor negativo.\
Consequência: a operação é recusada, com indicador de sucesso 'N' e código de falha '4'.\
Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)

5\. Regra: Quando o valor da operação é negativo, ela é classificada como débito, com identificação específica para operações do tipo de facilidade 496.\
Condição: valor da operação negativo e tipo de facilidade igual a 496.\
Consequência: a movimentação é classificada como 'PDR', utilizando a origem da operação como descrição.\
Parágrafo: WTPD010 (WRITE-TO-PROCTRAN-DB2)

6\. Regra: Quando o valor da operação é negativo e o tipo de facilidade é diferente de 496, a movimentação é classificada como retirada no caixa.\
Condição: valor da operação negativo e tipo de facilidade diferente de 496.\
Consequência: a movimentação é classificada como débito 'DEB', com descrição 'COUNTER WTHDRW'.\
Parágrafo: WTPD010 (WRITE-TO-PROCTRAN-DB2)

7\. Regra: Quando o valor da operação é positivo ou igual a zero e o tipo de facilidade é 496, a movimentação é classificada como crédito específico dessa facilidade.\
Condição: valor da operação maior ou igual a zero e tipo de facilidade igual a 496.\
Consequência: a movimentação é classificada como 'PCR', utilizando a origem da operação como descrição.\
Parágrafo: WTPD010 (WRITE-TO-PROCTRAN-DB2)

8\. Regra: Quando o valor da operação é positivo ou igual a zero e o tipo de facilidade é diferente de 496, a movimentação é classificada como recebimento no caixa.\
Condição: valor da operação maior ou igual a zero e tipo de facilidade diferente de 496.\
Consequência: a movimentação é classificada como crédito 'CRE', com descrição 'COUNTER RECVED'.\
Parágrafo: WTPD010 (WRITE-TO-PROCTRAN-DB2)

9\. Regra: Quando a movimentação da conta é registrada com sucesso, a operação é confirmada como bem-sucedida.\
Condição: o registro da movimentação na PROCTRAN é concluído com sucesso (SQLCODE igual a zero).\
Consequência: a operação recebe indicador de sucesso 'Y' e código de falha '0'.\
Parágrafo: WTPD010 (WRITE-TO-PROCTRAN-DB2)