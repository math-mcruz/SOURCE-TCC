1\. **Regra:** O número da conta bancária deve ser diferente de zero.

- **Condição:** Quando o número da conta informado é igual a zero.
- **Consequência:** A solicitação é rejeitada e o cliente recebe uma mensagem solicitando um número de conta diferente de zero.
- **Parágrafo:** ED010

2\. **Regra:** O valor da operação deve ser informado obrigatoriamente.

- **Condição:** Quando o campo de valor da operação está vazio (AMTL = ZERO).
- **Consequência:** A solicitação é rejeitada e o cliente recebe uma mensagem informando que o valor deve ser numérico.
- **Parágrafo:** VA010

3\. **Regra:** O valor da operação não pode conter apenas espaços em branco.

- **Condição:** Quando todos os caracteres informados no campo de valor são espaços em branco.
- **Consequência:** A solicitação é rejeitada e o cliente recebe uma mensagem informando que o valor deve ser numérico.
- **Parágrafo:** VA010

4\. **Regra:** O valor da operação pode ser aceito diretamente quando contém apenas dígitos, inclusive quando é zero.

- **Condição:** Quando todos os caracteres do valor informado são numéricos (AMTI(1:AMTL) IS NUMERIC).
- **Consequência:** O valor é considerado válido e segue para processamento, sem passar pela verificação posterior que rejeita valores iguais a zero.
- **Parágrafo:** VA010

5\. **Regra:** O valor da operação admite no máximo duas casas decimais.

- **Condição:** Quando o valor informado contém um ponto decimal e a validação identifica mais de duas casas decimais.
- **Consequência:** A solicitação é rejeitada e o cliente recebe uma mensagem informando que são permitidas no máximo duas casas decimais.
- **Parágrafo:** VA010

6\. **Regra:** O valor da operação deve ser diferente de zero quando submetido à verificação final de valor.

- **Condição:** Quando o valor convertido é igual a zero (WS-AMOUNT-AS-FLOAT = ZERO) e o processamento alcança essa verificação.
- **Consequência:** A solicitação é rejeitada e o cliente recebe uma mensagem solicitando um valor diferente de zero.
- **Parágrafo:** VA010

7\. **Regra:** Uma solicitação com dados considerados válidos é encaminhada para aplicação do valor à conta bancária.

- **Condição:** Quando as validações terminam com a indicação de dados válidos (VALID-DATA).
- **Consequência:** O sistema encaminha a operação para processamento na conta informada.
- **Parágrafo:** PM010

8\. **Regra:** Uma operação identificada com sinal negativo deve ser tratada como redução do valor da conta.

- **Condição:** Quando o sinal informado para a operação é negativo (SIGNI = '-').
- **Consequência:** O sistema inverte o sinal do valor e encaminha o montante negativo para processamento. A efetiva redução do saldo depende do processamento realizado pelo programa chamado.
- **Parágrafo:** UCD010

9\. **Regra:** Uma operação não pode ser aplicada quando a conta bancária não é encontrada.

- **Condição:** Quando o processamento retorna insucesso (SUBPGM-SUCCESS = 'N') com código de falha '1'.
- **Consequência:** O valor não é aplicado e o cliente recebe uma mensagem informando que a conta não foi encontrada para o código bancário (SORTCODE) retornado.
- **Parágrafo:** UCD010

10\. **Regra:** Uma operação não pode ser aplicada quando ocorre uma falha inesperada em seu processamento.

- **Condição:** Quando o processamento retorna insucesso (SUBPGM-SUCCESS = 'N') com código de falha '2' ou com um código diferente de '1', '2' e '3'.
- **Consequência:** O cliente recebe uma mensagem informando que o valor não pôde ser aplicado devido a um erro inesperado. Para códigos não reconhecidos, a mensagem também apresenta o código retornado.
- **Parágrafo:** UCD010

11\. **Regra:** Uma operação não pode ser realizada quando não existem fundos disponíveis suficientes.

- **Condição:** Quando o processamento retorna insucesso (SUBPGM-SUCCESS = 'N') com código de falha '3'.
- **Consequência:** A operação não é aplicada e o cliente recebe uma mensagem informando que não há fundos disponíveis suficientes para processar a solicitação.
- **Parágrafo:** UCD010

12\. **Regra:** O cliente deve ser informado quando o valor da operação é aplicado com sucesso à conta bancária.

- **Condição:** Quando o indicador de sucesso retornado pelo processamento é diferente de 'N' (SUBPGM-SUCCESS NOT = 'N').
- **Consequência:** O sistema informa que o valor foi aplicado com sucesso e apresenta o número da conta, o código bancário, o saldo real e o saldo disponível atualizados, conforme os dados retornados pelo processamento.
- **Parágrafo:** UCD010