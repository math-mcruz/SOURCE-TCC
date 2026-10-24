1. Regra: A conta só é criada se todas as validações dos dados informados passarem. Caso contrário, nenhuma conta é criada e a tela é reexibida com a mensagem de erro.
   Condição: os dados informados são considerados válidos (VALID-DATA)
   Consequência: o programa de criação de conta (CREACC) é acionado; se houve erro de validação, ele não é acionado
   Parágrafo: PM010 (PROCESS-MAP)

2. Regra: O número do cliente é obrigatório. Se não for informado, a entrada é considerada inválida e é exibida a mensagem 'Please enter a 10 digit Customer Number'.
   Condição: número do cliente sem conteúdo (CUSTNOL menor que 1 ou CUSTNOI preenchido apenas com '__________')
   Consequência: entrada inválida, com a mensagem indicada; as demais validações não são feitas
   Parágrafo: ED010 (EDIT-DATA)

3. Regra: O tipo de conta é obrigatório. Se não for informado, a entrada é considerada inválida e é exibida a mensagem 'Account Type should be ISA,CURRENT,LOAN,SAVING or MORTGAGE'.
   Condição: tipo de conta sem conteúdo (ACCTYPI preenchido apenas com '________' ou ACCTYPL menor que 1)
   Consequência: entrada inválida, com a mensagem indicada; as demais validações não são feitas
   Parágrafo: ED010 (EDIT-DATA)

4. Regra: O tipo de conta deve ser ISA, CURRENT, LOAN, SAVING ou MORTGAGE, aceito em maiúsculas ou minúsculas. Qualquer outro valor torna a entrada inválida, com a mensagem 'Account Type should be ISA,CURRENT,LOAN,SAVING or MORTGAGE'. Quando o valor é aceito em minúsculas, ele é convertido para maiúsculas. O código só reconhece a forma toda em maiúsculas ou toda em minúsculas; grafias com letras misturadas (ex.: 'Isa') são rejeitadas.
   Condição: tipo de conta informado diferente dos valores aceitos
   Consequência: entrada inválida, com a mensagem indicada; as demais validações não são feitas
   Parágrafo: ED010 (EDIT-DATA)

5. Regra: A taxa de juros é obrigatória. Se não for informada, a entrada é considerada inválida e é exibida a mensagem 'Please supply a numeric interest rate'.
   Condição: campo de taxa de juros sem conteúdo (INTRTL igual a zero)
   Consequência: entrada inválida, com a mensagem indicada; as demais validações não são feitas
   Parágrafo: ED010 (EDIT-DATA)

6. Regra: A taxa de juros aceita no máximo duas casas decimais. Com mais casas, a entrada é considerada inválida e é exibida a mensagem 'Only up to two decimal places are supported'. A lógica de contagem do código é complexa e pode ser ambígua em alguns casos (por exemplo, com sinais ou espaços após o ponto); o objetivo evidente é limitar a duas casas decimais.
   Condição: taxa de juros informada com mais de duas casas decimais após o ponto
   Consequência: entrada inválida, com a mensagem indicada; as demais validações não são feitas
   Parágrafo: ED010 (EDIT-DATA)

7. Regra: A taxa de juros não pode ser negativa; deve ser zero ou positiva. Se for negativa, a entrada é considerada inválida e é exibida a mensagem 'Please supply a zero or positive interest rate'.
   Condição: valor numérico da taxa de juros menor que zero
   Consequência: entrada inválida, com a mensagem indicada; as demais validações não são feitas
   Parágrafo: ED010 (EDIT-DATA)

8. Regra: A taxa de juros não pode ultrapassar 9999,99%. Se ultrapassar, a entrada é considerada inválida e é exibida a mensagem 'Please supply an interest rate less than 9999.99%'. A mensagem diz "menor que", mas o código só rejeita valores estritamente maiores que 9999.99, ou seja, o próprio 9999.99 é aceito.
   Condição: valor numérico da taxa de juros maior que 9999.99
   Consequência: entrada inválida, com a mensagem indicada; as demais validações não são feitas
   Parágrafo: ED010 (EDIT-DATA)

9. Regra: O limite de cheque especial é opcional. Se não for informado, é assumido o valor zero.
   Condição: limite de cheque especial sem conteúdo (OVERDRL menor que 1, OVERDRI preenchido apenas com '________' ou em branco)
   Consequência: o limite de cheque especial passa a valer zero, sem mensagem de erro
   Parágrafo: ED010 (EDIT-DATA)

10. Regra: Como verificação final, se o número do cliente estiver ausente, a entrada é considerada inválida e é exibida a mensagem 'Missing expected data.'. Essa checagem repete a obrigatoriedade já testada anteriormente e, pela ordem do código, dificilmente será alcançada, pois a ausência já encerra a validação antes.
    Condição: número do cliente sem conteúdo (CUSTNOL menor que 1)
    Consequência: entrada inválida, com a mensagem 'Missing expected data.'
    Parágrafo: ED010 (EDIT-DATA)

11. Regra: Como verificação final, se o tipo de conta estiver ausente, a entrada é considerada inválida e é exibida a mensagem 'Missing expected data.'. Essa checagem repete a obrigatoriedade já testada anteriormente e, pela ordem do código, dificilmente será alcançada, pois a ausência já encerra a validação antes.
    Condição: tipo de conta sem conteúdo (ACCTYPL menor que 1)
    Consequência: entrada inválida, com a mensagem 'Missing expected data.'
    Parágrafo: ED010 (EDIT-DATA)

12. Regra: Se o cliente informado não existir, a conta não é criada e é exibida a mensagem 'The supplied customer number does not exist.'
    Condição: o programa de criação de conta retorna falha com código '1'
    Consequência: conta não criada, com a mensagem indicada
    Parágrafo: CAD010 (CRE-ACC-DATA)

13. Regra: Se o cliente já tiver o número máximo de contas permitido, a conta não é criada e é exibida a mensagem 'Account record creation failed, (too many accounts).' O limite em si é definido no programa CREACC, não neste programa.
    Condição: o programa de criação de conta retorna falha com código '8'
    Consequência: conta não criada, com a mensagem indicada
    Parágrafo: CAD010 (CRE-ACC-DATA)

14. Regra: Se o tipo de conta não for suportado pelo sistema de criação de contas, a conta não é criada e é exibida a mensagem 'Account record creation failed, account type unsupported.'
    Condição: o programa de criação de conta retorna falha com código 'A'
    Consequência: conta não criada, com a mensagem indicada
    Parágrafo: CAD010 (CRE-ACC-DATA)

15. Regra: Quando a conta é criada com sucesso, é exibida a mensagem 'The Account has been successfully created' junto com os dados da nova conta (código da agência, número da conta, datas de abertura e de extratos, saldos, tipo, taxa de juros e limite de cheque especial).
    Condição: o programa de criação de conta não retorna indicador de falha (SUBPGM-SUCCESS diferente de 'N')
    Consequência: mensagem de sucesso e exibição dos dados da conta criada
    Parágrafo: CAD010 (CRE-ACC-DATA)