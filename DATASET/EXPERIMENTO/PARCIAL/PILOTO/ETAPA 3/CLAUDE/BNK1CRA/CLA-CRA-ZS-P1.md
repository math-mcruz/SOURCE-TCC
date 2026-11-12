1. Regra: A conta informada não pode ser zero; o sistema pede uma conta diferente de zero.
   Condição: O número da conta informado é igual a zero (ACCNOI = ZERO).
   Consequência: Exibe a mensagem "Please enter a non zero account number", marca os dados como inválidos e não aplica o valor.
   Parágrafo: EDIT-DATA (ED010)

2. Regra: O sinal do valor deve ser "+" (crédito) ou "-" (débito).
   Condição: O campo de sinal foi preenchido com um único caractere (SIGNL = 1) e esse caractere não é "+" nem "-". Se o sinal for deixado vazio, ou tiver mais de um caractere, o código não aplica este teste, e o resultado nesses casos não fica claro no programa.
   Consequência: Exibe a mensagem "Please enter + or - preceding the amount", marca os dados como inválidos e não aplica o valor.
   Parágrafo: EDIT-DATA (ED010)

3. Regra: O valor da operação é obrigatório.
   Condição: O campo de valor tem tamanho zero (AMTL = ZERO).
   Consequência: Exibe uma mensagem de erro (o texto fala em valor "numérico"), marca os dados como inválidos e não aplica o valor.
   Parágrafo: VALIDATE-AMOUNT (VA010)

4. Regra: O valor da operação não pode ser composto apenas de espaços.
   Condição: Todos os caracteres do valor informado são espaços (contagem de espaços iniciais igual ao tamanho do campo).
   Consequência: Exibe uma mensagem de erro (o texto fala em valor "numérico"), marca os dados como inválidos e não aplica o valor.
   Parágrafo: VALIDATE-AMOUNT (VA010)

5. Regra: O valor da operação aceita no máximo duas casas decimais.
   Condição: O valor informado tem ponto decimal e mais de dois dígitos depois dele.
   Consequência: Exibe a mensagem "Only up to two decimal places are supported", marca os dados como inválidos e não aplica o valor.
   Parágrafo: VALIDATE-AMOUNT (VA010)

6. Regra: O valor da operação não pode ser zero.
   Condição: O valor informado, depois de convertido, é igual a zero (WS-AMOUNT-AS-FLOAT = ZERO).
   Consequência: Exibe a mensagem "Please supply a non-zero amount", marca os dados como inválidos e não aplica o valor.
   Parágrafo: VALIDATE-AMOUNT (VA010)

7. Regra: O valor só é aplicado à conta quando todos os dados informados passam nas validações.
   Condição: Os dados informados foram considerados válidos (VALID-DATA).
   Consequência: Chama a rotina que aplica o valor à conta. Se os dados forem inválidos, a rotina não é chamada e apenas a mensagem de erro é exibida.
   Parágrafo: PROCESS-MAP (PM010)

8. Regra: Quando o sinal informado é "-", o valor é aplicado como negativo (débito).
   Condição: O sinal informado é "-" (SIGNI = '-').
   Consequência: O valor é multiplicado por -1 antes de ser enviado para aplicação na conta. Com qualquer outro sinal, o valor é enviado como positivo.
   Parágrafo: UPD-CRED-DATA (UCD010)

9. Regra: O valor não é aplicado se a conta não existir para o código de agência (sort code) informado.
   Condição: A rotina de aplicação retorna falha (SUBPGM-SUCCESS = 'N') com código de falha '1'.
   Consequência: Exibe a mensagem "a conta não foi encontrada para o SORTCODE ... Valor não aplicado" e marca os dados como inválidos. Os saldos não são exibidos.
   Parágrafo: UPD-CRED-DATA (UCD010)

10. Regra: O valor não é aplicado se não houver saldo suficiente.
    Condição: A rotina de aplicação retorna falha (SUBPGM-SUCCESS = 'N') com código de falha '3'.
    Consequência: Exibe a mensagem "Sorry insufficient funds available to process the request" e marca os dados como inválidos. Os saldos não são exibidos.
    Parágrafo: UPD-CRED-DATA (UCD010)

11. Regra: Quando o valor é aplicado com sucesso, o sistema confirma a operação e mostra a conta e os saldos.
    Condição: A rotina de aplicação não retorna falha. O código trata qualquer valor diferente de 'N' em SUBPGM-SUCCESS como sucesso.
    Consequência: Exibe a mensagem "Amount successfully applied to the account" e mostra o número da conta, o código de agência, o saldo atual e o saldo disponível.
    Parágrafo: UPD-CRED-DATA (UCD010)