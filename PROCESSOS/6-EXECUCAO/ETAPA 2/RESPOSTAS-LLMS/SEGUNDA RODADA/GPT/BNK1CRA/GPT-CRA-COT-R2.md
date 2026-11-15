## **Análise**

### **1. Parágrafos e fluxo principal do programa**

O programa **BNK1CRA** permite solicitar a aplicação de um valor a uma conta bancária. O valor pode ser positivo ou negativo, conforme o sinal informado. A efetivação da operação é delegada ao programa **DBCRFUN**, que retorna o resultado e, quando aplicável, os saldos da conta.

| Parágrafo | Função no programa                                                                                   |
| --------- | ---------------------------------------------------------------------------------------------------- |
| A010      | Identifica a situação de entrada da transação e direciona o processamento.                           |
| PM010     | Recebe os dados, executa as validações e, se os dados forem válidos, solicita a operação financeira. |
| RM010     | Recebe os dados informados na tela.                                                                  |
| ED010     | Valida o número da conta e o sinal do valor; em seguida, chama a validação do valor.                 |
| VA010     | Valida o preenchimento, o formato, a precisão decimal e o valor monetário.                           |
| UCD010    | Prepara a operação financeira, chama DBCRFUN e interpreta seu resultado.                             |
| SM010     | Controla as diferentes formas de apresentação da tela.                                               |
| STM010    | Apresenta a mensagem de encerramento da sessão.                                                      |
| ATT010    | Encerra a execução em caso de falha técnica.                                                         |
| PTD010    | Obtém data e hora para registros técnicos de falhas.                                                 |

**Fluxo principal:** A010 → PM010 → RM010 → ED010 → VA010 → UCD010 (somente quando os dados são válidos) → SM010.

### **2. Estruturas de decisão e classificação**

| Parágrafo | Estrutura e condição                                               | Classificação          | Consequência                                                                                    |
| --------- | ------------------------------------------------------------------ | ---------------------- | ----------------------------------------------------------------------------------------------- |
| A010      | EVALUATE TRUE: primeira execução, teclas especiais, Enter e outras | Interface              | Define a apresentação, o processamento ou o encerramento da tela.                               |
| A010      | IF EIBCALEN NOT = ZERO                                             | Infraestrutura         | Preserva os dados de comunicação da transação.                                                  |
| A010      | IF WS-CICS-RESP NOT = NORMAL                                       | Infraestrutura         | Trata falha técnica no retorno da transação.                                                    |
| PM010     | IF VALID-DATA                                                      | Negócio                | Se os dados forem válidos, solicita a aplicação do valor à conta; caso contrário, não solicita. |
| RM010     | IF WS-CICS-RESP NOT = NORMAL                                       | Infraestrutura         | Trata falha técnica na recepção da tela.                                                        |
| ED010     | IF ACCNOI NOT NUMERIC                                              | Interface — formato    | Rejeita número de conta que não tenha formato numérico.                                         |
| ED010     | IF ACCNOI = ZERO                                                   | Negócio                | Rejeita conta de número zero.                                                                   |
| ED010     | IF SIGNI NOT = '+' AND SIGNI NOT = '-' AND SIGNL = 1               | Interface — formato    | Rejeita sinal informado diferente de + ou -.                                                    |
| UCD010    | IF SIGNI = '-'                                                     | Negócio                | Converte o valor informado em negativo antes de solicitar a operação.                           |
| UCD010    | IF WS-CICS-RESP NOT = NORMAL                                       | Infraestrutura         | Trata falha técnica na chamada ao programa DBCRFUN.                                             |
| UCD010    | IF SUBPGM-SUCCESS = 'N'                                            | Negócio                | Distingue operação não efetivada de operação informada como bem-sucedida.                       |
| UCD010    | EVALUATE SUBPGM-FAIL-CODE                                          | Negócio                | Identifica o motivo da operação não efetivada.                                                  |
| SM010     | IF SEND-ERASE                                                      | Interface              | Apresenta a tela com limpeza anterior.                                                          |
| SM010     | IF SEND-DATAONLY                                                   | Interface              | Atualiza os dados exibidos na tela.                                                             |
| SM010     | IF SEND-DATAONLY-ALARM                                             | Interface              | Atualiza os dados e emite alerta.                                                               |
| SM010     | Três IF WS-CICS-RESP NOT = NORMAL                                  | Infraestrutura         | Tratam falhas técnicas de apresentação da tela.                                                 |
| STM010    | IF WS-CICS-RESP NOT = NORMAL                                       | Infraestrutura         | Trata falha técnica na apresentação da mensagem de encerramento.                                |
| VA010     | IF AMTL = ZERO                                                     | Negócio                | Rejeita valor monetário não preenchido.                                                         |
| VA010     | IF AMTI(1:AMTL) IS NUMERIC                                         | Interface — formato    | Aceita diretamente conteúdo numérico, sem executar as verificações posteriores.                 |
| VA010     | IF WS-NUM-COUNT-TOTAL = AMTL                                       | Negócio                | Rejeita valor monetário preenchido somente com espaços.                                         |
| VA010     | IF WS-NUM-COUNT-TOTAL = ZERO                                       | Interface — tratamento | Escolhe como remover os espaços iniciais do conteúdo.                                           |
| VA010     | IF WS-NUM-COUNT-SPACE > 0                                          | Interface — formato    | Rejeita espaços internos no valor.                                                              |
| VA010     | IF WS-NUM-COUNT-TOTAL < WS-AMOUNT-UNSTR-L                          | Interface — formato    | Rejeita caracteres incompatíveis com o formato numérico aceito.                                 |
| VA010     | IF WS-NUM-COUNT-POINT > 1                                          | Interface — formato    | Rejeita mais de um separador decimal.                                                           |
| VA010     | IF WS-NUM-COUNT-POINT = 1                                          | Interface — formato    | Inicia verificações adicionais de casas decimais.                                               |
| VA010     | IF WS-NUM-COUNT-TOTAL > 2                                          | Interface — formato    | Executa a verificação complementar de precisão decimal.                                         |
| VA010     | IF WS-NUM-COUNT-TOTAL > 2, interno                                 | Negócio                | Rejeita o valor quando a contagem realizada pelo código ultrapassa duas casas decimais.         |
| VA010     | IF WS-AMOUNT-AS-FLOAT = ZERO                                       | Negócio                | Rejeita valor monetário igual a zero quando esse teste é alcançado.                             |

### **3. Condições e consequências das decisões de negócio**

**PM010 — autorização do processamento:** A aplicação do valor somente é solicitada quando o indicador `VALID-DATA` está ativo. A rejeição de uma validação impede a chamada ao programa financeiro.

**ED010 — identificação da conta:** Quando o número da conta é zero, o programa rejeita a solicitação e pede um número diferente de zero.

**VA010 — preenchimento e valor monetário:** O programa rejeita a ausência do valor, inclusive quando o campo contém apenas espaços. Também existe uma restrição de duas casas decimais, mas sua implementação depende de contagens de caracteres e não constitui uma validação uniforme de precisão. O valor zero é rejeitado no caminho que alcança o teste final; entretanto, o caminho de entrada integralmente numérica termina antecipadamente, sem executar esse teste. Assim, não é correto afirmar que todo valor zero é rejeitado.

**UCD010 — sinal da operação:** Quando o sinal informado é negativo, o valor é multiplicado por -1 antes de ser enviado ao programa financeiro. Para sinal positivo ou não negativo, não ocorre essa inversão. O programa não determina diretamente se o débito ou crédito será efetivado.

**UCD010 — resultado financeiro:** O programa DBCRFUN informa o resultado da solicitação. Quando retorna insucesso, BNK1CRA distingue conta não encontrada, insuficiência de fundos e falha inesperada. Nos casos de insucesso, a rotina não chega às instruções que apresentam os saldos retornados. Quando `SUBPGM-SUCCESS` é diferente de `N`, a operação é apresentada como bem-sucedida e os saldos retornados são mostrados.

**Limite de interpretação:** A existência da conta, a disponibilidade de fundos e a efetivação financeira são verificadas pelo programa externo DBCRFUN, cujo código-fonte não foi fornecido. Portanto, essas condições são documentadas como resultados interpretados por BNK1CRA, não como validações executadas diretamente por ele.

## **Regras de negócio**

1\. Regra: A aplicação de um valor a uma conta bancária somente é solicitada quando os dados informados são considerados válidos.

- Condição: Quando o indicador de validade dos dados está ativo (`VALID-DATA`).
- Consequência: O sistema encaminha a solicitação para processamento financeiro.
- Parágrafo: PM010.

2\. Regra: Uma solicitação com dados inválidos não é encaminhada para aplicação do valor à conta.

- Condição: Quando o indicador de validade dos dados não está ativo.
- Consequência: O sistema não executa a solicitação de atualização financeira.
- Parágrafo: PM010.

3\. Regra: O número da conta bancária deve ser diferente de zero.

- Condição: Quando o número da conta informado é igual a zero (`ACCNOI = ZERO`).
- Consequência: A solicitação é rejeitada e o sistema pede um número de conta diferente de zero.
- Parágrafo: ED010.

4\. Regra: Um valor informado com sinal negativo deve ser encaminhado como valor negativo para processamento financeiro.

- Condição: Quando o sinal informado é `-` (`SIGNI = '-'`).
- Consequência: O sistema inverte o sinal do valor antes de encaminhá-lo para processamento.
- Parágrafo: UCD010.

5\. Regra: Quando o sinal informado não é negativo, o sistema não inverte o sinal do valor antes do processamento financeiro.

- Condição: Quando `SIGNI` é diferente de `-`.
- Consequência: O valor é encaminhado sem a inversão de sinal prevista para operações negativas.
- Parágrafo: UCD010.

6\. Regra: Uma operação financeira não efetivada deve ter seu motivo identificado pelo resultado retornado pelo processamento financeiro.

- Condição: Quando o programa financeiro informa insucesso (`SUBPGM-SUCCESS = 'N'`) e o motivo retornado é avaliado.
- Consequência: O sistema seleciona o tratamento correspondente ao motivo da não efetivação.
- Parágrafo: UCD010.

7\. Regra: Uma operação não pode ser aplicada quando a conta bancária não é encontrada pelo processamento financeiro.

- Condição: Quando o processamento financeiro retorna insucesso e código de motivo `1` (`SUBPGM-FAIL-CODE = '1'`).
- Consequência: O sistema informa que a conta não foi encontrada para o código bancário retornado e que o valor não foi aplicado.
- Parágrafo: UCD010.

8\. Regra: Uma operação financeira não efetivada por erro inesperado deve ser informada ao cliente.

- Condição: Quando o processamento financeiro retorna insucesso e código de motivo `2` (`SUBPGM-FAIL-CODE = '2'`).
- Consequência: O sistema informa que o valor não pôde ser aplicado devido a um erro inesperado.
- Parágrafo: UCD010.

9\. Regra: Uma operação financeira não pode ser processada quando o processamento financeiro informa insuficiência de fundos disponíveis.

- Condição: Quando o processamento financeiro retorna insucesso e código de motivo `3` (`SUBPGM-FAIL-CODE = '3'`).
- Consequência: O sistema informa que não há fundos disponíveis suficientes para processar a solicitação.
- Parágrafo: UCD010.

10\. Regra: Uma operação financeira não efetivada por motivo não reconhecido deve ser informada como não aplicada.

- Condição: Quando o processamento financeiro retorna insucesso e um código de motivo diferente de `1`, `2` ou `3`.
- Consequência: O sistema informa que o valor não pôde ser aplicado devido a um erro inesperado e apresenta o código retornado.
- Parágrafo: UCD010.

11\. Regra: Uma operação informada como bem-sucedida pelo processamento financeiro deve ser confirmada ao cliente.

- Condição: Quando o indicador de sucesso retornado é diferente de `N` (`SUBPGM-SUCCESS NOT = 'N'`).
- Consequência: O sistema apresenta a confirmação de que o valor foi aplicado à conta, juntamente com o número da conta, o código bancário, o saldo atual e o saldo disponível retornados pelo processamento financeiro.
- Parágrafo: UCD010.

12\. Regra: O valor monetário da operação é de preenchimento obrigatório.

- Condição: Quando o campo de valor não contém caracteres (`AMTL = ZERO`).
- Consequência: O sistema rejeita a solicitação e exige o preenchimento do valor.
- Parágrafo: VA010.

13\. Regra: O valor monetário da operação não pode ser preenchido somente com espaços.

- Condição: Quando todos os caracteres informados no campo de valor são espaços (`WS-NUM-COUNT-TOTAL = AMTL`).
- Consequência: O sistema rejeita a solicitação e exige um valor preenchido.
- Parágrafo: VA010.

14\. Regra: O valor monetário está sujeito a uma restrição de até duas casas decimais no caminho de validação que verifica a precisão decimal.

- Condição: Quando o valor contém um ponto decimal, a verificação complementar é alcançada e a contagem efetuada pelo programa ultrapassa duas casas decimais (`WS-NUM-COUNT-TOTAL > 2` no teste interno).
- Consequência: O sistema rejeita o valor e informa que são aceitas até duas casas decimais. A implementação não garante que todos os valores com mais de duas casas sejam rejeitados.
- Parágrafo: VA010.

15\. Regra: O valor monetário da operação não pode ser igual a zero no caminho de validação que executa a verificação final do valor.

- Condição: Quando o valor convertido é igual a zero (`WS-AMOUNT-AS-FLOAT = ZERO`) e o processamento alcança esse teste.
- Consequência: O sistema rejeita a solicitação e exige um valor diferente de zero. Valores integralmente numéricos podem seguir um caminho anterior que não executa essa verificação.
- Parágrafo: VA010.