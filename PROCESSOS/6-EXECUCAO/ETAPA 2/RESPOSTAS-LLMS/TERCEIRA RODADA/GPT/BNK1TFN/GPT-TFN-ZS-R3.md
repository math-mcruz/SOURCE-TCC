1\. Regra: As contas de origem e destino de uma transferência devem ser diferentes.\
Condição: Quando o número da conta de origem é igual ao número da conta de destino (FACCNOI = TACCNOI).\
Consequência: A transferência não é processada e o cliente é informado de que as contas de origem e destino devem ser diferentes.\
Parágrafo: ED010

2\. Regra: O número de conta 00000000 não é permitido em transferências.\
Condição: Quando a conta de origem ou a conta de destino possui o número 00000000.\
Consequência: A transferência não é processada e o cliente é informado de que o número da conta é inválido.\
Parágrafo: ED010

3\. Regra: O valor da transferência é obrigatório.\
Condição: Quando o campo de valor da transferência não foi preenchido (AMTL = ZERO).\
Consequência: A transferência não é processada e é apresentada uma mensagem solicitando um valor numérico.\
Parágrafo: VA010

4\. Regra: O valor numérico da transferência deve ser maior que zero.\
Condição: Quando o valor informado é numérico e menor ou igual a zero (WS-AMOUNT-AS-FLOAT  0).\
Consequência: A transferência não é processada e o cliente é solicitado a informar um valor positivo.\
Parágrafo: VA010

7\. Regra: O valor da transferência pode possuir no máximo duas casas decimais.\
Condição: Quando o valor informado possui um ponto decimal, mais de dois caracteres após esse ponto e a contagem adicional de dígitos decimais realizada pelo programa é superior a dois (WS-NUM-COUNT-TOTAL > 2).\
Consequência: A transferência não é processada e o cliente é informado de que são aceitas somente até duas casas decimais.\
Parágrafo: VA010

8\. Regra: O valor da transferência não pode ser zero.\
Condição: Quando o valor convertido após o tratamento da entrada é igual a zero (WS-AMOUNT-AS-FLOAT = ZERO).\
Consequência: A transferência não é processada e o cliente é solicitado a informar um valor diferente de zero.\
Parágrafo: VA010

9\. Regra: Uma transferência com dados validados é encaminhada para processamento.\
Condição: Quando todas as validações dos dados informados são concluídas sem invalidar a operação (VALID-DATA).\
Consequência: A solicitação de transferência é encaminhada para processamento, com as contas de origem e destino e o valor informado.\
Parágrafo: PM010

10\. Regra: Uma transferência com dados inválidos não é encaminhada para processamento.\
Condição: Quando alguma validação dos dados informados identifica uma condição inválida (VALID-DATA-SW = 'N').\
Consequência: A transferência não é encaminhada para execução.\
Parágrafo: PM010

11\. Regra: A transferência não pode ser realizada quando a conta de origem não é encontrada.\
Condição: Quando o processamento da transferência retorna insucesso (SUBPGM-SUCCESS = 'N') com código de falha 1 (SUBPGM-FAIL-CODE = '1').\
Consequência: O cliente é informado de que a conta de origem não foi encontrada e de que a transferência não foi aplicada.\
Parágrafo: GCD010

12\. Regra: A transferência não pode ser realizada quando a conta de destino não é encontrada.\
Condição: Quando o processamento da transferência retorna insucesso (SUBPGM-SUCCESS = 'N') com código de falha 2 (SUBPGM-FAIL-CODE = '2').\
Consequência: O cliente é informado de que a conta de destino não foi encontrada e de que a transferência não foi aplicada.\
Parágrafo: GCD010

13\. Regra: O processamento da transferência exige um valor maior que zero.\
Condição: Quando o processamento da transferência retorna insucesso (SUBPGM-SUCCESS = 'N') com código de falha 4 (SUBPGM-FAIL-CODE = '4').\
Consequência: O cliente é informado de que deve fornecer um valor de transferência maior que zero.\
Parágrafo: GCD010

14\. Regra: Uma transferência com falha não identificada pelos códigos específicos não é considerada aplicada.\
Condição: Quando o processamento retorna insucesso (SUBPGM-SUCCESS = 'N') e o código de falha é diferente de 1, 2, 3 e 4.\
Consequência: O cliente é informado de que a transferência não pôde ser aplicada devido a um erro.\
Parágrafo: GCD010

15\. Regra: Uma transferência com indicação de erro inesperado termina com uma mensagem de impossibilidade de confirmação do sucesso.\
Condição: Quando o processamento retorna insucesso (SUBPGM-SUCCESS = 'N') com código de falha 3 (SUBPGM-FAIL-CODE = '3').\
Consequência: Embora o programa inicialmente prepare uma mensagem de erro inesperado, essa mensagem é substituída pela informação de que a transferência não pôde ser aplicada porque não foi possível determinar seu sucesso.\
Parágrafo: GCD010

16\. Regra: Uma transferência cujo resultado não confirma sucesso nem indica explicitamente insucesso não é apresentada como concluída.\
Condição: Quando o indicador de sucesso retornado pelo processamento é diferente de 'Y' e também diferente de 'N' (SUBPGM-SUCCESS NOT = 'Y', após não atender a SUBPGM-SUCCESS = 'N').\
Consequência: O cliente é informado de que a transferência não pôde ser aplicada porque não foi possível determinar seu sucesso.\
Parágrafo: GCD010

17\. Regra: Uma transferência confirmada como bem-sucedida é apresentada ao cliente como realizada.\
Condição: Quando o processamento retorna indicador de sucesso igual a 'Y' (SUBPGM-SUCCESS = 'Y').\
Consequência: O cliente recebe a confirmação de que a transferência foi aplicada com sucesso, acompanhada dos dados das contas e dos saldos efetivos e disponíveis retornados pelo processamento.\
Parágrafo: GCD010