1. Regra: Só é possível abrir uma conta para um cliente que exista e cuja consulta ao cadastro tenha sido bem-sucedida.
   Condição: A consulta ao cadastro do cliente (INQCUST) não retorna resposta normal ou não retorna sucesso (INQCUST-INQ-SUCCESS diferente de 'Y').
   Consequência: A criação da conta é recusada, com indicação de falha código '1' (cliente não encontrado/inválido), e o processamento é encerrado.
   Parágrafo: PREMIERE (P010)

2. Regra: Se não for possível apurar quantas contas o cliente já possui, a abertura da conta é recusada.
   Condição: A consulta de contas do cliente (INQACCCU) retorna resposta diferente de normal.
   Consequência: A criação da conta é recusada, com indicação de falha código '9', e o processamento é encerrado.
   Parágrafo: PREMIERE (P010)

3. Regra: Se a consulta das contas do cliente indicar insucesso, a abertura da conta é recusada.
   Condição: O indicador de sucesso retornado pela consulta de contas do cliente (COMM-SUCCESS de INQACCCU) é 'N'.
   Consequência: A criação da conta é recusada, com indicação de falha código '9', e o processamento é encerrado.
   Parágrafo: PREMIERE (P010)

4. Regra: Um cliente não pode ter mais de 9 contas; a abertura de uma nova conta é recusada quando o cliente já tem mais de 9.
   Condição: O número de contas existentes do cliente é maior que 9 (NUMBER-OF-ACCOUNTS > 9). Observação: como o teste é "maior que 9", um cliente com exatamente 9 contas ainda pode abrir mais uma; o limite efetivo permite chegar a 10 contas.
   Consequência: A criação da conta é recusada, com indicação de falha código '8', e o processamento é encerrado.
   Parágrafo: PREMIERE (P010)

5. Regra: O tipo de conta deve ser um dos tipos aceitos: ISA, MORTGAGE, SAVING, CURRENT ou LOAN.
   Condição: O tipo de conta informado (COMM-ACC-TYPE) começa com 'ISA', 'MORTGAGE', 'SAVING', 'CURRENT' ou 'LOAN'. Observação: o teste compara apenas o início do campo (os primeiros 3, 8, 6, 7 ou 4 caracteres, conforme o tipo), de modo que textos que apenas comecem com esses valores também são aceitos.
   Consequência: O tipo de conta é considerado válido e a abertura da conta prossegue.
   Parágrafo: ACCOUNT-TYPE-CHECK (ATC010)

6. Regra: Tipos de conta fora da lista aceita são recusados.
   Condição: O tipo de conta informado não é nenhum dos tipos aceitos (ISA, MORTGAGE, SAVING, CURRENT, LOAN).
   Consequência: A criação da conta é recusada, com indicação de falha código 'A' (tipo de conta inválido).
   Parágrafo: ACCOUNT-TYPE-CHECK (ATC010)

7. Regra: Se o tipo de conta for considerado inválido, a abertura da conta é interrompida.
   Condição: O indicador de sucesso da operação (COMM-SUCCESS) é 'N' após a verificação do tipo de conta.
   Consequência: O processamento é encerrado sem criar a conta.
   Parágrafo: PREMIERE (P010)

8. Regra: A data do próximo extrato de uma conta nova é calculada como 30 dias após a data de abertura.
   Condição: Abertura de uma nova conta (gravação da conta no cadastro). Observação: o programa também calcula, em CALCULATE-DATES, um prazo que varia conforme o mês (28 dias para fevereiro, mais 1 se bissexto, 30 para os demais), porém o valor efetivamente gravado na conta é o de 30 dias fixos, recalculado em WRITE-ACCOUNT-DB2.
   Consequência: A data do próximo extrato gravada é a data de abertura mais 30 dias, e a data do último extrato é igual à data de abertura.
   Parágrafo: WRITE-ACCOUNT-DB2

9. Regra: Em fevereiro, o prazo até o próximo extrato calculado considera o ano bissexto (ver observação na regra anterior: esse cálculo não é o valor gravado na conta).
   Condição: O mês da data de abertura é 2 e o ano é bissexto (divisível por 4 e não por 100, ou divisível por 400).
   Consequência: Soma-se 28 dias mais 1 dia (29 no total) à data de abertura no cálculo de CALCULATE-DATES; nos demais anos, soma-se 28 dias.
   Parágrafo: CALCULATE-DATES (CD010)

10. Regra: Nos meses de 31 dias e nos de 30 dias, o prazo calculado até o próximo extrato é de 30 dias (ver observação na regra 8: esse cálculo não é o valor gravado na conta).
    Condição: O mês da data de abertura é 1, 3, 5, 7, 8, 10 ou 12 (meses de 31 dias), ou 4, 6, 9 ou 11 (meses de 30 dias).
    Consequência: Soma-se 30 dias à data de abertura no cálculo de CALCULATE-DATES.
    Parágrafo: CALCULATE-DATES (CD010)

11. Regra: Se a gravação da nova conta não for concluída, a abertura é recusada.
    Condição: A inclusão da conta no cadastro de contas retorna código diferente de zero (SQLCODE diferente de 0).
    Consequência: A criação da conta é recusada, com indicação de falha código '7', e o processamento é encerrado.
    Parágrafo: WRITE-ACCOUNT-DB2 (WAD010)

12. Regra: Se a conta for criada com sucesso, a operação é confirmada ao solicitante.
    Condição: A gravação da conta e do registro da operação foi concluída sem recusa.
    Consequência: Retorna-se indicação de sucesso ('Y'), com o número da conta, o código da agência e as datas de abertura e de extratos.
    Parágrafo: WRITE-ACCOUNT-DB2 (WAD010)