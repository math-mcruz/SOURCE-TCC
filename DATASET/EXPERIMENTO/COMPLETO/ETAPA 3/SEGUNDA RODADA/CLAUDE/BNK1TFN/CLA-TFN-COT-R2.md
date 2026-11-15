## Análise

**1. Parágrafos e fluxo principal**

- **PREMIERE (A010):** ponto de entrada. Decide o que fazer conforme a tecla pressionada e, no fim, reagenda a transação (RETURN TRANSID 'OTFN').
- **PROCESS-MAP (PM010):** orquestra o ciclo de uma transferência. Recebe a tela, valida os dados, chama a transferência se os dados forem válidos e reenvia a tela.
- **RECEIVE-MAP (RM010):** lê os dados digitados na tela.
- **EDIT-DATA (ED010):** valida conta de origem, conta de destino e a relação entre elas, e depois chama VALIDATE-AMOUNT.
- **VALIDATE-AMOUNT (VA010):** valida o valor digitado.
- **GET-ACC-DATA (GCD010):** chama o subprograma XFRFUN, que executa a transferência, e traduz o resultado em mensagem e saldos na tela.
- **SEND-MAP (SM010), SEND-TERMINATION-MSG (STM010), POPULATE-TIME-DATE (PTD010), ABEND-THIS-TASK (ATT010):** envio de tela, mensagem de fim de sessão, data e hora técnicas e encerramento anormal.

Fluxo principal: A010 → (ENTER) PM010 → RM010 → ED010 → VA010 → (se válido) GCD010 → SM010.

**2 e 3. Estruturas de decisão e classificação**

| Parágrafo | Estrutura | Classificação |
|---|---|---|
| A010 | EVALUATE (EIBCALEN, PA1-3, PF3, PF12, CLEAR, ENTER, outra tecla) | Interface |
| A010 | RESP do RETURN diferente de NORMAL | Infraestrutura |
| PM010 | IF VALID-DATA | Negócio (a transferência só é solicitada se tudo for válido) |
| RM010, SM010, STM010 | RESP diferente de NORMAL; IF SEND-ERASE, SEND-DATAONLY, SEND-DATAONLY-ALARM | Infraestrutura e interface |
| ED010 | FACCNOI e TACCNOI NOT NUMERIC | Formato (não listar), embora a mensagem peça para informar a conta |
| ED010 | FACCNOI = TACCNOI | Negócio |
| ED010 | Conta = '00000000' | Negócio |
| VA010 | AMTL = ZERO | Negócio (obrigatoriedade) |
| VA010 | IS NUMERIC e valor <= 0 | Negócio |
| VA010 | Contagem de espaços iniciais igual a AMTL | Negócio (campo só com espaços, obrigatoriedade) |
| VA010 | Presença de '-' | Negócio (valor negativo) |
| VA010 | Espaços embutidos, caracteres não numéricos, mais de um ponto | Formato (não listar) |
| VA010 | Mais de duas casas decimais | Negócio (restrição de valor) |
| VA010 | Valor = ZERO | Negócio |
| GCD010 | RESP do LINK XFRFUN diferente de NORMAL | Infraestrutura |
| GCD010 | SUBPGM-SUCCESS = 'N' e EVALUATE de SUBPGM-FAIL-CODE ('1', '2', '4') | Negócio |
| GCD010 | FAIL-CODE '3' (erro inesperado) e OTHER (erro genérico) | Infraestrutura (falha técnica) |
| GCD010 | SUBPGM-SUCCESS NOT = 'Y' (não foi possível determinar o sucesso) | Infraestrutura (proteção técnica) |
| GCD010 | SUBPGM-SUCCESS = 'Y' | Negócio |

**4. Condição e consequência das estruturas de negócio**

- **PM010:** se os dados estão válidos, a transferência é solicitada ao XFRFUN.
- **ED010:**
  - Contas de origem e destino iguais: mensagem de erro e dados marcados como inválidos.
  - Qualquer conta igual a 00000000: mensagem de erro e dados inválidos.
- **VA010:**
  - Valor com tamanho zero ou só com espaços: erro de valor obrigatório.
  - Valor numérico menor ou igual a zero: erro de valor positivo.
  - Presença de sinal de menos: erro de valor positivo.
  - Mais de duas casas decimais: erro de casas decimais.
  - Valor igual a zero (caminho com ponto decimal): erro de valor diferente de zero.
- **GCD010:**
  - Código '1': conta de origem não encontrada.
  - Código '2': conta de destino não encontrada.
  - Código '4': valor não maior que zero.
  - Sucesso 'Y': confirmação e saldos atualizados.

Observações de ambiguidade:

- Quando o código de falha é '3', o fluxo continua para o teste seguinte (SUBPGM-SUCCESS NOT = 'Y'), que sobrescreve a mensagem. Por isso a mensagem de "erro inesperado" nunca chega à tela.
- As regras de saldo e de existência de contas ficam no XFRFUN, que não faz parte deste código. O BNK1TFN apenas traduz o resultado.

## Regras de negócio

1. Regra: A transferência só é solicitada quando todas as validações dos dados digitados foram aprovadas (VALID-DATA).
   Condição: As validações de contas e valor terminam sem erro (VALID-DATA-SW = 'Y').
   Consequência: O programa solicita a execução da transferência ao subprograma XFRFUN.
   Parágrafo: PROCESS-MAP (PM010)

2. Regra: A conta de origem e a conta de destino devem ser diferentes.
   Condição: Número da conta de origem igual ao da conta de destino (FACCNOI = TACCNOI).
   Consequência: Exibe "The FROM & TO account should be different", marca os dados como inválidos e a transferência não é solicitada.
   Parágrafo: EDIT-DATA (ED010)

3. Regra: O número de conta 00000000 não é aceito, seja na origem ou no destino.
   Condição: Conta de origem ou conta de destino igual a '00000000'.
   Consequência: Exibe "Account no 00000000 is not valid", marca os dados como inválidos e a transferência não é solicitada.
   Parágrafo: EDIT-DATA (ED010)

4. Regra: O valor da transferência é obrigatório.
   Condição: O campo de valor foi enviado com tamanho zero (AMTL = ZERO).
   Consequência: Exibe "The Amount entered must be numeric.", marca os dados como inválidos e a transferência não é solicitada. A mensagem fala em valor numérico, mas o teste é de ausência de conteúdo.
   Parágrafo: VALIDATE-AMOUNT (VA010)

5. Regra: O valor da transferência não pode ser apenas espaços em branco.
   Condição: Todo o conteúdo do campo de valor é composto de espaços (quantidade de espaços iniciais = AMTL).
   Consequência: Exibe "The Amount entered must be numeric.", marca os dados como inválidos e a transferência não é solicitada.
   Parágrafo: VALIDATE-AMOUNT (VA010)

6. Regra: O valor da transferência deve ser positivo; valor zero ou negativo é recusado.
   Condição: O valor digitado é numérico (sem ponto decimal) e menor ou igual a zero (WS-AMOUNT-AS-FLOAT <= 0).
   Consequência: Exibe "Please supply a positive amount.", marca os dados como inválidos e a transferência não é solicitada.
   Parágrafo: VALIDATE-AMOUNT (VA010)

7. Regra: Valor com sinal de menos é recusado, pois o valor da transferência deve ser positivo.
   Condição: O valor digitado contém o caractere '-' (WS-NUM-COUNT-MINUS > 0). O código detecta apenas o sinal, e não o valor numérico resultante.
   Consequência: Exibe "Please supply a positive amount.", marca os dados como inválidos e a transferência não é solicitada.
   Parágrafo: VALIDATE-AMOUNT (VA010)

8. Regra: O valor da transferência aceita no máximo duas casas decimais.
   Condição: O valor tem um ponto decimal e mais de dois dígitos após ele. O código confirma contando os dígitos após o ponto (WS-NUM-COUNT-TOTAL > 2), e a lógica dessa recontagem é pouco clara.
   Consequência: Exibe "Only up to two decimal places are supported.", marca os dados como inválidos e a transferência não é solicitada.
   Parágrafo: VALIDATE-AMOUNT (VA010)

9. Regra: O valor da transferência não pode ser zero.
   Condição: Após as demais validações, o valor convertido é igual a zero (WS-AMOUNT-AS-FLOAT = ZERO). Esse caminho só é alcançado por valores com ponto decimal, como 0.00.
   Consequência: Exibe "Please supply a non-zero amount.", marca os dados como inválidos e a transferência não é solicitada.
   Parágrafo: VALIDATE-AMOUNT (VA010)

10. Regra: A transferência não é aplicada quando a conta de origem não é encontrada.
    Condição: O subprograma XFRFUN devolve falha (SUBPGM-SUCCESS = 'N') com código de falha '1'.
    Consequência: Exibe "Sorry the FROM ACCOUNT no was not found. Transfer not applied." e os saldos são exibidos zerados.
    Parágrafo: GET-ACC-DATA (GCD010)

11. Regra: A transferência não é aplicada quando a conta de destino não é encontrada.
    Condição: O subprograma XFRFUN devolve falha (SUBPGM-SUCCESS = 'N') com código de falha '2'.
    Consequência: Exibe "Sorry the TO ACCOUNT no was not found. Transfer not applied." e os saldos são exibidos zerados.
    Parágrafo: GET-ACC-DATA (GCD010)

12. Regra: A transferência não é aplicada quando o valor informado não é maior que zero.
    Condição: O subprograma XFRFUN devolve falha (SUBPGM-SUCCESS = 'N') com código de falha '4'.
    Consequência: Exibe "Please supply an amount greater than zero." e os saldos são exibidos zerados.
    Parágrafo: GET-ACC-DATA (GCD010)

13. Regra: Quando a transferência é aplicada com sucesso, o programa confirma a operação e mostra os saldos atualizados das duas contas.
    Condição: O subprograma XFRFUN devolve sucesso (SUBPGM-SUCCESS = 'Y').
    Consequência: Exibe "Transfer successfully applied." junto com as contas, os códigos de agência e os saldos real e disponível da conta de origem e da conta de destino.
    Parágrafo: GET-ACC-DATA (GCD010)