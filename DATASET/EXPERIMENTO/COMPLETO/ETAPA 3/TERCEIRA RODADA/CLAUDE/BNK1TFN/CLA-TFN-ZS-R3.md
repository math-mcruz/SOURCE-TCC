1. Regra: A conta de origem e a conta de destino da transferência devem ser diferentes.
   Condição: O número da conta de origem (FACCNOI) é igual ao da conta de destino (TACCNOI).
   Consequência: A transferência é recusada com a mensagem "The FROM & TO account should be different" e não segue para processamento.
   Parágrafo: EDIT-DATA

2. Regra: A conta número 00000000 não é aceita como origem nem como destino da transferência.
   Condição: A conta de origem ou a conta de destino é igual a '00000000'.
   Consequência: A transferência é recusada com a mensagem "Account no 00000000 is not valid" e não segue para processamento.
   Parágrafo: EDIT-DATA

3. Regra: O valor da transferência é obrigatório.
   Condição: O campo de valor (AMTI) chega com tamanho zero (AMTL = zero).
   Consequência: A transferência é recusada. A mensagem exibida diz "The Amount entered must be numeric", embora o teste seja de ausência de preenchimento.
   Parágrafo: VALIDATE-AMOUNT

4. Regra: O valor da transferência não pode ser informado apenas com espaços em branco.
   Condição: O campo de valor não é numérico por classe e todos os seus caracteres são espaços (contagem de espaços à esquerda igual ao tamanho informado).
   Consequência: A transferência é recusada. A mensagem exibida diz "The Amount entered must be numeric", embora o teste seja de ausência de preenchimento.
   Parágrafo: VALIDATE-AMOUNT

5. Regra: Um valor inteiro menor ou igual a zero não é aceito na transferência.
   Condição: O valor informado é totalmente numérico (só dígitos) e o valor convertido (WS-AMOUNT-AS-FLOAT) é menor ou igual a zero.
   Consequência: A transferência é recusada com a mensagem "Please supply a positive amount".
   Parágrafo: VALIDATE-AMOUNT

6. Regra: Valores informados com sinal de menos não são aceitos na transferência.
   Condição: O valor informado não é só dígitos e contém o caractere '-' (WS-NUM-COUNT-MINUS maior que zero).
   Consequência: A transferência é recusada com a mensagem "Please supply a positive amount". Este teste procura o caractere de sinal, e não o valor numérico. Pode ser lido como regra de valor (não aceitar negativos) ou como validação de formato do sinal. Foi listado por rejeitar valores negativos.
   Parágrafo: VALIDATE-AMOUNT

7. Regra: O valor da transferência aceita no máximo duas casas decimais.
   Condição: O valor contém um único ponto decimal e há mais de dois dígitos depois do ponto.
   Consequência: A transferência é recusada com a mensagem "Only up to two decimal places are supported".
   Parágrafo: VALIDATE-AMOUNT

8. Regra: Um valor com casas decimais igual a zero não é aceito na transferência.
   Condição: O valor passou pelas demais validações (contém ponto decimal, pois valores só com dígitos são tratados na regra 5) e o valor convertido (WS-AMOUNT-AS-FLOAT) é igual a zero.
   Consequência: A transferência é recusada com a mensagem "Please supply a non-zero amount".
   Parágrafo: VALIDATE-AMOUNT

9. Regra: A transferência só é solicitada quando todos os dados informados passam nas validações.
   Condição: Os dados informados são válidos (VALID-DATA).
   Consequência: O programa solicita a execução da transferência ao programa XFRFUN. Quando os dados são inválidos, nenhuma transferência é solicitada.
   Parágrafo: PROCESS-MAP

10. Regra: A transferência não é realizada quando a conta de origem não é encontrada.
    Condição: O resultado da transferência é insucesso (SUBPGM-SUCCESS = 'N') com código de falha '1'.
    Consequência: É exibida a mensagem "Sorry the FROM ACCOUNT no was not found. Transfer not applied." e os saldos são exibidos zerados.
    Parágrafo: GET-ACC-DATA

11. Regra: A transferência não é realizada quando a conta de destino não é encontrada.
    Condição: O resultado da transferência é insucesso (SUBPGM-SUCCESS = 'N') com código de falha '2'.
    Consequência: É exibida a mensagem "Sorry the TO ACCOUNT no was not found. Transfer not applied." e os saldos são exibidos zerados.
    Parágrafo: GET-ACC-DATA

12. Regra: A transferência não é realizada quando o valor não é maior que zero, conforme apurado pelo programa de transferência.
    Condição: O resultado da transferência é insucesso (SUBPGM-SUCCESS = 'N') com código de falha '4'.
    Consequência: É exibida a mensagem "Please supply an amount greater than zero." e os saldos são exibidos zerados.
    Parágrafo: GET-ACC-DATA

13. Regra: Quando a transferência é aplicada com sucesso, o cliente é informado e vê os saldos atualizados das duas contas.
    Condição: O resultado da transferência é sucesso (SUBPGM-SUCCESS = 'Y').
    Consequência: É exibida a mensagem "Transfer successfully applied." junto com os saldos real e disponível da conta de origem e da conta de destino.
    Parágrafo: GET-ACC-DATA