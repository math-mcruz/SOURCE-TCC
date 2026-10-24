1\. Regra: A criação de uma conta bancária somente é solicitada quando os dados informados passam pelas validações.

- Condição: Quando todos os dados são considerados válidos (`VALID-DATA`).
- Consequência: O sistema solicita a criação da conta bancária.
- Parágrafo: PM010.

2\. Regra: O número do cliente é obrigatório para a criação de uma conta.

- Condição: Quando o número do cliente não é informado (`CUSTNOL < 1`) ou permanece preenchido com caracteres de campo vazio (`CUSTNOI = '__________'`).
- Consequência: A solicitação é rejeitada e o sistema pede o preenchimento do número do cliente.
- Parágrafo: ED010.

3\. Regra: O tipo de conta é obrigatório para a criação de uma conta bancária.

- Condição: Quando o tipo de conta não é informado (`ACCTYPL < 1`) ou permanece preenchido com caracteres de campo vazio (`ACCTYPI = '________'`).
- Consequência: A solicitação é rejeitada e o sistema informa os tipos de conta permitidos.
- Parágrafo: ED010.

4\. Regra: O tipo de conta ISA pode ser informado com letras maiúsculas ou minúsculas e com preenchimento complementar por sublinhados ou espaços.

- Condição: Quando o tipo de conta informado é `ISA_____`, `isa_____`, `ISA     ` ou `isa     `.
- Consequência: O tipo de conta é aceito como ISA.
- Parágrafo: ED010.

5\. Regra: O tipo de conta CURRENT pode ser informado com letras maiúsculas ou minúsculas e com preenchimento complementar por sublinhado ou espaço.

- Condição: Quando o tipo de conta informado é `CURRENT_`, `current_`, `CURRENT ` ou `current `.
- Consequência: O tipo de conta é aceito como CURRENT.
- Parágrafo: ED010.

6\. Regra: O tipo de conta LOAN pode ser informado com letras maiúsculas ou minúsculas e com preenchimento complementar por sublinhados ou espaços.

- Condição: Quando o tipo de conta informado é `LOAN____`, `loan____`, `LOAN    ` ou `loan    `.
- Consequência: O tipo de conta é aceito como LOAN.
- Parágrafo: ED010.

7\. Regra: O tipo de conta SAVING pode ser informado com letras maiúsculas ou minúsculas e com preenchimento complementar por sublinhados ou espaços.

- Condição: Quando o tipo de conta informado é `SAVING__`, `saving__`, `SAVING  ` ou `saving  `.
- Consequência: O tipo de conta é aceito como SAVING.
- Parágrafo: ED010.

8\. Regra: O tipo de conta MORTGAGE pode ser informado com letras maiúsculas ou minúsculas.

- Condição: Quando o tipo de conta informado é `MORTGAGE` ou `mortgage`.
- Consequência: O tipo de conta é aceito como MORTGAGE.
- Parágrafo: ED010.

9\. Regra: A criação de contas é restrita aos tipos ISA, CURRENT, LOAN, SAVING e MORTGAGE, nas representações explicitamente aceitas pelo programa.

- Condição: Quando o tipo de conta informado não corresponde a nenhuma das opções reconhecidas.
- Consequência: A solicitação é rejeitada e o sistema informa os tipos de conta permitidos.
- Parágrafo: ED010.

10\. Regra: A taxa de juros deve ser obrigatoriamente informada para a criação da conta.

- Condição: Quando a taxa de juros não foi preenchida (`INTRTL = ZERO`).
- Consequência: A solicitação é rejeitada e o sistema pede o preenchimento da taxa de juros.
- Parágrafo: ED010.

11\. Regra: A taxa de juros da conta não pode ser negativa.

- Condição: Quando a taxa de juros informada é inferior a zero (`INTRTI-COMP-1 < 0`).
- Consequência: A solicitação é rejeitada e o sistema informa que a taxa deve ser zero ou positiva.
- Parágrafo: ED010.

12\. Regra: A taxa de juros da conta não pode ultrapassar 9999,99%.

- Condição: Quando a taxa informada é superior a 9999,99 (`INTRTI-COMP-1 > 9999.99`).
- Consequência: A solicitação é rejeitada e o sistema informa o limite permitido para a taxa de juros.
- Parágrafo: ED010.

13\. Regra: O limite de cheque especial é opcional e assume o valor zero quando não é informado.

- Condição: Quando o limite de cheque especial está vazio, contém apenas espaços ou apresenta os caracteres de campo vazio (`OVERDRL < 1`, `OVERDRI = '________'` ou `OVERDRI = SPACES`).
- Consequência: O sistema considera o limite de cheque especial igual a zero.
- Parágrafo: ED010.

14\. Regra: O número do cliente e o tipo de conta devem estar preenchidos para que a solicitação seja considerada válida.

- Condição: Quando o número do cliente ou o tipo de conta apresenta comprimento inferior a um (`CUSTNOL < 1 OR ACCTYPL < 1`), na verificação final dos dados.
- Consequência: A solicitação é rejeitada com a mensagem de ausência de dados obrigatórios.
- Parágrafo: ED010.

15\. Regra: A criação da conta é recusada quando o número de cliente informado não existe.

- Condição: Quando a tentativa de criação não obtém sucesso (`SUBPGM-SUCCESS = 'N'`) e retorna o motivo `SUBPGM-FAIL-CODE = '1'`.
- Consequência: O sistema informa que o número de cliente fornecido não existe.
- Parágrafo: CAD010.

16\. Regra: A criação da conta não pode ser concluída quando os dados cadastrais do cliente estão inacessíveis.

- Condição: Quando a tentativa de criação não obtém sucesso e retorna o motivo `SUBPGM-FAIL-CODE = '2'`.
- Consequência: O sistema informa que os dados do cliente não podem ser acessados e que a conta não pode ser criada.
- Parágrafo: CAD010.

17\. Regra: A criação da conta é recusada quando o cliente atingiu a quantidade máxima de contas permitida.

- Condição: Quando a tentativa de criação não obtém sucesso e retorna o motivo `SUBPGM-FAIL-CODE = '8'`.
- Consequência: O sistema informa que a conta não foi criada porque há contas em excesso, sem especificar o limite máximo.
- Parágrafo: CAD010.

18\. Regra: A criação da conta é recusada quando o tipo de conta solicitado não é suportado pelo processamento de abertura.

- Condição: Quando a tentativa de criação não obtém sucesso e retorna o motivo `SUBPGM-FAIL-CODE = 'A'`.
- Consequência: O sistema informa que a conta não foi criada porque o tipo de conta não é suportado.
- Parágrafo: CAD010.

19\. Regra: Uma tentativa de abertura de conta sem sucesso pode resultar em uma recusa sem motivo específico apresentado ao cliente.

- Condição: Quando a tentativa de criação não obtém sucesso e o motivo retornado não corresponde a nenhum dos códigos explicitamente tratados (`WHEN OTHER`).
- Consequência: O sistema informa genericamente que a conta não foi criada.
- Parágrafo: CAD010.

20\. Regra: A abertura de conta é confirmada quando o processamento de criação não indica insucesso.

- Condição: Quando `SUBPGM-SUCCESS` é diferente de `'N'`, após a execução do processamento de criação.
- Consequência: O sistema informa que a conta foi criada com sucesso e apresenta os dados da conta retornados pelo processamento, incluindo identificação, datas e saldos.
- Parágrafo: CAD010.