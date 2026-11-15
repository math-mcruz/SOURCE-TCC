## **Análise**

### **1. Parágrafos e fluxo principal do programa**

O programa COBOL `XFRFUN` realiza transferências de valores entre contas bancárias, atualizando os saldos da conta de origem e da conta de destino.

| Parágrafo ou seção                     | Finalidade                                                                                      |
| -------------------------------------- | ----------------------------------------------------------------------------------------------- |
| `PREMIERE / A010`                      | Verifica o valor da transferência e inicia o processamento.                                     |
| `UPDATE-ACCOUNT-DB2 / UAD010`          | Verifica se as contas são diferentes e coordena a transferência.                                |
| `UPDATE-ACCOUNT-DB2-FROM / UADF010`    | Consulta a conta de origem e, quando encontrada, debita o valor dos saldos disponível e real.   |
| `UPDATE-ACCOUNT-DB2-TO / UADT010`      | Consulta a conta de destino e, quando encontrada, credita o valor nos saldos disponível e real. |
| `WRITE-TO-PROCTRAN / WTP010`           | Aciona o registro da transferência processada.                                                  |
| `WRITE-TO-PROCTRAN-DB2 / WTPD010`      | Grava os dados da transferência na tabela `PROCTRAN`.                                           |
| `GET-ME-OUT-OF-HERE / GMOOH010`        | Encerra o processamento e retorna ao programa chamador.                                         |
| `CHECK-FOR-STORM-DRAIN-DB2 / CFSDD010` | Identifica condições técnicas de indisponibilidade do banco de dados.                           |
| `ABEND-HANDLING / AH010`               | Trata interrupções técnicas do processamento.                                                   |
| `POPULATE-TIME-DATE / PTD010`          | Obtém a data e a hora utilizadas pelo programa.                                                 |

**Fluxo principal:**

1. O programa recebe os dados da transferência, incluindo valor, conta de origem e conta de destino.
2. Verifica se o valor da transferência é maior que zero.
3. Verifica se a conta de origem é diferente da conta de destino.
4. Determina a sequência de atualização das contas por comparação dos números das contas, para controle técnico do processamento.
5. Consulta e atualiza a conta de origem, subtraindo o valor da transferência dos saldos disponível e real.
6. Consulta e atualiza a conta de destino, acrescentando o valor da transferência aos saldos disponível e real.
7. Quando as duas atualizações são concluídas, registra a transferência processada.
8. Indica sucesso e encerra o processamento.

A ordem das etapas 5 e 6 pode ser invertida conforme os números das contas. Se alguma das contas não for encontrada, o programa sinaliza a falha e executa o tratamento correspondente.

O programa não contém uma decisão que verifique se o saldo da conta de origem é suficiente para realizar a transferência. Também não há decisão que consulte o limite de cheque especial para autorizar ou impedir a operação.

### **2. Estruturas de decisão e classificação**

| Parágrafo  | Estrutura e condição                                                        | Classificação                   | Resultado                                                                                           |
| ---------- | --------------------------------------------------------------------------- | ------------------------------- | --------------------------------------------------------------------------------------------------- |
| `A010`     | `IF COMM-AMT <= ZERO`                                                       | Negócio                         | Rejeita valores de transferência iguais ou inferiores a zero, com código de falha 4.                |
| `UAD010`   | `IF COMM-FACCNO = COMM-TACCNO AND COMM-FSCODE = COMM-TSCODE`                | Negócio                         | Impede a transferência entre a mesma conta de origem e destino, interrompendo o processamento.      |
| `UAD010`   | `IF COMM-FACCNO < COMM-TACCNO`                                              | Infraestrutura                  | Determina a ordem técnica de atualização das contas.                                                |
| `UAD010`   | `IF COMM-SUCCESS = 'Y'` nas duas sequências                                 | Negócio — controle do resultado | Permite prosseguir para a atualização da outra conta quando a primeira foi atualizada com sucesso.  |
| `UAD010`   | `IF COMM-SUCCESS = 'N'` nas duas sequências                                 | Negócio — controle do resultado | Impede a conclusão normal da transferência quando uma atualização falha.                            |
| `UAD010`   | `IF COMM-FAIL-CODE = '1'`, `= '2'` ou `NOT = '1'/'2'`                       | Negócio e infraestrutura        | Distingue conta de origem não encontrada, conta de destino não encontrada e outras falhas técnicas. |
| `UAD010`   | `IF WS-CICS-RESP IS NOT EQUAL TO DFHRESP(NORMAL)`                           | Infraestrutura                  | Trata falhas técnicas de reversão de operações.                                                     |
| `UADF010`  | `IF SQLCODE NOT = 0`, seguido de `IF SQLCODE = +100`                        | Negócio e infraestrutura        | Distingue conta de origem não encontrada de erros técnicos de consulta.                             |
| `UADF010`  | `IF SQLCODE NOT = 0` após `UPDATE ACCOUNT`                                  | Infraestrutura                  | Trata falhas técnicas na atualização da conta de origem.                                            |
| `UADT010`  | `IF SQLCODE NOT = 0`, seguido de `IF SQLCODE = +100`                        | Negócio e infraestrutura        | Distingue conta de destino não encontrada de erros técnicos de consulta.                            |
| `UADT010`  | `IF SQLCODE = -911`, `IF SQLERRD(3) = ...` e `IF DB2-DEADLOCK-RETRY < 6`    | Infraestrutura                  | Identifica conflitos, tempos de espera e necessidade de novas tentativas de processamento.          |
| `UADT010`  | `IF WS-CICS-RESP IS NOT EQUAL TO DFHRESP(NORMAL)`                           | Infraestrutura                  | Trata falhas técnicas de reversão.                                                                  |
| `UADT010`  | `IF SQLCODE NOT = 0` após `UPDATE ACCOUNT`, com testes aninhados de retorno | Infraestrutura                  | Trata falhas de atualização, conflitos e tempos de espera.                                          |
| `WTPD010`  | `IF SQLCODE NOT = 0` após `INSERT INTO PROCTRAN`                            | Infraestrutura                  | Trata falha técnica na gravação da transferência processada.                                        |
| `CFSDD010` | `EVALUATE SQLCODE`, com `WHEN 923` e `WHEN OTHER`                           | Infraestrutura                  | Identifica perda de conexão com o banco de dados.                                                   |
| `CFSDD010` | `IF STORM-DRAIN-CONDITION NOT EQUAL ...`                                    | Infraestrutura                  | Identifica e informa uma condição técnica de indisponibilidade.                                     |
| `AH010`    | `EVALUATE MY-ABEND-CODE`                                                    | Infraestrutura                  | Diferencia tipos de interrupção técnica.                                                            |
| `AH010`    | `IF WS-CICS-RESP NOT = DFHRESP(NORMAL)`                                     | Infraestrutura                  | Trata falhas técnicas durante a reversão.                                                           |
| `AH010`    | `IF WS-STORM-DRAIN = 'N'`                                                   | Infraestrutura                  | Determina o tratamento de interrupções não classificadas como condição de indisponibilidade.        |

Não foram identificadas decisões de interface relativas à navegação de telas ou teclas de função.

### **3. Condições e consequências das decisões de negócio**

**Valor da transferência —&#x20;**`A010`

- Condição: o valor informado é igual ou inferior a zero (`COMM-AMT <= ZERO`).
- Consequência: a transferência é rejeitada, com indicação de insucesso e código de falha `4`, sem iniciar a atualização das contas.

**Transferência para a mesma conta —&#x20;**`UAD010`

- Condição: o número e o código bancário da conta de origem são iguais aos da conta de destino.
- Consequência: a transferência não é executada. O programa aciona uma interrupção identificada pelo código `SAME`, em vez de retornar normalmente uma rejeição de negócio.

**Conta de origem não encontrada —&#x20;**`UADF010`

- Condição: a consulta da conta de origem retorna `SQLCODE = +100`.
- Consequência: a transferência não é concluída, sendo informado o código de falha `1`. Se a conta de destino já tiver sido atualizada, o fluxo de tratamento prevê a reversão dessa atualização.

**Conta de destino não encontrada —&#x20;**`UADT010`

- Condição: a consulta da conta de destino retorna `SQLCODE = +100`.
- Consequência: a transferência não é concluída, sendo informado o código de falha `2`. O programa executa uma reversão para evitar que uma atualização anterior seja mantida isoladamente.

**Continuidade e conclusão da transferência —&#x20;**`UAD010`**,&#x20;**`UADF010`**&#x20;e&#x20;**`UADT010`

- Condição: a primeira atualização foi bem-sucedida (`COMM-SUCCESS = 'Y'`).
- Consequência: o programa prossegue com a atualização da outra conta.
- Condição: alguma das atualizações retorna insucesso (`COMM-SUCCESS = 'N'`).
- Consequência: o programa não segue pelo fluxo normal de conclusão da transferência.
- Condição: ambas as contas são encontradas e suas atualizações são concluídas sem falhas.
- Consequência: o programa registra a transferência e indica sucesso (`COMM-SUCCESS = 'Y'`).

Os saldos disponível e real são debitados ou creditados por operações diretas de cálculo, sem decisões específicas sobre seus valores. Portanto, essas operações descrevem o funcionamento da transferência, mas não constituem regras independentes segundo o critério de escopo solicitado.

### **4. Decisões excluídas das regras de negócio**

As seguintes estruturas não geram itens na lista final:

- A comparação dos números das contas para determinar a ordem de atualização, por representar controle técnico.
- Os tratamentos de falhas SQL diferentes de conta não encontrada.
- As verificações de `ROLLBACK`, `SYNCPOINT`, conflitos de banco de dados e novas tentativas.
- Os testes de perda de conexão e interrupções CICS.
- O tratamento de falhas na gravação da tabela `PROCTRAN`.
- A preparação de dados, os cálculos de saldo e a gravação de informações sem uma decisão própria associada.
- A geração de mensagens técnicas, informações de diagnóstico e registros de erro.

## **Regras de negócio**

1\. Regra: Uma transferência bancária não pode ser realizada com valor igual ou inferior a zero.

- Condição: O valor informado para a transferência (`COMM-AMT`) é menor ou igual a zero.
- Consequência: A transferência é rejeitada, com indicação de insucesso (`COMM-SUCCESS = 'N'`) e código de falha `4`, sem atualização das contas.
- Parágrafo: `A010`

2\. Regra: Uma transferência bancária não pode ter a mesma conta como origem e destino.

- Condição: O número da conta de origem e o número da conta de destino são iguais, assim como seus respectivos códigos bancários (`COMM-FACCNO = COMM-TACCNO` e `COMM-FSCODE = COMM-TSCODE`).
- Consequência: A transferência é impedida e o processamento é interrompido com o código `SAME`.
- Parágrafo: `UAD010`

3\. Regra: Uma transferência somente pode prosseguir quando a atualização da primeira conta envolvida for concluída com sucesso.

- Condição: A primeira conta processada é atualizada com sucesso (`COMM-SUCCESS = 'Y'`), independentemente de ser a conta de origem ou de destino.
- Consequência: O programa prossegue com a atualização da outra conta envolvida na transferência.
- Parágrafo: `UAD010`

4\. Regra: Uma transferência não pode ser concluída quando a conta de origem não é encontrada.

- Condição: A consulta da conta de origem não encontra a conta informada (`SQLCODE = +100`).
- Consequência: A transferência é sinalizada como malsucedida (`COMM-SUCCESS = 'N'`), com código de falha `1`, e não é concluída.
- Parágrafo: `UADF010`

5\. Regra: Uma transferência não pode ser concluída quando a conta de destino não é encontrada.

- Condição: A consulta da conta de destino não encontra a conta informada (`SQLCODE = +100`).
- Consequência: A transferência é sinalizada como malsucedida (`COMM-SUCCESS = 'N'`), com código de falha `2`, e não é concluída.
- Parágrafo: `UADT010`