## Análise

**1. Parágrafos e fluxo principal**

O programa BNK1CRA é uma transação CICS de tela, a "Creditar/Debitar conta". O fluxo é este:

- **PREMIERE (A010):** decide pela tecla ou pela primeira chamada. Com ENTER, chama PROCESS-MAP. Ao final, devolve o controle à transação OCRA.
- **PROCESS-MAP:** chama RECEIVE-MAP, depois EDIT-DATA. Se os dados forem válidos, chama UPD-CRED-DATA. Por fim, envia a tela com SEND-MAP.
- **RECEIVE-MAP:** recebe a tela.
- **EDIT-DATA:** valida conta e sinal, e chama VALIDATE-AMOUNT.
- **VALIDATE-AMOUNT:** valida o valor informado.
- **UPD-CRED-DATA:** monta os parâmetros, chama o subprograma DBCRFUN e trata o retorno.
- **SEND-MAP, SEND-TERMINATION-MSG, ABEND-THIS-TASK, POPULATE-TIME-DATE:** apoio técnico.

**2 e 3. Estruturas de decisão e classificação**

| Seção | Decisão | Classificação |
|---|---|---|
| A010 | EVALUATE (primeira chamada, PA1-3, PF3, PF12, CLEAR, ENTER, tecla inválida) | Interface |
| A010 | IF EIBCALEN NOT = ZERO (cópia da área de comunicação) | Infraestrutura |
| A010, RECEIVE-MAP, UPD-CRED-DATA (LINK), SEND-MAP, SEND-TERMINATION-MSG | Testes de WS-CICS-RESP NOT = NORMAL | Infraestrutura |
| SEND-MAP | IF SEND-ERASE, SEND-DATAONLY, SEND-DATAONLY-ALARM | Interface |
| PROCESS-MAP | IF VALID-DATA | Negócio |
| EDIT-DATA | ACCNOI NOT NUMERIC | Formato (não listar) |
| EDIT-DATA | ACCNOI = ZERO | Negócio |
| EDIT-DATA | SIGNI diferente de + e de - | Negócio |
| VALIDATE-AMOUNT | AMTL = ZERO | Negócio (obrigatoriedade) |
| VALIDATE-AMOUNT | AMTI IS NUMERIC | Formato (não listar) |
| VALIDATE-AMOUNT | Campo só com espaços | Negócio (obrigatoriedade) |
| VALIDATE-AMOUNT | Espaços embutidos, caracteres não numéricos, mais de um ponto decimal | Formato (não listar) |
| VALIDATE-AMOUNT | Mais de duas casas decimais | Negócio |
| VALIDATE-AMOUNT | Valor igual a zero | Negócio |
| UPD-CRED-DATA | IF SIGNI = '-' | Negócio |
| UPD-CRED-DATA | IF SUBPGM-SUCCESS = 'N' com EVALUATE de SUBPGM-FAIL-CODE | Negócio nos códigos '1' e '3' |
| UPD-CRED-DATA | Fail code '2' e WHEN OTHER (erro inesperado) | Infraestrutura (não listar) |
| UPD-CRED-DATA | ELSE (sucesso) | Negócio |

**4. Condição e consequência das estruturas de negócio**

- **VALID-DATA:** com a validação aprovada, a atualização da conta é executada. Caso contrário, ela é pulada.
- **Conta igual a zero:** a mensagem de conta diferente de zero é exibida e o processamento é interrompido.
- **Sinal inválido:** se o sinal foi informado e não é + nem -, a mensagem é exibida e a validação é interrompida.
- **Valor ausente ou só com espaços:** a mensagem é exibida e o valor é rejeitado.
- **Mais de duas casas decimais:** o valor é rejeitado.
- **Valor igual a zero:** o valor é rejeitado.
- **Sinal '-':** o valor enviado ao subprograma fica negativo.
- **Fail code '1':** a conta não foi encontrada para a agência, o valor não é aplicado e a mensagem é exibida.
- **Fail code '3':** há saldo insuficiente, o valor não é aplicado e a mensagem é exibida.
- **Sucesso:** a mensagem de sucesso é exibida, junto com conta, agência e saldos.

## Regras de negócio

1. Regra: Não é permitido operar com o número de conta igual a zero (ACCNOI = ZERO).
   Condição: O número da conta informado é zero.
   Consequência: O sistema exibe "Please enter a non zero account number", considera os dados inválidos e interrompe a validação, sem aplicar o valor.
   Parágrafo: EDIT-DATA

2. Regra: Quando o sinal é informado, ele só pode ser "+" ou "-" (SIGNI).
   Condição: O campo de sinal foi preenchido (SIGNL = 1) com um caractere diferente de "+" e "-".
   Consequência: O sistema exibe "Please enter + or - preceding the amount", considera os dados inválidos e interrompe a validação. Se o sinal ficar vazio, o código não rejeita; o valor segue como positivo (crédito), pois só o sinal "-" o torna negativo.
   Parágrafo: EDIT-DATA

3. Regra: O valor da operação é de preenchimento obrigatório (teste de tamanho zero, AMTL = ZERO).
   Condição: O campo de valor foi enviado vazio (tamanho zero).
   Consequência: O sistema exibe "The Amount entered must be numeric" (a mensagem fala em numérico, mas o teste é de campo vazio), considera os dados inválidos e rejeita o valor.
   Parágrafo: VALIDATE-AMOUNT

4. Regra: O valor da operação não pode ser composto apenas de espaços em branco.
   Condição: O campo de valor tem tamanho maior que zero, mas só contém espaços (a contagem de espaços à esquerda é igual ao tamanho do campo).
   Consequência: O sistema exibe "The Amount entered must be numeric" (a mensagem fala em numérico, mas o teste é de campo só com espaços), considera os dados inválidos e rejeita o valor.
   Parágrafo: VALIDATE-AMOUNT

5. Regra: O valor da operação aceita no máximo duas casas decimais.
   Condição: O valor tem um ponto decimal e mais de dois dígitos após ele.
   Consequência: O sistema exibe "Only up to two decimal places are supported", considera os dados inválidos e rejeita o valor. A lógica de contagem do código é complexa e a conferência ocorre em duas etapas sucessivas; o resultado de negócio é a rejeição de valores com mais de duas casas decimais.
   Parágrafo: VALIDATE-AMOUNT

6. Regra: O valor da operação não pode ser zero.
   Condição: O valor informado, com ponto decimal ou outras formas não puramente numéricas, resulta em zero após a conversão (WS-AMOUNT-AS-FLOAT = ZERO).
   Consequência: O sistema exibe "Please supply a non-zero amount", considera os dados inválidos e rejeita o valor. Ambiguidade: um valor só com dígitos (por exemplo "0" ou "000") é aceito logo no primeiro teste e não passa por esta verificação, então o código, na prática, não impede valor zero nesse caso.
   Parágrafo: VALIDATE-AMOUNT

7. Regra: A atualização da conta só é executada se todas as validações da tela foram aprovadas (VALID-DATA).
   Condição: Os dados informados passaram pela validação de conta, sinal e valor.
   Consequência: O sistema chama a rotina de crédito/débito da conta (DBCRFUN). Se a validação falhou, o valor não é aplicado e apenas a mensagem de erro é exibida.
   Parágrafo: PROCESS-MAP

8. Regra: O sinal "-" transforma a operação em débito.
   Condição: O sinal informado é "-" (SIGNI = '-').
   Consequência: O valor é enviado à rotina de atualização como negativo (débito). Nos demais casos ("+" ou sinal vazio), o valor segue positivo (crédito).
   Parágrafo: UPD-CRED-DATA

9. Regra: Não é possível aplicar o valor a uma conta inexistente na agência.
   Condição: A rotina DBCRFUN retorna falha (SUBPGM-SUCCESS = 'N') com código de falha '1' (conta não encontrada para a agência).
   Consequência: O valor não é aplicado e o sistema exibe a mensagem informando que a conta não foi encontrada para a agência e que o valor não foi aplicado.
   Parágrafo: UPD-CRED-DATA

10. Regra: Não é possível aplicar o valor quando não há saldo suficiente.
    Condição: A rotina DBCRFUN retorna falha (SUBPGM-SUCCESS = 'N') com código de falha '3' (fundos insuficientes). A verificação do saldo é feita no subprograma; este programa apenas reage ao código recebido.
    Consequência: O valor não é aplicado e o sistema exibe "Sorry insufficient funds available to process the request".
    Parágrafo: UPD-CRED-DATA

11. Regra: Quando a operação é aceita, o valor é aplicado à conta e o cliente vê os novos saldos.
    Condição: A rotina DBCRFUN retorna sucesso (SUBPGM-SUCCESS diferente de 'N').
    Consequência: O sistema exibe "Amount successfully applied to the account" e mostra na tela a conta, a agência (sort code), o saldo atual e o saldo disponível.
    Parágrafo: UPD-CRED-DATA