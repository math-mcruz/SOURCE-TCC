1. Regra: Para abrir uma conta, o cliente informado precisa existir. Se a consulta ao cliente falhar ou não retornar sucesso (INQCUST-INQ-SUCCESS diferente de 'Y'), a criação da conta não é feita e é sinalizada como malsucedida com o código de falha '1'.
   Condição: a consulta do cliente retorna erro ou indicador de sucesso diferente de 'Y'
   Consequência: a conta não é criada; indicador de sucesso 'N' e código de falha '1'
   Parágrafo: P010 (PREMIERE SECTION)

2. Regra: Se a contagem das contas do cliente falhar (resposta diferente de normal na chamada de consulta), a criação da conta não é feita e é sinalizada como malsucedida com o código de falha '9'.
   Condição: a chamada de contagem das contas do cliente retorna resposta diferente de normal
   Consequência: a conta não é criada; indicador de sucesso 'N' e código de falha '9'
   Parágrafo: P010 (PREMIERE SECTION)

3. Regra: Se a consulta de contas do cliente informar que não teve sucesso (COMM-SUCCESS = 'N' no retorno de INQACCCU), a criação da conta não é feita e é sinalizada como malsucedida com o código de falha '9'.
   Condição: o retorno da consulta de contas do cliente traz indicador de sucesso 'N'
   Consequência: a conta não é criada; indicador de sucesso 'N' e código de falha '9'
   Parágrafo: P010 (PREMIERE SECTION)

4. Regra: Um cliente pode ter no máximo 10 contas. Se o cliente já possuir mais de 9 contas, não é permitido abrir outra e a operação é sinalizada como malsucedida com o código de falha '8'.
   Condição: número de contas do cliente maior que 9
   Consequência: a conta não é criada; indicador de sucesso 'N' e código de falha '8'
   Parágrafo: P010 (PREMIERE SECTION)

5. Regra: Se a verificação do tipo de conta indicar falha (indicador de sucesso 'N'), a criação da conta é encerrada sem abrir a conta. Esse indicador só é 'N' quando o tipo de conta não é aceito (ver regra do tipo de conta em ATC010).
   Condição: indicador de sucesso igual a 'N' após a verificação do tipo de conta
   Consequência: a criação da conta é encerrada e a conta não é criada
   Parágrafo: P010 (PREMIERE SECTION)

6. Regra: O tipo de conta deve ser ISA, MORTGAGE, SAVING, CURRENT ou LOAN. Com qualquer outro tipo, a conta não é criada e a operação é sinalizada como malsucedida com o código de falha 'A'. O programa compara apenas o início do campo (3, 8, 6, 7 e 4 primeiros caracteres, respectivamente), de modo que o texto após o nome do tipo não é verificado.
   Condição: o tipo de conta informado não começa com ISA, MORTGAGE, SAVING, CURRENT nem LOAN
   Consequência: indicador de sucesso 'N' e código de falha 'A'
   Parágrafo: ATC010 (ACCOUNT-TYPE-CHECK)

7. Regra: Se o tipo de conta informado é um dos aceitos (ISA, MORTGAGE, SAVING, CURRENT ou LOAN), a verificação é considerada bem-sucedida e a abertura da conta prossegue.
   Condição: o início do tipo de conta corresponde a um dos tipos aceitos
   Consequência: indicador de sucesso 'Y' e a abertura da conta segue
   Parágrafo: ATC010 (ACCOUNT-TYPE-CHECK)

8. Regra: Ao calcular a data do próximo extrato na rotina de cálculo de datas, a data de abertura da conta é acrescida de 30 dias para os meses de 31 dias (janeiro, março, maio, julho, agosto, outubro e dezembro). Observação: o resultado dessa rotina para a data do próximo extrato é depois sobrescrito pelo cálculo de 30 dias feito na gravação da conta.
   Condição: mês de abertura é 1, 3, 5, 7, 8, 10 ou 12
   Consequência: próxima data de extrato calculada como a data de abertura mais 30 dias
   Parágrafo: CD010 (CALCULATE-DATES)

9. Regra: Ao calcular a data do próximo extrato na rotina de cálculo de datas, a data de abertura da conta é acrescida de 30 dias também para os meses de abril, junho, setembro e novembro. Observação: o resultado dessa rotina para a data do próximo extrato é depois sobrescrito pelo cálculo de 30 dias feito na gravação da conta.
   Condição: mês de abertura é 4, 6, 9 ou 11
   Consequência: próxima data de extrato calculada como a data de abertura mais 30 dias
   Parágrafo: CD010 (CALCULATE-DATES)

10. Regra: Ao calcular a data do próximo extrato na rotina de cálculo de datas, para contas abertas em fevereiro de ano não bissexto são acrescidos 28 dias à data de abertura. Observação: o resultado dessa rotina para a data do próximo extrato é depois sobrescrito pelo cálculo de 30 dias feito na gravação da conta.
    Condição: mês de abertura é fevereiro e o ano não é bissexto (não divisível por 4, ou divisível por 100 e não por 400)
    Consequência: próxima data de extrato calculada como a data de abertura mais 28 dias
    Parágrafo: CD010 (CALCULATE-DATES)

11. Regra: Ao calcular a data do próximo extrato na rotina de cálculo de datas, para contas abertas em fevereiro de ano bissexto são acrescidos 29 dias à data de abertura (ano divisível por 4 e não por 100, ou divisível por 400). Observação: o resultado dessa rotina para a data do próximo extrato é depois sobrescrito pelo cálculo de 30 dias feito na gravação da conta.
    Condição: mês de abertura é fevereiro e o ano é bissexto
    Consequência: próxima data de extrato calculada como a data de abertura mais 29 dias
    Parágrafo: CD010 (CALCULATE-DATES)