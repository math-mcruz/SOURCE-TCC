1. Regra: O lançamento de crédito/débito só é enviado para processamento na conta se todas as validações dos dados informados tiverem sido aprovadas; caso contrário, nada é aplicado e a tela é reexibida com a mensagem de erro correspondente.
   Condição: os dados informados passaram em todas as validações (VALID-DATA)
   Consequência: o lançamento é processado; se as validações falharem, o lançamento não é processado e a mensagem de erro é exibida
   Parágrafo: PM010 (PROCESS-MAP)

2. Regra: O número da conta informado não pode ser zero; se for, a entrada é considerada inválida e é exibida a mensagem 'Please enter a non zero account number.'
   Condição: número da conta igual a zero (ACCNOI = ZERO)
   Consequência: entrada inválida, com a mensagem indicada; as demais validações não são feitas
   Parágrafo: ED010 (EDIT-DATA)

3. Regra: Quando o sinal do valor é informado, ele deve ser '+' ou '-'; com qualquer outro sinal, a entrada é considerada inválida e é exibida a mensagem 'Please enter + or - preceding the amount'. O código só testa isso quando o campo de sinal tem tamanho 1; se o sinal não for informado, a validação não bloqueia e o comportamento posterior é tratar o valor como positivo (ambíguo quanto a ser a intenção de negócio).
   Condição: sinal informado (SIGNL = 1) diferente de '+' e de '-'
   Consequência: entrada inválida, com a mensagem indicada; as demais validações não são feitas
   Parágrafo: ED010 (EDIT-DATA)

4. Regra: O valor do lançamento é obrigatório; se o campo de valor vier sem conteúdo (tamanho zero), a entrada é considerada inválida e é exibida a mensagem 'The Amount entered must be numeric.'
   Condição: campo de valor sem conteúdo (AMTL igual a zero)
   Consequência: entrada inválida, com a mensagem indicada; as demais validações do valor não são feitas
   Parágrafo: VA010 (VALIDATE-AMOUNT)

5. Regra: O valor do lançamento não pode ser composto só de espaços em branco; se for, a entrada é considerada inválida e é exibida a mensagem 'The Amount entered must be numeric.'
   Condição: o campo de valor contém apenas espaços (quantidade de espaços iniciais igual ao tamanho informado), quando o conteúdo não é puramente numérico
   Consequência: entrada inválida, com a mensagem indicada; as demais validações do valor não são feitas
   Parágrafo: VA010 (VALIDATE-AMOUNT)

6. Regra: O valor do lançamento aceita no máximo duas casas decimais; com mais de duas casas, a entrada é considerada inválida e é exibida a mensagem 'Only up to two decimal places are supported.' A lógica de contagem dos dígitos após o ponto é pouco clara no código (recontagem em dois passos), então a aplicação exata do limite pode divergir do esperado.
   Condição: valor com ponto decimal e mais de dois dígitos após o ponto
   Consequência: entrada inválida, com a mensagem indicada
   Parágrafo: VA010 (VALIDATE-AMOUNT)

7. Regra: O valor do lançamento não pode ser zero; se o valor convertido for zero, a entrada é considerada inválida e é exibida a mensagem 'Please supply a non-zero amount.' Atenção: esse teste só é alcançado quando o valor não é puramente numérico (por exemplo, com ponto decimal); um valor puramente numérico igual a zero é aceito pela validação sem passar por esta regra.
   Condição: valor convertido igual a zero (WS-AMOUNT-AS-FLOAT = ZERO), para entradas que não são puramente numéricas
   Consequência: entrada inválida, com a mensagem indicada
   Parágrafo: VA010 (VALIDATE-AMOUNT)

8. Regra: Quando o sinal informado é '-', o valor é tratado como negativo (débito) antes de ser enviado para aplicação na conta; com sinal '+' (ou sem sinal), o valor segue positivo (crédito).
   Condição: sinal informado igual a '-' (SIGNI = '-')
   Consequência: o valor do lançamento é multiplicado por -1 antes de ser aplicado à conta
   Parágrafo: UCD010 (UPD-CRED-DATA)

9. Regra: Se a conta informada não for encontrada para o código de agência (sort code), o valor não é aplicado e é exibida a mensagem 'Sorry but the ACCOUNT no was not found for SORTCODE ... . Amount not applied.'
   Condição: o processamento do lançamento retorna insucesso com código de falha '1'
   Consequência: dados marcados como inválidos, valor não aplicado, mensagem de conta não encontrada exibida; saldos não são atualizados na tela
   Parágrafo: UCD010 (UPD-CRED-DATA)

10. Regra: Se não houver saldo suficiente para processar o lançamento, o valor não é aplicado e é exibida a mensagem 'Sorry insufficient funds available to process the request.'
    Condição: o processamento do lançamento retorna insucesso com código de falha '3'
    Consequência: dados marcados como inválidos, valor não aplicado, mensagem de fundos insuficientes exibida; saldos não são atualizados na tela
    Parágrafo: UCD010 (UPD-CRED-DATA)

11. Regra: Quando o lançamento é processado com sucesso, é exibida a mensagem 'Amount successfully applied to the account.' junto com o número da conta, o código de agência e os saldos atual e disponível atualizados.
    Condição: o processamento do lançamento não retorna insucesso (SUBPGM-SUCCESS diferente de 'N')
    Consequência: mensagem de sucesso exibida e conta, agência, saldo atual e saldo disponível mostrados na tela
    Parágrafo: UCD010 (UPD-CRED-DATA)