1. Regra: Se a conta informada não for encontrada na base (consulta retorna SQLCODE +100), a operação é sinalizada como malsucedida com o código de falha '1'.
   Condição: a leitura da conta pelo código da agência e número da conta retorna SQLCODE = +100
   Consequência: indicador de sucesso 'N' e código de falha '1'; a operação é encerrada
   Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)

2. Regra: Se a consulta da conta falhar por qualquer outro motivo que não seja conta inexistente, a operação é sinalizada como malsucedida com o código de falha '2'.
   Condição: a leitura da conta retorna SQLCODE diferente de 0 e diferente de +100
   Consequência: indicador de sucesso 'N' e código de falha '2'; a operação é encerrada
   Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)

3. Regra: Um débito (valor negativo) de pagamento do tipo de facilidade 496 não é permitido em conta do tipo MORTGAGE (hipoteca) ou LOAN (empréstimo); a operação é recusada com o código de falha '4'.
   Condição: valor da operação menor que zero (COMM-AMT < 0), tipo de facilidade 496 e tipo de conta MORTGAGE ou LOAN
   Consequência: indicador de sucesso 'N' e código de falha '4'; o saldo não é alterado
   Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)

4. Regra: Um débito (valor negativo) de tipo de facilidade 496 que deixaria o saldo disponível negativo (saldo disponível + valor < 0) é recusado por fundos insuficientes, com o código de falha '3'. O limite de cheque especial (overdraft) da conta não é considerado nesse cálculo.
   Condição: valor da operação menor que zero, tipo de facilidade 496 e saldo disponível somado ao valor resulta em número negativo
   Consequência: indicador de sucesso 'N' e código de falha '3'; o saldo não é alterado
   Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)

5. Regra: Qualquer operação (crédito ou débito) de tipo de facilidade 496 em conta do tipo MORTGAGE (hipoteca) ou LOAN (empréstimo) é recusada com o código de falha '4'. Esta é uma segunda ocorrência da regra 3, que também alcança os créditos, pois o teste ocorre fora do bloco de valor negativo.
   Condição: tipo de facilidade 496 e tipo de conta MORTGAGE ou LOAN (valor da operação de zero ou positivo, já que os negativos são recusados antes)
   Consequência: indicador de sucesso 'N' e código de falha '4'; o saldo não é alterado
   Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)

6. Regra: Quando a operação é aceita, o valor é somado aos saldos disponível e atual da conta (créditos aumentam e débitos reduzem os saldos).
   Condição: a conta foi encontrada e a operação não foi recusada pelas regras 3, 4 e 5
   Consequência: saldo disponível e saldo atual da conta são atualizados com o valor da operação
   Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)

7. Regra: Se a gravação da atualização de saldo da conta falhar, a operação é sinalizada como malsucedida com o código de falha '2' e o movimento não é registrado.
   Condição: a atualização da conta retorna SQLCODE diferente de 0
   Consequência: indicador de sucesso 'N' e código de falha '2'; o registro da transação não é gravado
   Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)

8. Regra: Um movimento de valor negativo é classificado como débito de balcão ('DEB', descrição 'COUNTER WTHDRW'), e um movimento de valor zero ou positivo como crédito de balcão ('CRE', descrição 'COUNTER RECVED').
   Condição: valor da operação menor que zero (débito) ou maior ou igual a zero (crédito)
   Consequência: o tipo e a descrição do movimento são definidos como débito de balcão ou crédito de balcão
   Parágrafo: WTPD010 (WRITE-TO-PROCTRAN-DB2)

9. Regra: Quando o débito é de tipo de facilidade 496, o movimento é classificado como débito de pagamento ('PDR') e a descrição passa a ser a origem informada na operação (primeiros 14 caracteres), em vez de 'COUNTER WTHDRW'.
   Condição: valor da operação menor que zero e tipo de facilidade 496
   Consequência: tipo do movimento 'PDR' e descrição igual à origem da operação
   Parágrafo: WTPD010 (WRITE-TO-PROCTRAN-DB2)

10. Regra: Quando o crédito é de tipo de facilidade 496, o movimento é classificado como crédito de pagamento ('PCR') e a descrição passa a ser a origem informada na operação (primeiros 14 caracteres), em vez de 'COUNTER RECVED'.
    Condição: valor da operação maior ou igual a zero e tipo de facilidade 496
    Consequência: tipo do movimento 'PCR' e descrição igual à origem da operação
    Parágrafo: WTPD010 (WRITE-TO-PROCTRAN-DB2)

11. Regra: Se o registro do movimento não puder ser gravado, a operação é sinalizada como malsucedida com o código de falha '02'. Há um ponto ambíguo: o código de falha usa '02', enquanto as demais falhas usam um único dígito, e o saldo da conta é desfeito pelo rollback antes dessa sinalização.
    Condição: a gravação do registro do movimento retorna SQLCODE diferente de 0 (e o rollback é concluído com sucesso)
    Consequência: indicador de sucesso 'N' e código de falha '02'
    Parágrafo: WTPD010 (WRITE-TO-PROCTRAN-DB2)

12. Regra: Se o registro do movimento for gravado com sucesso, a operação é sinalizada como bem-sucedida.
    Condição: a gravação do registro do movimento retorna SQLCODE igual a 0
    Consequência: indicador de sucesso 'Y' e código de falha '0'
    Parágrafo: WTPD010 (WRITE-TO-PROCTRAN-DB2)