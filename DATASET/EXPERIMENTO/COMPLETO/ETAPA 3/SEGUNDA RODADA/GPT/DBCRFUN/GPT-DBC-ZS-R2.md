1\. Regra: Uma operação financeira não pode ser realizada quando a conta bancária informada não existe.\
Condição: Quando a consulta da conta pelo código da agência e número da conta não encontra nenhum registro (SQLCODE = +100).\
Consequência: A operação é recusada, com indicação de insucesso e código de falha 1.\
Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2).

2\. Regra: Não são permitidos débitos de operações da modalidade 496 em contas de financiamento imobiliário ou empréstimo.\
Condição: Quando o valor da operação é negativo (COMM-AMT < 0), a modalidade é 496 (COMM-FACILTYPE = 496) e o tipo da conta é MORTGAGE ou LOAN.\
Consequência: A operação é recusada, com indicação de insucesso e código de falha 4.\
Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2).

3\. Regra: Uma operação de débito da modalidade 496 não pode deixar o saldo disponível da conta negativo.\
Condição: Quando o valor da operação é negativo, a modalidade é 496, a conta não é MORTGAGE nem LOAN e a soma do saldo disponível com o valor da operação é inferior a zero.\
Consequência: A operação é recusada por insuficiência de saldo disponível, com indicação de insucesso e código de falha 3.\
Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2).

4\. Regra: Não são permitidas operações de valor positivo ou zero da modalidade 496 em contas de financiamento imobiliário ou empréstimo.\
Condição: Quando o valor da operação é maior ou igual a zero (COMM-AMT >= 0), a modalidade é 496 e o tipo da conta é MORTGAGE ou LOAN. O código repete a restrição da regra 2, mas os débitos dessas contas já foram recusados anteriormente.\
Consequência: A operação é recusada, com indicação de insucesso e código de falha 4.\
Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2).

5\. Regra: Uma operação de valor negativo fora da modalidade 496 é classificada como saque em guichê.\
Condição: Quando o valor da operação é negativo (COMM-AMT < 0) e a modalidade é diferente de 496.\
Consequência: A movimentação é classificada como débito, com tipo DEB e descrição COUNTER WTHDRW.\
Parágrafo: WTPD010 (WRITE-TO-PROCTRAN-DB2).

6\. Regra: Uma operação de valor negativo da modalidade 496 é classificada como débito específico dessa modalidade.\
Condição: Quando o valor da operação é negativo (COMM-AMT < 0), a modalidade é 496 e a operação passou pelas restrições de tipo de conta e saldo disponível.\
Consequência: A movimentação é classificada com tipo PDR e recebe como descrição os primeiros 14 caracteres da origem da operação (COMM-ORIGIN).\
Parágrafo: WTPD010 (WRITE-TO-PROCTRAN-DB2).

7\. Regra: Uma operação de valor positivo ou zero fora da modalidade 496 é classificada como recebimento em guichê.\
Condição: Quando o valor da operação é maior ou igual a zero (COMM-AMT >= 0) e a modalidade é diferente de 496.\
Consequência: A movimentação é classificada como crédito, com tipo CRE e descrição COUNTER RECVED.\
Parágrafo: WTPD010 (WRITE-TO-PROCTRAN-DB2).

8\. Regra: Uma operação de valor positivo ou zero da modalidade 496 é classificada como crédito específico dessa modalidade.\
Condição: Quando o valor da operação é maior ou igual a zero (COMM-AMT >= 0), a modalidade é 496 e a conta não é do tipo MORTGAGE nem LOAN.\
Consequência: A movimentação é classificada com tipo PCR e recebe como descrição os primeiros 14 caracteres da origem da operação (COMM-ORIGIN).\
Parágrafo: WTPD010 (WRITE-TO-PROCTRAN-DB2).

9\. Regra: Uma operação financeira é considerada concluída com sucesso após a atualização dos saldos da conta e o registro da movimentação.\
Condição: Quando a operação passa pelas restrições aplicáveis, a atualização da conta é bem-sucedida e o registro da movimentação é realizado com sucesso (SQLCODE = 0).\
Consequência: A operação é confirmada, com indicação de sucesso (COMM-SUCCESS = Y) e código de falha 0.\
Parágrafo: WTPD010 (WRITE-TO-PROCTRAN-DB2).