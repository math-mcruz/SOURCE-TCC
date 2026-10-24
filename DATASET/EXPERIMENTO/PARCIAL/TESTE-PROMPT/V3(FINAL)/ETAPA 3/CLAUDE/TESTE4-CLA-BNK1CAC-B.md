1. Regra: Se o número do cliente não for informado (campo vazio ou preenchido só com sublinhados), a entrada é considerada inválida e é exibida a mensagem 'Please enter a 10 digit Customer Number'.
   Condição: tamanho do campo de número do cliente menor que 1 (CUSTNOL < 1) ou conteúdo igual a '__________'
   Consequência: entrada inválida, com a mensagem indicada; as demais validações não são feitas
   Parágrafo: ED010 (EDIT-DATA)

2. Regra: Se o tipo de conta não for informado (campo vazio ou preenchido só com sublinhados), a entrada é considerada inválida e é exibida a mensagem 'Account Type should be ISA,CURRENT,LOAN,SAVING or MORTGAGE'.
   Condição: tipo de conta igual a '________' ou tamanho do campo menor que 1 (ACCTYPL < 1)
   Consequência: entrada inválida, com a mensagem indicada; as demais validações não são feitas
   Parágrafo: ED010 (EDIT-DATA)

3. Regra: O tipo de conta aceito é ISA, CURRENT, LOAN, SAVING ou MORTGAGE, em maiúsculas ou minúsculas (o programa converte para maiúsculas); qualquer outro valor torna a entrada inválida, com a mensagem 'Account Type should be ISA,CURRENT,LOAN,SAVING or MORTGAGE'. Ambíguo: a variante 'MORTGAGE' com preenchimento de sublinhados não se aplica por ocupar os 8 caracteres, e outras combinações de maiúsculas e minúsculas misturadas não estão na lista, sendo recusadas.
   Condição: tipo de conta informado (ACCTYPL > 0) diferente dos valores listados no EVALUATE
   Consequência: entrada inválida, com a mensagem indicada; as demais validações não são feitas
   Parágrafo: ED010 (EDIT-DATA)

4. Regra: Se a taxa de juros não for informada (campo vazio), a entrada é considerada inválida e é exibida a mensagem 'Please supply a numeric interest rate'.
   Condição: campo de taxa de juros sem conteúdo (INTRTL igual a zero)
   Consequência: entrada inválida, com a mensagem indicada; as demais validações não são feitas
   Parágrafo: ED010 (EDIT-DATA)

5. Regra: A taxa de juros não pode ser negativa; se for, a entrada é considerada inválida e é exibida a mensagem 'Please supply a zero or positive interest rate'.
   Condição: valor numérico da taxa de juros menor que zero
   Consequência: entrada inválida, com a mensagem indicada; as demais validações não são feitas
   Parágrafo: ED010 (EDIT-DATA)

6. Regra: A taxa de juros não pode ultrapassar 9999,99; se ultrapassar, a entrada é considerada inválida e é exibida a mensagem 'Please supply an interest rate less than 9999.99%'. Ambíguo: a mensagem fala em "menor que" 9999,99, mas o código aceita exatamente 9999,99.
   Condição: valor numérico da taxa de juros maior que 9999,99
   Consequência: entrada inválida, com a mensagem indicada; as demais validações não são feitas
   Parágrafo: ED010 (EDIT-DATA)

7. Regra: A taxa de juros pode ter no máximo duas casas decimais; se tiver mais de duas, a entrada é considerada inválida e é exibida a mensagem 'Only up to two decimal places are supported'. Ambíguo: a verificação só ocorre quando o campo contém caracteres não numéricos puros (por exemplo, o ponto decimal) e há exatamente um ponto, e a contagem considera dígitos e sinais após o ponto.
   Condição: taxa de juros com um ponto decimal e mais de duas posições de dígitos após o ponto
   Consequência: entrada inválida, com a mensagem indicada; as demais validações não são feitas
   Parágrafo: ED010 (EDIT-DATA)

8. Regra: Se o limite de cheque especial não for informado (campo vazio, só sublinhados ou só espaços), ele é assumido como zero e a entrada segue válida.
   Condição: tamanho do campo de limite de cheque especial menor que 1 (OVERDRL < 1), ou conteúdo igual a '________' ou a espaços
   Consequência: o limite de cheque especial é assumido como zero; a validação continua
   Parágrafo: ED010 (EDIT-DATA)

9. Regra: Se o número do cliente ou o tipo de conta estiver ausente na verificação final, a entrada é considerada inválida e é exibida a mensagem 'Missing expected data.'
   Condição: tamanho do campo de número do cliente menor que 1 (CUSTNOL < 1) ou do tipo de conta menor que 1 (ACCTYPL < 1)
   Consequência: entrada inválida, com a mensagem indicada. Ambíguo: como as mesmas ausências já são recusadas antes, esta regra provavelmente nunca é alcançada.
   Parágrafo: ED010 (EDIT-DATA)

10. Regra: Somente se todos os dados informados forem válidos o programa solicita a criação da conta.
    Condição: dados informados válidos após a edição (VALID-DATA)
    Consequência: a criação da conta é solicitada ao programa CREACC; caso contrário, a criação não é solicitada e a tela é reexibida com a mensagem de erro
    Parágrafo: PM010 (PROCESS-MAP)

11. Regra: Se o número do cliente informado não existir, a conta não é criada e é exibida a mensagem 'The supplied customer number does not exist.'
    Condição: retorno da criação de conta com indicador de sucesso 'N' e código de falha '1'
    Consequência: conta não criada, com a mensagem indicada
    Parágrafo: CAD010 (CRE-ACC-DATA)

12. Regra: Se os dados do cliente não puderem ser acessados, a conta não é criada e é exibida a mensagem 'The customer data cannot be accessed, unable to create account.'
    Condição: retorno da criação de conta com indicador de sucesso 'N' e código de falha '2'
    Consequência: conta não criada, com a mensagem indicada
    Parágrafo: CAD010 (CRE-ACC-DATA)

13. Regra: Se o cliente já tiver o número máximo de contas, a conta não é criada e é exibida a mensagem 'Account record creation failed, (too many accounts).'
    Condição: retorno da criação de conta com indicador de sucesso 'N' e código de falha '8'
    Consequência: conta não criada, com a mensagem indicada
    Parágrafo: CAD010 (CRE-ACC-DATA)

14. Regra: Se não for possível contar as contas do cliente, a conta não é criada e é exibida a mensagem 'Account record creation failed, unable to count accounts.'
    Condição: retorno da criação de conta com indicador de sucesso 'N' e código de falha '9'
    Consequência: conta não criada, com a mensagem indicada
    Parágrafo: CAD010 (CRE-ACC-DATA)

15. Regra: Se o tipo de conta não for aceito pelo programa de criação, a conta não é criada e é exibida a mensagem 'Account record creation failed, account type unsupported.'
    Condição: retorno da criação de conta com indicador de sucesso 'N' e código de falha 'A'
    Consequência: conta não criada, com a mensagem indicada
    Parágrafo: CAD010 (CRE-ACC-DATA)

16. Regra: Se a criação da conta falhar por qualquer outro motivo não previsto acima, é exibida a mensagem 'The account was not created.'
    Condição: retorno da criação de conta com indicador de sucesso 'N' e código de falha diferente de '1', '2', '3', '4', '5', '6', '7', '8', '9' e 'A'
    Consequência: conta não criada, com a mensagem indicada
    Parágrafo: CAD010 (CRE-ACC-DATA)

17. Regra: Se a conta for criada com sucesso, é exibida a mensagem 'The Account has been successfully created', junto com os dados da nova conta (código da agência, número da conta, datas e saldos).
    Condição: retorno da criação de conta com indicador de sucesso diferente de 'N'
    Consequência: conta criada, com a mensagem de sucesso e os dados da conta exibidos
    Parágrafo: CAD010 (CRE-ACC-DATA)