1\. Regra: O número da conta informado deve ser diferente de zero. Caso seja zero, a solicitação é considerada inválida e não é processada.\
Condição: número da conta igual a zero (ACCNOI = ZERO).\
Consequência: solicitação inválida, com a mensagem 'Please enter a non zero account number.'; o processamento é interrompido.\
Parágrafo: ED010 (EDIT-DATA)

2\. Regra: O valor da operação é obrigatório. Caso não seja informado, a solicitação é considerada inválida e não é processada.\
Condição: campo de valor da operação sem conteúdo (AMTL = ZERO).\
Consequência: solicitação inválida, com a mensagem 'The Amount entered must be numeric.'; a validação é interrompida.\
Parágrafo: VA010 (VALIDATE-AMOUNT)

3\. Regra: O valor da operação não pode ser preenchido apenas com espaços. Caso isso aconteça, a solicitação é considerada inválida.\
Condição: todos os caracteres informados no campo de valor são espaços (WS-NUM-COUNT-TOTAL = AMTL).\
Consequência: solicitação inválida, com a mensagem 'The Amount entered must be numeric.'; a validação é interrompida.\
Parágrafo: VA010 (VALIDATE-AMOUNT)

4\. Regra: O valor da operação admite no máximo duas casas decimais. Caso o valor informado ultrapasse esse limite, a solicitação é considerada inválida.\
Condição: valor com ponto decimal e mais de duas casas decimais, conforme a contagem realizada pelo programa (WS-NUM-COUNT-TOTAL > 2).\
Consequência: solicitação inválida, com a mensagem 'Only up to two decimal places are supported.'; a validação é interrompida.\
Parágrafo: VA010 (VALIDATE-AMOUNT)

5\. Regra: O valor da operação deve ser diferente de zero. Caso seja zero, a solicitação é considerada inválida. Essa verificação ocorre apenas no caminho de validação que não reconhece inicialmente o conteúdo inteiro como numérico.\
Condição: valor convertido igual a zero (WS-AMOUNT-AS-FLOAT = ZERO), após passar pelas verificações anteriores do caminho de validação.\
Consequência: solicitação inválida, com a mensagem 'Please supply a non-zero amount.'; a validação é interrompida.\
Parágrafo: VA010 (VALIDATE-AMOUNT)

6\. Regra: Quando o valor da operação é precedido pelo sinal negativo, o valor encaminhado para aplicação na conta é negativo.\
Condição: sinal informado igual a '-' (SIGNI = '-').\
Consequência: o valor da operação é convertido para negativo antes de ser encaminhado ao processamento da conta.\
Parágrafo: UCD010 (UPD-CRED-DATA)

7\. Regra: Quando a conta informada não é encontrada para o código bancário retornado, o valor solicitado não é aplicado à conta.\
Condição: processamento da operação malsucedido (SUBPGM-SUCCESS = 'N') com código de falha '1' (SUBPGM-FAIL-CODE = '1').\
Consequência: a operação é considerada malsucedida e é exibida a mensagem 'Sorry but the ACCOUNT no was not found for SORTCODE [código bancário]. Amount not applied.'.\
Parágrafo: UCD010 (UPD-CRED-DATA)

8\. Regra: Quando não há saldo disponível suficiente para realizar a operação solicitada, a operação não é concluída.\
Condição: processamento da operação malsucedido (SUBPGM-SUCCESS = 'N') com código de falha '3' (SUBPGM-FAIL-CODE = '3').\
Consequência: a operação é considerada malsucedida e é exibida a mensagem 'Sorry insufficient funds available to process the request.'.\
Parágrafo: UCD010 (UPD-CRED-DATA)

9\. Regra: Quando o processamento da operação não retorna indicação de insucesso, o valor é considerado aplicado com sucesso à conta.\
Condição: indicador de sucesso do processamento diferente de 'N' (SUBPGM-SUCCESS NOT = 'N').\
Consequência: é exibida a mensagem 'Amount successfully applied to the account.' e são apresentados o número da conta, o código bancário, o saldo atual e o saldo disponível retornados pelo processamento.\
Parágrafo: UCD010 (UPD-CRED-DATA)