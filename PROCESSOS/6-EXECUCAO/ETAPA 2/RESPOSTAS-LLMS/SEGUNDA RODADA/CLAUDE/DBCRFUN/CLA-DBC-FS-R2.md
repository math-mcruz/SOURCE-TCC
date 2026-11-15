1. Regra: Se a conta informada (agência + número) não for encontrada no cadastro de contas (SQLCODE = +100), a operação não é realizada e é sinalizada como malsucedida com o código de falha '1'.
   Condição: a consulta da conta retorna SQLCODE igual a +100 (conta não encontrada)
   Consequência: indicador de sucesso 'N' e código de falha '1'; a operação é encerrada
   Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)

2. Regra: Em um débito (valor negativo) de pagamento de facilidade (tipo de facilidade 496) contra uma conta do tipo MORTGAGE, a operação é recusada com o código de falha '4'.
   Condição: valor movimentado menor que zero (COMM-AMT < 0), tipo de facilidade igual a 496 e tipo de conta MORTGAGE
   Consequência: operação não realizada; indicador de sucesso 'N' e código de falha '4'
   Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)

3. Regra: Em um débito (valor negativo) de pagamento de facilidade (tipo de facilidade 496) contra uma conta do tipo LOAN, a operação é recusada com o código de falha '4'.
   Condição: valor movimentado menor que zero (COMM-AMT < 0), tipo de facilidade igual a 496 e tipo de conta LOAN
   Consequência: operação não realizada; indicador de sucesso 'N' e código de falha '4'
   Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)

4. Regra: Em um débito (valor negativo) de pagamento de facilidade (tipo de facilidade 496), se o saldo disponível mais o valor do débito ficar negativo, a operação é recusada por saldo insuficiente com o código de falha '3'. O teste usa apenas o saldo disponível; o limite de cheque especial (overdraft) não é considerado.
   Condição: valor movimentado menor que zero, tipo de facilidade igual a 496 e saldo disponível + valor movimentado menor que zero
   Consequência: operação não realizada; indicador de sucesso 'N' e código de falha '3'
   Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)

5. Regra: Em qualquer movimentação de pagamento de facilidade (tipo de facilidade 496) contra uma conta do tipo MORTGAGE, a operação é recusada com o código de falha '4'. Esta é a segunda ocorrência da regra, agora para valores não negativos (créditos), já que os débitos já foram recusados antes.
   Condição: tipo de facilidade igual a 496 e tipo de conta MORTGAGE
   Consequência: operação não realizada; indicador de sucesso 'N' e código de falha '4'
   Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)

6. Regra: Em qualquer movimentação de pagamento de facilidade (tipo de facilidade 496) contra uma conta do tipo LOAN, a operação é recusada com o código de falha '4'. Esta é a segunda ocorrência da regra, agora para valores não negativos (créditos), já que os débitos já foram recusados antes.
   Condição: tipo de facilidade igual a 496 e tipo de conta LOAN
   Consequência: operação não realizada; indicador de sucesso 'N' e código de falha '4'
   Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)

7. Regra: Se a movimentação passar pelas verificações, os saldos disponível e atual da conta são atualizados somando o valor movimentado (negativo para débito, positivo para crédito).
   Condição: conta encontrada e nenhuma das recusas anteriores aplicável
   Consequência: saldo disponível e saldo atual da conta recebem o valor da movimentação
   Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)

8. Regra: Se o valor movimentado for negativo, o lançamento no histórico de transações é classificado como débito de balcão (tipo 'DEB', 'COUNTER WTHDRW').
   Condição: valor movimentado menor que zero e tipo de facilidade diferente de 496
   Consequência: lançamento de tipo débito 'DEB' com descrição 'COUNTER WTHDRW'
   Parágrafo: WTPD010 (WRITE-TO-PROCTRAN-DB2)

9. Regra: Se o valor movimentado for negativo e for um pagamento de facilidade (tipo 496), o lançamento é classificado como débito de pagamento (tipo 'PDR') e a descrição passa a ser a origem informada na operação.
   Condição: valor movimentado menor que zero e tipo de facilidade igual a 496
   Consequência: lançamento de tipo 'PDR', com descrição igual aos 14 primeiros caracteres da origem (COMM-ORIGIN)
   Parágrafo: WTPD010 (WRITE-TO-PROCTRAN-DB2)

10. Regra: Se o valor movimentado não for negativo, o lançamento no histórico de transações é classificado como crédito de balcão (tipo 'CRE', 'COUNTER RECVED').
    Condição: valor movimentado maior ou igual a zero e tipo de facilidade diferente de 496
    Consequência: lançamento de tipo crédito 'CRE' com descrição 'COUNTER RECVED'
    Parágrafo: WTPD010 (WRITE-TO-PROCTRAN-DB2)

11. Regra: Se o valor movimentado não for negativo e for um pagamento de facilidade (tipo 496), o lançamento é classificado como crédito de pagamento (tipo 'PCR') e a descrição passa a ser a origem informada na operação.
    Condição: valor movimentado maior ou igual a zero e tipo de facilidade igual a 496
    Consequência: lançamento de tipo 'PCR', com descrição igual aos 14 primeiros caracteres da origem (COMM-ORIGIN)
    Parágrafo: WTPD010 (WRITE-TO-PROCTRAN-DB2)

12. Regra: Se a movimentação for concluída e o lançamento no histórico for gravado com sucesso, a operação é sinalizada como bem-sucedida.
    Condição: gravação do lançamento no histórico de transações com SQLCODE igual a zero
    Consequência: indicador de sucesso 'Y' e código de falha '0'
    Parágrafo: WTPD010 (WRITE-TO-PROCTRAN-DB2)