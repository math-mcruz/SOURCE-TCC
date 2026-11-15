1. Regra: Uma transferência com valor igual a zero ou negativo é recusada; o valor transferido deve ser maior que zero.
   Condição: valor da transferência menor ou igual a zero (COMM-AMT <= ZERO)
   Consequência: a transferência não é feita; indicador de sucesso 'N' e código de falha '4'
   Parágrafo: A010 (PREMIERE SECTION)

2. Regra: Não é permitido transferir de uma conta para ela mesma (mesmo número de conta e mesmo sort code na origem e no destino).
   Condição: conta de origem igual à conta de destino, com o mesmo sort code (COMM-FACCNO = COMM-TACCNO e COMM-FSCODE = COMM-TSCODE)
   Consequência: a transferência é interrompida com o encerramento anormal 'SAME' e a mensagem "Cannot transfer to the same account"; nenhum valor é movimentado
   Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)

3. Regra: Se a conta de origem não for encontrada, a transferência é sinalizada como malsucedida com o código de falha '1'.
   Condição: a consulta da conta de origem retorna "não encontrado" (SQLCODE = +100)
   Consequência: indicador de sucesso 'N' e código de falha '1'; o valor não é debitado
   Parágrafo: UADF010 (UPDATE-ACCOUNT-DB2-FROM)

4. Regra: Se a consulta da conta de origem falhar por qualquer outro motivo que não seja conta inexistente, a transferência é sinalizada como malsucedida com o código de falha '3'.
   Condição: a consulta da conta de origem retorna erro diferente de zero e diferente de +100 (SQLCODE)
   Consequência: indicador de sucesso 'N' e código de falha '3'; o valor não é debitado
   Parágrafo: UADF010 (UPDATE-ACCOUNT-DB2-FROM)

5. Regra: Se o débito na conta de origem não puder ser gravado, a transferência é sinalizada como malsucedida com o código de falha '3'.
   Condição: a atualização do saldo da conta de origem retorna erro (SQLCODE diferente de zero)
   Consequência: indicador de sucesso 'N' e código de falha '3'
   Parágrafo: UADF010 (UPDATE-ACCOUNT-DB2-FROM)

6. Regra: Se a conta de destino não for encontrada, a transferência é sinalizada como malsucedida com o código de falha '2' e a operação é desfeita (o débito eventualmente já feito na conta de origem é revertido).
   Condição: a consulta da conta de destino retorna "não encontrado" (SQLCODE = +100)
   Consequência: indicador de sucesso 'N' e código de falha '2'; a operação é desfeita para evitar inconsistência entre as contas
   Parágrafo: UADT010 (UPDATE-ACCOUNT-DB2-TO)

7. Regra: Quando a conta de origem tem número menor que o da conta de destino, o débito na origem é feito primeiro; se a origem não for encontrada (código de falha '1'), a transferência é encerrada sem prosseguir para o destino e a operação é desfeita.
   Condição: número da conta de origem menor que o da conta de destino (COMM-FACCNO < COMM-TACCNO), débito na origem malsucedido com código de falha '1'
   Consequência: a operação é desfeita e a transferência termina com indicador de sucesso 'N' e código de falha '1'; o destino não é creditado
   Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)

8. Regra: Quando a conta de origem tem número menor que o da conta de destino, o débito na origem é feito primeiro; se ele falhar por outro motivo que não conta inexistente, a transferência é encerrada de forma anormal com o código 'FROM'.
   Condição: número da conta de origem menor que o da conta de destino (COMM-FACCNO < COMM-TACCNO), débito na origem malsucedido com código de falha diferente de '1'
   Consequência: encerramento anormal 'FROM' (erro ao atualizar a conta de origem); nenhum crédito é feito no destino
   Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)

9. Regra: Quando a conta de origem tem número menor que o da conta de destino, e o débito na origem foi bem-sucedido, a falha por conta de destino inexistente (código de falha '2') desfaz a transferência, que termina malsucedida.
   Condição: número da conta de origem menor que o da conta de destino, débito na origem bem-sucedido e crédito no destino malsucedido com código de falha '2'
   Consequência: a operação é desfeita e a transferência termina com indicador de sucesso 'N' e código de falha '2'
   Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)

10. Regra: Quando a conta de origem tem número menor que o da conta de destino, e o débito na origem foi bem-sucedido, qualquer outra falha no crédito do destino (código de falha diferente de '2') encerra a transferência de forma anormal com o código 'TO'.
    Condição: número da conta de origem menor que o da conta de destino, débito na origem bem-sucedido e crédito no destino malsucedido com código de falha diferente de '2'
    Consequência: encerramento anormal 'TO' (erro ao atualizar a conta de destino)
    Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)

11. Regra: Quando a conta de origem tem número igual ou maior que o da conta de destino, o crédito no destino é feito primeiro; se ele falhar por conta de destino inexistente (código de falha '2'), a operação é desfeita e a transferência termina malsucedida.
    Condição: número da conta de origem não menor que o da conta de destino, crédito no destino malsucedido com código de falha '2'
    Consequência: a operação é desfeita e a transferência termina com indicador de sucesso 'N' e código de falha '2'; a origem não é debitada
    Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)

12. Regra: Quando a conta de origem tem número igual ou maior que o da conta de destino, o crédito no destino é feito primeiro; se ele falhar por outro motivo que não conta inexistente, a transferência é encerrada de forma anormal com o código 'TO'.
    Condição: número da conta de origem não menor que o da conta de destino, crédito no destino malsucedido com código de falha diferente de '2'
    Consequência: encerramento anormal 'TO' (erro ao atualizar a conta de destino)
    Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)

13. Regra: Quando a conta de origem tem número igual ou maior que o da conta de destino, e o crédito no destino foi bem-sucedido, a falha no débito da origem por conta inexistente (código de falha '1') desfaz a transferência, que termina malsucedida.
    Condição: número da conta de origem não menor que o da conta de destino, crédito no destino bem-sucedido e débito na origem malsucedido com código de falha '1'
    Consequência: a operação é desfeita (o crédito já feito no destino é revertido) e a transferência termina com indicador de sucesso 'N' e código de falha '1'
    Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)

14. Regra: Quando a conta de origem tem número igual ou maior que o da conta de destino, e o crédito no destino foi bem-sucedido, qualquer outra falha no débito da origem (código de falha diferente de '1') encerra a transferência de forma anormal com o código 'FROM'.
    Condição: número da conta de origem não menor que o da conta de destino, crédito no destino bem-sucedido e débito na origem malsucedido com código de falha diferente de '1'
    Consequência: encerramento anormal 'FROM' (erro ao atualizar a conta de origem)
    Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)

15. Regra: Se ambas as contas forem atualizadas com sucesso, a transferência é registrada no histórico de transações e concluída com sucesso.
    Condição: débito na origem e crédito no destino concluídos com sucesso
    Consequência: é gravado o registro da transferência (tipo transferência, valor e conta de destino) e o indicador de sucesso passa a 'Y'
    Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)

16. Regra: Se a consulta da conta de destino falhar por motivo diferente de conta inexistente, a transferência é sinalizada com o código de falha '3' e é encerrada de forma anormal (ambíguo: o programa tenta, em caso de impasse transitório no banco de dados, repetir a transferência até cinco vezes antes de encerrar).
    Condição: a consulta da conta de destino retorna erro diferente de zero e diferente de +100 (SQLCODE)
    Consequência: código de falha '3'; encerramento anormal 'RUF2' (ou nova tentativa da transferência, em caso de impasse transitório)
    Parágrafo: UADT010 (UPDATE-ACCOUNT-DB2-TO)

17. Regra: Se o crédito na conta de destino não puder ser gravado, a transferência é encerrada de forma anormal (ambíguo: em caso de impasse transitório no banco de dados, o programa tenta repetir a transferência até cinco vezes antes de encerrar).
    Condição: a atualização do saldo da conta de destino retorna erro (SQLCODE diferente de zero)
    Consequência: encerramento anormal 'RUF3' (ou nova tentativa da transferência, em caso de impasse transitório)
    Parágrafo: UADT010 (UPDATE-ACCOUNT-DB2-TO)