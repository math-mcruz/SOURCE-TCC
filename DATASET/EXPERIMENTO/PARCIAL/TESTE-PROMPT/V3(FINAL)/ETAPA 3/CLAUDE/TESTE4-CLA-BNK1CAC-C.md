## Análise

**1. Parágrafos e fluxo principal**

O programa BNK1CAC é a tela CICS de criação de conta bancária (transação OCAC). O fluxo é este:

- **PREMIERE (A010):** decide o que fazer conforme a tecla pressionada. Em ENTER, executa PROCESS-MAP. Ao final, devolve o controle com a transação OCAC.
- **PROCESS-MAP (PM010):** executa RECEIVE-MAP, depois EDIT-DATA. Se os dados forem válidos, executa CRE-ACC-DATA. Por fim, executa SEND-MAP.
- **RECEIVE-MAP (RM010):** recebe os dados da tela.
- **EDIT-DATA (ED010):** valida número do cliente, tipo de conta, taxa de juros e limite de cheque especial.
- **CRE-ACC-DATA (CAD010):** chama o programa CREACC, que cria a conta, e trata o resultado.
- **SEND-MAP (SM010), SEND-TERMINATION-MSG (STM010), ABEND-THIS-TASK (ATT010) e POPULATE-TIME-DATE (PTD010):** enviam a tela e a mensagem de encerramento, abendam a tarefa e obtêm data e hora.

**2 e 3. Estruturas de decisão e classificação**

| Estrutura | Parágrafo | Classificação |
|---|---|---|
| EVALUATE TRUE (EIBCALEN, PA1–3, PF3, PF12, CLEAR, ENTER, tecla inválida) | A010 | Interface |
| IF EIBCALEN NOT = 0 (preparar commarea) | A010 | Interface |
| IF WS-CICS-RESP NOT = NORMAL (RETURN, RECEIVE MAP, LINK CREACC, SEND MAP, SEND TEXT) | A010, RM010, CAD010, SM010, STM010 | Infraestrutura (abend e registro técnico) |
| IF SEND-ERASE / SEND-DATAONLY / SEND-DATAONLY-ALARM | SM010 | Interface |
| IF VALID-DATA | PM010 | Fluxo que apenas leva à criação da conta. Cada rejeição já está coberta pelas regras de EDIT-DATA, então não é listado à parte. |
| Número do cliente vazio | ED010 | Negócio (obrigatoriedade) |
| Número do cliente não numérico | ED010 | Formato (não listado) |
| Tipo de conta vazio | ED010 | Negócio (obrigatoriedade) |
| EVALUATE ACCTYPI (valores aceitos / outro valor) | ED010 | Negócio (lista de valores aceitos) |
| Taxa de juros vazia | ED010 | Negócio (obrigatoriedade) |
| Taxa não numérica, caracteres inválidos, mais de um ponto decimal | ED010 | Formato (não listado) |
| Mais de duas casas decimais na taxa | ED010 | Negócio (restrição de valor). Há uma ambiguidade, descrita na regra. |
| Taxa menor que zero | ED010 | Negócio (limite mínimo) |
| Taxa maior que 9999,99 | ED010 | Negócio (limite máximo) |
| Limite de cheque especial com caracteres não numéricos (duas ocorrências) | ED010 | Formato (não listado) |
| Limite de cheque especial vazio | ED010 | Negócio (campo opcional, assume zero) |
| Cliente ou tipo de conta vazio ("Missing expected data") | ED010 | Negócio (obrigatoriedade, repetida) |
| SUBPGM-SUCCESS = 'N' e EVALUATE SUBPGM-FAIL-CODE | CAD010 | Misto, detalhado abaixo |
| ELSE (sucesso) | CAD010 | Negócio |

Detalhe do EVALUATE SUBPGM-FAIL-CODE:

- **Negócio:** código '1' (cliente inexistente), '8' (excesso de contas) e 'A' (tipo de conta não suportado).
- **Infraestrutura:** códigos '2', '3', '4', '5', '6', '7' e '9'. São falhas de acesso a dados, ENQ, incremento ou restauração de contador, gravação e contagem.
- **OTHER:** mensagem genérica "conta não criada". É falha técnica sem causa de negócio definida e não foi listada.

**4. Condição e consequência das estruturas de negócio**

- Número do cliente vazio: a conta não é criada e a tela pede o número de 10 dígitos.
- Tipo de conta vazio: a conta não é criada e a tela informa os tipos aceitos.
- Tipo de conta informado: se estiver na lista aceita, segue o processamento. Caso contrário, é rejeitado.
- Taxa de juros vazia: é rejeitada.
- Taxa com mais de duas casas decimais: o programa tenta rejeitar, mas a lógica é ambígua.
- Taxa negativa ou acima de 9999,99: é rejeitada.
- Limite de cheque especial vazio: assume zero.
- Cliente ou tipo de conta vazio na verificação final: a conta não é criada.
- Retorno de CREACC: o resultado define a mensagem. Cliente inexistente, excesso de contas ou tipo não suportado impedem a criação. Em caso de sucesso, a conta é criada e exibida.

## Regras de negócio

1. Regra: O número do cliente é obrigatório para criar uma conta.
   Condição: Número do cliente não informado (CUSTNOL < 1 ou CUSTNOI preenchido apenas com o caractere de preenchimento "_").
   Consequência: A criação é recusada e a tela pede um número de cliente de 10 dígitos.
   Parágrafo: EDIT-DATA (ED010)

2. Regra: O tipo de conta é obrigatório para criar uma conta.
   Condição: Tipo de conta não informado (ACCTYPI só com "_" ou ACCTYPL < 1).
   Consequência: A criação é recusada e a tela informa que o tipo deve ser ISA, CURRENT, LOAN, SAVING ou MORTGAGE.
   Parágrafo: EDIT-DATA (ED010)

3. Regra: Só são aceitos os tipos de conta ISA, CURRENT, LOAN, SAVING e MORTGAGE.
   Condição: Tipo de conta informado igual a um desses valores, em maiúsculas ou em minúsculas, com ou sem preenchimento por "_" ou espaços. Ambiguidade: variações com letras maiúsculas e minúsculas misturadas, como "Isa", não constam da lista e caem na recusa.
   Consequência: O tipo é aceito e normalizado para maiúsculas, e a validação segue para os demais campos.
   Parágrafo: EDIT-DATA (ED010)

4. Regra: Tipo de conta fora da lista de tipos aceitos é recusado.
   Condição: Tipo de conta informado diferente dos valores aceitos (EVALUATE ACCTYPI, WHEN OTHER).
   Consequência: A criação é recusada e a tela informa os tipos aceitos.
   Parágrafo: EDIT-DATA (ED010)

5. Regra: A taxa de juros é obrigatória.
   Condição: Taxa de juros não informada (INTRTL = ZERO).
   Consequência: A criação é recusada e a tela pede uma taxa de juros numérica.
   Parágrafo: EDIT-DATA (ED010)

6. Regra: A taxa de juros aceita no máximo duas casas decimais.
   Condição: Taxa informada com ponto decimal seguido de mais de duas casas. Ambiguidade: a contagem do código, feita com INSPECT ... AFTER '.' sobre uma faixa que já começa depois do ponto, parece não contar nada. Pode ser que a mensagem "Only up to two decimal places are supported" nunca seja exibida.
   Consequência: A criação é recusada com a mensagem de que só são suportadas até duas casas decimais.
   Parágrafo: EDIT-DATA (ED010)

7. Regra: A taxa de juros não pode ser negativa.
   Condição: Valor numérico da taxa menor que zero (INTRTI-COMP-1 < 0).
   Consequência: A criação é recusada e a tela pede uma taxa zero ou positiva.
   Parágrafo: EDIT-DATA (ED010)

8. Regra: A taxa de juros tem um limite máximo.
   Condição: Valor da taxa maior que 9999,99 (INTRTI-COMP-1 > 9999.99). Ambiguidade: a mensagem diz "menos de 9999.99%", mas o código só recusa valores estritamente maiores, então 9999,99 é aceito.
   Consequência: A criação é recusada e a tela pede uma taxa menor que 9999,99%.
   Parágrafo: EDIT-DATA (ED010)

9. Regra: O limite de cheque especial é opcional e, se não for informado, é considerado zero.
   Condição: Limite de cheque especial não informado (OVERDRL < 1, OVERDRI só com "_" ou em branco).
   Consequência: O limite é assumido como zero e a validação continua.
   Parágrafo: EDIT-DATA (ED010)

10. Regra: Na verificação final, número do cliente e tipo de conta ausentes impedem a criação da conta.
    Condição: Número do cliente ou tipo de conta não informado (CUSTNOL < 1 ou ACCTYPL < 1). Repete as regras 1 e 2 e só seria alcançada se as verificações anteriores não tivessem encerrado a validação.
    Consequência: A criação é recusada com a mensagem "Missing expected data".
    Parágrafo: EDIT-DATA (ED010)

11. Regra: Não é possível criar conta para um cliente que não existe.
    Condição: A criação de conta falha com código '1' (SUBPGM-SUCCESS = 'N' e SUBPGM-FAIL-CODE = '1').
    Consequência: A conta não é criada e a tela informa que o número do cliente fornecido não existe.
    Parágrafo: CRE-ACC-DATA (CAD010)

12. Regra: Há um limite de contas por cliente.
    Condição: A criação de conta falha com código '8' (SUBPGM-FAIL-CODE = '8', "too many accounts"). O limite em si é definido no programa CREACC, não neste.
    Consequência: A conta não é criada e a tela informa que há contas demais.
    Parágrafo: CRE-ACC-DATA (CAD010)

13. Regra: Tipos de conta não suportados pela criação de contas são recusados.
    Condição: A criação de conta falha com código 'A' (SUBPGM-FAIL-CODE = 'A'). Ambiguidade: este programa já só aceita os cinco tipos acima, então o motivo de CREACC recusar um tipo não é evidente aqui.
    Consequência: A conta não é criada e a tela informa que o tipo de conta não é suportado.
    Parágrafo: CRE-ACC-DATA (CAD010)

14. Regra: A conta é criada quando a criação é concluída com sucesso.
    Condição: A criação de conta termina com sucesso (SUBPGM-SUCCESS diferente de 'N').
    Consequência: A tela informa que a conta foi criada e exibe os dados da conta: agência, número, datas de abertura e de extrato e saldos.
    Parágrafo: CRE-ACC-DATA (CAD010)