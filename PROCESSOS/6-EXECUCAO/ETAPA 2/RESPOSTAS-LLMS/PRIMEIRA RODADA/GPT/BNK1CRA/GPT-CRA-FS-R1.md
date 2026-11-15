1\. Regra: O número da conta deve ser diferente de zero para que a operação de crédito ou débito possa ser processada.\
Condição: o número da conta informado é igual a zero (ACCNOI = ZERO).\
Consequência: a operação não é processada, os dados são considerados inválidos e é exibida a mensagem "Please enter a non zero account number."\
Parágrafo: ED010 (EDIT-DATA)

2\. Regra: O valor da operação é obrigatório e deve ser informado para que a operação possa ser processada.\
Condição: o campo de valor da operação está vazio (AMTL = ZERO).\
Consequência: os dados são considerados inválidos, a operação não é processada e é exibida a mensagem "The Amount entered must be numeric."\
Parágrafo: VA010 (VALIDATE-AMOUNT)

3\. Regra: O valor da operação não pode conter apenas espaços em branco.\
Condição: todos os caracteres informados no campo de valor são espaços em branco (WS-NUM-COUNT-TOTAL = AMTL).\
Consequência: os dados são considerados inválidos, a operação não é processada e é exibida a mensagem "The Amount entered must be numeric."\
Parágrafo: VA010 (VALIDATE-AMOUNT)

4\. Regra: O valor da operação admite até duas casas decimais, e a operação é rejeitada quando a verificação adicional identifica mais de duas casas decimais. Há uma ambiguidade na implementação: a verificação adicional examina uma parte do valor que não contém o ponto decimal, de modo que a rejeição pode não ocorrer como pretendido.\
Condição: o valor possui ponto decimal, há mais de dois caracteres após esse ponto e a verificação adicional contabiliza mais de dois dígitos (WS-NUM-COUNT-TOTAL > 2).\
Consequência: caso essa condição seja satisfeita, os dados são considerados inválidos, a operação não é processada e é exibida a mensagem "Only up to two decimal places are supported."\
Parágrafo: VA010 (VALIDATE-AMOUNT)

5\. Regra: O valor da operação deve ser diferente de zero, quando submetido à validação final do valor convertido. Entretanto, valores compostos exclusivamente por dígitos seguem outro caminho de validação e podem ser aceitos mesmo quando iguais a zero.\
Condição: o valor convertido da operação é igual a zero (WS-AMOUNT-AS-FLOAT = ZERO), após passar pelas verificações anteriores sem ter sido aceito diretamente como numérico.\
Consequência: os dados são considerados inválidos, a operação não é processada e é exibida a mensagem "Please supply a non-zero amount."\
Parágrafo: VA010 (VALIDATE-AMOUNT)

6\. Regra: Quando a operação é identificada com sinal negativo, o valor é tratado como negativo para processamento na conta.\
Condição: o sinal informado para a operação é '-' (SIGNI = '-').\
Consequência: o valor é multiplicado por -1 e encaminhado como valor negativo para processamento da operação.\
Parágrafo: UCD010 (UPD-CRED-DATA)

7\. Regra: Quando a conta informada não é encontrada para o código bancário correspondente, o valor solicitado não é aplicado à conta.\
Condição: o processamento da operação retorna insucesso (SUBPGM-SUCCESS = 'N') com código de falha '1' (SUBPGM-FAIL-CODE = '1').\
Consequência: a operação é considerada malsucedida, o valor não é aplicado e é exibida a mensagem "Sorry but the ACCOUNT no was not found for SORTCODE [código bancário]. Amount not applied."\
Parágrafo: UCD010 (UPD-CRED-DATA)

8\. Regra: Quando o processamento da operação retorna uma falha inesperada identificada pelo código '2', o valor não é aplicado à conta.\
Condição: o processamento retorna insucesso (SUBPGM-SUCCESS = 'N') com código de falha '2' (SUBPGM-FAIL-CODE = '2').\
Consequência: a operação é considerada malsucedida, o valor não é aplicado e é exibida a mensagem "Sorry but the AMOUNT could not be applied due to an unexpected error."\
Parágrafo: UCD010 (UPD-CRED-DATA)

9\. Regra: Quando não há saldo disponível suficiente para realizar a operação solicitada, o valor não é aplicado à conta.\
Condição: o processamento retorna insucesso (SUBPGM-SUCCESS = 'N') com código de falha '3' (SUBPGM-FAIL-CODE = '3').\
Consequência: a operação é considerada malsucedida, o valor não é aplicado e é exibida a mensagem "Sorry insufficient funds available to process the request."\
Parágrafo: UCD010 (UPD-CRED-DATA)

10\. Regra: Quando a operação é recusada por um motivo não identificado entre os códigos de falha previstos, o valor não é aplicado à conta.\
Condição: o processamento retorna insucesso (SUBPGM-SUCCESS = 'N') com código de falha diferente de '1', '2' e '3'.\
Consequência: a operação é considerada malsucedida, o valor não é aplicado e é exibida a mensagem "Sorry but the AMOUNT could not be applied due to an unexpected error.", acompanhada do código de falha retornado.\
Parágrafo: UCD010 (UPD-CRED-DATA)

11\. Regra: Quando o processamento da operação não indica insucesso, o valor é considerado aplicado à conta e a operação é apresentada como bem-sucedida.\
Condição: o indicador de sucesso retornado pelo processamento é diferente de 'N' (SUBPGM-SUCCESS NOT = 'N').\
Consequência: é exibida a mensagem "Amount successfully applied to the account.", e são apresentados o número da conta, o código bancário, o saldo atual e o saldo disponível retornados pelo processamento. O código considera qualquer valor diferente de 'N' como sucesso.\
Parágrafo: UCD010 (UPD-CRED-DATA)