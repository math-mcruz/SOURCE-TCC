## Análise

### 1. Parágrafos e fluxo principal do programa

O programa BNK1CAC é responsável por receber e validar informações para a criação de uma conta bancária. Após a validação, solicita a criação da conta ao programa `CREACC` e interpreta o resultado retornado.

| Seção / Parágrafo               | Responsabilidade                                                                                       |
| ------------------------------- | ------------------------------------------------------------------------------------------------------ |
| `PREMIERE / A010`               | Controlar o início da transação, as ações do usuário e a continuidade da sessão.                       |
| `PROCESS-MAP / PM010`           | Receber os dados, executar as validações e solicitar a criação da conta quando os dados forem válidos. |
| `RECEIVE-MAP / RM010`           | Receber as informações fornecidas pelo usuário.                                                        |
| `EDIT-DATA / ED010`             | Validar número do cliente, tipo de conta, taxa de juros e limite de cheque especial.                   |
| `CRE-ACC-DATA / CAD010`         | Solicitar a criação da conta ao programa `CREACC` e interpretar o resultado da operação.               |
| `SEND-MAP / SM010`              | Controlar a apresentação de informações e mensagens.                                                   |
| `SEND-TERMINATION-MSG / STM010` | Apresentar a mensagem de encerramento da sessão.                                                       |
| `ABEND-THIS-TASK / ATT010`      | Encerrar a execução em situações de falha técnica.                                                     |
| `POPULATE-TIME-DATE / PTD010`   | Obter data e hora para o tratamento de falhas técnicas.                                                |

Fluxo principal:

1. O programa inicia a interação com o usuário.
2. Quando o usuário confirma os dados, o programa executa `PROCESS-MAP`.
3. `PROCESS-MAP` recebe as informações e chama `EDIT-DATA`.
4. `EDIT-DATA` verifica os campos obrigatórios, os tipos de conta aceitos, os limites da taxa de juros e as demais condições de validação.
5. Se os dados forem válidos, `PROCESS-MAP` executa `CRE-ACC-DATA`.
6. `CRE-ACC-DATA` solicita a criação da conta ao programa `CREACC`.
7. O programa interpreta o resultado retornado: informa sucesso ou apresenta a razão pela qual a conta não foi criada.
8. A aplicação apresenta o resultado ao usuário.

O código analisado não contém a implementação interna de `CREACC`. Portanto, somente é possível documentar as decisões e os resultados efetivamente tratados por `BNK1CAC`.

### 2. Estruturas de decisão e classificação

#### PREMIERE / A010

| Estrutura                               | Condição ou finalidade                                                       | Classificação  |
| --------------------------------------- | ---------------------------------------------------------------------------- | -------------- |
| `EVALUATE TRUE`                         | Distingue início de interação, teclas de função, confirmação e outras ações. | Interface      |
| `IF EIBCALEN NOT = 0`                   | Determina a preparação dos dados de continuidade da transação.               | Infraestrutura |
| `IF WS-CICS-RESP NOT = DFHRESP(NORMAL)` | Trata falha técnica no retorno da transação.                                 | Infraestrutura |

Nenhuma dessas decisões gera regra de negócio no escopo definido.

#### PROCESS-MAP / PM010

| Estrutura       | Condição                                                     | Consequência                 | Classificação |
| --------------- | ------------------------------------------------------------ | ---------------------------- | ------------- |
| `IF VALID-DATA` | Todas as validações foram concluídas sem invalidar os dados. | Solicita a criação da conta. | Negócio       |

O caminho contrário impede a solicitação de criação quando alguma validação falha.

#### RECEIVE-MAP / RM010

| Estrutura                               | Condição ou finalidade                              | Classificação  |
| --------------------------------------- | --------------------------------------------------- | -------------- |
| `IF WS-CICS-RESP NOT = DFHRESP(NORMAL)` | Trata falha técnica no recebimento das informações. | Infraestrutura |

#### EDIT-DATA / ED010

| Estrutura                                                    | Condição                                                                                    | Consequência                                                                | Classificação                   |
| ------------------------------------------------------------ | ------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------- | ------------------------------- |
| `IF CUSTNOL < 1 OR CUSTNOI = '__________'`                   | Número do cliente não informado ou mantido com o conteúdo inicial de sublinhados.           | Rejeita os dados e solicita o número do cliente.                            | Negócio                         |
| `IF CUSTNOI NOT NUMERIC`                                     | Número do cliente não é numérico.                                                           | Rejeita a entrada.                                                          | Interface — formato             |
| `IF ACCTYPI = '________' OR ACCTYPL < 1`                     | Tipo de conta não informado.                                                                | Rejeita os dados e solicita um tipo de conta.                               | Negócio                         |
| `IF ACCTYPL > 0`                                             | Campo do tipo de conta possui comprimento positivo.                                         | Executa a avaliação do tipo de conta.                                       | Negócio — decisão intermediária |
| `EVALUATE ACCTYPI`                                           | Tipo informado corresponde a ISA, CURRENT, LOAN, SAVING ou MORTGAGE, nas grafias previstas. | Aceita o tipo de conta e, conforme a entrada, uniformiza sua representação. | Negócio                         |
| `EVALUATE ACCTYPI / WHEN OTHER`                              | Tipo informado não corresponde a nenhuma alternativa aceita.                                | Rejeita os dados e informa os tipos permitidos.                             | Negócio                         |
| `IF INTRTL = ZERO`                                           | Taxa de juros não informada.                                                                | Rejeita os dados e solicita a taxa de juros.                                | Negócio                         |
| `IF INTRTI(1:INTRTL) IS NOT NUMERIC`                         | Conteúdo da taxa exige verificações adicionais de formato.                                  | Executa as verificações de caracteres e casas decimais.                     | Interface — formato             |
| `IF WS-NUM-COUNT-TOTAL < INTRTL`                             | Taxa contém caracteres fora do conjunto verificado.                                         | Rejeita a entrada.                                                          | Interface — formato             |
| `IF WS-NUM-COUNT-POINT > 1`                                  | Taxa possui mais de um ponto decimal.                                                       | Rejeita a entrada.                                                          | Interface — formato             |
| `IF WS-NUM-COUNT-POINT = 1`                                  | Taxa contém um ponto decimal.                                                               | Executa verificações adicionais de casas decimais.                          | Interface — formato             |
| `IF WS-NUM-COUNT-TOTAL > 2`                                  | Contagem de caracteres após o ponto supera dois.                                            | Executa nova verificação do conteúdo decimal.                               | Interface — formato             |
| `IF WS-NUM-COUNT-TOTAL > 2` (aninhado)                       | A nova contagem supera dois.                                                                | Rejeita a taxa com mensagem sobre casas decimais.                           | Interface — formato             |
| `IF INTRTI-COMP-1 < 0`                                       | Taxa de juros negativa.                                                                     | Rejeita os dados e solicita taxa zero ou positiva.                          | Negócio                         |
| `IF INTRTI-COMP-1 > 9999.99`                                 | Taxa de juros superior a 9999,99.                                                           | Rejeita os dados.                                                           | Negócio                         |
| `IF WS-NUM-COUNT-TOTAL < OVERDRL`                            | Limite de cheque especial contém caracteres não numéricos.                                  | Rejeita a entrada.                                                          | Interface — formato             |
| `IF OVERDRL < 1 OR OVERDRI = '________' OR OVERDRI = SPACES` | Limite de cheque especial não informado.                                                    | Considera o limite igual a zero.                                            | Negócio                         |
| `IF OVERDRI NOT NUMERIC`                                     | Limite de cheque especial não é numérico.                                                   | Rejeita a entrada.                                                          | Interface — formato             |
| `IF CUSTNOL < 1 OR ACCTYPL < 1`                              | Número do cliente ou tipo de conta está ausente na verificação final.                       | Rejeita os dados e informa ausência de informação obrigatória.              | Negócio                         |

Observações de fidelidade:

- As alternativas de tipo de conta são agrupadas quando produzem a mesma consequência, sem criar uma regra para cada variação de maiúsculas, minúsculas ou sublinhados.
- A verificação das casas decimais da taxa de juros é classificada como formato, conforme a exclusão estabelecida.
- O limite superior efetivamente testado para a taxa de juros é `> 9999.99`; portanto, o valor exatamente igual a 9999,99 não é rejeitado por essa condição.
- A primeira verificação do limite de cheque especial examina caracteres antes da decisão que transforma a ausência de valor em zero. Por isso, o comportamento para determinadas entradas não numéricas ou com sublinhados pode depender das condições anteriores.
- A verificação final da obrigatoriedade do número do cliente e do tipo de conta é mantida como ocorrência distinta, apesar de repetir validações anteriores.

#### CRE-ACC-DATA / CAD010

| Estrutura                               | Condição                                                        | Consequência                                                     | Classificação                   |
| --------------------------------------- | --------------------------------------------------------------- | ---------------------------------------------------------------- | ------------------------------- |
| `IF WS-CICS-RESP NOT = DFHRESP(NORMAL)` | Falha técnica na chamada ao programa de criação.                | Aciona o tratamento técnico da falha.                            | Infraestrutura                  |
| `IF SUBPGM-SUCCESS = 'N'`               | Programa de criação informa insucesso.                          | Não confirma a criação da conta e interpreta o motivo retornado. | Negócio — decisão intermediária |
| `EVALUATE SUBPGM-FAIL-CODE / WHEN '1'`  | Cliente informado não existe.                                   | Informa que o número do cliente não existe.                      | Negócio                         |
| `WHEN '2'`                              | Os dados do cliente não podem ser acessados.                    | Informa impossibilidade de criar a conta.                        | Infraestrutura                  |
| `WHEN '3', '4', '5', '6', '7'`          | O programa retorna falhas técnicas de controle ou persistência. | Informa falha na criação da conta.                               | Infraestrutura                  |
| `WHEN '8'`                              | O programa informa excesso de contas.                           | Informa que a conta não foi criada por excesso de contas.        | Negócio                         |
| `WHEN '9'`                              | Falha ao contar as contas.                                      | Informa falha na criação.                                        | Infraestrutura                  |
| `WHEN 'A'`                              | O programa de criação informa tipo de conta não suportado.      | Informa que a conta não foi criada.                              | Negócio                         |
| `WHEN OTHER`                            | Insucesso sem código de falha especificamente tratado.          | Informa genericamente que a conta não foi criada.                | Negócio                         |
| `ELSE` do `IF SUBPGM-SUCCESS = 'N'`     | Indicador de sucesso diferente de `N`.                          | Informa criação bem-sucedida da conta.                           | Negócio                         |

O código utiliza a condição `SUBPGM-SUCCESS = 'N'` para identificar falha e considera qualquer outro valor como sucesso. Não existe uma comparação explícita com `Y`.

O código `'8'` é interpretado como excesso de contas, mas o programa analisado não estabelece o limite máximo permitido. Também não é possível determinar quais critérios internos fazem `CREACC` devolver o código `'A'`.

#### SEND-MAP / SM010

| Estrutura                                           | Condição ou finalidade                                | Classificação  |
| --------------------------------------------------- | ----------------------------------------------------- | -------------- |
| `IF SEND-ERASE`                                     | Seleciona apresentação com limpeza da tela.           | Interface      |
| `IF SEND-DATAONLY`                                  | Seleciona atualização dos dados apresentados.         | Interface      |
| `IF SEND-DATAONLY-ALARM`                            | Seleciona atualização com sinal de alerta.            | Interface      |
| Três testes `IF WS-CICS-RESP NOT = DFHRESP(NORMAL)` | Tratam falhas técnicas das operações de apresentação. | Infraestrutura |

#### SEND-TERMINATION-MSG / STM010

| Estrutura                               | Condição ou finalidade                                    | Classificação  |
| --------------------------------------- | --------------------------------------------------------- | -------------- |
| `IF WS-CICS-RESP NOT = DFHRESP(NORMAL)` | Trata falha técnica no envio da mensagem de encerramento. | Infraestrutura |

#### ABEND-THIS-TASK / ATT010 e POPULATE-TIME-DATE / PTD010

Não possuem estruturas `IF` ou `EVALUATE` que gerem regras de negócio.

## Regras de negócio

1\. Regra: A criação de uma conta bancária somente deve ser solicitada quando os dados fornecidos forem considerados válidos.

- Condição: Quando todas as validações forem concluídas sem invalidar os dados (`VALID-DATA`).
- Consequência: O sistema solicita a criação da conta.
- Parágrafo: `PM010`

2\. Regra: A criação de uma conta bancária não deve ser solicitada quando os dados fornecidos forem considerados inválidos.

- Condição: Quando alguma validação invalidar os dados (`VALID-DATA-SW` diferente de `Y`).
- Consequência: O sistema não solicita a criação da conta.
- Parágrafo: `PM010`

3\. Regra: O número do cliente é obrigatório para solicitar a criação de uma conta.

- Condição: Quando o número do cliente não for informado (`CUSTNOL < 1`) ou permanecer preenchido com dez sublinhados.
- Consequência: O sistema rejeita os dados e solicita o preenchimento do número do cliente.
- Parágrafo: `ED010`

4\. Regra: O tipo de conta é obrigatório para solicitar a criação de uma conta bancária.

- Condição: Quando o tipo de conta não for informado (`ACCTYPL < 1`) ou permanecer preenchido com oito sublinhados.
- Consequência: O sistema rejeita os dados e solicita um tipo de conta válido.
- Parágrafo: `ED010`

5\. Regra: Somente os tipos de conta ISA, CURRENT, LOAN, SAVING e MORTGAGE são aceitos na validação inicial.

- Condição: Quando o tipo de conta informado corresponder a uma dessas cinco categorias, em uma das representações previstas no programa.
- Consequência: O sistema aceita o tipo de conta e prossegue com as validações.
- Parágrafo: `ED010`

6\. Regra: Um tipo de conta diferente de ISA, CURRENT, LOAN, SAVING ou MORTGAGE deve ser rejeitado.

- Condição: Quando o tipo de conta informado não corresponder a nenhuma das alternativas previstas na validação.
- Consequência: O sistema rejeita os dados e informa os tipos de conta permitidos.
- Parágrafo: `ED010`

7\. Regra: A taxa de juros é obrigatória para a criação de uma conta bancária.

- Condição: Quando a taxa de juros não for informada (`INTRTL = ZERO`).
- Consequência: O sistema rejeita os dados e solicita o preenchimento da taxa de juros.
- Parágrafo: `ED010`

8\. Regra: A taxa de juros não pode ser negativa.

- Condição: Quando a taxa de juros informada for menor que zero (`INTRTI-COMP-1 < 0`).
- Consequência: O sistema rejeita os dados e solicita uma taxa de juros igual ou superior a zero.
- Parágrafo: `ED010`

9\. Regra: A taxa de juros não pode ultrapassar 9999,99%.

- Condição: Quando a taxa de juros informada for superior a 9999,99 (`INTRTI-COMP-1 > 9999.99`).
- Consequência: O sistema rejeita os dados e solicita uma taxa de juros dentro do limite permitido.
- Parágrafo: `ED010`

10\. Regra: O limite de cheque especial é considerado zero quando não for informado.

- Condição: Quando o campo de limite de cheque especial estiver sem preenchimento, contiver apenas espaços ou apresentar oito sublinhados (`OVERDRL < 1`, `OVERDRI = SPACES` ou `OVERDRI = '________'`), desde que o processamento alcance essa verificação.
- Consequência: O sistema considera o limite de cheque especial igual a zero.
- Parágrafo: `ED010`

11\. Regra: O número do cliente e o tipo de conta devem estar preenchidos na verificação final dos dados.

- Condição: Quando o número do cliente ou o tipo de conta estiver ausente (`CUSTNOL < 1 OR ACCTYPL < 1`).
- Consequência: O sistema rejeita os dados e informa a ausência de informações obrigatórias.
- Parágrafo: `ED010`

12\. Regra: Uma conta não pode ter sua criação confirmada quando o programa responsável pela criação retornar insucesso por inexistência do cliente.

- Condição: Quando a criação falhar (`SUBPGM-SUCCESS = 'N'`) e o motivo retornado for cliente inexistente (`SUBPGM-FAIL-CODE = '1'`).
- Consequência: O sistema informa que o número do cliente fornecido não existe.
- Parágrafo: `CAD010`

13\. Regra: A criação de uma conta deve ser recusada quando o programa responsável informar excesso de contas.

- Condição: Quando a criação falhar (`SUBPGM-SUCCESS = 'N'`) e o motivo retornado for excesso de contas (`SUBPGM-FAIL-CODE = '8'`).
- Consequência: O sistema informa que a conta não foi criada devido ao excesso de contas, sem especificar o limite máximo.
- Parágrafo: `CAD010`

14\. Regra: A criação de uma conta deve ser recusada quando o programa responsável informar que o tipo de conta não é suportado.

- Condição: Quando a criação falhar (`SUBPGM-SUCCESS = 'N'`) e o motivo retornado for tipo de conta não suportado (`SUBPGM-FAIL-CODE = 'A'`).
- Consequência: O sistema informa que a conta não foi criada porque o tipo de conta não é suportado.
- Parágrafo: `CAD010`

15\. Regra: Quando a criação de uma conta não for concluída e o motivo retornado não possuir tratamento específico, o cliente deve receber uma informação genérica de insucesso.

- Condição: Quando `SUBPGM-SUCCESS = 'N'` e `SUBPGM-FAIL-CODE` for diferente dos códigos `'1'` a `'9'` e `'A'`.
- Consequência: O sistema informa que a conta não foi criada, sem apresentar um motivo específico.
- Parágrafo: `CAD010`

16\. Regra: Uma conta deve ser apresentada como criada quando o programa responsável não indicar insucesso.

- Condição: Quando o indicador de criação (`SUBPGM-SUCCESS`) for diferente de `'N'`.
- Consequência: O sistema informa que a conta foi criada com sucesso e apresenta os dados retornados da conta.
- Parágrafo: `CAD010`