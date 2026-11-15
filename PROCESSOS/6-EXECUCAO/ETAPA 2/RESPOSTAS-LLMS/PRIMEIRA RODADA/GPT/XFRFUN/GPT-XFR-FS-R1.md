1\. Regra: O valor da transferência deve ser maior que zero. Caso seja zero ou negativo, a transferência é rejeitada com o código de falha '4'.\
Condição: o valor da transferência (COMM-AMT) é menor ou igual a zero.\
Consequência: a transferência não é realizada; indicador de sucesso 'N' e código de falha '4'.\
Parágrafo: A010 (PREMIERE SECTION)

2\. Regra: Não é permitido transferir valores de uma conta para ela mesma. Quando a conta de origem e a conta de destino são iguais, a transferência é impedida.\
Condição: o número e o código bancário da conta de origem são iguais aos da conta de destino (COMM-FACCNO = COMM-TACCNO e COMM-FSCODE = COMM-TSCODE).\
Consequência: a transferência não é realizada e o processamento é interrompido com o código 'SAME'.\
Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)

3\. Regra: Se a conta de origem da transferência não for encontrada, a operação é considerada malsucedida com o código de falha '1'.\
Condição: a consulta da conta de origem retorna SQLCODE +100, indicando que a conta não foi encontrada.\
Consequência: a transferência não é concluída; indicador de sucesso 'N' e código de falha '1'.\
Parágrafo: UADF010 (UPDATE-ACCOUNT-DB2-FROM)

4\. Regra: Se a conta de destino da transferência não for encontrada, a operação é considerada malsucedida com o código de falha '2'.\
Condição: a consulta da conta de destino retorna SQLCODE +100, indicando que a conta não foi encontrada.\
Consequência: a transferência não é concluída; indicador de sucesso 'N' e código de falha '2'.\
Parágrafo: UADT010 (UPDATE-ACCOUNT-DB2-TO)

5\. Regra: Quando as atualizações das contas de origem e destino são concluídas com sucesso, a transferência é considerada realizada e recebe o indicador de sucesso 'Y'.\
Condição: as atualizações das duas contas são bem-sucedidas (COMM-SUCCESS = 'Y'), independentemente de qual conta foi atualizada primeiro.\
Consequência: a transferência é concluída, com débito do valor nos saldos disponível e atual da conta de origem, crédito do mesmo valor nos saldos da conta de destino e indicador de sucesso 'Y'.\
Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)