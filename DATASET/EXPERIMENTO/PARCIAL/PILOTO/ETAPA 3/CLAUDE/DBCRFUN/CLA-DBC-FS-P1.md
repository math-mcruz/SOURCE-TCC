1. Regra: Se a conta informada não for encontrada na base de contas (SQLCODE = +100), a operação não é realizada e é sinalizada como malsucedida com o código de falha '1'.
   Condição: a consulta da conta pelo código da agência e número da conta retorna "não encontrado" (SQLCODE = +100)
   Consequência: indicador de sucesso 'N' e código de falha '1'
   Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)

2. Regra: Um débito (valor negativo) feito por meio do tipo de facilidade 496 não é permitido em conta do tipo MORTGAGE (hipoteca) ou LOAN (empréstimo). A operação não é realizada e é sinalizada como malsucedida com o código de falha '4'.
   Condição: valor da operação negativo (COMM-AMT < 0), tipo de facilidade igual a 496 e tipo da conta igual a MORTGAGE ou LOAN
   Consequência: a operação não é realizada; indicador de sucesso 'N' e código de falha '4'
   Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)

3. Regra: Um débito feito por meio do tipo de facilidade 496 não é permitido quando o saldo disponível, depois do débito, ficaria negativo (saldo insuficiente). A operação não é realizada e é sinalizada como malsucedida com o código de falha '3'. O código compara apenas o saldo disponível com o valor, sem citar o limite de cheque especial (OVERDRAFT-LIM). Se o saldo disponível já incluir esse limite, o limite é considerado de forma indireta; o código não deixa isso claro.
   Condição: valor da operação negativo (COMM-AMT < 0), saldo disponível mais o valor da operação menor que zero (WS-DIFFERENCE < 0) e tipo de facilidade igual a 496
   Consequência: a operação não é realizada; indicador de sucesso 'N' e código de falha '3'
   Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)

4. Regra: Uma operação feita por meio do tipo de facilidade 496 não é permitida em conta do tipo MORTGAGE (hipoteca) ou LOAN (empréstimo). A operação não é realizada e é sinalizada como malsucedida com o código de falha '4'. Este teste repete o do item 2, mas fica fora do bloco de valor negativo. Na prática ele só alcança operações de valor zero ou positivo (créditos), pois os débitos já foram rejeitados antes.
   Condição: tipo de facilidade igual a 496 e tipo da conta igual a MORTGAGE ou LOAN
   Consequência: a operação não é realizada; indicador de sucesso 'N' e código de falha '4'
   Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)