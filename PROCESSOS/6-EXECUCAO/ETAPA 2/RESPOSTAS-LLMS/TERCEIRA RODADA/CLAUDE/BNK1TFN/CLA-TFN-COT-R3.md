## Análise

**1. Parágrafos e fluxo principal**

- **PREMIERE (A010):** recebe a tecla ou o estado da tela e decide o que fazer. Na tecla ENTER chama PROCESS-MAP. Depois devolve o controle à transação OTFN.
- **PROCESS-MAP:** coordena o ciclo. Chama RECEIVE-MAP, depois EDIT-DATA, depois GET-ACC-DATA (se os dados forem válidos) e por fim SEND-MAP.
- **RECEIVE-MAP:** lê os dados digitados na tela.
- **EDIT-DATA:** valida as contas de origem (FROM) e destino (TO) e chama VALIDATE-AMOUNT.
- **VALIDATE-AMOUNT:** valida o valor a transferir.
- **GET-ACC-DATA:** chama o subprograma XFRFUN, que efetiva a transferência. Interpreta o retorno e monta a mensagem e os saldos.
- **SEND-MAP:** envia a tela.
- **SEND-TERMINATION-MSG:** envia a mensagem "Session Ended".
- **ABEND-THIS-TASK:** encerra a tarefa com erro.
- **POPULATE-TIME-DATE:** obtém data e hora para o registro técnico.

Fluxo principal: a tela é exibida, o usuário informa as contas e o valor e pressiona ENTER. O programa valida, aciona XFRFUN e mostra a mensagem de resultado e os saldos.

**2 e 3. Estruturas de decisão e classificação**

| Parágrafo | Estrutura | Classificação |
|---|---|---|
| A010 | EVALUATE de EIBCALEN e EIBAID (primeira exibição, PA1-3, PF3, PF12, CLEAR, ENTER, outra tecla) | Interface |
| A010, RECEIVE-MAP, SEND-MAP, SEND-TERMINATION-MSG | IF de WS-CICS-RESP diferente de NORMAL | Infraestrutura |
| SEND-MAP | IF SEND-ERASE, SEND-DATAONLY, SEND-DATAONLY-ALARM | Interface |
| PROCESS-MAP | IF VALID-DATA | Negócio (a transferência só é pedida se os dados forem válidos) |
| EDIT-DATA | IF FACCNOI/TACCNOI NOT NUMERIC | Formato do campo, fora do escopo, apesar da mensagem pedir para informar a conta |
| EDIT-DATA | IF FACCNOI = TACCNOI | Negócio |
| EDIT-DATA | IF conta = '00000000' | Negócio |
| VALIDATE-AMOUNT | IF AMTL = ZERO | Negócio (obrigatoriedade, teste de tamanho zero) |
| VALIDATE-AMOUNT | IF AMTI(1:AMTL) IS NUMERIC | Intermediário. Leva ao teste de valor <= 0, que é negócio. |
| VALIDATE-AMOUNT | IF WS-AMOUNT-AS-FLOAT <= 0 | Negócio |
| VALIDATE-AMOUNT | IF WS-NUM-COUNT-TOTAL = AMTL (campo só com espaços) | Negócio (obrigatoriedade) |
| VALIDATE-AMOUNT | IF WS-NUM-COUNT-TOTAL = ZERO (com ou sem espaços à esquerda) | Técnico de tratamento do texto |
| VALIDATE-AMOUNT | IF WS-NUM-COUNT-MINUS > 0 | Negócio (valor negativo não aceito) |
| VALIDATE-AMOUNT | IF WS-NUM-COUNT-SPACE > 0 (espaços no meio) | Formato, fora do escopo |
| VALIDATE-AMOUNT | IF WS-NUM-COUNT-TOTAL < WS-AMOUNT-UNSTR-L (caracteres não numéricos) | Formato, fora do escopo |
| VALIDATE-AMOUNT | IF WS-NUM-COUNT-POINT > 1 | Formato, fora do escopo |
| VALIDATE-AMOUNT | IF WS-NUM-COUNT-POINT = 1, depois mais de 2 casas decimais, depois nova contagem > 2 | Negócio (testes aninhados com uma única consequência final) |
| VALIDATE-AMOUNT | IF WS-AMOUNT-AS-FLOAT = ZERO | Negócio |
| GET-ACC-DATA | IF SUBPGM-SUCCESS = 'N' e EVALUATE SUBPGM-FAIL-CODE | '1', '2' e '4' são negócio. '3' e OTHER são erros técnicos, infraestrutura. |
| GET-ACC-DATA | IF SUBPGM-SUCCESS NOT = 'Y' / ELSE | O ramo ELSE (sucesso) é negócio. O ramo "não foi possível determinar o sucesso" é infraestrutura. |

**4. Condição e consequência das estruturas de negócio**

- **VALID-DATA:** se todas as validações passam, a transferência é solicitada ao subprograma XFRFUN. Caso contrário, só a mensagem de erro é exibida.
- **Contas iguais:** FROM e TO iguais levam a erro e a transferência não é solicitada.
- **Conta 00000000:** conta de origem ou de destino igual a zeros leva a erro.
- **Valor ausente:** o valor vazio ou só com espaços leva a erro. A mensagem fala em "numérico", mas o teste é de tamanho zero ou de espaços, portanto é obrigatoriedade.
- **Valor numérico <= 0:** leva à mensagem "positive amount". Como o teste NUMERIC aceita só dígitos, na prática só o zero chega a esse ponto.
- **Sinal de menos:** qualquer sinal de menos no valor leva à mensagem de valor positivo.
- **Casas decimais:** mais de duas casas decimais levam a erro.
- **Valor zero:** se o valor convertido é zero, vem a mensagem "non-zero amount".
- **Retorno de XFRFUN:** o código '1' (conta de origem não encontrada), '2' (conta de destino não encontrada) e '4' (valor não maior que zero) levam a mensagens específicas e a transferência não é aplicada. O sucesso 'Y' leva à confirmação e à exibição dos saldos.
- **Sobre o código '3':** não há GO TO nesse ramo, então o fluxo continua e a mensagem de "erro inesperado" é sobrescrita pela de "não foi possível determinar o sucesso". É um comportamento ambíguo, mas técnico, e por isso fica fora das regras.
- **Limitação:** este programa não verifica saldo suficiente nem limites. Isso depende do XFRFUN, cujo código não foi fornecido.

## Regras de negócio

1. Regra: A transferência só é solicitada quando todos os dados informados (contas e valor) passaram nas validações.
   Condição: Os dados informados são válidos (VALID-DATA).
   Consequência: O programa aciona a rotina de transferência (XFRFUN) com as contas e o valor informados. Se algum dado for inválido, a rotina não é acionada e apenas a mensagem de erro é exibida.
   Parágrafo: PROCESS-MAP

2. Regra: A conta de origem e a conta de destino devem ser diferentes.
   Condição: O número da conta de origem é igual ao da conta de destino (FACCNOI = TACCNOI).
   Consequência: A transferência é recusada com a mensagem "The FROM & TO account should be different".
   Parágrafo: EDIT-DATA

3. Regra: O número de conta 00000000 não é aceito, seja na origem ou no destino.
   Condição: A conta de origem ou a conta de destino é igual a '00000000'.
   Consequência: A transferência é recusada com a mensagem "Account no 00000000 is not valid".
   Parágrafo: EDIT-DATA

4. Regra: O valor da transferência é obrigatório (campo não pode ficar vazio).
   Condição: O campo de valor veio com tamanho zero (AMTL = ZERO).
   Consequência: A transferência é recusada com a mensagem "The Amount entered must be numeric." O texto fala em "numérico", mas o teste é de campo vazio.
   Parágrafo: VALIDATE-AMOUNT

5. Regra: O valor da transferência é obrigatório (campo não pode conter só espaços).
   Condição: O campo de valor tem comprimento maior que zero, mas contém apenas espaços (contagem de espaços iniciais igual ao tamanho do campo).
   Consequência: A transferência é recusada com a mensagem "The Amount entered must be numeric." O texto fala em "numérico", mas o teste é de campo só com espaços.
   Parágrafo: VALIDATE-AMOUNT

6. Regra: O valor numérico informado deve ser positivo.
   Condição: O valor é composto só por dígitos e, depois de convertido, é menor ou igual a zero (WS-AMOUNT-AS-FLOAT <= 0). Como só dígitos passam nesse teste, na prática só o valor zero chega a esse ponto.
   Consequência: A transferência é recusada com a mensagem "Please supply a positive amount."
   Parágrafo: VALIDATE-AMOUNT

7. Regra: Valores negativos não são aceitos.
   Condição: O valor informado contém um sinal de menos (WS-NUM-COUNT-MINUS > 0).
   Consequência: A transferência é recusada com a mensagem "Please supply a positive amount."
   Parágrafo: VALIDATE-AMOUNT

8. Regra: O valor da transferência aceita no máximo duas casas decimais.
   Condição: O valor tem um ponto decimal e mais de dois dígitos depois dele (verificado em duas contagens sucessivas, WS-NUM-COUNT-TOTAL > 2). A lógica de recontagem é pouco clara, mas a consequência final é única.
   Consequência: A transferência é recusada com a mensagem "Only up to two decimal places are supported."
   Parágrafo: VALIDATE-AMOUNT

9. Regra: O valor da transferência não pode ser zero.
   Condição: O valor informado, depois de convertido, é igual a zero (WS-AMOUNT-AS-FLOAT = ZERO).
   Consequência: A transferência é recusada com a mensagem "Please supply a non-zero amount."
   Parágrafo: VALIDATE-AMOUNT

10. Regra: A transferência não é aplicada quando a conta de origem não existe.
    Condição: A rotina de transferência retorna falha com código '1' (SUBPGM-FAIL-CODE = '1').
    Consequência: Exibe a mensagem "Sorry the FROM ACCOUNT no was not found. Transfer not applied." e não confirma a transferência.
    Parágrafo: GET-ACC-DATA

11. Regra: A transferência não é aplicada quando a conta de destino não existe.
    Condição: A rotina de transferência retorna falha com código '2' (SUBPGM-FAIL-CODE = '2').
    Consequência: Exibe a mensagem "Sorry the TO ACCOUNT no was not found. Transfer not applied." e não confirma a transferência.
    Parágrafo: GET-ACC-DATA

12. Regra: A transferência não é aplicada quando o valor não é maior que zero na verificação da rotina de transferência.
    Condição: A rotina de transferência retorna falha com código '4' (SUBPGM-FAIL-CODE = '4').
    Consequência: Exibe a mensagem "Please supply an amount greater than zero." e não confirma a transferência.
    Parágrafo: GET-ACC-DATA

13. Regra: Quando a transferência é aplicada com sucesso, o programa confirma a operação e mostra os saldos atualizados das duas contas.
    Condição: A rotina de transferência retorna sucesso (SUBPGM-SUCCESS = 'Y').
    Consequência: Exibe a mensagem "Transfer successfully applied." e mostra as contas, os códigos de agência (sort code) e os saldos real e disponível da conta de origem e da conta de destino.
    Parágrafo: GET-ACC-DATA