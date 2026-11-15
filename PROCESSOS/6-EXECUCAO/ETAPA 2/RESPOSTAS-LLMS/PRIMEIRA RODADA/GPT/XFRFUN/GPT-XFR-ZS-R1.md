1\. **Regra:** O valor de uma transferência bancária deve ser maior que zero.

**Condição:** Quando o valor informado para a transferência (COMM-AMT) for menor ou igual a zero.

**Consequência:** A transferência é rejeitada, com indicação de insucesso e código de falha 4.

**Parágrafo:** A010.

2\. **Regra:** Não é permitido realizar transferências entre uma conta bancária e ela mesma.

**Condição:** Quando o número e o código bancário da conta de origem forem iguais aos da conta de destino (COMM-FACCNO = COMM-TACCNO e COMM-FSCODE = COMM-TSCODE).

**Consequência:** A transferência é interrompida e não é concluída.

**Parágrafo:** UAD010.

3\. **Regra:** A conta de origem deve existir para que uma transferência seja realizada.

**Condição:** Quando a conta de origem não for encontrada no cadastro de contas (SQLCODE = +100).

**Consequência:** A transferência não prossegue, sendo indicado insucesso com código de falha 1.

**Parágrafo:** UADF010.

4\. **Regra:** A conta de destino deve existir para receber uma transferência bancária.

**Condição:** Quando a conta de destino não for encontrada no cadastro de contas (SQLCODE = +100).

**Consequência:** A transferência não prossegue, sendo indicado insucesso com código de falha 2.

**Parágrafo:** UADT010.

5\. **Regra:** Uma transferência bancária somente é considerada concluída quando as operações nas contas de origem e destino são realizadas com sucesso.

**Condição:** Quando o processamento das duas contas é bem-sucedido (COMM-SUCCESS = 'Y' nas verificações correspondentes), independentemente da ordem numérica das contas.

**Consequência:** A transferência é considerada concluída, com redução dos saldos disponível e efetivo da conta de origem, aumento dos mesmos saldos na conta de destino, registro da transferência e indicação de sucesso.

**Parágrafo:** UAD010.