1. Regra: Uma transferência só é aceita se o valor for maior que zero. Valor zero ou negativo é recusado e sinalizado como malsucedido com o código de falha '4'.
   Condição: valor da transferência menor ou igual a zero (COMM-AMT <= ZERO)
   Consequência: indicador de sucesso 'N' e código de falha '4'; nenhuma conta é atualizada e o programa encerra
   Parágrafo: A010 (PREMIERE SECTION)

2. Regra: Não é permitido transferir de uma conta para ela mesma. Se a conta de origem e a de destino forem a mesma (mesmo número de conta e mesmo código de agência), a transferência é cancelada por término anormal com o código 'SAME'. Nenhum código de falha de negócio é informado ao chamador.
   Condição: número da conta de origem igual ao da conta de destino e código da agência de origem igual ao da agência de destino
   Consequência: a transferência é cancelada (término anormal 'SAME') e nenhuma conta é movimentada
   Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)

3. Regra: Se a conta de origem não for encontrada (SQLCODE +100 na leitura), a transferência é sinalizada como malsucedida com o código de falha '1'. A conta de origem não é debitada.
   Condição: a consulta à conta de origem retorna "não encontrado" (SQLCODE = +100)
   Consequência: indicador de sucesso 'N' e código de falha '1'; a conta de origem não é debitada
   Parágrafo: UADF010 (UPDATE-ACCOUNT-DB2-FROM)

4. Regra: Se a conta de destino não for encontrada (SQLCODE +100 na leitura), a transferência é sinalizada como malsucedida com o código de falha '2'. Os lançamentos já feitos na transferência são desfeitos, para evitar inconsistência entre as contas.
   Condição: a consulta à conta de destino retorna "não encontrado" (SQLCODE = +100)
   Consequência: indicador de sucesso 'N' e código de falha '2'; a transferência é desfeita (rollback) e a conta de destino não é creditada
   Parágrafo: UADT010 (UPDATE-ACCOUNT-DB2-TO)

5. Regra: Quando a conta de origem tem número menor que o da conta de destino, a origem é debitada primeiro. Se a origem não for encontrada (código de falha '1'), a transferência é desfeita e termina como malsucedida, sem creditar o destino.
   Condição: número da conta de origem menor que o da conta de destino, e a atualização da conta de origem falha com código de falha '1'
   Consequência: a transferência é desfeita (rollback) e termina sem sucesso, com o código de falha '1'; nenhum registro da transferência é gravado
   Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)

6. Regra: Quando a conta de origem tem número menor que o da conta de destino, a origem é debitada primeiro. Se o destino não for encontrado (código de falha '2'), o débito já feito na origem é desfeito e a transferência termina como malsucedida.
   Condição: número da conta de origem menor que o da conta de destino, a origem foi atualizada com sucesso e a atualização do destino falha com código de falha '2'
   Consequência: o débito na origem é desfeito (rollback) e a transferência termina sem sucesso, com o código de falha '2'; nenhum registro da transferência é gravado
   Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)

7. Regra: Quando a conta de origem tem número maior ou igual ao da conta de destino, o destino é creditado primeiro. Se o destino não for encontrado (código de falha '2'), a transferência é desfeita e termina como malsucedida, sem debitar a origem.
   Condição: número da conta de origem maior ou igual ao da conta de destino, e a atualização da conta de destino falha com código de falha '2'
   Consequência: a transferência é desfeita (rollback) e termina sem sucesso, com o código de falha '2'; nenhum registro da transferência é gravado
   Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)

8. Regra: Quando o destino é creditado primeiro e a conta de origem não é encontrada (código de falha '1'), o crédito já feito no destino é desfeito e a transferência termina como malsucedida.
   Condição: número da conta de origem maior ou igual ao da conta de destino, o destino foi atualizado com sucesso e a atualização da origem falha com código de falha '1'
   Consequência: o crédito no destino é desfeito (rollback) e a transferência termina sem sucesso, com o código de falha '1'; nenhum registro da transferência é gravado
   Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)