1. Regra: O número da conta informado não pode ser zero.
   Condição: Número da conta (ACCNOI) igual a zero.
   Consequência: A operação é rejeitada com a mensagem "Please enter a non zero account number" e o valor não é lançado.
   Parágrafo: ED010 (EDIT-DATA)

2. Regra: O valor da operação é obrigatório.
   Condição: O campo de valor (AMTL) é enviado com tamanho zero, ou seja, vazio.
   Consequência: A operação é rejeitada com a mensagem "The Amount entered must be numeric" (a mensagem fala em número, mas o teste é de ausência de dado) e o valor não é lançado.
   Parágrafo: VA010 (VALIDATE-AMOUNT)

3. Regra: O valor da operação não pode ser composto apenas por espaços em branco.
   Condição: Todos os caracteres do campo de valor são espaços.
   Consequência: A operação é rejeitada com a mensagem "The Amount entered must be numeric" e o valor não é lançado.
   Parágrafo: VA010 (VALIDATE-AMOUNT)

4. Regra: O valor da operação aceita no máximo duas casas decimais.
   Condição: O valor informado tem ponto decimal e mais de duas posições após o ponto.
   Consequência: A operação é rejeitada com a mensagem "Only up to two decimal places are supported". Ambiguidade: a segunda contagem de casas decimais parece nunca ultrapassar 2, porque o ponto não aparece no trecho examinado. Por isso a rejeição final pode nunca ocorrer, e um valor com mais de duas casas pode seguir adiante sem esse bloqueio.
   Parágrafo: VA010 (VALIDATE-AMOUNT)

5. Regra: O valor da operação não pode ser zero.
   Condição: O valor numérico informado (WS-AMOUNT-AS-FLOAT) é igual a zero.
   Consequência: A operação é rejeitada com a mensagem "Please supply a non-zero amount" e o valor não é lançado.
   Parágrafo: VA010 (VALIDATE-AMOUNT)

6. Regra: O valor só é enviado para lançamento na conta se todas as validações dos dados informados forem aprovadas.
   Condição: Os dados informados passaram em todas as validações (VALID-DATA).
   Consequência: O valor é enviado ao lançamento na conta. Caso contrário, nenhum lançamento é feito e a tela exibe a mensagem de erro correspondente.
   Parágrafo: PM010 (PROCESS-MAP)

7. Regra: Um valor informado com o sinal "-" é tratado como débito, isto é, como valor negativo.
   Condição: O sinal informado (SIGNI) é "-". Se for "+" ou não for informado, o valor segue positivo, o que o código não trata como exceção.
   Consequência: O valor é multiplicado por -1 antes de ser enviado ao lançamento na conta.
   Parágrafo: UCD010 (UPD-CRED-DATA)

8. Regra: O lançamento não é feito quando a conta não é encontrada para o código de agência.
   Condição: O lançamento retorna insucesso com código de falha "1" (SUBPGM-FAIL-CODE).
   Consequência: A tela exibe "Sorry but the ACCOUNT no was not found for SORTCODE ... Amount not applied." e o valor não é aplicado.
   Parágrafo: UCD010 (UPD-CRED-DATA)

9. Regra: O lançamento não é feito quando não há saldo suficiente.
   Condição: O lançamento retorna insucesso com código de falha "3" (SUBPGM-FAIL-CODE).
   Consequência: A tela exibe "Sorry insufficient funds available to process the request." e o valor não é aplicado.
   Parágrafo: UCD010 (UPD-CRED-DATA)

10. Regra: Quando o lançamento é bem-sucedido, o cliente é informado e vê os saldos atualizados.
    Condição: O lançamento retorna sucesso (SUBPGM-SUCCESS diferente de "N").
    Consequência: A tela exibe "Amount successfully applied to the account." junto com a conta, o código da agência, o saldo atual e o saldo disponível.
    Parágrafo: UCD010 (UPD-CRED-DATA)