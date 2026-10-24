## Análise

### 1. Parágrafos e fluxo principal do programa

O programa CREACC realiza a abertura de uma conta bancária para um cliente existente.

O fluxo principal, definido em `PREMIERE / P010`, é:

1. Consultar o cliente por meio do programa `INQCUST`.
2. Consultar a quantidade de contas do cliente por meio de `CUSTOMER-ACCOUNT-COUNT`.
3. Impedir a abertura quando o cliente já possuir mais de nove contas.
4. Validar o tipo de conta solicitado em `ACCOUNT-TYPE-CHECK`.
5. Obter o próximo número de conta em `FIND-NEXT-ACCOUNT`.
6. Criar a conta com os dados recebidos e as datas calculadas em `WRITE-ACCOUNT-DB2`.
7. Registrar uma transação de abertura e devolver o resultado da operação.

As demais seções são `ENQ-NAMED-COUNTER`, `DEQ-NAMED-COUNTER`, `WRITE-PROCTRAN`, `WRITE-PROCTRAN-DB2`, `GET-ME-OUT-OF-HERE`, `CALCULATE-DATES` e `POPULATE-TIME-DATE2`.

### 2. Estruturas de decisão e classificação

| Parágrafo | Decisão ou processamento                                                    | Classificação                        |
| --------- | --------------------------------------------------------------------------- | ------------------------------------ |
| P010      | Cliente não localizado ou consulta sem sucesso                              | Negócio, com teste técnico associado |
| P010      | Falha na execução da consulta de quantidade de contas                       | Infraestrutura                       |
| P010      | Consulta de quantidade de contas retorna insucesso                          | Infraestrutura                       |
| P010      | Quantidade de contas maior que 9                                            | Negócio                              |
| P010      | Resultado da validação do tipo de conta é negativo                          | Negócio                              |
| ENC010    | Falha na obtenção do controle de exclusividade                              | Infraestrutura                       |
| DNC010    | Falha na liberação do controle de exclusividade                             | Infraestrutura                       |
| FNA010    | Testes de SQLCODE nas consultas e atualizações                              | Infraestrutura                       |
| FNA010    | Incremento dos números sequenciais da conta e da quantidade geral de contas | Negócio                              |
| WAD010    | Gravação dos atributos da nova conta                                        | Negócio                              |
| WAD010    | Falha na inclusão da conta no banco de dados                                | Infraestrutura                       |
| WPD010    | Falha no registro de processamento                                          | Infraestrutura                       |
| CD010     | EVALUATE do mês para determinar o intervalo de datas                        | Negócio                              |
| CD010     | IF de divisibilidade por 4, 100 e 400 para ano bissexto                     | Negócio                              |
| ATC010    | EVALUATE dos tipos de conta aceitos                                         | Negócio                              |
| PTD2010   | Obtenção de data e hora para processamento técnico                          | Infraestrutura                       |

Não foram identificadas validações de obrigatoriedade de campos nem decisões relacionadas à navegação de interface.

### 3. Condições e consequências de negócio identificadas

A consulta inicial do cliente impede a abertura quando não retorna sucesso, embora o código também agrupe falhas técnicas nessa condição.

A quantidade máxima permitida é de dez contas por cliente: a abertura é rejeitada quando a quantidade existente é superior a nove.

Os tipos aceitos são `ISA`, `MORTGAGE`, `SAVING`, `CURRENT` e `LOAN`. A comparação utiliza prefixos de comprimento específico, o que permite aprovar valores que comecem pelos textos aceitos, mesmo com caracteres adicionais.

A numeração é obtida de um contador associado ao código da agência (`SORTCODE`). O programa também incrementa um contador geral de contas associado a esse código.

Na criação, são utilizados os dados recebidos para identificação do cliente, agência, tipo de conta, taxa de juros, limite de cheque especial e saldos inicial disponível e efetivo. Não há validação de valores monetários nesses campos.

A data de abertura é a data corrente; a data do último extrato é inicializada com essa mesma data. O cálculo efetuado em `CALCULATE-DATES` utiliza acréscimos de 30 dias para meses diferentes de fevereiro e de 28 ou 29 dias para fevereiro. Entretanto, `WRITE-ACCOUNT-DB2` substitui posteriormente a data do próximo extrato por uma data calculada com acréscimo fixo de 30 dias à data corrente. Portanto, a regra efetivamente gravada para o próximo extrato é de 30 dias após a abertura.

### 4. Critérios de seleção

Foram excluídos os testes de falhas técnicas, os controles de concorrência, os registros de processamento e os procedimentos de encerramento. Foram mantidos os critérios de elegibilidade, os limites de contas, a seleção do tipo de conta, a atribuição dos dados da nova conta e as regras de datas.

## Regras de negócio

1\. Regra: A abertura de uma conta depende da confirmação da existência do cliente no banco.\
Condição: Quando a consulta do cliente não retorna sucesso (`INQCUST-INQ-SUCCESS` diferente de `Y`).\
Consequência: A abertura é recusada, com indicador de insucesso e código de falha `1`. O mesmo tratamento também ocorre em caso de falha técnica na chamada, sem distinção entre as duas situações.\
Parágrafo: P010 (PREMIERE).

2\. Regra: Um cliente não pode abrir uma nova conta se já possuir dez ou mais contas.\
Condição: Quando a quantidade de contas existentes do cliente (`NUMBER-OF-ACCOUNTS`) é maior que 9.\
Consequência: A abertura é recusada, com indicador de insucesso e código de falha `8`.\
Parágrafo: P010 (PREMIERE).

3\. Regra: É permitida a abertura de contas dos tipos ISA, MORTGAGE, SAVING, CURRENT e LOAN.\
Condição: Quando o tipo de conta informado começa por `ISA`, `MORTGAGE`, `SAVING`, `CURRENT` ou `LOAN`, considerando respectivamente os primeiros 3, 8, 6, 7 ou 4 caracteres.\
Consequência: O tipo de conta é aprovado e o processamento da abertura pode continuar.\
Parágrafo: ATC010 (ACCOUNT-TYPE-CHECK).

4\. Regra: A abertura de conta é recusada quando o tipo solicitado não pertence aos tipos aceitos pelo banco.\
Condição: Quando o tipo informado não corresponde a nenhum dos prefixos `ISA`, `MORTGAGE`, `SAVING`, `CURRENT` ou `LOAN`.\
Consequência: A validação é rejeitada, com indicador de insucesso e código de falha `A`.\
Parágrafo: ATC010 (ACCOUNT-TYPE-CHECK).

5\. Regra: Cada nova conta recebe uma numeração sequencial associada ao código da agência.\
Condição: Quando uma abertura chega à etapa de geração do número da conta e o contador `SORTCODE-ACCOUNT-LAST` é consultado com sucesso.\
Consequência: O contador é incrementado em uma unidade e o novo valor é atribuído à conta.\
Parágrafo: FNA010 (FIND-NEXT-ACCOUNT).

6\. Regra: A quantidade geral de contas associada à agência é incrementada a cada abertura processada nessa etapa.\
Condição: Quando o contador `SORTCODE-ACCOUNT-COUNT` é consultado com sucesso durante a abertura.\
Consequência: O total registrado para a agência é aumentado em uma unidade, antes da efetiva inclusão da nova conta.\
Parágrafo: FNA010 (FIND-NEXT-ACCOUNT).

7\. Regra: A nova conta é vinculada ao cliente informado na solicitação de abertura.\
Condição: Quando a conta é preparada para inclusão.\
Consequência: O número do cliente informado (`COMM-CUSTNO`) é atribuído ao cadastro da nova conta.\
Parágrafo: WAD010 (WRITE-ACCOUNT-DB2).

8\. Regra: A nova conta é cadastrada com o código da agência utilizado na operação.\
Condição: Quando a conta é preparada para inclusão.\
Consequência: O código da agência (`SORTCODE`) é atribuído à nova conta.\
Parágrafo: WAD010 (WRITE-ACCOUNT-DB2).

9\. Regra: O cadastro da nova conta utiliza os oito últimos dígitos do número sequencial gerado.\
Condição: Quando o número da nova conta é preparado para gravação.\
Consequência: Os oito últimos dígitos do número gerado são utilizados como número da conta cadastrada.\
Parágrafo: WAD010 (WRITE-ACCOUNT-DB2).

10\. Regra: A nova conta é cadastrada com o tipo de conta solicitado.\
Condição: Quando a conta é preparada para inclusão após a aprovação do tipo informado.\
Consequência: O tipo recebido (`COMM-ACC-TYPE`) é atribuído à nova conta.\
Parágrafo: WAD010 (WRITE-ACCOUNT-DB2).

11\. Regra: A nova conta é cadastrada com a taxa de juros informada na solicitação.\
Condição: Quando a conta é preparada para inclusão.\
Consequência: A taxa de juros recebida (`COMM-INT-RT`) é atribuída à nova conta, sem validação adicional de seu valor neste programa.\
Parágrafo: WAD010 (WRITE-ACCOUNT-DB2).

12\. Regra: A nova conta é cadastrada com o limite de cheque especial informado na solicitação.\
Condição: Quando a conta é preparada para inclusão.\
Consequência: O limite recebido (`COMM-OVERDR-LIM`) é atribuído à nova conta, sem validação adicional de seu valor neste programa.\
Parágrafo: WAD010 (WRITE-ACCOUNT-DB2).

13\. Regra: A nova conta é cadastrada com o saldo disponível informado na solicitação.\
Condição: Quando a conta é preparada para inclusão.\
Consequência: O saldo disponível recebido (`COMM-AVAIL-BAL`) é atribuído à nova conta.\
Parágrafo: WAD010 (WRITE-ACCOUNT-DB2).

14\. Regra: A nova conta é cadastrada com o saldo efetivo informado na solicitação.\
Condição: Quando a conta é preparada para inclusão.\
Consequência: O saldo efetivo recebido (`COMM-ACT-BAL`) é atribuído à nova conta.\
Parágrafo: WAD010 (WRITE-ACCOUNT-DB2).

15\. Regra: O próximo extrato da conta é programado para 30 dias após a data de abertura.\
Condição: Quando a nova conta é preparada para inclusão e a data corrente é utilizada como referência.\
Consequência: A data do próximo extrato gravada no cadastro é definida como a data corrente acrescida de 30 dias, independentemente do mês.\
Parágrafo: WAD010 (WRITE-ACCOUNT-DB2).

16\. Regra: A data de abertura da nova conta corresponde à data corrente do processamento.\
Condição: Quando a rotina de cálculo de datas é executada.\
Consequência: A data corrente é atribuída à data de abertura da conta.\
Parágrafo: CD010 (CALCULATE-DATES).

17\. Regra: A data do último extrato de uma conta recém-aberta é inicializada com a data de abertura.\
Condição: Quando a rotina de cálculo de datas é executada para uma nova conta.\
Consequência: A data corrente é atribuída à data do último extrato, mesmo sem existir um extrato anterior.\
Parágrafo: CD010 (CALCULATE-DATES).

18\. Regra: O cálculo intermediário da data do próximo extrato acrescenta 30 dias quando a abertura ocorre em janeiro, março, maio, julho, agosto, outubro ou dezembro.\
Condição: Quando o mês da data corrente é `1`, `3`, `5`, `7`, `8`, `10` ou `12`.\
Consequência: São acrescentados 30 dias à data de referência para calcular a data intermediária do próximo extrato. Esse resultado é posteriormente substituído no cadastro pela regra de 30 dias fixos de `WAD010`.\
Parágrafo: CD010 (CALCULATE-DATES).

19\. Regra: O cálculo intermediário da data do próximo extrato acrescenta 30 dias quando a abertura ocorre em abril, junho, setembro ou novembro.\
Condição: Quando o mês da data corrente é `4`, `6`, `9` ou `11`.\
Consequência: São acrescentados 30 dias à data de referência para calcular a data intermediária do próximo extrato, posteriormente substituída no cadastro.\
Parágrafo: CD010 (CALCULATE-DATES).

20\. Regra: O cálculo intermediário da data do próximo extrato acrescenta 28 dias quando a abertura ocorre em fevereiro.\
Condição: Quando o mês da data corrente é fevereiro (`WS-ORIG-DATE-MM = 2`).\
Consequência: São acrescentados inicialmente 28 dias à data de referência, antes de considerar eventual ajuste por ano bissexto. Esse cálculo não determina a data finalmente gravada no cadastro.\
Parágrafo: CD010 (CALCULATE-DATES).

21\. Regra: O cálculo intermediário considera um dia adicional em fevereiro de ano divisível por quatro que não seja divisível por cem.\
Condição: Quando o mês é fevereiro, o ano é divisível por 4 e não é divisível por 100.\
Consequência: É acrescentado mais um dia ao cálculo intermediário do próximo extrato, totalizando 29 dias.\
Parágrafo: CD010 (CALCULATE-DATES).

22\. Regra: O cálculo intermediário considera um dia adicional em fevereiro de ano divisível por quatrocentos.\
Condição: Quando o mês é fevereiro e o ano é divisível por 4, por 100 e por 400.\
Consequência: É acrescentado mais um dia ao cálculo intermediário do próximo extrato, totalizando 29 dias.\
Parágrafo: CD010 (CALCULATE-DATES).

23\. Regra: O cálculo intermediário de fevereiro mantém o intervalo de 28 dias para anos centenários não divisíveis por quatrocentos.\
Condição: Quando o mês é fevereiro, o ano é divisível por 100, mas não por 400.\
Consequência: Nenhum dia adicional é acrescentado aos 28 dias inicialmente calculados.\
Parágrafo: CD010 (CALCULATE-DATES).

24\. Regra: Uma abertura concluída com sucesso disponibiliza o número da conta, o código da agência e as datas da conta criada.\
Condição: Quando a inclusão da nova conta é concluída com sucesso.\
Consequência: São devolvidos o código da agência, o número da conta, a data de abertura, a data do último extrato e a data do próximo extrato, com indicador de sucesso `Y` e código de falha em branco.\
Parágrafo: WAD010 (WRITE-ACCOUNT-DB2).