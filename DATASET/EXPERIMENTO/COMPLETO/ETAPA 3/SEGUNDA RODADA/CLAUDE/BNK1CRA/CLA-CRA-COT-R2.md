## Análise

**1. Parágrafos e fluxo principal**

BNK1CRA é uma transação CICS de tela que aplica um crédito ou débito a uma conta. O fluxo é:

- **PREMIERE (A010):** decide o que fazer conforme a tecla pressionada. Em ENTER, chama PROCESS-MAP. No fim, devolve o controle ao CICS com a transação OCRA.
- **PROCESS-MAP (PM010):** chama RECEIVE-MAP e EDIT-DATA. Se os dados forem válidos, chama UPD-CRED-DATA. Depois envia a tela com alarme (SEND-MAP).
- **RECEIVE-MAP (RM010):** recebe a tela.
- **EDIT-DATA (ED010):** valida conta e sinal, e chama VALIDATE-AMOUNT.
- **VALIDATE-AMOUNT (VA010):** valida o valor informado.
- **UPD-CRED-DATA (UCD010):** monta os parâmetros, aplica o sinal ao valor, chama o subprograma DBCRFUN e trata o resultado.
- **SEND-MAP (SM010), SEND-TERMINATION-MSG (STM010), ABEND-THIS-TASK (ATT010), POPULATE-TIME-DATE (PTD010):** apoio técnico e de interface.

**2. Estruturas de decisão e 3. Classificação**

| Local | Estrutura | Classificação |
|---|---|---|
| A010 | EVALUATE de EIBCALEN, PA1/2/3, PF3, PF12, CLEAR, ENTER, OTHER | Interface |
| A010 | IF EIBCALEN NOT = ZERO (cópia da área de comunicação) | Infraestrutura |
| A010, RM010, UCD010, SM010, STM010 | IF RESP NOT = NORMAL (abend) | Infraestrutura |
| PM010 | IF VALID-DATA | Negócio |
| SM010 | IF SEND-ERASE / SEND-DATAONLY / SEND-DATAONLY-ALARM | Interface |
| ED010 | IF ACCNOI NOT NUMERIC | Formato (não listar). A mensagem pede o número da conta, mas o teste é de valor numérico. |
| ED010 | IF ACCNOI = ZERO | Negócio |
| ED010 | IF SIGNI diferente de '+' e '-' e SIGNL = 1 | Negócio (lista de valores aceitos) |
| VA010 | IF AMTL = ZERO | Negócio (obrigatoriedade). A mensagem diz "numeric", mas o teste é de tamanho zero. |
| VA010 | IF AMTI(1:AMTL) IS NUMERIC | Formato. Se passa, o valor é aceito sem outros testes. |
| VA010 | IF contagem de espaços iniciais = AMTL | Negócio (campo só com espaços) |
| VA010 | IF NUM-COUNT-TOTAL = ZERO (ajuste de espaços iniciais) | Técnico |
| VA010 | IF espaços embutidos > 0 | Formato |
| VA010 | IF caracteres válidos < tamanho | Formato |
| VA010 | IF pontos decimais > 1 | Formato |
| VA010 | IF casas decimais > 2 | Negócio (restrição sobre o valor) |
| VA010 | IF valor = ZERO | Negócio |
| UCD010 | IF SIGNI = '-' | Negócio |
| UCD010 | IF SUBPGM-SUCCESS = 'N' / ELSE | Negócio |
| UCD010 | EVALUATE SUBPGM-FAIL-CODE: '1', '2', '3', OTHER | '1' e '3' são negócio. '2' e OTHER são erro inesperado, tratado como técnico. |

**4. Condição e consequência das estruturas de negócio**

- **Dados válidos (PM010):** se VALID-DATA, o lançamento é enviado a DBCRFUN. Caso contrário, só a mensagem de erro é exibida.
- **Conta igual a zero:** mensagem de conta diferente de zero e lançamento não realizado.
- **Sinal informado fora de + e -:** mensagem pedindo + ou -.
- **Valor ausente ou só com espaços:** mensagem de valor obrigatório.
- **Mais de duas casas decimais:** mensagem de limite de duas casas.
- **Valor igual a zero:** mensagem pedindo valor diferente de zero.
- **Sinal '-':** o valor é multiplicado por -1.
- **Falha código '1':** conta não encontrada para a agência.
- **Falha código '3':** saldo insuficiente.
- **Sucesso:** mensagem de êxito e exibição de conta, agência e saldos.

**Pontos ambíguos**

- O teste de valor zero só ocorre quando o valor não é puramente numérico, por exemplo "0.00". Um valor "0" passa pelo teste NUMERIC e vai direto para a aplicação, sem checagem de zero.
- Se o sinal não for informado (SIGNL diferente de 1), nenhum erro é gerado. O valor não é negado, então é tratado como positivo.
- O teste de casas decimais é um pouco confuso no código. Considerei que a intenção é aceitar no máximo duas casas.

## Regras de negócio

1. Regra: O número da conta informado não pode ser zero.
   Condição: O número da conta é zero (ACCNOI = ZERO), depois de aprovado no teste de formato numérico.
   Consequência: Exibe a mensagem pedindo um número de conta diferente de zero, marca os dados como inválidos e o lançamento não é realizado.
   Parágrafo: EDIT-DATA (ED010)

2. Regra: Se o sinal do valor for informado, só são aceitos "+" ou "-".
   Condição: O campo de sinal foi preenchido (SIGNL = 1) com um caractere diferente de "+" e de "-".
   Consequência: Exibe a mensagem pedindo "+" ou "-" antes do valor, marca os dados como inválidos e o lançamento não é realizado. Se o sinal não for informado, o código não rejeita.
   Parágrafo: EDIT-DATA (ED010)

3. Regra: O valor do lançamento é obrigatório (campo vazio).
   Condição: O tamanho do valor digitado é zero (AMTL = ZERO).
   Consequência: Exibe a mensagem de que o valor deve ser numérico (a mensagem fala em "numérico", mas o teste é de ausência) e marca os dados como inválidos.
   Parágrafo: VALIDATE-AMOUNT (VA010)

4. Regra: O valor do lançamento é obrigatório (campo só com espaços).
   Condição: O valor digitado contém apenas espaços (quantidade de espaços iniciais igual ao tamanho do campo).
   Consequência: Exibe a mensagem de que o valor deve ser numérico e marca os dados como inválidos.
   Parágrafo: VALIDATE-AMOUNT (VA010)

5. Regra: O valor do lançamento aceita no máximo duas casas decimais.
   Condição: O valor tem ponto decimal e mais de duas casas decimais (contagem de dígitos após o ponto maior que 2). A lógica de contagem é confusa, então a leitura é aproximada.
   Consequência: Exibe a mensagem de que só são suportadas até duas casas decimais e marca os dados como inválidos.
   Parágrafo: VALIDATE-AMOUNT (VA010)

6. Regra: O valor do lançamento não pode ser zero.
   Condição: O valor convertido é zero (WS-AMOUNT-AS-FLOAT = ZERO). Esse teste só é alcançado por valores que não passam no teste numérico inicial, como "0.00". Um valor "0" é aceito sem essa checagem, o que é ambíguo.
   Consequência: Exibe a mensagem pedindo um valor diferente de zero e marca os dados como inválidos.
   Parágrafo: VALIDATE-AMOUNT (VA010)

7. Regra: O lançamento só é enviado para processamento se os dados informados forem válidos.
   Condição: Os dados passaram em todas as validações (VALID-DATA).
   Consequência: A aplicação do valor na conta é solicitada ao subprograma DBCRFUN. Se os dados forem inválidos, nada é aplicado e só a mensagem de erro é exibida.
   Parágrafo: PROCESS-MAP (PM010)

8. Regra: Valor informado com sinal "-" é aplicado com o sinal invertido.
   Condição: O sinal informado é "-" (SIGNI = '-').
   Consequência: O valor é multiplicado por -1 antes de ser enviado ao processamento da conta. Com "+" ou sem sinal, o valor segue positivo.
   Parágrafo: UPD-CRED-DATA (UCD010)

9. Regra: Lançamento em conta inexistente na agência não é aplicado.
   Condição: O processamento retorna falha com código '1' (SUBPGM-SUCCESS = 'N' e SUBPGM-FAIL-CODE = '1').
   Consequência: Exibe a mensagem de que a conta não foi encontrada para a agência (sort code) e que o valor não foi aplicado.
   Parágrafo: UPD-CRED-DATA (UCD010)

10. Regra: Lançamento sem saldo suficiente não é aplicado.
    Condição: O processamento retorna falha com código '3' (SUBPGM-SUCCESS = 'N' e SUBPGM-FAIL-CODE = '3').
    Consequência: Exibe a mensagem de fundos insuficientes para processar a solicitação. O saldo não é exibido.
    Parágrafo: UPD-CRED-DATA (UCD010)

11. Regra: Lançamento aplicado com sucesso informa o resultado e os saldos da conta.
    Condição: O processamento não retorna falha (SUBPGM-SUCCESS diferente de 'N').
    Consequência: Exibe a mensagem de que o valor foi aplicado à conta, junto com o número da conta, a agência, o saldo atual e o saldo disponível.
    Parágrafo: UPD-CRED-DATA (UCD010)