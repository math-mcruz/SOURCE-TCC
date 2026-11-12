## Análise

### 1. Parágrafos e fluxo principal do programa

O programa DBCRFUN realiza a atualização dos saldos disponível e efetivo de uma conta bancária, de acordo com o valor de uma operação recebida. Antes da atualização, verifica restrições relacionadas ao tipo de conta, ao tipo de operação e à disponibilidade de saldo. Após a atualização, registra a transação processada.

| Parágrafo ou seção                     | Função no programa                                                                                   |
| -------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| `A010` — PREMIERE                      | Inicializa o resultado da operação, identifica o código bancário e inicia a atualização da conta.    |
| `UAD010` — UPDATE-ACCOUNT-DB2          | Consulta a conta, verifica restrições da operação e atualiza seus saldos.                            |
| `WTP010` — WRITE-TO-PROCTRAN           | Encaminha o processamento para o registro da transação.                                              |
| `WTPD010` — WRITE-TO-PROCTRAN-DB2      | Classifica a transação como débito ou crédito, determina seu tipo e descrição e registra a operação. |
| `GMOOH010` — GET-ME-OUT-OF-HERE        | Encerra o processamento.                                                                             |
| `CFSDD010` — CHECK-FOR-STORM-DRAIN-DB2 | Identifica e comunica condições técnicas de indisponibilidade do DB2.                                |
| `AH010` — ABEND-HANDLING               | Trata interrupções técnicas do processamento.                                                        |
| `PTD10` — POPULATE-TIME-DATE           | Obtém data e horário para tratamento técnico.                                                        |

O fluxo principal é:

1. O programa recebe a conta, o valor da operação e o tipo de facilidade (`COMM-FACILTYPE`).
2. Consulta a conta utilizando código bancário e número da conta.
3. Se a conta não for encontrada, informa o insucesso da operação.
4. Se o valor for negativo, verifica restrições para contas de financiamento imobiliário ou empréstimo e, quando aplicável, a suficiência do saldo disponível.
5. Realiza uma segunda verificação de restrição para contas de financiamento imobiliário ou empréstimo, independentemente do sinal do valor.
6. Se a operação for permitida, acrescenta o valor recebido aos saldos disponível e efetivo.
7. Atualiza a conta e, em caso de sucesso técnico, classifica e registra a transação.
8. Se o registro da transação for concluído, sinaliza o sucesso da operação.

### 2. Estruturas de decisão e classificação

| Parágrafo  | Estrutura e condição                                                                      | Classificação                                                   | Consequência                                                                                 |
| ---------- | ----------------------------------------------------------------------------------------- | --------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| `UAD010`   | `IF SQLCODE NOT = 0`, após consulta                                                       | Negócio para `SQLCODE = +100`; infraestrutura para demais erros | Conta não encontrada impede a operação; outros códigos indicam falha técnica.                |
| `UAD010`   | `IF SQLCODE = +100`                                                                       | Negócio                                                         | Informa que a conta não foi localizada, com código de falha 1.                               |
| `UAD010`   | `IF COMM-AMT < 0`                                                                         | Negócio                                                         | Submete as operações de valor negativo às verificações específicas de débito.                |
| `UAD010`   | Conta `MORTGAGE` ou `LOAN`, com `COMM-FACILTYPE = 496`, dentro do teste de valor negativo | Negócio                                                         | Rejeita a operação, com código de falha 4.                                                   |
| `UAD010`   | `WS-DIFFERENCE < 0 AND COMM-FACILTYPE = 496`                                              | Negócio                                                         | Rejeita o débito quando o saldo disponível resultante seria negativo, com código de falha 3. |
| `UAD010`   | Conta `MORTGAGE` ou `LOAN`, com `COMM-FACILTYPE = 496`, após as verificações de débito    | Negócio                                                         | Rejeita a operação, com código de falha 4, inclusive para valores não negativos.             |
| `UAD010`   | `IF SQLCODE NOT = 0`, após atualização                                                    | Infraestrutura                                                  | Informa falha técnica na atualização da conta.                                               |
| `WTPD010`  | `IF COMM-AMT < 0`                                                                         | Negócio                                                         | Classifica a transação como débito se negativa; caso contrário, como crédito.                |
| `WTPD010`  | `IF COMM-FACILTYPE = 496`, dentro do ramo de débito                                       | Negócio                                                         | Classifica o débito como `PDR` e utiliza a origem informada como descrição.                  |
| `WTPD010`  | `IF COMM-FACILTYPE = 496`, dentro do ramo de crédito                                      | Negócio                                                         | Classifica o crédito como `PCR` e utiliza a origem informada como descrição.                 |
| `WTPD010`  | `IF SQLCODE NOT = 0`, após inclusão da transação                                          | Infraestrutura                                                  | Trata falha no registro da transação; no caminho de sucesso, confirma a operação.            |
| `WTPD010`  | `IF WS-CICS-RESP NOT = DFHRESP(NORMAL)`                                                   | Infraestrutura                                                  | Trata falha técnica no desfazimento da transação.                                            |
| `CFSDD010` | `EVALUATE SQLCODE`, incluindo 923 e OTHER                                                 | Infraestrutura                                                  | Identifica perda de conexão com DB2 ou outra condição técnica.                               |
| `CFSDD010` | `IF STORM-DRAIN-CONDITION NOT EQUAL 'Not Storm Drain     '`                               | Infraestrutura                                                  | Emite diagnóstico técnico de indisponibilidade.                                              |
| `AH010`    | `EVALUATE MY-ABEND-CODE`, incluindo `AD2Z`, `AFCR`, `AFCS` e `AFCT`                       | Infraestrutura                                                  | Trata diferentes condições de interrupção técnica.                                           |
| `AH010`    | `IF WS-CICS-RESP NOT = DFHRESP(NORMAL)`                                                   | Infraestrutura                                                  | Trata falha no desfazimento de alterações.                                                   |
| `AH010`    | `IF WS-STORM-DRAIN = 'N'`                                                                 | Infraestrutura                                                  | Determina tratamento técnico da interrupção.                                                 |

Não foram identificadas decisões classificadas exclusivamente como interface. O programa não implementa validações de preenchimento obrigatório nem restrições explícitas de formato dos campos recebidos.

### 3. Interpretação das decisões de negócio

Em `UAD010`, o valor 496 identifica uma modalidade de operação sujeita a restrições específicas. O código não fornece sua denominação comercial, portanto essa modalidade é referida pelo próprio valor.

As contas `MORTGAGE` e `LOAN` são impedidas de receber operações dessa modalidade. Para valores negativos, a rejeição ocorre na primeira verificação. Para valores não negativos, ocorre na segunda verificação.

O teste de insuficiência de saldo considera exclusivamente o saldo disponível acrescido do valor da operação. O limite de cheque especial existente no cadastro da conta não participa dessa decisão.

Em `WTPD010`, os tipos `DEB`, `CRE`, `PDR` e `PCR` distinguem registros de débito e crédito. Para a modalidade 496, a descrição vem dos primeiros 14 caracteres de `COMM-ORIGIN`; para as demais modalidades, são utilizadas descrições fixas.

O valor zero segue o caminho das operações não negativas, sendo classificado como crédito. Isso não significa que exista uma validação explícita permitindo ou proibindo valores zerados.

As regras repetidas de restrição a contas `MORTGAGE` e `LOAN` são apresentadas separadamente, respeitando suas duas ocorrências no código.

## Regras de negócio

1\. Regra: Uma operação bancária deve ser recusada quando a conta informada não for encontrada.\
Condição: Quando a consulta pelo código bancário e número da conta não localizar um cadastro (`SQLCODE = +100`).\
Consequência: A operação não é realizada e retorna o código de falha 1.\
Parágrafo: `UAD010` — UPDATE-ACCOUNT-DB2.

2\. Regra: Uma operação de débito da modalidade 496 não é permitida em contas de financiamento imobiliário ou empréstimo.\
Condição: Quando o valor da operação é negativo (`COMM-AMT < 0`), a modalidade é 496 (`COMM-FACILTYPE = 496`) e o tipo de conta é `MORTGAGE` ou `LOAN`.\
Consequência: A operação é recusada, com código de falha 4, sem atualização dos saldos.\
Parágrafo: `UAD010` — UPDATE-ACCOUNT-DB2.

3\. Regra: Uma operação de débito da modalidade 496 não pode deixar o saldo disponível da conta negativo.\
Condição: Quando o valor da operação é negativo, a modalidade é 496, a conta não foi recusada pela restrição anterior e a soma do saldo disponível com o valor da operação é inferior a zero.\
Consequência: A operação é recusada, com código de falha 3, sem atualização dos saldos.\
Parágrafo: `UAD010` — UPDATE-ACCOUNT-DB2.

4\. Regra: Operações da modalidade 496 são recusadas para contas de financiamento imobiliário ou empréstimo na verificação geral do tipo de conta.\
Condição: Quando a conta é `MORTGAGE` ou `LOAN`, a modalidade é 496 e a operação alcança essa verificação, o que, pelo fluxo anterior, ocorre para valores não negativos.\
Consequência: A operação é recusada, com código de falha 4, sem atualização dos saldos.\
Parágrafo: `UAD010` — UPDATE-ACCOUNT-DB2.

5\. Regra: Uma operação negativa de modalidade diferente de 496 é registrada como retirada em caixa.\
Condição: Quando o valor da operação é negativo e `COMM-FACILTYPE` é diferente de 496, após a atualização da conta.\
Consequência: A transação é classificada como débito (`DEB`), com a descrição `COUNTER WTHDRW`.\
Parágrafo: `WTPD010` — WRITE-TO-PROCTRAN-DB2.

6\. Regra: Uma operação negativa da modalidade 496 é registrada como débito específico dessa modalidade.\
Condição: Quando o valor da operação é negativo e `COMM-FACILTYPE = 496`, após a aprovação e atualização da conta.\
Consequência: A transação é classificada como `PDR`, utilizando os primeiros 14 caracteres da origem da operação (`COMM-ORIGIN`) como descrição.\
Parágrafo: `WTPD010` — WRITE-TO-PROCTRAN-DB2.

7\. Regra: Uma operação não negativa de modalidade diferente de 496 é registrada como recebimento em caixa.\
Condição: Quando o valor da operação é maior ou igual a zero e `COMM-FACILTYPE` é diferente de 496, após a atualização da conta.\
Consequência: A transação é classificada como crédito (`CRE`), com a descrição `COUNTER RECVED`.\
Parágrafo: `WTPD010` — WRITE-TO-PROCTRAN-DB2.

8\. Regra: Uma operação não negativa da modalidade 496 é registrada como crédito específico dessa modalidade.\
Condição: Quando o valor da operação é maior ou igual a zero e `COMM-FACILTYPE = 496`, após a aprovação e atualização da conta.\
Consequência: A transação é classificada como `PCR`, utilizando os primeiros 14 caracteres da origem da operação (`COMM-ORIGIN`) como descrição.\
Parágrafo: `WTPD010` — WRITE-TO-PROCTRAN-DB2.