1\. Regra: Uma transferência bancária não pode ser realizada com valor igual ou inferior a zero.\
Condição: Quando o valor da transferência (COMM-AMT) é menor ou igual a zero.\
Consequência: A transferência é rejeitada, com indicação de insucesso (COMM-SUCCESS = 'N') e código de falha '4'.\
Parágrafo: A010.

2\. Regra: Não é permitido transferir dinheiro de uma conta para ela mesma.\
Condição: Quando o número e o código bancário da conta de origem são iguais aos da conta de destino (COMM-FACCNO = COMM-TACCNO e COMM-FSCODE = COMM-TSCODE).\
Consequência: A transferência não é realizada, sendo interrompida com a indicação de que não é possível transferir para a mesma conta.\
Parágrafo: UAD010.

3\. Regra: A transferência não pode ser realizada quando a conta de origem não é encontrada.\
Condição: Quando a consulta à conta de origem retorna indicação de registro inexistente (SQLCODE = +100).\
Consequência: A transferência é considerada malsucedida (COMM-SUCCESS = 'N'), com código de falha '1'.\
Parágrafo: UADF010.

4\. Regra: A transferência não pode ser realizada quando a conta de destino não é encontrada.\
Condição: Quando a consulta à conta de destino retorna indicação de registro inexistente (SQLCODE = +100).\
Consequência: A transferência é considerada malsucedida (COMM-SUCCESS = 'N'), com código de falha '2', sem efetivação da operação.\
Parágrafo: UADT010.

5\. Regra: Uma transferência é considerada concluída quando as operações nas contas envolvidas são realizadas com sucesso.\
Condição: Quando o processamento da conta de origem e da conta de destino é bem-sucedido, independentemente de qual conta tenha sido processada primeiro.\
Consequência: A transferência é registrada como bem-sucedida (COMM-SUCCESS = 'Y').\
Parágrafo: UAD010.