1\. Regra: A abertura de conta não é permitida quando o cliente informado não é localizado ou sua consulta não é concluída com sucesso.\
Condição: Quando a consulta do cliente não retorna confirmação de sucesso (`INQCUST-INQ-SUCCESS` diferente de `Y`), ou sua execução não é concluída normalmente.\
Consequência: A abertura da conta é recusada, com indicação de insucesso e código de falha `1`.\
Parágrafo: PREMIERE (P010).

2\. Regra: A abertura de conta não pode prosseguir quando não é possível obter a quantidade de contas vinculadas ao cliente.\
Condição: Quando a consulta de quantidade de contas retorna `COMM-SUCCESS = 'N'`.\
Consequência: A abertura da conta é recusada, com indicação de insucesso e código de falha `9`.\
Parágrafo: PREMIERE (P010).

3\. Regra: Um cliente pode possuir no máximo 10 contas para que uma nova abertura seja permitida.\
Condição: Quando a quantidade de contas existentes do cliente (`NUMBER-OF-ACCOUNTS`) é superior a 9.\
Consequência: A abertura de uma nova conta é recusada, com indicação de insucesso e código de falha `8`.\
Parágrafo: PREMIERE (P010).

4\. Regra: A abertura de conta somente prossegue quando o tipo de conta informado é aceito.\
Condição: Quando a verificação do tipo de conta resulta em `COMM-SUCCESS = 'N'`.\
Consequência: O processamento da abertura é encerrado sem criar a conta.\
Parágrafo: PREMIERE (P010).

5\. Regra: Os tipos de conta ISA, MORTGAGE, SAVING, CURRENT e LOAN são aceitos para abertura de conta.\
Condição: Quando o início do tipo de conta informado (`COMM-ACC-TYPE`) corresponde a `ISA`, `MORTGAGE`, `SAVING`, `CURRENT` ou `LOAN`, conforme os respectivos comprimentos comparados pelo programa.\
Consequência: O tipo de conta é aprovado, permitindo a continuidade da abertura.\
Parágrafo: ACCOUNT-TYPE-CHECK (ATC010).

6\. Regra: A abertura de conta é recusada quando o tipo de conta informado não pertence aos tipos aceitos.\
Condição: Quando o tipo informado não corresponde a nenhum dos valores reconhecidos: `ISA`, `MORTGAGE`, `SAVING`, `CURRENT` ou `LOAN`.\
Consequência: O tipo de conta é rejeitado, com indicação de insucesso e código de falha `A`.\
Parágrafo: ACCOUNT-TYPE-CHECK (ATC010).

7\. Regra: Para contas abertas em janeiro, março, maio, julho, agosto, outubro ou dezembro, o cálculo da data do próximo extrato considera um acréscimo de 30 dias.\
Condição: Quando o mês da abertura (`WS-ORIG-DATE-MM`) é `1`, `3`, `5`, `7`, `8`, `10` ou `12`.\
Consequência: São adicionados 30 dias à data-base utilizada no cálculo, embora o valor calculado nesse parágrafo seja posteriormente substituído no processamento da abertura.\
Parágrafo: CALCULATE-DATES (CD010).

8\. Regra: Para contas abertas em abril, junho, setembro ou novembro, o cálculo da data do próximo extrato considera um acréscimo de 30 dias.\
Condição: Quando o mês da abertura (`WS-ORIG-DATE-MM`) é `4`, `6`, `9` ou `11`.\
Consequência: São adicionados 30 dias à data-base utilizada no cálculo, embora o valor calculado nesse parágrafo seja posteriormente substituído no processamento da abertura.\
Parágrafo: CALCULATE-DATES (CD010).

9\. Regra: Para contas abertas em fevereiro de um ano que não é divisível por 4, o cálculo da data do próximo extrato considera um acréscimo de 28 dias.\
Condição: Quando o mês da abertura é fevereiro e o ano não é divisível por 4.\
Consequência: São adicionados 28 dias à data-base utilizada no cálculo, embora o valor calculado nesse parágrafo seja posteriormente substituído no processamento da abertura.\
Parágrafo: CALCULATE-DATES (CD010).

10\. Regra: Para contas abertas em fevereiro de um ano divisível por 4, mas não por 100, o cálculo da data do próximo extrato considera um acréscimo de 29 dias.\
Condição: Quando o mês da abertura é fevereiro, o ano é divisível por 4 e não é divisível por 100.\
Consequência: São adicionados 29 dias à data-base utilizada no cálculo, embora o valor calculado nesse parágrafo seja posteriormente substituído no processamento da abertura.\
Parágrafo: CALCULATE-DATES (CD010).

11\. Regra: Para contas abertas em fevereiro de um ano divisível por 100 e por 400, o cálculo da data do próximo extrato considera um acréscimo de 29 dias.\
Condição: Quando o mês da abertura é fevereiro e o ano é divisível por 400.\
Consequência: São adicionados 29 dias à data-base utilizada no cálculo, embora o valor calculado nesse parágrafo seja posteriormente substituído no processamento da abertura.\
Parágrafo: CALCULATE-DATES (CD010).

12\. Regra: Para contas abertas em fevereiro de um ano divisível por 100, mas não por 400, o cálculo da data do próximo extrato considera um acréscimo de 28 dias.\
Condição: Quando o mês da abertura é fevereiro, o ano é divisível por 100 e não é divisível por 400.\
Consequência: São adicionados 28 dias à data-base utilizada no cálculo, embora o valor calculado nesse parágrafo seja posteriormente substituído no processamento da abertura.\
Parágrafo: CALCULATE-DATES (CD010).