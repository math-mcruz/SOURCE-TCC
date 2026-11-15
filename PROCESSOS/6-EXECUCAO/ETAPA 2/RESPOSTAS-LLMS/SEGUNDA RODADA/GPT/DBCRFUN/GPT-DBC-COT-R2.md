## **Análise**

### **1. Parágrafos e fluxo principal do programa**

O programa **DBCRFUN** processa movimentações financeiras em contas bancárias, atualizando os saldos disponível e efetivo e registrando a transação correspondente.

| Seção / Parágrafo                      | Função no programa                                                                                                      |
| -------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| `PREMIERE / A010`                      | Inicializa o resultado da operação, identifica o código bancário e chama a atualização da conta.                        |
| `UPDATE-ACCOUNT-DB2 / UAD010`          | Consulta a conta, verifica restrições à movimentação, atualiza os saldos e solicita o registro da transação.            |
| `WRITE-TO-PROCTRAN / WTP010`           | Encaminha o processamento do registro da transação.                                                                     |
| `WRITE-TO-PROCTRAN-DB2 / WTPD010`      | Classifica a movimentação conforme o sinal do valor e o tipo de facilidade, registra a transação e informa o resultado. |
| `GET-ME-OUT-OF-HERE / GMOOH010`        | Encerra o processamento.                                                                                                |
| `CHECK-FOR-STORM-DRAIN-DB2 / CFSDD010` | Identifica condições técnicas de indisponibilidade do banco de dados.                                                   |
| `ABEND-HANDLING / AH010`               | Trata interrupções e falhas técnicas.                                                                                   |
| `POPULATE-TIME-DATE / PTD10`           | Obtém informações de data e hora para tratamento técnico.                                                               |

O fluxo principal é:

1. Receber a conta e o valor da movimentação.
2. Consultar a conta bancária.
3. Verificar se a conta existe.
4. Para valores negativos, verificar restrições de tipo de conta e disponibilidade de saldo.
5. Verificar a restrição específica para contas dos tipos `MORTGAGE` e `LOAN`, quando a facilidade é `496`.
6. Atualizar os saldos disponível e efetivo pelo valor da movimentação.
7. Classificar a movimentação e registrar a transação.
8. Informar se o processamento foi concluído com sucesso.

### **2. Estruturas de decisão e classificação**

| Nº | Parágrafo  | Estrutura e condição                                                                    | Classificação            | Consequência                                                                                           |
| -- | ---------- | --------------------------------------------------------------------------------------- | ------------------------ | ------------------------------------------------------------------------------------------------------ |
| 1  | `UAD010`   | `IF SQLCODE NOT = 0` após consulta da conta                                             | Negócio / Infraestrutura | Diferencia conta não encontrada de erro técnico.                                                       |
| 2  | `UAD010`   | `IF SQLCODE = +100`                                                                     | Negócio                  | Informa que a conta não foi encontrada, com código de falha `1`.                                       |
| 3  | `UAD010`   | `IF COMM-AMT < 0`                                                                       | Negócio                  | Identifica movimentações negativas, sujeitas a restrições adicionais.                                  |
| 4  | `UAD010`   | `IF` conta `MORTGAGE` ou `LOAN` e facilidade `496`, dentro do ramo de valor negativo    | Negócio                  | Rejeita a movimentação com código de falha `4`.                                                        |
| 5  | `UAD010`   | `IF WS-DIFFERENCE < 0 AND COMM-FACILTYPE = 496`                                         | Negócio                  | Rejeita movimentação negativa que deixaria o saldo disponível abaixo de zero, com código de falha `3`. |
| 6  | `UAD010`   | `IF` conta `MORTGAGE` ou `LOAN` e facilidade `496`, após o tratamento do valor negativo | Negócio                  | Rejeita a movimentação com código de falha `4`.                                                        |
| 7  | `UAD010`   | `IF SQLCODE NOT = 0` após atualização da conta                                          | Infraestrutura           | Trata falha técnica na atualização.                                                                    |
| 8  | `WTPD010`  | `IF COMM-AMT < 0`                                                                       | Negócio                  | Diferencia movimentações negativas das não negativas.                                                  |
| 9  | `WTPD010`  | `IF COMM-FACILTYPE = 496` dentro do ramo negativo                                       | Negócio                  | Classifica a transação como `PDR`, em vez de `DEB`.                                                    |
| 10 | `WTPD010`  | `IF COMM-FACILTYPE = 496` dentro do ramo não negativo                                   | Negócio                  | Classifica a transação como `PCR`, em vez de `CRE`.                                                    |
| 11 | `WTPD010`  | `IF SQLCODE NOT = 0` após registro da transação                                         | Infraestrutura / Negócio | Trata falha técnica ou confirma o sucesso da operação.                                                 |
| 12 | `WTPD010`  | `IF WS-CICS-RESP NOT = DFHRESP(NORMAL)`                                                 | Infraestrutura           | Trata falha no desfazimento da operação.                                                               |
| 13 | `CFSDD010` | `EVALUATE SQLCODE`, incluindo `WHEN 923` e `WHEN OTHER`                                 | Infraestrutura           | Identifica perda da conexão com o banco de dados.                                                      |
| 14 | `CFSDD010` | `IF STORM-DRAIN-CONDITION NOT EQUAL 'Not Storm Drain     '`                             | Infraestrutura           | Emite diagnóstico técnico da condição encontrada.                                                      |
| 15 | `AH010`    | `EVALUATE MY-ABEND-CODE`, incluindo `AD2Z`, `AFCR`, `AFCS` e `AFCT`                     | Infraestrutura           | Trata diferentes categorias de interrupção técnica.                                                    |
| 16 | `AH010`    | `IF WS-CICS-RESP NOT = DFHRESP(NORMAL)`                                                 | Infraestrutura           | Trata falha técnica durante o desfazimento da operação.                                                |
| 17 | `AH010`    | `IF WS-STORM-DRAIN = 'N'`                                                               | Infraestrutura           | Determina o encerramento por falha técnica.                                                            |

Não foram identificadas decisões classificadas como interface.

### **3. Condições e consequências das decisões de negócio**

**Consulta da conta — UAD010**

A consulta utiliza o código bancário e o número da conta. Quando não encontra a conta (`SQLCODE = +100`), o programa interrompe a movimentação e devolve o código de falha `1`.

**Movimentações com valor negativo — UAD010**

Quando o valor da movimentação é negativo, o programa executa duas verificações sequenciais:

- Se a conta é `MORTGAGE` ou `LOAN` e a facilidade é `496`, a movimentação é rejeitada com código `4`.
- Se não ocorreu essa rejeição, o programa calcula o saldo disponível após a movimentação. Caso esse saldo seja negativo e a facilidade seja `496`, a movimentação é rejeitada com código `3`.

Para facilidades diferentes de `496`, o programa não aplica a restrição de saldo disponível não negativo.

**Restrição adicional por tipo de conta — UAD010**

Existe uma segunda decisão que rejeita movimentações de contas `MORTGAGE` e `LOAN` associadas à facilidade `496`.

Como os valores negativos dessas contas já foram rejeitados na primeira verificação, essa segunda ocorrência alcança efetivamente os valores não negativos.

**Classificação de transações — WTPD010**

A combinação entre o sinal do valor e a facilidade determina o tipo de transação:

| Valor da movimentação | Facilidade         | Tipo de transação | Descrição registrada                     |
| --------------------- | ------------------ | ----------------- | ---------------------------------------- |
| Negativo              | Diferente de `496` | `DEB`             | `COUNTER WTHDRW`                         |
| Negativo              | `496`              | `PDR`             | Primeiros 14 caracteres de `COMM-ORIGIN` |
| Zero ou positivo      | Diferente de `496` | `CRE`             | `COUNTER RECVED`                         |
| Zero ou positivo      | `496`              | `PCR`             | Primeiros 14 caracteres de `COMM-ORIGIN` |

O código não explicita o significado comercial das siglas `PDR` e `PCR`. Portanto, elas são preservadas sem atribuir uma interpretação não demonstrada.

**Resultado da movimentação — WTPD010**

Quando o registro da transação é concluído com sucesso, o programa informa sucesso (`COMM-SUCCESS = 'Y'`) e código de falha `0`.

Quando ocorre uma falha técnica no registro, o programa informa insucesso. Os detalhes técnicos dessa falha não constituem regras de negócio segundo os critérios estabelecidos.

## **Regras de negócio**

1\. **Regra:** Uma movimentação financeira não pode ser realizada quando a conta bancária informada não é encontrada.

**Condição:** Quando a consulta pelo código bancário e número da conta não encontra uma conta cadastrada (`SQLCODE = +100`).

**Consequência:** A movimentação é rejeitada, com indicação de insucesso e código de falha `1`.

**Parágrafo:** `UAD010`

2\. **Regra:** Uma movimentação de valor negativo não é permitida para contas dos tipos `MORTGAGE` ou `LOAN` quando a facilidade informada é `496`.

**Condição:** Quando o valor da movimentação é negativo (`COMM-AMT < 0`), a conta é do tipo `MORTGAGE` ou `LOAN` e a facilidade é `496`.

**Consequência:** A movimentação é rejeitada, com indicação de insucesso e código de falha `4`.

**Parágrafo:** `UAD010`

3\. **Regra:** Uma movimentação de valor negativo associada à facilidade `496` não pode deixar o saldo disponível da conta abaixo de zero.

**Condição:** Quando o valor da movimentação é negativo, a facilidade é `496`, a movimentação não foi rejeitada pela restrição anterior e a soma do saldo disponível com o valor da movimentação é menor que zero (`WS-DIFFERENCE < 0`).

**Consequência:** A movimentação é rejeitada, com indicação de insucesso e código de falha `3`.

**Parágrafo:** `UAD010`

4\. **Regra:** Movimentações de valor negativo associadas a facilidades diferentes de `496` não são rejeitadas pelo programa apenas por deixarem o saldo disponível abaixo de zero.

**Condição:** Quando o valor da movimentação é negativo (`COMM-AMT < 0`) e a facilidade é diferente de `496`.

**Consequência:** O processamento prossegue para a atualização da conta, mesmo que a movimentação resulte em saldo disponível negativo.

**Parágrafo:** `UAD010`

5\. **Regra:** Uma movimentação de valor não negativo não é permitida para contas dos tipos `MORTGAGE` ou `LOAN` quando a facilidade informada é `496`.

**Condição:** Quando o valor da movimentação é zero ou positivo (`COMM-AMT >= 0`), a conta é do tipo `MORTGAGE` ou `LOAN` e a facilidade é `496`.

**Consequência:** A movimentação é rejeitada, com indicação de insucesso e código de falha `4`.

**Parágrafo:** `UAD010`

6\. **Regra:** Uma movimentação de valor negativo associada a uma facilidade diferente de `496` é registrada como transação do tipo `DEB`.

**Condição:** Quando o valor da movimentação é negativo (`COMM-AMT < 0`), a facilidade é diferente de `496` e a movimentação chegou à etapa de registro.

**Consequência:** A transação recebe o tipo `DEB` e a descrição `COUNTER WTHDRW`.

**Parágrafo:** `WTPD010`

7\. **Regra:** Uma movimentação de valor negativo associada à facilidade `496` é registrada como transação do tipo `PDR`.

**Condição:** Quando o valor da movimentação é negativo (`COMM-AMT < 0`), a facilidade é `496` e a movimentação passou pelas restrições anteriores.

**Consequência:** A transação recebe o tipo `PDR` e uma descrição formada pelos primeiros 14 caracteres da origem da movimentação (`COMM-ORIGIN`).

**Parágrafo:** `WTPD010`

8\. **Regra:** Uma movimentação de valor zero ou positivo associada a uma facilidade diferente de `496` é registrada como transação do tipo `CRE`.

**Condição:** Quando o valor da movimentação é zero ou positivo (`COMM-AMT >= 0`), a facilidade é diferente de `496` e a movimentação chegou à etapa de registro.

**Consequência:** A transação recebe o tipo `CRE` e a descrição `COUNTER RECVED`.

**Parágrafo:** `WTPD010`

9\. **Regra:** Uma movimentação de valor zero ou positivo associada à facilidade `496` é registrada como transação do tipo `PCR`.

**Condição:** Quando o valor da movimentação é zero ou positivo (`COMM-AMT >= 0`), a facilidade é `496` e a movimentação passou pelas restrições anteriores.

**Consequência:** A transação recebe o tipo `PCR` e uma descrição formada pelos primeiros 14 caracteres da origem da movimentação (`COMM-ORIGIN`).

**Parágrafo:** `WTPD010`

10\. **Regra:** Uma movimentação financeira é considerada concluída com sucesso quando seu registro de transação é realizado com sucesso.

**Condição:** Quando o registro da transação é concluído sem erro (`SQLCODE = 0` após a inclusão em `PROCTRAN`).

**Consequência:** O programa informa que a movimentação foi realizada com sucesso (`COMM-SUCCESS = 'Y'`), com código de falha `0`.

**Parágrafo:** `WTPD010`