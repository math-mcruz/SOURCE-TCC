1\. Regra: Uma movimentação financeira não pode ser realizada em uma conta que não esteja cadastrada no banco.\
Condição: Quando a conta informada não é encontrada no cadastro de contas (SQLCODE = +100).\
Consequência: A movimentação é recusada, com indicação de conta não encontrada (COMM-SUCCESS = 'N', COMM-FAIL-CODE = '1').\
Parágrafo: UAD010

2\. Regra: Movimentações de débito da modalidade 496 não são permitidas em contas de empréstimo ou financiamento imobiliário.\
Condição: Quando o valor da movimentação é negativo (COMM-AMT < 0), a modalidade é 496 (COMM-FACILTYPE = 496) e o tipo da conta é MORTGAGE ou LOAN.\
Consequência: A movimentação é recusada com código de impedimento da operação (COMM-FAIL-CODE = '4').\
Parágrafo: UAD010

3\. Regra: Uma movimentação de débito da modalidade 496 não pode deixar o saldo disponível da conta negativo.\
Condição: Quando o valor da movimentação é negativo, a modalidade é 496, a conta não foi rejeitada pela restrição anterior e a soma do saldo disponível com o valor da movimentação é inferior a zero.\
Consequência: A movimentação é recusada por insuficiência de saldo disponível (COMM-FAIL-CODE = '3').\
Parágrafo: UAD010

4\. Regra: Movimentações de valor positivo ou zero da modalidade 496 não são permitidas em contas de empréstimo ou financiamento imobiliário.\
Condição: Quando o valor da movimentação é maior ou igual a zero (COMM-AMT >= 0), a modalidade é 496 e o tipo da conta é MORTGAGE ou LOAN.\
Consequência: A movimentação é recusada com código de impedimento da operação (COMM-FAIL-CODE = '4').\
Parágrafo: UAD010

5\. Regra: Movimentações de débito de modalidades diferentes de 496 são classificadas como retirada em guichê.\
Condição: Quando o valor da movimentação é negativo (COMM-AMT < 0) e a modalidade é diferente de 496 (COMM-FACILTYPE NOT = 496).\
Consequência: A movimentação recebe o tipo DEB e a descrição COUNTER WTHDRW.\
Parágrafo: WTPD010

6\. Regra: Movimentações de débito da modalidade 496 são classificadas como PDR.\
Condição: Quando o valor da movimentação é negativo (COMM-AMT < 0) e a modalidade é 496 (COMM-FACILTYPE = 496).\
Consequência: A movimentação recebe o tipo PDR e uma descrição baseada nos primeiros 14 caracteres da origem informada (COMM-ORIGIN).\
Parágrafo: WTPD010

7\. Regra: Movimentações de valor positivo ou zero de modalidades diferentes de 496 são classificadas como recebimento em guichê.\
Condição: Quando o valor da movimentação é maior ou igual a zero (COMM-AMT >= 0) e a modalidade é diferente de 496.\
Consequência: A movimentação recebe o tipo CRE e a descrição COUNTER RECVED.\
Parágrafo: WTPD010

8\. Regra: Movimentações de valor positivo ou zero da modalidade 496 são classificadas como PCR.\
Condição: Quando o valor da movimentação é maior ou igual a zero (COMM-AMT >= 0) e a modalidade é 496 (COMM-FACILTYPE = 496).\
Consequência: A movimentação recebe o tipo PCR e uma descrição baseada nos primeiros 14 caracteres da origem informada (COMM-ORIGIN).\
Parágrafo: WTPD010

9\. Regra: Uma movimentação financeira é considerada concluída com sucesso quando seu registro é confirmado.\
Condição: Quando a gravação da movimentação é concluída com sucesso na base de transações (SQLCODE = 0 após INSERT em PROCTRAN).\
Consequência: A operação é sinalizada como bem-sucedida (COMM-SUCCESS = 'Y', COMM-FAIL-CODE = '0').\
Parágrafo: WTPD010