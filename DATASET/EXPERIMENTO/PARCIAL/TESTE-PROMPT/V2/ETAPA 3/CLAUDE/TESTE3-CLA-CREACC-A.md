1. Regra: A conta não pode ser criada se o cliente informado não existir ou não puder ser consultado.
   Condição: A consulta ao cliente (INQCUST) retorna resposta diferente de normal ou indicador de sucesso diferente de 'Y' (INQCUST-INQ-SUCCESS).
   Consequência: A criação é recusada com indicador de falha 'N' e código de falha '1', e o processamento é encerrado.
   Parágrafo: PREMIERE (P010)

2. Regra: A conta não pode ser criada quando a contagem das contas existentes do cliente falha.
   Condição: A consulta de contas do cliente (INQACCCU) retorna resposta diferente de normal.
   Consequência: A criação é recusada com indicador de falha 'N' e código de falha '9', e o processamento é encerrado.
   Parágrafo: PREMIERE (P010)

3. Regra: A conta não pode ser criada quando a consulta de contas do cliente informa que não teve sucesso.
   Condição: O indicador de sucesso retornado pela consulta de contas do cliente (COMM-SUCCESS em INQACCCU-COMMAREA) é 'N'.
   Consequência: A criação é recusada com indicador de falha 'N' e código de falha '9', e o processamento é encerrado.
   Parágrafo: PREMIERE (P010)

4. Regra: Um cliente não pode ter mais de 9 contas; ao atingir esse limite, não é permitido abrir nova conta.
   Condição: O número de contas já existentes do cliente (NUMBER-OF-ACCOUNTS) é maior que 9, ou seja, 10 ou mais.
   Consequência: A criação é recusada com indicador de falha 'N' e código de falha '8', e o processamento é encerrado.
   Parágrafo: PREMIERE (P010)

5. Regra: Apenas os tipos de conta ISA, MORTGAGE, SAVING, CURRENT e LOAN são aceitos na abertura de conta.
   Condição: O tipo de conta informado (COMM-ACC-TYPE) começa com 'ISA', 'MORTGAGE', 'SAVING', 'CURRENT' ou 'LOAN' (comparação apenas pelo início do campo, conforme o tamanho de cada palavra).
   Consequência: O tipo de conta é considerado válido e o processamento segue.
   Parágrafo: ACCOUNT-TYPE-CHECK (ATC010)

6. Regra: Tipos de conta fora da lista aceita são recusados.
   Condição: O tipo de conta informado (COMM-ACC-TYPE) não corresponde a nenhum dos valores aceitos (WHEN OTHER).
   Consequência: A criação é recusada com indicador de falha 'N' e código de falha 'A'.
   Parágrafo: ACCOUNT-TYPE-CHECK (ATC010)

7. Regra: Se o tipo de conta for inválido, a abertura da conta é interrompida.
   Condição: Após a verificação do tipo de conta, o indicador de sucesso (COMM-SUCCESS) está 'N'.
   Consequência: O processamento é encerrado sem criar a conta.
   Parágrafo: PREMIERE (P010)

8. Regra: A abertura de conta é recusada quando não é possível reservar o controle de numeração de contas do banco.
   Condição: O bloqueio do contador de numeração de contas (ENQ) retorna resposta diferente de normal.
   Consequência: A criação é recusada com indicador de falha 'N' e código de falha '3', e o processamento é encerrado.
   Parágrafo: ENQ-NAMED-COUNTER (ENC010)

9. Regra: A abertura de conta é recusada quando a gravação da nova conta não é concluída.
   Condição: A inclusão da conta no cadastro (INSERT em ACCOUNT) retorna código diferente de zero.
   Consequência: A criação é recusada com indicador de falha 'N' e código de falha '7', e o processamento é encerrado.
   Parágrafo: WRITE-ACCOUNT-DB2 (WAD010)

10. Regra: Fevereiro tem 28 dias no cálculo da data do próximo extrato, com ajuste de mais um dia em ano bissexto. Esse cálculo de datas (CALCULATE-DATES) alimenta apenas campos de uso interno; a data do próximo extrato efetivamente gravada na conta é a abertura mais 30 dias, calculada em WRITE-ACCOUNT-DB2 (ver item 14).
    Condição: O mês de abertura (WS-ORIG-DATE-MM) é fevereiro.
    Consequência: Soma-se 28 dias à data de abertura para obter a data do próximo extrato.
    Parágrafo: CALCULATE-DATES (CD010)

11. Regra: Em fevereiro, o ano é bissexto quando divisível por 4 e não divisível por 100.
    Condição: O mês é fevereiro, o ano é divisível por 4 e o ano não é divisível por 100.
    Consequência: Soma-se mais 1 dia ao prazo do próximo extrato (29 dias no total).
    Parágrafo: CALCULATE-DATES (CD010)

12. Regra: Em fevereiro, o ano divisível por 100 só é bissexto se também for divisível por 400.
    Condição: O mês é fevereiro, o ano é divisível por 4 e por 100, e é divisível por 400.
    Consequência: Soma-se mais 1 dia ao prazo do próximo extrato (29 dias no total).
    Parágrafo: CALCULATE-DATES (CD010)

13. Regra: Em meses de 31 dias e em meses de 30 dias, o próximo extrato é calculado com 30 dias após a data de abertura (ambos os grupos recebem o mesmo prazo).
    Condição: O mês de abertura (WS-ORIG-DATE-MM) é 1, 3, 5, 7, 8, 10 ou 12 (meses de 31 dias) ou 4, 6, 9 ou 11 (meses de 30 dias).
    Consequência: Soma-se 30 dias à data de abertura para obter a data do próximo extrato (valor usado apenas em campos internos; ver item 10).
    Parágrafo: CALCULATE-DATES (CD010)

14. Regra: Na gravação da conta, a data do próximo extrato é sempre 30 dias após a data de abertura, independentemente do mês. Esse comportamento é fixo no código e não depende de decisão; foi listado aqui apenas para registrar a divergência em relação à regra de calendário de CALCULATE-DATES, que não afeta o valor gravado. Se o negócio espera prazo variável por mês (28/29 dias em fevereiro), o código gravado não o implementa.
    Condição: Qualquer abertura de conta, sem teste condicional.
    Consequência: Próximo extrato gravado = data de abertura + 30 dias.
    Parágrafo: WRITE-ACCOUNT-DB2 (WAD010)