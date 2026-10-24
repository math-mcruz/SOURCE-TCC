## Análise

### 1. Parágrafos e fluxo principal do programa

O programa BNK1CAC é responsável por receber e validar os dados necessários à abertura de uma conta bancária e solicitar sua criação ao programa CREACC.

O fluxo principal envolve os seguintes parágrafos:

- A010: identifica a situação da transação e encaminha o processamento.
- PM010: recebe os dados, executa as validações e, quando os dados são válidos, solicita a criação da conta.
- RM010: recebe os dados informados.
- ED010: valida o número do cliente, o tipo de conta, a taxa de juros e o limite de cheque especial.
- CAD010: solicita a criação da conta ao programa CREACC e interpreta o resultado.
- SM010 e STM010: controlam a apresentação das informações e o encerramento da interação.
- ATT010 e PTD010: executam procedimentos técnicos de tratamento de falhas e obtenção de data e hora.

### 2. Estruturas de decisão identificadas e classificação

| Parágrafo | Decisão                                                     | Classificação                                                             |
| --------- | ----------------------------------------------------------- | ------------------------------------------------------------------------- |
| A010      | `EVALUATE TRUE` para situações de entrada e teclas          | Interface                                                                 |
| A010      | `IF EIBCALEN NOT = 0`                                       | Infraestrutura                                                            |
| A010      | Retorno da transação diferente de normal                    | Infraestrutura                                                            |
| PM010     | `IF VALID-DATA`                                             | Negócio                                                                   |
| RM010     | Retorno do recebimento de dados diferente de normal         | Infraestrutura                                                            |
| ED010     | Número do cliente ausente ou não preenchido                 | Negócio                                                                   |
| ED010     | Número do cliente não numérico                              | Interface — formato                                                       |
| ED010     | Tipo de conta ausente ou não preenchido                     | Negócio                                                                   |
| ED010     | `IF ACCTYPL > 0`                                            | Negócio — condiciona a avaliação do tipo de conta                         |
| ED010     | `EVALUATE ACCTYPI` com valores aceitos                      | Negócio                                                                   |
| ED010     | `WHEN OTHER` para tipo de conta inválido                    | Negócio                                                                   |
| ED010     | Taxa de juros com tamanho zero                              | Negócio                                                                   |
| ED010     | Testes de caracteres, ponto decimal e casas decimais        | Interface — formato                                                       |
| ED010     | Taxa de juros menor que zero                                | Negócio                                                                   |
| ED010     | Taxa de juros maior que 9999,99                             | Negócio                                                                   |
| ED010     | Limite de cheque especial contendo caracteres não numéricos | Interface — formato                                                       |
| ED010     | Limite de cheque especial ausente ou em branco              | Negócio                                                                   |
| ED010     | Limite de cheque especial não numérico                      | Interface — formato                                                       |
| ED010     | Número do cliente ou tipo de conta com tamanho inferior a 1 | Negócio                                                                   |
| CAD010    | Retorno técnico da chamada ao CREACC diferente de normal    | Infraestrutura                                                            |
| CAD010    | `IF SUBPGM-SUCCESS = 'N'`                                   | Negócio                                                                   |
| CAD010    | `EVALUATE SUBPGM-FAIL-CODE`                                 | Negócio nos códigos 1, 8, A e OTHER; infraestrutura nos códigos 2 a 7 e 9 |
| CAD010    | Resultado diferente de `SUBPGM-SUCCESS = 'N'`               | Negócio                                                                   |
| SM010     | Decisões de envio e seus retornos técnicos                  | Interface / infraestrutura                                                |
| STM010    | Retorno técnico do envio da mensagem                        | Infraestrutura                                                            |

### 3. Condições e consequências de negócio

As decisões de negócio identificadas determinam:

- Se a solicitação de criação da conta pode prosseguir após as validações.
- Se o número do cliente e o tipo de conta foram informados.
- Quais tipos de conta são aceitos, incluindo suas variantes em letras maiúsculas e minúsculas.
- Se a taxa de juros foi informada e está dentro dos limites permitidos.
- Se a ausência do limite de cheque especial resulta na utilização de zero.
- Se a ausência de dados obrigatórios impede a continuidade.
- Se a solicitação de criação da conta foi aceita ou recusada pelo programa responsável.
- Quais motivos de recusa são comunicados ao usuário, incluindo cliente inexistente, excesso de contas e tipo de conta não suportado.

A validação de casas decimais da taxa de juros foi excluída por tratar de formato. Os códigos de falha 2 a 7 e 9 foram excluídos por representarem problemas técnicos de acesso, controle ou gravação.

A validação `OVERDRI = SPACES` foi mantida como regra porque o programa atribui zero ao limite de cheque especial quando esse dado não é informado.

### 4. Critérios de fidelidade e atomicidade

Cada ocorrência de decisão de negócio foi considerada separadamente, inclusive quando repete uma validação anterior.

Os valores aceitos para o tipo de conta foram agrupados quando produzem o mesmo resultado de negócio, sem criar regras para cada conversão de letras ou preenchimento.

As respostas do programa CREACC foram interpretadas somente conforme as condições e os códigos explicitamente tratados pelo BNK1CAC. A implementação interna do CREACC não foi presumida.

## Regras de negócio

1\. Regra: A criação da conta bancária somente é solicitada quando todos os dados submetidos às validações do programa são considerados válidos.\
Condição: Quando os dados da solicitação são considerados válidos (`VALID-DATA`).\
Consequência: O programa solicita a criação da conta bancária.\
Parágrafo: PM010

2\. Regra: O número do cliente é obrigatório para solicitar a criação de uma conta bancária.\
Condição: Quando o número do cliente não foi informado ou contém apenas o preenchimento padrão de sublinhados (`CUSTNOL < 1` ou `CUSTNOI = '__________'`).\
Consequência: A solicitação é considerada inválida, e o usuário é orientado a informar o número do cliente.\
Parágrafo: ED010

3\. Regra: O tipo de conta é obrigatório para solicitar a criação de uma conta bancária.\
Condição: Quando o tipo de conta não foi informado ou contém apenas o preenchimento padrão de sublinhados (`ACCTYPI = '________'` ou `ACCTYPL < 1`).\
Consequência: A solicitação é considerada inválida, e o usuário é orientado a informar um dos tipos de conta permitidos.\
Parágrafo: ED010

4\. Regra: O tipo de conta informado é submetido à verificação dos tipos de conta permitidos.\
Condição: Quando o tipo de conta foi informado (`ACCTYPL > 0`).\
Consequência: O programa verifica se o tipo de conta corresponde a uma das opções aceitas.\
Parágrafo: ED010

5\. Regra: O tipo de conta ISA é aceito na solicitação de criação de conta, independentemente de estar escrito em letras maiúsculas ou minúsculas.\
Condição: Quando o tipo informado corresponde a ISA, nas variantes previstas pelo programa, com espaços ou sublinhados de preenchimento.\
Consequência: O tipo de conta é aceito como ISA.\
Parágrafo: ED010

6\. Regra: O tipo de conta CURRENT é aceito na solicitação de criação de conta, independentemente de estar escrito em letras maiúsculas ou minúsculas.\
Condição: Quando o tipo informado corresponde a CURRENT, nas variantes previstas pelo programa, com espaço ou sublinhado de preenchimento.\
Consequência: O tipo de conta é aceito como CURRENT.\
Parágrafo: ED010

7\. Regra: O tipo de conta LOAN é aceito na solicitação de criação de conta, independentemente de estar escrito em letras maiúsculas ou minúsculas.\
Condição: Quando o tipo informado corresponde a LOAN, nas variantes previstas pelo programa, com espaços ou sublinhados de preenchimento.\
Consequência: O tipo de conta é aceito como LOAN.\
Parágrafo: ED010

8\. Regra: O tipo de conta SAVING é aceito na solicitação de criação de conta, independentemente de estar escrito em letras maiúsculas ou minúsculas.\
Condição: Quando o tipo informado corresponde a SAVING, nas variantes previstas pelo programa, com espaços ou sublinhados de preenchimento.\
Consequência: O tipo de conta é aceito como SAVING.\
Parágrafo: ED010

9\. Regra: O tipo de conta MORTGAGE é aceito na solicitação de criação de conta, independentemente de estar escrito em letras maiúsculas ou minúsculas.\
Condição: Quando o tipo informado corresponde a MORTGAGE em letras maiúsculas ou minúsculas.\
Consequência: O tipo de conta é aceito como MORTGAGE.\
Parágrafo: ED010

10\. Regra: Não é permitida a solicitação de criação de conta com um tipo diferente de ISA, CURRENT, LOAN, SAVING ou MORTGAGE.\
Condição: Quando o tipo de conta informado não corresponde a nenhuma das opções reconhecidas pelo programa (`WHEN OTHER`).\
Consequência: A solicitação é considerada inválida, e o usuário é informado sobre os tipos de conta permitidos.\
Parágrafo: ED010

11\. Regra: A taxa de juros é obrigatória para solicitar a criação de uma conta bancária.\
Condição: Quando a taxa de juros não foi informada (`INTRTL = ZERO`).\
Consequência: A solicitação é considerada inválida, e o usuário é orientado a informar a taxa de juros.\
Parágrafo: ED010

12\. Regra: A taxa de juros de uma nova conta bancária não pode ser negativa.\
Condição: Quando a taxa de juros informada é menor que zero (`INTRTI-COMP-1 < 0`).\
Consequência: A solicitação é considerada inválida, e o usuário é orientado a informar uma taxa de juros igual ou superior a zero.\
Parágrafo: ED010

13\. Regra: A taxa de juros de uma nova conta bancária não pode ser superior a 9999,99%.\
Condição: Quando a taxa de juros informada é maior que 9999,99 (`INTRTI-COMP-1 > 9999.99`).\
Consequência: A solicitação é considerada inválida, e o usuário é orientado a informar uma taxa de juros dentro do limite permitido.\
Parágrafo: ED010

14\. Regra: Quando o limite de cheque especial não é informado, o programa considera o limite igual a zero.\
Condição: Quando o limite de cheque especial está ausente, contém apenas sublinhados de preenchimento ou está em branco (`OVERDRL < 1`, `OVERDRI = '________'` ou `OVERDRI = SPACES`).\
Consequência: O limite de cheque especial é definido como zero para a solicitação de criação da conta.\
Parágrafo: ED010

15\. Regra: A criação da conta não pode prosseguir quando o número do cliente ou o tipo de conta está ausente.\
Condição: Quando o número do cliente ou o tipo de conta apresenta tamanho inferior a um (`CUSTNOL < 1` ou `ACCTYPL < 1`).\
Consequência: A solicitação é considerada inválida, e o usuário recebe uma mensagem informando a ausência de dados esperados.\
Parágrafo: ED010

16\. Regra: Quando a tentativa de criação da conta é recusada, o programa informa o motivo da recusa conforme o resultado retornado pelo serviço de criação.\
Condição: Quando o programa responsável pela criação da conta retorna indicador de insucesso (`SUBPGM-SUCCESS = 'N'`).\
Consequência: A solicitação é considerada inválida, e o motivo da não criação é avaliado para apresentação ao usuário.\
Parágrafo: CAD010

17\. Regra: Não é possível criar uma conta bancária para um número de cliente inexistente.\
Condição: Quando a criação da conta é recusada porque o número do cliente informado não existe (`SUBPGM-FAIL-CODE = '1'`).\
Consequência: O usuário é informado de que o número do cliente fornecido não existe, e a conta não é criada.\
Parágrafo: CAD010

18\. Regra: A criação de uma conta bancária pode ser recusada quando há excesso de contas.\
Condição: Quando o serviço de criação retorna o motivo de excesso de contas (`SUBPGM-FAIL-CODE = '8'`).\
Consequência: A conta não é criada, e o usuário é informado de que há contas em excesso. O programa não especifica o limite nem a abrangência dessa restrição.\
Parágrafo: CAD010

19\. Regra: A criação de uma conta bancária pode ser recusada quando o tipo de conta não é suportado pelo serviço de criação.\
Condição: Quando o serviço de criação informa que o tipo de conta não é suportado (`SUBPGM-FAIL-CODE = 'A'`).\
Consequência: A conta não é criada, e o usuário recebe a informação de que o tipo de conta não é suportado.\
Parágrafo: CAD010

20\. Regra: Quando a criação de uma conta é recusada por um motivo não reconhecido pelo tratamento específico do programa, o usuário recebe uma informação genérica de não criação.\
Condição: Quando o indicador de sucesso é 'N' e o código de falha não corresponde a nenhum dos códigos tratados (`WHEN OTHER`).\
Consequência: O usuário é informado de que a conta não foi criada, sem indicação de um motivo específico.\
Parágrafo: CAD010

21\. Regra: Quando o serviço de criação não retorna o indicador explícito de insucesso, o programa considera a conta bancária criada com sucesso.\
Condição: Quando o indicador de resultado da criação da conta é diferente de 'N' (`SUBPGM-SUCCESS NOT = 'N'`).\
Consequência: O usuário recebe a confirmação de criação da conta e os dados da conta retornados pelo serviço, incluindo identificação, datas e saldos. O código não exige explicitamente que o indicador seja 'Y' para tratar o resultado como sucesso.\
Parágrafo: CAD010