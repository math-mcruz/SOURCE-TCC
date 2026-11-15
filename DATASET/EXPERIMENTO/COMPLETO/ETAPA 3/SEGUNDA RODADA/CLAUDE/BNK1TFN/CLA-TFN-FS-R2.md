1. Regra: A transferência só é solicitada ao módulo de transferência (XFRFUN) se todos os dados informados passaram nas validações; caso contrário, nenhuma transferência é tentada e a tela é reexibida com a mensagem de erro.
   Condição: dados da tela válidos (VALID-DATA)
   Consequência: os dados são enviados ao módulo de transferência (GET-ACC-DATA); se não forem válidos, não são enviados
   Parágrafo: PM010 (PROCESS-MAP)

2. Regra: As contas de origem (FROM) e de destino (TO) devem ser diferentes. Se forem iguais, a entrada é inválida e é exibida a mensagem 'The FROM & TO account should be different'.
   Condição: número da conta de origem igual ao da conta de destino (FACCNOI = TACCNOI)
   Consequência: entrada inválida, com a mensagem indicada; as demais validações, inclusive a do valor, não são feitas
   Parágrafo: ED010 (EDIT-DATA)

3. Regra: O número de conta 00000000 não é aceito, nem como conta de origem nem como conta de destino. Nesse caso a entrada é inválida e é exibida a mensagem 'Account no 00000000 is not valid'.
   Condição: conta de origem ou conta de destino igual a '00000000'
   Consequência: entrada inválida, com a mensagem indicada; a validação do valor não é feita
   Parágrafo: ED010 (EDIT-DATA)

4. Regra: Se a transferência for recusada porque a conta de origem não foi encontrada (código de falha '1' do módulo de transferência), a entrada é considerada inválida e é exibida a mensagem 'Sorry the FROM ACCOUNT no was not found. Transfer not applied.'
   Condição: módulo de transferência retorna indicador de sucesso 'N' e código de falha '1'
   Consequência: transferência não aplicada, com a mensagem indicada; os saldos exibidos ficam zerados
   Parágrafo: GCD010 (GET-ACC-DATA)

5. Regra: Se a transferência for recusada porque a conta de destino não foi encontrada (código de falha '2'), a entrada é considerada inválida e é exibida a mensagem 'Sorry the TO ACCOUNT no was not found. Transfer not applied.'
   Condição: módulo de transferência retorna indicador de sucesso 'N' e código de falha '2'
   Consequência: transferência não aplicada, com a mensagem indicada; os saldos exibidos ficam zerados
   Parágrafo: GCD010 (GET-ACC-DATA)

6. Regra: Se o módulo de transferência informar um erro inesperado (código de falha '3'), a transferência não é aplicada. Ambiguidade: o código prepara a mensagem 'due to an unexpected error', mas não desvia para o fim do parágrafo. O fluxo segue para o teste seguinte, que, como o indicador é 'N', substitui a mensagem por 'unable to determine success'. A mensagem efetivamente exibida é a da regra 10.
   Condição: indicador de sucesso 'N' e código de falha '3'
   Consequência: transferência não aplicada; a mensagem de erro inesperado é sobrescrita pela mensagem de sucesso indeterminado
   Parágrafo: GCD010 (GET-ACC-DATA)

7. Regra: Se o módulo de transferência recusar o valor por não ser maior que zero (código de falha '4'), a transferência não é aplicada e é exibida a mensagem 'Please supply an amount greater than zero.'
   Condição: indicador de sucesso 'N' e código de falha '4'
   Consequência: transferência não aplicada, com a mensagem indicada; os saldos exibidos ficam zerados
   Parágrafo: GCD010 (GET-ACC-DATA)

8. Regra: Se o módulo de transferência recusar por qualquer outro motivo não previsto (código de falha diferente de '1', '2', '3' e '4'), a transferência não é aplicada e é exibida a mensagem 'Sorry but the transfer could not be applied due to an error.'
   Condição: indicador de sucesso 'N' e código de falha diferente de '1', '2', '3' e '4'
   Consequência: transferência não aplicada, com a mensagem indicada; os saldos exibidos ficam zerados
   Parágrafo: GCD010 (GET-ACC-DATA)

9. Regra: Quando o módulo de transferência confirma o sucesso, é exibida a mensagem 'Transfer successfully applied.' junto com os saldos real e disponível das contas de origem e de destino.
   Condição: indicador de sucesso igual a 'Y'
   Consequência: mensagem de transferência aplicada com sucesso e exibição dos saldos real e disponível das duas contas
   Parágrafo: GCD010 (GET-ACC-DATA)

10. Regra: Se o módulo de transferência não retornar indicador de sucesso 'Y', o resultado é tratado como indeterminado: a transferência é considerada não aplicada e é exibida a mensagem 'Sorry but the transfer could not be applied unable to determine success.' Esse teste também é alcançado quando o código de falha é '3' (ver regra 6).
   Condição: indicador de sucesso diferente de 'Y'
   Consequência: mensagem de sucesso indeterminado; os saldos exibidos ficam zerados
   Parágrafo: GCD010 (GET-ACC-DATA)

11. Regra: O valor da transferência é obrigatório. Se não for informado (campo vazio), a entrada é inválida e é exibida a mensagem 'The Amount entered must be numeric.'
   Condição: tamanho do campo de valor igual a zero (AMTL = ZERO)
   Consequência: entrada inválida, com a mensagem indicada; as demais validações do valor não são feitas
   Parágrafo: VA010 (VALIDATE-AMOUNT)

12. Regra: O valor da transferência é obrigatório. Se o campo contiver apenas espaços, a entrada é inválida e é exibida a mensagem 'The Amount entered must be numeric.'
   Condição: campo de valor preenchido somente com espaços (quantidade de espaços iniciais igual ao tamanho do campo)
   Consequência: entrada inválida, com a mensagem indicada; as demais validações do valor não são feitas
   Parágrafo: VA010 (VALIDATE-AMOUNT)

13. Regra: O valor da transferência deve ser positivo. Se o valor, composto apenas por dígitos, resultar em zero ou menos, a entrada é inválida e é exibida a mensagem 'Please supply a positive amount.' Ambiguidade: como o teste só se aplica a conteúdo composto apenas por dígitos, na prática só o valor zero é capturado aqui.
   Condição: valor numérico (só dígitos) menor ou igual a zero (WS-AMOUNT-AS-FLOAT <= 0)
   Consequência: entrada inválida, com a mensagem indicada
   Parágrafo: VA010 (VALIDATE-AMOUNT)

14. Regra: O valor da transferência não pode ser negativo. Se o valor informado contiver sinal de menos, a entrada é inválida e é exibida a mensagem 'Please supply a positive amount.'
   Condição: valor informado contém o caractere '-' (WS-NUM-COUNT-MINUS > 0)
   Consequência: entrada inválida, com a mensagem indicada
   Parágrafo: VA010 (VALIDATE-AMOUNT)

15. Regra: O valor da transferência aceita no máximo duas casas decimais. Se tiver mais, a entrada é inválida e é exibida a mensagem 'Only up to two decimal places are supported.' Ambiguidade: a contagem dos dígitos após o ponto é zerada e refeita sobre um trecho que já começa depois do ponto. Por isso o teste final parece nunca ser verdadeiro e a mensagem provavelmente não é exibida na prática.
   Condição: valor com ponto decimal e mais de duas casas decimais
   Consequência: entrada inválida, com a mensagem indicada (comportamento efetivo incerto, conforme a ambiguidade)
   Parágrafo: VA010 (VALIDATE-AMOUNT)

16. Regra: O valor da transferência não pode ser zero. Se, depois de convertido, o valor for zero (por exemplo '0.00'), a entrada é inválida e é exibida a mensagem 'Please supply a non-zero amount.'
   Condição: valor convertido igual a zero (WS-AMOUNT-AS-FLOAT = ZERO)
   Consequência: entrada inválida, com a mensagem indicada
   Parágrafo: VA010 (VALIDATE-AMOUNT)