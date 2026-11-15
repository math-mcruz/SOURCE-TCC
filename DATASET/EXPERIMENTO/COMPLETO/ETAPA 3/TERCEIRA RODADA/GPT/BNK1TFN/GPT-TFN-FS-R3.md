1\. Regra: A conta de origem e a conta de destino de uma transferência devem ser diferentes. Caso sejam iguais, a transferência não é processada e é apresentada uma mensagem de rejeição.\
Condição: número da conta de origem igual ao número da conta de destino (FACCNOI = TACCNOI).\
Consequência: dados considerados inválidos, com a mensagem "The FROM & TO account should be different".\
Parágrafo: ED010 (EDIT-DATA)

2\. Regra: O número da conta de origem e o número da conta de destino não podem ser 00000000. Caso qualquer uma das contas tenha esse número, a transferência não é processada.\
Condição: conta de origem ou conta de destino igual a 00000000 (FACCNOI = '00000000' ou TACCNOI = '00000000').\
Consequência: dados considerados inválidos, com a mensagem "Account no 00000000 is not valid".\
Parágrafo: ED010 (EDIT-DATA)

3\. Regra: O valor da transferência é obrigatório. Se não for informado, a transferência não é processada.\
Condição: campo de valor da transferência sem conteúdo (AMTL = ZERO).\
Consequência: valor considerado inválido, com a mensagem "The Amount entered must be numeric.".\
Parágrafo: VA010 (VALIDATE-AMOUNT)

4\. Regra: O valor de uma transferência deve ser maior que zero. Caso seja zero ou negativo, a transferência não é processada.\
Condição: valor informado diretamente como numérico e convertido para um número menor ou igual a zero (WS-AMOUNT-AS-FLOAT menor ou igual a zero).\
Consequência: valor considerado inválido, com a mensagem "Please supply a positive amount.".\
Parágrafo: VA010 (VALIDATE-AMOUNT)

5\. Regra: O valor da transferência não pode ser preenchido apenas com espaços. Caso isso aconteça, a transferência não é processada.\
Condição: todos os caracteres do valor informado são espaços (WS-NUM-COUNT-TOTAL = AMTL).\
Consequência: valor considerado inválido, com a mensagem "The Amount entered must be numeric.".\
Parágrafo: VA010 (VALIDATE-AMOUNT)

6\. Regra: O valor de uma transferência não pode conter sinal negativo. Caso contenha, a transferência não é processada.\
Condição: presença de pelo menos um sinal de menos no valor informado (WS-NUM-COUNT-MINUS maior que zero).\
Consequência: valor considerado inválido, com a mensagem "Please supply a positive amount.".\
Parágrafo: VA010 (VALIDATE-AMOUNT)

7\. Regra: O valor de uma transferência deve respeitar o limite de duas casas decimais. Caso a validação identifique mais de duas casas decimais, a transferência não é processada.\
Condição: valor informado com um ponto decimal, mais de dois caracteres após o ponto e contagem de dígitos decimais superior a dois na verificação adicional (WS-NUM-COUNT-TOTAL maior que 2). A implementação utiliza uma segunda contagem cujo resultado pode não corresponder exatamente à quantidade de casas decimais informadas.\
Consequência: valor considerado inválido, com a mensagem "Only up to two decimal places are supported.".\
Parágrafo: VA010 (VALIDATE-AMOUNT)

8\. Regra: O valor de uma transferência não pode ser zero. Caso o valor convertido seja igual a zero, a transferência não é processada.\
Condição: valor convertido após o tratamento da entrada igual a zero (WS-AMOUNT-AS-FLOAT = ZERO).\
Consequência: valor considerado inválido, com a mensagem "Please supply a non-zero amount.".\
Parágrafo: VA010 (VALIDATE-AMOUNT)

9\. Regra: Quando a conta de origem não é encontrada durante o processamento da transferência, a operação é rejeitada.\
Condição: processamento da transferência sem sucesso (SUBPGM-SUCCESS = 'N') e código de falha '1' (SUBPGM-FAIL-CODE = '1').\
Consequência: transferência não realizada, com a mensagem "Sorry the FROM ACCOUNT no was not found. Transfer not applied.".\
Parágrafo: GCD010 (GET-ACC-DATA)

10\. Regra: Quando a conta de destino não é encontrada durante o processamento da transferência, a operação é rejeitada.\
Condição: processamento da transferência sem sucesso (SUBPGM-SUCCESS = 'N') e código de falha '2' (SUBPGM-FAIL-CODE = '2').\
Consequência: transferência não realizada, com a mensagem "Sorry the TO ACCOUNT no was not found. Transfer not applied.".\
Parágrafo: GCD010 (GET-ACC-DATA)

11\. Regra: Quando o processamento da transferência retorna o código de falha '3', a operação é tratada como não concluída, e o sistema informa que não foi possível determinar seu sucesso.\
Condição: processamento da transferência sem sucesso (SUBPGM-SUCCESS = 'N') e código de falha '3' (SUBPGM-FAIL-CODE = '3').\
Consequência: a mensagem inicial de erro inesperado é substituída por "Sorry but the transfer could not be applied unable to determine success.".\
Parágrafo: GCD010 (GET-ACC-DATA)

12\. Regra: Quando o processamento da transferência rejeita o valor por não ser maior que zero, a transferência não é realizada.\
Condição: processamento da transferência sem sucesso (SUBPGM-SUCCESS = 'N') e código de falha '4' (SUBPGM-FAIL-CODE = '4').\
Consequência: transferência não realizada, com a mensagem "Please supply an amount greater than zero.".\
Parágrafo: GCD010 (GET-ACC-DATA)

13\. Regra: Quando o processamento da transferência retorna um código de falha não reconhecido, a operação é tratada como não realizada.\
Condição: processamento da transferência sem sucesso (SUBPGM-SUCCESS = 'N') e código de falha diferente de '1', '2', '3' e '4'.\
Consequência: transferência não realizada, com a mensagem "Sorry but the transfer could not be applied due to an error.".\
Parágrafo: GCD010 (GET-ACC-DATA)

14\. Regra: Quando o resultado do processamento da transferência não indica sucesso nem corresponde ao indicador de falha esperado, o sistema informa que não foi possível determinar o sucesso da operação.\
Condição: indicador de resultado da transferência diferente de 'N' e de 'Y' (SUBPGM-SUCCESS diferente de 'N' e 'Y').\
Consequência: transferência não confirmada, com a mensagem "Sorry but the transfer could not be applied unable to determine success.".\
Parágrafo: GCD010 (GET-ACC-DATA)

15\. Regra: Quando o processamento da transferência confirma seu sucesso, o sistema informa que a transferência foi realizada e apresenta os saldos atualizados das contas de origem e destino.\
Condição: indicador de resultado da transferência igual a 'Y' (SUBPGM-SUCCESS = 'Y').\
Consequência: transferência confirmada, com a mensagem "Transfer successfully applied." e apresentação dos saldos contábeis e disponíveis das duas contas.\
Parágrafo: GCD010 (GET-ACC-DATA)