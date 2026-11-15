1\. Regra: O número da conta bancária deve ser diferente de zero. Caso seja informado zero, a solicitação é considerada inválida e o processamento é interrompido.\
Condição: número da conta informado igual a zero (ACCNOI = ZERO).\
Consequência: a solicitação é considerada inválida e é exibida a mensagem "Please enter a non zero account number.", sem prosseguir com a validação do valor.\
Parágrafo: ED010 (EDIT-DATA)

2\. Regra: O valor da operação deve ser informado obrigatoriamente. Caso o campo esteja vazio, a solicitação é considerada inválida.\
Condição: campo do valor da operação sem conteúdo (AMTL = ZERO).\
Consequência: a solicitação é considerada inválida e é exibida a mensagem "The Amount entered must be numeric.", sem prosseguir com as demais validações do valor.\
Parágrafo: VA010 (VALIDATE-AMOUNT)

3\. Regra: O valor da operação não pode ser preenchido somente com espaços. Caso isso ocorra, a solicitação é considerada inválida.\
Condição: todos os caracteres informados no campo do valor da operação são espaços (WS-NUM-COUNT-TOTAL = AMTL).\
Consequência: a solicitação é considerada inválida e é exibida a mensagem "The Amount entered must be numeric.", sem prosseguir com as demais validações do valor.\
Parágrafo: VA010 (VALIDATE-AMOUNT)

4\. Regra: O valor da operação deve respeitar o limite de duas casas decimais. Caso sejam identificados mais de dois dígitos decimais na verificação realizada pelo programa, a solicitação é considerada inválida.\
Condição: o valor informado contém um ponto decimal, possui mais de dois caracteres após esse ponto e a contagem adicional realizada pelo programa identifica mais de dois dígitos (WS-NUM-COUNT-TOTAL > 2).\
Consequência: a solicitação é considerada inválida e é exibida a mensagem "Only up to two decimal places are supported.", sem prosseguir com a operação.\
Parágrafo: VA010 (VALIDATE-AMOUNT)

5\. Regra: O valor da operação deve ser diferente de zero. Caso o valor convertido seja zero, a solicitação é considerada inválida. Essa rejeição ocorre apenas no caminho de validação que não reconheceu inicialmente o conteúdo do campo como inteiramente numérico.\
Condição: valor convertido da operação igual a zero (WS-AMOUNT-AS-FLOAT = ZERO), após passar pelas validações anteriores sem utilizar o caminho de aceitação direta de conteúdo numérico.\
Consequência: a solicitação é considerada inválida e é exibida a mensagem "Please supply a non-zero amount.", sem aplicar a operação à conta.\
Parágrafo: VA010 (VALIDATE-AMOUNT)

6\. Regra: Quando a conta bancária informada não é encontrada para o código bancário (SORTCODE) retornado, o valor da operação não é aplicado à conta.\
Condição: o processamento da operação retorna indicador de insucesso (SUBPGM-SUCCESS = 'N') e código de falha '1' (SUBPGM-FAIL-CODE = '1').\
Consequência: a operação é considerada malsucedida e é exibida a mensagem "Sorry but the ACCOUNT no was not found for SORTCODE [código]. Amount not applied.", informando que o valor não foi aplicado.\
Parágrafo: UCD010 (UPD-CRED-DATA)

7\. Regra: Quando o processamento bancário retorna o código de falha '2', a operação é considerada malsucedida e o valor não pode ser aplicado à conta.\
Condição: o processamento da operação retorna indicador de insucesso (SUBPGM-SUCCESS = 'N') e código de falha '2' (SUBPGM-FAIL-CODE = '2').\
Consequência: a operação é considerada malsucedida e é exibida a mensagem "Sorry but the AMOUNT could not be applied due to an unexpected error.", sem confirmar a aplicação do valor.\
Parágrafo: UCD010 (UPD-CRED-DATA)

8\. Regra: Quando não existem fundos disponíveis suficientes para processar a operação, a solicitação é recusada.\
Condição: o processamento da operação retorna indicador de insucesso (SUBPGM-SUCCESS = 'N') e código de falha '3' (SUBPGM-FAIL-CODE = '3').\
Consequência: a operação é considerada malsucedida e é exibida a mensagem "Sorry insufficient funds available to process the request.", informando a insuficiência de fundos disponíveis.\
Parágrafo: UCD010 (UPD-CRED-DATA)

9\. Regra: Quando o processamento bancário retorna um código de falha diferente dos códigos '1', '2' e '3', a operação é considerada malsucedida e o valor não pode ser aplicado à conta.\
Condição: o processamento da operação retorna indicador de insucesso (SUBPGM-SUCCESS = 'N') e código de falha diferente de '1', '2' e '3'.\
Consequência: a operação é considerada malsucedida e é exibida a mensagem "Sorry but the AMOUNT could not be applied due to an unexpected error.", acompanhada do código de falha retornado, sem confirmar a aplicação do valor.\
Parágrafo: UCD010 (UPD-CRED-DATA)

10\. Regra: Quando o processamento bancário não retorna o indicador de insucesso 'N', a aplicação do valor à conta é apresentada como bem-sucedida.\
Condição: o indicador de sucesso retornado pelo processamento é diferente de 'N' (SUBPGM-SUCCESS NOT = 'N').\
Consequência: é exibida a mensagem "Amount successfully applied to the account." e são apresentados o número da conta, o código bancário, o saldo atual e o saldo disponível retornados pelo processamento. O programa não verifica explicitamente se o indicador possui o valor 'Y'.\
Parágrafo: UCD010 (UPD-CRED-DATA)