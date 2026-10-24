1\. Regra: A abertura de uma conta bancária somente pode prosseguir quando o cliente informado for localizado e sua consulta for concluída com sucesso.\
Condição: Quando a consulta do cliente não retorna confirmação de sucesso (INQCUST-INQ-SUCCESS diferente de 'Y') ou não é concluída normalmente.\
Consequência: A abertura da conta é recusada, com indicador de insucesso e código de falha '1'.\
Parágrafo: P010.

2\. Regra: Um cliente pode possuir no máximo 10 contas bancárias antes de uma nova abertura.\
Condição: Quando o cliente já possui mais de 9 contas (NUMBER-OF-ACCOUNTS > 9).\
Consequência: A abertura de outra conta é recusada, com código de falha '8'.\
Parágrafo: P010.

3\. Regra: Somente contas dos tipos ISA, MORTGAGE, SAVING, CURRENT e LOAN podem ser abertas.\
Condição: Quando o tipo de conta informado começa com um dos valores permitidos: 'ISA', 'MORTGAGE', 'SAVING', 'CURRENT' ou 'LOAN', considerando os respectivos comprimentos verificados pelo programa.\
Consequência: O tipo de conta é aceito e a abertura pode prosseguir.\
Parágrafo: ATC010.

4\. Regra: A abertura de conta com tipo não permitido deve ser recusada.\
Condição: Quando o tipo de conta informado não começa com nenhum dos valores aceitos: 'ISA', 'MORTGAGE', 'SAVING', 'CURRENT' ou 'LOAN'.\
Consequência: A abertura é marcada como malsucedida, com código de falha 'A'.\
Parágrafo: ATC010.

5\. Regra: Cada nova conta recebe um número sequencial associado ao código da agência.\
Condição: Quando uma abertura de conta passa pelas verificações iniciais e o último número de conta da agência é recuperado.\
Consequência: O último número é incrementado em uma unidade e utilizado como número da nova conta.\
Parágrafo: FNA010.

6\. Regra: A quantidade total de contas registradas para a agência aumenta a cada abertura.\
Condição: Quando o processo de geração de uma nova conta alcança a atualização do contador de contas da agência.\
Consequência: O contador de contas da agência (ACCOUNT-COUNT) é incrementado em uma unidade, antes da confirmação da gravação da nova conta.\
Parágrafo: FNA010.

7\. Regra: A conta criada deve ficar vinculada ao cliente informado na solicitação.\
Condição: Quando uma nova conta é registrada.\
Consequência: O número do cliente informado (COMM-CUSTNO) é associado à nova conta.\
Parágrafo: WAD010.

8\. Regra: A nova conta deve ser registrada com o código da agência responsável pela abertura.\
Condição: Quando uma nova conta é registrada.\
Consequência: O código da agência (SORTCODE) é associado à conta.\
Parágrafo: WAD010.

9\. Regra: O cadastro da nova conta deve utilizar os oito últimos dígitos do número sequencial gerado.\
Condição: Quando o número da conta é preparado para o registro.\
Consequência: Os oito últimos dígitos do valor gerado são utilizados como número da conta bancária.\
Parágrafo: WAD010.

10\. Regra: A nova conta deve ser registrada com o tipo de conta aprovado na solicitação.\
Condição: Quando uma nova conta é registrada.\
Consequência: O tipo informado (COMM-ACC-TYPE) é atribuído à conta.\
Parágrafo: WAD010.

11\. Regra: A taxa de juros inicial da conta corresponde à taxa informada na solicitação.\
Condição: Quando uma nova conta é registrada.\
Consequência: A taxa de juros informada (COMM-INT-RT) é atribuída à conta, sem cálculo ou restrição adicional neste programa.\
Parágrafo: WAD010.

12\. Regra: O limite de cheque especial da conta corresponde ao limite informado na solicitação.\
Condição: Quando uma nova conta é registrada.\
Consequência: O limite informado (COMM-OVERDR-LIM) é atribuído à conta, sem validação de valor mínimo ou máximo neste programa.\
Parágrafo: WAD010.

13\. Regra: O saldo disponível inicial da conta corresponde ao valor informado na solicitação.\
Condição: Quando uma nova conta é registrada.\
Consequência: O saldo disponível informado (COMM-AVAIL-BAL) é atribuído à conta.\
Parágrafo: WAD010.

14\. Regra: O saldo efetivo inicial da conta corresponde ao valor informado na solicitação.\
Condição: Quando uma nova conta é registrada.\
Consequência: O saldo efetivo informado (COMM-ACT-BAL) é atribuído à conta.\
Parágrafo: WAD010.

15\. Regra: A data de abertura da conta corresponde à data corrente do processamento.\
Condição: Quando as datas da nova conta são calculadas.\
Consequência: A data corrente é definida como data de abertura da conta.\
Parágrafo: CD010.

16\. Regra: A data do último extrato da nova conta deve ser inicialmente igual à data de abertura.\
Condição: Quando as datas da nova conta são calculadas.\
Consequência: A data de abertura é atribuída à data do último extrato, mesmo que nenhum extrato anterior tenha sido efetivamente emitido.\
Parágrafo: CD010.

17\. Regra: O cálculo preliminar da data do próximo extrato acrescenta 30 dias quando a abertura ocorre em janeiro, março, maio, julho, agosto, outubro ou dezembro.\
Condição: Quando o mês da data corrente é 1, 3, 5, 7, 8, 10 ou 12.\
Consequência: São acrescentados 30 dias à data corrente para calcular a data preliminar do próximo extrato.\
Parágrafo: CD010.

18\. Regra: O cálculo preliminar da data do próximo extrato acrescenta 30 dias quando a abertura ocorre em abril, junho, setembro ou novembro.\
Condição: Quando o mês da data corrente é 4, 6, 9 ou 11.\
Consequência: São acrescentados 30 dias à data corrente para calcular a data preliminar do próximo extrato.\
Parágrafo: CD010.

19\. Regra: O cálculo preliminar da data do próximo extrato acrescenta 28 dias quando a abertura ocorre em fevereiro.\
Condição: Quando o mês da data corrente é fevereiro.\
Consequência: São acrescentados inicialmente 28 dias à data corrente para calcular a data preliminar do próximo extrato.\
Parágrafo: CD010.

20\. Regra: O cálculo preliminar do próximo extrato considera um dia adicional em fevereiro de anos bissextos não seculares.\
Condição: Quando a abertura ocorre em fevereiro de um ano divisível por 4, mas não divisível por 100.\
Consequência: É acrescentado um dia aos 28 dias inicialmente considerados, totalizando 29 dias.\
Parágrafo: CD010.

21\. Regra: O cálculo preliminar do próximo extrato considera um dia adicional em fevereiro de anos seculares divisíveis por 400.\
Condição: Quando a abertura ocorre em fevereiro de um ano divisível por 100 e também por 400.\
Consequência: É acrescentado um dia aos 28 dias inicialmente considerados, totalizando 29 dias.\
Parágrafo: CD010.

22\. Regra: O cálculo preliminar do próximo extrato considera apenas 28 dias em fevereiro de anos seculares não divisíveis por 400.\
Condição: Quando a abertura ocorre em fevereiro de um ano divisível por 100, mas não divisível por 400.\
Consequência: Não é acrescentado o dia adicional, permanecendo o cálculo de 28 dias.\
Parágrafo: CD010.

23\. Regra: A data do próximo extrato calculada conforme o mês de abertura é atribuída ao registro intermediário da conta.\
Condição: Quando o cálculo de datas da conta é concluído.\
Consequência: A data calculada, considerando 30 dias ou a duração de fevereiro conforme o ano, é atribuída ao campo ACCOUNT-NEXT-STMT-DATE. Esse valor não é o utilizado posteriormente na gravação definitiva da conta.\
Parágrafo: CD010.

24\. Regra: O primeiro próximo extrato da nova conta deve ser programado para 30 dias corridos após a abertura.\
Condição: Quando os dados da nova conta são preparados para gravação, após o cálculo preliminar das datas.\
Consequência: A data do próximo extrato que será efetivamente gravada (HV-ACCOUNT-NEXT-STMT) é definida como a data corrente acrescida de 30 dias, independentemente do mês ou de o ano ser bissexto.\
Parágrafo: WAD010.

25\. Regra: A abertura da conta deve registrar uma data de abertura, uma data de último extrato e uma data de próximo extrato.\
Condição: Quando a nova conta é gravada no cadastro bancário.\
Consequência: São armazenadas a data corrente como abertura, a mesma data como último extrato e a data corrente acrescida de 30 dias como próximo extrato.\
Parágrafo: WAD010.

26\. Regra: A conta somente é considerada aberta com sucesso após a gravação do seu cadastro e a execução do registro de processamento associado.\
Condição: Quando a gravação da conta é concluída e o programa prossegue até a confirmação da abertura.\
Consequência: O resultado da solicitação é marcado como sucesso (COMM-SUCCESS = 'Y'), e o código de falha é limpo.\
Parágrafo: WAD010.

27\. Regra: O resultado de uma abertura bem-sucedida deve disponibilizar o código da agência e o número da conta criada.\
Condição: Quando a abertura chega à etapa de confirmação.\
Consequência: O código da agência e o número da conta criada são devolvidos ao solicitante.\
Parágrafo: WAD010.

28\. Regra: O resultado de uma abertura bem-sucedida deve disponibilizar a data de abertura da conta.\
Condição: Quando a abertura chega à etapa de confirmação.\
Consequência: A data de abertura é devolvida ao solicitante no formato dia, mês e ano.\
Parágrafo: WAD010.

29\. Regra: O resultado de uma abertura bem-sucedida deve disponibilizar a data inicial do último extrato.\
Condição: Quando a abertura chega à etapa de confirmação.\
Consequência: A data do último extrato, inicialmente igual à data de abertura, é devolvida ao solicitante.\
Parágrafo: WAD010.

30\. Regra: O resultado de uma abertura bem-sucedida deve disponibilizar a data prevista para o próximo extrato.\
Condição: Quando a abertura chega à etapa de confirmação.\
Consequência: A data do próximo extrato, definida como 30 dias após a abertura, é devolvida ao solicitante.\
Parágrafo: WAD010.