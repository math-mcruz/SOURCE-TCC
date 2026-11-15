1\. Regra: A conta de origem e a conta de destino de uma transferência bancária devem ser diferentes. Se forem iguais, a transferência não é processada.\
Condição: o número da conta de origem (FACCNOI) é igual ao número da conta de destino (TACCNOI).\
Consequência: os dados são considerados inválidos e é exibida a mensagem "The FROM & TO account should be different".\
Parágrafo: ED010 (EDIT-DATA)

2\. Regra: O número de conta '00000000' não é aceito como conta de origem nem como conta de destino de uma transferência.\
Condição: o número da conta de origem ou da conta de destino é '00000000'.\
Consequência: os dados são considerados inválidos e é exibida a mensagem "Account no 00000000 is not valid".\
Parágrafo: ED010 (EDIT-DATA)

3\. Regra: A transferência bancária somente é encaminhada para processamento quando os dados informados são considerados válidos.\
Condição: as validações dos dados da transferência são concluídas com resultado válido (VALID-DATA).\
Consequência: a transferência é encaminhada para processamento, com a consulta das contas envolvidas e a tentativa de efetivação da operação.\
Parágrafo: PM010 (PROCESS-MAP)

4\. Regra: O valor da transferência bancária é obrigatório e não pode ficar vazio.\
Condição: o campo de valor da transferência não foi preenchido (AMTL igual a zero).\
Consequência: os dados são considerados inválidos, é exibida a mensagem "The Amount entered must be numeric." e o processamento da validação é interrompido.\
Parágrafo: VA010 (VALIDATE-AMOUNT)

5\. Regra: O valor da transferência bancária deve ser maior que zero. Valores iguais ou inferiores a zero não são aceitos quando informados diretamente como números.\
Condição: o valor informado é numérico e seu valor convertido (WS-AMOUNT-AS-FLOAT) é menor ou igual a zero.\
Consequência: os dados são considerados inválidos e é exibida a mensagem "Please supply a positive amount.".\
Parágrafo: VA010 (VALIDATE-AMOUNT)

6\. Regra: O valor da transferência bancária é obrigatório e não pode conter apenas espaços em branco.\
Condição: todos os caracteres informados no campo de valor da transferência são espaços em branco (WS-NUM-COUNT-TOTAL igual a AMTL).\
Consequência: os dados são considerados inválidos e é exibida a mensagem "The Amount entered must be numeric.".\
Parágrafo: VA010 (VALIDATE-AMOUNT)

7\. Regra: Não são aceitos valores de transferência informados com sinal negativo.\
Condição: o valor da transferência contém pelo menos um sinal de menos (WS-NUM-COUNT-MINUS maior que zero).\
Consequência: os dados são considerados inválidos e é exibida a mensagem "Please supply a positive amount.".\
Parágrafo: VA010 (VALIDATE-AMOUNT)

8\. Regra: O valor da transferência bancária admite, no máximo, duas casas decimais. Valores com mais de duas casas decimais não são aceitos.\
Condição: o valor informado contém um ponto decimal, possui mais de dois caracteres após esse ponto e a contagem adicional realizada pelo programa supera dois (WS-NUM-COUNT-TOTAL maior que 2).\
Consequência: os dados são considerados inválidos e é exibida a mensagem "Only up to two decimal places are supported.". A rejeição depende dessa contagem adicional, não apenas da quantidade de casas decimais.\
Parágrafo: VA010 (VALIDATE-AMOUNT)

9\. Regra: Uma transferência bancária não pode ser realizada com valor igual a zero, mesmo quando o valor foi informado com representação decimal.\
Condição: após o tratamento e a conversão do valor informado, o resultado (WS-AMOUNT-AS-FLOAT) é igual a zero.\
Consequência: os dados são considerados inválidos e é exibida a mensagem "Please supply a non-zero amount.".\
Parágrafo: VA010 (VALIDATE-AMOUNT)

10\. Regra: Se a conta de origem não for encontrada durante o processamento da transferência, a operação não é efetivada.\
Condição: o processamento da transferência retorna insucesso (SUBPGM-SUCCESS igual a 'N') com código de falha '1' (SUBPGM-FAIL-CODE).\
Consequência: a transferência é considerada malsucedida e é exibida a mensagem "Sorry the FROM ACCOUNT no was not found. Transfer not applied.".\
Parágrafo: GCD010 (GET-ACC-DATA)

11\. Regra: Se a conta de destino não for encontrada durante o processamento da transferência, a operação não é efetivada.\
Condição: o processamento da transferência retorna insucesso (SUBPGM-SUCCESS igual a 'N') com código de falha '2' (SUBPGM-FAIL-CODE).\
Consequência: a transferência é considerada malsucedida e é exibida a mensagem "Sorry the TO ACCOUNT no was not found. Transfer not applied.".\
Parágrafo: GCD010 (GET-ACC-DATA)

12\. Regra: Quando o processamento da transferência retorna um erro inesperado identificado pelo código '3', a operação é considerada malsucedida e o cliente recebe uma mensagem de impossibilidade de determinar o sucesso da transferência.\
Condição: o processamento retorna SUBPGM-SUCCESS igual a 'N' e SUBPGM-FAIL-CODE igual a '3'.\
Consequência: os dados são considerados inválidos; embora o programa inicialmente prepare a mensagem "Sorry but the transfer could not be applied due to an unexpected error.", ela é substituída por "Sorry but the transfer could not be applied unable to determine success.".\
Parágrafo: GCD010 (GET-ACC-DATA)

13\. Regra: A transferência bancária não é efetivada quando o processamento identifica que o valor informado deve ser maior que zero.\
Condição: o processamento retorna insucesso (SUBPGM-SUCCESS igual a 'N') com código de falha '4' (SUBPGM-FAIL-CODE).\
Consequência: a transferência é considerada malsucedida e é exibida a mensagem "Please supply an amount greater than zero.".\
Parágrafo: GCD010 (GET-ACC-DATA)

14\. Regra: Quando a transferência não é concluída e o motivo da falha não corresponde aos códigos específicos reconhecidos pelo programa, o cliente recebe uma mensagem genérica de erro.\
Condição: o processamento retorna insucesso (SUBPGM-SUCCESS igual a 'N') com código de falha diferente de '1', '2', '3' e '4'.\
Consequência: a transferência é considerada malsucedida e é exibida a mensagem "Sorry but the transfer could not be applied due to an error.".\
Parágrafo: GCD010 (GET-ACC-DATA)

15\. Regra: Quando o processamento não confirma nem rejeita explicitamente o sucesso de uma transferência, a operação não é apresentada ao cliente como concluída.\
Condição: o indicador de sucesso da transferência (SUBPGM-SUCCESS) é diferente de 'Y' e de 'N'.\
Consequência: é exibida a mensagem "Sorry but the transfer could not be applied unable to determine success.". O programa não confirma a efetivação da operação.\
Parágrafo: GCD010 (GET-ACC-DATA)

16\. Regra: Quando o processamento confirma o sucesso da transferência bancária, a operação é apresentada ao cliente como efetivada.\
Condição: o indicador de sucesso da transferência (SUBPGM-SUCCESS) é igual a 'Y'.\
Consequência: é exibida a mensagem "Transfer successfully applied." e são apresentados os saldos atual e disponível das contas de origem e destino retornados pelo processamento.\
Parágrafo: GCD010 (GET-ACC-DATA)