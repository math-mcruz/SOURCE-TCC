1. Regra: O valor só é aplicado à conta (crédito ou débito) quando todas as validações dos dados informados foram aprovadas; se alguma falhou, nada é aplicado e a tela é reexibida com a mensagem de erro.
   Condição: os dados informados passaram em todas as validações (VALID-DATA)
   Consequência: o valor é enviado para aplicação na conta; caso contrário, a aplicação não é feita
   Parágrafo: PM010 (PROCESS-MAP)

2. Regra: O número da conta não pode ser zero; com número zero, a entrada é considerada inválida e é exibida a mensagem 'Please enter a non zero account number.'
   Condição: número da conta igual a zero (ACCNOI = ZERO)
   Consequência: entrada inválida, com a mensagem indicada; as demais validações não são feitas
   Parágrafo: ED010 (EDIT-DATA)

3. Regra: Quando o sinal é informado, ele deve ser '+' ou '-'; com outro sinal, a entrada é considerada inválida e é exibida a mensagem 'Please enter + or - preceding the amount'. O programa só testa o sinal quando ele tem um caractere informado (SIGNL = 1); se o sinal for deixado em branco, não há erro e, na aplicação, o valor não é invertido, ou seja, é tratado como positivo.
   Condição: sinal informado (SIGNL = 1) e diferente de '+' e de '-'
   Consequência: entrada inválida, com a mensagem indicada; as demais validações não são feitas
   Parágrafo: ED010 (EDIT-DATA)

4. Regra: O valor da operação é obrigatório; se o campo de valor vier sem nenhum conteúdo, a entrada é considerada inválida e é exibida a mensagem 'The Amount entered must be numeric.' (a mensagem fala em valor numérico, mas o teste é de ausência de conteúdo).
   Condição: campo de valor com tamanho zero (AMTL = ZERO)
   Consequência: entrada inválida, com a mensagem indicada; as demais validações do valor não são feitas
   Parágrafo: VA010 (VALIDATE-AMOUNT)

5. Regra: O valor da operação não pode ser preenchido somente com espaços; nesse caso, a entrada é considerada inválida e é exibida a mensagem 'The Amount entered must be numeric.'
   Condição: todos os caracteres do valor informado são espaços (quantidade de espaços à esquerda igual ao tamanho do campo)
   Consequência: entrada inválida, com a mensagem indicada; as demais validações do valor não são feitas
   Parágrafo: VA010 (VALIDATE-AMOUNT)

6. Regra: O valor da operação aceita no máximo duas casas decimais; com mais de duas casas decimais, a entrada é considerada inválida e é exibida a mensagem 'Only up to two decimal places are supported.' (o programa conta os dígitos após o ponto em duas verificações encadeadas, e a rejeição ocorre quando a contagem final passa de duas).
   Condição: valor informado com mais de dois dígitos após o ponto decimal
   Consequência: entrada inválida, com a mensagem indicada
   Parágrafo: VA010 (VALIDATE-AMOUNT)

7. Regra: O valor da operação não pode ser zero; com valor zero, a entrada é considerada inválida e é exibida a mensagem 'Please supply a non-zero amount.'
   Condição: valor convertido igual a zero (WS-AMOUNT-AS-FLOAT = ZERO)
   Consequência: entrada inválida, com a mensagem indicada
   Parágrafo: VA010 (VALIDATE-AMOUNT)

8. Regra: Quando o sinal informado é '-', o valor é aplicado como negativo (débito na conta); com qualquer outro sinal ou sinal em branco, o valor é mantido positivo (crédito).
   Condição: sinal informado igual a '-' (SIGNI = '-')
   Consequência: o valor é multiplicado por -1 antes de ser enviado para aplicação na conta
   Parágrafo: UCD010 (UPD-CRED-DATA)

9. Regra: Se a conta informada não for encontrada para a agência (sort code), o valor não é aplicado e é exibida a mensagem 'Sorry but the ACCOUNT no was not found for SORTCODE ... Amount not applied.'
   Condição: a rotina de crédito/débito (DBCRFUN) retorna indicador de sucesso 'N' com código de falha '1'
   Consequência: entrada marcada como inválida, valor não aplicado, mensagem de conta não encontrada exibida; os saldos não são exibidos
   Parágrafo: UCD010 (UPD-CRED-DATA)

10. Regra: Se não houver saldo suficiente para a operação, o valor não é aplicado e é exibida a mensagem 'Sorry insufficient funds available to process the request.'
    Condição: a rotina de crédito/débito (DBCRFUN) retorna indicador de sucesso 'N' com código de falha '3'
    Consequência: entrada marcada como inválida, valor não aplicado, mensagem de fundos insuficientes exibida; os saldos não são exibidos
    Parágrafo: UCD010 (UPD-CRED-DATA)

11. Regra: Quando a operação é aplicada com sucesso, é exibida a mensagem 'Amount successfully applied to the account.' junto com o número da conta, o sort code, o saldo atual e o saldo disponível após a operação.
    Condição: a rotina de crédito/débito (DBCRFUN) não retorna indicador de sucesso 'N'
    Consequência: mensagem de confirmação exibida, com conta, sort code, saldo atual e saldo disponível
    Parágrafo: UCD010 (UPD-CRED-DATA)