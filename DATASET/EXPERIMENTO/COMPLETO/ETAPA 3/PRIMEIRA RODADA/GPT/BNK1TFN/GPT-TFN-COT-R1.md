## **Análise**

### **1. Parágrafos e fluxo principal do programa**

O programa **BNK1TFN** realiza o processamento de solicitações de transferência de valores entre contas bancárias. Ele valida os dados informados, solicita a execução da transferência ao programa **XFRFUN** e apresenta o resultado da operação.

| Parágrafo | Responsabilidade                                                                                         |
| --------- | -------------------------------------------------------------------------------------------------------- |
| A010      | Controlar o início da transação e direcionar o processamento conforme a interação do usuário.            |
| PM010     | Receber os dados, executar as validações e prosseguir com a transferência quando os dados forem válidos. |
| RM010     | Receber os dados informados na tela.                                                                     |
| ED010     | Validar os números das contas de origem e destino.                                                       |
| GCD010    | Solicitar a transferência ao programa XFRFUN e interpretar o resultado retornado.                        |
| SM010     | Controlar a apresentação das informações na tela.                                                        |
| STM010    | Apresentar a mensagem de encerramento da sessão.                                                         |
| ATT010    | Encerrar a execução em situações de falha técnica.                                                       |
| VA010     | Validar o valor informado para a transferência.                                                          |
| PTD010    | Obter a data e a hora utilizadas nos procedimentos técnicos.                                             |

O fluxo principal é: recebimento dos dados → validação das contas → validação do valor → solicitação da transferência → interpretação do resultado → apresentação da resposta.

### **2. Estruturas de decisão e classificação**

**A010 — Controle inicial**

- `EVALUATE TRUE`, com condições relacionadas a `EIBCALEN` e `EIBAID`: **Interface**. Controla a apresentação inicial, as teclas utilizadas, o encerramento e o encaminhamento para o processamento.
- `IF WS-CICS-RESP NOT = DFHRESP(NORMAL)`: **Infraestrutura**. Trata uma falha técnica no retorno da transação.

**PM010 — Processamento dos dados**

\- `IF VALID-DATA`: **Negócio**. Quando os dados são considerados válidos, solicita o processamento da transferência por meio de `GET-ACC-DATA`. Caso contrário, não solicita a transferência.

**RM010 — Recebimento da tela**

\- `IF WS-CICS-RESP NOT = DFHRESP(NORMAL)`: **Infraestrutura**. Trata falha técnica no recebimento dos dados.

**ED010 — Validação das contas**

- `IF FACCNOI NOT NUMERIC`: **Interface**. Verifica o formato numérico da conta de origem.
- `IF TACCNOI NOT NUMERIC`: **Interface**. Verifica o formato numérico da conta de destino.
- `IF FACCNOI = TACCNOI`: **Negócio**. Impede transferências entre contas com o mesmo número.
- `IF FACCNOI = '00000000' OR TACCNOI = '00000000'`: **Negócio**. Rejeita a operação quando uma das contas possui o número `00000000`.

**GCD010 — Processamento da transferência**

- `IF WS-CICS-RESP NOT = DFHRESP(NORMAL)`: **Infraestrutura**. Trata falha técnica na chamada ao programa XFRFUN.
- `IF SUBPGM-SUCCESS = 'N'`: **Negócio**. Identifica uma transferência não confirmada como bem-sucedida e encaminha o processamento para a interpretação do motivo.
- `EVALUATE SUBPGM-FAIL-CODE`: **Negócio**, com os seguintes caminhos:
  - Código `1`: informa que a conta de origem não foi encontrada e que a transferência não foi aplicada.
  - Código `2`: informa que a conta de destino não foi encontrada e que a transferência não foi aplicada.
  - Código `3`: prepara uma mensagem de erro inesperado, mas não encerra o processamento nesse ponto.
  - Código `4`: informa que é necessário fornecer um valor maior que zero.
  - Outros códigos: informa que a transferência não foi aplicada devido a um erro.
- `IF SUBPGM-SUCCESS NOT = 'Y'`: **Negócio**. Quando o processamento alcança essa decisão sem confirmação de sucesso, informa que não foi possível determinar o sucesso da transferência. Isso inclui o caminho do código de falha `3`, cuja mensagem anterior é substituída.
- `ELSE` de `IF SUBPGM-SUCCESS NOT = 'Y'`: **Negócio**. Quando existe confirmação de sucesso (`Y`), informa que a transferência foi aplicada.

O programa BNK1TFN interpreta os resultados enviados por XFRFUN. As verificações internas realizadas por XFRFUN não estão disponíveis no código fornecido.

**SM010 — Apresentação dos resultados**

- `IF SEND-ERASE`: **Interface**. Controla a apresentação da tela com limpeza anterior.
- `IF SEND-DATAONLY`: **Interface**. Controla a atualização dos dados apresentados.
- `IF SEND-DATAONLY-ALARM`: **Interface**. Controla a atualização da tela com aviso sonoro.
- Os três testes de `WS-CICS-RESP NOT = DFHRESP(NORMAL)`: **Infraestrutura**. Tratam falhas técnicas no envio da tela.

**STM010 — Encerramento da sessão**

\- `IF WS-CICS-RESP NOT = DFHRESP(NORMAL)`: **Infraestrutura**. Trata falha técnica na apresentação da mensagem de encerramento.

**VA010 — Validação do valor da transferência**

- `IF AMTL = ZERO`: **Negócio**. Impede o prosseguimento quando o campo do valor está vazio, embora a mensagem apresentada mencione formato numérico.
- `IF AMTI(1:AMTL) IS NUMERIC`: **Interface**. Identifica o formato da informação e direciona sua conversão.
- `IF WS-AMOUNT-AS-FLOAT <= 0`: **Negócio**. Rejeita valores menores ou iguais a zero no caminho de conteúdo diretamente numérico.
- `IF WS-NUM-COUNT-TOTAL = AMTL`: **Negócio**. Rejeita o valor quando o campo contém apenas espaços.
- `IF WS-NUM-COUNT-TOTAL = ZERO`: **Interface**. Determina como remover os espaços iniciais do valor.
- `IF WS-NUM-COUNT-MINUS > 0`: **Interface**. Verifica a presença do caractere de sinal negativo; trata-se de validação de formato, conforme o critério estabelecido.
- `IF WS-NUM-COUNT-SPACE > 0`: **Interface**. Rejeita espaços internos.
- `IF WS-NUM-COUNT-TOTAL < WS-AMOUNT-UNSTR-L`: **Interface**. Rejeita caracteres incompatíveis com o formato numérico esperado.
- `IF WS-NUM-COUNT-POINT > 1`: **Interface**. Rejeita mais de um ponto decimal.
- `IF WS-NUM-COUNT-POINT = 1`: **Interface**. Identifica a presença de separador decimal para continuar a validação.
- `IF WS-NUM-COUNT-TOTAL > 2`: **Negócio**. Identifica mais de duas posições após o separador decimal, encaminhando o processamento para uma verificação adicional.
- `IF WS-NUM-COUNT-TOTAL > 2`, na verificação aninhada: **Negócio**. Rejeita o valor quando a contagem adicional também ultrapassa dois. A implementação utiliza uma segunda contagem de caracteres numéricos, portanto a rejeição não é determinada exclusivamente pelo número inicial de casas decimais.
- `IF WS-AMOUNT-AS-FLOAT = ZERO`: **Negócio**. Rejeita um valor igual a zero após a conversão.

As decisões classificadas como interface ou infraestrutura não produzem regras na lista final.

### **3. Consolidação das decisões de negócio**

As regras identificadas abrangem as seguintes situações:

- A transferência somente é solicitada quando os dados passam pelas validações.
- As contas de origem e destino devem ser diferentes e nenhuma delas pode possuir o número `00000000`.
- O valor da transferência deve ser informado, ser positivo e atender à restrição de casas decimais efetivamente verificada.
- O processamento pode retornar conta de origem inexistente, conta de destino inexistente, valor não permitido, falta de confirmação de sucesso ou erro na execução.
- A confirmação de sucesso depende do indicador devolvido pelo programa XFRFUN.

Os testes que apenas conduzem a uma decisão posterior foram considerados junto ao caminho completo até sua consequência, evitando regras intermediárias sem resultado próprio.

## **Regras de negócio**

1\. Regra: Uma transferência bancária somente é encaminhada para processamento quando os dados informados são considerados válidos.\
Condição: Quando as validações dos dados da transferência são concluídas com resultado válido (`VALID-DATA`).\
Consequência: O sistema solicita o processamento da transferência.\
Parágrafo: PM010

2\. Regra: Uma transferência bancária não é encaminhada para processamento quando os dados informados são considerados inválidos.\
Condição: Quando alguma validação dos dados da transferência identifica uma inconsistência.\
Consequência: O sistema não solicita o processamento da transferência.\
Parágrafo: PM010

3\. Regra: A conta de origem e a conta de destino de uma transferência bancária devem ser diferentes.\
Condição: Quando o número da conta de origem é igual ao número da conta de destino (`FACCNOI = TACCNOI`).\
Consequência: O sistema rejeita a solicitação de transferência e informa que as contas devem ser diferentes.\
Parágrafo: ED010

4\. Regra: O número de conta `00000000` não é permitido em transferências bancárias.\
Condição: Quando a conta de origem ou a conta de destino possui o número `00000000`.\
Consequência: O sistema rejeita a solicitação de transferência e informa que o número da conta é inválido.\
Parágrafo: ED010

5\. Regra: Uma transferência bancária não é aplicada quando a conta de origem não é encontrada.\
Condição: Quando o programa responsável pela transferência retorna insucesso (`SUBPGM-SUCCESS = 'N'`) e código de falha `1`.\
Consequência: O sistema informa que a conta de origem não foi encontrada e que a transferência não foi aplicada.\
Parágrafo: GCD010

6\. Regra: Uma transferência bancária não é aplicada quando a conta de destino não é encontrada.\
Condição: Quando o programa responsável pela transferência retorna insucesso (`SUBPGM-SUCCESS = 'N'`) e código de falha `2`.\
Consequência: O sistema informa que a conta de destino não foi encontrada e que a transferência não foi aplicada.\
Parágrafo: GCD010

7\. Regra: Uma transferência bancária com falha inesperada pode terminar com uma mensagem de impossibilidade de confirmar seu sucesso.\
Condição: Quando o programa responsável pela transferência retorna insucesso (`SUBPGM-SUCCESS = 'N'`) e código de falha `3`.\
Consequência: O sistema substitui a mensagem inicial de erro inesperado por uma mensagem informando que a transferência não pôde ser aplicada porque não foi possível determinar seu sucesso.\
Parágrafo: GCD010

8\. Regra: Uma transferência bancária não é aplicada quando o processamento retorna a exigência de um valor maior que zero.\
Condição: Quando o programa responsável pela transferência retorna insucesso (`SUBPGM-SUCCESS = 'N'`) e código de falha `4`.\
Consequência: O sistema informa que é necessário fornecer um valor maior que zero.\
Parágrafo: GCD010

9\. Regra: Uma transferência bancária não é aplicada quando o processamento retorna um código de falha não previsto especificamente.\
Condição: Quando o programa responsável pela transferência retorna insucesso (`SUBPGM-SUCCESS = 'N'`) e código de falha diferente de `1`, `2`, `3` e `4`.\
Consequência: O sistema informa que a transferência não foi aplicada devido a um erro.\
Parágrafo: GCD010

10\. Regra: Uma transferência bancária sem confirmação de sucesso recebe uma resposta de resultado não confirmado.\
Condição: Quando o processamento alcança a verificação final com indicador de sucesso diferente de `Y` (`SUBPGM-SUCCESS NOT = 'Y'`).\
Consequência: O sistema informa que a transferência não pôde ser aplicada porque não foi possível determinar seu sucesso.\
Parágrafo: GCD010

11\. Regra: Uma transferência bancária é apresentada como realizada quando o programa responsável confirma seu sucesso.\
Condição: Quando o indicador de sucesso retornado é igual a `Y` (`SUBPGM-SUCCESS = 'Y'`).\
Consequência: O sistema informa que a transferência foi aplicada com sucesso.\
Parágrafo: GCD010

12\. Regra: O valor da transferência bancária é obrigatório.\
Condição: Quando o campo destinado ao valor da transferência está vazio (`AMTL = ZERO`).\
Consequência: O sistema rejeita o valor e impede o prosseguimento da transferência, apresentando uma mensagem que solicita um valor numérico.\
Parágrafo: VA010

13\. Regra: O valor de uma transferência bancária deve ser maior que zero.\
Condição: Quando o valor informado é diretamente numérico e, após a conversão, é menor ou igual a zero (`WS-AMOUNT-AS-FLOAT <= 0`).\
Consequência: O sistema rejeita o valor e solicita que seja informado um valor positivo.\
Parágrafo: VA010

14\. Regra: O valor da transferência bancária não pode ser deixado em branco.\
Condição: Quando o campo do valor contém apenas espaços (`WS-NUM-COUNT-TOTAL = AMTL`).\
Consequência: O sistema rejeita o valor e impede o prosseguimento da transferência, apresentando uma mensagem que solicita um valor numérico.\
Parágrafo: VA010

15\. Regra: O valor de uma transferência bancária está sujeito à restrição de até duas casas decimais.\
Condição: Quando o valor contém separador decimal, possui mais de duas posições após esse separador e a verificação adicional de caracteres numéricos também resulta em contagem superior a dois (`WS-NUM-COUNT-TOTAL > 2` na decisão aninhada).\
Consequência: O sistema rejeita o valor e informa que somente até duas casas decimais são aceitas; devido à segunda contagem implementada, o código não garante que todos os valores com mais de duas casas decimais sejam rejeitados.\
Parágrafo: VA010

16\. Regra: O valor de uma transferência bancária não pode ser igual a zero.\
Condição: Quando o valor, após o tratamento e a conversão, é igual a zero (`WS-AMOUNT-AS-FLOAT = ZERO`).\
Consequência: O sistema rejeita o valor e solicita que seja informado um valor diferente de zero.\
Parágrafo: VA010