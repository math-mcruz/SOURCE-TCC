1. Regra: O número do cliente é obrigatório para abrir uma conta.
   Condição: O número do cliente não foi informado (CUSTNOL < 1 ou CUSTNOI preenchido apenas com '__________').
   Consequência: A abertura é recusada, com a mensagem pedindo um número de cliente de 10 dígitos, e os dados são considerados inválidos.
   Parágrafo: EDIT-DATA (ED010)

2. Regra: O tipo de conta é obrigatório para abrir uma conta.
   Condição: O tipo de conta não foi informado (ACCTYPI preenchido apenas com '________' ou ACCTYPL < 1).
   Consequência: A abertura é recusada, com a mensagem informando que o tipo deve ser ISA, CURRENT, LOAN, SAVING ou MORTGAGE, e os dados são considerados inválidos.
   Parágrafo: EDIT-DATA (ED010)

3. Regra: São aceitos os tipos de conta ISA, CURRENT, LOAN, SAVING e MORTGAGE, em maiúsculas ou minúsculas, e o tipo é padronizado em maiúsculas. Ambiguidade: só são aceitas as grafias totalmente em maiúsculas ou totalmente em minúsculas, e o código não aceita grafias mistas, como "Isa".
   Condição: O tipo de conta informado é um dos valores aceitos (EVALUATE ACCTYPI), em qualquer das grafias previstas.
   Consequência: O tipo de conta é aceito e convertido para o texto padrão em maiúsculas, e a validação segue para os demais campos.
   Parágrafo: EDIT-DATA (ED010)

4. Regra: Tipos de conta fora da lista de valores aceitos são recusados.
   Condição: O tipo de conta informado não coincide com nenhum dos valores aceitos (EVALUATE ACCTYPI, WHEN OTHER).
   Consequência: A abertura é recusada, com a mensagem informando que o tipo deve ser ISA, CURRENT, LOAN, SAVING ou MORTGAGE, e os dados são considerados inválidos.
   Parágrafo: EDIT-DATA (ED010)

5. Regra: A taxa de juros é obrigatória para abrir uma conta.
   Condição: A taxa de juros não foi informada (INTRTL = ZERO).
   Consequência: A abertura é recusada, com a mensagem pedindo uma taxa de juros numérica, e os dados são considerados inválidos.
   Parágrafo: EDIT-DATA (ED010)

6. Regra: A taxa de juros pode ter no máximo duas casas decimais. Ambiguidade: o teste só é feito quando o campo não passa na verificação numérica inicial e contém exatamente um ponto decimal. Taxas puramente numéricas não passam por essa checagem.
   Condição: A taxa informada tem um ponto decimal e mais de dois dígitos depois dele (WS-NUM-COUNT-TOTAL > 2).
   Consequência: A abertura é recusada, com a mensagem de que só são aceitas até duas casas decimais, e os dados são considerados inválidos.
   Parágrafo: EDIT-DATA (ED010)

7. Regra: A taxa de juros não pode ser negativa.
   Condição: O valor numérico da taxa de juros é menor que zero (INTRTI-COMP-1 < 0).
   Consequência: A abertura é recusada, com a mensagem pedindo uma taxa zero ou positiva, e os dados são considerados inválidos.
   Parágrafo: EDIT-DATA (ED010)

8. Regra: A taxa de juros tem um limite máximo de 9999,99%.
   Condição: O valor numérico da taxa de juros é maior que 9999.99 (INTRTI-COMP-1 > 9999.99).
   Consequência: A abertura é recusada, com a mensagem pedindo uma taxa menor que 9999,99%, e os dados são considerados inválidos.
   Parágrafo: EDIT-DATA (ED010)

9. Regra: O limite de cheque especial é opcional e, se não for informado, é considerado zero.
   Condição: O limite de cheque especial não foi informado (OVERDRL < 1, OVERDRI preenchido apenas com '________' ou em branco).
   Consequência: O limite de cheque especial assume o valor zero e a validação continua.
   Parágrafo: EDIT-DATA (ED010)

10. Regra: A validação final recusa a solicitação se faltar o número do cliente ou o tipo de conta. Ambiguidade: este teste repete as regras 1 e 2, que já interrompem o processamento antes de chegar aqui, então na prática ele dificilmente é atingido.
    Condição: O número do cliente ou o tipo de conta não foi informado (CUSTNOL < 1 ou ACCTYPL < 1).
    Consequência: A solicitação é recusada, com a mensagem "Missing expected data", e os dados são considerados inválidos.
    Parágrafo: EDIT-DATA (ED010)

11. Regra: A conta só é criada se todos os dados informados forem válidos.
    Condição: Os dados informados passaram em todas as validações (VALID-DATA).
    Consequência: É solicitada a criação da conta ao programa CREACC. Se os dados forem inválidos, a criação não é solicitada e apenas a mensagem de erro é exibida.
    Parágrafo: PROCESS-MAP (PM010)

12. Regra: Não é possível criar conta para um cliente que não existe.
    Condição: A criação retornou falha com o código '1' (SUBPGM-SUCCESS = 'N' e SUBPGM-FAIL-CODE = '1').
    Consequência: A conta não é criada e é exibida a mensagem de que o número de cliente informado não existe.
    Parágrafo: CRE-ACC-DATA (CAD010)

13. Regra: Há um limite máximo de contas por cliente.
    Condição: A criação retornou falha com o código '8' (SUBPGM-SUCCESS = 'N' e SUBPGM-FAIL-CODE = '8'). A regra do limite, incluindo a quantidade máxima, está no programa CREACC e não neste código.
    Consequência: A conta não é criada e é exibida a mensagem de que a criação falhou por excesso de contas.
    Parágrafo: CRE-ACC-DATA (CAD010)

14. Regra: Tipos de conta não suportados pelo sistema de criação de contas são recusados. Ambiguidade: a lista de tipos aceitos na tela não garante que o CREACC suporte todos eles. A decisão final de suporte cabe ao CREACC.
    Condição: A criação retornou falha com o código 'A' (SUBPGM-SUCCESS = 'N' e SUBPGM-FAIL-CODE = 'A').
    Consequência: A conta não é criada e é exibida a mensagem de que a criação falhou porque o tipo de conta não é suportado.
    Parágrafo: CRE-ACC-DATA (CAD010)

15. Regra: Quando a criação da conta é bem-sucedida, o usuário é informado e vê os dados da nova conta.
    Condição: A criação não retornou falha (SUBPGM-SUCCESS diferente de 'N').
    Consequência: É exibida a mensagem de que a conta foi criada com sucesso, junto com os dados da conta (código da agência, número da conta, datas de abertura e de extrato, saldos).
    Parágrafo: CRE-ACC-DATA (CAD010)