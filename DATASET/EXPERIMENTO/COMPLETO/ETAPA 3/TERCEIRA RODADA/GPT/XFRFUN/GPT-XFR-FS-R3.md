1\. Regra: O valor da transferência deve ser maior que zero. Caso seja igual ou menor que zero, a transferência não é realizada e é sinalizada como malsucedida com o código de falha '4'.\
Condição: o valor da transferência (COMM-AMT) é menor ou igual a zero.\
Consequência: a transferência não é realizada; indicador de sucesso 'N' e código de falha '4'.\
Parágrafo: A010 (PREMIERE SECTION).

2\. Regra: Não é permitido transferir valores de uma conta para ela mesma. Quando a conta de origem e a conta de destino são iguais, a transferência é impedida.\
Condição: o número e o código bancário da conta de origem são iguais aos da conta de destino (COMM-FACCNO = COMM-TACCNO e COMM-FSCODE = COMM-TSCODE).\
Consequência: a transferência não é realizada; o processamento é interrompido com a indicação de que não é possível transferir para a mesma conta.\
Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2).

3\. Regra: Se a conta de origem da transferência não for encontrada, a operação é sinalizada como malsucedida com o código de falha '1'.\
Condição: a consulta da conta de origem retorna que a conta não existe (SQLCODE = +100).\
Consequência: indicador de sucesso 'N' e código de falha '1'; a transferência não é concluída.\
Parágrafo: UADF010 (UPDATE-ACCOUNT-DB2-FROM).

4\. Regra: Quando a conta de origem é encontrada, seu saldo disponível e seu saldo efetivo são reduzidos pelo valor da transferência, desde que a atualização seja concluída com sucesso.\
Condição: a consulta e a atualização da conta de origem são bem-sucedidas (SQLCODE = 0).\
Consequência: os saldos disponível e efetivo da conta de origem são debitados pelo valor transferido; o indicador de sucesso recebe 'Y' e os novos saldos são disponibilizados.\
Parágrafo: UADF010 (UPDATE-ACCOUNT-DB2-FROM).

5\. Regra: Se a conta de destino da transferência não for encontrada, a operação é sinalizada como malsucedida com o código de falha '2'.\
Condição: a consulta da conta de destino retorna que a conta não existe (SQLCODE = +100).\
Consequência: indicador de sucesso 'N' e código de falha '2'; a transferência não é concluída.\
Parágrafo: UADT010 (UPDATE-ACCOUNT-DB2-TO).

6\. Regra: Quando a conta de destino é encontrada, seu saldo disponível e seu saldo efetivo são aumentados pelo valor da transferência, desde que a atualização seja concluída com sucesso.\
Condição: a consulta e a atualização da conta de destino são bem-sucedidas (SQLCODE = 0).\
Consequência: os saldos disponível e efetivo da conta de destino são creditados pelo valor transferido; o indicador de sucesso recebe 'Y' e os novos saldos são disponibilizados.\
Parágrafo: UADT010 (UPDATE-ACCOUNT-DB2-TO).

7\. Regra: A transferência é considerada bem-sucedida quando as operações sobre as contas de origem e destino são concluídas com sucesso.\
Condição: as operações de atualização das duas contas terminam com indicador de sucesso 'Y', permitindo que o processamento alcance sua conclusão normal.\
Consequência: a transferência é sinalizada como realizada com sucesso (COMM-SUCCESS = 'Y').\
Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2).