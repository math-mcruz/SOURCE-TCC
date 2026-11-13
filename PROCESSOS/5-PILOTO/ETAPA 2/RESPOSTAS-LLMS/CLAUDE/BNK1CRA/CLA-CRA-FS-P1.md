1. Regra: Se a tela é chamada sem dados de sessão anterior (área de comunicação vazia), a tela de crédito/débito é exibida em branco para o usuário começar a operação.
   Condição: EIBCALEN igual a zero
   Consequência: a tela inicial é enviada limpa, com o cursor no campo de número da conta
   Parágrafo: A010 (PREMIERE SECTION)

2. Regra: Se o usuário pressiona a tecla PF3, a operação é encerrada e o usuário retorna ao menu principal (transação 'OMEN').
   Condição: tecla PF3 pressionada
   Consequência: retorno imediato ao menu principal
   Parágrafo: A010 (PREMIERE SECTION)

3. Regra: Se o usuário pressiona PF12 (ou a tecla DFHAID), a sessão é encerrada com a mensagem 'Session Ended'.
   Condição: tecla PF12 ou DFHAID pressionada
   Consequência: mensagem de fim de sessão e término da transação
   Parágrafo: A010 (PREMIERE SECTION)

4. Regra: Se o usuário pressiona uma tecla que não é reconhecida pelo programa, é exibida a mensagem 'Invalid key pressed.'
   Condição: tecla pressionada diferente de PA1/PA2/PA3, PF3, PF12, CLEAR e ENTER
   Consequência: mensagem 'Invalid key pressed.' com alarme
   Parágrafo: A010 (PREMIERE SECTION)

5. Regra: Se o número da conta não for informado, a entrada é considerada inválida e é exibida a mensagem 'Please enter an account number.'
   Condição: número da conta (ACCNOI) sem valor numérico informado
   Consequência: entrada inválida, com a mensagem indicada; as demais validações não são feitas. Observação: o teste é de valor numérico (NOT NUMERIC), o que indica formato; foi listado porque a mensagem trata de obrigatoriedade, mas pelo critério do código seria classificado como formato — ambíguo.
   Parágrafo: ED010 (EDIT-DATA)

6. Regra: Se o número da conta informado for zero, a entrada é considerada inválida e é exibida a mensagem 'Please enter a non zero account number.'
   Condição: número da conta (ACCNOI) igual a zero
   Consequência: entrada inválida, com a mensagem indicada; as demais validações não são feitas
   Parágrafo: ED010 (EDIT-DATA)

7. Regra: Se o sinal informado antes do valor não for '+' nem '-', a entrada é considerada inválida e é exibida a mensagem 'Please enter + or - preceding the amount'. A checagem só ocorre quando o campo de sinal foi preenchido (SIGNL = 1).
   Condição: sinal (SIGNI) diferente de '+' e '-', com o campo de sinal preenchido
   Consequência: entrada inválida, com a mensagem indicada; as demais validações não são feitas
   Parágrafo: ED010 (EDIT-DATA)

8. Regra: Se o valor não for informado (campo de valor com tamanho zero), a entrada é considerada inválida e é exibida a mensagem 'The Amount entered must be numeric.'
   Condição: tamanho do campo de valor (AMTL) igual a zero
   Consequência: entrada inválida, com a mensagem indicada; as demais validações do valor não são feitas
   Parágrafo: VA010 (VALIDATE-AMOUNT)

9. Regra: Se o campo de valor contiver apenas espaços, a entrada é considerada inválida e é exibida a mensagem 'The Amount entered must be numeric.'
   Condição: campo de valor (AMTI) composto somente por espaços
   Consequência: entrada inválida, com a mensagem indicada; as demais validações do valor não são feitas
   Parágrafo: VA010 (VALIDATE-AMOUNT)

10. Regra: Se o valor informado, depois de convertido, for igual a zero, a entrada é considerada inválida e é exibida a mensagem 'Please supply a non-zero amount.'
    Condição: valor convertido (WS-AMOUNT-AS-FLOAT) igual a zero
    Consequência: entrada inválida, com a mensagem indicada
    Parágrafo: VA010 (VALIDATE-AMOUNT)

11. Regra: Se o valor informado tiver mais de duas casas decimais com algum dígito significativo após a segunda casa, a entrada é considerada inválida e é exibida a mensagem 'Only up to two decimal places are supported.'
    Condição: valor com ponto decimal e mais de dois dígitos numéricos após o ponto
    Consequência: entrada inválida, com a mensagem indicada
    Parágrafo: VA010 (VALIDATE-AMOUNT)

12. Regra: Se o valor for válido, o movimento é aplicado à conta; quando o sinal informado é '-', o valor é tratado como negativo (débito), caso contrário como positivo (crédito).
    Condição: sinal informado igual a '-'
    Consequência: o valor enviado para processamento é multiplicado por -1 (tratado como débito)
    Parágrafo: UCD010 (UPD-CRED-DATA)

13. Regra: Se a conta informada não for encontrada para o código de agência (sort code), o valor não é aplicado e é exibida a mensagem 'Sorry but the ACCOUNT no was not found for SORTCODE ... . Amount not applied.'
    Condição: indicador de falha do processamento retorna 'N' com código de falha '1'
    Consequência: valor não aplicado, entrada marcada como inválida e mensagem indicada
    Parágrafo: UCD010 (UPD-CRED-DATA)

14. Regra: Se ocorrer um erro inesperado ao aplicar o valor, o valor não é aplicado e é exibida a mensagem 'Sorry but the AMOUNT could not be applied due to an unexpected error.'
    Condição: indicador de falha 'N' com código de falha '2'
    Consequência: valor não aplicado, entrada marcada como inválida e mensagem indicada
    Parágrafo: UCD010 (UPD-CRED-DATA)

15. Regra: Se não houver saldo suficiente para o movimento, o valor não é aplicado e é exibida a mensagem 'Sorry insufficient funds available to process the request.'
    Condição: indicador de falha 'N' com código de falha '3'
    Consequência: valor não aplicado, entrada marcada como inválida e mensagem indicada
    Parágrafo: UCD010 (UPD-CRED-DATA)

16. Regra: Se a aplicação do valor falhar com qualquer outro código de falha não previsto, o valor não é aplicado e é exibida a mensagem de erro inesperado seguida do código de falha.
    Condição: indicador de falha 'N' com código de falha diferente de '1', '2' e '3'
    Consequência: valor não aplicado, entrada marcada como inválida e mensagem 'Sorry but the AMOUNT could not be applied due to an unexpected error.' com o código de falha
    Parágrafo: UCD010 (UPD-CRED-DATA)

17. Regra: Se o valor for aplicado com sucesso, é exibida a mensagem 'Amount successfully applied to the account.' junto com o número da conta, o código da agência e os saldos atual e disponível.
    Condição: indicador de sucesso diferente de 'N'
    Consequência: mensagem de sucesso e exibição da conta, agência e saldos
    Parágrafo: UCD010 (UPD-CRED-DATA)

18. Regra: A operação de crédito/débito só é processada se todas as validações de entrada forem aprovadas; caso contrário, nenhum valor é aplicado e apenas a mensagem de erro é exibida.
    Condição: entrada considerada válida (VALID-DATA)
    Consequência: se válida, o valor é enviado para aplicação na conta; se inválida, a atualização não é feita
    Parágrafo: PM010 (PROCESS-MAP)