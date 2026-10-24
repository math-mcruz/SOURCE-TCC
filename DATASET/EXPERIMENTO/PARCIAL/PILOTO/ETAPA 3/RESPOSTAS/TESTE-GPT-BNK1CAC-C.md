## Análise

1\. Parágrafos e fluxo principal do programa

O programa `BNK1CAC` realiza a solicitação de criação de contas bancárias.

O fluxo principal é composto por:

- A010: Inicializa a transação e direciona o processamento conforme a interação do usuário.
- PM010: Recebe os dados, executa as validações e, se forem válidos, solicita a criação da conta.
- RM010: Recebe os dados informados.
- ED010: Valida o número do cliente, o tipo de conta, a taxa de juros e o limite de cheque especial.
- CAD010: Envia os dados ao programa `CREACC`, interpreta o resultado e apresenta as informações da conta criada.
- SM010, STM010, ATT010 e PTD010: Executam funções de interface e infraestrutura.

2\. Estruturas de decisão e classificação

| Parágrafo | Decisão                                                         | Classificação                                |
| --------- | --------------------------------------------------------------- | -------------------------------------------- |
| A010      | Verificação de início da transação e teclas utilizadas          | Interface                                    |
| A010      | Verificação de existência de dados de comunicação               | Infraestrutura                               |
| A010      | Verificação de retorno CICS                                     | Infraestrutura                               |
| PM010     | Verificação de validade dos dados antes de solicitar a criação  | Negócio                                      |
| RM010     | Verificação de retorno da recepção da tela                      | Infraestrutura                               |
| ED010     | Número do cliente não informado                                 | Negócio                                      |
| ED010     | Número do cliente não numérico                                  | Interface — formato                          |
| ED010     | Tipo de conta não informado                                     | Negócio                                      |
| ED010     | Normalização e verificação dos tipos de conta aceitos           | Negócio                                      |
| ED010     | Taxa de juros não informada                                     | Negócio                                      |
| ED010     | Verificações de caracteres e ponto decimal da taxa              | Interface — formato                          |
| ED010     | Taxa de juros negativa                                          | Negócio                                      |
| ED010     | Taxa de juros superior a 9999,99                                | Negócio                                      |
| ED010     | Verificações de formato do limite de cheque especial            | Interface — formato                          |
| ED010     | Limite de cheque especial não informado                         | Negócio                                      |
| ED010     | Verificação final de número do cliente ou tipo de conta ausente | Negócio                                      |
| CAD010    | Preparação dos valores iniciais da conta                        | Negócio                                      |
| CAD010    | Falha técnica na chamada ao programa CREACC                     | Infraestrutura                               |
| CAD010    | Resultado de insucesso da criação                               | Negócio ou infraestrutura, conforme o motivo |
| CAD010    | Código 1: cliente inexistente                                   | Negócio                                      |
| CAD010    | Código 2: impossibilidade de acessar os dados do cliente        | Infraestrutura                               |
| CAD010    | Códigos 3 a 7: falhas técnicas de criação                       | Infraestrutura                               |
| CAD010    | Código 8: excesso de contas                                     | Negócio                                      |
| CAD010    | Código 9: impossibilidade de contar contas                      | Infraestrutura                               |
| CAD010    | Código A: tipo de conta não suportado                           | Negócio                                      |
| CAD010    | Outros códigos de insucesso                                     | Negócio — motivo não especificado            |
| CAD010    | Resultado de sucesso da criação                                 | Negócio                                      |
| SM010     | Escolha da modalidade de exibição e verificações CICS           | Interface e infraestrutura                   |
| STM010    | Verificação do envio da mensagem de encerramento                | Infraestrutura                               |

3\. Condições e consequências identificadas

As decisões de negócio determinam a obrigatoriedade dos dados, os tipos de conta aceitos, os limites da taxa de juros, o valor padrão do limite de cheque especial, a autorização para solicitar a criação e o tratamento dos resultados dessa solicitação.

As verificações de formato, navegação, concorrência, códigos técnicos de retorno e registros de falhas são excluídas das regras finais.

4\. Limites da análise

O programa `CREACC` é chamado, mas seu código não foi fornecido. Portanto, os motivos de rejeição comunicados por esse programa podem ser documentados, mas seus critérios internos não podem ser detalhados.

A mensagem associada ao limite de juros menciona um valor inferior a 9999,99%, mas a condição implementada rejeita apenas valores superiores a 9999,99. A regra considera o teste efetivamente realizado.

## Regras de negócio

1\. Regra: A criação de uma conta bancária somente pode ser solicitada quando os dados informados forem considerados válidos.

Condição: Quando todas as validações dos dados forem concluídas sem identificar impedimentos.

Consequência: O sistema solicita a criação da conta bancária.

Parágrafo: PM010.

2\. Regra: O número do cliente é obrigatório para solicitar a criação de uma conta bancária.

Condição: Quando o número do cliente não for informado ou permanecer com o preenchimento padrão de sublinhados.

Consequência: O sistema rejeita a solicitação e solicita o preenchimento do número do cliente.

Parágrafo: ED010.

3\. Regra: O tipo de conta é obrigatório para solicitar a criação de uma conta bancária.

Condição: Quando o tipo de conta não for informado ou permanecer com o preenchimento padrão de sublinhados.

Consequência: O sistema rejeita a solicitação e informa os tipos de conta permitidos.

Parágrafo: ED010.

4\. Regra: Os tipos de conta aceitos na solicitação são ISA, CURRENT, LOAN, SAVING e MORTGAGE.

Condição: Quando o tipo de conta informado não corresponder a um dos cinco tipos reconhecidos pelo programa.

Consequência: O sistema rejeita a solicitação e informa os tipos de conta permitidos.

Parágrafo: ED010.

5\. Regra: O tipo de conta informado em letras minúsculas é convertido para sua representação em letras maiúsculas.

Condição: Quando o tipo de conta corresponder a uma das opções aceitas em letras minúsculas, com os preenchimentos previstos pelo programa.

Consequência: O sistema utiliza a representação padronizada em letras maiúsculas na solicitação de criação da conta.

Parágrafo: ED010.

6\. Regra: A taxa de juros é obrigatória para solicitar a criação de uma conta bancária.

Condição: Quando a taxa de juros não for informada.

Consequência: O sistema rejeita a solicitação e exige o preenchimento da taxa de juros.

Parágrafo: ED010.

7\. Regra: A taxa de juros de uma conta bancária não pode ser negativa.

Condição: Quando a taxa de juros informada for inferior a zero.

Consequência: O sistema rejeita a solicitação e exige uma taxa de juros igual ou superior a zero.

Parágrafo: ED010.

8\. Regra: A taxa de juros de uma conta bancária não pode ultrapassar 9999,99%.

Condição: Quando a taxa de juros informada for superior a 9999,99.

Consequência: O sistema rejeita a solicitação de criação da conta.

Parágrafo: ED010.

9\. Regra: O limite de cheque especial é considerado zero quando não for informado.

Condição: Quando o limite de cheque especial estiver vazio, contiver somente espaços ou apresentar o preenchimento padrão de sublinhados.

Consequência: O sistema assume o valor zero como limite de cheque especial da conta.

Parágrafo: ED010.

10\. Regra: A criação de uma conta exige a presença do número do cliente na validação final dos dados.

Condição: Quando o número do cliente permanecer não informado na verificação final.

Consequência: O sistema rejeita a solicitação e informa que existem dados obrigatórios ausentes.

Parágrafo: ED010.

11\. Regra: A criação de uma conta exige a presença do tipo de conta na validação final dos dados.

Condição: Quando o tipo de conta permanecer não informado na verificação final.

Consequência: O sistema rejeita a solicitação e informa que existem dados obrigatórios ausentes.

Parágrafo: ED010.

12\. Regra: Uma nova conta é solicitada com saldo disponível inicial igual a zero.

Condição: Quando o sistema prepara os dados para a criação de uma conta.

Consequência: O saldo disponível enviado para a criação é definido como zero.

Parágrafo: CAD010.

13\. Regra: Uma nova conta é solicitada com saldo efetivo inicial igual a zero.

Condição: Quando o sistema prepara os dados para a criação de uma conta.

Consequência: O saldo efetivo enviado para a criação é definido como zero.

Parágrafo: CAD010.

14\. Regra: A data de abertura da conta é inicialmente enviada sem um valor definido.

Condição: Quando o sistema prepara os dados para a criação de uma conta.

Consequência: O programa envia zero no campo de data de abertura, ficando a determinação da data efetiva dependente do processamento de criação da conta.

Parágrafo: CAD010.

15\. Regra: A data do último extrato de uma nova conta é inicialmente enviada sem um valor definido.

Condição: Quando o sistema prepara os dados para a criação de uma conta.

Consequência: O programa envia zero no campo da data do último extrato.

Parágrafo: CAD010.

16\. Regra: A data do próximo extrato de uma nova conta é inicialmente enviada sem um valor definido.

Condição: Quando o sistema prepara os dados para a criação de uma conta.

Consequência: O programa envia zero no campo da data do próximo extrato.

Parágrafo: CAD010.

17\. Regra: A criação de uma conta é rejeitada quando o número do cliente informado não existe.

Condição: Quando o processamento de criação retorna o código de insucesso `1`.

Consequência: O sistema informa que o número do cliente fornecido não existe e que a criação não foi concluída.

Parágrafo: CAD010.

18\. Regra: A criação de uma conta é rejeitada quando o limite de quantidade de contas é excedido.

Condição: Quando o processamento de criação retorna o código de insucesso `8`.

Consequência: O sistema informa que a conta não foi criada devido ao excesso de contas. O limite numérico aplicável não está definido no programa fornecido.

Parágrafo: CAD010.

19\. Regra: A criação de uma conta é rejeitada quando o tipo de conta não é suportado pelo processamento responsável pela criação.

Condição: Quando o processamento de criação retorna o código de insucesso `A`.

Consequência: O sistema informa que a conta não foi criada porque seu tipo não é suportado.

Parágrafo: CAD010.

20\. Regra: Uma solicitação de criação de conta pode ser rejeitada por motivo não especificado.

Condição: Quando o processamento de criação indica insucesso com um código diferente dos códigos explicitamente tratados.

Consequência: O sistema informa que a conta não foi criada, sem apresentar um motivo específico.

Parágrafo: CAD010.

21\. Regra: A criação de uma conta bancária é confirmada quando o processamento responsável informa sucesso.

Condição: Quando o indicador de sucesso retornado pelo processamento de criação é diferente de `N`.

Consequência: O sistema informa que a conta foi criada com sucesso.

Parágrafo: CAD010.

22\. Regra: O código bancário e o número da nova conta são disponibilizados após a confirmação de criação.

Condição: Quando o processamento de criação informa sucesso.

Consequência: O sistema apresenta o código bancário e o número da conta retornados pelo processamento de criação.

Parágrafo: CAD010.

23\. Regra: A data de abertura da nova conta é apresentada após a confirmação de criação.

Condição: Quando o processamento de criação informa sucesso.

Consequência: O sistema apresenta a data de abertura retornada pelo processamento de criação.

Parágrafo: CAD010.

24\. Regra: A data do próximo extrato é apresentada após a confirmação de criação da conta.

Condição: Quando o processamento de criação informa sucesso.

Consequência: O sistema apresenta a data do próximo extrato retornada pelo processamento de criação.

Parágrafo: CAD010.

25\. Regra: A data do último extrato é apresentada após a confirmação de criação da conta.

Condição: Quando o processamento de criação informa sucesso.

Consequência: O sistema apresenta a data do último extrato retornada pelo processamento de criação.

Parágrafo: CAD010.

26\. Regra: O saldo disponível da nova conta é apresentado após a confirmação de criação.

Condição: Quando o processamento de criação informa sucesso.

Consequência: O sistema apresenta o saldo disponível retornado pelo processamento de criação.

Parágrafo: CAD010.

27\. Regra: O saldo efetivo da nova conta é apresentado após a confirmação de criação.

Condição: Quando o processamento de criação informa sucesso.

Consequência: O sistema apresenta o saldo efetivo retornado pelo processamento de criação.

Parágrafo: CAD010.