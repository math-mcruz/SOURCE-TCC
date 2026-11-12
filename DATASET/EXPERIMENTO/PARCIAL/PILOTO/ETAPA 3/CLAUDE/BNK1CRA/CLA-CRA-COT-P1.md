# Análise

**1. Parágrafos e fluxo principal**

Programa CICS de tela (BNK1CRA, transação OCRA) para creditar ou debitar um valor em uma conta.

- **PREMIERE (A010):** decide o que fazer conforme a tecla pressionada.
  - Na primeira chamada, envia a tela vazia.
  - Em ENTER, executa PROCESS-MAP.
  - Em PF3, PF12 ou CLEAR, encerra ou volta ao menu.
  - Ao final, devolve o controle com a COMMAREA.
- **PROCESS-MAP (PM010):** executa RECEIVE-MAP, depois EDIT-DATA. Se os dados forem válidos, executa UPD-CRED-DATA. Em seguida envia a tela com alarme (SEND-MAP).
- **RECEIVE-MAP (RM010):** recebe a tela.
- **EDIT-DATA (ED010):** valida conta e sinal e chama VALIDATE-AMOUNT.
- **VALIDATE-AMOUNT (VA010):** valida e converte o valor digitado.
- **UPD-CRED-DATA (UCD010):** chama o subprograma DBCRFUN, que aplica o valor, e monta a mensagem de resultado e os saldos.
- **SEND-MAP (SM010), SEND-TERMINATION-MSG (STM010), ABEND-THIS-TASK (ATT010), POPULATE-TIME-DATE (PTD010):** rotinas de apoio (envio de tela, mensagem de fim de sessão, abend e data/hora).

**2 e 3. Estruturas de decisão e classificação**

| Parágrafo | Decisão | Classificação |
|---|---|---|
| A010 | EVALUATE de EIBCALEN e EIBAID (primeira chamada, PA1-3, PF3, PF12, CLEAR, ENTER, outra tecla) | Interface |
| A010 | IF EIBCALEN NOT = ZERO (copia a COMMAREA) | Interface |
| A010, RM010, UCD010, SM010, STM010 | IF WS-CICS-RESP NOT = NORMAL (abend) | Infraestrutura |
| SM010 | IF SEND-ERASE, SEND-DATAONLY, SEND-DATAONLY-ALARM | Interface |
| PM010 | IF VALID-DATA | Negócio |
| ED010 | IF ACCNOI NOT NUMERIC | Infraestrutura (formato do campo) |
| ED010 | IF ACCNOI = ZERO | Negócio |
| ED010 | IF SIGNI diferente de '+' e '-' com SIGNL = 1 | Negócio (lista de valores aceitos) |
| VA010 | IF AMTL = ZERO | Negócio (obrigatoriedade) |
| VA010 | IF AMTI NUMERIC (aceita e converte) | Infraestrutura (formato; ver ambiguidade abaixo) |
| VA010 | IF contagem de espaços iniciais = AMTL (só espaços) | Negócio (obrigatoriedade) |
| VA010 | IF espaços embutidos, caracteres não numéricos, mais de um ponto | Infraestrutura (formato) |
| VA010 | IF NUM-COUNT-POINT = 1, depois IF casas decimais > 2 (aninhados) | Negócio (restrição ao valor) |
| VA010 | IF WS-AMOUNT-AS-FLOAT = ZERO | Negócio |
| UCD010 | IF SIGNI = '-' | Negócio |
| UCD010 | IF SUBPGM-SUCCESS = 'N' | Intermediário, leva ao EVALUATE |
| UCD010 | EVALUATE SUBPGM-FAIL-CODE '1' (conta não encontrada) e '3' (saldo insuficiente) | Negócio |
| UCD010 | EVALUATE SUBPGM-FAIL-CODE '2' e OTHER (erro inesperado) | Infraestrutura |
| UCD010 | ELSE (sucesso) | Negócio |

**4. Condição e consequência das estruturas de negócio**

- **PM010:** se todas as validações passaram, o valor é enviado ao subprograma de crédito e débito. Caso contrário, nada é aplicado.
- **ED010, conta zero:** conta igual a zero gera mensagem de rejeição e interrompe as validações.
- **ED010, sinal:** sinal informado diferente de '+' e '-' gera mensagem de rejeição. Se o sinal ficar em branco, não há erro.
- **VA010, valor vazio:** valor com tamanho zero ou só espaços gera mensagem e rejeição.
- **VA010, casas decimais:** valor com mais de duas casas decimais gera mensagem e rejeição.
- **VA010, valor zero:** valor que resulta em zero gera mensagem e rejeição.
- **UCD010, sinal '-':** o valor é enviado como negativo (débito).
- **UCD010, código '1':** o subprograma informa conta não encontrada. A mensagem diz que o valor não foi aplicado.
- **UCD010, código '3':** o subprograma informa saldo insuficiente. A mensagem diz que o pedido não foi processado.
- **UCD010, sucesso:** exibe mensagem de confirmação, a conta, o sort code e os saldos real e disponível.

**Ambiguidades**

- Se o valor digitado for totalmente numérico (por exemplo, "0"), o código o aceita e sai de VALIDATE-AMOUNT sem testar valor zero. Só os valores que passam pelo caminho de conversão (com ponto decimal ou espaços à esquerda) sofrem o teste de valor zero.
- O programa não calcula saldo nem verifica fundos. O teste de saldo insuficiente e de conta existente ocorre no subprograma DBCRFUN, que não foi fornecido. Aqui só se vê a reação ao código de retorno.

# Regras de negócio

1. Regra: Só se aplica o crédito ou débito à conta quando todas as validações dos dados digitados foram aprovadas.
   Condição: Dados válidos após a edição (VALID-DATA).
   Consequência: O valor é enviado ao processamento de crédito e débito da conta (DBCRFUN).
   Parágrafo: PROCESS-MAP (PM010)

2. Regra: O número da conta não pode ser zero.
   Condição: Número da conta informado igual a zero (ACCNOI = ZERO).
   Consequência: A operação é rejeitada com a mensagem "Please enter a non zero account number" e o valor não é aplicado.
   Parágrafo: EDIT-DATA (ED010)

3. Regra: Quando o sinal é informado, só são aceitos "+" ou "-" antes do valor.
   Condição: Sinal informado (SIGNL = 1) diferente de "+" e de "-" (SIGNI). Se o sinal ficar em branco, o código não rejeita.
   Consequência: A operação é rejeitada com a mensagem "Please enter + or - preceding the amount" e o valor não é aplicado.
   Parágrafo: EDIT-DATA (ED010)

4. Regra: O valor da operação é obrigatório (campo não pode ficar vazio).
   Condição: Campo de valor sem nenhum caractere informado (AMTL = ZERO).
   Consequência: A operação é rejeitada com a mensagem "The Amount entered must be numeric" e o valor não é aplicado.
   Parágrafo: VALIDATE-AMOUNT (VA010)

5. Regra: O valor da operação não pode ser composto apenas de espaços.
   Condição: Todos os caracteres do campo de valor são espaços (quantidade de espaços = AMTL).
   Consequência: A operação é rejeitada com a mensagem "The Amount entered must be numeric" e o valor não é aplicado.
   Parágrafo: VALIDATE-AMOUNT (VA010)

6. Regra: O valor da operação aceita no máximo duas casas decimais.
   Condição: Valor com ponto decimal e mais de dois dígitos após o ponto.
   Consequência: A operação é rejeitada com a mensagem "Only up to two decimal places are supported" e o valor não é aplicado. O código faz uma contagem em duas etapas, e o teste interno é pouco claro, mas o resultado final é essa rejeição.
   Parágrafo: VALIDATE-AMOUNT (VA010)

7. Regra: O valor da operação não pode ser zero.
   Condição: Valor convertido igual a zero (WS-AMOUNT-AS-FLOAT = ZERO). O teste só é alcançado quando o valor não é puramente numérico, por exemplo quando tem ponto decimal ou espaços à esquerda. Um valor como "0" digitado sem ponto passa direto sem esse teste (ambíguo).
   Consequência: A operação é rejeitada com a mensagem "Please supply a non-zero amount" e o valor não é aplicado.
   Parágrafo: VALIDATE-AMOUNT (VA010)

8. Regra: Um valor precedido do sinal "-" é tratado como débito (valor negativo).
   Condição: Sinal informado igual a "-" (SIGNI = '-').
   Consequência: O valor é invertido para negativo antes de ser enviado ao processamento da conta. Nos demais casos, inclusive sem sinal, o valor segue positivo (crédito).
   Parágrafo: UPD-CRED-DATA (UCD010)

9. Regra: Se a conta não for encontrada para o sort code, o valor não é aplicado.
   Condição: Processamento retorna falha com código '1' (SUBPGM-SUCCESS = 'N' e SUBPGM-FAIL-CODE = '1'). A busca da conta é feita no subprograma DBCRFUN, não neste programa.
   Consequência: Exibe a mensagem de que a conta não foi encontrada para o sort code e que o valor não foi aplicado.
   Parágrafo: UPD-CRED-DATA (UCD010)

10. Regra: Se não houver saldo suficiente, a operação não é processada.
    Condição: Processamento retorna falha com código '3' (SUBPGM-SUCCESS = 'N' e SUBPGM-FAIL-CODE = '3'). A verificação de saldo é feita no subprograma DBCRFUN, não neste programa.
    Consequência: Exibe a mensagem "Sorry insufficient funds available to process the request" e o valor não é aplicado.
    Parágrafo: UPD-CRED-DATA (UCD010)

11. Regra: Quando a operação é aplicada com sucesso, o cliente é informado e vê os saldos atualizados.
    Condição: Processamento não retorna falha (SUBPGM-SUCCESS diferente de 'N').
    Consequência: Exibe a mensagem "Amount successfully applied to the account", a conta, o sort code e os saldos real e disponível.
    Parágrafo: UPD-CRED-DATA (UCD010)