## **Análise**

### **1. Parágrafos e fluxo principal do programa**

**Programa:** BNK1CRA

**Finalidade:** Permitir a aplicação de um valor positivo ou negativo a uma conta bancária, realizando validações dos dados informados e apresentando o resultado da operação. O processamento da movimentação é delegado ao programa DBCRFUN.

| Parágrafo | Função no fluxo                                                                          |
| --------- | ---------------------------------------------------------------------------------------- |
| A010      | Controla a entrada na transação, a inicialização e o direcionamento do processamento.    |
| PM010     | Recebe os dados, executa as validações e, se forem válidos, solicita a movimentação.     |
| RM010     | Recebe os dados da tela.                                                                 |
| ED010     | Valida o número da conta e o sinal do valor, e aciona a validação do montante.           |
| VA010     | Verifica o preenchimento, o formato, a precisão decimal e o valor do montante.           |
| UCD010    | Define o sinal do montante, solicita a movimentação ao DBCRFUN e interpreta o resultado. |
| SM010     | Controla a apresentação das informações na tela.                                         |
| STM010    | Apresenta a mensagem de encerramento da sessão.                                          |
| ATT010    | Executa o encerramento técnico por falha.                                                |
| PTD010    | Obtém a data e a hora utilizadas no tratamento técnico de falhas.                        |

**Fluxo principal:** A010 → PM010 → RM010 → ED010 → VA010 → PM010 (verificação da validade) → UCD010 (quando os dados são válidos) → SM010.

O programa não implementa diretamente a atualização do saldo. Essa responsabilidade é delegada ao DBCRFUN, cujo código não foi fornecido. Portanto, somente as decisões e consequências observáveis no BNK1CRA são consideradas.

### **2. Estruturas de decisão e classificação**

| Parágrafo | Estrutura e condição                                   | Classificação  | Consequência                                                                                                           |
| --------- | ------------------------------------------------------ | -------------- | ---------------------------------------------------------------------------------------------------------------------- |
| A010      | `EVALUATE TRUE`, verificando EIBCALEN e EIBAID         | Interface      | Inicializa a tela, processa a entrada ou executa ações de navegação.                                                   |
| A010      | `IF EIBCALEN NOT = ZERO`                               | Infraestrutura | Recupera os dados da área de comunicação.                                                                              |
| A010      | `IF WS-CICS-RESP NOT = NORMAL`                         | Infraestrutura | Trata falha técnica no retorno da transação.                                                                           |
| PM010     | `IF VALID-DATA`                                        | Negócio        | Quando os dados são válidos, permite solicitar a movimentação bancária. Quando não são, não solicita a movimentação.   |
| RM010     | `IF WS-CICS-RESP NOT = NORMAL`                         | Infraestrutura | Trata falha técnica no recebimento da tela.                                                                            |
| ED010     | `IF ACCNOI NOT NUMERIC`                                | Interface      | Rejeita o formato inválido do número da conta.                                                                         |
| ED010     | `IF ACCNOI = ZERO`                                     | Negócio        | Rejeita o número de conta igual a zero e impede a movimentação.                                                        |
| ED010     | `IF SIGNI NOT = '+' AND SIGNI NOT = '-' AND SIGNL = 1` | Interface      | Rejeita um caractere de sinal inválido.                                                                                |
| VA010     | `IF AMTL = ZERO`                                       | Negócio        | Rejeita o montante não preenchido e impede a movimentação.                                                             |
| VA010     | `IF AMTI(1:AMTL) IS NUMERIC`                           | Interface      | Aceita diretamente um montante composto somente por dígitos, inclusive zero, sem executar as verificações posteriores. |
| VA010     | `IF WS-NUM-COUNT-TOTAL = AMTL`                         | Negócio        | Rejeita o montante preenchido somente com espaços.                                                                     |
| VA010     | `IF WS-NUM-COUNT-TOTAL = ZERO`                         | Interface      | Define o tratamento de espaços iniciais.                                                                               |
| VA010     | `IF WS-NUM-COUNT-SPACE > 0`                            | Interface      | Rejeita espaços internos no montante.                                                                                  |
| VA010     | `IF WS-NUM-COUNT-TOTAL < WS-AMOUNT-UNSTR-L`            | Interface      | Rejeita caracteres incompatíveis com a representação numérica.                                                         |
| VA010     | `IF WS-NUM-COUNT-POINT > 1`                            | Interface      | Rejeita mais de um separador decimal.                                                                                  |
| VA010     | `IF WS-NUM-COUNT-POINT = 1`                            | Interface      | Identifica valores com separador decimal para verificar sua precisão.                                                  |
| VA010     | `IF WS-NUM-COUNT-TOTAL > 2` (primeira ocorrência)      | Negócio        | Quando existem mais de dois caracteres após o separador decimal, executa uma verificação adicional da precisão.        |
| VA010     | `IF WS-NUM-COUNT-TOTAL > 2` (segunda ocorrência)       | Negócio        | Rejeita o valor quando a contagem específica de dígitos após o separador excede dois.                                  |
| VA010     | `IF WS-AMOUNT-AS-FLOAT = ZERO`                         | Negócio        | Rejeita o montante igual a zero, desde que o processamento tenha alcançado essa verificação.                           |
| UCD010    | `IF SIGNI = '-'`                                       | Negócio        | Converte o montante para negativo antes de solicitar a movimentação.                                                   |
| UCD010    | `IF WS-CICS-RESP NOT = NORMAL`                         | Infraestrutura | Trata falha técnica na chamada ao DBCRFUN.                                                                             |
| UCD010    | `IF SUBPGM-SUCCESS = 'N'`                              | Negócio        | Distingue a movimentação não realizada da movimentação considerada bem-sucedida.                                       |
| UCD010    | `EVALUATE SUBPGM-FAIL-CODE`, valor '1'                 | Negócio        | Informa que a conta não foi encontrada para o código bancário retornado e que o montante não foi aplicado.             |
| UCD010    | `EVALUATE SUBPGM-FAIL-CODE`, valor '2'                 | Negócio        | Informa que o montante não pôde ser aplicado devido a erro inesperado.                                                 |
| UCD010    | `EVALUATE SUBPGM-FAIL-CODE`, valor '3'                 | Negócio        | Informa que não existem fundos disponíveis suficientes para realizar a operação.                                       |
| UCD010    | `EVALUATE SUBPGM-FAIL-CODE`, OTHER                     | Negócio        | Informa que o montante não pôde ser aplicado por erro inesperado, incluindo o código de falha na mensagem.             |
| UCD010    | `ELSE` de `IF SUBPGM-SUCCESS = 'N'`                    | Negócio        | Informa que o montante foi aplicado com sucesso.                                                                       |
| SM010     | `IF SEND-ERASE`                                        | Interface      | Envia a tela com limpeza prévia.                                                                                       |
| SM010     | `IF SEND-DATAONLY`                                     | Interface      | Envia somente os dados da tela.                                                                                        |
| SM010     | `IF SEND-DATAONLY-ALARM`                               | Interface      | Envia os dados da tela com sinalização sonora.                                                                         |
| SM010     | Três verificações `IF WS-CICS-RESP NOT = NORMAL`       | Infraestrutura | Tratam falhas técnicas nas diferentes modalidades de envio.                                                            |
| STM010    | `IF WS-CICS-RESP NOT = NORMAL`                         | Infraestrutura | Trata falha técnica na apresentação da mensagem de encerramento.                                                       |

### **3. Observações sobre as decisões de negócio**

O código apresenta algumas particularidades que devem ser preservadas na documentação:

- **Montante igual a zero:** quando o conteúdo é inteiramente numérico, o programa aceita o valor diretamente e não executa a verificação posterior de valor zero. Portanto, a rejeição de zero não é universal.
- **Precisão decimal:** a rejeição depende de uma contagem específica de dígitos realizada no código. A intenção expressa pela mensagem é limitar a duas casas decimais, mas a implementação não permite afirmar que todos os valores com mais de duas casas sejam rejeitados.
- **Resultado da movimentação:** qualquer retorno de `SUBPGM-SUCCESS` diferente de `'N'` segue o caminho de sucesso. O programa não exige explicitamente `'Y'`.
- **Sinal positivo:** a aplicação do valor sem inversão de sinal ocorre na ausência de `'-'`. Não há uma decisão específica para o sinal `'+'`; sua aceitação depende das demais validações.

## **Regras de negócio**

1\. **Regra:** Uma movimentação bancária somente pode ser encaminhada para processamento quando os dados informados forem considerados válidos pelo programa.

**Condição:** Quando o número da conta, o sinal e o montante passam pelas validações e o indicador `VALID-DATA` permanece verdadeiro.

**Consequência:** A movimentação é encaminhada para processamento pelo programa responsável.

**Parágrafo:** PM010.

2\. **Regra:** Uma movimentação bancária não deve ser encaminhada para processamento quando os dados informados forem considerados inválidos.

**Condição:** Quando alguma validação torna o indicador `VALID-DATA` falso.

**Consequência:** A movimentação não é encaminhada para processamento.

**Parágrafo:** PM010.

3\. **Regra:** O número da conta bancária deve ser diferente de zero.

**Condição:** Quando o número da conta informado é igual a zero (`ACCNOI = ZERO`).

**Consequência:** O número da conta é rejeitado, o usuário é solicitado a informar uma conta diferente de zero e a movimentação não é processada.

**Parágrafo:** ED010.

4\. **Regra:** O valor da movimentação bancária deve ser informado.

**Condição:** Quando o campo do montante apresenta comprimento zero (`AMTL = ZERO`).

**Consequência:** O montante é rejeitado e a movimentação não é processada.

**Parágrafo:** VA010.

5\. **Regra:** O valor da movimentação bancária não pode ser preenchido somente com espaços.

**Condição:** Quando todos os caracteres do montante informado são espaços (`WS-NUM-COUNT-TOTAL = AMTL`).

**Consequência:** O montante é rejeitado e a movimentação não é processada.

**Parágrafo:** VA010.

6\. **Regra:** O montante informado está sujeito à restrição de duas casas decimais, conforme a contagem implementada pelo programa.

**Condição:** Quando o valor contém um separador decimal e mais de dois caracteres após ele, acionando a verificação adicional de precisão (`WS-NUM-COUNT-TOTAL > 2`, primeira ocorrência).

**Consequência:** O valor é submetido à verificação adicional que determina se sua precisão decimal será aceita.

**Parágrafo:** VA010.

7\. **Regra:** Um montante cuja contagem de dígitos decimais exceda dois, conforme a verificação implementada, não pode ser utilizado na movimentação.

**Condição:** Quando a contagem específica de dígitos executada após a identificação do separador decimal é superior a dois (`WS-NUM-COUNT-TOTAL > 2`, segunda ocorrência).

**Consequência:** O montante é rejeitado, o usuário recebe uma mensagem informando o limite de duas casas decimais e a movimentação não é processada.

**Parágrafo:** VA010.

8\. **Regra:** Um montante igual a zero deve ser rejeitado quando a validação alcançar a verificação de valor zero.

**Condição:** Quando o montante convertido é igual a zero (`WS-AMOUNT-AS-FLOAT = ZERO`) e não foi previamente aceito pelo caminho destinado a valores inteiramente numéricos.

**Consequência:** O montante é rejeitado, o usuário é solicitado a informar um valor diferente de zero e a movimentação não é processada.

**Parágrafo:** VA010.

9\. **Regra:** Um montante precedido pelo sinal negativo deve ser encaminhado como valor negativo para a movimentação da conta.

**Condição:** Quando o sinal informado é `'-'` (`SIGNI = '-'`).

**Consequência:** O montante tem seu sinal invertido antes de ser encaminhado para processamento pelo DBCRFUN.

**Parágrafo:** UCD010.

10\. **Regra:** Quando a movimentação não é realizada porque a conta bancária não foi encontrada, o usuário deve ser informado.

**Condição:** Quando o processamento retorna insucesso (`SUBPGM-SUCCESS = 'N'`) e o motivo informado é conta não encontrada (`SUBPGM-FAIL-CODE = '1'`).

**Consequência:** O sistema informa que a conta não foi encontrada para o código bancário retornado e que o montante não foi aplicado.

**Parágrafo:** UCD010.

11\. **Regra:** Quando a movimentação não é realizada devido a erro inesperado, o usuário deve ser informado da impossibilidade de aplicar o montante.

**Condição:** Quando o processamento retorna insucesso (`SUBPGM-SUCCESS = 'N'`) e o código de falha é `'2'` ou não corresponde aos códigos `'1'`, `'2'` ou `'3'`.

**Consequência:** O sistema informa que o montante não pôde ser aplicado devido a erro inesperado. Para códigos não previstos, também apresenta o código retornado.

**Parágrafo:** UCD010.

12\. **Regra:** Uma movimentação não realizada por insuficiência de fundos disponíveis deve ser comunicada ao usuário.

**Condição:** Quando o processamento retorna insucesso (`SUBPGM-SUCCESS = 'N'`) e o motivo informado é insuficiência de fundos (`SUBPGM-FAIL-CODE = '3'`).

**Consequência:** O sistema informa que não existem fundos disponíveis suficientes para processar a solicitação.

**Parágrafo:** UCD010.

13\. **Regra:** Uma movimentação considerada bem-sucedida pelo programa deve ter sua aplicação confirmada ao usuário.

**Condição:** Quando o indicador de sucesso retornado pelo processamento é diferente de `'N'` (`SUBPGM-SUCCESS NOT = 'N'`, caminho `ELSE`).

**Consequência:** O sistema informa que o montante foi aplicado com sucesso à conta bancária e disponibiliza o número da conta, o código bancário, o saldo atual e o saldo disponível retornados pelo processamento.

**Parágrafo:** UCD010.