1\. Regra: O número do cliente é obrigatório para solicitar a criação de uma conta bancária. Se não for informado, a solicitação é considerada inválida.\
Condição: o número do cliente não foi informado (CUSTNOL menor que 1 ou CUSTNOI igual a '\_\_\_\_\_\_\_\_\_\_').\
Consequência: a solicitação é considerada inválida, é exibida a mensagem "Please enter a 10 digit Customer Number" e o processamento das demais validações é interrompido.\
Parágrafo: ED010 (EDIT-DATA)

2\. Regra: O tipo de conta é obrigatório para solicitar a criação de uma conta bancária.\
Condição: o tipo de conta não foi informado (ACCTYPI igual a '\_\_\_\_\_\_\_\_' ou ACCTYPL menor que 1).\
Consequência: a solicitação é considerada inválida, é exibida a mensagem "Account Type should be ISA,CURRENT,LOAN,SAVING or MORTGAGE" e o processamento das demais validações é interrompido.\
Parágrafo: ED010 (EDIT-DATA)

3\. Regra: O tipo de conta informado deve ser ISA, CURRENT, LOAN, SAVING ou MORTGAGE, sendo aceitas as versões em letras maiúsculas ou minúsculas desses valores.\
Condição: o tipo de conta informado corresponde a um dos cinco tipos aceitos, nas representações reconhecidas pelo programa.\
Consequência: o tipo de conta é aceito e padronizado em letras maiúsculas para a solicitação de criação da conta.\
Parágrafo: ED010 (EDIT-DATA)

4\. Regra: Não é permitida a criação de uma conta com tipo diferente de ISA, CURRENT, LOAN, SAVING ou MORTGAGE.\
Condição: o tipo de conta informado não corresponde a nenhum dos valores aceitos pelo programa.\
Consequência: a solicitação é considerada inválida, é exibida a mensagem "Account Type should be ISA,CURRENT,LOAN,SAVING or MORTGAGE" e o processamento das demais validações é interrompido.\
Parágrafo: ED010 (EDIT-DATA)

5\. Regra: A taxa de juros é obrigatória para solicitar a criação de uma conta bancária.\
Condição: o campo da taxa de juros não foi preenchido (INTRTL igual a zero).\
Consequência: a solicitação é considerada inválida, é exibida a mensagem "Please supply a numeric interest rate" e o processamento das demais validações é interrompido.\
Parágrafo: ED010 (EDIT-DATA)

6\. Regra: A taxa de juros informada não pode ser negativa.\
Condição: a taxa de juros informada é menor que zero (INTRTI-COMP-1 menor que 0).\
Consequência: a solicitação é considerada inválida, é exibida a mensagem "Please supply a zero or positive interest rate" e o processamento das demais validações é interrompido.\
Parágrafo: ED010 (EDIT-DATA)

7\. Regra: A taxa de juros informada não pode ultrapassar 9999,99%.\
Condição: a taxa de juros informada é maior que 9999,99 (INTRTI-COMP-1 maior que 9999.99).\
Consequência: a solicitação é considerada inválida, é exibida a mensagem "Please supply an interest rate less than 9999.99%" e o processamento das demais validações é interrompido. Apesar de a mensagem exigir valor inferior a 9999,99%, o código aceita o valor exatamente igual a 9999,99.\
Parágrafo: ED010 (EDIT-DATA)

8\. Regra: Quando o limite de cheque especial não é informado, seu valor é considerado zero.\
Condição: o campo de limite de cheque especial está vazio, contém apenas espaços ou apresenta o valor '' (OVERDRL menor que 1, OVERDRI igual a espaços ou '').\
Consequência: o limite de cheque especial é definido como zero, permitindo que a solicitação prossiga sem um limite informado.\
Parágrafo: ED010 (EDIT-DATA)

9\. Regra: O número do cliente e o tipo de conta devem estar presentes para que a solicitação de criação da conta seja considerada válida.\
Condição: o número do cliente ou o tipo de conta está ausente (CUSTNOL menor que 1 ou ACCTYPL menor que 1).\
Consequência: a solicitação é considerada inválida e é exibida a mensagem "Missing expected data."; o processamento da validação é encerrado.\
Parágrafo: ED010 (EDIT-DATA)

10\. Regra: A criação da conta bancária somente é solicitada quando os dados informados são considerados válidos.\
Condição: todas as validações aplicáveis são concluídas sem invalidar os dados (VALID-DATA-SW igual a 'Y').\
Consequência: a solicitação é encaminhada para criação da conta bancária.\
Parágrafo: PM010 (PROCESS-MAP)

11\. Regra: Uma nova conta bancária é solicitada com o número do cliente informado.\
Condição: a solicitação de criação da conta passou pelas validações.\
Consequência: o número do cliente informado é utilizado na solicitação de criação da nova conta.\
Parágrafo: CAD010 (CRE-ACC-DATA)

12\. Regra: Uma nova conta bancária é solicitada com o tipo de conta informado e aceito na validação.\
Condição: a solicitação de criação da conta passou pelas validações.\
Consequência: o tipo de conta validado é utilizado na solicitação de criação da nova conta.\
Parágrafo: CAD010 (CRE-ACC-DATA)

13\. Regra: Uma nova conta bancária é solicitada com a taxa de juros informada.\
Condição: a solicitação de criação da conta passou pelas validações.\
Consequência: a taxa de juros informada é convertida para valor numérico e encaminhada para criação da conta.\
Parágrafo: CAD010 (CRE-ACC-DATA)

14\. Regra: Uma nova conta bancária é solicitada com o limite de cheque especial informado ou com valor zero quando não preenchido.\
Condição: a solicitação de criação da conta passou pelas validações.\
Consequência: o limite de cheque especial validado é encaminhado para criação da conta.\
Parágrafo: CAD010 (CRE-ACC-DATA)

15\. Regra: Os saldos disponível e efetivo de uma nova conta são inicialmente solicitados com valor zero.\
Condição: a solicitação de criação de uma nova conta é encaminhada ao processamento de criação.\
Consequência: o saldo disponível e o saldo efetivo são enviados com valor zero. A efetiva gravação desses valores depende do programa responsável pela criação da conta.\
Parágrafo: CAD010 (CRE-ACC-DATA)

16\. Regra: Quando o número do cliente informado não existe, a conta bancária não é criada.\
Condição: o processamento de criação da conta retorna insucesso com código de falha '1'.\
Consequência: a solicitação é considerada malsucedida e é exibida a mensagem "The supplied customer number does not exist."\
Parágrafo: CAD010 (CRE-ACC-DATA)

17\. Regra: Quando os dados do cliente não podem ser acessados, a criação da conta não é concluída.\
Condição: o processamento de criação da conta retorna insucesso com código de falha '2'.\
Consequência: a solicitação é considerada malsucedida e é exibida a mensagem "The customer data cannot be accessed, unable to create account."\
Parágrafo: CAD010 (CRE-ACC-DATA)

18\. Regra: A criação de uma conta bancária não é permitida quando o limite de quantidade de contas é excedido.\
Condição: o processamento de criação da conta retorna insucesso com código de falha '8', identificado como excesso de contas.\
Consequência: a solicitação é considerada malsucedida e é exibida a mensagem "Account record creation failed, (too many accounts)." O programa analisado não informa qual é o limite máximo de contas.\
Parágrafo: CAD010 (CRE-ACC-DATA)

19\. Regra: A criação de uma conta bancária não é concluída quando o tipo de conta solicitado não é suportado pelo processamento de criação.\
Condição: o processamento de criação da conta retorna insucesso com código de falha 'A'.\
Consequência: a solicitação é considerada malsucedida e é exibida a mensagem "Account record creation failed, account type unsupported."\
Parágrafo: CAD010 (CRE-ACC-DATA)

20\. Regra: Quando a criação de uma conta bancária não é concluída por um motivo não identificado entre os códigos de falha tratados, o cliente é informado de que a conta não foi criada.\
Condição: o processamento de criação retorna insucesso (SUBPGM-SUCCESS igual a 'N') com código de falha diferente dos códigos '1' a '9' e 'A'.\
Consequência: a solicitação é considerada malsucedida e é exibida a mensagem "The account was not created."\
Parágrafo: CAD010 (CRE-ACC-DATA)

21\. Regra: Quando uma conta bancária é criada com sucesso, a conclusão é comunicada ao solicitante.\
Condição: o processamento de criação da conta retorna indicador de sucesso diferente de 'N'.\
Consequência: é exibida a mensagem "The Account has been successfully created". O programa considera qualquer valor diferente de 'N' como sucesso, sem verificar explicitamente um indicador afirmativo.\
Parágrafo: CAD010 (CRE-ACC-DATA)

22\. Regra: Após a criação bem-sucedida de uma conta bancária, seu código bancário e número de conta são apresentados ao solicitante.\
Condição: o processamento de criação da conta retorna indicador de sucesso diferente de 'N'.\
Consequência: são apresentados o código bancário (SUBPGM-SORTCODE) e o número da conta criada (SUBPGM-NUMBER).\
Parágrafo: CAD010 (CRE-ACC-DATA)

23\. Regra: Após a criação bem-sucedida de uma conta bancária, a data de abertura da conta é apresentada ao solicitante.\
Condição: o processamento de criação da conta retorna indicador de sucesso diferente de 'N'.\
Consequência: a data de abertura devolvida pelo processamento de criação é apresentada em dia, mês e ano.\
Parágrafo: CAD010 (CRE-ACC-DATA)

24\. Regra: Após a criação bem-sucedida de uma conta bancária, a data prevista para o próximo extrato é apresentada ao solicitante.\
Condição: o processamento de criação da conta retorna indicador de sucesso diferente de 'N'.\
Consequência: a data do próximo extrato devolvida pelo processamento de criação é apresentada em dia, mês e ano.\
Parágrafo: CAD010 (CRE-ACC-DATA)

25\. Regra: Após a criação bem-sucedida de uma conta bancária, a data do último extrato é apresentada ao solicitante.\
Condição: o processamento de criação da conta retorna indicador de sucesso diferente de 'N'.\
Consequência: a data do último extrato devolvida pelo processamento de criação é apresentada em dia, mês e ano.\
Parágrafo: CAD010 (CRE-ACC-DATA)

26\. Regra: Após a criação bem-sucedida de uma conta bancária, o saldo disponível é apresentado ao solicitante.\
Condição: o processamento de criação da conta retorna indicador de sucesso diferente de 'N'.\
Consequência: o saldo disponível devolvido pelo processamento de criação é apresentado com sinal e duas casas decimais.\
Parágrafo: CAD010 (CRE-ACC-DATA)

27\. Regra: Após a criação bem-sucedida de uma conta bancária, o saldo efetivo é apresentado ao solicitante.\
Condição: o processamento de criação da conta retorna indicador de sucesso diferente de 'N'.\
Consequência: o saldo efetivo devolvido pelo processamento de criação é apresentado com sinal e duas casas decimais.\
Parágrafo: CAD010 (CRE-ACC-DATA)

28\. Regra: Após o processamento da solicitação de criação de conta, são apresentados os dados do cliente e as condições da conta retornados pelo processamento.\
Condição: a solicitação de criação da conta foi processada, independentemente de o indicador de sucesso ser 'N' ou diferente de 'N'.\
Consequência: são apresentados o número do cliente, o tipo de conta, a taxa de juros e o limite de cheque especial retornados pelo processamento de criação.\
Parágrafo: CAD010 (CRE-ACC-DATA)