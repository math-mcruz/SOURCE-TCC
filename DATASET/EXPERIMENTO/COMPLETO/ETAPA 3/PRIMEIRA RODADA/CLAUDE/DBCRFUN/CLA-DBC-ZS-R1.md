1. Regra: Conta não encontrada: a operação de débito/crédito é recusada quando a conta informada não existe (SQLCODE = +100).
   Condição: A conta (código de agência e número da conta) não é localizada no cadastro de contas.
   Consequência: A operação não é efetivada e retorna o código de falha 1 (conta inexistente).
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)

2. Regra: Débito em conta de financiamento ou empréstimo é recusado quando feito pela facilidade 496.
   Condição: O valor da operação é negativo (COMM-AMT < 0), o tipo da conta é MORTGAGE ou LOAN (HV-ACCOUNT-ACC-TYPE) e o tipo de facilidade é 496 (COMM-FACILTYPE).
   Consequência: A operação não é efetivada e retorna o código de falha 4.
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)

3. Regra: Débito feito pela facilidade 496 é recusado quando o saldo disponível não cobre o valor.
   Condição: O valor da operação é negativo, o tipo de facilidade é 496 e a soma do saldo disponível com o valor do débito fica menor que zero (WS-DIFFERENCE < 0). O código não considera o limite de cheque especial nesse teste; para débitos com outro tipo de facilidade, não há verificação de saldo suficiente neste programa.
   Consequência: A operação não é efetivada e retorna o código de falha 3 (fundos insuficientes).
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)

4. Regra: Operação em conta de financiamento ou empréstimo pela facilidade 496 é recusada, independentemente do sinal do valor (segunda ocorrência da regra 2, fora do teste de débito).
   Condição: O tipo da conta é MORTGAGE ou LOAN e o tipo de facilidade é 496. Como os débitos já são barrados antes, na prática este teste atinge os créditos (valor não negativo).
   Consequência: A operação não é efetivada e retorna o código de falha 4.
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)

5. Regra: Débito feito pela facilidade 496 é registrado no histórico de movimentações como tipo PDR.
   Condição: O valor da operação é negativo e o tipo de facilidade é 496.
   Consequência: A movimentação é gravada com tipo PDR e a descrição recebe a origem informada (primeiros 14 caracteres de COMM-ORIGIN).
   Parágrafo: WRITE-TO-PROCTRAN-DB2 (WTPD010)

6. Regra: Débito feito por outro meio que não a facilidade 496 é registrado como saque no balcão.
   Condição: O valor da operação é negativo e o tipo de facilidade é diferente de 496.
   Consequência: A movimentação é gravada com tipo DEB e descrição "COUNTER WTHDRW".
   Parágrafo: WRITE-TO-PROCTRAN-DB2 (WTPD010)

7. Regra: Crédito feito pela facilidade 496 é registrado no histórico de movimentações como tipo PCR.
   Condição: O valor da operação não é negativo (zero ou positivo) e o tipo de facilidade é 496.
   Consequência: A movimentação é gravada com tipo PCR e a descrição recebe a origem informada (primeiros 14 caracteres de COMM-ORIGIN).
   Parágrafo: WRITE-TO-PROCTRAN-DB2 (WTPD010)

8. Regra: Crédito feito por outro meio que não a facilidade 496 é registrado como recebimento no balcão.
   Condição: O valor da operação não é negativo (zero ou positivo) e o tipo de facilidade é diferente de 496.
   Consequência: A movimentação é gravada com tipo CRE e descrição "COUNTER RECVED".
   Parágrafo: WRITE-TO-PROCTRAN-DB2 (WTPD010)