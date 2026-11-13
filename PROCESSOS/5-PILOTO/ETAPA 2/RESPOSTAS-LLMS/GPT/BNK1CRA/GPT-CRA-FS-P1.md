1\. Regra: O número da conta informado deve ser diferente de zero. Caso seja zero, a solicitação é considerada inválida e o processamento não é realizado.\
Condição: o número da conta informado (ACCNOI) é igual a zero.\
Consequência: a solicitação é considerada inválida (VALID-DATA-SW = 'N') e é exibida a mensagem 'Please enter a non zero account number.'.\
Parágrafo: ED010 (EDIT-DATA)

2\. Regra: Quando o valor da operação for informado com sinal negativo, o valor será tratado como negativo para processamento na conta.\
Condição: o sinal informado (SIGNI) é igual a '-'.\
Consequência: o valor da operação é convertido para negativo antes de ser encaminhado ao processamento da conta.\
Parágrafo: UCD010 (UPD-CRED-DATA)

3\. Regra: Se a conta informada não for encontrada para o código de agência retornado pelo processamento, o valor solicitado não será aplicado à conta.\
Condição: o processamento da operação retorna insucesso (SUBPGM-SUCCESS = 'N') com código de falha '1' (SUBPGM-FAIL-CODE).\
Consequência: a operação é considerada malsucedida e é exibida a mensagem 'Sorry but the ACCOUNT no was not found for SORTCODE ... Amount not applied.', incluindo o código de agência retornado.\
Parágrafo: UCD010 (UPD-CRED-DATA)

4\. Regra: Se o valor da operação não puder ser aplicado à conta devido a um erro inesperado identificado pelo processamento, a operação será considerada malsucedida.\
Condição: o processamento retorna insucesso (SUBPGM-SUCCESS = 'N') com código de falha '2'.\
Consequência: a operação é considerada malsucedida e é exibida a mensagem 'Sorry but the AMOUNT could not be applied due to an unexpected error.'.\
Parágrafo: UCD010 (UPD-CRED-DATA)

5\. Regra: Quando não houver saldo disponível suficiente para realizar a operação solicitada, a operação não será concluída com sucesso.\
Condição: o processamento retorna insucesso (SUBPGM-SUCCESS = 'N') com código de falha '3'.\
Consequência: a operação é considerada malsucedida e é exibida a mensagem 'Sorry insufficient funds available to process the request.'.\
Parágrafo: UCD010 (UPD-CRED-DATA)

6\. Regra: Quando a operação não puder ser aplicada à conta por uma falha não identificada entre os códigos específicos previstos, a operação será considerada malsucedida.\
Condição: o processamento retorna insucesso (SUBPGM-SUCCESS = 'N') com código de falha diferente de '1', '2' e '3'.\
Consequência: a operação é considerada malsucedida e é exibida a mensagem 'Sorry but the AMOUNT could not be applied due to an unexpected error.', acompanhada do código de falha retornado.\
Parágrafo: UCD010 (UPD-CRED-DATA)

7\. Regra: Quando o processamento da operação não indicar insucesso, o valor será informado ao usuário como aplicado com sucesso à conta.\
Condição: o indicador de sucesso retornado pelo processamento (SUBPGM-SUCCESS) é diferente de 'N'.\
Consequência: é exibida a mensagem 'Amount successfully applied to the account.' e são apresentados o número da conta, o código da agência, o saldo atual e o saldo disponível retornados pelo processamento. O programa não exige explicitamente que o indicador seja 'Y'.\
Parágrafo: UCD010 (UPD-CRED-DATA)

8\. Regra: O valor da operação é obrigatório e não pode ser deixado sem preenchimento.\
Condição: o campo de valor da operação não foi preenchido (AMTL = ZERO).\
Consequência: a solicitação é considerada inválida (VALID-DATA-SW = 'N'), é exibida a mensagem 'The Amount entered must be numeric.' e o processamento do valor é interrompido.\
Parágrafo: VA010 (VALIDATE-AMOUNT)

9\. Regra: O valor da operação não pode conter apenas espaços em branco.\
Condição: todos os caracteres informados no campo de valor são espaços em branco (WS-NUM-COUNT-TOTAL = AMTL).\
Consequência: a solicitação é considerada inválida (VALID-DATA-SW = 'N'), é exibida a mensagem 'The Amount entered must be numeric.' e o processamento do valor é interrompido.\
Parágrafo: VA010 (VALIDATE-AMOUNT)

10\. Regra: O valor da operação deve respeitar o limite de duas casas decimais quando essa validação for executada.\
Condição: o valor informado contém um ponto decimal e a verificação de casas decimais identifica mais de duas casas (WS-NUM-COUNT-TOTAL > 2). Essa verificação ocorre somente no caminho em que o valor não foi reconhecido inicialmente como inteiramente numérico.\
Consequência: a solicitação é considerada inválida (VALID-DATA-SW = 'N'), é exibida a mensagem 'Only up to two decimal places are supported.' e o processamento do valor é interrompido.\
Parágrafo: VA010 (VALIDATE-AMOUNT)

11\. Regra: O valor da operação deve ser diferente de zero quando alcançar a validação final do valor.\
Condição: o valor convertido da operação (WS-AMOUNT-AS-FLOAT) é igual a zero, após passar pelas verificações anteriores. Essa regra não é aplicada ao caminho em que o conteúdo inicial é reconhecido como inteiramente numérico, pois nesse caso o programa encerra a validação antecipadamente.\
Consequência: a solicitação é considerada inválida (VALID-DATA-SW = 'N'), é exibida a mensagem 'Please supply a non-zero amount.' e o processamento do valor é interrompido.\
Parágrafo: VA010 (VALIDATE-AMOUNT)