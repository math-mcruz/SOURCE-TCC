1\. Regra: Uma movimentação financeira não pode ser realizada quando a conta bancária informada não existe.\
Condição: Quando não é encontrada uma conta correspondente ao código da agência e ao número da conta informados (SQLCODE = +100).\
Consequência: A movimentação é rejeitada, com indicação de insucesso e código de falha 1.\
Parágrafo: UAD010

2\. Regra: Uma movimentação de débito do tipo 496 não é permitida em contas de financiamento imobiliário ou empréstimo.\
Condição: Quando o valor da movimentação é negativo (COMM-AMT < 0), o tipo de operação é 496 (COMM-FACILTYPE = 496) e a conta é do tipo MORTGAGE ou LOAN.\
Consequência: A movimentação é rejeitada, com indicação de insucesso e código de falha 4.\
Parágrafo: UAD010

3\. Regra: Uma movimentação de débito do tipo 496 não pode deixar o saldo disponível da conta negativo.\
Condição: Quando o valor da movimentação é negativo, o tipo de operação é 496, a conta não é do tipo MORTGAGE nem LOAN e a soma do saldo disponível com o valor da movimentação é inferior a zero.\
Consequência: A movimentação é rejeitada por insuficiência de saldo disponível, com indicação de insucesso e código de falha 3.\
Parágrafo: UAD010

4\. Regra: Uma movimentação de débito cujo tipo de operação é diferente de 496 pode prosseguir mesmo que o saldo disponível fique negativo.\
Condição: Quando o valor da movimentação é negativo e o tipo de operação é diferente de 496, independentemente de a soma do saldo disponível com o valor da movimentação ser negativa.\
Consequência: A movimentação não é rejeitada por insuficiência de saldo, podendo prosseguir para a atualização dos saldos da conta.\
Parágrafo: UAD010

5\. Regra: Uma movimentação de valor não negativo do tipo 496 não é permitida em contas de financiamento imobiliário ou empréstimo.\
Condição: Quando o valor da movimentação é maior ou igual a zero, o tipo de operação é 496 e a conta é do tipo MORTGAGE ou LOAN.\
Consequência: A movimentação é rejeitada, com indicação de insucesso e código de falha 4.\
Parágrafo: UAD010

6\. Regra: Uma movimentação de débito comum deve ser identificada como retirada em caixa.\
Condição: Quando o valor da movimentação é negativo e o tipo de operação é diferente de 496.\
Consequência: A movimentação é registrada com o tipo DEB e a descrição "COUNTER WTHDRW".\
Parágrafo: WTPD010

7\. Regra: Uma movimentação de débito do tipo 496 deve receber uma identificação específica.\
Condição: Quando o valor da movimentação é negativo e o tipo de operação é 496.\
Consequência: A movimentação é registrada com o tipo PDR e uma descrição formada pelos primeiros 14 caracteres da origem da operação (COMM-ORIGIN).\
Parágrafo: WTPD010

8\. Regra: Uma movimentação de crédito comum deve ser identificada como recebimento em caixa.\
Condição: Quando o valor da movimentação é maior ou igual a zero e o tipo de operação é diferente de 496.\
Consequência: A movimentação é registrada com o tipo CRE e a descrição "COUNTER RECVED".\
Parágrafo: WTPD010

9\. Regra: Uma movimentação de crédito do tipo 496 deve receber uma identificação específica.\
Condição: Quando o valor da movimentação é maior ou igual a zero e o tipo de operação é 496.\
Consequência: A movimentação é registrada com o tipo PCR e uma descrição formada pelos primeiros 14 caracteres da origem da operação (COMM-ORIGIN).\
Parágrafo: WTPD010

10\. Regra: Uma movimentação financeira deve ser considerada concluída com sucesso quando seu registro de transação é realizado com sucesso.\
Condição: Quando a atualização dos saldos da conta foi realizada e o registro da movimentação foi incluído com sucesso (SQLCODE = 0 na inclusão em PROCTRAN).\
Consequência: A movimentação é confirmada como bem-sucedida, com indicador de sucesso Y e código de falha 0.\
Parágrafo: WTPD010