## Análise

**1. Parágrafos e fluxo principal**

O programa BNK1TFN é uma tela CICS de transferência entre duas contas.

- **PREMIERE (A010):** decide pela tecla pressionada. Na primeira chamada exibe a tela. Com ENTER executa PROCESS-MAP. Depois devolve o controle à transação OTFN.
- **PROCESS-MAP (PM010):** executa RECEIVE-MAP e EDIT-DATA. Se os dados são válidos, executa GET-ACC-DATA. Em seguida reexibe a tela com SEND-MAP.
- **RECEIVE-MAP (RM010):** recebe os dados da tela.
- **EDIT-DATA (ED010):** valida as contas e chama VALIDATE-AMOUNT.
- **VALIDATE-AMOUNT (VA010):** valida o valor informado.
- **GET-ACC-DATA (GCD010):** chama o subprograma XFRFUN, que executa a transferência, e interpreta o retorno.
- **SEND-MAP (SM010), SEND-TERMINATION-MSG (STM010), ABEND-THIS-TASK (ATT010), POPULATE-TIME-DATE (PTD010):** rotinas de apoio técnico.

**2 e 3. Estruturas de decisão e classificação**

| Local | Estrutura | Classificação |
|---|---|---|
| A010 | EVALUATE de EIBCALEN e EIBAID (primeira chamada, PA1-3, PF3, PF12, CLEAR, ENTER, outra tecla) | Interface |
| A010, RM010, GCD010, SM010, STM010 | Testes de RESP diferente de NORMAL, seguidos de abend | Infraestrutura |
| SM010 | IF SEND-ERASE, SEND-DATAONLY, SEND-DATAONLY-ALARM | Interface |
| PM010 | IF VALID-DATA | Negócio |
| ED010 | FACCNOI e TACCNOI NOT NUMERIC | Formato (excluída) |
| ED010 | FACCNOI = TACCNOI | Negócio |
| ED010 | Conta igual a '00000000' | Negócio |
| VA010 | AMTL = ZERO | Negócio (obrigatoriedade) |
| VA010 | AMTI IS NUMERIC e NUMVAL <= 0 | Negócio |
| VA010 | Campo só com espaços | Negócio (obrigatoriedade) |
| VA010 | Presença de '-' | Negócio, com ambiguidade (ver abaixo) |
| VA010 | Espaços embutidos, caracteres não numéricos, mais de um ponto | Formato (excluídas) |
| VA010 | Mais de duas casas decimais | Negócio |
| VA010 | NUMVAL = ZERO | Negócio |
| GCD010 | SUBPGM-SUCCESS = 'N' com EVALUATE de SUBPGM-FAIL-CODE | Negócio nos códigos 1, 2 e 4. Os códigos 3 e OTHER são falhas técnicas. |
| GCD010 | SUBPGM-SUCCESS NOT = 'Y' | Infraestrutura (sucesso indeterminado) |
| GCD010 | Sucesso (ELSE) | Negócio |

**4. Condição e consequência das estruturas de negócio**

- **PM010:** se os dados passaram nas validações, a transferência é solicitada ao XFRFUN. Caso contrário, só a mensagem de erro é exibida.
- **ED010:** contas de origem e destino iguais, ou qualquer uma igual a 00000000, resultam em erro e na transferência não solicitada.
- **VA010:** valor ausente ou só com espaços, negativo, zero ou com mais de duas casas decimais resulta em erro e na transferência não solicitada.
- **GCD010:** o retorno do XFRFUN define a mensagem exibida.
  - Código 1: conta de origem não encontrada.
  - Código 2: conta de destino não encontrada.
  - Código 4: valor não maior que zero.
  - Sucesso: confirmação e exibição dos saldos.

**Observações de fidelidade**

- No código de falha '3' não há GO TO, então o fluxo cai no teste SUCCESS NOT = 'Y' e a mensagem de "erro inesperado" é sobrescrita por "unable to determine success". Por ser falha técnica, não entra nas regras.
- A rejeição por '-' testa o caractere e não o valor numérico. Ela só é alcançada quando o campo não é NUMERIC. Equivale a rejeitar valores negativos, mas é ambígua quanto à classificação formato versus valor.
- O teste de casas decimais tem lógica de contagem duplicada e confusa. A intenção é rejeitar mais de dois dígitos após o ponto.
- A rejeição de valor zero ou negativo é feita duas vezes no programa (VALIDATE-AMOUNT) e uma terceira vez pelo subprograma (código 4).

## Regras de negócio

1. Regra: A transferência só é solicitada ao sistema de contas quando todas as validações dos dados informados foram aprovadas.
   Condição: Os dados informados passaram nas validações de contas e valor (VALID-DATA).
   Consequência: A transferência é solicitada ao subprograma XFRFUN. Se as validações falharam, apenas a mensagem de erro é exibida e nada é solicitado.
   Parágrafo: PROCESS-MAP (PM010)

2. Regra: A conta de origem e a conta de destino devem ser diferentes.
   Condição: O número da conta de origem é igual ao da conta de destino (FACCNOI = TACCNOI).
   Consequência: A transferência é recusada com a mensagem "The FROM & TO account should be different".
   Parágrafo: EDIT-DATA (ED010)

3. Regra: O número de conta 00000000 não é aceito, seja como origem ou como destino.
   Condição: A conta de origem ou a conta de destino é igual a '00000000'.
   Consequência: A transferência é recusada com a mensagem "Account no 00000000 is not valid".
   Parágrafo: EDIT-DATA (ED010)

4. Regra: O valor da transferência é obrigatório.
   Condição: O campo de valor foi enviado com tamanho zero (AMTL = ZERO).
   Consequência: A transferência é recusada com a mensagem "The Amount entered must be numeric".
   Parágrafo: VALIDATE-AMOUNT (VA010)

5. Regra: O valor da transferência deve ser positivo quando informado em formato numérico.
   Condição: O valor informado é numérico e resulta em zero ou menos (WS-AMOUNT-AS-FLOAT <= 0).
   Consequência: A transferência é recusada com a mensagem "Please supply a positive amount".
   Parágrafo: VALIDATE-AMOUNT (VA010)

6. Regra: O valor da transferência não pode ser composto apenas de espaços em branco.
   Condição: Todo o conteúdo do campo de valor são espaços (contagem de espaços iniciais igual ao tamanho do campo).
   Consequência: A transferência é recusada com a mensagem "The Amount entered must be numeric".
   Parágrafo: VALIDATE-AMOUNT (VA010)

7. Regra: Valores negativos não são aceitos na transferência.
   Condição: O valor informado contém o sinal de menos '-' (WS-NUM-COUNT-MINUS > 0). Ambíguo: o código testa a presença do caractere e não o valor numérico, e só chega a este teste quando o campo não é puramente numérico.
   Consequência: A transferência é recusada com a mensagem "Please supply a positive amount".
   Parágrafo: VALIDATE-AMOUNT (VA010)

8. Regra: O valor da transferência aceita no máximo duas casas decimais.
   Condição: O valor tem ponto decimal e mais de dois dígitos após o ponto (WS-NUM-COUNT-TOTAL > 2). Ambíguo: a contagem é feita em duas etapas redundantes e confusas, mas a intenção evidente é limitar a duas casas.
   Consequência: A transferência é recusada com a mensagem "Only up to two decimal places are supported".
   Parágrafo: VALIDATE-AMOUNT (VA010)

9. Regra: O valor da transferência não pode ser zero.
   Condição: O valor numérico convertido é igual a zero (WS-AMOUNT-AS-FLOAT = ZERO).
   Consequência: A transferência é recusada com a mensagem "Please supply a non-zero amount".
   Parágrafo: VALIDATE-AMOUNT (VA010)

10. Regra: A transferência não é aplicada quando a conta de origem não existe.
    Condição: O XFRFUN retorna falha com código '1' (SUBPGM-SUCCESS = 'N' e SUBPGM-FAIL-CODE = '1').
    Consequência: É exibida a mensagem "Sorry the FROM ACCOUNT no was not found. Transfer not applied" e a transferência não é efetuada.
    Parágrafo: GET-ACC-DATA (GCD010)

11. Regra: A transferência não é aplicada quando a conta de destino não existe.
    Condição: O XFRFUN retorna falha com código '2' (SUBPGM-SUCCESS = 'N' e SUBPGM-FAIL-CODE = '2').
    Consequência: É exibida a mensagem "Sorry the TO ACCOUNT no was not found. Transfer not applied" e a transferência não é efetuada.
    Parágrafo: GET-ACC-DATA (GCD010)

12. Regra: A transferência não é aplicada quando o valor não é maior que zero, conforme verificação do sistema de contas.
    Condição: O XFRFUN retorna falha com código '4' (SUBPGM-SUCCESS = 'N' e SUBPGM-FAIL-CODE = '4').
    Consequência: É exibida a mensagem "Please supply an amount greater than zero" e a transferência não é efetuada.
    Parágrafo: GET-ACC-DATA (GCD010)

13. Regra: Quando a transferência é concluída com sucesso, o cliente recebe a confirmação e os saldos atualizados das duas contas.
    Condição: O XFRFUN retorna sucesso (SUBPGM-SUCCESS = 'Y').
    Consequência: É exibida a mensagem "Transfer successfully applied" junto com as contas, os códigos de agência e os saldos real e disponível da conta de origem e da conta de destino.
    Parágrafo: GET-ACC-DATA (GCD010)