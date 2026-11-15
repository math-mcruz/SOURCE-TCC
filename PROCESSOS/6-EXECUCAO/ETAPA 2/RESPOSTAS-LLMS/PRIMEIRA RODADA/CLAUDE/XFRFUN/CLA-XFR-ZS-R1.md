1. Regra: O valor da transferência deve ser maior que zero (COMM-AMT).
   Condição: O valor informado para a transferência é menor ou igual a zero (COMM-AMT <= ZERO).
   Consequência: A transferência é recusada, sem sucesso (COMM-SUCCESS = 'N'), com código de falha '4', e o programa encerra sem movimentar nenhuma conta.
   Parágrafo: PREMIERE (A010)

2. Regra: Não é permitido transferir de uma conta para ela mesma.
   Condição: A conta de origem e a conta de destino têm o mesmo número e o mesmo sort code (COMM-FACCNO = COMM-TACCNO e COMM-FSCODE = COMM-TSCODE).
   Consequência: A transferência não é realizada, e o processamento é encerrado de forma anormal com o código 'SAME' e a mensagem "Cannot transfer to the same account".
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)

3. Regra: A transferência é recusada quando a conta de origem não existe.
   Condição: A conta de origem não é encontrada no cadastro de contas (SQLCODE = +100 na leitura da conta de origem).
   Consequência: A transferência falha sem sucesso (COMM-SUCCESS = 'N') com código de falha '1' (conta de origem inexistente) e a conta de origem não é debitada.
   Parágrafo: UPDATE-ACCOUNT-DB2-FROM (UADF010)

4. Regra: A transferência é recusada, e o débito já feito na origem é desfeito, quando a conta de destino não existe.
   Condição: A conta de destino não é encontrada no cadastro de contas (SQLCODE = +100 na leitura da conta de destino).
   Consequência: A transferência falha sem sucesso (COMM-SUCCESS = 'N') com código de falha '2' (conta de destino inexistente) e as alterações pendentes são desfeitas (rollback) para evitar inconsistência de saldos.
   Parágrafo: UPDATE-ACCOUNT-DB2-TO (UADT010)

5. Regra: Quando o número da conta de origem é menor que o da conta de destino, a origem é debitada primeiro, e a transferência é encerrada sem sucesso e com as alterações desfeitas se a conta de destino não existir.
   Condição: COMM-FACCNO < COMM-TACCNO, a origem foi debitada com sucesso e a conta de destino falhou com código de falha '2' (destino inexistente).
   Consequência: As alterações são desfeitas (rollback) e a transferência termina sem sucesso, sem gravar o registro da transferência.
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)

6. Regra: Quando o número da conta de origem é menor que o da conta de destino, a transferência é encerrada sem sucesso se a conta de origem não existir.
   Condição: COMM-FACCNO < COMM-TACCNO e a atualização da origem falhou com código de falha '1' (origem inexistente).
   Consequência: As alterações são desfeitas (rollback) e a transferência termina sem sucesso, sem gravar o registro da transferência.
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)

7. Regra: Quando o número da conta de origem não é menor que o da conta de destino, o destino é creditado primeiro, e a transferência é encerrada sem sucesso se a conta de destino não existir.
   Condição: COMM-FACCNO não é menor que COMM-TACCNO e a atualização do destino falhou com código de falha '2' (destino inexistente).
   Consequência: As alterações são desfeitas (rollback) e a transferência termina sem sucesso, sem gravar o registro da transferência.
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)

8. Regra: Quando o número da conta de origem não é menor que o da conta de destino, o crédito feito no destino é desfeito se a conta de origem não existir.
   Condição: COMM-FACCNO não é menor que COMM-TACCNO, o destino foi creditado com sucesso e a atualização da origem falhou com código de falha '1' (origem inexistente).
   Consequência: O crédito no destino é desfeito (rollback) e a transferência termina sem sucesso, sem gravar o registro da transferência.
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)