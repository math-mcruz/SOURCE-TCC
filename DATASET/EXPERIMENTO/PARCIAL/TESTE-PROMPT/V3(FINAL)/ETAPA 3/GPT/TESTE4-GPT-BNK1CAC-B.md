1\. Regra: O número do cliente é obrigatório para solicitar a criação de uma conta bancária.\
Condição: o número do cliente não foi informado (CUSTNOL inferior a 1 ou CUSTNOI igual a '\_\_\_\_\_\_\_\_\_\_').\
Consequência: a solicitação é considerada inválida, a criação da conta não é realizada e é exibida a mensagem 'Please enter a 10 digit Customer Number'.\
Parágrafo: ED010 (EDIT-DATA)

2\. Regra: O tipo de conta bancária é obrigatório para solicitar a criação de uma conta.\
Condição: o tipo de conta não foi informado (ACCTYPI igual a '\_\_\_\_\_\_\_\_' ou ACCTYPL inferior a 1).\
Consequência: a solicitação é considerada inválida, a criação da conta não é realizada e é exibida a mensagem 'Account Type should be ISA,CURRENT,LOAN,SAVING or MORTGAGE'.\
Parágrafo: ED010 (EDIT-DATA)

3\. Regra: O sistema aceita os tipos de conta ISA, CURRENT, LOAN, SAVING e MORTGAGE, inclusive quando informados em letras minúsculas ou nas variantes com sublinhados previstas pelo programa.\
Condição: o tipo de conta informado corresponde a uma das alternativas reconhecidas pelo programa.\
Consequência: o tipo de conta é aceito e, quando necessário, padronizado em letras maiúsculas para continuar a solicitação.\
Parágrafo: ED010 (EDIT-DATA)

4\. Regra: A criação de uma conta bancária não é permitida quando o tipo de conta informado é diferente de ISA, CURRENT, LOAN, SAVING ou MORTGAGE, considerando as variantes aceitas pelo programa.\
Condição: o tipo de conta informado não corresponde a nenhuma das alternativas reconhecidas.\
Consequência: a solicitação é considerada inválida, a criação da conta não é realizada e é exibida a mensagem 'Account Type should be ISA,CURRENT,LOAN,SAVING or MORTGAGE'.\
Parágrafo: ED010 (EDIT-DATA)

5\. Regra: A taxa de juros é obrigatória para solicitar a criação de uma conta bancária.\
Condição: o campo da taxa de juros não foi preenchido (INTRTL igual a zero).\
Consequência: a solicitação é considerada inválida, a criação da conta não é realizada e é exibida a mensagem 'Please supply a numeric interest rate'.\
Parágrafo: ED010 (EDIT-DATA)

6\. Regra: A taxa de juros informada não pode ser negativa.\
Condição: o valor da taxa de juros é inferior a zero (INTRTI-COMP-1 menor que 0).\
Consequência: a solicitação é considerada inválida, a criação da conta não é realizada e é exibida a mensagem 'Please supply a zero or positive interest rate'.\
Parágrafo: ED010 (EDIT-DATA)

7\. Regra: A taxa de juros informada não pode ultrapassar 9999,99%.\
Condição: o valor da taxa de juros é superior a 9999,99 (INTRTI-COMP-1 maior que 9999.99).\
Consequência: a solicitação é considerada inválida, a criação da conta não é realizada e é exibida a mensagem 'Please supply an interest rate less than 9999.99%'. Apesar da mensagem mencionar um valor inferior a 9999,99%, a condição implementada permite o valor exatamente igual a 9999,99.\
Parágrafo: ED010 (EDIT-DATA)

8\. Regra: Quando o limite de cheque especial não é informado, o sistema considera que a conta terá limite igual a zero.\
Condição: o campo de limite de cheque especial está vazio, contém apenas espaços ou apresenta o preenchimento padrão '' (OVERDRL inferior a 1, OVERDRI igual a espaços ou '').\
Consequência: o limite de cheque especial é definido como zero, sem impedir a continuidade da solicitação.\
Parágrafo: ED010 (EDIT-DATA)

9\. Regra: A solicitação de criação de conta não pode prosseguir quando faltam os dados obrigatórios de identificação do cliente ou do tipo de conta.\
Condição: após as demais verificações, o número do cliente ou o tipo de conta apresenta comprimento inferior a 1 (CUSTNOL menor que 1 ou ACCTYPL menor que 1).\
Consequência: a solicitação é considerada inválida, a criação da conta não é realizada e é exibida a mensagem 'Missing expected data.'.\
Parágrafo: ED010 (EDIT-DATA)

10\. Regra: A criação da conta bancária somente é solicitada quando os dados informados passam pelas validações do programa.\
Condição: as validações dos dados terminam com o indicador de validade positivo (VALID-DATA igual a 'Y').\
Consequência: o sistema encaminha a solicitação de criação da conta para o processamento pelo programa CREACC.\
Parágrafo: PM010 (PROCESS-MAP)

11\. Regra: Quando a criação da conta é recusada porque o número do cliente não existe, a solicitação é considerada malsucedida.\
Condição: o processamento da criação retorna indicador de insucesso (SUBPGM-SUCCESS igual a 'N') e código de falha '1'.\
Consequência: a conta não é confirmada como criada e é exibida a mensagem 'The supplied customer number does not exist.'.\
Parágrafo: CAD010 (CRE-ACC-DATA)

12\. Regra: Quando os dados cadastrais do cliente não podem ser acessados, a criação da conta é considerada malsucedida.\
Condição: o processamento da criação retorna indicador de insucesso (SUBPGM-SUCCESS igual a 'N') e código de falha '2'.\
Consequência: a conta não é confirmada como criada e é exibida a mensagem 'The customer data cannot be accessed, unable to create account.'.\
Parágrafo: CAD010 (CRE-ACC-DATA)

13\. Regra: Quando a criação da conta é recusada por excesso de contas, a solicitação é considerada malsucedida.\
Condição: o processamento da criação retorna indicador de insucesso (SUBPGM-SUCCESS igual a 'N') e código de falha '8'.\
Consequência: a conta não é confirmada como criada e é exibida a mensagem 'Account record creation failed, (too many accounts).'. O programa não informa qual é a quantidade máxima de contas permitida.\
Parágrafo: CAD010 (CRE-ACC-DATA)

14\. Regra: Quando a criação da conta é recusada porque o tipo de conta não é suportado, a solicitação é considerada malsucedida.\
Condição: o processamento da criação retorna indicador de insucesso (SUBPGM-SUCCESS igual a 'N') e código de falha 'A'.\
Consequência: a conta não é confirmada como criada e é exibida a mensagem 'Account record creation failed, account type unsupported.'.\
Parágrafo: CAD010 (CRE-ACC-DATA)

15\. Regra: Quando a criação da conta é recusada por um motivo não identificado entre os códigos de falha tratados, o sistema informa que a conta não foi criada.\
Condição: o processamento da criação retorna indicador de insucesso (SUBPGM-SUCCESS igual a 'N') e um código de falha diferente de '1', '2', '3', '4', '5', '6', '7', '8', '9' e 'A'.\
Consequência: a solicitação é considerada malsucedida e é exibida a mensagem 'The account was not created.'.\
Parágrafo: CAD010 (CRE-ACC-DATA)

16\. Regra: Quando o processamento da criação da conta retorna resultado positivo, o sistema confirma a criação da conta bancária.\
Condição: o indicador de sucesso retornado pelo processamento é diferente de 'N' (SUBPGM-SUCCESS diferente de 'N').\
Consequência: é exibida a mensagem 'The Account has been successfully created' e são apresentados os dados da conta criada, incluindo identificação bancária, datas e saldos. O programa considera qualquer valor diferente de 'N' como sucesso.\
Parágrafo: CAD010 (CRE-ACC-DATA)