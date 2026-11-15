1\. Regra: O valor de uma transferência bancária deve ser maior que zero. Caso o valor informado seja zero ou negativo, a transferência é rejeitada com o código de falha '4'.\
Condição: o valor da transferência (COMM-AMT) é menor ou igual a zero.\
Consequência: a transferência não é realizada; indicador de sucesso 'N' e código de falha '4'.\
Parágrafo: A010 (PREMIERE SECTION)

2\. Regra: Não é permitido realizar uma transferência bancária entre a mesma conta de origem e destino. Caso as contas sejam iguais, a transferência é interrompida.\
Condição: o número e o código bancário da conta de origem são iguais aos da conta de destino (COMM-FACCNO = COMM-TACCNO e COMM-FSCODE = COMM-TSCODE).\
Consequência: a transferência é interrompida, sem movimentação dos saldos; o programa encerra de forma anormal com o código 'SAME'.\
Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)

3\. Regra: Uma transferência bancária somente é concluída com sucesso quando a atualização das contas de origem e destino é realizada com sucesso.\
Condição: as atualizações das contas de origem e destino são bem-sucedidas (COMM-SUCCESS = 'Y' após as operações nas duas contas), permitindo a conclusão do processamento.\
Consequência: a transferência é considerada realizada, com o valor debitado dos saldos disponível e atual da conta de origem e creditado nos saldos disponível e atual da conta de destino; indicador de sucesso 'Y'.\
Parágrafo: UAD010 (UPDATE-ACCOUNT-DB2)

4\. Regra: A conta de origem de uma transferência bancária deve existir. Caso não seja encontrada, a transferência é considerada malsucedida com o código de falha '1'.\
Condição: a consulta da conta de origem não encontra registro correspondente ao código bancário e ao número da conta informados (SQLCODE = +100).\
Consequência: a transferência não é concluída; indicador de sucesso 'N' e código de falha '1'.\
Parágrafo: UADF010 (UPDATE-ACCOUNT-DB2-FROM)

5\. Regra: A conta de destino de uma transferência bancária deve existir. Caso não seja encontrada, a transferência é considerada malsucedida com o código de falha '2'.\
Condição: a consulta da conta de destino não encontra registro correspondente ao código bancário e ao número da conta informados (SQLCODE = +100).\
Consequência: a transferência não é concluída; indicador de sucesso 'N' e código de falha '2'.\
Parágrafo: UADT010 (UPDATE-ACCOUNT-DB2-TO)