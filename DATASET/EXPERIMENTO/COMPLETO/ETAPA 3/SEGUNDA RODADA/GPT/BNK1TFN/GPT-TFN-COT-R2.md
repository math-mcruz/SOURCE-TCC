## **Análise**

### **1. Parágrafos e fluxo principal do programa**

O programa **BNK1TFN** é responsável por receber solicitações de transferência bancária entre duas contas, validar os dados informados e encaminhar a operação ao programa **XFRFUN**, que retorna o resultado da transferência.

O fluxo principal é:

1. **A010 (PREMIERE):** identifica a situação de entrada da transação e encaminha o processamento.
2. **PM010 (PROCESS-MAP):** recebe os dados informados, executa as validações e, quando válidos, solicita o processamento da transferência.
3. **RM010 (RECEIVE-MAP):** recebe os dados da interface.
4. **ED010 (EDIT-DATA):** verifica os números das contas de origem e destino e solicita a validação do valor.
5. **VA010 (VALIDATE-AMOUNT):** verifica o preenchimento, o valor e a precisão decimal da transferência.
6. **GCD010 (GET-ACC-DATA):** solicita a transferência ao programa XFRFUN e interpreta o resultado retornado.
7. **SM010 (SEND-MAP):** apresenta as informações e mensagens na interface.
8. **STM010 (SEND-TERMINATION-MSG):** apresenta a mensagem de encerramento.
9. **ATT010 (ABEND-THIS-TASK):** trata encerramentos técnicos anormais.
10. **PTD010 (POPULATE-TIME-DATE):** obtém data e hora para registros técnicos.

O programa não implementa diretamente a movimentação de saldos. Essa responsabilidade é delegada ao programa XFRFUN, cujo código não foi fornecido. Assim, somente as decisões implementadas em BNK1TFN são consideradas.

### **2. Estruturas de decisão e classificação**

| Parágrafo | Estrutura de decisão                                        | Classificação                                                  |
| --------- | ----------------------------------------------------------- | -------------------------------------------------------------- |
| A010      | `EVALUATE TRUE`, com condições de início, teclas e comandos | Interface                                                      |
| A010      | `IF WS-CICS-RESP NOT = NORMAL`                              | Infraestrutura                                                 |
| PM010     | `IF VALID-DATA`                                             | Negócio                                                        |
| RM010     | `IF WS-CICS-RESP NOT = NORMAL`                              | Infraestrutura                                                 |
| ED010     | `IF FACCNOI NOT NUMERIC`                                    | Interface — formato                                            |
| ED010     | `IF TACCNOI NOT NUMERIC`                                    | Interface — formato                                            |
| ED010     | `IF FACCNOI = TACCNOI`                                      | Negócio                                                        |
| ED010     | `IF FACCNOI = '00000000' OR TACCNOI = '00000000'`           | Negócio                                                        |
| GCD010    | `IF WS-CICS-RESP NOT = NORMAL`                              | Infraestrutura                                                 |
| GCD010    | `IF SUBPGM-SUCCESS = 'N'`                                   | Negócio                                                        |
| GCD010    | `EVALUATE SUBPGM-FAIL-CODE`                                 | Negócio                                                        |
| GCD010    | `IF SUBPGM-SUCCESS NOT = 'Y'`                               | Negócio                                                        |
| SM010     | `IF SEND-ERASE`                                             | Interface                                                      |
| SM010     | `IF SEND-DATAONLY`                                          | Interface                                                      |
| SM010     | `IF SEND-DATAONLY-ALARM`                                    | Interface                                                      |
| SM010     | Três testes de resposta CICS                                | Infraestrutura                                                 |
| STM010    | `IF WS-CICS-RESP NOT = NORMAL`                              | Infraestrutura                                                 |
| VA010     | `IF AMTL = ZERO`                                            | Negócio — obrigatoriedade                                      |
| VA010     | `IF AMTI(1:AMTL) IS NUMERIC`                                | Interface — formato                                            |
| VA010     | `IF WS-AMOUNT-AS-FLOAT <= 0`                                | Negócio                                                        |
| VA010     | `IF WS-NUM-COUNT-TOTAL = AMTL`                              | Negócio — obrigatoriedade                                      |
| VA010     | `IF WS-NUM-COUNT-TOTAL = ZERO`                              | Interface — tratamento de espaços                              |
| VA010     | `IF WS-NUM-COUNT-MINUS > 0`                                 | Negócio — restrição a valores negativos                        |
| VA010     | `IF WS-NUM-COUNT-SPACE > 0`                                 | Interface — formato                                            |
| VA010     | `IF WS-NUM-COUNT-TOTAL < WS-AMOUNT-UNSTR-L`                 | Interface — formato                                            |
| VA010     | `IF WS-NUM-COUNT-POINT > 1`                                 | Interface — formato                                            |
| VA010     | `IF WS-NUM-COUNT-POINT = 1`                                 | Interface — formato e encaminhamento à verificação de precisão |
| VA010     | `IF WS-NUM-COUNT-TOTAL > 2` (primeira ocorrência)           | Negócio — encaminhamento à verificação de precisão             |
| VA010     | `IF WS-NUM-COUNT-TOTAL > 2` (segunda ocorrência)            | Negócio — limite de precisão                                   |
| VA010     | `IF WS-AMOUNT-AS-FLOAT = ZERO`                              | Negócio                                                        |

As decisões de infraestrutura e interface não serão incluídas como regras de negócio. A verificação de campos numéricos também não será interpretada como obrigatoriedade, pois o código testa formato, não ausência do dado.

### **3. Condições e consequências das decisões de negócio**

**PM010 — Validação geral**

- Se os dados forem considerados válidos, o programa solicita o processamento da transferência.
- Se os dados forem considerados inválidos, o programa não solicita a transferência.

**ED010 — Contas bancárias**

- Se as contas de origem e destino forem iguais, a solicitação é rejeitada.
- Se uma das contas tiver o número `00000000`, a solicitação é rejeitada.
- Se as contas ultrapassarem essas verificações, o programa prossegue para a validação do valor.

**VA010 — Valor da transferência**

- Se o comprimento informado do valor for zero, o campo é considerado inválido e o processamento não prossegue.
- Se o conteúdo numérico convertido for menor ou igual a zero, o valor é rejeitado.
- Se o campo, depois da contagem dos espaços iniciais, contiver somente espaços, o valor é rejeitado.
- Se houver sinal negativo no conteúdo analisado, o valor é rejeitado.
- Se a quantidade de casas decimais ultrapassar duas na verificação específica implementada, o valor é rejeitado.
- Se o valor convertido for igual a zero na etapa final, o valor é rejeitado.

A validação de casas decimais apresenta uma particularidade: a rejeição depende de duas verificações aninhadas. Portanto, não se deve afirmar que o programa rejeita indistintamente todos os valores com mais de duas posições após o ponto decimal; a regra deve refletir o caminho efetivamente implementado.

**GCD010 — Resultado da transferência**

Quando o programa XFRFUN retorna `SUBPGM-SUCCESS = 'N'`, o código de falha determina o tratamento:

- Código `1`: informa que a conta de origem não foi encontrada e que a transferência não foi aplicada.
- Código `2`: informa que a conta de destino não foi encontrada e que a transferência não foi aplicada.
- Código `3`: inicialmente prepara uma mensagem de erro inesperado, mas essa mensagem é substituída pela informação de que não foi possível determinar o sucesso da transferência.
- Código `4`: informa que o valor deve ser maior que zero.
- Demais códigos: informa que a transferência não pôde ser aplicada devido a um erro.

Em seguida, há uma nova decisão sobre o indicador de sucesso:

- Se `SUBPGM-SUCCESS` for diferente de `Y` e o fluxo chegar a essa decisão, o programa informa que a transferência não pôde ser aplicada porque não foi possível determinar seu sucesso.
- Se `SUBPGM-SUCCESS` for igual a `Y`, o programa informa que a transferência foi realizada com sucesso e apresenta os saldos retornados.

O código não contém uma decisão específica que verifique saldo suficiente, limite de transferência ou situação cadastral das contas. Essas regras não podem ser atribuídas ao programa BNK1TFN.

## **Regras de negócio**

1\. Regra: Uma transferência não pode ser realizada entre duas contas bancárias com o mesmo número.\
Condição: Quando o número da conta de origem é igual ao número da conta de destino (`FACCNOI = TACCNOI`).\
Consequência: A solicitação é rejeitada e o cliente é informado de que as contas devem ser diferentes.\
Parágrafo: ED010

2\. Regra: O número de conta `00000000` não é aceito em uma transferência.\
Condição: Quando a conta de origem ou a conta de destino possui o número `00000000`.\
Consequência: A solicitação é rejeitada e o cliente é informado de que esse número de conta é inválido.\
Parágrafo: ED010

3\. Regra: O valor da transferência deve ser informado.\
Condição: Quando o campo do valor da transferência apresenta comprimento zero (`AMTL = ZERO`).\
Consequência: A solicitação é considerada inválida e a transferência não é processada.\
Parágrafo: VA010

4\. Regra: O valor da transferência deve ser maior que zero.\
Condição: Quando o valor informado é reconhecido diretamente como numérico e sua conversão resulta em valor menor ou igual a zero (`WS-AMOUNT-AS-FLOAT <= 0`).\
Consequência: A solicitação é rejeitada e o cliente é orientado a informar um valor positivo.\
Parágrafo: VA010

5\. Regra: O valor da transferência não pode conter somente espaços.\
Condição: Quando a quantidade de espaços iniciais corresponde ao comprimento total do campo (`WS-NUM-COUNT-TOTAL = AMTL`).\
Consequência: A solicitação é considerada inválida e a transferência não é processada.\
Parágrafo: VA010

6\. Regra: Não são aceitos valores de transferência que contenham sinal negativo.\
Condição: Quando o conteúdo analisado do valor apresenta pelo menos um sinal de menos (`WS-NUM-COUNT-MINUS > 0`).\
Consequência: A solicitação é rejeitada e o cliente é orientado a informar um valor positivo.\
Parágrafo: VA010

7\. Regra: O valor da transferência está sujeito ao limite de duas casas decimais, conforme a verificação implementada.\
Condição: Quando existe exatamente um ponto decimal, a primeira contagem identifica mais de duas posições após o ponto e a segunda contagem específica também resulta em mais de duas (`WS-NUM-COUNT-TOTAL > 2`).\
Consequência: A solicitação é rejeitada e o cliente é informado de que são aceitas até duas casas decimais.\
Parágrafo: VA010

8\. Regra: Uma transferência não pode ter valor igual a zero.\
Condição: Quando o valor convertido na etapa final da validação é igual a zero (`WS-AMOUNT-AS-FLOAT = ZERO`).\
Consequência: A solicitação é rejeitada e o cliente é orientado a informar um valor diferente de zero.\
Parágrafo: VA010

9\. Regra: Somente solicitações com dados considerados válidos são encaminhadas para processamento da transferência.\
Condição: Quando todas as validações executadas terminam com o indicador de dados válidos (`VALID-DATA`).\
Consequência: O programa solicita o processamento da transferência ao serviço responsável (XFRFUN).\
Parágrafo: PM010

10\. Regra: Uma solicitação com dados inválidos não é encaminhada para processamento da transferência.\
Condição: Quando o indicador de validade dos dados não está na condição válida (`VALID-DATA` falso).\
Consequência: O programa não solicita a transferência e apresenta o resultado da validação ao cliente.\
Parágrafo: PM010

11\. Regra: Uma transferência não é aplicada quando a conta de origem não é encontrada.\
Condição: Quando o processamento retorna insucesso (`SUBPGM-SUCCESS = 'N'`) e código de falha `1`.\
Consequência: O cliente é informado de que a conta de origem não foi encontrada e de que a transferência não foi aplicada.\
Parágrafo: GCD010

12\. Regra: Uma transferência não é aplicada quando a conta de destino não é encontrada.\
Condição: Quando o processamento retorna insucesso (`SUBPGM-SUCCESS = 'N'`) e código de falha `2`.\
Consequência: O cliente é informado de que a conta de destino não foi encontrada e de que a transferência não foi aplicada.\
Parágrafo: GCD010

13\. Regra: Uma transferência com erro inesperado retornado pelo serviço é apresentada ao cliente como uma operação cujo sucesso não pôde ser determinado.\
Condição: Quando o processamento retorna insucesso (`SUBPGM-SUCCESS = 'N'`) e código de falha `3`.\
Consequência: O cliente recebe a mensagem de que a transferência não pôde ser aplicada porque não foi possível determinar seu sucesso; a mensagem inicial de erro inesperado é substituída.\
Parágrafo: GCD010

14\. Regra: O serviço de transferência não aceita operações com valor menor ou igual a zero, conforme o motivo de falha retornado.\
Condição: Quando o processamento retorna insucesso (`SUBPGM-SUCCESS = 'N'`) e código de falha `4`.\
Consequência: O cliente é orientado a informar um valor maior que zero.\
Parágrafo: GCD010

15\. Regra: Uma transferência com código de falha não previsto recebe uma mensagem genérica de não realização.\
Condição: Quando o processamento retorna insucesso (`SUBPGM-SUCCESS = 'N'`) e o código de falha é diferente de `1`, `2`, `3` e `4`.\
Consequência: O cliente é informado de que a transferência não pôde ser aplicada devido a um erro.\
Parágrafo: GCD010

16\. Regra: Uma transferência cujo resultado não é confirmado como sucesso não recebe confirmação de realização.\
Condição: Quando o indicador de sucesso é diferente de `Y` e o processamento alcança a verificação final, incluindo o caso de indicador `N` com código de falha `3`.\
Consequência: O cliente é informado de que a transferência não pôde ser aplicada porque não foi possível determinar seu sucesso.\
Parágrafo: GCD010

17\. Regra: Uma transferência confirmada como bem-sucedida é apresentada ao cliente como realizada.\
Condição: Quando o serviço retorna o indicador de sucesso igual a `Y` (`SUBPGM-SUCCESS = 'Y'`).\
Consequência: O cliente recebe a confirmação de que a transferência foi realizada e os saldos atual e disponível das contas de origem e destino são apresentados.\
Parágrafo: GCD010