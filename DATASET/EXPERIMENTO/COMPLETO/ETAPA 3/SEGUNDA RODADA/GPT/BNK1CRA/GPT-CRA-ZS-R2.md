1\. **Regra:** O número da conta bancária deve ser diferente de zero para permitir a operação.

- **Condição:** Quando o número da conta informado (ACCNOI) é igual a zero.
- **Consequência:** A operação é rejeitada e o cliente recebe uma mensagem solicitando um número de conta diferente de zero.
- **Parágrafo:** ED010

2\. **Regra:** O valor da operação é obrigatório.

- **Condição:** Quando o campo de valor da operação não foi preenchido (AMTL = ZERO).
- **Consequência:** A operação é rejeitada e o cliente recebe uma mensagem de valor inválido.
- **Parágrafo:** VA010

3\. **Regra:** O valor da operação não pode conter somente espaços em branco.

- **Condição:** Quando todos os caracteres informados no campo de valor são espaços em branco (WS-NUM-COUNT-TOTAL = AMTL).
- **Consequência:** A operação é rejeitada e o cliente recebe uma mensagem solicitando um valor numérico.
- **Parágrafo:** VA010

4\. **Regra:** O valor da operação admite no máximo duas casas decimais.

- **Condição:** Quando o valor informado contém um ponto decimal, possui mais de dois caracteres após esse ponto e a contagem adicional de dígitos decimais ultrapassa dois (WS-NUM-COUNT-TOTAL > 2).
- **Consequência:** A operação é rejeitada e o cliente recebe uma mensagem informando que somente até duas casas decimais são aceitas. A contagem adicional realizada pelo código torna a aplicação exata dessa restrição potencialmente ambígua.
- **Parágrafo:** VA010

5\. **Regra:** O valor da operação deve ser diferente de zero quando submetido à validação após o tratamento de espaços e casas decimais.

- **Condição:** Quando o valor convertido é igual a zero (WS-AMOUNT-AS-FLOAT = ZERO), após passar pelo tratamento complementar do campo.
- **Consequência:** A operação é rejeitada e o cliente recebe uma mensagem solicitando um valor diferente de zero. Essa verificação não é executada quando o valor informado é inteiramente numérico e foi aceito antecipadamente.
- **Parágrafo:** VA010

6\. **Regra:** Uma operação com dados considerados válidos deve ser encaminhada para aplicação do valor na conta bancária.

- **Condição:** Quando os dados informados são considerados válidos (VALID-DATA).
- **Consequência:** O sistema encaminha a solicitação para processamento da operação na conta.
- **Parágrafo:** PM010

7\. **Regra:** Uma operação com dados considerados inválidos não deve ser encaminhada para aplicação do valor na conta bancária.

- **Condição:** Quando os dados informados não são considerados válidos (VALID-DATA não atendida).
- **Consequência:** O sistema não executa a atualização da conta.
- **Parágrafo:** PM010

8\. **Regra:** Uma operação informada com sinal negativo deve ser processada com valor negativo.

- **Condição:** Quando o sinal informado para a operação é negativo (SIGNI = '-').
- **Consequência:** O sistema inverte o sinal do valor da operação antes de encaminhá-lo para processamento na conta.
- **Parágrafo:** UCD010

9\. **Regra:** Uma operação não pode ser aplicada quando a conta bancária informada não é encontrada.

- **Condição:** Quando o processamento da operação retorna insucesso (SUBPGM-SUCCESS = 'N') com código de falha '1'.
- **Consequência:** O valor não é aplicado e o cliente recebe uma mensagem informando que a conta não foi encontrada para o código bancário (SORTCODE) retornado.
- **Parágrafo:** UCD010

10\. **Regra:** Uma operação não pode ser aplicada quando ocorre um erro inesperado identificado pelo processamento bancário.

- **Condição:** Quando o processamento retorna insucesso (SUBPGM-SUCCESS = 'N') com código de falha '2'.
- **Consequência:** O valor não é aplicado e o cliente recebe uma mensagem informando que a operação não pôde ser realizada devido a um erro inesperado.
- **Parágrafo:** UCD010

11\. **Regra:** Uma operação não pode ser realizada quando a conta não possui fundos disponíveis suficientes.

- **Condição:** Quando o processamento retorna insucesso (SUBPGM-SUCCESS = 'N') com código de falha '3'.
- **Consequência:** A operação não é aplicada e o cliente recebe uma mensagem informando que os fundos disponíveis são insuficientes.
- **Parágrafo:** UCD010

12\. **Regra:** Uma operação não pode ser aplicada quando o processamento bancário retorna uma falha não prevista entre os códigos específicos.

- **Condição:** Quando o processamento retorna insucesso (SUBPGM-SUCCESS = 'N') com código de falha diferente de '1', '2' e '3'.
- **Consequência:** O valor não é aplicado e o cliente recebe uma mensagem de erro inesperado, acompanhada do código de falha retornado.
- **Parágrafo:** UCD010

13\. **Regra:** Uma operação deve ser apresentada ao cliente como concluída quando o processamento não informa insucesso.

- **Condição:** Quando o indicador de sucesso retornado pelo processamento é diferente de 'N' (SUBPGM-SUCCESS NOT = 'N').
- **Consequência:** O cliente recebe a confirmação de que o valor foi aplicado à conta, juntamente com o número da conta, o código bancário, o saldo atual e o saldo disponível. O código não verifica explicitamente se o indicador possui um valor específico de sucesso.
- **Parágrafo:** UCD010