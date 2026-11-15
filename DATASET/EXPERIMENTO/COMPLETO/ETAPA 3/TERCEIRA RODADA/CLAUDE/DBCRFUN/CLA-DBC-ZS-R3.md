1. Regra: Se a conta informada não existe, a operação de débito/crédito é recusada com código de falha 1 (conta não encontrada).
   Condição: A consulta da conta pelo código do banco/agência e número da conta não encontra registro (SQLCODE = +100).
   Consequência: A operação é marcada como não realizada, com código de falha '1'.
   Parágrafo: UPDATE-ACCOUNT-DB2

2. Regra: Débitos de facilidade tipo 496 não são permitidos em contas do tipo hipoteca ou empréstimo.
   Condição: O valor é negativo (COMM-AMT < 0), o tipo da conta é 'MORTGAGE' ou 'LOAN' e o tipo de facilidade é 496 (COMM-FACILTYPE).
   Consequência: A operação é marcada como não realizada, com código de falha '4', e a conta não é alterada.
   Parágrafo: UPDATE-ACCOUNT-DB2

3. Regra: Débitos de facilidade tipo 496 não são permitidos quando o saldo disponível não cobre o valor.
   Condição: O valor é negativo (COMM-AMT < 0), o saldo disponível mais o valor do débito resulta em número negativo (WS-DIFFERENCE < 0) e o tipo de facilidade é 496. Ambíguo: o teste usa o saldo disponível e não considera o limite de cheque especial (ACCOUNT-OVERDRAFT-LIM).
   Consequência: A operação é marcada como não realizada, com código de falha '3' (saldo insuficiente), e a conta não é alterada.
   Parágrafo: UPDATE-ACCOUNT-DB2

4. Regra: Operações de facilidade tipo 496 não são permitidas em contas do tipo hipoteca ou empréstimo, também quando o valor não é negativo (crédito).
   Condição: O tipo da conta é 'MORTGAGE' ou 'LOAN' e o tipo de facilidade é 496, sem teste do sinal do valor. Ambíguo: para valores negativos essa mesma situação já foi tratada antes (regra 2), então na prática este teste só alcança valores zero ou positivos.
   Consequência: A operação é marcada como não realizada, com código de falha '4', e a conta não é alterada.
   Parágrafo: UPDATE-ACCOUNT-DB2

5. Regra: Um débito comum é classificado como débito de balcão.
   Condição: O valor é negativo (COMM-AMT < 0) e o tipo de facilidade não é 496.
   Consequência: A movimentação é classificada com tipo 'DEB' e descrição 'COUNTER WTHDRW'.
   Parágrafo: WRITE-TO-PROCTRAN-DB2

6. Regra: Um débito de facilidade tipo 496 é classificado como débito de pagamento, com a origem da operação na descrição.
   Condição: O valor é negativo (COMM-AMT < 0) e o tipo de facilidade é 496.
   Consequência: A movimentação é classificada com tipo 'PDR' e a descrição recebe a origem da operação (COMM-ORIGIN, 14 primeiros caracteres).
   Parágrafo: WRITE-TO-PROCTRAN-DB2

7. Regra: Um crédito comum é classificado como crédito de balcão.
   Condição: O valor não é negativo (COMM-AMT >= 0) e o tipo de facilidade não é 496.
   Consequência: A movimentação é classificada com tipo 'CRE' e descrição 'COUNTER RECVED'.
   Parágrafo: WRITE-TO-PROCTRAN-DB2

8. Regra: Um crédito de facilidade tipo 496 é classificado como crédito de pagamento, com a origem da operação na descrição.
   Condição: O valor não é negativo (COMM-AMT >= 0) e o tipo de facilidade é 496.
   Consequência: A movimentação é classificada com tipo 'PCR' e a descrição recebe a origem da operação (COMM-ORIGIN, 14 primeiros caracteres).
   Parágrafo: WRITE-TO-PROCTRAN-DB2