## **Análise**

### **1. Parágrafos e fluxo principal do programa**

O programa **DBCRFUN** realiza a atualização dos saldos disponível e efetivo de uma conta bancária, utilizando o valor de uma movimentação recebida. Após a atualização da conta, registra a movimentação na tabela de transações processadas.

| Parágrafo  | Finalidade                                                                                                                         |
| ---------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| `A010`     | Inicializa o resultado da operação, identifica a agência e aciona a atualização da conta.                                          |
| `UAD010`   | Consulta a conta, verifica restrições para movimentação, atualiza os saldos e trata o resultado da atualização.                    |
| `WTP010`   | Encaminha o registro da movimentação para o processamento em DB2.                                                                  |
| `WTPD010`  | Classifica a movimentação como débito ou crédito, determina seu tipo e descrição, registra a transação e define o resultado final. |
| `GMOOH010` | Encerra o processamento.                                                                                                           |
| `CFSDD010` | Identifica e comunica determinadas falhas de infraestrutura do DB2.                                                                |
| `AH010`    | Trata encerramentos anormais e falhas técnicas.                                                                                    |
| `PTD10`    | Obtém a data e a hora para tratamento técnico.                                                                                     |

O fluxo principal é:

1. Inicializar o resultado da operação.
2. Localizar a conta pela agência e pelo número.
3. Verificar se a conta foi encontrada.
4. Para valores negativos, verificar as restrições referentes ao tipo de conta e ao saldo disponível.
5. Verificar a restrição para contas de empréstimo ou financiamento imobiliário, independentemente do sinal do valor.
6. Caso a movimentação seja permitida, atualizar os saldos disponível e efetivo.
7. Se a atualização for concluída, classificar e registrar a movimentação.
8. Informar sucesso somente quando o registro da movimentação também for concluído.

### **2. Estruturas de decisão e classificação**

| Parágrafo  | Estrutura e condição                                                                | Classificação            | Consequência                                                                                 |
| ---------- | ----------------------------------------------------------------------------------- | ------------------------ | -------------------------------------------------------------------------------------------- |
| `UAD010`   | `IF SQLCODE NOT = 0`, após consulta da conta                                        | Negócio / infraestrutura | Impede o processamento quando a consulta não é bem-sucedida.                                 |
| `UAD010`   | `IF SQLCODE = +100`                                                                 | Negócio                  | Identifica conta não encontrada e retorna falha `1`.                                         |
| `UAD010`   | `ELSE` de `SQLCODE = +100`                                                          | Infraestrutura           | Retorna falha `2` para outros problemas na consulta.                                         |
| `UAD010`   | `IF COMM-AMT < 0`                                                                   | Negócio                  | Encaminha movimentações negativas às verificações específicas.                               |
| `UAD010`   | Conta `MORTGAGE` ou `LOAN`, com modalidade `496`, dentro do teste de valor negativo | Negócio                  | Rejeita a movimentação com falha `4`.                                                        |
| `UAD010`   | `IF WS-DIFFERENCE < 0 AND COMM-FACILTYPE = 496`                                     | Negócio                  | Rejeita movimentação negativa que deixaria o saldo disponível abaixo de zero, com falha `3`. |
| `UAD010`   | Conta `MORTGAGE` ou `LOAN`, com modalidade `496`, após o bloco de valores negativos | Negócio                  | Rejeita a movimentação com falha `4`.                                                        |
| `UAD010`   | `IF SQLCODE NOT = 0`, após atualização                                              | Infraestrutura           | Indica falha na atualização da conta e interrompe o processamento.                           |
| `WTPD010`  | `IF COMM-AMT < 0`                                                                   | Negócio                  | Classifica a movimentação como débito ou, no caminho alternativo, como crédito.              |
| `WTPD010`  | `IF COMM-FACILTYPE = 496`, dentro do débito                                         | Negócio                  | Classifica a movimentação como `PDR`, utilizando a origem informada como descrição.          |
| `WTPD010`  | `IF COMM-FACILTYPE = 496`, dentro do crédito                                        | Negócio                  | Classifica a movimentação como `PCR`, utilizando a origem informada como descrição.          |
| `WTPD010`  | `IF SQLCODE NOT = 0`, após inclusão da transação                                    | Infraestrutura           | Trata falha de gravação, tenta desfazer a atualização e retorna insucesso.                   |
| `WTPD010`  | `IF WS-CICS-RESP NOT = DFHRESP(NORMAL)`                                             | Infraestrutura           | Trata falha ao desfazer a transação.                                                         |
| `WTPD010`  | `ELSE` de `SQLCODE NOT = 0`                                                         | Negócio                  | Confirma o sucesso da operação após o registro da movimentação.                              |
| `CFSDD010` | `EVALUATE SQLCODE`, casos `923` e `OTHER`                                           | Infraestrutura           | Classifica uma falha de conexão com DB2 ou outra condição técnica.                           |
| `CFSDD010` | `IF STORM-DRAIN-CONDITION NOT EQUAL 'Not Storm Drain     '`                         | Infraestrutura           | Emite mensagem técnica para a condição identificada.                                         |
| `AH010`    | `EVALUATE MY-ABEND-CODE`, casos `AD2Z`, `AFCR`, `AFCS`, `AFCT`                      | Infraestrutura           | Trata tipos de encerramento anormal.                                                         |
| `AH010`    | `IF WS-CICS-RESP NOT = DFHRESP(NORMAL)`                                             | Infraestrutura           | Trata falha técnica no desfazimento de uma transação.                                        |
| `AH010`    | `IF WS-STORM-DRAIN = 'N'`                                                           | Infraestrutura           | Determina o encerramento anormal do programa.                                                |

Não foram identificadas estruturas de decisão classificadas como **interface**.

### **3. Condições e consequências de negócio**

As decisões de negócio concentram-se nos parágrafos `UAD010` e `WTPD010`.

Em `UAD010`, as decisões determinam se a conta existe e se a movimentação é permitida. A modalidade identificada pelo código `496` recebe tratamento específico: não permite movimentações em contas `MORTGAGE` ou `LOAN` e impede débitos que produziriam saldo disponível negativo.

Há duas ocorrências da restrição para contas `MORTGAGE` e `LOAN`: uma dentro do processamento de valores negativos e outra após esse processamento. Ambas devem ser documentadas separadamente, pois correspondem a decisões distintas no código.

Em `WTPD010`, as decisões classificam a movimentação pelo sinal do valor e pela modalidade. Para valores negativos, o tipo padrão é `DEB`, ou `PDR` quando a modalidade é `496`. Para valores não negativos, o tipo padrão é `CRE`, ou `PCR` quando a modalidade é `496`.

A modalidade `496` não tem seu significado de negócio explicitado no código. Por isso, deve ser identificada pelo próprio código, sem atribuição de uma denominação não comprovada.

O resultado de sucesso somente é confirmado depois da inclusão da movimentação em `PROCTRAN`. Os demais testes relativos a SQLCODE, rollback, ABEND e diagnósticos de sistema são tratados como infraestrutura, com exceção da identificação de conta inexistente e da confirmação funcional de conclusão da operação.

## **Regras de negócio**

1\. **Regra:** Uma movimentação não pode ser realizada quando a conta bancária informada não é encontrada.

**Condição:** Quando a consulta da conta pela agência e pelo número retorna ausência de registro (`SQLCODE = +100`).

**Consequência:** A movimentação é rejeitada, com indicação de insucesso e código de falha `1`.

**Parágrafo:** `UAD010`

2\. **Regra:** Movimentações com valor negativo estão sujeitas às restrições específicas de débito.

**Condição:** Quando o valor da movimentação é negativo (`COMM-AMT < 0`).

**Consequência:** São aplicadas as verificações de tipo de conta e de suficiência do saldo disponível antes de permitir a movimentação.

**Parágrafo:** `UAD010`

3\. **Regra:** Não são permitidos débitos da modalidade `496` em contas de financiamento imobiliário ou empréstimo.

**Condição:** Quando o valor é negativo, a modalidade é `496` (`COMM-FACILTYPE = 496`) e o tipo de conta é `MORTGAGE` ou `LOAN`.

**Consequência:** A movimentação é rejeitada, com indicação de insucesso e código de falha `4`.

**Parágrafo:** `UAD010`

4\. **Regra:** Débitos da modalidade `496` não podem deixar o saldo disponível da conta negativo.

**Condição:** Quando o valor da movimentação é negativo, a modalidade é `496` e a soma do saldo disponível com o valor da movimentação é inferior a zero (`WS-DIFFERENCE < 0`).

**Consequência:** A movimentação é rejeitada, com indicação de insucesso e código de falha `3`.

**Parágrafo:** `UAD010`

5\. **Regra:** Movimentações da modalidade `496` não são permitidas em contas de financiamento imobiliário ou empréstimo.

**Condição:** Quando a modalidade é `496` e o tipo de conta é `MORTGAGE` ou `LOAN`, na segunda verificação existente no programa, independentemente do sinal do valor.

**Consequência:** A movimentação é rejeitada, com indicação de insucesso e código de falha `4`.

**Parágrafo:** `UAD010`

6\. **Regra:** Movimentações negativas de modalidades diferentes de `496` são classificadas como retiradas no caixa.

**Condição:** Quando o valor da movimentação é negativo e a modalidade é diferente de `496`.

**Consequência:** A movimentação recebe o tipo `DEB` e a descrição `COUNTER WTHDRW`.

**Parágrafo:** `WTPD010`

7\. **Regra:** Movimentações negativas da modalidade `496` recebem classificação específica de débito.

**Condição:** Quando o valor da movimentação é negativo e a modalidade é `496`.

**Consequência:** A movimentação recebe o tipo `PDR` e utiliza os primeiros 14 caracteres da origem informada (`COMM-ORIGIN`) como descrição.

**Parágrafo:** `WTPD010`

8\. **Regra:** Movimentações com valor positivo ou igual a zero, de modalidades diferentes de `496`, são classificadas como recebimentos no caixa.

**Condição:** Quando o valor da movimentação é maior ou igual a zero e a modalidade é diferente de `496`.

**Consequência:** A movimentação recebe o tipo `CRE` e a descrição `COUNTER RECVED`.

**Parágrafo:** `WTPD010`

9\. **Regra:** Movimentações com valor positivo ou igual a zero da modalidade `496` recebem classificação específica de crédito.

**Condição:** Quando o valor da movimentação é maior ou igual a zero e a modalidade é `496`.

**Consequência:** A movimentação recebe o tipo `PCR` e utiliza os primeiros 14 caracteres da origem informada (`COMM-ORIGIN`) como descrição.

**Parágrafo:** `WTPD010`

10\. **Regra:** Uma movimentação é considerada concluída com sucesso somente após seu registro como transação processada.

**Condição:** Quando a inclusão da movimentação na tabela `PROCTRAN` é concluída com sucesso (`SQLCODE = 0`).

**Consequência:** A operação é confirmada como bem-sucedida (`COMM-SUCCESS = 'Y'`), com código de falha `0`.

**Parágrafo:** `WTPD010`