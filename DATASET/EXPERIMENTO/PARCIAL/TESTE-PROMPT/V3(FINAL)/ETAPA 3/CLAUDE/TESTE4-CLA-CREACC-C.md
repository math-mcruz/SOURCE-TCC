# Análise

## 1. Parágrafos e fluxo principal

O programa CREACC cria uma conta bancária para um cliente existente. Seções e parágrafos:

- **PREMIERE / P010**: fluxo principal.
- **CUSTOMER-ACCOUNT-COUNT (CAC010)**: consulta, via programa INQACCCU, quantas contas o cliente possui.
- **ACCOUNT-TYPE-CHECK (ATC010)**: valida o tipo de conta.
- **ENQ-NAMED-COUNTER (ENC010)** e **DEQ-NAMED-COUNTER (DNC010)**: reservam e liberam o contador de número de conta.
- **FIND-NEXT-ACCOUNT (FNA010)**: obtém e incrementa o próximo número de conta e o contador de contas na tabela CONTROL.
- **WRITE-ACCOUNT-DB2 (WAD010)**: calcula datas, grava a conta e chama a gravação do registro de movimento.
- **CALCULATE-DATES (CD010)**: calcula datas de abertura e de extrato. Não é executado no fluxo (ver observação abaixo).
- **WRITE-PROCTRAN / WRITE-PROCTRAN-DB2**: gravam o registro técnico de movimento (tipo 'OCA', valor zero).
- **POPULATE-TIME-DATE2**: obtém data e hora para registro de falhas.
- **GET-ME-OUT-OF-HERE**: encerra o programa.

Fluxo principal: (1) consultar o cliente (INQCUST); (2) contar as contas do cliente; (3) verificar o limite de contas; (4) validar o tipo de conta; (5) reservar o contador; (6) obter o próximo número de conta; (7) gravar a conta e o registro de movimento; (8) liberar o contador e devolver os dados.

## 2 e 3. Estruturas de decisão e classificação

| # | Local | Estrutura | Classificação |
|---|---|---|---|
| 1 | P010 | IF EIBRESP ≠ NORMAL OR INQCUST-INQ-SUCCESS ≠ 'Y' | Negócio (cliente inexistente ou não validado) com componente técnico (EIBRESP) |
| 2 | P010 | IF WS-CICS-RESP ≠ NORMAL após contagem | Infraestrutura |
| 3 | P010 | IF COMM-SUCCESS do INQACCCU = 'N' | Infraestrutura (falha na contagem) |
| 4 | P010 | IF NUMBER-OF-ACCOUNTS > 9 | Negócio |
| 5 | ACCOUNT-TYPE-CHECK | EVALUATE TRUE sobre o tipo de conta | Negócio |
| 6 | P010 | IF COMM-SUCCESS = 'N' após o tipo | Navegação técnica: apenas propaga o resultado da decisão 5; é um teste intermediário |
| 7 | ENQ / DEQ | IF WS-CICS-RESP ≠ NORMAL | Infraestrutura (concorrência) |
| 8 | FIND-NEXT-ACCOUNT | IF SQLCODE ≠ 0 (4 ocorrências) | Infraestrutura |
| 9 | WRITE-ACCOUNT-DB2 | IF SQLCODE ≠ 0 após INSERT | Infraestrutura |
| 10 | WRITE-PROCTRAN-DB2 | IF SQLCODE ≠ 0 | Infraestrutura |
| 11 | CALCULATE-DATES | EVALUATE do mês e testes de ano bissexto | Negócio em tese, mas o parágrafo não é executado (ver abaixo) |

## 4. Condição e consequência das estruturas de negócio

- **Decisão 1**: se a consulta ao cliente falha ou não retorna sucesso, a criação é recusada com código de falha '1'. O teste mistura o código técnico de resposta e o indicador de sucesso; o código não distingue as causas.
- **Decisão 4**: se o cliente já tem mais de 9 contas, a criação é recusada com código de falha '8'.
- **Decisão 5**: se o tipo de conta começa com ISA, MORTGAGE, SAVING, CURRENT ou LOAN, a criação segue. Qualquer outro valor leva à recusa com código de falha 'A'.
- **Decisão 11 (observação de fidelidade)**: CALCULATE-DATES não é chamado em nenhum ponto do fluxo. A rotina WRITE-ACCOUNT-DB2 faz `PERFORM CALCULATE-DATES`, então ela é de fato executada. Nela o EVALUATE soma 30 dias para os meses de 31 e de 30 dias e 28 dias para fevereiro (mais 1 dia em ano bissexto), mas o resultado vai para campos do ACCOUNT que não são os gravados. Logo depois, WRITE-ACCOUNT-DB2 recalcula a data do próximo extrato somando sempre 30 dias, sem testar o mês. Assim, a data efetivamente gravada é abertura + 30 dias. As regras de mês e de ano bissexto não afetam o valor gravado e não são listadas como regras.

Observações adicionais: o teste da decisão 5 compara apenas o início do campo (por exemplo, 'ISA' nos 3 primeiros caracteres), portanto valores que apenas começam com essas letras são aceitos. O limite de 9 contas é testado antes da validação do tipo de conta.

# Regras de negócio

1. Regra: Não é possível abrir conta para um cliente que não seja localizado ou validado na consulta de clientes (INQCUST).
   Condição: A consulta do cliente retorna erro ou o indicador de sucesso da consulta é diferente de 'Y'.
   Consequência: A criação da conta é recusada, com indicador de falha e código de falha '1'.
   Parágrafo: PREMIERE (P010)

2. Regra: Um cliente não pode ter mais de 9 contas.
   Condição: O número de contas já existentes do cliente é maior que 9 (NUMBER-OF-ACCOUNTS > 9).
   Consequência: A criação da conta é recusada, com código de falha '8'.
   Parágrafo: PREMIERE (P010)

3. Regra: Só são aceitos os tipos de conta ISA, MORTGAGE, SAVING, CURRENT e LOAN.
   Condição: O tipo de conta informado (COMM-ACC-TYPE) começa com ISA, MORTGAGE, SAVING, CURRENT ou LOAN (comparação feita só com o início do campo).
   Consequência: O tipo é aceito e a criação da conta prossegue.
   Parágrafo: ACCOUNT-TYPE-CHECK (ATC010)

4. Regra: Tipos de conta fora da lista aceita são recusados.
   Condição: O tipo de conta informado não começa com nenhum dos valores aceitos (ISA, MORTGAGE, SAVING, CURRENT, LOAN).
   Consequência: A criação da conta é recusada, com código de falha 'A'.
   Parágrafo: ACCOUNT-TYPE-CHECK (ATC010)