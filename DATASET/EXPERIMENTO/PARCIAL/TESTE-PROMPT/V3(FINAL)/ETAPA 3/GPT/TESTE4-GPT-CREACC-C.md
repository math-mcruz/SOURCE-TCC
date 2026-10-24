## Análise

### 1. Parágrafos e fluxo principal do programa

O programa CREACC realiza a abertura de uma conta bancária para um cliente, verificando a existência do cliente, a quantidade de contas que ele possui e o tipo de conta solicitado.

| Parágrafo ou seção                | Função no fluxo                                                                                                  |
| --------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| `PREMIERE / P010`                 | Coordena a abertura da conta, consultando o cliente, verificando o limite de contas e validando o tipo de conta. |
| `CUSTOMER-ACCOUNT-COUNT / CAC010` | Consulta a quantidade de contas associadas ao cliente por meio do programa `INQACCCU`.                           |
| `ACCOUNT-TYPE-CHECK / ATC010`     | Verifica se o tipo de conta solicitado pertence à lista de tipos aceitos.                                        |
| `ENQ-NAMED-COUNTER / ENC010`      | Obtém controle exclusivo para a geração do número da conta.                                                      |
| `FIND-NEXT-ACCOUNT / FNA010`      | Obtém o próximo número de conta e atualiza os controles de numeração e quantidade de contas.                     |
| `WRITE-ACCOUNT-DB2 / WAD010`      | Registra a nova conta e informa o resultado da operação.                                                         |
| `CALCULATE-DATES / CD010`         | Calcula datas relacionadas à abertura e aos extratos da conta.                                                   |
| `WRITE-PROCTRAN / WP010`          | Aciona o registro da operação de abertura.                                                                       |
| `WRITE-PROCTRAN-DB2 / WPD010`     | Grava o registro da operação realizada.                                                                          |
| `DEQ-NAMED-COUNTER / DNC010`      | Libera o controle exclusivo da numeração.                                                                        |
| `GET-ME-OUT-OF-HERE / GMOFH010`   | Encerra a execução do programa.                                                                                  |
| `POPULATE-TIME-DATE2 / PTD2010`   | Obtém data e hora utilizadas nos registros técnicos de erro.                                                     |

O fluxo principal consiste em consultar o cliente, consultar sua quantidade de contas, impedir a abertura quando essa quantidade ultrapassa o limite implementado, validar o tipo solicitado, gerar o número da nova conta e registrar a abertura.

### 2. Estruturas de decisão e classificação

| Parágrafo | Decisão                                             | Classificação                     | Condição e consequência                                                                                                                                        |
| --------- | --------------------------------------------------- | --------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `P010`    | `IF EIBRESP ... OR INQCUST-INQ-SUCCESS ...`         | Negócio / infraestrutura          | Se a consulta ao cliente não indicar sucesso, a abertura é recusada com código `1`. A condição também inclui falha técnica de comunicação.                     |
| `P010`    | `IF WS-CICS-RESP ...`                               | Infraestrutura                    | Se a chamada para contagem de contas apresentar falha técnica, o processamento é encerrado com código `9`.                                                     |
| `P010`    | `IF COMM-SUCCESS IN INQACCCU-COMMAREA = 'N'`        | Negócio, com motivo indeterminado | Se a consulta à quantidade de contas retornar insucesso, a abertura é impedida com código `9`. O programa não esclarece se o insucesso é funcional ou técnico. |
| `P010`    | `IF NUMBER-OF-ACCOUNTS > 9`                         | Negócio                           | Se o cliente já possuir mais de nove contas, a abertura é recusada com código `8`.                                                                             |
| `P010`    | `IF COMM-SUCCESS OF DFHCOMMAREA = 'N'`              | Negócio                           | Se a validação do tipo de conta resultar em insucesso, a abertura é interrompida.                                                                              |
| `ENC010`  | `IF WS-CICS-RESP NOT = DFHRESP(NORMAL)`             | Infraestrutura                    | Falha na obtenção do controle exclusivo encerra o processamento.                                                                                               |
| `DNC010`  | `IF WS-CICS-RESP NOT = DFHRESP(NORMAL)`             | Infraestrutura                    | Falha na liberação do controle exclusivo encerra o processamento.                                                                                              |
| `FNA010`  | `IF SQLCODE IS NOT EQUAL TO ZERO` (primeiro SELECT) | Infraestrutura                    | Falha na consulta do controle do último número de conta provoca tratamento técnico de erro.                                                                    |
| `FNA010`  | `IF SQLCODE IS NOT EQUAL TO ZERO` (primeiro UPDATE) | Infraestrutura                    | Falha na atualização do último número de conta provoca tratamento técnico de erro.                                                                             |
| `FNA010`  | `IF SQLCODE IS NOT EQUAL TO ZERO` (segundo SELECT)  | Infraestrutura                    | Falha na consulta do controle da quantidade de contas provoca tratamento técnico de erro.                                                                      |
| `FNA010`  | `IF SQLCODE IS NOT EQUAL TO ZERO` (segundo UPDATE)  | Infraestrutura                    | Falha na atualização da quantidade de contas provoca tratamento técnico de erro.                                                                               |
| `WAD010`  | `IF SQLCODE NOT = 0`                                | Infraestrutura                    | Falha na gravação da conta encerra o processamento com código `7`.                                                                                             |
| `WPD010`  | `IF SQLCODE NOT = 0`                                | Infraestrutura                    | Falha na gravação do registro de operação provoca tratamento técnico de erro.                                                                                  |
| `CD010`   | `EVALUATE WS-ORIG-DATE-MM`                          | Negócio                           | Define o avanço da data calculada para os extratos conforme o mês de abertura.                                                                                 |
| `CD010`   | `IF LEAP-YEAR = ZERO` (divisão por 4)               | Negócio                           | Se o ano for divisível por quatro, verifica os demais critérios de ano bissexto.                                                                               |
| `CD010`   | `IF LEAP-YEAR > 0` (divisão por 100)                | Negócio                           | Se o ano não for divisível por cem, acrescenta um dia ao cálculo de fevereiro.                                                                                 |
| `CD010`   | `IF LEAP-YEAR = ZERO` (divisão por 400)             | Negócio                           | Se o ano for divisível por quatrocentos, acrescenta um dia ao cálculo de fevereiro.                                                                            |
| `ATC010`  | `EVALUATE TRUE`                                     | Negócio                           | Aceita os tipos `ISA`, `MORTGAGE`, `SAVING`, `CURRENT` e `LOAN`; recusa os demais.                                                                             |

Não há decisões de navegação de tela ou teclas de função classificadas como interface no código fornecido.

### 3. Condições de negócio e particularidades

Consulta do cliente. O programa verifica o indicador de sucesso retornado por `INQCUST`. O código não contém uma condição explícita que diferencie cliente inexistente de outros motivos de insucesso na consulta. Portanto, a regra deve ser descrita como recusa quando a consulta não confirma o sucesso, e não como comprovação de inexistência cadastral.

Quantidade de contas. A comparação implementada é estritamente `NUMBER-OF-ACCOUNTS > 9`. Dessa forma, um cliente com exatamente nove contas não é barrado por essa verificação. A quantidade é fornecida pelo programa externo `INQACCCU`, cujo código não foi disponibilizado.

Tipo de conta. A validação compara apenas o início do conteúdo informado, utilizando comprimentos diferentes para cada tipo. Assim, não existe uma exigência explícita de igualdade do conteúdo completo do campo.

Data dos extratos. `CALCULATE-DATES` possui caminhos distintos para fevereiro em anos comuns e bissextos. Entretanto, `WRITE-ACCOUNT-DB2` realiza posteriormente outro cálculo, acrescentando sempre 30 dias à data de abertura e preenchendo a data do próximo extrato que será gravada no banco.

Portanto, os caminhos de decisão de fevereiro são relevantes para documentar o cálculo em `CALCULATE-DATES`, mas não determinam, isoladamente, a data do próximo extrato persistida na conta. Essa distinção evita atribuir ao programa um comportamento que o fluxo completo não garante.

A definição da data do próximo extrato como 30 dias após a abertura e a inicialização da data do último extrato com a data de abertura são operações sem decisão associada. Por isso, não constituem regras independentes no escopo solicitado.

## Regras de negócio

1\. Regra: A abertura de uma conta é recusada quando a consulta dos dados do cliente não confirma seu sucesso.

Condição: Quando `INQCUST-INQ-SUCCESS` for diferente de `Y`, independentemente de a comunicação com o programa de consulta ter sido tecnicamente bem-sucedida.

Consequência: A abertura é interrompida, com indicador de insucesso e código de recusa `1`. O motivo específico do insucesso da consulta não é identificado pelo programa.

Parágrafo: `PREMIERE / P010`.

2\. Regra: A abertura de uma conta é impedida quando não é possível confirmar com sucesso a consulta da quantidade de contas do cliente.

Condição: Quando `COMM-SUCCESS` retornado por `INQACCCU` for `N`, após a chamada ao programa ter retornado normalmente.

Consequência: A abertura é interrompida com indicador de insucesso e código `9`. O código não permite determinar se a recusa da consulta decorre de uma condição de negócio ou de um problema interno do programa consultado.

Parágrafo: `PREMIERE / P010`.

3\. Regra: Um cliente que já possui dez ou mais contas não pode abrir outra conta.

Condição: Quando a quantidade de contas retornada para o cliente (`NUMBER-OF-ACCOUNTS`) for maior que `9`.

Consequência: A solicitação de abertura é recusada, com indicador de insucesso e código `8`.

Parágrafo: `PREMIERE / P010`.

4\. Regra: A abertura da conta é interrompida quando a validação do tipo de conta solicitado indica insucesso.

Condição: Quando `COMM-SUCCESS` estiver igual a `N` após a execução de `ACCOUNT-TYPE-CHECK`.

Consequência: O processamento da abertura é encerrado sem prosseguir para a geração do número e a gravação da nova conta.

Parágrafo: `PREMIERE / P010`.

5\. Regra: A abertura de conta aceita solicitações cujo tipo informado corresponda a um dos tipos bancários permitidos.

Condição: Quando o início do campo de tipo de conta (`COMM-ACC-TYPE`) corresponder a `ISA`, `MORTGAGE`, `SAVING`, `CURRENT` ou `LOAN`, considerando respectivamente os primeiros 3, 8, 6, 7 ou 4 caracteres.

Consequência: O tipo de conta é considerado válido e a abertura fica autorizada a prosseguir para as etapas seguintes.

Parágrafo: `ACCOUNT-TYPE-CHECK / ATC010`.

6\. Regra: A abertura de conta rejeita tipos de conta que não correspondam a nenhuma das categorias bancárias permitidas.

Condição: Quando o campo `COMM-ACC-TYPE` não corresponder, nas posições verificadas, a `ISA`, `MORTGAGE`, `SAVING`, `CURRENT` ou `LOAN`.

Consequência: A validação retorna insucesso, com código de recusa `A`.

Parágrafo: `ACCOUNT-TYPE-CHECK / ATC010`.

7\. Regra: Para contas abertas em qualquer mês diferente de fevereiro, o cálculo da data de referência dos extratos utiliza um avanço de 30 dias.

Condição: Quando o mês da data de abertura (`WS-ORIG-DATE-MM`) for janeiro, março, abril, maio, junho, julho, agosto, setembro, outubro, novembro ou dezembro.

Consequência: O cálculo realizado em `CALCULATE-DATES` acrescenta 30 dias à data de abertura. Essa data calculada não é necessariamente a data do próximo extrato efetivamente gravada, pois é recalculada posteriormente.

Parágrafo: `CALCULATE-DATES / CD010`.

8\. Regra: Para contas abertas em fevereiro de um ano comum, o cálculo da data de referência dos extratos utiliza um avanço de 28 dias.

Condição: Quando o mês de abertura for fevereiro e o ano não for bissexto, isto é, não for divisível por 4 ou for divisível por 100 sem ser divisível por 400.

Consequência: O cálculo realizado em `CALCULATE-DATES` acrescenta 28 dias à data de abertura, sem ajuste adicional. O valor calculado é posteriormente substituído no fluxo de gravação da conta.

Parágrafo: `CALCULATE-DATES / CD010`.

9\. Regra: Para contas abertas em fevereiro de um ano bissexto não centenário, o cálculo da data de referência dos extratos utiliza um avanço de 29 dias.

Condição: Quando o mês de abertura for fevereiro, o ano for divisível por 4 e não for divisível por 100.

Consequência: O cálculo realizado em `CALCULATE-DATES` acrescenta 28 dias e mais um dia adicional à data de abertura, totalizando 29 dias. O valor calculado é posteriormente substituído no fluxo de gravação da conta.

Parágrafo: `CALCULATE-DATES / CD010`.

10\. Regra: Para contas abertas em fevereiro de um ano centenário bissexto, o cálculo da data de referência dos extratos utiliza um avanço de 29 dias.

Condição: Quando o mês de abertura for fevereiro e o ano for divisível por 100 e também por 400.

Consequência: O cálculo realizado em `CALCULATE-DATES` acrescenta 28 dias e mais um dia adicional à data de abertura, totalizando 29 dias. O valor calculado é posteriormente substituído no fluxo de gravação da conta.

Parágrafo: `CALCULATE-DATES / CD010`.