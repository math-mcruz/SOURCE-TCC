1. Regra: A transferência só é solicitada ao serviço de transferência quando os dados informados passaram nas validações.
   Condição: Os dados da tela foram considerados válidos (VALID-DATA).
   Consequência: O programa aciona a rotina de transferência (XFRFUN) com as contas e o valor informados. Se os dados forem inválidos, a transferência não é solicitada e apenas a mensagem de erro é exibida.
   Parágrafo: PROCESS-MAP (PM010)

2. Regra: A conta de origem e a conta de destino não podem ser a mesma.
   Condição: O número da conta de origem (FACCNOI) é igual ao da conta de destino (TACCNOI).
   Consequência: Os dados são marcados como inválidos e é exibida a mensagem "The FROM & TO account should be different". A transferência não é solicitada.
   Parágrafo: EDIT-DATA (ED010)

3. Regra: O número de conta 00000000 não é aceito, nem como origem nem como destino.
   Condição: A conta de origem (FACCNOI) ou a conta de destino (TACCNOI) é igual a '00000000'.
   Consequência: Os dados são marcados como inválidos e é exibida a mensagem "Account no 00000000 is not valid". A transferência não é solicitada.
   Parágrafo: EDIT-DATA (ED010)

4. Regra: O valor da transferência é de preenchimento obrigatório (campo vazio).
   Condição: O campo de valor chega sem nenhum conteúdo digitado (AMTL = zero).
   Consequência: Os dados são marcados como inválidos e é exibida a mensagem "The Amount entered must be numeric". A mensagem fala em valor numérico, mas o teste é de campo sem conteúdo.
   Parágrafo: VALIDATE-AMOUNT (VA010)

5. Regra: Um valor numérico informado deve ser positivo.
   Condição: O valor informado é numérico (AMTI IS NUMERIC) e, convertido, é menor ou igual a zero (WS-AMOUNT-AS-FLOAT <= 0).
   Consequência: Os dados são marcados como inválidos e é exibida a mensagem "Please supply a positive amount". A transferência não é solicitada.
   Parágrafo: VALIDATE-AMOUNT (VA010)

6. Regra: O valor da transferência é de preenchimento obrigatório (campo só com espaços).
   Condição: O campo de valor tem conteúdo, mas só espaços (a contagem de espaços à esquerda é igual ao tamanho do campo).
   Consequência: Os dados são marcados como inválidos e é exibida a mensagem "The Amount entered must be numeric".
   Parágrafo: VALIDATE-AMOUNT (VA010)

7. Regra: Valor negativo não é aceito na transferência.
   Condição: O valor informado contém o caractere '-' (WS-NUM-COUNT-MINUS > 0). O programa trata a presença do sinal de menos como valor não positivo, mesmo que o restante do texto fosse inválido.
   Consequência: Os dados são marcados como inválidos e é exibida a mensagem "Please supply a positive amount".
   Parágrafo: VALIDATE-AMOUNT (VA010)

8. Regra: O valor da transferência aceita no máximo duas casas decimais.
   Condição: O valor informado tem um ponto decimal e mais de dois dígitos após ele (contagem final de dígitos após o ponto > 2). Este teste vem depois das verificações de formato.
   Consequência: Os dados são marcados como inválidos e é exibida a mensagem "Only up to two decimal places are supported".
   Parágrafo: VALIDATE-AMOUNT (VA010)

9. Regra: O valor da transferência não pode ser zero.
   Condição: O valor informado, depois de convertido para número, é igual a zero (WS-AMOUNT-AS-FLOAT = ZERO).
   Consequência: Os dados são marcados como inválidos e é exibida a mensagem "Please supply a non-zero amount".
   Parágrafo: VALIDATE-AMOUNT (VA010)

10. Regra: A transferência não é aplicada quando a conta de origem não é encontrada.
    Condição: A rotina de transferência informa falha (SUBPGM-SUCCESS = 'N') com código de falha '1'.
    Consequência: É exibida a mensagem "Sorry the FROM ACCOUNT no was not found. Transfer not applied." Os saldos são exibidos zerados.
    Parágrafo: GET-ACC-DATA (GCD010)

11. Regra: A transferência não é aplicada quando a conta de destino não é encontrada.
    Condição: A rotina de transferência informa falha (SUBPGM-SUCCESS = 'N') com código de falha '2'.
    Consequência: É exibida a mensagem "Sorry the TO ACCOUNT no was not found. Transfer not applied." Os saldos são exibidos zerados.
    Parágrafo: GET-ACC-DATA (GCD010)

12. Regra: A transferência não é aplicada quando o valor não é maior que zero, segundo a rotina de transferência.
    Condição: A rotina de transferência informa falha (SUBPGM-SUCCESS = 'N') com código de falha '4'.
    Consequência: É exibida a mensagem "Please supply an amount greater than zero." Os saldos são exibidos zerados.
    Parágrafo: GET-ACC-DATA (GCD010)

13. Regra: A transferência não é aplicada quando a rotina de transferência informa erro inesperado. Comportamento ambíguo.
    Condição: A rotina de transferência informa falha (SUBPGM-SUCCESS = 'N') com código de falha '3'.
    Consequência: O programa monta a mensagem "could not be applied due to an unexpected error", mas não sai do parágrafo. O teste seguinte (sucesso diferente de 'Y') sobrescreve a mensagem por "unable to determine success", que é a exibida ao final. Os saldos são exibidos zerados.
    Parágrafo: GET-ACC-DATA (GCD010)

14. Regra: A transferência não é aplicada quando a rotina de transferência informa uma falha com código não previsto.
    Condição: A rotina de transferência informa falha (SUBPGM-SUCCESS = 'N') com código de falha diferente de '1', '2', '3' e '4' (WHEN OTHER).
    Consequência: É exibida a mensagem "Sorry but the transfer could not be applied due to an error." Os saldos são exibidos zerados.
    Parágrafo: GET-ACC-DATA (GCD010)

15. Regra: Se a rotina de transferência não confirma sucesso, a transferência é tratada como não aplicada.
    Condição: O indicador de sucesso retornado é diferente de 'Y' (SUBPGM-SUCCESS NOT = 'Y'). Isso inclui o caso de falha com código '3', como descrito na regra 13.
    Consequência: É exibida a mensagem "Sorry but the transfer could not be applied unable to determine success." Os saldos são exibidos zerados.
    Parágrafo: GET-ACC-DATA (GCD010)

16. Regra: Quando a transferência é confirmada, o programa informa o sucesso e mostra os saldos atualizados das duas contas.
    Condição: A rotina de transferência retorna sucesso (SUBPGM-SUCCESS = 'Y').
    Consequência: É exibida a mensagem "Transfer successfully applied." com as contas, os códigos de agência e os saldos real e disponível da conta de origem e da conta de destino.
    Parágrafo: GET-ACC-DATA (GCD010)