1. Regra: Não é permitida transferência de valor zero ou negativo; o valor informado deve ser maior que zero. Com valor menor ou igual a zero, a transferência não é feita e é sinalizada como malsucedida com o código de falha '4'.
   Condição: valor da transferência menor ou igual a zero (COMM-AMT <= ZERO)
   Consequência: a transferência não é feita; indicador de sucesso 'N' e código de falha '4'
   Parágrafo: A010 (PREMIERE)

2. Regra: Não é permitido transferir de uma conta para ela mesma. Se a conta de origem e a conta de destino forem a mesma (mesmo número e mesmo código de agência), a transferência é interrompida. O programa não devolve um código de falha ao chamador: ele encerra a transação de forma anormal com o código 'SAME' (comportamento ambíguo do ponto de vista de negócio).
   Condição: número da conta de origem igual ao da conta de destino e código de agência de origem igual ao de destino
   Consequência: a transferência não é feita e a transação é encerrada de forma anormal com o código 'SAME'
   Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)

3. Regra: Quando a conta de origem tem número menor que o da conta de destino e a conta de origem não é encontrada, a transferência é desfeita e sinalizada como malsucedida com o código de falha '1'.
   Condição: número da origem menor que o do destino, e a atualização da conta de origem falha com código de falha '1' (conta de origem não encontrada)
   Consequência: as alterações são desfeitas; indicador de sucesso 'N' e código de falha '1'; nenhum registro de transferência é gravado
   Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)

4. Regra: Quando a conta de origem tem número menor que o da conta de destino, a origem foi debitada e a conta de destino não é encontrada, a transferência é desfeita e sinalizada como malsucedida com o código de falha '2'.
   Condição: número da origem menor que o do destino, origem atualizada com sucesso, e a atualização da conta de destino falha com código de falha '2' (conta de destino não encontrada)
   Consequência: as alterações são desfeitas, inclusive o débito da origem; indicador de sucesso 'N' e código de falha '2'; nenhum registro de transferência é gravado
   Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)

5. Regra: Quando a conta de origem tem número maior ou igual ao da conta de destino e a conta de destino não é encontrada, a transferência é desfeita e sinalizada como malsucedida com o código de falha '2'.
   Condição: número da origem maior ou igual ao do destino, e a atualização da conta de destino falha com código de falha '2' (conta de destino não encontrada)
   Consequência: as alterações são desfeitas; indicador de sucesso 'N' e código de falha '2'; nenhum registro de transferência é gravado
   Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)

6. Regra: Quando a conta de origem tem número maior ou igual ao da conta de destino, o destino foi creditado e a conta de origem não é encontrada, a transferência é desfeita e sinalizada como malsucedida com o código de falha '1'.
   Condição: número da origem maior ou igual ao do destino, destino atualizado com sucesso, e a atualização da conta de origem falha com código de falha '1' (conta de origem não encontrada)
   Consequência: as alterações são desfeitas, inclusive o crédito do destino; indicador de sucesso 'N' e código de falha '1'; nenhum registro de transferência é gravado
   Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)

7. Regra: Se a conta de origem da transferência não existir (leitura sem resultado, SQLCODE +100), o débito não é feito e a transferência é sinalizada como malsucedida com o código de falha '1'.
   Condição: a consulta da conta de origem retorna SQLCODE +100 (registro não encontrado)
   Consequência: indicador de sucesso 'N' e código de falha '1'; a conta não é debitada
   Parágrafo: UADF010 (UPDATE-ACCOUNT-DB2-FROM)

8. Regra: Se a conta de destino da transferência não existir (leitura sem resultado, SQLCODE +100), o crédito não é feito, as alterações da transferência são desfeitas para evitar inconsistência entre as contas e a transferência é sinalizada como malsucedida com o código de falha '2'.
   Condição: a consulta da conta de destino retorna SQLCODE +100 (registro não encontrado)
   Consequência: as alterações são desfeitas; indicador de sucesso 'N' e código de falha '2'
   Parágrafo: UADT010 (UPDATE-ACCOUNT-DB2-TO)