1. Regra: A atualização do saldo da conta com o valor informado só é solicitada se todas as validações da tela forem aprovadas (VALID-DATA). Se alguma validação falhar, o valor não é aplicado e a tela é reapresentada com a mensagem de erro.
   Condição: dados informados válidos (VALID-DATA-SW = 'Y')
   Consequência: o valor é enviado para aplicação na conta (UPD-CRED-DATA); caso contrário, nada é aplicado
   Parágrafo: PM010 (PROCESS-MAP)

2. Regra: Se o número da conta informado for zero, a entrada é considerada inválida e é exibida a mensagem 'Please enter a non zero account number.'
   Condição: número da conta (ACCNOI) igual a zero
   Consequência: entrada inválida, com a mensagem indicada; as demais validações não são feitas
   Parágrafo: ED010 (EDIT-DATA)

3. Regra: Se o sinal do valor for informado, deve ser '+' ou '-'. Com outro sinal, a entrada é considerada inválida e é exibida a mensagem 'Please enter + or - preceding the amount'. O código não exige o sinal: se o campo de sinal vier vazio, nenhum erro é gerado (comportamento ambíguo quanto à obrigatoriedade do sinal).
   Condição: campo de sinal preenchido (SIGNL = 1) com valor diferente de '+' e '-'
   Consequência: entrada inválida, com a mensagem indicada; as demais validações não são feitas
   Parágrafo: ED010 (EDIT-DATA)

4. Regra: Se o valor não for informado (campo de tamanho zero), a entrada é considerada inválida e é exibida a mensagem 'The Amount entered must be numeric.'
   Condição: tamanho do campo de valor (AMTL) igual a zero
   Consequência: entrada inválida, com a mensagem indicada; as demais validações do valor não são feitas
   Parágrafo: VA010 (VALIDATE-AMOUNT)

5. Regra: Se o campo de valor contiver apenas espaços, a entrada é considerada inválida e é exibida a mensagem 'The Amount entered must be numeric.'
   Condição: o campo de valor é composto somente por espaços
   Consequência: entrada inválida, com a mensagem indicada; as demais validações do valor não são feitas
   Parágrafo: VA010 (VALIDATE-AMOUNT)

6. Regra: O valor pode ter no máximo duas casas decimais; com mais de duas, a entrada é considerada inválida e é exibida a mensagem 'Only up to two decimal places are supported.' Comportamento ambíguo: o teste final que emite essa mensagem conta os dígitos a partir da posição seguinte ao ponto decimal, buscando um novo ponto que não existe nesse trecho. Na leitura do código, a contagem tende a ficar em zero e a mensagem nunca é exibida, e um valor com mais de duas casas decimais seguiria adiante.
   Condição: valor com ponto decimal e mais de dois dígitos após o ponto (WS-NUM-COUNT-TOTAL > 2, conferido duas vezes)
   Consequência: entrada inválida, com a mensagem indicada (conforme a ressalva acima)
   Parágrafo: VA010 (VALIDATE-AMOUNT)

7. Regra: Se o valor informado for zero, a entrada é considerada inválida e é exibida a mensagem 'Please supply a non-zero amount.'
   Condição: valor convertido (WS-AMOUNT-AS-FLOAT) igual a zero
   Consequência: entrada inválida, com a mensagem indicada
   Parágrafo: VA010 (VALIDATE-AMOUNT)

8. Regra: Se o sinal informado for '-', o valor é tratado como negativo (débito) ao ser enviado para aplicação na conta. Nos demais casos o valor segue positivo (crédito).
   Condição: sinal (SIGNI) igual a '-'
   Consequência: o valor é multiplicado por -1 antes de ser aplicado na conta
   Parágrafo: UCD010 (UPD-CRED-DATA)

9. Regra: Se a conta não for encontrada para o código de agência (retorno '1' da rotina DBCRFUN), o valor não é aplicado e é exibida a mensagem 'Sorry but the ACCOUNT no was not found for SORTCODE ... . Amount not applied.'
   Condição: aplicação sem sucesso (SUBPGM-SUCCESS = 'N') com código de falha '1'
   Consequência: entrada marcada como inválida; mensagem de conta não encontrada, sem exibir os saldos
   Parágrafo: UCD010 (UPD-CRED-DATA)

10. Regra: Se ocorrer erro inesperado na aplicação do valor (código de falha '2'), o valor não é aplicado e é exibida a mensagem 'Sorry but the AMOUNT could not be applied due to an unexpected error.'
    Condição: aplicação sem sucesso (SUBPGM-SUCCESS = 'N') com código de falha '2'
    Consequência: entrada marcada como inválida; mensagem de erro inesperado, sem exibir os saldos
    Parágrafo: UCD010 (UPD-CRED-DATA)

11. Regra: Se não houver saldo suficiente para processar o pedido (código de falha '3'), o valor não é aplicado e é exibida a mensagem 'Sorry insufficient funds available to process the request.'
    Condição: aplicação sem sucesso (SUBPGM-SUCCESS = 'N') com código de falha '3'
    Consequência: entrada marcada como inválida; mensagem de saldo insuficiente, sem exibir os saldos
    Parágrafo: UCD010 (UPD-CRED-DATA)

12. Regra: Se a aplicação falhar com qualquer outro código de falha, o valor não é aplicado e é exibida a mensagem de erro inesperado acompanhada do código de falha recebido.
    Condição: aplicação sem sucesso (SUBPGM-SUCCESS = 'N') com código de falha diferente de '1', '2' e '3'
    Consequência: entrada marcada como inválida; mensagem 'Sorry but the AMOUNT could not be applied due to an unexpected error.' seguida do código de falha, sem exibir os saldos
    Parágrafo: UCD010 (UPD-CRED-DATA)

13. Regra: Se o valor for aplicado com sucesso à conta, é exibida a mensagem 'Amount successfully applied to the account.' junto com o número da conta, o código da agência, o saldo atual e o saldo disponível.
    Condição: aplicação com sucesso (SUBPGM-SUCCESS diferente de 'N')
    Consequência: mensagem de sucesso e exibição da conta, da agência e dos saldos atual e disponível
    Parágrafo: UCD010 (UPD-CRED-DATA)