## Análise

### 1. Parágrafos e fluxo principal

O programa COBOL `CREACC` implementa a abertura de contas bancárias.

O fluxo principal, no parágrafo `P010`, consulta o cliente, verifica a quantidade de contas existentes, valida o tipo de conta solicitado, obtém um novo número de conta e realiza o cadastramento.

Os principais parágrafos são:

- `P010`: coordena a abertura da conta e suas verificações.
- `CAC010`: consulta a quantidade de contas do cliente.
- `ATC010`: valida o tipo de conta solicitado.
- `ENC010` e `DNC010`: controlam o acesso exclusivo ao contador de contas.
- `FNA010`: obtém o próximo número de conta e atualiza os controles.
- `WAD010`: grava a nova conta.
- `CD010`: calcula as datas associadas à abertura.
- `WP010` e `WPD010`: registram a operação de abertura.
- `GMOFH010`: encerra a execução.
- `PTD2010`: obtém informações de data e hora para tratamento técnico.

### 2. Estruturas de decisão identificadas

| Parágrafo | Decisão                                                                        | Classificação                       |
| --------- | ------------------------------------------------------------------------------ | ----------------------------------- |
| `P010`    | Falha na consulta ou ausência de confirmação de sucesso da consulta do cliente | Negócio                             |
| `P010`    | Falha técnica na chamada de contagem de contas                                 | Infraestrutura                      |
| `P010`    | Consulta de quantidade de contas retorna insucesso                             | Negócio, com causa não especificada |
| `P010`    | Quantidade de contas superior a 9                                              | Negócio                             |
| `P010`    | Validação do tipo de conta retorna insucesso                                   | Negócio                             |
| `ENC010`  | Falha na obtenção de acesso exclusivo ao contador                              | Infraestrutura                      |
| `DNC010`  | Falha na liberação do acesso exclusivo                                         | Infraestrutura                      |
| `FNA010`  | Falha nas consultas ou atualizações dos controles                              | Infraestrutura                      |
| `WAD010`  | Falha na gravação da conta                                                     | Infraestrutura                      |
| `WPD010`  | Falha na gravação do registro de processamento                                 | Infraestrutura                      |
| `CD010`   | Mês com 30 ou 31 dias                                                          | Negócio                             |
| `CD010`   | Mês de fevereiro                                                               | Negócio                             |
| `CD010`   | Ano divisível por 4                                                            | Negócio                             |
| `CD010`   | Ano divisível por 100                                                          | Negócio                             |
| `CD010`   | Ano divisível por 400                                                          | Negócio                             |
| `ATC010`  | Tipo de conta pertence à lista aceita                                          | Negócio                             |
| `ATC010`  | Tipo de conta não pertence à lista aceita                                      | Negócio                             |

Não foram identificadas decisões específicas de navegação ou validação de formato de campos.

### 3. Condições e consequências de negócio

As decisões de negócio estabelecem que a abertura depende do sucesso da consulta do cliente e da consulta de quantidade de contas, que clientes com mais de nove contas não podem abrir outra conta e que somente determinados tipos de conta são aceitos.

O tratamento das datas diferencia fevereiro dos demais meses. Para fevereiro, considera 28 dias ou 29 dias conforme os testes de ano bissexto. Os demais meses utilizam 30 dias no cálculo realizado por `CD010`.

Existe uma particularidade importante: embora `CD010` calcule a próxima data de extrato com base no mês e no ano, `WAD010` realiza posteriormente outro cálculo, adicionando sempre 30 dias à data de abertura, e utiliza esse resultado para preencher a data do próximo extrato gravada na conta.

### 4. Critérios de consolidação

As verificações de infraestrutura, registros técnicos e atribuições sem decisão associada foram excluídos da relação final.

As alternativas de tipo de conta foram separadas por valor aceito. As verificações de ano bissexto também foram separadas conforme os caminhos condicionais implementados.

## Regras de negócio

1\. Regra: A abertura de uma conta não pode prosseguir quando a consulta do cliente não é concluída com sucesso.\
Condição: Quando a chamada de consulta do cliente não retorna normalmente ou a consulta não confirma sucesso (`INQCUST-INQ-SUCCESS` diferente de `Y`).\
Consequência: A abertura da conta é recusada, com código de falha `1`.\
Parágrafo: `P010`

2\. Regra: A abertura de uma conta não pode prosseguir quando a consulta da quantidade de contas do cliente informa insucesso.\
Condição: Quando `COMM-SUCCESS` da consulta `INQACCCU` é igual a `N`.\
Consequência: A abertura é interrompida, com código de falha `9`, sem que o programa identifique a causa de negócio do insucesso.\
Parágrafo: `P010`

3\. Regra: Um cliente que já possui dez ou mais contas não pode abrir outra conta.\
Condição: Quando a quantidade de contas existentes do cliente (`NUMBER-OF-ACCOUNTS`) é superior a `9`.\
Consequência: A abertura é recusada, com código de falha `8`.\
Parágrafo: `P010`

4\. Regra: A abertura de uma conta deve ser interrompida quando o tipo de conta informado não é aceito.\
Condição: Quando a validação do tipo de conta define `COMM-SUCCESS` como `N`.\
Consequência: O processamento da abertura é encerrado sem criar a conta.\
Parágrafo: `P010`

5\. Regra: Para meses diferentes de fevereiro, o cálculo da próxima data de extrato considera um intervalo de 30 dias.\
Condição: Quando o mês da abertura é janeiro, março, abril, maio, junho, julho, agosto, setembro, outubro, novembro ou dezembro.\
Consequência: São acrescentados 30 dias à data de abertura no cálculo realizado pelo programa.\
Parágrafo: `CD010`

6\. Regra: Para contas abertas em fevereiro, o cálculo inicial da próxima data de extrato considera 28 dias.\
Condição: Quando o mês da abertura é fevereiro.\
Consequência: São acrescentados inicialmente 28 dias à data de abertura.\
Parágrafo: `CD010`

7\. Regra: O cálculo da próxima data de extrato em fevereiro considera a possibilidade de ano bissexto apenas quando o ano é divisível por quatro.\
Condição: Quando o mês da abertura é fevereiro e o resto da divisão do ano por `4` é zero.\
Consequência: O programa verifica se o ano é divisível por `100` para determinar a necessidade de acrescentar mais um dia.\
Parágrafo: `CD010`

8\. Regra: Em fevereiro de um ano divisível por quatro, mas não por cem, o cálculo considera 29 dias.\
Condição: Quando o ano é divisível por `4` e o resto da divisão por `100` é maior que zero.\
Consequência: É acrescentado um dia ao intervalo inicial de 28 dias.\
Parágrafo: `CD010`

9\. Regra: Em fevereiro de um ano divisível por cem, a consideração de um dia adicional depende de o ano ser divisível por quatrocentos.\
Condição: Quando o ano é divisível por `4` e por `100`.\
Consequência: O programa verifica a divisibilidade por `400` para decidir se acrescenta mais um dia ao cálculo.\
Parágrafo: `CD010`

10\. Regra: Em fevereiro de um ano divisível por quatrocentos, o cálculo considera 29 dias.\
Condição: Quando o resto da divisão do ano por `400` é zero, após as verificações anteriores.\
Consequência: É acrescentado um dia ao intervalo inicial de 28 dias.\
Parágrafo: `CD010`

11\. Regra: O tipo de conta ISA é permitido na abertura de uma conta bancária.\
Condição: Quando os três primeiros caracteres do tipo de conta são `ISA`.\
Consequência: O tipo de conta é considerado válido.\
Parágrafo: `ATC010`

12\. Regra: O tipo de conta MORTGAGE é permitido na abertura de uma conta bancária.\
Condição: Quando os oito primeiros caracteres do tipo de conta são `MORTGAGE`.\
Consequência: O tipo de conta é considerado válido.\
Parágrafo: `ATC010`

13\. Regra: O tipo de conta SAVING é permitido na abertura de uma conta bancária.\
Condição: Quando os seis primeiros caracteres do tipo de conta são `SAVING`.\
Consequência: O tipo de conta é considerado válido.\
Parágrafo: `ATC010`

14\. Regra: O tipo de conta CURRENT é permitido na abertura de uma conta bancária.\
Condição: Quando os sete primeiros caracteres do tipo de conta são `CURRENT`.\
Consequência: O tipo de conta é considerado válido.\
Parágrafo: `ATC010`

15\. Regra: O tipo de conta LOAN é permitido na abertura de uma conta bancária.\
Condição: Quando os quatro primeiros caracteres do tipo de conta são `LOAN`.\
Consequência: O tipo de conta é considerado válido.\
Parágrafo: `ATC010`

16\. Regra: A abertura de contas com tipos diferentes dos cinco tipos permitidos é recusada.\
Condição: Quando o tipo informado não começa com `ISA`, `MORTGAGE`, `SAVING`, `CURRENT` ou `LOAN`, considerando os comprimentos específicos de cada comparação.\
Consequência: O tipo de conta é considerado inválido e é atribuído o código de falha `A`.\
Parágrafo: `ATC010`