1. Regra: A conta só é criada se todos os dados informados na tela passarem pelas validações.
   Condição: Os dados informados são válidos (VALID-DATA).
   Consequência: O programa chama a criação da conta (CREACC). Se algum dado for inválido, a criação não é solicitada e a tela volta com a mensagem de erro.
   Parágrafo: PROCESS-MAP (PM010)

2. Regra: O número do cliente é obrigatório.
   Condição: O campo número do cliente está vazio (tamanho zero ou só com sublinhados).
   Consequência: Rejeita os dados e exibe a mensagem pedindo um número de cliente de 10 dígitos. A conta não é criada.
   Parágrafo: EDIT-DATA (ED010)

3. Regra: O tipo de conta é obrigatório.
   Condição: O campo tipo de conta está vazio (tamanho zero ou só com sublinhados).
   Consequência: Rejeita os dados e exibe a mensagem de que o tipo deve ser ISA, CURRENT, LOAN, SAVING ou MORTGAGE. A conta não é criada.
   Parágrafo: EDIT-DATA (ED010)

4. Regra: O tipo de conta deve ser um dos valores aceitos: ISA, CURRENT, LOAN, SAVING ou MORTGAGE.
   Condição: O tipo de conta informado não corresponde a nenhum dos valores aceitos. O programa aceita as grafias em maiúsculas e em minúsculas e converte as minúsculas para maiúsculas. Grafias com letras maiúsculas e minúsculas misturadas, como "Isa", não estão na lista e seriam rejeitadas.
   Consequência: Rejeita os dados e exibe a mensagem com os tipos de conta aceitos. A conta não é criada.
   Parágrafo: EDIT-DATA (ED010)

5. Regra: A taxa de juros é obrigatória.
   Condição: O campo taxa de juros está vazio (tamanho zero, INTRTL = ZERO).
   Consequência: Rejeita os dados e exibe a mensagem pedindo uma taxa de juros numérica. A conta não é criada.
   Parágrafo: EDIT-DATA (ED010)

6. Regra: A taxa de juros aceita no máximo duas casas decimais.
   Condição: A taxa de juros informada tem mais de duas casas decimais. Comportamento ambíguo: a intenção é clara pela mensagem. Porém, a contagem interna dos dígitos após o ponto decimal parece sempre resultar em zero, então a rejeição possivelmente nunca ocorre na prática.
   Consequência: Rejeita os dados e exibe a mensagem de que só são suportadas até duas casas decimais. A conta não é criada.
   Parágrafo: EDIT-DATA (ED010)

7. Regra: A taxa de juros não pode ser negativa; zero e valores positivos são aceitos.
   Condição: O valor numérico da taxa de juros é menor que zero (INTRTI-COMP-1 < 0).
   Consequência: Rejeita os dados e exibe a mensagem pedindo uma taxa de juros igual a zero ou positiva. A conta não é criada.
   Parágrafo: EDIT-DATA (ED010)

8. Regra: A taxa de juros tem um limite máximo de 9999,99%.
   Condição: O valor da taxa de juros é maior que 9999,99. Comportamento ambíguo: a mensagem diz "menor que 9999.99%", mas o teste só rejeita valores estritamente maiores, então exatamente 9999,99 é aceito.
   Consequência: Rejeita os dados e exibe a mensagem pedindo uma taxa de juros menor que 9999,99%. A conta não é criada.
   Parágrafo: EDIT-DATA (ED010)

9. Regra: O limite de cheque especial é opcional e, quando não informado, assume o valor zero.
   Condição: O campo limite de cheque especial está vazio (tamanho menor que 1, só sublinhados ou só espaços).
   Consequência: O limite de cheque especial é considerado zero e a validação segue normalmente.
   Parágrafo: EDIT-DATA (ED010)

10. Regra: O número do cliente é exigido novamente na conferência final dos dados.
    Condição: O campo número do cliente está vazio (CUSTNOL < 1) na verificação final.
    Consequência: Rejeita os dados e exibe a mensagem "Missing expected data". A conta não é criada.
    Parágrafo: EDIT-DATA (ED010)

11. Regra: O tipo de conta é exigido novamente na conferência final dos dados.
    Condição: O campo tipo de conta está vazio (ACCTYPL < 1) na verificação final.
    Consequência: Rejeita os dados e exibe a mensagem "Missing expected data". A conta não é criada.
    Parágrafo: EDIT-DATA (ED010)

12. Regra: Não é possível abrir conta para um cliente que não existe.
    Condição: A criação da conta retorna falha com código '1' (cliente informado não existe).
    Consequência: A conta não é criada e exibe a mensagem de que o número de cliente informado não existe.
    Parágrafo: CRE-ACC-DATA (CAD010)

13. Regra: Há um limite de contas por cliente.
    Condição: A criação da conta retorna falha com código '8' (excesso de contas). O limite em si não está definido neste programa; ele é decidido pelo programa CREACC.
    Consequência: A conta não é criada e exibe a mensagem de que a criação falhou por excesso de contas.
    Parágrafo: CRE-ACC-DATA (CAD010)

14. Regra: Só podem ser criadas contas de tipos suportados pelo sistema.
    Condição: A criação da conta retorna falha com código 'A' (tipo de conta não suportado). Comportamento ambíguo: o programa já valida a lista de tipos na tela, e o critério de "suportado" pelo CREACC não é visível neste programa.
    Consequência: A conta não é criada e exibe a mensagem de que a criação falhou porque o tipo de conta não é suportado.
    Parágrafo: CRE-ACC-DATA (CAD010)

15. Regra: Quando a criação da conta é concluída com sucesso, o cliente é informado e os dados da conta são exibidos.
    Condição: O retorno da criação da conta não indica falha (SUBPGM-SUCCESS diferente de 'N').
    Consequência: Exibe a mensagem "The Account has been successfully created", junto com o código da agência, o número da conta, as datas de abertura e de extratos e os saldos.
    Parágrafo: CRE-ACC-DATA (CAD010)