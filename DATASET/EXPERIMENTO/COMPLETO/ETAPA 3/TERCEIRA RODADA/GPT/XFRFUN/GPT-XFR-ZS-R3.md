1\. **Regra:** Uma transferência bancária somente pode ser realizada quando o valor informado for maior que zero (`COMM-AMT > 0`).

- **Condição:** O valor da transferência é menor ou igual a zero.
- **Consequência:** A transferência é rejeitada, com indicação de insucesso e código de falha `4`.
- **Parágrafo:** `A010`

2\. **Regra:** Não é permitido realizar uma transferência entre a mesma conta de origem e destino.

- **Condição:** O número e o código da agência da conta de origem são iguais aos da conta de destino (`COMM-FACCNO = COMM-TACCNO` e `COMM-FSCODE = COMM-TSCODE`).
- **Consequência:** A transferência é impedida e o processamento é encerrado, com a indicação de que não é possível transferir para a mesma conta.
- **Parágrafo:** `UAD010`

3\. **Regra:** Uma transferência não pode ser realizada quando a conta de origem não é encontrada.

- **Condição:** A consulta à conta de origem não encontra uma conta correspondente ao código da agência e ao número informados (`SQLCODE = +100`).
- **Consequência:** A transferência é considerada malsucedida, com código de falha `1`.
- **Parágrafo:** `UADF010`

4\. **Regra:** Uma transferência não pode ser realizada quando a conta de destino não é encontrada.

- **Condição:** A consulta à conta de destino não encontra uma conta correspondente ao código da agência e ao número informados (`SQLCODE = +100`).
- **Consequência:** A transferência é considerada malsucedida, com código de falha `2`.
- **Parágrafo:** `UADT010`

5\. **Regra:** Uma transferência é considerada concluída com sucesso quando as operações nas contas de origem e destino são realizadas com sucesso.

- **Condição:** O processamento das duas contas termina sem indicação de falha (`COMM-SUCCESS = 'Y'` após as operações).
- **Consequência:** O valor da transferência é debitado dos saldos disponível e efetivo da conta de origem, creditado nos saldos disponível e efetivo da conta de destino, e a transferência recebe indicação de sucesso.
- **Parágrafo:** `UAD010`