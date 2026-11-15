1\. Regra: Uma transferência somente pode ser realizada entre contas bancárias diferentes.\
Condição: Quando o número da conta de origem é igual ao número da conta de destino (FACCNOI = TACCNOI).\
Consequência: A transferência não é processada e o sistema informa que as contas de origem e destino devem ser diferentes.\
Parágrafo: ED010

2\. Regra: O número de conta bancária 00000000 não é aceito em transferências.\
Condição: Quando a conta de origem ou a conta de destino possui o número 00000000.\
Consequência: A transferência não é processada e o sistema informa que o número da conta é inválido.\
Parágrafo: ED010

3\. Regra: O valor da transferência é obrigatório.\
Condição: Quando o campo do valor da transferência não foi preenchido (AMTL = ZERO).\
Consequência: A transferência não é processada e o sistema apresenta uma mensagem solicitando um valor numérico.\
Parágrafo: VA010

4\. Regra: O valor da transferência deve ser maior que zero.\
Condição: Quando o valor informado é numérico e é menor ou igual a zero (WS-AMOUNT-AS-FLOAT  0).\
Consequência: A transferência não é processada e o sistema solicita um valor positivo.\
Parágrafo: VA010

7\. Regra: O valor da transferência pode conter no máximo duas casas decimais.\
Condição: Quando o valor informado contém um ponto decimal, possui mais de dois caracteres após esse ponto e a contagem adicional de dígitos ultrapassa dois (WS-NUM-COUNT-TOTAL > 2).\
Consequência: A transferência não é processada e o sistema informa que somente até duas casas decimais são aceitas.\
Parágrafo: VA010

8\. Regra: O valor da transferência não pode ser zero.\
Condição: Quando o valor convertido da transferência é igual a zero (WS-AMOUNT-AS-FLOAT = ZERO).\
Consequência: A transferência não é processada e o sistema solicita um valor diferente de zero.\
Parágrafo: VA010

9\. Regra: A transferência não pode ser concluída quando a conta de origem não é encontrada.\
Condição: Quando o processamento da transferência retorna insucesso (SUBPGM-SUCCESS = 'N') com código de falha '1'.\
Consequência: O sistema informa que a conta de origem não foi encontrada e que a transferência não foi realizada.\
Parágrafo: GCD010

10\. Regra: A transferência não pode ser concluída quando a conta de destino não é encontrada.\
Condição: Quando o processamento da transferência retorna insucesso (SUBPGM-SUCCESS = 'N') com código de falha '2'.\
Consequência: O sistema informa que a conta de destino não foi encontrada e que a transferência não foi realizada.\
Parágrafo: GCD010

11\. Regra: A transferência não pode ser confirmada quando ocorre uma falha inesperada identificada pelo código '3'.\
Condição: Quando o processamento retorna insucesso (SUBPGM-SUCCESS = 'N') com código de falha '3'.\
Consequência: O sistema inicialmente prepara uma mensagem de erro inesperado, mas ela é substituída por uma mensagem informando que a transferência não pôde ser aplicada porque não foi possível determinar seu sucesso.\
Parágrafo: GCD010

12\. Regra: Uma transferência não pode ser realizada com valor menor ou igual a zero, conforme a validação do processamento da transferência.\
Condição: Quando o processamento retorna insucesso (SUBPGM-SUCCESS = 'N') com código de falha '4'.\
Consequência: O sistema informa que o valor da transferência deve ser maior que zero.\
Parágrafo: GCD010

13\. Regra: Uma transferência não pode ser concluída quando o processamento retorna uma falha não identificada entre os códigos previstos.\
Condição: Quando o processamento retorna insucesso (SUBPGM-SUCCESS = 'N') com código de falha diferente de '1', '2', '3' e '4'.\
Consequência: O sistema informa que a transferência não pôde ser realizada devido a um erro.\
Parágrafo: GCD010

14\. Regra: Uma transferência somente é confirmada quando o processamento retorna uma indicação explícita de sucesso.\
Condição: Quando o indicador de sucesso da transferência é diferente de 'Y' (SUBPGM-SUCCESS NOT = 'Y') e o processamento não foi encerrado anteriormente por outro código de falha.\
Consequência: O sistema informa que a transferência não pôde ser aplicada porque não foi possível determinar seu sucesso.\
Parágrafo: GCD010

15\. Regra: A transferência é considerada realizada quando o processamento confirma seu sucesso.\
Condição: Quando o indicador de sucesso da transferência é igual a 'Y' (SUBPGM-SUCCESS = 'Y').\
Consequência: O sistema informa que a transferência foi realizada com sucesso e apresenta os dados das contas de origem e destino, incluindo seus saldos reais e disponíveis.\
Parágrafo: GCD010