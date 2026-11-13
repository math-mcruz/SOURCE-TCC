## Análise

### 1. Parágrafos e fluxo principal do programa

O programa BNK1CRA realiza o processamento de solicitações de crédito ou débito em contas bancárias. Recebe o número da conta, o sinal da operação e o valor, valida os dados e encaminha a solicitação ao programa DBCRFUN, responsável pelo processamento efetivo da operação.

| Parágrafo | Responsabilidade                                                                       |
| --------- | -------------------------------------------------------------------------------------- |
| A010      | Controla a entrada na transação e direciona o processamento.                           |
| PM010     | Recebe os dados, executa as validações e, se válidos, solicita a atualização da conta. |
| RM010     | Recebe os dados informados na tela.                                                    |
| ED010     | Valida o número da conta e o sinal informado para a operação.                          |
| VA010     | Valida o valor monetário informado.                                                    |
| UCD010    | Encaminha a operação ao DBCRFUN e interpreta o resultado retornado.                    |
| SM010     | Controla o envio das informações para a tela.                                          |
| STM010    | Apresenta a mensagem de encerramento da sessão.                                        |
| ATT010    | Executa o encerramento por falha técnica.                                              |
| PTD010    | Obtém a data e a hora utilizadas nos registros técnicos.                               |

Fluxo principal:

A010 → PM010 → RM010 → ED010 → VA010 → UCD010 → SM010.

O processamento em UCD010 somente ocorre quando os dados são considerados válidos. O programa DBCRFUN retorna informações sobre o resultado da operação, que são interpretadas por UCD010.

### 2. Estruturas de decisão e classificação

| Parágrafo | Estrutura de decisão                                        | Classificação  | Resultado                                                                                   |
| --------- | ----------------------------------------------------------- | -------------- | ------------------------------------------------------------------------------------------- |
| A010      | EVALUATE TRUE, conforme estado da sessão ou tecla utilizada | Interface      | Inicializa, encerra, retorna ou processa a tela.                                            |
| A010      | IF EIBCALEN NOT = ZERO                                      | Infraestrutura | Preserva dados de comunicação entre transações.                                             |
| A010      | IF WS-CICS-RESP NOT = NORMAL                                | Infraestrutura | Trata falha técnica no retorno CICS.                                                        |
| PM010     | IF VALID-DATA                                               | Negócio        | Somente solicita a atualização quando os dados estão válidos.                               |
| RM010     | IF WS-CICS-RESP NOT = NORMAL                                | Infraestrutura | Trata falha no recebimento da tela.                                                         |
| ED010     | IF ACCNOI NOT NUMERIC                                       | Interface      | Rejeita número de conta em formato inválido.                                                |
| ED010     | IF ACCNOI = ZERO                                            | Negócio        | Rejeita conta de número zero.                                                               |
| ED010     | IF SIGNI NOT = '+' AND SIGNI NOT = '-' AND SIGNL = 1        | Interface      | Rejeita sinal informado em formato inválido.                                                |
| UCD010    | IF SIGNI = '-'                                              | Negócio        | Transforma o valor em negativo para representar débito.                                     |
| UCD010    | IF WS-CICS-RESP NOT = NORMAL                                | Infraestrutura | Trata falha técnica na chamada ao DBCRFUN.                                                  |
| UCD010    | IF SUBPGM-SUCCESS = 'N'                                     | Negócio        | Identifica operação não concluída e avalia o motivo.                                        |
| UCD010    | EVALUATE SUBPGM-FAIL-CODE                                   | Negócio        | Diferencia conta não encontrada, erro inesperado e insuficiência de fundos.                 |
| UCD010    | ELSE de SUBPGM-SUCCESS = 'N'                                | Negócio        | Informa que o valor foi aplicado à conta.                                                   |
| SM010     | IF SEND-ERASE                                               | Interface      | Envia a tela com limpeza anterior.                                                          |
| SM010     | IF SEND-DATAONLY                                            | Interface      | Envia somente os dados da tela.                                                             |
| SM010     | IF SEND-DATAONLY-ALARM                                      | Interface      | Envia dados com sinal sonoro.                                                               |
| SM010     | Três testes IF WS-CICS-RESP NOT = NORMAL                    | Infraestrutura | Tratam falhas técnicas de envio.                                                            |
| STM010    | IF WS-CICS-RESP NOT = NORMAL                                | Infraestrutura | Trata falha na mensagem de encerramento.                                                    |
| VA010     | IF AMTL = ZERO                                              | Negócio        | Rejeita valor não preenchido.                                                               |
| VA010     | IF AMTI(1:AMTL) IS NUMERIC                                  | Interface      | Aceita diretamente valor em formato numérico, sem executar as validações posteriores.       |
| VA010     | IF WS-NUM-COUNT-TOTAL = AMTL                                | Negócio        | Rejeita valor preenchido somente com espaços.                                               |
| VA010     | IF WS-NUM-COUNT-TOTAL = ZERO                                | Interface      | Escolhe a forma de tratamento dos espaços iniciais.                                         |
| VA010     | IF WS-NUM-COUNT-SPACE > 0                                   | Interface      | Rejeita espaços internos no valor.                                                          |
| VA010     | IF WS-NUM-COUNT-TOTAL < WS-AMOUNT-UNSTR-L                   | Interface      | Rejeita caracteres não aceitos no formato numérico.                                         |
| VA010     | IF WS-NUM-COUNT-POINT > 1                                   | Interface      | Rejeita múltiplos separadores decimais.                                                     |
| VA010     | IF WS-NUM-COUNT-POINT = 1                                   | Interface      | Identifica a existência de separador decimal.                                               |
| VA010     | IF WS-NUM-COUNT-TOTAL > 2                                   | Interface      | Aciona a verificação complementar das casas decimais.                                       |
| VA010     | IF WS-NUM-COUNT-TOTAL > 2, interno                          | Negócio        | Rejeita valores que excedam a precisão decimal permitida, conforme a contagem implementada. |
| VA010     | IF WS-AMOUNT-AS-FLOAT = ZERO                                | Negócio        | Rejeita valor monetário zero.                                                               |

### 3. Condições e consequências das decisões de negócio

PM010 — Autorização do processamento: se os dados forem considerados válidos, o programa solicita a atualização da conta. Caso contrário, não executa essa solicitação.

ED010 — Número da conta: quando o número da conta é zero, o programa rejeita a solicitação e informa que deve ser fornecido um número diferente de zero.

UCD010 — Natureza da operação: quando o sinal informado é negativo, o valor é convertido em negativo antes do envio ao processamento bancário. O código não apresenta decisão equivalente para converter explicitamente o sinal positivo.

UCD010 — Resultado da operação: se DBCRFUN indicar insucesso, o motivo retornado determina a mensagem:

- Código `1`: conta não encontrada para o código bancário retornado.
- Código `2`: valor não aplicado por erro inesperado.
- Código `3`: fundos disponíveis insuficientes.
- Outros códigos: valor não aplicado por erro inesperado.

Quando `SUBPGM-SUCCESS` é diferente de `N`, o programa informa sucesso e disponibiliza os saldos atual e disponível retornados. O programa não exige explicitamente que esse indicador seja `Y`.

VA010 — Obrigatoriedade do valor: quando o comprimento informado é zero ou o conteúdo contém somente espaços, a operação é rejeitada por ausência de valor.

VA010 — Precisão decimal: há uma decisão que rejeita valores quando a contagem adicional de dígitos ultrapassa dois, dentro do caminho de validação de casas decimais. A implementação utiliza uma contagem específica, de modo que não é possível afirmar que todos os valores com mais de duas casas decimais sejam rejeitados.

VA010 — Valor zero: quando o valor convertido é zero no caminho de validação detalhada, a solicitação é rejeitada. Entretanto, quando a entrada é inteiramente numérica, existe um caminho anterior que a aceita diretamente, sem executar essa verificação. Portanto, a rejeição de zero não é universal.

### 4. Limites da análise

O programa BNK1CRA não apresenta as regras internas do DBCRFUN. Consequentemente, não é possível determinar como esse programa identifica contas, calcula saldos, verifica fundos ou efetiva os lançamentos.

As regras abaixo descrevem exclusivamente as decisões identificadas em BNK1CRA, incluindo as particularidades de implementação que afetam o comportamento observável.

## Regras de negócio

1\. Regra: Uma operação bancária com dados considerados válidos é encaminhada para processamento.

- Condição: Quando as validações da conta e do valor terminam com o indicador de dados válidos (`VALID-DATA`).
- Consequência: A operação é encaminhada para atualização da conta.
- Parágrafo: PM010

2\. Regra: Uma operação bancária com dados inválidos não é encaminhada para atualização.

- Condição: Quando alguma validação altera o indicador de dados válidos para `N`.
- Consequência: A solicitação de atualização da conta não é executada.
- Parágrafo: PM010

3\. Regra: O número da conta bancária deve ser diferente de zero.

- Condição: Quando o número da conta informado é zero (`ACCNOI = ZERO`).
- Consequência: A operação é rejeitada e é solicitada a informação de um número de conta diferente de zero.
- Parágrafo: ED010

4\. Regra: Uma operação indicada como débito é encaminhada com valor negativo.

- Condição: Quando o sinal informado é menos (`SIGNI = '-'`).
- Consequência: O valor da operação é convertido em negativo antes de ser encaminhado ao processamento bancário.
- Parágrafo: UCD010

5\. Regra: Uma operação não pode ser aplicada quando a conta não é encontrada para o código bancário informado no resultado.

- Condição: Quando o processamento retorna insucesso (`SUBPGM-SUCCESS = 'N'`) com código de falha `1`.
- Consequência: O banco informa que a conta não foi encontrada para o código bancário retornado e que o valor não foi aplicado.
- Parágrafo: UCD010

6\. Regra: Uma operação não concluída por erro inesperado é informada como não aplicada.

- Condição: Quando o processamento retorna insucesso (`SUBPGM-SUCCESS = 'N'`) com código de falha `2`.
- Consequência: O banco informa que o valor não pôde ser aplicado devido a um erro inesperado.
- Parágrafo: UCD010

7\. Regra: Uma operação é recusada quando não existem fundos disponíveis suficientes para sua execução.

- Condição: Quando o processamento retorna insucesso (`SUBPGM-SUCCESS = 'N'`) com código de falha `3`.
- Consequência: O banco informa a insuficiência de fundos disponíveis para processar a solicitação.
- Parágrafo: UCD010

8\. Regra: Uma operação não concluída com motivo não reconhecido é informada como não aplicada.

- Condição: Quando o processamento retorna insucesso (`SUBPGM-SUCCESS = 'N'`) com código de falha diferente de `1`, `2` ou `3`.
- Consequência: O banco informa que o valor não pôde ser aplicado devido a erro inesperado, apresentando também o código retornado.
- Parágrafo: UCD010

9\. Regra: Uma operação cujo processamento não indica insucesso é apresentada como concluída.

- Condição: Quando o indicador retornado pelo processamento é diferente de `N` (`SUBPGM-SUCCESS NOT = 'N'`).
- Consequência: O banco informa que o valor foi aplicado com sucesso à conta e apresenta os saldos atual e disponível retornados pelo processamento.
- Parágrafo: UCD010

10\. Regra: O valor monetário da operação é obrigatório.

- Condição: Quando o campo de valor não possui conteúdo (`AMTL = ZERO`).
- Consequência: A operação é rejeitada e é solicitada a informação do valor.
- Parágrafo: VA010

11\. Regra: O valor monetário da operação não pode ser preenchido somente com espaços.

- Condição: Quando todos os caracteres do campo de valor são espaços (`WS-NUM-COUNT-TOTAL = AMTL`).
- Consequência: A operação é rejeitada e é solicitada a informação de um valor.
- Parágrafo: VA010

12\. Regra: O valor monetário está sujeito à restrição de duas casas decimais no caminho de validação detalhada.

- Condição: Quando o valor contém um separador decimal, a contagem inicial de caracteres após o separador excede dois e a contagem complementar de dígitos também excede dois (`WS-NUM-COUNT-TOTAL > 2`).
- Consequência: A operação é rejeitada com a informação de que somente até duas casas decimais são aceitas. A contagem implementada não permite garantir rejeição uniforme de todos os valores com mais de duas casas decimais.
- Parágrafo: VA010

13\. Regra: O valor monetário da operação deve ser diferente de zero no caminho de validação detalhada.

- Condição: Quando o valor convertido é zero (`WS-AMOUNT-AS-FLOAT = ZERO`) e o processamento alcança essa validação.
- Consequência: A operação é rejeitada e é solicitado um valor diferente de zero. Essa restrição não é aplicada ao caminho anterior que aceita diretamente uma entrada inteiramente numérica.
- Parágrafo: VA010