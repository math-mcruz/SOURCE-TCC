# Análise

**1. Parágrafos e fluxo principal**

- **PREMIERE (A010)**: ponto de entrada. Registra o tratador de abend, copia o código da agência (sort code) para origem e destino, valida o valor, chama UPDATE-ACCOUNT-DB2 e encerra por GET-ME-OUT-OF-HERE.
- **UPDATE-ACCOUNT-DB2 (UAD010)**: orquestra a transferência.
  - Rejeita transferência para a mesma conta.
  - Define a ordem de atualização pela comparação dos números de conta: origem primeiro se origem < destino, senão destino primeiro.
  - Trata o resultado de cada atualização.
  - Se tudo deu certo, chama WRITE-TO-PROCTRAN e marca sucesso.
- **UPDATE-ACCOUNT-DB2-FROM (UADF010)**: lê a conta de origem, subtrai o valor dos saldos disponível e real e atualiza a conta.
- **UPDATE-ACCOUNT-DB2-TO (UADT010)**: lê a conta de destino, soma o valor aos saldos e atualiza a conta. Contém tratamento de deadlock e timeout.
- **WRITE-TO-PROCTRAN / WRITE-TO-PROCTRAN-DB2**: grava o registro da transferência na tabela PROCTRAN.
- **GET-ME-OUT-OF-HERE**: devolve o controle (RETURN).
- **CHECK-FOR-STORM-DRAIN-DB2**: diagnóstico de perda de conexão com o DB2.
- **ABEND-HANDLING**: tratador de abends (deadlock, falhas de VSAM).
- **POPULATE-TIME-DATE**: obtém data e hora para os registros técnicos.

Fluxo principal: A010 → valida valor → UAD010 → valida contas distintas → atualiza origem e destino (em uma das duas ordens) → grava PROCTRAN → COMM-SUCCESS = 'Y' → RETURN.

**2. Estruturas de decisão e 3. Classificação**

| Local | Estrutura | Classificação |
|---|---|---|
| A010 | IF COMM-AMT <= ZERO | Negócio |
| UAD010 | IF conta origem = conta destino (número e agência) | Negócio |
| UAD010 | IF COMM-FACCNO < COMM-TACCNO | Infraestrutura (ordem técnica de atualização) |
| UAD010 | IF COMM-SUCCESS = 'Y' após a primeira atualização | Teste intermediário (leva a outro teste) |
| UAD010 | IF COMM-SUCCESS = 'N' após a segunda atualização | Teste intermediário |
| UAD010 | IF COMM-FAIL-CODE = '2' / '1' / NOT '1' / NOT '2' | Negócio quando o código é '1' ou '2'. Os ramos "NOT" levam a abend (infraestrutura) |
| UAD010 | IF WS-CICS-RESP NOT = DFHRESP(NORMAL) após rollback | Infraestrutura |
| UADF010 | IF SQLCODE NOT = 0 / IF SQLCODE = +100 | Negócio quando +100 (conta inexistente). Os demais códigos são infraestrutura |
| UADF010 | IF SQLCODE NOT = 0 após o UPDATE | Infraestrutura |
| UADT010 | IF SQLCODE NOT = 0 / IF SQLCODE = +100 | Negócio quando +100 (conta inexistente). Os demais códigos são infraestrutura |
| UADT010 | IF SQLCODE = -911, SQLERRD(3), DB2-DEADLOCK-RETRY < 6, rollback e retentativa | Infraestrutura |
| UADT010 | IF SQLCODE NOT = 0 após o UPDATE | Infraestrutura |
| WTPD010 | IF SQLCODE NOT = 0 após o INSERT em PROCTRAN | Infraestrutura |
| CFSDD010 | EVALUATE SQLCODE (923) e IF STORM-DRAIN | Infraestrutura |
| AH010 | EVALUATE MY-ABEND-CODE, IF WS-STORM-DRAIN | Infraestrutura |

Não há decisões de interface (telas ou teclas de função).

**4. Condição e consequência das estruturas de negócio**

- **Valor da transferência**: se o valor for zero ou negativo, a transferência não é feita, sucesso = 'N' e código de falha '4'.
- **Mesma conta**: se origem e destino forem a mesma conta, o programa termina em abend 'SAME'. O chamador não recebe código de falha.
- **Conta de origem inexistente** (SQLCODE +100 em UADF010): código de falha '1'.
- **Conta de destino inexistente** (SQLCODE +100 em UADT010): código de falha '2' e desfazimento das alterações.
- **Combinação com a ordem de atualização**:
  - Origem primeiro: origem inexistente (código '1') ou destino inexistente após o débito (código '2') leva a rollback e à transferência não realizada.
  - Destino primeiro: destino inexistente (código '2') ou origem inexistente após o crédito (código '1') leva a rollback e à transferência não realizada.
- **Ausência de verificações**: o programa não verifica saldo suficiente nem limite de cheque especial. O débito é aplicado sem essa checagem.

# Regras de negócio

1. Regra: O valor da transferência deve ser maior que zero; transferências de valor zero ou negativo são recusadas.
   Condição: O valor informado é menor ou igual a zero (COMM-AMT <= ZERO).
   Consequência: A transferência não é realizada e o resultado é de falha, com código de falha '4' (COMM-SUCCESS = 'N', COMM-FAIL-CODE = '4').
   Parágrafo: PREMIERE (A010)

2. Regra: Não é permitido transferir de uma conta para ela mesma.
   Condição: A conta de origem e a conta de destino têm o mesmo número e a mesma agência (COMM-FACCNO = COMM-TACCNO e COMM-FSCODE = COMM-TSCODE).
   Consequência: A transferência não é realizada; o programa é encerrado de forma anormal (abend 'SAME'), sem devolver código de falha ao chamador. O código não devolve uma recusa controlada, o que é ambíguo do ponto de vista do chamador.
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)

3. Regra: Se a conta de origem não existe, a transferência é recusada com o código de falha de origem inexistente.
   Condição: A leitura da conta de origem não encontra o registro (SQLCODE = +100).
   Consequência: Resultado de falha com código '1' (conta de origem não encontrada) e nenhum débito é feito.
   Parágrafo: UPDATE-ACCOUNT-DB2-FROM (UADF010)

4. Regra: Se a conta de destino não existe, a transferência é recusada e as alterações já feitas são desfeitas.
   Condição: A leitura da conta de destino não encontra o registro (SQLCODE = +100).
   Consequência: Resultado de falha com código '2' (conta de destino não encontrada) e rollback das alterações pendentes para evitar inconsistência.
   Parágrafo: UPDATE-ACCOUNT-DB2-TO (UADT010)

5. Regra: Quando o número da conta de origem é menor que o da conta de destino, e a conta de destino não existe depois de a origem ser debitada, o débito é desfeito e a transferência é recusada.
   Condição: Origem < destino, a origem foi atualizada com sucesso e a conta de destino não foi encontrada (COMM-FAIL-CODE = '2').
   Consequência: Rollback do débito e término sem concluir a transferência, com sucesso = 'N' e código de falha '2'.
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)

6. Regra: Quando o número da conta de origem é menor que o da conta de destino, e a conta de origem não existe, a transferência é recusada.
   Condição: Origem < destino e a conta de origem não foi encontrada (COMM-FAIL-CODE = '1').
   Consequência: Rollback e término sem concluir a transferência, com sucesso = 'N' e código de falha '1'.
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)

7. Regra: Quando o número da conta de origem não é menor que o da conta de destino, e a conta de destino não existe, a transferência é recusada.
   Condição: Origem >= destino (e contas distintas) e a conta de destino não foi encontrada (COMM-FAIL-CODE = '2').
   Consequência: Rollback e término sem concluir a transferência, com sucesso = 'N' e código de falha '2'.
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)

8. Regra: Quando o número da conta de origem não é menor que o da conta de destino, e a conta de origem não existe depois de o destino ser creditado, o crédito é desfeito e a transferência é recusada.
   Condição: Origem >= destino (e contas distintas), o destino foi creditado com sucesso e a conta de origem não foi encontrada (COMM-FAIL-CODE = '1').
   Consequência: Rollback do crédito e término sem concluir a transferência, com sucesso = 'N' e código de falha '1'.
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)