# Análise

**1. Parágrafos e fluxo principal**

O programa BNK1CRA é uma transação de tela (CICS) que aplica um crédito ou débito a uma conta.

- **PREMIERE (A010):** decide o que fazer conforme a tecla pressionada. Na primeira chamada exibe a tela. No ENTER chama PROCESS-MAP. No fim, retorna à própria transação (OCRA).
- **PROCESS-MAP (PM010):** executa RECEIVE-MAP, depois EDIT-DATA. Se os dados forem válidos, executa UPD-CRED-DATA. Por fim, envia a tela com o resultado.
- **RECEIVE-MAP (RM010):** recebe os dados digitados.
- **EDIT-DATA (ED010):** valida conta e sinal e chama VALIDATE-AMOUNT.
- **VALIDATE-AMOUNT (VA010):** valida o valor digitado e o converte para número.
- **UPD-CRED-DATA (UCD010):** monta os parâmetros, aplica o sinal ao valor, chama o subprograma DBCRFUN e trata o retorno.
- **SEND-MAP, SEND-TERMINATION-MSG, ABEND-THIS-TASK, POPULATE-TIME-DATE:** apoio técnico e de tela.

**2 e 3. Estruturas de decisão e classificação**

| Parágrafo | Decisão | Classe |
|---|---|---|
| A010 | EVALUATE do EIBAID e EIBCALEN (primeira chamada, PA1-3, PF3, PF12, CLEAR, ENTER, tecla inválida) | Interface |
| A010 | IF EIBCALEN NOT = ZERO, que copia a área de comunicação | Infraestrutura |
| A010, RM010, UCD010 (LINK), SEND-MAP, STM010 | IF WS-CICS-RESP NOT = NORMAL, que registra o abend e aborta | Infraestrutura |
| SEND-MAP | IF SEND-ERASE, SEND-DATAONLY e SEND-DATAONLY-ALARM | Interface |
| PM010 | IF VALID-DATA | Negócio |
| ED010 | IF ACCNOI NOT NUMERIC | Formato (excluída) |
| ED010 | IF ACCNOI = ZERO | Negócio |
| ED010 | IF SIGNI diferente de '+' e '-' e SIGNL = 1 | Negócio |
| VA010 | IF AMTL = ZERO | Negócio (obrigatoriedade) |
| VA010 | IF AMTI(1:AMTL) IS NUMERIC | Formato (excluída) |
| VA010 | IF contagem de espaços iniciais = AMTL | Negócio (obrigatoriedade) |
| VA010 | IF ZERO de espaços iniciais, que só escolhe como copiar o texto | Técnico (excluída) |
| VA010 | IF espaços embutidos > 0 | Formato (excluída) |
| VA010 | IF contagem de dígitos e ponto < tamanho | Formato (excluída) |
| VA010 | IF mais de um ponto decimal | Formato (excluída) |
| VA010 | IF um ponto e mais de 2 casas decimais (decisões aninhadas) | Negócio |
| VA010 | IF valor convertido = ZERO | Negócio |
| UCD010 | IF SIGNI = '-' | Negócio |
| UCD010 | IF SUBPGM-SUCCESS = 'N', que só leva ao EVALUATE | Intermediária (não listada) |
| UCD010 | EVALUATE SUBPGM-FAIL-CODE: '1' conta não encontrada, '3' saldo insuficiente | Negócio |
| UCD010 | EVALUATE SUBPGM-FAIL-CODE: '2' e OTHER, erros inesperados | Infraestrutura (excluídas) |
| UCD010 | ELSE do SUCCESS, sucesso na aplicação | Negócio |

**4. Condição e consequência das estruturas de negócio**

- **PM010:** se os dados são válidos, o crédito ou débito é aplicado; caso contrário, apenas a mensagem de erro é exibida.
- **Conta igual a zero:** rejeita e pede conta diferente de zero.
- **Sinal:** se um sinal é informado e não é "+" nem "-", rejeita. Se o sinal vier vazio, o programa não rejeita, e ele é tratado como crédito.
- **Valor ausente ou só com espaços:** rejeita.
- **Mais de 2 casas decimais:** rejeita.
- **Valor zero:** rejeita. Esse teste só é alcançado quando o texto não é puramente numérico, por exemplo "0.00". Um "0" inteiro passa direto como válido.
- **Sinal "-":** o valor é invertido e tratado como débito.
- **Códigos de falha '1' e '3':** a operação é recusada com mensagem específica.
- **Sucesso:** confirma a aplicação e exibe conta, agência e saldos.

# Regras de negócio

1. Regra: O crédito ou débito só é aplicado à conta quando todas as validações dos dados informados (conta, sinal e valor) foram aprovadas (VALID-DATA).
   Condição: Os dados informados passaram em todas as validações.
   Consequência: O valor é enviado ao processamento de crédito/débito (DBCRFUN); caso contrário, o valor não é aplicado e apenas a mensagem de erro é exibida.
   Parágrafo: PROCESS-MAP

2. Regra: O número da conta informado não pode ser zero.
   Condição: O número da conta (ACCNOI) é igual a zero.
   Consequência: Rejeita a operação, com a mensagem "Please enter a non zero account number" (VALID-DATA-SW = 'N').
   Parágrafo: EDIT-DATA

3. Regra: Quando um sinal é informado, ele deve ser "+" ou "-".
   Condição: O campo de sinal foi preenchido (SIGNL = 1) com valor diferente de "+" e "-". Se o sinal for deixado em branco, a regra não rejeita (ambíguo: o código aceita, e o valor segue como crédito).
   Consequência: Rejeita a operação, com a mensagem "Please enter + or - preceding the amount".
   Parágrafo: EDIT-DATA

4. Regra: O valor da operação é obrigatório.
   Condição: O campo de valor chega com tamanho zero (AMTL = ZERO).
   Consequência: Rejeita a operação, com a mensagem "The Amount entered must be numeric" (a mensagem fala em valor numérico, mas o teste é de campo vazio).
   Parágrafo: VALIDATE-AMOUNT

5. Regra: O valor da operação não pode ser composto apenas de espaços em branco.
   Condição: Todos os caracteres do valor informado são espaços (contagem de espaços iniciais = AMTL).
   Consequência: Rejeita a operação, com a mensagem "The Amount entered must be numeric".
   Parágrafo: VALIDATE-AMOUNT

6. Regra: O valor da operação aceita no máximo duas casas decimais.
   Condição: O valor contém um ponto decimal e mais de dois dígitos após o ponto (o teste é feito em duas etapas aninhadas, com contagem de caracteres e de dígitos após o ponto).
   Consequência: Rejeita a operação, com a mensagem "Only up to two decimal places are supported".
   Parágrafo: VALIDATE-AMOUNT

7. Regra: O valor da operação não pode ser zero.
   Condição: O valor convertido para número é igual a zero. Ambíguo: este teste só é alcançado quando o texto digitado não é puramente numérico (por exemplo, "0.00"). Um valor inteiro como "0" é considerado numérico e é aceito sem passar por esta verificação.
   Consequência: Rejeita a operação, com a mensagem "Please supply a non-zero amount".
   Parágrafo: VALIDATE-AMOUNT

8. Regra: Um valor com sinal "-" é tratado como débito na conta.
   Condição: O sinal informado é "-" (SIGNI = '-').
   Consequência: O valor é multiplicado por -1 antes de ser enviado ao processamento (valor negativo, ou seja, débito). Com qualquer outro sinal ou sem sinal, o valor segue positivo (crédito).
   Parágrafo: UCD010 (UPD-CRED-DATA)

9. Regra: A operação é recusada quando a conta não é encontrada para a agência.
   Condição: O processamento do crédito/débito retorna falha com código '1' (SUBPGM-SUCCESS = 'N' e SUBPGM-FAIL-CODE = '1').
   Consequência: Informa que a conta não foi encontrada para a agência (SORTCODE) e que o valor não foi aplicado.
   Parágrafo: UCD010 (UPD-CRED-DATA)

10. Regra: A operação é recusada quando não há saldo suficiente.
    Condição: O processamento do crédito/débito retorna falha com código '3' (SUBPGM-SUCCESS = 'N' e SUBPGM-FAIL-CODE = '3').
    Consequência: Informa "insufficient funds available to process the request" e o valor não é aplicado.
    Parágrafo: UCD010 (UPD-CRED-DATA)

11. Regra: Quando o crédito/débito é aplicado com sucesso, a tela confirma a operação e mostra os dados atualizados da conta.
    Condição: O processamento do crédito/débito não retorna falha (SUBPGM-SUCCESS diferente de 'N').
    Consequência: Exibe "Amount successfully applied to the account" junto com o número da conta, a agência, o saldo atual e o saldo disponível.
    Parágrafo: UCD010 (UPD-CRED-DATA)