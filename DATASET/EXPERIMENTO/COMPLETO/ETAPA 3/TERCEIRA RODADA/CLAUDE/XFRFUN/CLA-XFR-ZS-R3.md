1. Regra: O valor da transferência deve ser maior que zero.
   Condição: O valor informado para transferir é menor ou igual a zero (COMM-AMT <= ZERO).
   Consequência: A transferência é recusada com código de falha '4' e nenhuma conta é atualizada.
   Parágrafo: PREMIERE / A010

2. Regra: Não é permitido transferir de uma conta para ela mesma.
   Condição: A conta de origem é igual à conta de destino, com o mesmo código de agência (COMM-FACCNO = COMM-TACCNO e COMM-FSCODE = COMM-TSCODE). Ambiguidade: o código de agência de origem e o de destino recebem o mesmo valor (SORTCODE) no início do programa, então na prática o teste depende apenas do número da conta.
   Consequência: A transação é cancelada (ABEND 'SAME') em vez de devolver um código de falha ao solicitante, e nenhuma transferência é feita.
   Parágrafo: UPDATE-ACCOUNT-DB2 / UAD010

3. Regra: A transferência é recusada se a conta de origem não existir.
   Condição: A conta de origem (agência e número) não é encontrada na base de contas (SQLCODE = +100 na leitura).
   Consequência: A transferência não é realizada e retorna com falha, código '1' (conta de origem inexistente).
   Parágrafo: UPDATE-ACCOUNT-DB2-FROM / UADF010

4. Regra: A transferência é recusada se a conta de destino não existir.
   Condição: A conta de destino (agência e número) não é encontrada na base de contas (SQLCODE = +100 na leitura).
   Consequência: A transferência não é realizada e retorna com falha, código '2' (conta de destino inexistente). Os valores já movimentados na operação são desfeitos (rollback).
   Parágrafo: UPDATE-ACCOUNT-DB2-TO / UADT010

5. Regra: Quando o número da conta de origem é menor que o da conta de destino e a conta de destino não existe, o débito já feito na origem é desfeito.
   Condição: Número da conta de origem menor que o da conta de destino (COMM-FACCNO < COMM-TACCNO), débito na origem concluído e falha no crédito do destino com código '2' (conta de destino inexistente).
   Consequência: A operação é desfeita (rollback) e a transferência termina sem sucesso, sem registro da transferência.
   Parágrafo: UPDATE-ACCOUNT-DB2 / UAD010

6. Regra: Quando o número da conta de origem é menor que o da conta de destino e a conta de origem não existe, a transferência é desfeita.
   Condição: Número da conta de origem menor que o da conta de destino (COMM-FACCNO < COMM-TACCNO) e falha na atualização da origem com código '1' (conta de origem inexistente).
   Consequência: A operação é desfeita (rollback) e a transferência termina sem sucesso, sem registro da transferência.
   Parágrafo: UPDATE-ACCOUNT-DB2 / UAD010

7. Regra: Quando o número da conta de origem é maior que o da conta de destino e a conta de destino não existe, a transferência é desfeita.
   Condição: Número da conta de origem não menor que o da conta de destino (caminho ELSE de COMM-FACCNO < COMM-TACCNO) e falha na atualização do destino com código '2' (conta de destino inexistente).
   Consequência: A operação é desfeita (rollback) e a transferência termina sem sucesso, sem registro da transferência.
   Parágrafo: UPDATE-ACCOUNT-DB2 / UAD010

8. Regra: Quando o número da conta de origem é maior que o da conta de destino e a conta de origem não existe, o crédito já feito no destino é desfeito.
   Condição: Número da conta de origem não menor que o da conta de destino (caminho ELSE de COMM-FACCNO < COMM-TACCNO), crédito no destino concluído e falha na atualização da origem com código '1' (conta de origem inexistente).
   Consequência: A operação é desfeita (rollback) e a transferência termina sem sucesso, sem registro da transferência.
   Parágrafo: UPDATE-ACCOUNT-DB2 / UAD010