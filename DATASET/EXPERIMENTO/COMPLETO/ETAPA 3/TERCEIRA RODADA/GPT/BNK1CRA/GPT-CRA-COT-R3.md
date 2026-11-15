## **Análise**

### **1. Parágrafos e fluxo principal do programa**

O programa **BNK1CRA** recebe uma solicitação de movimentação de valor em uma conta bancária, valida os dados informados e encaminha a operação ao programa **DBCRFUN**, responsável pelo processamento da movimentação.

| Seção / Parágrafo             | Função no programa                                                                                             |
| ----------------------------- | -------------------------------------------------------------------------------------------------------------- |
| PREMIERE / A010               | Controla a entrada na transação, identifica a ação solicitada e inicia o processamento.                        |
| PROCESS-MAP / PM010           | Recebe os dados, executa as validações e, quando válidos, solicita a movimentação.                             |
| RECEIVE-MAP / RM010           | Recebe os dados informados na tela.                                                                            |
| EDIT-DATA / ED010             | Valida o número da conta e o sinal da operação e chama a validação do valor.                                   |
| VALIDATE-AMOUNT / VA010       | Verifica a presença, a representação, a precisão decimal e, em determinados caminhos, o valor da movimentação. |
| UPD-CRED-DATA / UCD010        | Determina o sinal do valor, solicita a movimentação ao DBCRFUN e interpreta o resultado.                       |
| SEND-MAP / SM010              | Controla o envio das informações à tela.                                                                       |
| SEND-TERMINATION-MSG / STM010 | Apresenta a mensagem de encerramento da sessão.                                                                |
| ABEND-THIS-TASK / ATT010      | Executa o encerramento anormal em caso de falha técnica.                                                       |
| POPULATE-TIME-DATE / PTD010   | Obtém data e hora para informações técnicas.                                                                   |

**Fluxo principal:**

1. A010 identifica a situação de entrada e, quando há solicitação de processamento, chama PM010.
2. PM010 executa RM010 para receber os dados e ED010 para validá-los.
3. ED010 verifica o número da conta, o sinal informado e chama VA010.
4. VA010 valida o valor solicitado.
5. PM010 chama UCD010 somente quando os dados permanecem válidos.
6. UCD010 encaminha a solicitação ao DBCRFUN e interpreta o resultado informado.
7. O programa apresenta o resultado da operação.

### **2. Estruturas de decisão e classificação**

#### **PREMIERE / A010**

| Decisão                                        | Classificação  | Comportamento                                                                    |
| ---------------------------------------------- | -------------- | -------------------------------------------------------------------------------- |
| EVALUATE TRUE, com testes de EIBCALEN e EIBAID | Interface      | Controla a inicialização, as ações de teclado, o processamento e o encerramento. |
| IF EIBCALEN NOT = ZERO                         | Infraestrutura | Preserva informações de comunicação entre execuções da transação.                |
| IF WS-CICS-RESP NOT = DFHRESP(NORMAL)          | Infraestrutura | Trata falha técnica no retorno da transação.                                     |

Nenhuma dessas decisões origina regra de negócio no escopo solicitado.

#### **PROCESS-MAP / PM010**

| Decisão       | Classificação | Condição e consequência                                                                                                                            |
| ------------- | ------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| IF VALID-DATA | Negócio       | Quando os dados são válidos, a solicitação é encaminhada ao processamento da movimentação. Quando são inválidos, a movimentação não é encaminhada. |

Essa decisão funciona como condição de entrada do processamento. As regras finais são descritas nas validações e nos resultados da operação, evitando duplicação de regras intermediárias.

#### **RECEIVE-MAP / RM010**

| Decisão                               | Classificação  | Comportamento                                 |
| ------------------------------------- | -------------- | --------------------------------------------- |
| IF WS-CICS-RESP NOT = DFHRESP(NORMAL) | Infraestrutura | Trata falha técnica no recebimento dos dados. |

#### **EDIT-DATA / ED010**

| Decisão                                              | Classificação | Condição e consequência                                                                                                            |
| ---------------------------------------------------- | ------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| IF ACCNOI NOT NUMERIC                                | Interface     | Rejeita uma conta cujo conteúdo não seja numérico. É validação de formato, mesmo que a mensagem solicite o preenchimento da conta. |
| IF ACCNOI = ZERO                                     | Negócio       | Quando o número da conta é zero, a solicitação é rejeitada.                                                                        |
| IF SIGNI NOT = '+' AND SIGNI NOT = '-' AND SIGNL = 1 | Interface     | Rejeita sinal informado diferente de + ou -. É validação de caractere de sinal, expressamente excluída.                            |

#### **VALIDATE-AMOUNT / VA010**

| Decisão                                   | Classificação  | Condição e consequência                                                                                            |
| ----------------------------------------- | -------------- | ------------------------------------------------------------------------------------------------------------------ |
| IF AMTL = ZERO                            | Negócio        | Quando o campo de valor tem comprimento zero, a solicitação é rejeitada.                                           |
| IF AMTI(1:AMTL) IS NUMERIC                | Interface      | Quando o conteúdo é inteiramente numérico, o valor é aceito diretamente e a validação termina.                     |
| IF WS-NUM-COUNT-TOTAL = AMTL              | Negócio        | Quando o campo contém apenas espaços, a solicitação é rejeitada.                                                   |
| IF WS-NUM-COUNT-TOTAL = ZERO              | Infraestrutura | Escolhe como tratar os espaços iniciais durante a preparação do valor.                                             |
| IF WS-NUM-COUNT-SPACE > 0                 | Interface      | Rejeita espaços internos no valor.                                                                                 |
| IF WS-NUM-COUNT-TOTAL < WS-AMOUNT-UNSTR-L | Interface      | Rejeita caracteres que não correspondem à representação numérica admitida.                                         |
| IF WS-NUM-COUNT-POINT > 1                 | Interface      | Rejeita valores com mais de um ponto decimal.                                                                      |
| IF WS-NUM-COUNT-POINT = 1                 | Infraestrutura | Identifica valores que precisam passar pela verificação da parte decimal. É uma condição intermediária.            |
| IF WS-NUM-COUNT-TOTAL > 2                 | Infraestrutura | Aciona a verificação adicional da quantidade de casas decimais.                                                    |
| IF WS-NUM-COUNT-TOTAL > 2, interno        | Negócio        | Quando a contagem final ultrapassa duas casas decimais, a solicitação é rejeitada.                                 |
| IF WS-AMOUNT-AS-FLOAT = ZERO              | Negócio        | Quando o valor convertido é zero, a solicitação é rejeitada, desde que o processamento tenha alcançado esse teste. |

**Observações importantes sobre o comportamento implementado:**

- A obrigatoriedade do valor é verificada tanto pelo comprimento zero quanto pelo preenchimento exclusivamente com espaços. São decisões distintas e, portanto, geram regras separadas.
- A limitação de duas casas decimais é tratada como restrição da precisão monetária, e não como simples validação de caractere.
- A rejeição de valor zero não é universal: quando o conteúdo inteiro do campo é numérico, o programa aceita diretamente o valor e não executa a verificação posterior de valor zero.
- A rejeição por excesso de casas decimais depende de uma contagem adicional cuja implementação não permite afirmar que todos os valores com mais de duas casas decimais serão rejeitados.

#### **UPD-CRED-DATA / UCD010**

| Decisão                               | Classificação  | Condição e consequência                                                                                                          |
| ------------------------------------- | -------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| IF SIGNI = '-'                        | Negócio        | Quando o sinal informado é negativo, o valor da movimentação é convertido em negativo antes de ser encaminhado ao processamento. |
| IF WS-CICS-RESP NOT = DFHRESP(NORMAL) | Infraestrutura | Trata falha técnica na chamada ao DBCRFUN.                                                                                       |
| IF SUBPGM-SUCCESS = 'N'               | Negócio        | Quando o processamento retorna insucesso, o programa examina o motivo da recusa. É uma decisão intermediária.                    |
| EVALUATE SUBPGM-FAIL-CODE, WHEN '1'   | Negócio        | Quando a conta não é encontrada para o código bancário informado pelo processamento, o valor não é aplicado.                     |
| EVALUATE SUBPGM-FAIL-CODE, WHEN '2'   | Negócio        | Quando há erro inesperado informado pelo processamento, o valor não é aplicado.                                                  |
| EVALUATE SUBPGM-FAIL-CODE, WHEN '3'   | Negócio        | Quando há insuficiência de fundos disponíveis, a solicitação não é processada.                                                   |
| EVALUATE SUBPGM-FAIL-CODE, WHEN OTHER | Negócio        | Quando ocorre outro motivo de insucesso, o valor não é aplicado e o código recebido é apresentado.                               |
| ELSE de IF SUBPGM-SUCCESS = 'N'       | Negócio        | Quando o indicador de sucesso é diferente de N, o programa informa que o valor foi aplicado à conta.                             |

O programa não implementa diretamente a verificação da existência da conta nem a verificação de saldo suficiente. Essas situações são identificadas pelos resultados devolvidos pelo DBCRFUN.

#### **SEND-MAP / SM010**

| Decisão                                           | Classificação  | Comportamento                                    |
| ------------------------------------------------- | -------------- | ------------------------------------------------ |
| IF SEND-ERASE                                     | Interface      | Seleciona a apresentação completa da tela.       |
| IF SEND-DATAONLY                                  | Interface      | Seleciona a atualização dos dados apresentados.  |
| IF SEND-DATAONLY-ALARM                            | Interface      | Seleciona a atualização dos dados com alarme.    |
| Três testes IF WS-CICS-RESP NOT = DFHRESP(NORMAL) | Infraestrutura | Tratam falhas técnicas nas modalidades de envio. |

#### **SEND-TERMINATION-MSG / STM010**

| Decisão                               | Classificação  | Comportamento                                                 |
| ------------------------------------- | -------------- | ------------------------------------------------------------- |
| IF WS-CICS-RESP NOT = DFHRESP(NORMAL) | Infraestrutura | Trata falha técnica ao apresentar a mensagem de encerramento. |

#### **ABEND-THIS-TASK / ATT010 e POPULATE-TIME-DATE / PTD010**

Não apresentam estruturas de decisão que originem regras de negócio.

## **Regras de negócio**

1\. Regra: O número da conta bancária deve ser diferente de zero.\
Condição: Quando o número da conta informado (ACCNOI) é igual a zero.\
Consequência: A solicitação é rejeitada, com uma mensagem solicitando um número de conta diferente de zero.\
Parágrafo: ED010

2\. Regra: O valor da movimentação bancária é obrigatório.\
Condição: Quando o campo do valor (AMTI) tem comprimento zero (AMTL = ZERO).\
Consequência: A solicitação é rejeitada, com uma mensagem solicitando um valor numérico.\
Parágrafo: VA010

3\. Regra: O valor da movimentação bancária não pode ser preenchido apenas com espaços.\
Condição: Quando todos os caracteres informados no campo do valor são espaços.\
Consequência: A solicitação é rejeitada, com uma mensagem solicitando um valor numérico.\
Parágrafo: VA010

4\. Regra: O valor da movimentação bancária admite no máximo duas casas decimais, quando a verificação de precisão decimal identifica esse excesso.\
Condição: Quando o valor contém um ponto decimal, a primeira contagem indica mais de duas posições após o ponto e a contagem adicional de dígitos decimais também resulta em mais de dois.\
Consequência: A solicitação é rejeitada, com uma mensagem informando que são aceitas até duas casas decimais; a implementação da contagem adicional torna ambígua a rejeição de todos os valores com precisão superior a duas casas.\
Parágrafo: VA010

5\. Regra: O valor da movimentação bancária deve ser diferente de zero quando submetido à verificação final do valor convertido.\
Condição: Quando o valor convertido é igual a zero e a entrada não foi aceita anteriormente pelo caminho que reconhece o conteúdo como inteiramente numérico.\
Consequência: A solicitação é rejeitada, com uma mensagem exigindo um valor diferente de zero; valores compostos exclusivamente de dígitos, inclusive zero, não passam por essa verificação.\
Parágrafo: VA010

6\. Regra: A movimentação bancária com sinal negativo deve ser encaminhada como um valor negativo.\
Condição: Quando o sinal informado (SIGNI) é '-'.\
Consequência: O valor da movimentação é convertido em negativo antes de ser encaminhado ao processamento bancário.\
Parágrafo: UCD010

7\. Regra: Uma movimentação bancária não é aplicada quando a conta não é encontrada para o código bancário retornado pelo processamento.\
Condição: Quando o processamento retorna insucesso (SUBPGM-SUCCESS = 'N') com motivo '1' (SUBPGM-FAIL-CODE).\
Consequência: O valor não é aplicado e é apresentada uma mensagem informando que a conta não foi encontrada, incluindo o código bancário retornado (SUBPGM-SORTC).\
Parágrafo: UCD010

8\. Regra: Uma movimentação bancária não é aplicada quando o processamento informa um erro inesperado.\
Condição: Quando o processamento retorna insucesso (SUBPGM-SUCCESS = 'N') com motivo '2' (SUBPGM-FAIL-CODE).\
Consequência: O valor não é aplicado e é apresentada uma mensagem informando que a movimentação não pôde ser realizada devido a um erro inesperado.\
Parágrafo: UCD010

9\. Regra: Uma movimentação bancária não é realizada quando o processamento informa insuficiência de fundos disponíveis.\
Condição: Quando o processamento retorna insucesso (SUBPGM-SUCCESS = 'N') com motivo '3' (SUBPGM-FAIL-CODE).\
Consequência: A solicitação não é processada e é apresentada uma mensagem informando a insuficiência de fundos disponíveis.\
Parágrafo: UCD010

10\. Regra: Uma movimentação bancária não é aplicada quando o processamento informa um motivo de insucesso diferente dos motivos previstos.\
Condição: Quando o processamento retorna insucesso (SUBPGM-SUCCESS = 'N') com um código de falha diferente de '1', '2' e '3'.\
Consequência: O valor não é aplicado e é apresentada uma mensagem informando um erro inesperado, acompanhada do código de falha retornado.\
Parágrafo: UCD010

11\. Regra: Uma movimentação bancária é informada como realizada quando o processamento não retorna o indicador de insucesso.\
Condição: Quando o indicador de resultado (SUBPGM-SUCCESS) é diferente de 'N'.\
Consequência: O programa informa que o valor foi aplicado à conta e apresenta os saldos contábil e disponível retornados pelo processamento; o código não exige explicitamente que o indicador seja 'Y'.\
Parágrafo: UCD010