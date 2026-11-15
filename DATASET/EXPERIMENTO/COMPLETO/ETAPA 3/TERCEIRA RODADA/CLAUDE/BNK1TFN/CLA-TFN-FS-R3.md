1. Regra: A transferência só é solicitada ao módulo de transferência (XFRFUN) se todas as validações dos dados informados passaram; caso contrário, apenas a mensagem de erro é exibida.
   Condição: dados informados válidos (VALID-DATA)
   Consequência: a transferência é solicitada; se houver dado inválido, ela não é solicitada e a mensagem correspondente é exibida
   Parágrafo: PM010 (PROCESS-MAP)

2. Regra: A conta de origem (FROM) e a conta de destino (TO) devem ser diferentes; se forem iguais, a entrada é inválida e é exibida a mensagem 'The FROM & TO account should be different'.
   Condição: número da conta de origem igual ao número da conta de destino
   Consequência: entrada inválida, com a mensagem indicada; as demais validações não são feitas
   Parágrafo: ED010 (EDIT-DATA)

3. Regra: O número de conta 00000000 não é aceito, nem como origem nem como destino; a entrada é inválida e é exibida a mensagem 'Account no 00000000 is not valid'.
   Condição: conta de origem ou conta de destino igual a '00000000'
   Consequência: entrada inválida, com a mensagem indicada; as demais validações não são feitas
   Parágrafo: ED010 (EDIT-DATA)

4. Regra: Se o valor da transferência não for informado (campo sem conteúdo, AMTL igual a zero), a entrada é inválida e é exibida a mensagem 'The Amount entered must be numeric.'
   Condição: campo de valor com tamanho zero (AMTL igual a zero). A mensagem fala em "numérico", mas o teste é de ausência de conteúdo
   Consequência: entrada inválida, com a mensagem indicada; as demais validações do valor não são feitas
   Parágrafo: VA010 (VALIDATE-AMOUNT)

5. Regra: Se o valor da transferência for composto apenas de espaços em branco, a entrada é inválida e é exibida a mensagem 'The Amount entered must be numeric.'
   Condição: todos os caracteres do campo de valor são espaços iniciais (contagem de espaços igual ao tamanho do campo)
   Consequência: entrada inválida, com a mensagem indicada; as demais validações do valor não são feitas
   Parágrafo: VA010 (VALIDATE-AMOUNT)

6. Regra: Se o valor informado for numérico e menor ou igual a zero, a entrada é inválida e é exibida a mensagem 'Please supply a positive amount.'
   Condição: valor numérico (AMTI) com resultado menor ou igual a zero (WS-AMOUNT-AS-FLOAT <= 0)
   Consequência: entrada inválida, com a mensagem indicada. Se o valor for positivo, a entrada é considerada válida e as demais validações do valor não são feitas
   Parágrafo: VA010 (VALIDATE-AMOUNT)

7. Regra: Não são aceitos valores negativos na transferência; se o valor contiver sinal de menos, a entrada é inválida e é exibida a mensagem 'Please supply a positive amount.'
   Condição: o valor informado contém o caractere '-'
   Consequência: entrada inválida, com a mensagem indicada; as demais validações do valor não são feitas
   Parágrafo: VA010 (VALIDATE-AMOUNT)

8. Regra: O valor da transferência aceita no máximo duas casas decimais; se houver mais de duas casas decimais com dígitos, a entrada é inválida e é exibida a mensagem 'Only up to two decimal places are supported.' (Ambíguo: a lógica de contagem é complexa e o código só aplica este teste quando há ponto decimal e mais de dois caracteres após ele.)
   Condição: valor com um ponto decimal e mais de dois dígitos após o ponto
   Consequência: entrada inválida, com a mensagem indicada; as demais validações do valor não são feitas
   Parágrafo: VA010 (VALIDATE-AMOUNT)

9. Regra: Um valor igual a zero não é aceito para a transferência; é exibida a mensagem 'Please supply a non-zero amount.' (Ambíguo: este teste só é alcançado por valores que não passaram pelo teste numérico direto, como '0.00'; valores numéricos iguais a zero já são rejeitados antes, com a mensagem 'Please supply a positive amount.')
   Condição: valor convertido igual a zero (WS-AMOUNT-AS-FLOAT = ZERO)
   Consequência: entrada inválida, com a mensagem indicada
   Parágrafo: VA010 (VALIDATE-AMOUNT)

10. Regra: Se a conta de origem não for encontrada pelo módulo de transferência (código de falha '1'), a transferência não é aplicada e é exibida a mensagem 'Sorry the FROM ACCOUNT no was not found. Transfer not applied.'
    Condição: módulo de transferência retorna indicador de sucesso 'N' e código de falha '1'
    Consequência: dados inválidos; transferência não aplicada, com a mensagem indicada
    Parágrafo: GCD010 (GET-ACC-DATA)

11. Regra: Se a conta de destino não for encontrada pelo módulo de transferência (código de falha '2'), a transferência não é aplicada e é exibida a mensagem 'Sorry the TO ACCOUNT no was not found. Transfer not applied.'
    Condição: módulo de transferência retorna indicador de sucesso 'N' e código de falha '2'
    Consequência: dados inválidos; transferência não aplicada, com a mensagem indicada
    Parágrafo: GCD010 (GET-ACC-DATA)

12. Regra: Se o módulo de transferência rejeitar o valor por não ser maior que zero (código de falha '4'), a transferência não é aplicada e é exibida a mensagem 'Please supply an amount greater than zero.'
    Condição: módulo de transferência retorna indicador de sucesso 'N' e código de falha '4'
    Consequência: dados inválidos; transferência não aplicada, com a mensagem indicada
    Parágrafo: GCD010 (GET-ACC-DATA)

13. Regra: Se o módulo de transferência informar sucesso, a transferência é considerada aplicada, é exibida a mensagem 'Transfer successfully applied.' e são mostrados os números das contas, os códigos de agência (sort code) e os saldos real e disponível das contas de origem e de destino.
    Condição: indicador de sucesso do módulo de transferência igual a 'Y'
    Consequência: mensagem de transferência aplicada com sucesso e exibição dos saldos atualizados das duas contas
    Parágrafo: GCD010 (GET-ACC-DATA)