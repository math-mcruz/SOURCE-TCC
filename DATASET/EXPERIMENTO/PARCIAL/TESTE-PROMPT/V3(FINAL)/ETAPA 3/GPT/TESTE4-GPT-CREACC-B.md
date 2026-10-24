1\. Regra: Se a consulta dos dados do cliente não for concluída com sucesso, a abertura da conta é recusada com o código de falha '1'.\
Condição: a consulta do cliente (INQCUST) retorna indicador de sucesso diferente de 'Y', desde que a chamada tenha sido concluída normalmente.\
Consequência: a conta não é aberta; indicador de sucesso 'N' e código de falha '1'.\
Parágrafo: P010 (PREMIERE SECTION)

2\. Regra: Se não for possível obter a quantidade de contas do cliente, a abertura de uma nova conta é recusada com o código de falha '9'.\
Condição: a consulta da quantidade de contas (INQACCCU) retorna indicador de sucesso 'N', com a chamada concluída normalmente.\
Consequência: a conta não é aberta; indicador de sucesso 'N' e código de falha '9'.\
Parágrafo: P010 (PREMIERE SECTION)

3\. Regra: Um cliente pode possuir no máximo 10 contas. Se já possuir mais de 9 contas, a abertura de uma nova conta é recusada com o código de falha '8'.\
Condição: a quantidade de contas existentes do cliente (NUMBER-OF-ACCOUNTS) é superior a 9.\
Consequência: a conta não é aberta; indicador de sucesso 'N' e código de falha '8'.\
Parágrafo: P010 (PREMIERE SECTION)

4\. Regra: Se o tipo de conta solicitado for ISA, MORTGAGE, SAVING, CURRENT ou LOAN, ele é considerado válido para abertura de conta.\
Condição: o tipo de conta informado (COMM-ACC-TYPE) começa com ISA, MORTGAGE, SAVING, CURRENT ou LOAN, conforme o tamanho do prefixo testado para cada tipo.\
Consequência: o tipo de conta é aprovado, com indicador de sucesso 'Y', permitindo a continuidade do processo de abertura.\
Parágrafo: ATC010 (ACCOUNT-TYPE-CHECK)

5\. Regra: Se o tipo de conta solicitado não for ISA, MORTGAGE, SAVING, CURRENT ou LOAN, a abertura da conta é recusada com o código de falha 'A'.\
Condição: o tipo de conta informado (COMM-ACC-TYPE) não começa com nenhum dos prefixos aceitos: ISA, MORTGAGE, SAVING, CURRENT ou LOAN.\
Consequência: o tipo de conta é considerado inválido; indicador de sucesso 'N' e código de falha 'A', impedindo a abertura da conta.\
Parágrafo: ATC010 (ACCOUNT-TYPE-CHECK)

6\. Regra: Para contas abertas em janeiro, março, maio, julho, agosto, outubro ou dezembro, o programa calcula a data de referência do próximo extrato acrescentando 30 dias à data de abertura.\
Condição: o mês da data de abertura é 1, 3, 5, 7, 8, 10 ou 12.\
Consequência: a data de referência do próximo extrato é calculada com acréscimo de 30 dias.\
Parágrafo: CD010 (CALCULATE-DATES)

7\. Regra: Para contas abertas em abril, junho, setembro ou novembro, o programa calcula a data de referência do próximo extrato acrescentando 30 dias à data de abertura.\
Condição: o mês da data de abertura é 4, 6, 9 ou 11.\
Consequência: a data de referência do próximo extrato é calculada com acréscimo de 30 dias.\
Parágrafo: CD010 (CALCULATE-DATES)

8\. Regra: Para contas abertas em fevereiro de um ano não bissexto, o programa calcula a data de referência do próximo extrato acrescentando 28 dias à data de abertura.\
Condição: o mês da data de abertura é fevereiro e o ano não é divisível por 4, ou é divisível por 100 mas não por 400.\
Consequência: a data de referência do próximo extrato é calculada com acréscimo de 28 dias.\
Parágrafo: CD010 (CALCULATE-DATES)

9\. Regra: Para contas abertas em fevereiro de um ano bissexto divisível por 4, mas não por 100, o programa calcula a data de referência do próximo extrato acrescentando 29 dias à data de abertura.\
Condição: o mês da data de abertura é fevereiro, o ano é divisível por 4 e não é divisível por 100.\
Consequência: a data de referência do próximo extrato é calculada com acréscimo de 29 dias.\
Parágrafo: CD010 (CALCULATE-DATES)

10\. Regra: Para contas abertas em fevereiro de um ano bissexto divisível por 400, o programa calcula a data de referência do próximo extrato acrescentando 29 dias à data de abertura.\
Condição: o mês da data de abertura é fevereiro e o ano é divisível por 400.\
Consequência: a data de referência do próximo extrato é calculada com acréscimo de 29 dias.\
Parágrafo: CD010 (CALCULATE-DATES)