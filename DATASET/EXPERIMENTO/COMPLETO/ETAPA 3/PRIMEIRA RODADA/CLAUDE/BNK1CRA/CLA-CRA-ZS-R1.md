1. Regra: O número da conta informado não pode ser zero (ACCNOI = ZERO).
   Condição: O número da conta informado na tela é igual a zero.
   Consequência: A solicitação é recusada com a mensagem pedindo uma conta diferente de zero, e nenhum valor é aplicado.
   Parágrafo: EDIT-DATA (ED010)

2. Regra: O valor do lançamento é obrigatório e não pode ser deixado vazio (AMTL = ZERO).
   Condição: O campo de valor chega sem nenhum caractere digitado (tamanho zero).
   Consequência: A solicitação é recusada com a mensagem de que o valor deve ser informado (texto "The Amount entered must be numeric."), e nenhum valor é aplicado.
   Parágrafo: VALIDATE-AMOUNT (VA010)

3. Regra: O valor do lançamento não pode ser preenchido apenas com espaços.
   Condição: O campo de valor tem tamanho maior que zero, mas só contém espaços em branco.
   Consequência: A solicitação é recusada com a mensagem de que o valor deve ser informado (texto "The Amount entered must be numeric."), e nenhum valor é aplicado.
   Parágrafo: VALIDATE-AMOUNT (VA010)

4. Regra: O valor do lançamento não pode ser zero (WS-AMOUNT-AS-FLOAT = ZERO). Ambiguidade: esse teste só é alcançado quando o valor digitado não é puramente numérico (por exemplo, "0.00"). Um valor puramente numérico como "0" é aceito sem passar por esta verificação.
   Condição: O valor digitado, depois de convertido, é igual a zero e o campo não era puramente numérico.
   Consequência: A solicitação é recusada com a mensagem "Please supply a non-zero amount.", e nenhum valor é aplicado.
   Parágrafo: VALIDATE-AMOUNT (VA010)

5. Regra: O crédito ou débito só é aplicado na conta se todos os dados informados forem válidos.
   Condição: A validação dos dados (número da conta e valor) termina com dados válidos (VALID-DATA).
   Consequência: O lançamento é enviado para processamento na conta. Se algum dado for inválido, o lançamento não é processado e a tela volta com a mensagem de erro.
   Parágrafo: PROCESS-MAP (PM010)

6. Regra: Valor informado com sinal negativo é tratado como débito na conta.
   Condição: O sinal informado na tela é "-" (SIGNI = '-').
   Consequência: O valor é convertido para negativo antes de ser enviado ao processamento do lançamento (DBCRFUN). O programa só inverte o sinal; a decisão de debitar o saldo está no subprograma, que não faz parte do código fornecido.
   Parágrafo: UPD-CRED-DATA (UCD010)

7. Regra: Lançamento em conta inexistente é recusado.
   Condição: O processamento do lançamento retorna insucesso com código de falha '1' (conta não encontrada para o código de agência).
   Consequência: O valor não é aplicado, e a tela exibe a mensagem de que a conta não foi encontrada para aquela agência (SORTCODE) e de que o valor não foi aplicado.
   Parágrafo: UPD-CRED-DATA (UCD010)

8. Regra: Lançamento é recusado quando não há saldo suficiente.
   Condição: O processamento do lançamento retorna insucesso com código de falha '3' (fundos insuficientes).
   Consequência: O valor não é aplicado, e a tela exibe a mensagem de que não há fundos suficientes para processar a solicitação.
   Parágrafo: UPD-CRED-DATA (UCD010)

9. Regra: Lançamento processado com sucesso confirma a operação e mostra a conta e os saldos atualizados.
   Condição: O processamento do lançamento não retorna insucesso (SUBPGM-SUCCESS diferente de 'N').
   Consequência: A tela exibe a mensagem "Amount successfully applied to the account." junto com o número da conta, o código da agência, o saldo atual e o saldo disponível.
   Parágrafo: UPD-CRED-DATA (UCD010)