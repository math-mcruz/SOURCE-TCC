1\. Regra: O número da conta bancária deve ser diferente de zero.\
Condição: Quando o número da conta informado é igual a zero.\
Consequência: A solicitação é rejeitada, e o cliente recebe uma mensagem solicitando um número de conta diferente de zero.\
Parágrafo: ED010

2\. Regra: O valor da operação bancária é obrigatório.\
Condição: Quando o campo de valor da operação não foi preenchido (AMTL = ZERO).\
Consequência: A solicitação é rejeitada, e o cliente recebe uma mensagem solicitando o preenchimento do valor.\
Parágrafo: VA010

3\. Regra: O valor da operação bancária não pode conter apenas espaços em branco.\
Condição: Quando todo o conteúdo informado no campo de valor é composto por espaços em branco (WS-NUM-COUNT-TOTAL = AMTL).\
Consequência: A solicitação é rejeitada, e o cliente recebe uma mensagem solicitando um valor válido.\
Parágrafo: VA010

4\. Regra: O valor da operação bancária deve possuir no máximo duas casas decimais.\
Condição: Quando a verificação identifica mais de duas casas decimais no valor informado (WS-NUM-COUNT-TOTAL > 2).\
Consequência: A solicitação é rejeitada, e o cliente recebe uma mensagem informando que somente até duas casas decimais são permitidas.\
Parágrafo: VA010

5\. Regra: O valor da operação bancária deve ser diferente de zero.\
Condição: Quando o valor convertido é igual a zero (WS-AMOUNT-AS-FLOAT = ZERO), após passar pelas verificações anteriores sem ser aceito pelo caminho de conteúdo inteiramente numérico.\
Consequência: A solicitação é rejeitada, e o cliente recebe uma mensagem solicitando um valor diferente de zero. O código permite, entretanto, que um valor inteiramente numérico igual a zero seja aceito por um caminho anterior.\
Parágrafo: VA010

6\. Regra: Somente solicitações com dados considerados válidos podem ser encaminhadas para processamento da operação bancária.\
Condição: Quando os dados informados são considerados válidos (VALID-DATA).\
Consequência: A solicitação é encaminhada para processamento da operação na conta bancária.\
Parágrafo: PM010

7\. Regra: Solicitações com dados considerados inválidos não são encaminhadas para processamento da operação bancária.\
Condição: Quando os dados informados não são considerados válidos (VALID-DATA não atendida).\
Consequência: A operação bancária não é encaminhada para processamento.\
Parágrafo: PM010

8\. Regra: Uma operação informada com sinal negativo deve ser tratada como um valor negativo.\
Condição: Quando o sinal informado para a operação é negativo (SIGNI = '-').\
Consequência: O valor da operação é convertido para negativo antes de ser encaminhado para processamento na conta bancária.\
Parágrafo: UCD010

9\. Regra: Uma operação bancária não pode ser aplicada quando a conta informada não é encontrada.\
Condição: Quando o processamento retorna insucesso (SUBPGM-SUCCESS = 'N') com código de falha '1'.\
Consequência: O valor não é aplicado à conta, e o cliente recebe uma mensagem informando que a conta não foi encontrada para o código bancário (SORTCODE) retornado.\
Parágrafo: UCD010

10\. Regra: Uma operação bancária não é aplicada quando o processamento informa um erro inesperado identificado pelo código '2'.\
Condição: Quando o processamento retorna insucesso (SUBPGM-SUCCESS = 'N') com código de falha '2'.\
Consequência: O valor não é aplicado à conta, e o cliente recebe uma mensagem informando que a operação não pôde ser realizada devido a um erro inesperado.\
Parágrafo: UCD010

11\. Regra: Uma operação bancária não pode ser realizada quando os fundos disponíveis são insuficientes.\
Condição: Quando o processamento retorna insucesso (SUBPGM-SUCCESS = 'N') com código de falha '3'.\
Consequência: A operação não é aplicada à conta, e o cliente recebe uma mensagem informando que não existem fundos disponíveis suficientes para atender à solicitação.\
Parágrafo: UCD010

12\. Regra: Uma operação bancária não é aplicada quando o processamento informa uma falha não identificada pelos códigos específicos previstos.\
Condição: Quando o processamento retorna insucesso (SUBPGM-SUCCESS = 'N') com código de falha diferente de '1', '2' e '3'.\
Consequência: O valor não é aplicado à conta, e o cliente recebe uma mensagem de erro inesperado acompanhada do código de falha retornado.\
Parágrafo: UCD010

13\. Regra: Uma operação bancária considerada bem-sucedida deve ser confirmada ao cliente.\
Condição: Quando o processamento não retorna o indicador de insucesso (SUBPGM-SUCCESS diferente de 'N').\
Consequência: O cliente recebe uma mensagem confirmando que o valor foi aplicado à conta, juntamente com a identificação da conta, o código bancário, o saldo atual e o saldo disponível retornados pelo processamento.\
Parágrafo: UCD010