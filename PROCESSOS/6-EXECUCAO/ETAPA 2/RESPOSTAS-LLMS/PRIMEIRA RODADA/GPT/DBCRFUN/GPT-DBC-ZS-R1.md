1\. Regra: A conta bancária deve existir para que a movimentação financeira seja realizada.\
Condição: Quando a conta informada não é encontrada no cadastro de contas (SQLCODE = +100).\
Consequência: A movimentação é recusada e retorna o código de falha 1.\
Parágrafo: UAD010

2\. Regra: Não é permitido realizar débitos em contas de financiamento imobiliário ou empréstimo por meio de operações da modalidade 496.\
Condição: Quando o valor da movimentação é negativo (COMM-AMT < 0), o tipo da conta é MORTGAGE ou LOAN e a modalidade da operação é 496 (COMM-FACILTYPE = 496).\
Consequência: A movimentação é recusada e retorna o código de falha 4.\
Parágrafo: UAD010

3\. Regra: Uma operação de débito da modalidade 496 não pode deixar o saldo disponível da conta negativo.\
Condição: Quando o valor da movimentação é negativo, a soma do saldo disponível com o valor da movimentação é inferior a zero e a modalidade da operação é 496, desde que a operação não tenha sido recusada pela restrição do tipo de conta.\
Consequência: A movimentação é recusada por insuficiência de saldo disponível e retorna o código de falha 3.\
Parágrafo: UAD010

4\. Regra: Não é permitido realizar movimentações de valor positivo ou zero em contas de financiamento imobiliário ou empréstimo por meio de operações da modalidade 496.\
Condição: Quando o valor da movimentação é maior ou igual a zero, o tipo da conta é MORTGAGE ou LOAN e a modalidade da operação é 496.\
Consequência: A movimentação é recusada e retorna o código de falha 4.\
Parágrafo: UAD010

5\. Regra: Uma movimentação de valor negativo realizada fora da modalidade 496 deve ser classificada como retirada de dinheiro no caixa.\
Condição: Quando o valor da movimentação é negativo (COMM-AMT < 0) e a modalidade da operação é diferente de 496.\
Consequência: A movimentação é identificada pelo tipo DEB e pela descrição COUNTER WTHDRW.\
Parágrafo: WTPD010

6\. Regra: Uma movimentação de valor negativo realizada na modalidade 496 deve ser classificada como débito específico dessa modalidade.\
Condição: Quando o valor da movimentação é negativo e a modalidade da operação é 496, desde que a movimentação tenha sido aceita pelas validações anteriores.\
Consequência: A movimentação é identificada pelo tipo PDR e recebe como descrição os primeiros 14 caracteres da origem informada (COMM-ORIGIN).\
Parágrafo: WTPD010

7\. Regra: Uma movimentação de valor positivo ou zero realizada fora da modalidade 496 deve ser classificada como recebimento no caixa.\
Condição: Quando o valor da movimentação é maior ou igual a zero (COMM-AMT >= 0) e a modalidade da operação é diferente de 496.\
Consequência: A movimentação é identificada pelo tipo CRE e pela descrição COUNTER RECVED.\
Parágrafo: WTPD010

8\. Regra: Uma movimentação de valor positivo ou zero realizada na modalidade 496 deve ser classificada como crédito específico dessa modalidade.\
Condição: Quando o valor da movimentação é maior ou igual a zero e a modalidade da operação é 496, desde que a movimentação tenha sido aceita pelas validações anteriores.\
Consequência: A movimentação é identificada pelo tipo PCR e recebe como descrição os primeiros 14 caracteres da origem informada (COMM-ORIGIN).\
Parágrafo: WTPD010

9\. Regra: Uma movimentação financeira deve ser confirmada como concluída quando seu registro é realizado com sucesso.\
Condição: Quando a inclusão da movimentação no cadastro de transações processadas (PROCTRAN) é concluída com sucesso (SQLCODE = 0).\
Consequência: A movimentação é confirmada como bem-sucedida (COMM-SUCCESS = Y) e retorna o código de falha 0, indicando ausência de falha.\
Parágrafo: WTPD010