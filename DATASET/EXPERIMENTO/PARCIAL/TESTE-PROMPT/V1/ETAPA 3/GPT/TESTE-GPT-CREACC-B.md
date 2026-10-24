1\. Regra: Para abrir uma conta, o cliente informado deve ser localizado com sucesso no cadastro de clientes; caso contrário, a abertura é recusada com o código de falha '1'.\
Condição: a consulta do cliente (INQCUST) não é concluída normalmente ou retorna indicador de sucesso diferente de 'Y'.\
Consequência: a abertura da conta é interrompida, com indicador de sucesso 'N' e código de falha '1'.\
Parágrafo: P010 (PREMIERE SECTION)

2\. Regra: Um cliente pode possuir, no máximo, 10 contas; se já possuir 10 ou mais, não poderá abrir outra conta.\
Condição: a quantidade de contas existentes do cliente (NUMBER-OF-ACCOUNTS) é maior que 9.\
Consequência: a abertura da conta é recusada, com indicador de sucesso 'N' e código de falha '8'.\
Parágrafo: P010 (PREMIERE SECTION)

3\. Regra: A abertura de uma conta somente é permitida para os tipos ISA, MORTGAGE, SAVING, CURRENT ou LOAN.\
Condição: o tipo de conta informado (COMM-ACC-TYPE) não corresponde a nenhum dos cinco valores aceitos, considerando apenas os primeiros 3, 8, 6, 7 e 4 caracteres, respectivamente.\
Consequência: a abertura da conta é recusada, com indicador de sucesso 'N' e código de falha 'A'.\
Parágrafo: ATC010 (ACCOUNT-TYPE-CHECK)

4\. Regra: Quando o tipo de conta informado é ISA, MORTGAGE, SAVING, CURRENT ou LOAN, a validação do tipo de conta é aprovada.\
Condição: o tipo de conta informado corresponde a um dos cinco valores aceitos, considerando os primeiros caracteres de acordo com o tamanho de cada valor.\
Consequência: o indicador de sucesso recebe 'Y', permitindo que o processamento de abertura continue.\
Parágrafo: ATC010 (ACCOUNT-TYPE-CHECK)

5\. Regra: Cada nova conta recebe um número obtido pelo acréscimo de uma unidade ao último número de conta registrado para o código bancário correspondente (SORTCODE).\
Condição: a abertura passou pelas verificações anteriores e o último número de conta do código bancário foi recuperado.\
Consequência: o último número registrado é incrementado em uma unidade e o resultado é atribuído à nova conta.\
Parágrafo: FNA010 (FIND-NEXT-ACCOUNT)

6\. Regra: A quantidade total de contas registrada para o código bancário (SORTCODE) é aumentada em uma unidade durante a abertura de uma nova conta.\
Condição: o processamento da abertura alcança a atualização da quantidade de contas vinculadas ao código bancário.\
Consequência: o contador de contas do código bancário (ACCOUNT-COUNT) é incrementado em uma unidade.\
Parágrafo: FNA010 (FIND-NEXT-ACCOUNT)

7\. Regra: A nova conta é vinculada ao número do cliente informado na solicitação de abertura.\
Condição: a abertura da conta chega à preparação dos dados para cadastro.\
Consequência: o número do cliente (COMM-CUSTNO) é atribuído à nova conta.\
Parágrafo: WAD010 (WRITE-ACCOUNT-DB2)

8\. Regra: A nova conta é cadastrada com o código bancário (SORTCODE) utilizado no processamento da abertura.\
Condição: a abertura da conta chega à preparação dos dados para cadastro.\
Consequência: o código bancário é atribuído à nova conta.\
Parágrafo: WAD010 (WRITE-ACCOUNT-DB2)

9\. Regra: A nova conta é cadastrada com o tipo de conta informado na solicitação de abertura.\
Condição: a abertura da conta chega à preparação dos dados para cadastro.\
Consequência: o tipo informado (COMM-ACC-TYPE) é atribuído à nova conta.\
Parágrafo: WAD010 (WRITE-ACCOUNT-DB2)

10\. Regra: A taxa de juros inicial da nova conta é definida pelo valor informado na solicitação de abertura.\
Condição: a abertura da conta chega à preparação dos dados para cadastro.\
Consequência: a taxa de juros informada (COMM-INT-RT) é atribuída à nova conta.\
Parágrafo: WAD010 (WRITE-ACCOUNT-DB2)

11\. Regra: O limite de cheque especial da nova conta é definido pelo valor informado na solicitação de abertura.\
Condição: a abertura da conta chega à preparação dos dados para cadastro.\
Consequência: o limite informado (COMM-OVERDR-LIM) é atribuído à nova conta, sem aplicação de limites mínimos ou máximos nesse parágrafo.\
Parágrafo: WAD010 (WRITE-ACCOUNT-DB2)

12\. Regra: O saldo disponível inicial da nova conta é definido pelo valor informado na solicitação de abertura.\
Condição: a abertura da conta chega à preparação dos dados para cadastro.\
Consequência: o saldo disponível informado (COMM-AVAIL-BAL) é atribuído à nova conta.\
Parágrafo: WAD010 (WRITE-ACCOUNT-DB2)

13\. Regra: O saldo efetivo inicial da nova conta é definido pelo valor informado na solicitação de abertura.\
Condição: a abertura da conta chega à preparação dos dados para cadastro.\
Consequência: o saldo efetivo informado (COMM-ACT-BAL) é atribuído à nova conta.\
Parágrafo: WAD010 (WRITE-ACCOUNT-DB2)

14\. Regra: A data do próximo extrato da nova conta é estabelecida em 30 dias corridos após a data da abertura.\
Condição: a nova conta está sendo preparada para cadastro, após a execução do cálculo inicial de datas.\
Consequência: a data de abertura é acrescida de 30 dias corridos, e o resultado é gravado como a data do próximo extrato da conta.\
Parágrafo: WAD010 (WRITE-ACCOUNT-DB2)

15\. Regra: Quando o cadastro da nova conta é concluído com sucesso, o banco devolve o código bancário e o número da conta criada.\
Condição: a inclusão da conta foi concluída e o processamento chegou à preparação do resultado da abertura.\
Consequência: o código bancário (COMM-SORTCODE) e o número da conta (COMM-NUMBER) são disponibilizados no resultado.\
Parágrafo: WAD010 (WRITE-ACCOUNT-DB2)

16\. Regra: Quando a abertura da conta é concluída com sucesso, as datas de abertura, do último extrato e do próximo extrato são disponibilizadas no resultado.\
Condição: a inclusão da conta foi concluída e o processamento chegou à preparação do resultado da abertura.\
Consequência: as três datas são devolvidas nos campos COMM-OPENED, COMM-LAST-STMT-DT e COMM-NEXT-STMT-DT.\
Parágrafo: WAD010 (WRITE-ACCOUNT-DB2)

17\. Regra: Quando a abertura de uma conta é concluída com sucesso, a operação é identificada como bem-sucedida e sem código de falha.\
Condição: o processamento da abertura chega à conclusão normal após a inclusão da conta.\
Consequência: o indicador de sucesso recebe 'Y' e o código de falha fica em branco.\
Parágrafo: WAD010 (WRITE-ACCOUNT-DB2)

18\. Regra: A data de abertura de uma nova conta corresponde à data corrente em que a abertura é processada.\
Condição: as datas da nova conta estão sendo calculadas.\
Consequência: a data corrente é atribuída como data de abertura da conta (ACCOUNT-OPENED e HV-ACCOUNT-OPENED).\
Parágrafo: CD010 (CALCULATE-DATES)

19\. Regra: Na abertura de uma nova conta, a data do último extrato é inicialmente igual à data de abertura.\
Condição: as datas da nova conta estão sendo calculadas.\
Consequência: a data de abertura é atribuída como data do último extrato (ACCOUNT-LAST-STMT-DATE e HV-ACCOUNT-LAST-STMT).\
Parágrafo: CD010 (CALCULATE-DATES)

20\. Regra: Para contas abertas em janeiro, março, maio, julho, agosto, outubro ou dezembro, o cálculo inicial do próximo extrato considera um intervalo de 30 dias corridos.\
Condição: o mês da data de abertura é 1, 3, 5, 7, 8, 10 ou 12.\
Consequência: são acrescentados 30 dias à data de abertura para calcular a data inicial do próximo extrato (ACCOUNT-NEXT-STMT-DATE).\
Parágrafo: CD010 (CALCULATE-DATES)

21\. Regra: Para contas abertas em abril, junho, setembro ou novembro, o cálculo inicial do próximo extrato considera um intervalo de 30 dias corridos.\
Condição: o mês da data de abertura é 4, 6, 9 ou 11.\
Consequência: são acrescentados 30 dias à data de abertura para calcular a data inicial do próximo extrato (ACCOUNT-NEXT-STMT-DATE).\
Parágrafo: CD010 (CALCULATE-DATES)

22\. Regra: Para contas abertas em fevereiro, o cálculo inicial do próximo extrato considera um intervalo básico de 28 dias corridos.\
Condição: o mês da data de abertura é fevereiro.\
Consequência: são acrescentados inicialmente 28 dias à data de abertura para calcular a data do próximo extrato (ACCOUNT-NEXT-STMT-DATE).\
Parágrafo: CD010 (CALCULATE-DATES)

23\. Regra: Para contas abertas em fevereiro de um ano bissexto divisível por 4, mas não por 100, o cálculo inicial do próximo extrato considera um dia adicional.\
Condição: o mês de abertura é fevereiro, o ano é divisível por 4 e não é divisível por 100.\
Consequência: é acrescentado mais um dia ao intervalo básico de 28 dias, totalizando 29 dias para o cálculo inicial do próximo extrato.\
Parágrafo: CD010 (CALCULATE-DATES)

24\. Regra: Para contas abertas em fevereiro de um ano divisível por 400, o cálculo inicial do próximo extrato considera um dia adicional.\
Condição: o mês de abertura é fevereiro e o ano é divisível por 400.\
Consequência: é acrescentado mais um dia ao intervalo básico de 28 dias, totalizando 29 dias para o cálculo inicial do próximo extrato.\
Parágrafo: CD010 (CALCULATE-DATES)