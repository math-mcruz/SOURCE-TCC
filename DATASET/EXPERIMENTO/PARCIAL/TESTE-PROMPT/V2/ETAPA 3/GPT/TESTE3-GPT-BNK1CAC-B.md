1\. Regra: O número do cliente é obrigatório para solicitar a criação de uma conta bancária.\
Condição: o número do cliente não foi informado (CUSTNOL menor que 1 ou CUSTNOI igual a '\_\_\_\_\_\_\_\_\_\_').\
Consequência: a solicitação é considerada inválida, a criação da conta não é realizada e é exibida a mensagem 'Please enter a 10 digit Customer Number'.\
Parágrafo: ED010 (EDIT-DATA)

2\. Regra: O tipo de conta é obrigatório para solicitar a criação de uma conta bancária.\
Condição: o tipo de conta não foi informado (ACCTYPI igual a '\_\_\_\_\_\_\_\_' ou ACCTYPL menor que 1).\
Consequência: a solicitação é considerada inválida, a criação da conta não é realizada e é exibida a mensagem 'Account Type should be ISA,CURRENT,LOAN,SAVING or MORTGAGE'.\
Parágrafo: ED010 (EDIT-DATA)

3\. Regra: O tipo de conta informado pode ser ISA, CURRENT, LOAN, SAVING ou MORTGAGE, sendo aceitas as representações previstas pelo programa em letras maiúsculas ou minúsculas.\
Condição: o tipo de conta informado corresponde a uma das representações reconhecidas pelo programa (ACCTYPI).\
Consequência: o tipo de conta é aceito e padronizado em letras maiúsculas para a solicitação de criação da conta.\
Parágrafo: ED010 (EDIT-DATA)

4\. Regra: Não é permitido solicitar a criação de uma conta com um tipo diferente de ISA, CURRENT, LOAN, SAVING ou MORTGAGE, considerando as representações aceitas pelo programa.\
Condição: o tipo de conta informado não corresponde a nenhuma das opções reconhecidas (WHEN OTHER de EVALUATE ACCTYPI).\
Consequência: a solicitação é considerada inválida, a criação da conta não é realizada e é exibida a mensagem 'Account Type should be ISA,CURRENT,LOAN,SAVING or MORTGAGE'.\
Parágrafo: ED010 (EDIT-DATA)

5\. Regra: A taxa de juros é obrigatória para solicitar a criação de uma conta bancária.\
Condição: o campo de taxa de juros não foi preenchido (INTRTL igual a zero).\
Consequência: a solicitação é considerada inválida, a criação da conta não é realizada e é exibida a mensagem 'Please supply a numeric interest rate'.\
Parágrafo: ED010 (EDIT-DATA)

6\. Regra: A taxa de juros informada deve ser maior ou igual a zero.\
Condição: a taxa de juros informada é negativa (INTRTI-COMP-1 menor que zero).\
Consequência: a solicitação é considerada inválida, a criação da conta não é realizada e é exibida a mensagem 'Please supply a zero or positive interest rate'.\
Parágrafo: ED010 (EDIT-DATA)

7\. Regra: A taxa de juros informada não pode ser superior a 9999,99%.\
Condição: a taxa de juros informada é maior que 9999,99 (INTRTI-COMP-1 maior que 9999.99).\
Consequência: a solicitação é considerada inválida, a criação da conta não é realizada e é exibida a mensagem 'Please supply an interest rate less than 9999.99%'. Apesar da mensagem indicar um valor inferior a 9999,99%, o programa rejeita apenas valores superiores a esse limite.\
Parágrafo: ED010 (EDIT-DATA)

8\. Regra: Quando o limite de cheque especial não é informado, a solicitação de criação da conta considera um limite igual a zero.\
Condição: o campo de limite de cheque especial está vazio, contém apenas o preenchimento padrão ou espaços (OVERDRL menor que 1, OVERDRI igual a '\_\_\_\_\_\_\_\_' ou OVERDRI igual a espaços).\
Consequência: o limite de cheque especial é definido como zero, sem invalidar a solicitação por essa ausência.\
Parágrafo: ED010 (EDIT-DATA)

9\. Regra: O número do cliente e o tipo de conta devem estar presentes para que a solicitação de criação da conta seja considerada válida.\
Condição: o número do cliente ou o tipo de conta está ausente (CUSTNOL menor que 1 ou ACCTYPL menor que 1).\
Consequência: a solicitação é considerada inválida, a criação da conta não é realizada e é exibida a mensagem 'Missing expected data.'.\
Parágrafo: ED010 (EDIT-DATA)

10\. Regra: A criação da conta somente é solicitada quando os dados informados passam pelas validações do programa.\
Condição: os dados da solicitação são considerados válidos (VALID-DATA igual a 'Y').\
Consequência: a solicitação é encaminhada ao processamento de criação da conta bancária.\
Parágrafo: PM010 (PROCESS-MAP)

11\. Regra: Se o número do cliente informado não existir no cadastro do banco, a conta não é criada.\
Condição: a criação da conta retorna insucesso (SUBPGM-SUCCESS igual a 'N') com código de falha '1'.\
Consequência: a solicitação é considerada malsucedida e é exibida a mensagem 'The supplied customer number does not exist.'.\
Parágrafo: CAD010 (CRE-ACC-DATA)

12\. Regra: Se os dados cadastrais do cliente não puderem ser acessados, a criação da conta não é realizada.\
Condição: a criação da conta retorna insucesso (SUBPGM-SUCCESS igual a 'N') com código de falha '2'.\
Consequência: a solicitação é considerada malsucedida e é exibida a mensagem 'The customer data cannot be accessed, unable to create account.'.\
Parágrafo: CAD010 (CRE-ACC-DATA)

13\. Regra: Se o processo de criação da conta retornar o código de falha '8', a conta não é criada por excesso de contas.\
Condição: a criação da conta retorna insucesso (SUBPGM-SUCCESS igual a 'N') com código de falha '8'.\
Consequência: a solicitação é considerada malsucedida e é exibida a mensagem 'Account record creation failed, (too many accounts).'. O programa não informa o limite máximo de contas permitido.\
Parágrafo: CAD010 (CRE-ACC-DATA)

14\. Regra: Se a criação da conta for recusada porque o tipo de conta não é suportado pelo processamento de criação, a conta não é criada.\
Condição: a criação da conta retorna insucesso (SUBPGM-SUCCESS igual a 'N') com código de falha 'A'.\
Consequência: a solicitação é considerada malsucedida e é exibida a mensagem 'Account record creation failed, account type unsupported.'.\
Parágrafo: CAD010 (CRE-ACC-DATA)

15\. Regra: Se a criação da conta não for concluída e o motivo não corresponder a nenhum dos códigos de falha reconhecidos pelo programa, o cliente é informado de que a conta não foi criada.\
Condição: a criação da conta retorna insucesso (SUBPGM-SUCCESS igual a 'N') com código de falha diferente de '1', '2', '3', '4', '5', '6', '7', '8', '9' e 'A'.\
Consequência: a solicitação é considerada malsucedida e é exibida a mensagem 'The account was not created.'.\
Parágrafo: CAD010 (CRE-ACC-DATA)

16\. Regra: Quando o processamento de criação da conta retorna sucesso, o cliente recebe a confirmação da criação da conta bancária.\
Condição: o indicador de sucesso do processamento de criação da conta é diferente de 'N' (SUBPGM-SUCCESS diferente de 'N').\
Consequência: é exibida a mensagem 'The Account has been successfully created', juntamente com os dados da conta criada, incluindo identificação da conta, datas e saldos. O programa considera qualquer valor diferente de 'N' como sucesso.\
Parágrafo: CAD010 (CRE-ACC-DATA)