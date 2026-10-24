1\. Regra: Se a consulta dos dados do cliente não for concluída com sucesso, a abertura da conta é recusada com o código de falha '1'.\
Condição: a consulta do cliente retorna uma resposta diferente de normal ou o indicador de sucesso da consulta (INQCUST-INQ-SUCCESS) é diferente de 'Y'.\
Consequência: a abertura da conta é interrompida, com indicador de sucesso 'N' e código de falha '1'.\
Parágrafo: P010 (PREMIERE SECTION)

2\. Regra: Se a consulta da quantidade de contas do cliente não for concluída normalmente, a abertura de uma nova conta é recusada com o código de falha '9'.\
Condição: a chamada de consulta da quantidade de contas retorna uma resposta diferente de normal (WS-CICS-RESP).\
Consequência: a abertura da conta é interrompida, com indicador de sucesso 'N' e código de falha '9'.\
Parágrafo: P010 (PREMIERE SECTION)

3\. Regra: Se a consulta da quantidade de contas do cliente indicar insucesso, a abertura de uma nova conta é recusada com o código de falha '9'.\
Condição: o indicador de sucesso da consulta da quantidade de contas (COMM-SUCCESS em INQACCCU-COMMAREA) é igual a 'N'.\
Consequência: a abertura da conta é interrompida, com indicador de sucesso 'N' e código de falha '9'.\
Parágrafo: P010 (PREMIERE SECTION)

4\. Regra: Um cliente pode ter no máximo 10 contas; se já possuir mais de 9 contas, a abertura de uma nova conta é recusada com o código de falha '8'.\
Condição: a quantidade de contas existentes do cliente (NUMBER-OF-ACCOUNTS) é maior que 9.\
Consequência: a abertura da conta é interrompida, com indicador de sucesso 'N' e código de falha '8'.\
Parágrafo: P010 (PREMIERE SECTION)

5\. Regra: Se o tipo de conta informado não for aceito, a abertura da conta é interrompida.\
Condição: após a validação do tipo de conta, o indicador de sucesso (COMM-SUCCESS) é igual a 'N'.\
Consequência: o processamento da abertura da conta é encerrado sem prosseguir para sua criação.\
Parágrafo: P010 (PREMIERE SECTION)

6\. Regra: Para fevereiro, o cálculo da próxima data de extrato considera inicialmente 28 dias.\
Condição: o mês da abertura da conta (WS-ORIG-DATE-MM) é igual a 2.\
Consequência: são adicionados 28 dias à data de abertura como base para calcular a próxima data de extrato.\
Parágrafo: CD010 (CALCULATE-DATES)

7\. Regra: Quando a abertura ocorre em fevereiro de um ano divisível por 4, mas não por 100, o cálculo da próxima data de extrato considera um dia adicional.\
Condição: o mês é fevereiro, o ano é divisível por 4 e o resto da divisão do ano por 100 é maior que zero.\
Consequência: é acrescentado um dia ao cálculo da próxima data de extrato, totalizando 29 dias.\
Parágrafo: CD010 (CALCULATE-DATES)

8\. Regra: Quando a abertura ocorre em fevereiro de um ano divisível por 400, o cálculo da próxima data de extrato considera um dia adicional.\
Condição: o mês é fevereiro, o ano é divisível por 4 e por 100, e o resto da divisão do ano por 400 é zero.\
Consequência: é acrescentado um dia ao cálculo da próxima data de extrato, totalizando 29 dias.\
Parágrafo: CD010 (CALCULATE-DATES)

9\. Regra: Se o tipo de conta informado for ISA, MORTGAGE, SAVING, CURRENT ou LOAN, ele é considerado válido para a abertura da conta.\
Condição: o tipo de conta (COMM-ACC-TYPE) começa com 'ISA', 'MORTGAGE', 'SAVING', 'CURRENT' ou 'LOAN', conforme o tamanho de cada valor testado.\
Consequência: o indicador de sucesso é definido como 'Y', permitindo o prosseguimento da abertura da conta.\
Parágrafo: ATC010 (ACCOUNT-TYPE-CHECK)

10\. Regra: Se o tipo de conta informado não corresponder a nenhum dos tipos aceitos, a abertura da conta é recusada com o código de falha 'A'.\
Condição: o tipo de conta (COMM-ACC-TYPE) não começa com 'ISA', 'MORTGAGE', 'SAVING', 'CURRENT' ou 'LOAN', conforme o tamanho de cada valor testado.\
Consequência: o indicador de sucesso é definido como 'N' e o código de falha como 'A'.\
Parágrafo: ATC010 (ACCOUNT-TYPE-CHECK)