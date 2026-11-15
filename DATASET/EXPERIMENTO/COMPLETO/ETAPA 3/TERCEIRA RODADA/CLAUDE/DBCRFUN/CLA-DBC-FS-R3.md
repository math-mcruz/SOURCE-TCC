1. Regra: Se a conta a ser movimentada não for encontrada (SQLCODE +100 na consulta), a operação de débito/crédito não é efetuada e é sinalizada como malsucedida com o código de falha '1'.
   Condição: a consulta da conta pelo código da agência e número da conta retorna não encontrado (SQLCODE = +100)
   Consequência: a operação não é feita; indicador de sucesso 'N' e código de falha '1'
   Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)

2. Regra: Débitos (valor negativo) do tipo de facilidade 496 não são permitidos em contas do tipo MORTGAGE ou LOAN; a operação é recusada com o código de falha '4'.
   Condição: valor da operação negativo (COMM-AMT < 0), tipo de facilidade igual a 496 e tipo de conta MORTGAGE ou LOAN
   Consequência: a operação não é feita; indicador de sucesso 'N' e código de falha '4'
   Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)

3. Regra: Um débito do tipo de facilidade 496 que deixaria o saldo disponível negativo é recusado por saldo insuficiente, com o código de falha '3'. O programa só faz essa verificação para o tipo de facilidade 496. Para outros tipos de facilidade, o débito não é barrado por este teste, e o código não considera o limite de cheque especial (ACCOUNT_OVERDRAFT_LIMIT), o que é ambíguo do ponto de vista de negócio.
   Condição: valor da operação negativo, a conta não é MORTGAGE/LOAN com facilidade 496, tipo de facilidade igual a 496 e saldo disponível mais o valor da operação menor que zero (WS-DIFFERENCE < 0)
   Consequência: a operação não é feita; indicador de sucesso 'N' e código de falha '3'
   Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)

4. Regra: Movimentações do tipo de facilidade 496 em contas do tipo MORTGAGE ou LOAN são recusadas com o código de falha '4'. Esta é a segunda ocorrência da regra 2, aplicada às operações com valor não negativo, que chegam a este ponto porque os débitos já foram recusados no teste anterior.
   Condição: tipo de facilidade igual a 496 e tipo de conta MORTGAGE ou LOAN, com valor da operação não negativo
   Consequência: a operação não é feita; indicador de sucesso 'N' e código de falha '4'
   Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)