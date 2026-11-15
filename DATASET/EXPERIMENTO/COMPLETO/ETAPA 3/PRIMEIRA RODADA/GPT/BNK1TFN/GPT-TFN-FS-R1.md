1\. Regra: Em uma transferência bancária, a conta de origem deve ser diferente da conta de destino. Caso sejam iguais, a transferência não é processada e os dados são considerados inválidos.\
Condição: o número da conta de origem é igual ao número da conta de destino (FACCNOI = TACCNOI).\
Consequência: a operação é interrompida, os dados são considerados inválidos e é exibida a mensagem 'The FROM & TO account should be different'.\
Parágrafo: ED010 (EDIT-DATA)

2\. Regra: O número de conta '00000000' não é aceito como conta de origem nem como conta de destino de uma transferência bancária.\
Condição: o número da conta de origem ou da conta de destino é igual a '00000000'.\
Consequência: a operação é interrompida, os dados são considerados inválidos e é exibida a mensagem 'Account no 00000000 is not valid'.\
Parágrafo: ED010 (EDIT-DATA)

3\. Regra: O valor da transferência bancária é obrigatório e não pode ficar vazio.\
Condição: o campo de valor da transferência não foi preenchido (AMTL = ZERO).\
Consequência: os dados são considerados inválidos, é exibida a mensagem 'The Amount entered must be numeric.' e a validação do valor é interrompida.\
Parágrafo: VA010 (VALIDATE-AMOUNT)

4\. Regra: O valor informado para uma transferência bancária deve ser maior que zero.\
Condição: o valor informado é numérico e seu valor convertido é menor ou igual a zero (WS-AMOUNT-AS-FLOAT  0).\
Consequência: os dados são considerados inválidos, é exibida a mensagem 'Please supply a positive amount.' e a validação do valor é interrompida.\
Parágrafo: VA010 (VALIDATE-AMOUNT)

7\. Regra: O valor da transferência bancária admite no máximo duas casas decimais.\
Condição: o valor informado contém um ponto decimal, possui mais de dois caracteres após esse ponto e a contagem adicional de dígitos realizada pelo programa é superior a dois (WS-NUM-COUNT-TOTAL > 2). A contagem implementada não corresponde diretamente à quantidade total de casas decimais, portanto a rejeição de todos os valores com mais de duas casas não é garantida.\
Consequência: os dados são considerados inválidos, é exibida a mensagem 'Only up to two decimal places are supported.' e a validação do valor é interrompida.\
Parágrafo: VA010 (VALIDATE-AMOUNT)

8\. Regra: O valor de uma transferência bancária não pode ser igual a zero após sua conversão para valor numérico.\
Condição: após o tratamento do valor informado, o resultado da conversão é igual a zero (WS-AMOUNT-AS-FLOAT = ZERO).\
Consequência: os dados são considerados inválidos, é exibida a mensagem 'Please supply a non-zero amount.' e a validação do valor é interrompida.\
Parágrafo: VA010 (VALIDATE-AMOUNT)

9\. Regra: Se a conta de origem de uma transferência não for encontrada, a transferência não é efetivada.\
Condição: o processamento da transferência retorna indicador de insucesso 'N' (SUBPGM-SUCCESS = 'N') e código de falha '1' (SUBPGM-FAIL-CODE = '1').\
Consequência: a transferência é considerada não realizada, os dados são marcados como inválidos e é exibida a mensagem 'Sorry the FROM ACCOUNT no was not found. Transfer not applied.'.\
Parágrafo: GCD010 (GET-ACC-DATA)

10\. Regra: Se a conta de destino de uma transferência não for encontrada, a transferência não é efetivada.\
Condição: o processamento da transferência retorna indicador de insucesso 'N' (SUBPGM-SUCCESS = 'N') e código de falha '2' (SUBPGM-FAIL-CODE = '2').\
Consequência: a transferência é considerada não realizada, os dados são marcados como inválidos e é exibida a mensagem 'Sorry the TO ACCOUNT no was not found. Transfer not applied.'.\
Parágrafo: GCD010 (GET-ACC-DATA)

11\. Regra: Quando o processamento de uma transferência retorna o código de falha '3', a operação não é confirmada como realizada.\
Condição: o processamento da transferência retorna indicador de insucesso 'N' (SUBPGM-SUCCESS = 'N') e código de falha '3' (SUBPGM-FAIL-CODE = '3').\
Consequência: os dados são marcados como inválidos e a mensagem inicial de erro inesperado é substituída pela mensagem 'Sorry but the transfer could not be applied unable to determine success.', indicando que não foi possível determinar o sucesso da operação.\
Parágrafo: GCD010 (GET-ACC-DATA)

12\. Regra: Se o processamento da transferência indicar que o valor informado deve ser maior que zero, a transferência não é efetivada.\
Condição: o processamento da transferência retorna indicador de insucesso 'N' (SUBPGM-SUCCESS = 'N') e código de falha '4' (SUBPGM-FAIL-CODE = '4').\
Consequência: os dados são marcados como inválidos e é exibida a mensagem 'Please supply an amount greater than zero.', sem confirmação da transferência.\
Parágrafo: GCD010 (GET-ACC-DATA)

13\. Regra: Quando o processamento da transferência retorna um código de falha não reconhecido, a transferência é considerada não realizada.\
Condição: o processamento da transferência retorna indicador de insucesso 'N' (SUBPGM-SUCCESS = 'N') e código de falha diferente de '1', '2', '3' e '4'.\
Consequência: os dados são marcados como inválidos e é exibida a mensagem 'Sorry but the transfer could not be applied due to an error.'.\
Parágrafo: GCD010 (GET-ACC-DATA)

14\. Regra: Quando o processamento da transferência não retorna uma confirmação de sucesso nem o indicador explícito de insucesso, a operação não pode ser confirmada como realizada.\
Condição: o indicador de sucesso da transferência é diferente de 'N' e de 'Y' (SUBPGM-SUCCESS NOT = 'N' e SUBPGM-SUCCESS NOT = 'Y').\
Consequência: é exibida a mensagem 'Sorry but the transfer could not be applied unable to determine success.' e o processamento de apresentação do resultado é interrompido.\
Parágrafo: GCD010 (GET-ACC-DATA)

15\. Regra: Quando o processamento da transferência confirma seu sucesso, a operação é informada como realizada.\
Condição: o processamento da transferência retorna indicador de sucesso 'Y' (SUBPGM-SUCCESS = 'Y').\
Consequência: é exibida a mensagem 'Transfer successfully applied.' e são apresentados os saldos disponíveis e efetivos das contas de origem e destino retornados pelo processamento.\
Parágrafo: GCD010 (GET-ACC-DATA)