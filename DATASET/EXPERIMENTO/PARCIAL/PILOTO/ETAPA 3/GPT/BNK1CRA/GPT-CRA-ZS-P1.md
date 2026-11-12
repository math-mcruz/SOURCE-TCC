1\. Regra: O número da conta deve ser diferente de zero.\
Condição: Quando o número da conta informado é igual a zero (`ACCNOI = ZERO`).\
Consequência: A solicitação é rejeitada e o cliente recebe uma mensagem solicitando um número de conta diferente de zero.\
Parágrafo: ED010

2\. Regra: O valor da operação é obrigatório.\
Condição: Quando o campo de valor não foi preenchido (`AMTL = ZERO`).\
Consequência: A solicitação é rejeitada e o cliente recebe uma mensagem solicitando o preenchimento do valor.\
Parágrafo: VA010

3\. Regra: O valor da operação não pode conter apenas espaços em branco.\
Condição: Quando todos os caracteres informados no campo de valor são espaços (`WS-NUM-COUNT-TOTAL = AMTL`).\
Consequência: A solicitação é rejeitada e o cliente recebe uma mensagem solicitando um valor válido.\
Parágrafo: VA010

4\. Regra: O valor da operação deve respeitar o limite de duas casas decimais.\
Condição: Quando o valor contém um ponto decimal, possui mais de dois caracteres após o ponto e a contagem adicional de dígitos realizada pelo programa também ultrapassa dois (`WS-NUM-COUNT-TOTAL > 2`).\
Consequência: A solicitação é rejeitada e o cliente recebe uma mensagem informando que são aceitas até duas casas decimais. A validação depende da contagem específica implementada no programa, que não equivale necessariamente a uma simples verificação da quantidade de casas decimais.\
Parágrafo: VA010

5\. Regra: O valor da operação deve ser diferente de zero.\
Condição: Quando o valor convertido é igual a zero (`WS-AMOUNT-AS-FLOAT = ZERO`), desde que tenha passado pelo fluxo de conversão que executa essa verificação.\
Consequência: A solicitação é rejeitada e o cliente recebe uma mensagem solicitando um valor diferente de zero. Valores reconhecidos diretamente como numéricos anteriormente não passam por essa verificação.\
Parágrafo: VA010

6\. Regra: Uma operação informada com sinal negativo deve ter seu valor tratado como negativo.\
Condição: Quando o sinal informado é menos (`SIGNI = '-'`).\
Consequência: O valor da operação é convertido para negativo antes de ser encaminhado para aplicação na conta.\
Parágrafo: UCD010

7\. Regra: Somente operações com dados considerados válidos são encaminhadas para aplicação na conta.\
Condição: Quando as validações dos dados da operação são concluídas com resultado válido (`VALID-DATA`).\
Consequência: A operação é encaminhada para processamento da atualização da conta.\
Parágrafo: PM010

8\. Regra: Operações com dados considerados inválidos não são encaminhadas para aplicação na conta.\
Condição: Quando alguma validação deixa os dados da operação em situação inválida (`VALID-DATA-SW = 'N'`).\
Consequência: O processamento da atualização da conta não é executado.\
Parágrafo: PM010

9\. Regra: Uma operação não pode ser aplicada quando a conta não é encontrada para o código de agência informado pelo processamento.\
Condição: Quando o processamento da operação retorna insucesso com código `1` (`SUBPGM-SUCCESS = 'N'` e `SUBPGM-FAIL-CODE = '1'`).\
Consequência: O valor não é aplicado e o cliente recebe uma mensagem informando que a conta não foi encontrada para o código de agência apresentado.\
Parágrafo: UCD010

10\. Regra: Uma operação não pode ser aplicada quando não existem fundos disponíveis suficientes.\
Condição: Quando o processamento da operação retorna insucesso com código `3` (`SUBPGM-SUCCESS = 'N'` e `SUBPGM-FAIL-CODE = '3'`).\
Consequência: A operação é recusada e o cliente recebe uma mensagem informando que não há fundos disponíveis suficientes para processar a solicitação.\
Parágrafo: UCD010

11\. Regra: Uma operação não é considerada aplicada quando o processamento informa um erro inesperado.\
Condição: Quando o processamento retorna insucesso com código `2` ou com outro código diferente de `1` e `3` (`SUBPGM-SUCCESS = 'N'`).\
Consequência: O cliente recebe uma mensagem informando que o valor não pôde ser aplicado devido a um erro inesperado. Para códigos não previstos, a mensagem também apresenta o código retornado.\
Parágrafo: UCD010

12\. Regra: Uma operação é apresentada como concluída com sucesso quando o processamento não informa insucesso.\
Condição: Quando o indicador de sucesso retornado pelo processamento é diferente de `N` (`SUBPGM-SUCCESS NOT = 'N'`).\
Consequência: O cliente recebe a confirmação de que o valor foi aplicado à conta. O programa também disponibiliza o saldo efetivo e o saldo disponível retornados pelo processamento.\
Parágrafo: UCD010