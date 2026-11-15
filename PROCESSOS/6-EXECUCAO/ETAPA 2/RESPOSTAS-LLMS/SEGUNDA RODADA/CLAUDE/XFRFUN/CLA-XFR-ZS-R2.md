1. Regra: O valor da transferência deve ser maior que zero; caso contrário a transferência é recusada (código de falha 4).
   Condição: O valor informado (COMM-AMT) é menor ou igual a zero.
   Consequência: A transferência não é realizada e o retorno indica falha com código '4'.
   Parágrafo: PREMIERE (A010)

2. Regra: Não é permitido transferir de uma conta para ela mesma.
   Condição: A conta de origem e a conta de destino são iguais, comparando número da conta e código da agência (COMM-FACCNO = COMM-TACCNO e COMM-FSCODE = COMM-TSCODE). Os dois códigos de agência são preenchidos com o mesmo valor (SORTCODE) no início do programa, então na prática só o número da conta decide.
   Consequência: A transação é interrompida de forma anormal (abend 'SAME'), sem devolver um código de falha ao chamador e sem concluir a transferência.
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)

3. Regra: Se a conta de origem não existir, a transferência falha com o código de conta de origem inexistente.
   Condição: A consulta da conta de origem não encontra registro (SQLCODE = +100).
   Consequência: A transferência não é realizada e o retorno indica falha com código '1'.
   Parágrafo: UPDATE-ACCOUNT-DB2-FROM (UADF010)

4. Regra: Se a conta de destino não existir, a transferência é cancelada e qualquer movimentação já feita é desfeita.
   Condição: A consulta da conta de destino não encontra registro (SQLCODE = +100).
   Consequência: A transferência falha com código '2' e as alterações da transação são desfeitas (rollback).
   Parágrafo: UPDATE-ACCOUNT-DB2-TO (UADT010)

5. Regra: Quando a conta de origem tem número menor que a de destino e a conta de destino não existe, a transferência é cancelada e desfeita.
   Condição: Número da conta de origem menor que o da conta de destino (COMM-FACCNO < COMM-TACCNO), a origem foi atualizada com sucesso e a atualização do destino falhou com código '2' (destino inexistente).
   Consequência: A transação é desfeita (rollback), a transferência não é concluída e o retorno indica falha com código '2'.
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)

6. Regra: Quando a conta de origem tem número menor que a de destino e a conta de origem não existe, a transferência é cancelada.
   Condição: Número da conta de origem menor que o da conta de destino (COMM-FACCNO < COMM-TACCNO) e a atualização da origem falhou com código '1' (origem inexistente).
   Consequência: A transação é desfeita (rollback), a transferência não é concluída e o retorno indica falha com código '1'.
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)

7. Regra: Quando a conta de origem tem número maior que a de destino e a conta de origem não existe, a transferência é cancelada e o crédito já feito no destino é desfeito.
   Condição: Número da conta de origem maior ou igual ao da conta de destino (caso contrário de COMM-FACCNO < COMM-TACCNO), o destino foi atualizado com sucesso e a atualização da origem falhou com código '1' (origem inexistente).
   Consequência: A transação é desfeita (rollback), a transferência não é concluída e o retorno indica falha com código '1'.
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)

8. Regra: Quando a conta de origem tem número maior que a de destino e a conta de destino não existe, a transferência é cancelada.
   Condição: Número da conta de origem maior ou igual ao da conta de destino e a atualização do destino falhou com código '2' (destino inexistente).
   Consequência: A transação é desfeita (rollback), a transferência não é concluída e o retorno indica falha com código '2'.
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)