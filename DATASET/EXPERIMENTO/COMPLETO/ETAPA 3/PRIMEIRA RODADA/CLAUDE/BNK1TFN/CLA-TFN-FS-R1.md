1. Regra: A transferência só é solicitada ao processamento de contas quando todos os dados informados na tela passaram nas validações; caso contrário, nenhuma transferência é tentada (VALID-DATA).
   Condição: os dados informados são válidos após as validações de contas e valor
   Consequência: a transferência é solicitada ao programa XFRFUN; se houver dado inválido, ela não é solicitada e a tela é reexibida com a mensagem de erro
   Parágrafo: PM010 (PROCESS-MAP)

2. Regra: A conta de origem (FROM) e a conta de destino (TO) devem ser diferentes; se forem iguais, é exibida a mensagem 'The FROM & TO account should be different'.
   Condição: número da conta de origem igual ao número da conta de destino (FACCNOI = TACCNOI)
   Consequência: entrada inválida, com a mensagem indicada; as demais validações não são feitas
   Parágrafo: ED010 (EDIT-DATA)

3. Regra: O número de conta 00000000 não é aceito, nem como conta de origem nem como conta de destino; é exibida a mensagem 'Account no 00000000 is not valid'.
   Condição: conta de origem ou conta de destino igual a '00000000'
   Consequência: entrada inválida, com a mensagem indicada; as demais validações não são feitas
   Parágrafo: ED010 (EDIT-DATA)

4. Regra: Se a conta de origem não for encontrada, a transferência não é aplicada e é exibida a mensagem 'Sorry the FROM ACCOUNT no was not found. Transfer not applied.'
   Condição: a transferência retorna indicador de sucesso 'N' e código de falha '1'
   Consequência: transferência não aplicada, com a mensagem indicada
   Parágrafo: GCD010 (GET-ACC-DATA)

5. Regra: Se a conta de destino não for encontrada, a transferência não é aplicada e é exibida a mensagem 'Sorry the TO ACCOUNT no was not found. Transfer not applied.'
   Condição: a transferência retorna indicador de sucesso 'N' e código de falha '2'
   Consequência: transferência não aplicada, com a mensagem indicada
   Parágrafo: GCD010 (GET-ACC-DATA)

6. Regra: Se a transferência recusar o valor por não ser maior que zero, é exibida a mensagem 'Please supply an amount greater than zero.' e a transferência não é aplicada.
   Condição: a transferência retorna indicador de sucesso 'N' e código de falha '4'
   Consequência: transferência não aplicada, com a mensagem indicada
   Parágrafo: GCD010 (GET-ACC-DATA)

7. Regra: Quando a transferência é concluída com sucesso, é exibida a mensagem 'Transfer successfully applied.' junto com as contas, os códigos das agências e os saldos atual e disponível das contas de origem e de destino.
   Condição: a transferência retorna indicador de sucesso 'Y'
   Consequência: mensagem de sucesso e exibição dos saldos atualizados das duas contas; nos demais casos os saldos exibidos ficam zerados
   Parágrafo: GCD010 (GET-ACC-DATA)

8. Regra: O valor da transferência é obrigatório; se o campo de valor vier sem nenhum conteúdo, a entrada é considerada inválida e é exibida a mensagem 'The Amount entered must be numeric.' (a mensagem fala em valor numérico, mas o teste é de campo sem conteúdo).
   Condição: tamanho do campo de valor igual a zero (AMTL = ZERO)
   Consequência: entrada inválida, com a mensagem indicada; as demais validações do valor não são feitas
   Parágrafo: VA010 (VALIDATE-AMOUNT)

9. Regra: O valor da transferência é obrigatório; se o campo de valor contiver apenas espaços, a entrada é considerada inválida e é exibida a mensagem 'The Amount entered must be numeric.' (a mensagem fala em valor numérico, mas o teste é de campo só com espaços).
   Condição: o campo de valor tem todas as posições preenchidas com espaços (quantidade de espaços iniciais igual ao tamanho do campo)
   Consequência: entrada inválida, com a mensagem indicada; as demais validações do valor não são feitas
   Parágrafo: VA010 (VALIDATE-AMOUNT)

10. Regra: Se o valor informado for composto apenas por dígitos e for menor ou igual a zero, a entrada é considerada inválida e é exibida a mensagem 'Please supply a positive amount.' (como o conteúdo é só de dígitos, na prática este caminho só é atingido por valor zero).
    Condição: valor numérico informado menor ou igual a zero (WS-AMOUNT-AS-FLOAT <= 0)
    Consequência: entrada inválida, com a mensagem indicada
    Parágrafo: VA010 (VALIDATE-AMOUNT)

11. Regra: Valor negativo não é aceito; se o valor informado contiver o sinal de menos, a entrada é considerada inválida e é exibida a mensagem 'Please supply a positive amount.' (o programa detecta a presença do caractere '-'; pode-se também interpretá-lo como verificação de sinal, mas a mensagem trata da exigência de valor positivo).
    Condição: o valor informado contém o caractere '-' (WS-NUM-COUNT-MINUS > 0)
    Consequência: entrada inválida, com a mensagem indicada; as demais validações do valor não são feitas
    Parágrafo: VA010 (VALIDATE-AMOUNT)

12. Regra: O valor pode ter no máximo duas casas decimais; se tiver mais, a entrada é considerada inválida e é exibida a mensagem 'Only up to two decimal places are supported.'
    Condição: o valor informado tem um ponto decimal e mais de dois dígitos depois dele
    Consequência: entrada inválida, com a mensagem indicada
    Parágrafo: VA010 (VALIDATE-AMOUNT)

13. Regra: O valor da transferência não pode ser zero; se o valor informado for zero, a entrada é considerada inválida e é exibida a mensagem 'Please supply a non-zero amount.'
    Condição: valor convertido igual a zero (WS-AMOUNT-AS-FLOAT = ZERO)
    Consequência: entrada inválida, com a mensagem indicada
    Parágrafo: VA010 (VALIDATE-AMOUNT)