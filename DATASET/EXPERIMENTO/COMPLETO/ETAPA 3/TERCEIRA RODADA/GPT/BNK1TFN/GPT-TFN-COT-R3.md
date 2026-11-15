## **Análise**

### **1. Identificação e fluxo principal do programa**

O programa **BNK1TFN** é responsável pela solicitação de transferências de valores entre contas bancárias.

A efetivação da transferência é delegada ao programa **XFRFUN**, chamado pelo BNK1TFN. O programa analisado valida os dados informados, solicita a transferência e interpreta o resultado devolvido pelo programa chamado.

**Parágrafos e seções principais:**

| Seção / Parágrafo             | Responsabilidade                                                                      |
| ----------------------------- | ------------------------------------------------------------------------------------- |
| PREMIERE / A010               | Controla o início da transação e as interações com a tela.                            |
| PROCESS-MAP / PM010           | Recebe os dados, solicita sua validação e, quando válidos, encaminha a transferência. |
| RECEIVE-MAP / RM010           | Recebe os dados informados na tela.                                                   |
| EDIT-DATA / ED010             | Valida as contas de origem e destino e solicita a validação do valor.                 |
| VALIDATE-AMOUNT / VA010       | Valida a obrigatoriedade e as restrições do valor da transferência.                   |
| GET-ACC-DATA / GCD010         | Solicita a transferência ao XFRFUN e interpreta o resultado.                          |
| SEND-MAP / SM010              | Envia as informações para a tela.                                                     |
| SEND-TERMINATION-MSG / STM010 | Apresenta a mensagem de encerramento da sessão.                                       |
| ABEND-THIS-TASK / ATT010      | Executa o encerramento por falha técnica.                                             |
| POPULATE-TIME-DATE / PTD010   | Obtém data e hora para tratamento técnico de falhas.                                  |

**Fluxo principal de negócio:**

1. O cliente informa a conta de origem, a conta de destino e o valor da transferência.
2. O programa valida as contas informadas.
3. O programa valida o valor solicitado.
4. Se os dados forem considerados válidos, encaminha a solicitação ao XFRFUN.
5. O programa interpreta o resultado devolvido, podendo informar transferência realizada, conta não encontrada, valor inválido ou transferência não aplicada.
6. Quando a transferência é confirmada, são apresentados os saldos atual e disponível das contas de origem e destino.

O código não permite determinar as regras internas de efetivação da transferência executadas pelo XFRFUN.

### **2. Estruturas de decisão e classificação**

#### **2.1. PREMIERE / A010**

**Estrutura:** `EVALUATE TRUE`

**Classificação:** Interface.

Os caminhos avaliam o início da sessão, as teclas utilizadas e o encerramento da interação. Não representam regras de negócio sobre a transferência.

**Estrutura:** `IF WS-CICS-RESP NOT = DFHRESP(NORMAL)`

**Classificação:** Infraestrutura.

Trata falhas técnicas no retorno da transação CICS.

#### **2.2. PROCESS-MAP / PM010**

**Estrutura:** `IF VALID-DATA`

**Classificação:** Negócio.

- Condição: os dados informados foram considerados válidos.
- Consequência: o programa solicita o processamento da transferência por meio de GET-ACC-DATA.
- Caminho alternativo: quando os dados são inválidos, o processamento da transferência não é solicitado.

#### **2.3. RECEIVE-MAP / RM010**

**Estrutura:** `IF WS-CICS-RESP NOT = DFHRESP(NORMAL)`

**Classificação:** Infraestrutura.

Trata falhas técnicas no recebimento da tela.

#### **2.4. EDIT-DATA / ED010**

| Estrutura                                         | Classificação       | Condição e consequência                                                   |
| ------------------------------------------------- | ------------------- | ------------------------------------------------------------------------- |
| `IF FACCNOI NOT NUMERIC`                          | Interface — formato | Rejeita conta de origem que não atende à verificação numérica.            |
| `IF TACCNOI NOT NUMERIC`                          | Interface — formato | Rejeita conta de destino que não atende à verificação numérica.           |
| `IF FACCNOI = TACCNOI`                            | Negócio             | Se as contas de origem e destino são iguais, a transferência é rejeitada. |
| `IF FACCNOI = '00000000' OR TACCNOI = '00000000'` | Negócio             | Se alguma das contas possui número 00000000, a transferência é rejeitada. |

Os dois primeiros testes são excluídos da lista final por verificarem formato numérico, mesmo que as mensagens solicitem o preenchimento das contas.

Os dois últimos testes estabelecem restrições sobre os valores das contas e, portanto, são regras de negócio.

#### **2.5. VALIDATE-AMOUNT / VA010**

| Estrutura                                   | Classificação                      | Condição e consequência                                                                      |
| ------------------------------------------- | ---------------------------------- | -------------------------------------------------------------------------------------------- |
| `IF AMTL = ZERO`                            | Negócio                            | Rejeita a solicitação quando o campo de valor não apresenta conteúdo informado.              |
| `IF AMTI(1:AMTL) IS NUMERIC`                | Interface — formato                | Escolhe o tratamento para valores diretamente reconhecidos como numéricos.                   |
| `IF WS-AMOUNT-AS-FLOAT <= 0`                | Negócio                            | Rejeita valor menor ou igual a zero no caminho de entrada numérica direta.                   |
| `IF WS-NUM-COUNT-TOTAL = AMTL`              | Negócio                            | Rejeita o valor quando o conteúdo informado é composto exclusivamente por espaços.           |
| `IF WS-NUM-COUNT-TOTAL = ZERO`              | Interface — formato                | Escolhe a forma de tratamento dos espaços iniciais.                                          |
| `IF WS-NUM-COUNT-MINUS > 0`                 | Negócio                            | Rejeita o valor quando é encontrado o sinal negativo.                                        |
| `IF WS-NUM-COUNT-SPACE > 0`                 | Interface — formato                | Rejeita espaços internos no valor.                                                           |
| `IF WS-NUM-COUNT-TOTAL < WS-AMOUNT-UNSTR-L` | Interface — formato                | Rejeita conteúdo que não corresponde aos caracteres numéricos e decimais aceitos.            |
| `IF WS-NUM-COUNT-POINT > 1`                 | Interface — formato                | Rejeita valores com mais de um ponto decimal.                                                |
| `IF WS-NUM-COUNT-POINT = 1`                 | Interface — formato                | Verifica a presença de ponto decimal para prosseguir com a análise das casas decimais.       |
| `IF WS-NUM-COUNT-TOTAL > 2`                 | Interface — estrutura de validação | Encaminha valores com mais de duas posições após o ponto para uma verificação adicional.     |
| `IF WS-NUM-COUNT-TOTAL > 2` (interno)       | Negócio                            | Rejeita valores com mais de duas casas decimais conforme a contagem realizada pelo programa. |
| `IF WS-AMOUNT-AS-FLOAT = ZERO`              | Negócio                            | Rejeita valor igual a zero após a conversão do conteúdo informado.                           |

**Observações sobre os caminhos:**

O teste `AMTL = ZERO` e o teste de conteúdo inteiramente preenchido por espaços são duas ocorrências distintas de verificação de ausência de valor. Por isso, serão listados separadamente.

A restrição de valor positivo aparece em caminhos diferentes: rejeição de valor numérico menor ou igual a zero, rejeição pela presença do sinal negativo e rejeição de valor convertido igual a zero.

A restrição de duas casas decimais depende de decisões aninhadas. A decisão externa encaminha para uma nova verificação; a consequência final de rejeição ocorre quando a contagem interna supera duas casas. Por isso, esse caminho produz uma única regra.

#### **2.6. GET-ACC-DATA / GCD010**

**Estrutura:** `IF WS-CICS-RESP NOT = DFHRESP(NORMAL)`

**Classificação:** Infraestrutura.

Trata falha técnica na chamada ao XFRFUN. Não representa rejeição de negócio da transferência.

**Estrutura:** `IF SUBPGM-SUCCESS = 'N'`

**Classificação:** Negócio.

Quando o programa XFRFUN devolve indicador de insucesso igual a `N`, o BNK1TFN interpreta o código de falha para definir o resultado informado.

**Estrutura aninhada:** `EVALUATE SUBPGM-FAIL-CODE`

**Classificação:** Negócio.

| Código  | Condição                                 | Consequência final                                                                                                                |
| ------- | ---------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| `1`     | Conta de origem não encontrada           | Informa que a conta de origem não foi encontrada e que a transferência não foi aplicada.                                          |
| `2`     | Conta de destino não encontrada          | Informa que a conta de destino não foi encontrada e que a transferência não foi aplicada.                                         |
| `3`     | Erro inesperado                          | Inicialmente prepara mensagem de erro inesperado, mas ela é substituída pela mensagem de impossibilidade de determinar o sucesso. |
| `4`     | Valor que deve ser maior que zero        | Informa que é necessário fornecer valor maior que zero e encerra o processamento.                                                 |
| `OTHER` | Código de falha diferente dos anteriores | Informa que a transferência não pôde ser aplicada devido a um erro.                                                               |

**Estrutura seguinte:** `IF SUBPGM-SUCCESS NOT = 'Y' ... ELSE`

**Classificação:** Negócio.

- Condição: o indicador de sucesso é diferente de `Y` e o processamento alcança essa decisão.
- Consequência: informa que a transferência não pôde ser aplicada porque não foi possível determinar o sucesso.
- Condição alternativa: o indicador de sucesso é igual a `Y`.
- Consequência alternativa: informa que a transferência foi aplicada com sucesso e disponibiliza os saldos retornados.

**Observação importante:** o código de falha `3` não resulta na manutenção da mensagem de erro inesperado. Como esse caminho não possui desvio para GCD999, o programa prossegue até a decisão seguinte, que substitui a mensagem. A regra final precisa refletir a mensagem efetivamente mantida.

Os códigos de falha são interpretados pelo BNK1TFN, mas suas condições de geração dentro do XFRFUN não estão disponíveis.

#### **2.7. SEND-MAP / SM010**

**Estruturas:**

- `IF SEND-ERASE`
- `IF SEND-DATAONLY`
- `IF SEND-DATAONLY-ALARM`
- Três testes internos de retorno CICS.

**Classificação:** Interface para os três primeiros testes; infraestrutura para os testes de retorno.

As decisões controlam o modo de apresentação da tela e o tratamento de falhas técnicas. Não produzem regras de negócio.

#### **2.8. SEND-TERMINATION-MSG / STM010**

**Estrutura:** `IF WS-CICS-RESP NOT = DFHRESP(NORMAL)`

**Classificação:** Infraestrutura.

Trata falha técnica na apresentação da mensagem de encerramento.

### **3. Critérios aplicados à extração**

Foram consideradas as decisões que determinam a aceitação dos dados, as restrições das contas e do valor transferido e a interpretação dos resultados da transferência.

Foram excluídas as verificações de formato numérico, espaços internos, múltiplos pontos decimais, navegação de tela, falhas CICS, registros técnicos e atribuições sem decisão de negócio.

As decisões aninhadas foram analisadas até sua consequência final. Os caminhos que terminam com a mesma consequência por alternativas de uma mesma decisão são agrupados, enquanto ocorrências em pontos distintos do programa são mantidas separadas.

## **Regras de negócio**

1\. Regra: Uma solicitação de transferência com dados considerados válidos deve ser encaminhada para processamento.\
Condição: Quando os dados da transferência passam pelas validações (`VALID-DATA`).\
Consequência: O programa solicita o processamento da transferência por meio do GET-ACC-DATA.\
Parágrafo: PM010

2\. Regra: Uma solicitação de transferência com dados inválidos não deve ser encaminhada para processamento.\
Condição: Quando os dados da transferência não são considerados válidos (`VALID-DATA` falso).\
Consequência: O programa não solicita o processamento da transferência e retorna as informações à tela.\
Parágrafo: PM010

3\. Regra: Uma transferência não pode ter a mesma conta como origem e destino.\
Condição: Quando o número da conta de origem é igual ao número da conta de destino (`FACCNOI = TACCNOI`).\
Consequência: A transferência é rejeitada e o cliente é informado de que as contas devem ser diferentes.\
Parágrafo: ED010

4\. Regra: O número de conta 00000000 não pode ser utilizado em uma transferência.\
Condição: Quando a conta de origem ou a conta de destino possui número 00000000.\
Consequência: A transferência é rejeitada e o cliente é informado de que esse número de conta é inválido.\
Parágrafo: ED010

5\. Regra: O valor da transferência deve ser informado.\
Condição: Quando o campo de valor da transferência não possui conteúdo informado (`AMTL = ZERO`).\
Consequência: A solicitação é rejeitada e o cliente recebe uma mensagem solicitando valor numérico.\
Parágrafo: VA010

6\. Regra: O valor da transferência deve ser maior que zero.\
Condição: Quando o valor reconhecido diretamente como numérico é menor ou igual a zero (`WS-AMOUNT-AS-FLOAT <= 0`).\
Consequência: A solicitação é rejeitada e o cliente é informado de que deve fornecer um valor positivo.\
Parágrafo: VA010

7\. Regra: O valor da transferência é obrigatório e não pode ser informado somente com espaços.\
Condição: Quando todos os caracteres do campo de valor são espaços (`WS-NUM-COUNT-TOTAL = AMTL`).\
Consequência: A solicitação é rejeitada e o cliente recebe uma mensagem solicitando valor numérico.\
Parágrafo: VA010

8\. Regra: O valor informado para transferência não pode ser negativo.\
Condição: Quando o programa identifica a presença do sinal negativo no valor informado (`WS-NUM-COUNT-MINUS > 0`).\
Consequência: A solicitação é rejeitada e o cliente é informado de que deve fornecer um valor positivo.\
Parágrafo: VA010

9\. Regra: O valor da transferência pode possuir no máximo duas casas decimais.\
Condição: Quando o valor possui ponto decimal e a verificação interna identifica mais de duas casas decimais (`WS-NUM-COUNT-TOTAL > 2`).\
Consequência: A solicitação é rejeitada e o cliente é informado de que são aceitas no máximo duas casas decimais.\
Parágrafo: VA010

10\. Regra: Uma transferência com valor igual a zero não pode ser solicitada.\
Condição: Quando o valor resultante da conversão do conteúdo informado é igual a zero (`WS-AMOUNT-AS-FLOAT = ZERO`).\
Consequência: A solicitação é rejeitada e o cliente é informado de que deve fornecer um valor diferente de zero.\
Parágrafo: VA010

11\. Regra: Uma transferência não pode ser aplicada quando a conta de origem não é encontrada.\
Condição: Quando o processamento da transferência retorna insucesso (`SUBPGM-SUCCESS = 'N'`) com código de falha `1`.\
Consequência: O cliente é informado de que a conta de origem não foi encontrada e de que a transferência não foi aplicada.\
Parágrafo: GCD010

12\. Regra: Uma transferência não pode ser aplicada quando a conta de destino não é encontrada.\
Condição: Quando o processamento da transferência retorna insucesso (`SUBPGM-SUCCESS = 'N'`) com código de falha `2`.\
Consequência: O cliente é informado de que a conta de destino não foi encontrada e de que a transferência não foi aplicada.\
Parágrafo: GCD010

13\. Regra: Uma transferência não deve ser apresentada como concluída quando o processamento retorna erro inesperado sem confirmação de sucesso.\
Condição: Quando o indicador de sucesso é `N` e o código de falha retornado é `3`.\
Consequência: O cliente recebe a mensagem de que a transferência não pôde ser aplicada porque não foi possível determinar o sucesso, substituindo a mensagem inicialmente preparada sobre erro inesperado.\
Parágrafo: GCD010

14\. Regra: Uma transferência deve ser rejeitada quando o processamento indicar que o valor precisa ser maior que zero.\
Condição: Quando o processamento da transferência retorna insucesso (`SUBPGM-SUCCESS = 'N'`) com código de falha `4`.\
Consequência: O cliente é informado de que deve fornecer um valor maior que zero e o processamento é encerrado.\
Parágrafo: GCD010

15\. Regra: Uma transferência não pode ser apresentada como aplicada quando o processamento retorna um código de falha não previsto.\
Condição: Quando o indicador de sucesso é `N` e o código de falha é diferente de `1`, `2`, `3` e `4`.\
Consequência: O cliente é informado de que a transferência não pôde ser aplicada devido a um erro.\
Parágrafo: GCD010

16\. Regra: Uma transferência sem confirmação de sucesso deve ser informada ao cliente como não aplicada.\
Condição: Quando o indicador de sucesso é diferente de `Y` (`SUBPGM-SUCCESS NOT = 'Y'`) e o processamento alcança essa verificação, incluindo indicadores diferentes de `N` e o caminho de falha `3`.\
Consequência: O cliente recebe a mensagem de que a transferência não pôde ser aplicada porque não foi possível determinar o sucesso.\
Parágrafo: GCD010

17\. Regra: Uma transferência confirmada como bem-sucedida deve ter seu sucesso informado ao cliente.\
Condição: Quando o processamento retorna indicador de sucesso igual a `Y` (`SUBPGM-SUCCESS = 'Y'`).\
Consequência: O cliente é informado de que a transferência foi aplicada com sucesso e são disponibilizados os saldos atual e disponível das contas de origem e destino retornados pelo processamento.\
Parágrafo: GCD010