1. Regra: Operações de débito de pagamento (tipo de facilidade 496) não são permitidas em contas de hipoteca ou de empréstimo.
   Condição: O valor da operação é negativo (COMM-AMT < 0), o tipo da conta é MORTGAGE ou LOAN e o tipo de facilidade é 496.
   Consequência: A operação é recusada e o código de falha 4 é devolvido (COMM-FAIL-CODE = '4'); o saldo não é alterado.
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)

2. Regra: Operações de pagamento (tipo de facilidade 496) não são permitidas em contas de hipoteca ou de empréstimo, mesmo quando o valor não é negativo.
   Condição: O tipo da conta é MORTGAGE ou LOAN e o tipo de facilidade é 496, sem teste do sinal do valor. Na prática só alcança valores não negativos, pois os débitos já foram recusados na regra anterior, que tem a mesma consequência (ocorrência repetida da mesma regra).
   Consequência: A operação é recusada e o código de falha 4 é devolvido (COMM-FAIL-CODE = '4'); o saldo não é alterado.
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)

3. Regra: Conta inexistente: a operação é recusada.
   Condição: A conta (código de agência e número da conta) não é encontrada na consulta ao cadastro de contas (SQLCODE = +100).
   Consequência: A operação não é realizada e o código de falha 1 é devolvido (COMM-FAIL-CODE = '1').
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)

4. Regra: Débito de pagamento (tipo de facilidade 496) é recusado por saldo insuficiente.
   Condição: O valor da operação é negativo, o tipo de facilidade é 496 e o saldo disponível somado ao valor da operação fica abaixo de zero (WS-DIFFERENCE < 0). O programa compara apenas o saldo disponível, sem considerar o limite de cheque especial (ACCOUNT-OVERDRAFT-LIM). Para débitos com outros tipos de facilidade não há teste de saldo.
   Consequência: A operação é recusada e o código de falha 3 é devolvido (COMM-FAIL-CODE = '3'); o saldo não é alterado.
   Parágrafo: UPDATE-ACCOUNT-DB2 (UAD010)

5. Regra: Débito comum no balcão é registrado como saque no balcão.
   Condição: O valor da operação é negativo e o tipo de facilidade não é 496.
   Consequência: A movimentação é registrada com o tipo DEB e a descrição "COUNTER WTHDRW".
   Parágrafo: WRITE-TO-PROCTRAN-DB2 (WTPD010)

6. Regra: Débito de pagamento (tipo de facilidade 496) é registrado como débito de pagamento, com a origem informada.
   Condição: O valor da operação é negativo e o tipo de facilidade é 496.
   Consequência: A movimentação é registrada com o tipo PDR e, como descrição, os 14 primeiros caracteres da origem da operação (COMM-ORIGIN).
   Parágrafo: WRITE-TO-PROCTRAN-DB2 (WTPD010)

7. Regra: Crédito comum no balcão é registrado como valor recebido no balcão.
   Condição: O valor da operação não é negativo e o tipo de facilidade não é 496.
   Consequência: A movimentação é registrada com o tipo CRE e a descrição "COUNTER RECVED".
   Parágrafo: WRITE-TO-PROCTRAN-DB2 (WTPD010)

8. Regra: Crédito de pagamento (tipo de facilidade 496) é registrado como crédito de pagamento, com a origem informada.
   Condição: O valor da operação não é negativo e o tipo de facilidade é 496.
   Consequência: A movimentação é registrada com o tipo PCR e, como descrição, os 14 primeiros caracteres da origem da operação (COMM-ORIGIN).
   Parágrafo: WRITE-TO-PROCTRAN-DB2 (WTPD010)