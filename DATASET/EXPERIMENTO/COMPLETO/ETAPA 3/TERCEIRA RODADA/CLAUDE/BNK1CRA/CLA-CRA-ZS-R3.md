1. Regra: Os dados informados só são enviados para aplicação na conta se tiverem passado em todas as validações da tela.
   Condição: Os dados da tela foram considerados válidos (VALID-DATA).
   Consequência: A solicitação de crédito ou débito é enviada para processamento na conta; caso contrário, nenhum valor é aplicado e apenas a mensagem de erro é exibida.
   Parágrafo: PROCESS-MAP

2. Regra: O número da conta não pode ser zero.
   Condição: O número da conta informado é igual a zero (ACCNOI = ZERO).
   Consequência: A operação é recusada com a mensagem "Please enter a non zero account number" e nenhum valor é aplicado.
   Parágrafo: EDIT-DATA

3. Regra: Quando o sinal do valor é informado, só são aceitos "+" ou "-".
   Condição: O campo de sinal foi preenchido (SIGNL = 1) com um caractere diferente de "+" e "-".
   Consequência: A operação é recusada com a mensagem "Please enter + or - preceding the amount" e nenhum valor é aplicado. Se o sinal não for preenchido, o código não recusa a operação, e o valor segue como positivo (crédito) por não ser "-".
   Parágrafo: EDIT-DATA

4. Regra: O valor informado com sinal "-" é tratado como débito na conta.
   Condição: O sinal informado é "-" (SIGNI = '-').
   Consequência: O valor é invertido para negativo antes de ser enviado para aplicação na conta. Nos demais casos, o valor segue positivo (crédito).
   Parágrafo: UPD-CRED-DATA

5. Regra: Se a conta não for encontrada para o código de agência (sort code), o valor não é aplicado.
   Condição: O processamento da conta retorna falha com código '1' (SUBPGM-SUCCESS = 'N' e SUBPGM-FAIL-CODE = '1').
   Consequência: Exibe a mensagem de que a conta não foi encontrada para o sort code e que o valor não foi aplicado, e nenhum saldo é exibido.
   Parágrafo: UPD-CRED-DATA

6. Regra: Se não houver saldo suficiente, o débito não é processado.
   Condição: O processamento da conta retorna falha com código '3' (SUBPGM-SUCCESS = 'N' e SUBPGM-FAIL-CODE = '3').
   Consequência: Exibe a mensagem "Sorry insufficient funds available to process the request", o valor não é aplicado e nenhum saldo é exibido.
   Parágrafo: UPD-CRED-DATA

7. Regra: Quando o processamento da conta é bem-sucedido, o valor é aplicado e os saldos atualizados são mostrados.
   Condição: O processamento da conta não retorna falha (SUBPGM-SUCCESS diferente de 'N').
   Consequência: Exibe a mensagem "Amount successfully applied to the account", mostrando o número da conta, o sort code, o saldo atual e o saldo disponível.
   Parágrafo: UPD-CRED-DATA

8. Regra: O valor da operação é obrigatório (campo não pode ficar vazio).
   Condição: O campo de valor foi enviado sem conteúdo (tamanho zero, AMTL = ZERO).
   Consequência: A operação é recusada com a mensagem "The Amount entered must be numeric" e nenhum valor é aplicado.
   Parágrafo: VALIDATE-AMOUNT

9. Regra: O valor da operação não pode ser composto apenas por espaços em branco.
   Condição: Todos os caracteres do valor informado são espaços (contagem de espaços à esquerda igual ao tamanho do campo).
   Consequência: A operação é recusada com a mensagem "The Amount entered must be numeric" e nenhum valor é aplicado.
   Parágrafo: VALIDATE-AMOUNT

10. Regra: O valor da operação aceita no máximo duas casas decimais.
    Condição: O valor contém um ponto decimal seguido de mais de dois caracteres (WS-NUM-COUNT-POINT = 1 e mais de 2 posições após o ponto). O código reconta os dígitos após o ponto, mas o resultado equivale ao mesmo limite de duas casas, e a contagem tem uma lógica pouco clara.
    Consequência: A operação é recusada com a mensagem "Only up to two decimal places are supported" e nenhum valor é aplicado.
    Parágrafo: VALIDATE-AMOUNT

11. Regra: O valor da operação não pode ser zero.
    Condição: O valor informado, depois de convertido, é igual a zero (WS-AMOUNT-AS-FLOAT = ZERO).
    Consequência: A operação é recusada com a mensagem "Please supply a non-zero amount" e nenhum valor é aplicado.
    Parágrafo: VALIDATE-AMOUNT