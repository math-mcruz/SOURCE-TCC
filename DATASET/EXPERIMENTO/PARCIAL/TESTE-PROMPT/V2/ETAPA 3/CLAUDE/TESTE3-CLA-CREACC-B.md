1. Regra: Só é possível abrir uma conta para um cliente que exista. Se a consulta do cliente falhar ou não indicar sucesso (INQCUST-INQ-SUCCESS diferente de 'Y'), a abertura da conta não é feita e é sinalizada como malsucedida com o código de falha '1'. O teste também cobre falha técnica da chamada (EIBRESP diferente de NORMAL), e o código não distingue "cliente não encontrado" de outros motivos.
   Condição: a consulta do cliente retorna resposta diferente de NORMAL ou indicador de sucesso diferente de 'Y'
   Consequência: a conta não é criada; indicador de sucesso 'N' e código de falha '1'
   Parágrafo: P010 (PREMIERE SECTION)

2. Regra: Um cliente não pode abrir nova conta se já tiver mais de 9 contas. Com 10 ou mais contas existentes, a abertura é recusada com o código de falha '8'. Com exatamente 9 contas, a abertura ainda é aceita, o que leva o cliente a até 10 contas.
   Condição: número de contas do cliente maior que 9 (NUMBER-OF-ACCOUNTS)
   Consequência: a conta não é criada; indicador de sucesso 'N' e código de falha '8'
   Parágrafo: P010 (PREMIERE SECTION)

3. Regra: O tipo de conta informado deve ser ISA, MORTGAGE, SAVING, CURRENT ou LOAN. Com qualquer outro tipo, a abertura é recusada com o código de falha 'A'. O programa compara apenas o início do campo (3, 8, 6, 7 e 4 primeiros caracteres, respectivamente); por isso, um valor que apenas comece com um desses nomes pode ser aceito (ambíguo).
   Condição: tipo de conta (COMM-ACC-TYPE) não começa com nenhum dos tipos aceitos
   Consequência: indicador de sucesso 'N' e código de falha 'A'; em seguida, a abertura da conta é encerrada sem criar a conta
   Parágrafo: ATC010 (ACCOUNT-TYPE-CHECK)

4. Regra: No cálculo da data do próximo extrato, para contas abertas em meses de 31 dias (janeiro, março, maio, julho, agosto, outubro e dezembro), são somados 30 dias à data de referência. O valor gravado na conta é recalculado depois como 30 dias após a abertura, sem essa decisão (ambíguo).
   Condição: mês da data de abertura é 1, 3, 5, 7, 8, 10 ou 12
   Consequência: data do próximo extrato = data de abertura + 30 dias
   Parágrafo: CD010 (CALCULATE-DATES)

5. Regra: No cálculo da data do próximo extrato, para contas abertas em meses de 30 dias (abril, junho, setembro e novembro), são somados 30 dias à data de referência. O valor gravado na conta é recalculado depois como 30 dias após a abertura (ambíguo).
   Condição: mês da data de abertura é 4, 6, 9 ou 11
   Consequência: data do próximo extrato = data de abertura + 30 dias
   Parágrafo: CD010 (CALCULATE-DATES)

6. Regra: No cálculo da data do próximo extrato, para contas abertas em fevereiro, são somados 28 dias à data de referência, com ajuste de 1 dia adicional em ano bissexto (regras seguintes).
   Condição: mês da data de abertura é 2
   Consequência: data do próximo extrato = data de abertura + 28 dias (mais o ajuste de ano bissexto, quando aplicável)
   Parágrafo: CD010 (CALCULATE-DATES)

7. Regra: Em fevereiro, se o ano for divisível por 4 e não for divisível por 100, é somado 1 dia ao prazo do próximo extrato (ano bissexto).
   Condição: mês igual a 2, ano divisível por 4 e não divisível por 100
   Consequência: soma 1 dia ao prazo (total de 29 dias)
   Parágrafo: CD010 (CALCULATE-DATES)

8. Regra: Em fevereiro, se o ano for divisível por 4, por 100 e também por 400, é somado 1 dia ao prazo do próximo extrato (ano bissexto). Se for divisível por 4 e por 100 mas não por 400, nada é somado.
   Condição: mês igual a 2, ano divisível por 4, por 100 e por 400
   Consequência: soma 1 dia ao prazo (total de 29 dias)
   Parágrafo: CD010 (CALCULATE-DATES)