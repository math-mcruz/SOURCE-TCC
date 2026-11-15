1. Regra: A conta de origem e a conta de destino de uma transferência não podem ser a mesma.
   Condição: O número da conta de origem (FACCNOI) é igual ao da conta de destino (TACCNOI).
   Consequência: A transferência é recusada com a mensagem "The FROM & TO account should be different" e não é enviada para processamento.
   Parágrafo: EDIT-DATA

2. Regra: A conta número 00000000 não é aceita como conta de origem nem como conta de destino.
   Condição: O número da conta de origem (FACCNOI) ou o da conta de destino (TACCNOI) é '00000000'.
   Consequência: A transferência é recusada com a mensagem "Account no 00000000 is not valid" e não é enviada para processamento.
   Parágrafo: EDIT-DATA

3. Regra: O valor da transferência é obrigatório.
   Condição: O campo de valor chega com tamanho zero (AMTL = ZERO).
   Consequência: A transferência é recusada, e a mensagem exibida é "The Amount entered must be numeric.", embora o teste seja de ausência de conteúdo.
   Parágrafo: VALIDATE-AMOUNT

4. Regra: O valor da transferência não pode ser deixado só com espaços em branco.
   Condição: Todos os caracteres do campo de valor são espaços (quantidade de espaços iniciais = AMTL).
   Consequência: A transferência é recusada, e a mensagem exibida é "The Amount entered must be numeric.", embora o teste seja de ausência de conteúdo.
   Parágrafo: VALIDATE-AMOUNT

5. Regra: Um valor numérico igual ou menor que zero não é aceito na transferência.
   Condição: O valor informado é numérico e o valor convertido (WS-AMOUNT-AS-FLOAT) é menor ou igual a zero. Como o teste de valor numérico já exclui o sinal de menos, na prática o caminho recusa o valor zero.
   Consequência: A transferência é recusada com a mensagem "Please supply a positive amount." e não é enviada para processamento.
   Parágrafo: VALIDATE-AMOUNT

6. Regra: Valor negativo não é aceito na transferência.
   Condição: O valor informado contém o caractere de menos '-' (WS-NUM-COUNT-MINUS > 0). O código identifica o valor negativo apenas pela presença do sinal, e esse teste pode também ser lido como validação de formato.
   Consequência: A transferência é recusada com a mensagem "Please supply a positive amount." e não é enviada para processamento.
   Parágrafo: VALIDATE-AMOUNT

7. Regra: O valor da transferência aceita no máximo duas casas decimais.
   Condição: O valor informado tem mais de dois dígitos após o ponto decimal.
   Consequência: A transferência é recusada com a mensagem "Only up to two decimal places are supported." e não é enviada para processamento.
   Parágrafo: VALIDATE-AMOUNT

8. Regra: O valor zero não é aceito na transferência.
   Condição: O valor informado, depois de convertido, é igual a zero (WS-AMOUNT-AS-FLOAT = ZERO).
   Consequência: A transferência é recusada com a mensagem "Please supply a non-zero amount." e não é enviada para processamento.
   Parágrafo: VALIDATE-AMOUNT

9. Regra: A transferência não é aplicada quando a conta de origem não é encontrada.
   Condição: O processamento da transferência (programa XFRFUN) falha (SUBPGM-SUCCESS = 'N') com o código de falha '1'.
   Consequência: A transferência não é aplicada, e a mensagem informa que a conta de origem não foi encontrada.
   Parágrafo: GET-ACC-DATA

10. Regra: A transferência não é aplicada quando a conta de destino não é encontrada.
    Condição: O processamento da transferência (programa XFRFUN) falha (SUBPGM-SUCCESS = 'N') com o código de falha '2'.
    Consequência: A transferência não é aplicada, e a mensagem informa que a conta de destino não foi encontrada.
    Parágrafo: GET-ACC-DATA

11. Regra: A transferência não é aplicada quando o valor não é maior que zero, segundo o processamento da transferência.
    Condição: O processamento da transferência (programa XFRFUN) falha (SUBPGM-SUCCESS = 'N') com o código de falha '4'.
    Consequência: A transferência não é aplicada, e a mensagem pede um valor maior que zero.
    Parágrafo: GET-ACC-DATA

12. Regra: Quando a transferência é aplicada com sucesso, o usuário recebe a confirmação e os saldos atualizados.
    Condição: O processamento da transferência (programa XFRFUN) retorna sucesso (SUBPGM-SUCCESS = 'Y').
    Consequência: Aparece a mensagem "Transfer successfully applied.", com as contas e os saldos real e disponível das contas de origem e de destino atualizados.
    Parágrafo: GET-ACC-DATA