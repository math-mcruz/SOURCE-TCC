## **Análise**

### **1. Parágrafos e fluxo principal do programa**

O programa COBOL `XFRFUN` implementa transferências de valores entre contas bancárias, utilizando informações de origem, destino e valor recebidas de outro programa.

O fluxo principal é:

| Seção / Parágrafo                      | Responsabilidade                                                                                                          |
| -------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| `PREMIERE / A010`                      | Verifica se o valor da transferência é positivo e inicia o processamento.                                                 |
| `UPDATE-ACCOUNT-DB2 / UAD010`          | Impede transferências para a mesma conta, coordena as operações nas duas contas e determina o resultado da transferência. |
| `UPDATE-ACCOUNT-DB2-FROM / UADF010`    | Consulta a conta de origem e, quando encontrada, subtrai o valor da transferência dos saldos disponível e atual.          |
| `UPDATE-ACCOUNT-DB2-TO / UADT010`      | Consulta a conta de destino e, quando encontrada, acrescenta o valor da transferência aos saldos disponível e atual.      |
| `WRITE-TO-PROCTRAN / WTP010`           | Aciona o registro da transferência processada.                                                                            |
| `WRITE-TO-PROCTRAN-DB2 / WTPD010`      | Grava as informações da transferência na tabela `PROCTRAN`.                                                               |
| `GET-ME-OUT-OF-HERE / GMOOH010`        | Encerra a execução do programa.                                                                                           |
| `CHECK-FOR-STORM-DRAIN-DB2 / CFSDD010` | Identifica uma condição técnica de indisponibilidade da conexão com o banco de dados.                                     |
| `ABEND-HANDLING / AH010`               | Trata interrupções e falhas técnicas.                                                                                     |
| `POPULATE-TIME-DATE / PTD010`          | Obtém a data e a hora utilizadas pelo programa.                                                                           |

O programa atribui o mesmo código bancário (`SORTCODE`) às contas de origem e destino antes de processar a transferência. Não há, entretanto, uma decisão específica que valide essa igualdade.

A operação utiliza os números das contas para determinar a ordem de processamento. Essa ordenação é técnica e não constitui uma regra de negócio independente.

### **2. Estruturas de decisão e classificação**

#### **2.1. Decisões de negócio**

| Parágrafo | Estrutura e condição                                                                   | Consequência                                                                                                           |
| --------- | -------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| `A010`    | `IF COMM-AMT <= ZERO`                                                                  | Recusa a transferência e retorna falha de código `4`.                                                                  |
| `UAD010`  | `IF COMM-FACCNO = COMM-TACCNO AND COMM-FSCODE = COMM-TSCODE`                           | Impede a transferência para a mesma conta, provocando a interrupção do programa.                                       |
| `UADF010` | `IF SQLCODE NOT = 0` e `IF SQLCODE = +100`                                             | Quando a conta de origem não é encontrada, retorna falha de código `1`.                                                |
| `UADF010` | Caminho de consulta bem-sucedida (`SQLCODE = 0`)                                       | Subtrai o valor transferido dos saldos disponível e atual da conta de origem.                                          |
| `UADT010` | `IF SQLCODE NOT = 0` e `IF SQLCODE = +100`                                             | Quando a conta de destino não é encontrada, retorna falha de código `2` e interrompe o processamento da transferência. |
| `UADT010` | Caminho de consulta bem-sucedida (`SQLCODE = 0`)                                       | Acrescenta o valor transferido aos saldos disponível e atual da conta de destino.                                      |
| `UAD010`  | Caminhos condicionados a `COMM-SUCCESS = 'Y'`, com êxito das operações nas duas contas | Prossegue até o registro da transferência e sinaliza a operação como bem-sucedida.                                     |

As alterações dos saldos são consequências dos caminhos de decisão associados à localização das contas. Não são criadas regras separadas para cada campo de saldo.

#### **2.2. Decisões de infraestrutura**

| Parágrafo  | Estruturas                                                     | Classificação e finalidade                                                                        |
| ---------- | -------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| `UAD010`   | `IF COMM-FACCNO < COMM-TACCNO`                                 | Infraestrutura: determina a ordem de processamento das contas.                                    |
| `UAD010`   | Testes de `COMM-SUCCESS` e `COMM-FAIL-CODE`                    | Infraestrutura, nos caminhos que apenas determinam rollback, interrupção ou continuidade técnica. |
| `UAD010`   | Testes de `WS-CICS-RESP`                                       | Infraestrutura: verificam o resultado de operações de rollback.                                   |
| `UADF010`  | `SQLCODE NOT = 0`, exceto a identificação de conta inexistente | Infraestrutura: identifica falhas de consulta ou atualização.                                     |
| `UADT010`  | `SQLCODE NOT = 0`, exceto a identificação de conta inexistente | Infraestrutura: identifica falhas de consulta ou atualização.                                     |
| `UADT010`  | `SQLCODE = -911`                                               | Infraestrutura: trata problemas de acesso concorrente ao banco de dados.                          |
| `UADT010`  | Testes de `SQLERRD(3)`                                         | Infraestrutura: diferenciam condições técnicas como deadlock e timeout.                           |
| `UADT010`  | `DB2-DEADLOCK-RETRY < 6`                                       | Infraestrutura: limita as tentativas de recuperação de deadlock.                                  |
| `UADT010`  | Testes de `WS-CICS-RESP`                                       | Infraestrutura: verificam falhas em operações de rollback.                                        |
| `WTPD010`  | `IF SQLCODE NOT = 0`                                           | Infraestrutura: verifica falha na gravação do registro da transferência.                          |
| `CFSDD010` | `EVALUATE SQLCODE`, com `WHEN 923` e `WHEN OTHER`              | Infraestrutura: classifica a condição de conexão com o banco de dados.                            |
| `CFSDD010` | `IF STORM-DRAIN-CONDITION NOT EQUAL 'Not Storm Drain'`         | Infraestrutura: identifica a necessidade de emitir diagnóstico técnico.                           |
| `AH010`    | `EVALUATE MY-ABEND-CODE`                                       | Infraestrutura: diferencia códigos de interrupção técnica.                                        |
| `AH010`    | `IF WS-CICS-RESP NOT = DFHRESP(NORMAL)`                        | Infraestrutura: verifica falha no rollback.                                                       |
| `AH010`    | `IF WS-STORM-DRAIN = 'N'`                                      | Infraestrutura: determina o tratamento da interrupção.                                            |

As verificações de falhas técnicas não são convertidas em regras de negócio. A inexistência de contas, porém, é considerada uma condição de negócio, pois determina se a transferência pode ser realizada.

#### **2.3. Decisões de interface**

Não foram identificadas decisões relacionadas à navegação de telas, teclas de função ou validação de formato dos dados digitados.

Os comandos `DISPLAY` presentes no programa fornecem mensagens de diagnóstico técnico, e não implementam regras de interface para o cliente bancário.

### **3. Delimitações da análise**

O programa não implementa decisões específicas para verificar saldo suficiente, respeitar limite de cheque especial, conferir titularidade das contas ou estabelecer um valor máximo de transferência. Portanto, essas regras não são incluídas.

O registro na tabela `PROCTRAN` também não gera uma regra independente, pois sua gravação não está condicionada a uma decisão de negócio própria. A transferência bem-sucedida é considerada no caminho de decisão que conduz ao registro e à sinalização de sucesso.

## **Regras de negócio**

1\. **Regra:** Uma transferência bancária somente pode ser processada quando seu valor for maior que zero.

- **Condição:** Quando o valor informado para transferência (`COMM-AMT`) for menor ou igual a zero.
- **Consequência:** A transferência é recusada, o resultado é definido como insucesso (`COMM-SUCCESS = 'N'`) e é retornado o código de falha `4`.
- **Parágrafo:** `A010`

2\. **Regra:** Não é permitido transferir valores de uma conta bancária para ela mesma.

- **Condição:** Quando o número e o código bancário da conta de origem forem iguais aos da conta de destino (`COMM-FACCNO = COMM-TACCNO` e `COMM-FSCODE = COMM-TSCODE`).
- **Consequência:** A transferência não é realizada e o programa é interrompido com a identificação `SAME`. O código utiliza uma interrupção do programa, em vez de retornar normalmente uma rejeição de negócio.
- **Parágrafo:** `UAD010`

3\. **Regra:** Uma transferência não pode prosseguir quando a conta bancária de origem não for encontrada.

- **Condição:** Quando a consulta da conta de origem retornar ausência de registro (`SQLCODE = +100`).
- **Consequência:** O processamento da conta de origem é encerrado sem realizar o débito, o resultado é definido como insucesso e é retornado o código de falha `1`.
- **Parágrafo:** `UADF010`

4\. **Regra:** O valor de uma transferência deve ser debitado dos saldos disponível e atual da conta de origem.

- **Condição:** Quando a conta de origem for encontrada com sucesso (`SQLCODE = 0` na consulta).
- **Consequência:** O valor da transferência (`COMM-AMT`) é subtraído dos saldos disponível (`ACCOUNT_AVAILABLE_BALANCE`) e atual (`ACCOUNT_ACTUAL_BALANCE`) da conta de origem, e os novos valores são encaminhados para atualização.
- **Parágrafo:** `UADF010`

5\. **Regra:** Uma transferência não pode prosseguir quando a conta bancária de destino não for encontrada.

- **Condição:** Quando a consulta da conta de destino retornar ausência de registro (`SQLCODE = +100`).
- **Consequência:** O crédito não é realizado, o resultado é definido como insucesso, o código de falha `2` é atribuído e o processamento da transferência é interrompido, com solicitação de reversão das alterações.
- **Parágrafo:** `UADT010`

6\. **Regra:** O valor de uma transferência deve ser creditado nos saldos disponível e atual da conta de destino.

- **Condição:** Quando a conta de destino for encontrada com sucesso (`SQLCODE = 0` na consulta).
- **Consequência:** O valor da transferência (`COMM-AMT`) é acrescentado aos saldos disponível (`ACCOUNT_AVAILABLE_BALANCE`) e atual (`ACCOUNT_ACTUAL_BALANCE`) da conta de destino, e os novos valores são encaminhados para atualização.
- **Parágrafo:** `UADT010`

7\. **Regra:** Uma transferência bancária somente é sinalizada como bem-sucedida após o processamento bem-sucedido das duas contas envolvidas.

- **Condição:** Quando as operações sobre as contas de origem e destino forem concluídas com sucesso (`COMM-SUCCESS = 'Y'` nos caminhos de processamento das contas), independentemente da ordem em que forem executadas.
- **Consequência:** O programa prossegue para o registro da transferência processada e sinaliza o resultado final como sucesso (`COMM-SUCCESS = 'Y'`).
- **Parágrafo:** `UAD010`