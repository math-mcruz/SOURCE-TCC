## Análise

**1. Parágrafos e fluxo principal**

O programa XFRFUN (CICS + DB2) transfere um valor entre duas contas. O fluxo é:

- **PREMIERE (A010)**: define o handler de abend, carrega o código do banco (SORTCODE) nas duas contas, valida o valor e chama UPDATE-ACCOUNT-DB2.
- **UPDATE-ACCOUNT-DB2 (UAD010)**: verifica se origem e destino são a mesma conta. Em seguida decide a ordem de atualização (menor número de conta primeiro) e chama UPDATE-ACCOUNT-DB2-FROM e UPDATE-ACCOUNT-DB2-TO. Se tudo correr bem, chama WRITE-TO-PROCTRAN e devolve sucesso ('Y').
- **UPDATE-ACCOUNT-DB2-FROM (UADF010)**: lê a conta de origem, subtrai o valor dos saldos disponível e real e grava.
- **UPDATE-ACCOUNT-DB2-TO (UADT010)**: lê a conta de destino, soma o valor aos saldos e grava.
- **WRITE-TO-PROCTRAN / WRITE-TO-PROCTRAN-DB2**: grava o registro da transação (tipo transferência).
- **GET-ME-OUT-OF-HERE**: devolve o controle ao chamador.
- **CHECK-FOR-STORM-DRAIN-DB2, ABEND-HANDLING, POPULATE-TIME-DATE**: rotinas técnicas.

O programa não confere saldo suficiente nem limite de cheque especial na conta de origem. O débito é feito sem esse teste.

**2. Estruturas de decisão e 3. classificação**

| Local | Estrutura | Classificação |
|---|---|---|
| A010 | IF COMM-AMT <= ZERO | Negócio |
| UAD010 | IF origem = destino (conta e sortcode) | Negócio |
| UAD010 | IF COMM-FACCNO < COMM-TACCNO (ordem de atualização) | Infraestrutura (ordem técnica) |
| UAD010 | IF COMM-SUCCESS = 'Y' / 'N' após cada etapa | Intermediário, só leva a outro teste |
| UAD010 | IF COMM-FAIL-CODE = '1' ou '2' (conta não encontrada) | Negócio |
| UAD010 | IF COMM-FAIL-CODE NOT = '1' ou '2' (abend FROM/TO) | Infraestrutura |
| UAD010 e demais | IF WS-CICS-RESP NOT = NORMAL (falha no rollback) | Infraestrutura |
| UADF010 | IF SQLCODE NOT = 0, com SQLCODE = +100 | Negócio (conta de origem inexistente) |
| UADF010 | SQLCODE diferente de 0 e de +100, ou falha no UPDATE | Infraestrutura (código 3) |
| UADT010 | IF SQLCODE = +100 (conta de destino inexistente) | Negócio |
| UADT010 | SQLCODE -911, deadlock, timeout, tentativas < 6, falha no UPDATE | Infraestrutura |
| WRITE-TO-PROCTRAN-DB2 | IF SQLCODE NOT = 0 | Infraestrutura (registro técnico) |
| CHECK-FOR-STORM-DRAIN-DB2 | EVALUATE SQLCODE | Infraestrutura |
| ABEND-HANDLING | EVALUATE MY-ABEND-CODE, IF WS-STORM-DRAIN | Infraestrutura |

**4. Condição e consequência das estruturas de negócio**

- **Valor da transferência**: se o valor é menor ou igual a zero, a transferência é recusada (falha código '4') e o programa retorna sem movimentar contas.
- **Mesma conta**: se a conta de origem é igual à de destino, a transferência é recusada com o motivo "Cannot transfer to the same account" (abend 'SAME'). O código sobrescreve o código do banco das duas contas com o SORTCODE do sistema, então na prática só o número da conta diferencia os lados. O programa não aceita transferência entre bancos diferentes.
- **Conta de origem inexistente**: SQLCODE +100 na leitura da origem gera falha código '1'. Quando a origem já tinha sido tratada antes, o chamador desfaz a atualização feita e devolve falha.
- **Conta de destino inexistente**: SQLCODE +100 na leitura do destino gera falha código '2'. A operação é desfeita (rollback) e o programa devolve falha.
- Nos dois ramos de ordem de atualização, as mesmas situações aparecem em UAD010 com tratamento próprio, e cada ocorrência está listada separadamente abaixo.

## Regras de negócio

1. Regra: O valor da transferência deve ser maior que zero (COMM-AMT).
   Condição: O valor informado é menor ou igual a zero.
   Consequência: A transferência é recusada, com falha código '4', e nenhuma conta é alterada.
   Parágrafo: PREMIERE (A010)

2. Regra: Não é permitido transferir de uma conta para ela mesma.
   Condição: A conta de origem e a conta de destino são a mesma (COMM-FACCNO = COMM-TACCNO e mesmo sortcode). Como o código do banco das duas contas é sempre carregado com o SORTCODE do sistema, na prática só o número da conta é comparado.
   Consequência: A transferência é recusada com a mensagem "Cannot transfer to the same account" (código 'SAME'), terminando de forma anormal.
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)

3. Regra: A transferência só pode sair de uma conta de origem existente.
   Condição: A conta de origem não é encontrada na base de contas (SQLCODE = +100).
   Consequência: A atualização falha e é devolvida a falha código '1' (conta de origem inexistente).
   Parágrafo: UPDATE-ACCOUNT-DB2-FROM (UADF010)

4. Regra: A transferência só pode ir para uma conta de destino existente.
   Condição: A conta de destino não é encontrada na base de contas (SQLCODE = +100).
   Consequência: É devolvida a falha código '2' (conta de destino inexistente) e a operação em andamento é desfeita (rollback) para evitar inconsistência.
   Parágrafo: UPDATE-ACCOUNT-DB2-TO (UADT010)

5. Regra: Se a conta de origem não existir, a transferência é cancelada, quando a origem é atualizada primeiro.
   Condição: O número da conta de origem é menor que o da conta de destino, a origem é processada primeiro e a falha é código '1' (conta não encontrada).
   Consequência: A operação é desfeita (rollback) e a transferência é devolvida como falha, sem registro de transferência.
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)

6. Regra: Se a conta de destino não existir, a transferência é cancelada e o débito já feito na origem é desfeito, quando a origem é atualizada primeiro.
   Condição: O número da conta de origem é menor que o da conta de destino, o débito na origem foi feito e a atualização do destino falha com código '2' (conta não encontrada).
   Consequência: A operação é desfeita (rollback, revertendo o débito) e a transferência é devolvida como falha.
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)

7. Regra: Se a conta de destino não existir, a transferência é cancelada, quando o destino é atualizado primeiro.
   Condição: O número da conta de origem é maior que o da conta de destino (a conta de destino é processada primeiro) e a falha é código '2' (conta não encontrada).
   Consequência: A operação é desfeita (rollback) e a transferência é devolvida como falha, sem registro de transferência.
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)

8. Regra: Se a conta de origem não existir, a transferência é cancelada e o crédito já feito no destino é desfeito, quando o destino é atualizado primeiro.
   Condição: O número da conta de origem é maior que o da conta de destino, o crédito no destino foi feito e a atualização da origem falha com código '1' (conta não encontrada).
   Consequência: A operação é desfeita (rollback, revertendo o crédito) e a transferência é devolvida como falha.
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)