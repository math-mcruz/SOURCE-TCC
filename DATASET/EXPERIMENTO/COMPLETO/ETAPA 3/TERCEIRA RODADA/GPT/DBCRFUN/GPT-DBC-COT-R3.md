## **Análise**

### **1. Parágrafos e fluxo principal do programa**

**Programa:** DBCRFUN

**Finalidade:** Processar movimentações financeiras em contas bancárias, verificando restrições conforme o tipo de conta e de operação, atualizando os saldos disponível e efetivo e registrando a transação processada.

| Seção / Parágrafo                    | Função                                                                                                   |
| ------------------------------------ | -------------------------------------------------------------------------------------------------------- |
| PREMIERE / A010                      | Inicializa o resultado da operação e inicia a atualização da conta.                                      |
| UPDATE-ACCOUNT-DB2 / UAD010          | Consulta a conta, verifica restrições da movimentação e atualiza seus saldos.                            |
| WRITE-TO-PROCTRAN / WTP010           | Encaminha o registro da movimentação financeira.                                                         |
| WRITE-TO-PROCTRAN-DB2 / WTPD010      | Classifica a movimentação como débito ou crédito, determina seu tipo e descrição e registra a transação. |
| GET-ME-OUT-OF-HERE / GMOOH010        | Encerra o processamento.                                                                                 |
| CHECK-FOR-STORM-DRAIN-DB2 / CFSDD010 | Identifica condições técnicas de indisponibilidade do banco de dados.                                    |
| ABEND-HANDLING / AH010               | Trata interrupções técnicas do programa.                                                                 |
| POPULATE-TIME-DATE / PTD10           | Obtém a data e hora utilizadas no tratamento técnico de falhas.                                          |

**Fluxo principal:**

1. O programa recebe a conta e o valor da movimentação.
2. Consulta a conta bancária usando o código da agência e o número da conta.
3. Se a conta não for encontrada, retorna uma indicação de insucesso.
4. Se o valor for negativo, verifica restrições relativas ao tipo de conta, à modalidade da operação e ao saldo disponível.
5. Verifica uma segunda vez a restrição para contas dos tipos MORTGAGE e LOAN na modalidade 496, independentemente do sinal do valor.
6. Quando a operação não é bloqueada, acrescenta seu valor aos saldos disponível e efetivo da conta.
7. Atualiza a conta.
8. Classifica a transação conforme o sinal do valor e a modalidade da operação.
9. Registra a movimentação financeira.
10. Se o registro da transação for concluído com sucesso, informa que a operação foi realizada.

### **2. Estruturas de decisão e classificação**

| Parágrafo | Estrutura de decisão                                                           | Classificação                          | Resultado                                                           |
| --------- | ------------------------------------------------------------------------------ | -------------------------------------- | ------------------------------------------------------------------- |
| UAD010    | `IF SQLCODE NOT = 0` após SELECT                                               | Negócio / infraestrutura               | Distingue conta não encontrada de falha técnica.                    |
| UAD010    | `IF SQLCODE = +100`                                                            | Negócio                                | Identifica conta inexistente e retorna código de falha 1.           |
| UAD010    | `IF COMM-AMT < 0`                                                              | Negócio                                | Aplica verificações específicas às movimentações de valor negativo. |
| UAD010    | `IF` tipo MORTGAGE ou LOAN e modalidade 496, dentro do teste de valor negativo | Negócio                                | Rejeita a movimentação com código 4.                                |
| UAD010    | `IF WS-DIFFERENCE < 0 AND COMM-FACILTYPE = 496`                                | Negócio                                | Rejeita a movimentação com código 3.                                |
| UAD010    | `IF` tipo MORTGAGE ou LOAN e modalidade 496, após o bloco de valor negativo    | Negócio                                | Rejeita a movimentação com código 4.                                |
| UAD010    | `IF SQLCODE NOT = 0` após UPDATE                                               | Infraestrutura                         | Trata falha técnica de atualização.                                 |
| WTPD010   | `IF COMM-AMT < 0`                                                              | Negócio                                | Distingue movimentações de débito e crédito.                        |
| WTPD010   | `IF COMM-FACILTYPE = 496` no ramo negativo                                     | Negócio                                | Classifica o débito como PDR.                                       |
| WTPD010   | `IF COMM-FACILTYPE = 496` no ramo não negativo                                 | Negócio                                | Classifica o crédito como PCR.                                      |
| WTPD010   | `IF SQLCODE NOT = 0` após INSERT                                               | Infraestrutura / resultado da operação | Distingue falha de registro de conclusão bem-sucedida.              |
| WTPD010   | `IF WS-CICS-RESP NOT = DFHRESP(NORMAL)`                                        | Infraestrutura                         | Trata falha técnica na reversão da operação.                        |
| CFSDD010  | `EVALUATE SQLCODE`                                                             | Infraestrutura                         | Identifica perda de conexão com DB2.                                |
| CFSDD010  | `IF STORM-DRAIN-CONDITION NOT EQUAL ...`                                       | Infraestrutura                         | Emite diagnóstico técnico.                                          |
| AH010     | `EVALUATE MY-ABEND-CODE`                                                       | Infraestrutura                         | Distingue tipos de interrupção técnica.                             |
| AH010     | `IF WS-CICS-RESP NOT = DFHRESP(NORMAL)`                                        | Infraestrutura                         | Trata falha técnica de reversão.                                    |
| AH010     | `IF WS-STORM-DRAIN = 'N'`                                                      | Infraestrutura                         | Determina o encerramento técnico anormal.                           |

Não foram identificadas decisões de interface.

### **3. Condições e consequências de negócio**

**Consulta da conta — UAD010**

- Quando a consulta retorna SQLCODE +100, a conta não foi encontrada e a movimentação é recusada com código 1.
- Outros resultados não nulos da consulta correspondem a falhas técnicas e não geram regras de negócio.

**Restrição por tipo de conta — UAD010**

- Para uma movimentação negativa, se a conta for MORTGAGE ou LOAN e a modalidade for 496, a operação é recusada com código 4.
- Existe uma segunda decisão com a mesma restrição. Como está fora do bloco de valor negativo, ela também alcança movimentações de valor zero ou positivo. Para valores negativos dessas contas, a primeira decisão já encerra o processamento.

**Restrição de saldo — UAD010**

- Para movimentações negativas na modalidade 496, se o saldo disponível somado ao valor da movimentação for inferior a zero, a operação é recusada com código 3.
- O teste não utiliza o limite de cheque especial cadastrado na conta.
- Para modalidades diferentes de 496, o código não aplica essa restrição de saldo.

**Classificação das movimentações — WTPD010**

- Valor negativo e modalidade diferente de 496: débito DEB, com descrição `COUNTER WTHDRW`.
- Valor negativo e modalidade 496: débito PDR, com descrição baseada nos 14 primeiros caracteres de `COMM-ORIGIN`.
- Valor zero ou positivo e modalidade diferente de 496: crédito CRE, com descrição `COUNTER RECVED`.
- Valor zero ou positivo e modalidade 496: crédito PCR, com descrição baseada nos 14 primeiros caracteres de `COMM-ORIGIN`.

**Conclusão da movimentação — WTPD010**

- Quando a inclusão da transação financeira é concluída com sucesso, o programa informa sucesso (`COMM-SUCCESS = 'Y'` e `COMM-FAIL-CODE = '0'`).
- O caminho de falha da inclusão é tratamento técnico e não constitui regra de negócio.

### **4. Delimitação**

A classificação das movimentações considera o código 496 como uma modalidade específica, sem atribuir a ele um significado comercial não demonstrado pelo programa.

A condição de saldo insuficiente é avaliada somente para valores negativos na modalidade 496. O programa não demonstra uma validação geral de saldo para todas as modalidades.

As duas ocorrências da restrição MORTGAGE/LOAN foram preservadas separadamente. Também foram preservados os quatro caminhos finais de classificação das transações. Não foram criadas regras independentes para atribuições de valores que não possuem decisão própria.

## **Regras de negócio**

1\. **Regra:** Uma movimentação financeira não pode ser realizada quando a conta bancária informada não é encontrada.

**Condição:** Quando a consulta da conta pelo código da agência e número da conta não encontra registro (SQLCODE = +100).

**Consequência:** A movimentação é recusada, com indicação de insucesso e código de falha 1.

**Parágrafo:** UAD010

2\. **Regra:** Uma movimentação de débito na modalidade 496 não é permitida em contas dos tipos financiamento imobiliário (MORTGAGE) ou empréstimo (LOAN).

**Condição:** Quando o valor da movimentação é negativo (`COMM-AMT < 0`), a modalidade é 496 e o tipo da conta é MORTGAGE ou LOAN.

**Consequência:** A movimentação é recusada, com indicação de insucesso e código de falha 4.

**Parágrafo:** UAD010

3\. **Regra:** Uma movimentação de débito na modalidade 496 não pode resultar em saldo disponível negativo.

**Condição:** Quando o valor da movimentação é negativo, a modalidade é 496 e a soma do saldo disponível da conta com o valor da movimentação é inferior a zero (`WS-DIFFERENCE < 0`), desde que a operação não tenha sido recusada pela restrição anterior.

**Consequência:** A movimentação é recusada, com indicação de insucesso e código de falha 3.

**Parágrafo:** UAD010

4\. **Regra:** Movimentações na modalidade 496 em contas dos tipos financiamento imobiliário (MORTGAGE) ou empréstimo (LOAN) são recusadas independentemente do valor, caso alcancem a segunda verificação dessa restrição.

**Condição:** Quando a conta é do tipo MORTGAGE ou LOAN, a modalidade é 496 e a movimentação alcança a segunda verificação, após as validações aplicáveis aos valores negativos.

**Consequência:** A movimentação é recusada, com indicação de insucesso e código de falha 4. Na prática, esse caminho também bloqueia valores iguais a zero ou positivos, pois os negativos dessas contas já foram recusados na primeira verificação.

**Parágrafo:** UAD010

5\. **Regra:** Uma movimentação de valor negativo, em modalidade diferente de 496, é classificada como débito de retirada em caixa.

**Condição:** Quando o valor da movimentação é negativo (`COMM-AMT < 0`) e a modalidade é diferente de 496.

**Consequência:** A transação é classificada com o tipo DEB e a descrição `COUNTER WTHDRW`.

**Parágrafo:** WTPD010

6\. **Regra:** Uma movimentação de valor negativo na modalidade 496 é classificada como débito específico dessa modalidade.

**Condição:** Quando o valor da movimentação é negativo e a modalidade é 496, desde que a movimentação tenha sido aprovada nas verificações anteriores.

**Consequência:** A transação é classificada com o tipo PDR e recebe como descrição os 14 primeiros caracteres da origem informada (`COMM-ORIGIN`).

**Parágrafo:** WTPD010

7\. **Regra:** Uma movimentação de valor positivo ou igual a zero, em modalidade diferente de 496, é classificada como crédito de recebimento em caixa.

**Condição:** Quando o valor da movimentação é maior ou igual a zero (`COMM-AMT >= 0`) e a modalidade é diferente de 496.

**Consequência:** A transação é classificada com o tipo CRE e a descrição `COUNTER RECVED`.

**Parágrafo:** WTPD010

8\. **Regra:** Uma movimentação de valor positivo ou igual a zero na modalidade 496 é classificada como crédito específico dessa modalidade.

**Condição:** Quando o valor da movimentação é maior ou igual a zero, a modalidade é 496 e a conta não foi bloqueada pelas restrições anteriores.

**Consequência:** A transação é classificada com o tipo PCR e recebe como descrição os 14 primeiros caracteres da origem informada (`COMM-ORIGIN`).

**Parágrafo:** WTPD010

9\. **Regra:** Uma movimentação financeira é considerada concluída com sucesso quando seu registro é efetivado.

**Condição:** Quando a inclusão da movimentação na base de transações processadas é concluída com sucesso (SQLCODE = 0).

**Consequência:** A operação é informada como bem-sucedida (`COMM-SUCCESS = 'Y'`) e recebe código de resultado 0 (`COMM-FAIL-CODE = '0'`).

**Parágrafo:** WTPD010