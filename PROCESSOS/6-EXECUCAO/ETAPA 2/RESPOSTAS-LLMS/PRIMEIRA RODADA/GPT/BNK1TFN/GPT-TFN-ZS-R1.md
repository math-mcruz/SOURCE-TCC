1\. **Regra:** A conta de origem e a conta de destino de uma transferência devem ser diferentes.\
**Condição:** Quando o número da conta de origem é igual ao número da conta de destino (`FACCNOI = TACCNOI`).\
**Consequência:** A transferência não prossegue e o sistema informa que as contas de origem e destino devem ser diferentes.\
**Parágrafo:** ED010

2\. **Regra:** O número de conta `00000000` não é permitido em transferências.\
**Condição:** Quando a conta de origem ou a conta de destino possui o número `00000000`.\
**Consequência:** A transferência não prossegue e o sistema informa que o número de conta é inválido.\
**Parágrafo:** ED010

3\. **Regra:** O valor da transferência é de preenchimento obrigatório.\
**Condição:** Quando o campo de valor da transferência não foi preenchido (`AMTL = ZERO`).\
**Consequência:** A transferência não prossegue e o sistema solicita a correção do valor informado.\
**Parágrafo:** VA010

4\. **Regra:** O valor da transferência deve ser maior que zero.\
**Condição:** Quando o valor informado é numérico e menor ou igual a zero (`WS-AMOUNT-AS-FLOAT <= 0`).\
**Consequência:** A transferência não prossegue e o sistema solicita um valor positivo.\
**Parágrafo:** VA010

5\. **Regra:** O valor da transferência não pode ficar em branco.\
**Condição:** Quando o campo contém somente espaços (`WS-NUM-COUNT-TOTAL = AMTL`).\
**Consequência:** A transferência não prossegue e o sistema solicita a correção do valor informado.\
**Parágrafo:** VA010

6\. **Regra:** O valor da transferência pode ter no máximo duas casas decimais.\
**Condição:** Quando o valor informado possui mais de duas casas decimais, conforme a contagem realizada pelo programa (`WS-NUM-COUNT-TOTAL > 2`).\
**Consequência:** A transferência não prossegue e o sistema informa que são permitidas no máximo duas casas decimais.\
**Parágrafo:** VA010

7\. **Regra:** Não são permitidas transferências com valor igual a zero.\
**Condição:** Quando o valor convertido da transferência é igual a zero (`WS-AMOUNT-AS-FLOAT = ZERO`), após passar pelas validações anteriores.\
**Consequência:** A transferência não prossegue e o sistema solicita um valor diferente de zero.\
**Parágrafo:** VA010

8\. **Regra:** Uma transferência não pode ser concluída quando a conta de origem não é encontrada.\
**Condição:** Quando o processamento da transferência retorna insucesso (`SUBPGM-SUCCESS = 'N'`) com código de falha `1`.\
**Consequência:** O sistema informa que a conta de origem não foi encontrada e que a transferência não foi aplicada.\
**Parágrafo:** GCD010

9\. **Regra:** Uma transferência não pode ser concluída quando a conta de destino não é encontrada.\
**Condição:** Quando o processamento da transferência retorna insucesso (`SUBPGM-SUCCESS = 'N'`) com código de falha `2`.\
**Consequência:** O sistema informa que a conta de destino não foi encontrada e que a transferência não foi aplicada.\
**Parágrafo:** GCD010

10\. **Regra:** Uma transferência com valor não positivo pode ser recusada pelo processamento da transferência.\
**Condição:** Quando o processamento retorna insucesso (`SUBPGM-SUCCESS = 'N'`) com código de falha `4`.\
**Consequência:** O sistema solicita um valor maior que zero, sem confirmar a transferência.\
**Parágrafo:** GCD010

11\. **Regra:** Uma transferência pode ser recusada por uma falha não identificada entre os códigos específicos previstos.\
**Condição:** Quando o processamento retorna insucesso (`SUBPGM-SUCCESS = 'N'`) com código de falha diferente de `1`, `2`, `3` e `4`.\
**Consequência:** O sistema informa que a transferência não pôde ser aplicada devido a um erro.\
**Parágrafo:** GCD010

12\. **Regra:** Uma transferência com falha inesperada não recebe confirmação de sucesso.\
**Condição:** Quando o processamento retorna insucesso (`SUBPGM-SUCCESS = 'N'`) com código de falha `3`.\
**Consequência:** O sistema inicialmente prepara uma mensagem de erro inesperado, mas a substitui por uma mensagem informando que não foi possível aplicar a transferência porque não foi possível determinar seu sucesso.\
**Parágrafo:** GCD010

13\. **Regra:** Uma transferência sem confirmação explícita de sucesso não é apresentada como concluída.\
**Condição:** Quando o indicador de sucesso é diferente de `Y` e diferente de `N` (`SUBPGM-SUCCESS NOT = 'Y'`), após o tratamento dos códigos de falha.\
**Consequência:** O sistema informa que a transferência não pôde ser aplicada porque não foi possível determinar seu sucesso.\
**Parágrafo:** GCD010

14\. **Regra:** Uma transferência é considerada concluída quando seu processamento confirma o sucesso.\
**Condição:** Quando o processamento retorna indicador de sucesso igual a `Y` (`SUBPGM-SUCCESS = 'Y'`).\
**Consequência:** O sistema informa que a transferência foi realizada com sucesso e apresenta os saldos atual e disponível das contas de origem e destino retornados pelo processamento.\
**Parágrafo:** GCD010