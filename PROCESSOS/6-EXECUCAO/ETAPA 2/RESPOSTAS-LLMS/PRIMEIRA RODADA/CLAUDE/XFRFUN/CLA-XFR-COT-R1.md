## Análise

**1. Parágrafos e fluxo principal**

| Seção | Função |
|---|---|
| PREMIERE (A010) | Entrada. Define o handler de abend, carrega o código da agência (sortcode) nos campos de origem e destino, valida o valor e chama a atualização das contas. |
| UPDATE-ACCOUNT-DB2 (UAD010) | Orquestra a transferência. Recusa origem igual a destino, escolhe a ordem de atualização das contas e trata o resultado de cada uma. |
| UPDATE-ACCOUNT-DB2-FROM (UADF010) | Lê a conta de origem e debita o saldo disponível e o saldo atual. |
| UPDATE-ACCOUNT-DB2-TO (UADT010) | Lê a conta de destino e credita os dois saldos. |
| WRITE-TO-PROCTRAN / WRITE-TO-PROCTRAN-DB2 | Grava o registro da transação (PROCTRAN). |
| GET-ME-OUT-OF-HERE | Devolve o controle ao chamador. |
| CHECK-FOR-STORM-DRAIN-DB2, ABEND-HANDLING, POPULATE-TIME-DATE | Apoio técnico (diagnóstico, tratamento de abend e data/hora). |

Fluxo principal: A010 valida o valor, e UAD010 testa se as contas são iguais. O programa debita a origem e credita o destino (ou o contrário, conforme qual número de conta é menor), grava o PROCTRAN e marca sucesso ('Y').

Observação de fidelidade: o programa não verifica saldo suficiente nem limite de cheque especial na origem. O débito é feito sem teste.

**2 e 3. Estruturas de decisão e classificação**

| Local | Decisão | Classificação |
|---|---|---|
| A010 | `COMM-AMT <= ZERO` | Negócio |
| UAD010 | Conta de origem = conta de destino (e agência igual) | Negócio |
| UAD010 | `COMM-FACCNO < COMM-TACCNO` (define a ordem dos updates) | Infraestrutura (ordem técnica de atualização, concorrência) |
| UAD010 | `COMM-SUCCESS = 'Y'/'N'` após cada update | Intermediário (leva a outro teste) |
| UAD010 | `COMM-FAIL-CODE = '1'` ou `'2'` (conta não encontrada) | Negócio |
| UAD010 | `COMM-FAIL-CODE` diferente de '1' ou '2' → abend FROM/TO | Infraestrutura |
| UAD010, UADT010, ABEND-HANDLING | `WS-CICS-RESP` diferente de NORMAL após ROLLBACK | Infraestrutura |
| UADF010 | `SQLCODE NOT = 0`, depois `SQLCODE = +100` | Negócio (+100 = conta não encontrada); demais códigos (fail code '3') são infraestrutura |
| UADF010 | `SQLCODE NOT = 0` após o UPDATE | Infraestrutura |
| UADT010 | `SQLCODE NOT = 0`, depois `SQLCODE = +100` | Negócio (conta de destino não encontrada); demais são infraestrutura |
| UADT010 | `SQLCODE = -911`, `SQLERRD(3)`, `DB2-DEADLOCK-RETRY < 6` (deadlock/timeout, nova tentativa) | Infraestrutura |
| UADT010 | `SQLCODE NOT = 0` após o UPDATE | Infraestrutura |
| WRITE-TO-PROCTRAN-DB2 | `SQLCODE NOT = 0` no INSERT | Infraestrutura (gravação de registro técnico/auditoria) |
| CHECK-FOR-STORM-DRAIN-DB2 | EVALUATE SQLCODE 923 e IF da condição | Infraestrutura |
| ABEND-HANDLING | EVALUATE do código de abend (AD2Z, AFCR/AFCS/AFCT), IF `WS-STORM-DRAIN` | Infraestrutura |

**4. Condição e consequência das estruturas de negócio**

- **A010:** se o valor for zero ou negativo, a transferência é recusada com falha código '4' e nada é atualizado.
- **UAD010, mesma conta:** se origem e destino forem a mesma conta, a transferência é recusada com encerramento anormal (abend 'SAME'). Como as duas agências recebem o mesmo sortcode em A010, na prática só o número da conta decide.
- **UADF010, SQLCODE +100:** conta de origem inexistente gera falha código '1'.
- **UADT010, SQLCODE +100:** conta de destino inexistente gera falha código '2' e rollback. O resultado ('2') é testado de novo em UAD010, que faz outro rollback.
- **UAD010, falha código '1' ou '2':**
  - Um código '1' ou '2' devolvido por UADF010 ou UADT010 leva a rollback e fim, sem gravar o PROCTRAN e sem marcar sucesso.
  - O teste aparece em quatro pontos, um para cada combinação de ordem (origem primeiro ou destino primeiro) e conta ausente.

## Regras de negócio

1. Regra: O valor da transferência deve ser maior que zero (COMM-AMT).
   Condição: O valor informado é menor ou igual a zero.
   Consequência: A transferência é recusada com indicador de falha e código de falha '4'. Nenhuma conta é atualizada.
   Parágrafo: PREMIERE (A010)

2. Regra: Não é permitido transferir de uma conta para ela mesma.
   Condição: A conta de origem é igual à conta de destino (número da conta e código da agência iguais).
   Consequência: A transferência é recusada, e a transação é encerrada de forma anormal (abend 'SAME') em vez de devolver um código de falha ao chamador.
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)

3. Regra: A transferência não ocorre se a conta de origem não existir.
   Condição: A leitura da conta de origem não a encontra (SQLCODE = +100).
   Consequência: O indicador de sucesso fica 'N' com código de falha '1'. A conta de origem não é debitada.
   Parágrafo: UPDATE-ACCOUNT-DB2-FROM (UADF010)

4. Regra: A transferência não ocorre se a conta de destino não existir.
   Condição: A leitura da conta de destino não a encontra (SQLCODE = +100).
   Consequência: O indicador de sucesso fica 'N' com código de falha '2', e as alterações pendentes são desfeitas (rollback) para evitar inconsistência.
   Parágrafo: UPDATE-ACCOUNT-DB2-TO (UADT010)

5. Regra: Quando a origem é atualizada primeiro (conta de origem menor que a de destino) e a conta de origem não existe, a transferência é encerrada sem efeito.
   Condição: A atualização da origem falha com código de falha '1' (conta não encontrada).
   Consequência: Fazem-se rollback e saída sem gravar o registro de transferência. O indicador de sucesso permanece 'N'.
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)

6. Regra: Quando a origem é atualizada primeiro e a conta de destino não existe, o débito já feito na origem é desfeito.
   Condição: A origem foi atualizada com sucesso e a atualização do destino falha com código de falha '2' (conta não encontrada).
   Consequência: Faz-se rollback, desfazendo o débito da origem. A transferência termina sem sucesso e sem registro de transferência.
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)

7. Regra: Quando o destino é atualizado primeiro (conta de origem maior ou igual à de destino) e a conta de destino não existe, a transferência é encerrada sem efeito.
   Condição: A atualização do destino falha com código de falha '2' (conta não encontrada).
   Consequência: Fazem-se rollback e saída sem gravar o registro de transferência. O indicador de sucesso permanece 'N'.
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)

8. Regra: Quando o destino é atualizado primeiro e a conta de origem não existe, o crédito já feito no destino é desfeito.
   Condição: O destino foi atualizado com sucesso e a atualização da origem falha com código de falha '1' (conta não encontrada).
   Consequência: Faz-se rollback, desfazendo o crédito do destino. A transferência termina sem sucesso e sem registro de transferência.
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)