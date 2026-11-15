## **Análise**

### **1. Parágrafos e fluxo principal do programa**

O programa **XFRFUN** realiza transferências de valores entre contas bancárias, alterando os saldos disponíveis e efetivos das contas de origem e destino.

| Seção / Parágrafo                      | Responsabilidade                                                                                                          |
| -------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| `PREMIERE / A010`                      | Inicializa o processamento, verifica o valor da transferência e inicia a atualização das contas.                          |
| `UPDATE-ACCOUNT-DB2 / UAD010`          | Verifica se a transferência ocorre entre contas diferentes, coordena as atualizações e determina o resultado da operação. |
| `UPDATE-ACCOUNT-DB2-FROM / UADF010`    | Localiza a conta de origem e debita o valor da transferência dos saldos disponível e efetivo.                             |
| `UPDATE-ACCOUNT-DB2-TO / UADT010`      | Localiza a conta de destino e credita o valor da transferência nos saldos disponível e efetivo.                           |
| `WRITE-TO-PROCTRAN / WTP010`           | Aciona o registro da transação processada.                                                                                |
| `WRITE-TO-PROCTRAN-DB2 / WTPD010`      | Registra a transferência na tabela PROCTRAN.                                                                              |
| `GET-ME-OUT-OF-HERE / GMOOH010`        | Encerra o processamento.                                                                                                  |
| `CHECK-FOR-STORM-DRAIN-DB2 / CFSDD010` | Identifica condições técnicas de indisponibilidade do banco de dados.                                                     |
| `ABEND-HANDLING / AH010`               | Trata interrupções e falhas técnicas.                                                                                     |
| `POPULATE-TIME-DATE / PTD010`          | Obtém informações de data e hora.                                                                                         |

### **2. Estruturas de decisão e classificação**

| Parágrafo  | Estrutura e condição                                                  | Classificação                | Condição e consequência                                                                                                                             |
| ---------- | --------------------------------------------------------------------- | ---------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| `A010`     | `IF COMM-AMT <= ZERO`                                                 | **Negócio**                  | Se o valor da transferência for menor ou igual a zero, a operação é recusada com código de falha 4.                                                 |
| `UAD010`   | `IF COMM-FACCNO = COMM-TACCNO AND COMM-FSCODE = COMM-TSCODE`          | **Negócio**                  | Se origem e destino forem a mesma conta, a transferência é impedida. O programa provoca uma interrupção com código SAME.                            |
| `UAD010`   | `IF COMM-FACCNO < COMM-TACCNO`                                        | Infraestrutura               | Define a ordem técnica de atualização das contas conforme os números das contas.                                                                    |
| `UAD010`   | `IF COMM-SUCCESS = 'Y'` após atualização da primeira conta            | **Negócio**                  | Se a primeira conta for processada com sucesso, o programa prossegue com a segunda conta.                                                           |
| `UAD010`   | `IF COMM-SUCCESS = 'N'` após atualização da segunda conta             | **Negócio**                  | Se o processamento da segunda conta falhar, o programa avalia o motivo e impede a conclusão normal da transferência nos caminhos de falha tratados. |
| `UAD010`   | `IF COMM-FAIL-CODE = '1'` ou `= '2'`, incluindo as condições inversas | Infraestrutura               | Distingue falhas de localização de contas de outras falhas para determinar o tratamento técnico da operação.                                        |
| `UAD010`   | `IF WS-CICS-RESP NOT = DFHRESP(NORMAL)`                               | Infraestrutura               | Trata falhas na reversão técnica da operação.                                                                                                       |
| `UADF010`  | `IF SQLCODE NOT = 0`                                                  | **Negócio / infraestrutura** | Distingue a impossibilidade de localizar a conta de origem de falhas técnicas de acesso aos dados.                                                  |
| `UADF010`  | `IF SQLCODE = +100`                                                   | **Negócio**                  | Se a conta de origem não for encontrada, a operação é marcada como malsucedida, com código de falha 1.                                              |
| `UADF010`  | `IF SQLCODE NOT = 0` após UPDATE                                      | Infraestrutura               | Trata falha técnica na atualização da conta de origem.                                                                                              |
| `UADT010`  | `IF SQLCODE NOT = 0` após SELECT                                      | **Negócio / infraestrutura** | Distingue a ausência da conta de destino das falhas técnicas na consulta.                                                                           |
| `UADT010`  | `IF SQLCODE = +100`                                                   | **Negócio**                  | Se a conta de destino não for encontrada, a operação é marcada como malsucedida, com código de falha 2.                                             |
| `UADT010`  | `IF WS-CICS-RESP NOT = DFHRESP(NORMAL)`                               | Infraestrutura               | Trata falhas técnicas na reversão da operação.                                                                                                      |
| `UADT010`  | `IF SQLCODE = -911`                                                   | Infraestrutura               | Identifica condições técnicas relacionadas ao acesso concorrente aos dados.                                                                         |
| `UADT010`  | `IF SQLERRD(3) = 13172872`                                            | Infraestrutura               | Identifica situações específicas de conflito técnico.                                                                                               |
| `UADT010`  | `IF DB2-DEADLOCK-RETRY < 6`                                           | Infraestrutura               | Controla novas tentativas de processamento diante de conflitos técnicos.                                                                            |
| `UADT010`  | `IF SQLERRD(3) = 13172894`                                            | Infraestrutura               | Identifica uma condição técnica de timeout.                                                                                                         |
| `UADT010`  | `IF SQLCODE NOT = 0` após UPDATE                                      | Infraestrutura               | Trata falhas na atualização da conta de destino.                                                                                                    |
| `WTPD010`  | `IF SQLCODE NOT = 0`                                                  | Infraestrutura               | Trata falha técnica no registro da transferência processada.                                                                                        |
| `CFSDD010` | `EVALUATE SQLCODE`, valores 923 e OTHER                               | Infraestrutura               | Classifica uma condição de perda de conexão com o banco de dados.                                                                                   |
| `CFSDD010` | `IF STORM-DRAIN-CONDITION NOT EQUAL 'Not Storm Drain     '`           | Infraestrutura               | Determina a emissão de informações sobre uma condição técnica de indisponibilidade.                                                                 |
| `AH010`    | `EVALUATE MY-ABEND-CODE`, valores AD2Z, AFCR, AFCS e AFCT             | Infraestrutura               | Diferencia tipos de interrupções técnicas.                                                                                                          |
| `AH010`    | `IF WS-CICS-RESP NOT = DFHRESP(NORMAL)`                               | Infraestrutura               | Trata falha técnica na reversão de uma operação interrompida.                                                                                       |
| `AH010`    | `IF WS-STORM-DRAIN = 'N'`                                             | Infraestrutura               | Determina o tratamento de interrupções não classificadas como indisponibilidade especial.                                                           |

As demais verificações de retorno CICS e DB2, inclusive as repetidas dentro de tratamentos de falha, são classificadas como infraestrutura. Não foram identificadas decisões de interface.

### **3. Condições e consequências de negócio**

O código implementa as seguintes decisões relevantes para a área de negócio:

- **Valor da transferência:** valores menores ou iguais a zero são recusados.
- **Identidade das contas:** transferências para a própria conta de origem são impedidas.
- **Conta de origem:** a inexistência da conta impede que o processamento da transferência prossiga normalmente.
- **Conta de destino:** a inexistência da conta impede que o processamento da transferência prossiga normalmente.
- **Conclusão da transferência:** quando as duas contas são processadas com sucesso, o programa registra a transferência e informa sucesso.

As duas últimas verificações de existência de conta são realizadas em parágrafos distintos. Cada uma produz seu próprio código de falha, independentemente da ordem técnica escolhida para atualizar as contas.

O programa não apresenta uma decisão que verifique saldo suficiente, limite de cheque especial, tipo de conta permitido ou limite máximo de transferência. Portanto, esses comportamentos não são considerados regras implementadas.

A alteração dos saldos disponível e efetivo é feita por cálculos diretos, sem decisões condicionais próprias. O registro da transferência também não possui uma condição de negócio específica, além do caminho que permite chegar à sua execução.

## **Regras de negócio**

1\. **Regra:** Uma transferência bancária deve possuir valor maior que zero.

**Condição:** Quando o valor informado para a transferência for menor ou igual a zero (`COMM-AMT <= ZERO`).

**Consequência:** A transferência é recusada, com indicador de insucesso e código de falha 4.

**Parágrafo:** `A010`

2\. **Regra:** Não é permitido realizar uma transferência bancária de uma conta para ela mesma.

**Condição:** Quando a conta de origem e a conta de destino possuírem o mesmo número e o mesmo código bancário (`COMM-FACCNO = COMM-TACCNO` e `COMM-FSCODE = COMM-TSCODE`), após a validação do valor da transferência.

**Consequência:** A transferência é impedida e o processamento é interrompido com a identificação SAME.

**Parágrafo:** `UAD010`

3\. **Regra:** A conta de origem de uma transferência bancária deve existir.

**Condição:** Quando a conta de origem não for localizada no cadastro de contas (`SQLCODE = +100`), durante o processamento de uma transferência com valor positivo entre contas distintas.

**Consequência:** O processamento da conta de origem é marcado como malsucedido, com código de falha 1, impedindo a conclusão normal da transferência.

**Parágrafo:** `UADF010`

4\. **Regra:** A conta de destino de uma transferência bancária deve existir.

**Condição:** Quando a conta de destino não for localizada no cadastro de contas (`SQLCODE = +100`), durante o processamento de uma transferência com valor positivo entre contas distintas.

**Consequência:** O processamento da conta de destino é marcado como malsucedido, com código de falha 2, impedindo a conclusão normal da transferência.

**Parágrafo:** `UADT010`

5\. **Regra:** Uma transferência bancária somente pode prosseguir para o processamento da segunda conta quando a primeira conta tiver sido processada com sucesso.

**Condição:** Quando a primeira conta processada tiver sua atualização concluída com sucesso (`COMM-SUCCESS = 'Y'`), seja ela a conta de origem ou a de destino.

**Consequência:** O programa prossegue com o processamento da outra conta envolvida na transferência.

**Parágrafo:** `UAD010`

6\. **Regra:** Uma transferência bancária é considerada concluída quando o processamento das duas contas envolvidas é bem-sucedido.

**Condição:** Quando as atualizações das contas de origem e destino forem concluídas com sucesso, independentemente da ordem em que forem processadas.

**Consequência:** O programa prossegue com o registro da transferência e informa sucesso na operação (`COMM-SUCCESS = 'Y'`).

**Parágrafo:** `UAD010`