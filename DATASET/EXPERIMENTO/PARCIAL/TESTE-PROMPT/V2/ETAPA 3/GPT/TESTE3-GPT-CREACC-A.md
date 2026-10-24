1\. Regra: A abertura de uma conta somente pode prosseguir quando a consulta do cliente for concluída com sucesso.

- Condição: Quando a consulta do cliente não retorna confirmação de sucesso (INQCUST-INQ-SUCCESS diferente de 'Y').
- Consequência: A abertura da conta é recusada, com código de falha '1'.
- Parágrafo: PREMIERE (P010).

2\. Regra: Um cliente pode possuir no máximo 10 contas bancárias.

- Condição: Quando o cliente já possui mais de 9 contas (NUMBER-OF-ACCOUNTS > 9).
- Consequência: A abertura de uma nova conta é recusada, com código de falha '8'.
- Parágrafo: PREMIERE (P010).

3\. Regra: A abertura de uma conta é permitida quando o tipo informado pertence à lista de tipos aceitos.

- Condição: Quando o tipo de conta começa com 'ISA', 'MORTGAGE', 'SAVING', 'CURRENT' ou 'LOAN', considerando os comprimentos de comparação definidos no programa.
- Consequência: O tipo de conta é considerado válido e a abertura pode prosseguir.
- Parágrafo: ACCOUNT-TYPE-CHECK (ATC010).

4\. Regra: Não é permitida a abertura de contas com tipos diferentes dos tipos aceitos pelo banco.

- Condição: Quando o tipo informado não corresponde a nenhum dos valores 'ISA', 'MORTGAGE', 'SAVING', 'CURRENT' ou 'LOAN', nas posições verificadas pelo programa.
- Consequência: A abertura da conta é recusada, com código de falha 'A'.
- Parágrafo: ACCOUNT-TYPE-CHECK (ATC010).

5\. Regra: Nos meses de janeiro, março, maio, julho, agosto, outubro e dezembro, o cálculo da próxima data de extrato considera um acréscimo de 30 dias.

- Condição: Quando o mês de abertura da conta é 1, 3, 5, 7, 8, 10 ou 12.
- Consequência: São acrescentados 30 dias à data utilizada no cálculo do próximo extrato.
- Parágrafo: CALCULATE-DATES (CD010).

6\. Regra: Nos meses de abril, junho, setembro e novembro, o cálculo da próxima data de extrato considera um acréscimo de 30 dias.

- Condição: Quando o mês de abertura da conta é 4, 6, 9 ou 11.
- Consequência: São acrescentados 30 dias à data utilizada no cálculo do próximo extrato.
- Parágrafo: CALCULATE-DATES (CD010).

7\. Regra: Para contas abertas em fevereiro, o cálculo da próxima data de extrato considera inicialmente 28 dias.

- Condição: Quando o mês de abertura da conta é fevereiro.
- Consequência: São acrescentados 28 dias à data utilizada no cálculo do próximo extrato, sujeitos ao ajuste para ano bissexto.
- Parágrafo: CALCULATE-DATES (CD010).

8\. Regra: Em fevereiro de um ano divisível por 4, o cálculo da próxima data de extrato verifica se o ano também é divisível por 100.

- Condição: Quando o mês é fevereiro e o ano é divisível por 4.
- Consequência: O cálculo passa a considerar a regra de exceção dos anos centenários para determinar se deve acrescentar um dia.
- Parágrafo: CALCULATE-DATES (CD010).

9\. Regra: Em fevereiro de um ano divisível por 4, mas não por 100, o prazo considerado para o próximo extrato é de 29 dias.

- Condição: Quando o ano é divisível por 4 e não é divisível por 100.
- Consequência: É acrescentado mais um dia aos 28 dias inicialmente considerados.
- Parágrafo: CALCULATE-DATES (CD010).

10\. Regra: Em fevereiro de um ano divisível por 100, o acréscimo do dia bissexto depende de o ano também ser divisível por 400.

- Condição: Quando o ano é divisível por 4 e por 100.
- Consequência: O programa verifica a divisibilidade por 400 para decidir se acrescenta um dia ao cálculo.
- Parágrafo: CALCULATE-DATES (CD010).

11\. Regra: Em fevereiro de um ano divisível por 400, o prazo considerado para o próximo extrato é de 29 dias.

- Condição: Quando o ano é divisível por 400, no processamento de fevereiro.
- Consequência: É acrescentado mais um dia aos 28 dias inicialmente considerados.
- Parágrafo: CALCULATE-DATES (CD010).

12\. Regra: Em fevereiro de um ano divisível por 100, mas não por 400, o prazo considerado para o próximo extrato permanece em 28 dias.

- Condição: Quando o ano é divisível por 100 e não é divisível por 400.
- Consequência: Não é acrescentado o dia adicional referente ao ano bissexto.
- Parágrafo: CALCULATE-DATES (CD010).