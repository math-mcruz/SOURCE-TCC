1\. Regra: O número do cliente é obrigatório para solicitar a abertura de uma conta.\
Condição: Quando o número do cliente não é informado (CUSTNOL < 1 ou CUSTNOI = '\_\_\_\_\_\_\_\_\_\_').\
Consequência: A solicitação é considerada inválida e o sistema exige o preenchimento do número do cliente antes de prosseguir.\
Parágrafo: ED010.

2\. Regra: O tipo de conta é obrigatório para solicitar a abertura de uma conta.\
Condição: Quando o tipo de conta não é informado (ACCTYPI = '\_\_\_\_\_\_\_\_' ou ACCTYPL < 1).\
Consequência: A solicitação é considerada inválida e o sistema informa que os tipos de conta disponíveis são ISA, CURRENT, LOAN, SAVING e MORTGAGE.\
Parágrafo: ED010.

3\. Regra: A abertura de conta admite os tipos ISA, CURRENT, LOAN, SAVING e MORTGAGE, independentemente de serem informados em letras maiúsculas ou minúsculas, nas representações previstas pelo programa.\
Condição: Quando o tipo de conta informado corresponde a uma das alternativas reconhecidas pelo programa.\
Consequência: O tipo de conta é aceito e o processamento da solicitação continua.\
Parágrafo: ED010.

4\. Regra: Não é permitida a abertura de conta com um tipo diferente dos tipos reconhecidos pelo programa.\
Condição: Quando o tipo de conta informado não corresponde a ISA, CURRENT, LOAN, SAVING ou MORTGAGE nas representações aceitas.\
Consequência: A solicitação é considerada inválida e o sistema informa os tipos de conta permitidos.\
Parágrafo: ED010.

5\. Regra: A taxa de juros é obrigatória para solicitar a abertura de uma conta.\
Condição: Quando a taxa de juros não é informada (INTRTL = ZERO).\
Consequência: A solicitação é considerada inválida e o sistema exige o preenchimento da taxa de juros.\
Parágrafo: ED010.

6\. Regra: A taxa de juros de uma nova conta não pode ser negativa.\
Condição: Quando a taxa de juros informada é inferior a zero (INTRTI-COMP-1 < 0).\
Consequência: A solicitação é considerada inválida e o sistema informa que a taxa de juros deve ser zero ou positiva.\
Parágrafo: ED010.

7\. Regra: A taxa de juros de uma nova conta não pode ser superior a 9999,99.\
Condição: Quando a taxa de juros informada é superior a 9999,99 (INTRTI-COMP-1 > 9999.99).\
Consequência: A solicitação é considerada inválida e o sistema apresenta uma mensagem solicitando uma taxa inferior a 9999,99%, embora a condição implementada permita exatamente 9999,99.\
Parágrafo: ED010.

8\. Regra: O limite de cheque especial é opcional na solicitação de abertura de conta.\
Condição: Quando o limite de cheque especial não é informado, contém apenas espaços ou apresenta o preenchimento padrão de sublinhados (OVERDRL < 1, OVERDRI = '\_\_\_\_\_\_\_\_' ou OVERDRI = espaços).\
Consequência: O sistema considera o limite de cheque especial igual a zero.\
Parágrafo: ED010.

9\. Regra: A solicitação de abertura de conta exige que o número do cliente e o tipo de conta estejam preenchidos.\
Condição: Quando, na verificação final, o número do cliente ou o tipo de conta apresenta comprimento inferior a um (CUSTNOL < 1 ou ACCTYPL < 1).\
Consequência: A solicitação é considerada inválida e o sistema informa que faltam dados obrigatórios.\
Parágrafo: ED010.

10\. Regra: A abertura de conta somente é encaminhada para efetivação quando os dados da solicitação são considerados válidos.\
Condição: Quando todas as validações aplicáveis são concluídas sem invalidar a solicitação (VALID-DATA).\
Consequência: O sistema encaminha a solicitação para a rotina responsável pela criação da conta.\
Parágrafo: PM010.

11\. Regra: A abertura de conta não é encaminhada para efetivação quando os dados da solicitação são considerados inválidos.\
Condição: Quando alguma validação invalida a solicitação (VALID-DATA-SW diferente de 'Y').\
Consequência: O sistema não executa a rotina de criação da conta.\
Parágrafo: PM010.

12\. Regra: Não é possível abrir uma conta para um número de cliente inexistente.\
Condição: Quando a rotina de criação retorna insucesso (SUBPGM-SUCCESS = 'N') com código de falha '1'.\
Consequência: A conta não é criada e o sistema informa que o número de cliente fornecido não existe.\
Parágrafo: CAD010.

13\. Regra: A abertura de conta não é concluída quando os dados do cliente não podem ser acessados.\
Condição: Quando a rotina de criação retorna insucesso (SUBPGM-SUCCESS = 'N') com código de falha '2'.\
Consequência: A conta não é criada e o sistema informa que não foi possível acessar os dados do cliente.\
Parágrafo: CAD010.

14\. Regra: A abertura de conta não é concluída quando o limite de quantidade de contas é excedido.\
Condição: Quando a rotina de criação retorna insucesso (SUBPGM-SUCCESS = 'N') com código de falha '8'.\
Consequência: A conta não é criada e o sistema informa que existem contas em quantidade excessiva, sem especificar o limite permitido.\
Parágrafo: CAD010.

15\. Regra: A abertura de conta não é concluída quando o tipo de conta não é suportado pela rotina responsável pela criação.\
Condição: Quando a rotina de criação retorna insucesso (SUBPGM-SUCCESS = 'N') com código de falha 'A'.\
Consequência: A conta não é criada e o sistema informa que o tipo de conta não é suportado.\
Parágrafo: CAD010.

16\. Regra: A abertura de conta pode ser recusada por um motivo não identificado nas situações específicas previstas pelo programa.\
Condição: Quando a rotina de criação retorna insucesso (SUBPGM-SUCCESS = 'N') com um código de falha diferente dos códigos explicitamente tratados.\
Consequência: O sistema informa genericamente que a conta não foi criada.\
Parágrafo: CAD010.

17\. Regra: A abertura de conta é confirmada quando a rotina responsável pela criação não sinaliza insucesso.\
Condição: Quando o indicador de sucesso da rotina de criação é diferente de 'N' (SUBPGM-SUCCESS diferente de 'N').\
Consequência: O sistema informa que a conta foi criada com sucesso e apresenta seus dados, incluindo identificação da conta, datas e saldos. O programa não exige explicitamente que o indicador tenha um valor específico de sucesso.\
Parágrafo: CAD010.