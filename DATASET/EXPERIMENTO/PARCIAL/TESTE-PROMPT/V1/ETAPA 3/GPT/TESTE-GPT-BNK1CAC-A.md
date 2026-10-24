1\. Regra: O número do cliente é obrigatório para a abertura de uma conta.

- Condição: Quando o número do cliente não é informado ou permanece com o preenchimento padrão de sublinhados.
- Consequência: A solicitação é rejeitada e é apresentada uma mensagem solicitando o número do cliente com 10 dígitos.
- Parágrafo: ED010.

2\. Regra: O tipo de conta é obrigatório para a abertura de uma conta.

- Condição: Quando o tipo de conta não é informado ou permanece com o preenchimento padrão de sublinhados.
- Consequência: A solicitação é rejeitada e é apresentada uma mensagem informando os tipos de conta permitidos.
- Parágrafo: ED010.

3\. Regra: O banco aceita cinco tipos de conta: ISA, CURRENT, LOAN, SAVING e MORTGAGE.

- Condição: Quando o tipo de conta informado não corresponde a nenhum desses cinco valores aceitos, incluindo as variações de preenchimento e letras maiúsculas ou minúsculas previstas no programa.
- Consequência: A solicitação é rejeitada e é apresentada uma mensagem informando os tipos de conta permitidos.
- Parágrafo: ED010.

4\. Regra: O tipo de conta informado em letras minúsculas é aceito e padronizado em letras maiúsculas.

- Condição: Quando o tipo de conta informado corresponde a isa, current, loan, saving ou mortgage, nas formas reconhecidas pelo programa.
- Consequência: O tipo de conta é convertido para a representação padronizada em letras maiúsculas.
- Parágrafo: ED010.

5\. Regra: A taxa de juros é obrigatória para a abertura de uma conta.

- Condição: Quando o campo da taxa de juros não é preenchido (INTRTL = ZERO).
- Consequência: A solicitação é rejeitada e é apresentada uma mensagem solicitando a taxa de juros.
- Parágrafo: ED010.

6\. Regra: A taxa de juros não pode ser negativa.

- Condição: Quando a taxa de juros informada é inferior a zero.
- Consequência: A solicitação é rejeitada e é apresentada uma mensagem informando que a taxa deve ser zero ou positiva.
- Parágrafo: ED010.

7\. Regra: A taxa de juros não pode ultrapassar 9999,99%.

- Condição: Quando a taxa de juros informada é superior a 9999,99.
- Consequência: A solicitação é rejeitada e é apresentada uma mensagem solicitando uma taxa inferior a 9999,99%, embora o teste do programa aceite o valor exatamente igual a 9999,99.
- Parágrafo: ED010.

8\. Regra: O limite de cheque especial é considerado zero quando não é informado.

- Condição: Quando o campo de limite de cheque especial está vazio, contém apenas espaços ou permanece com o preenchimento padrão de sublinhados.
- Consequência: O limite de cheque especial é definido como zero.
- Parágrafo: ED010.

9\. Regra: O número do cliente deve estar preenchido para que a solicitação de abertura de conta prossiga.

- Condição: Quando, na verificação final dos dados, o comprimento informado para o número do cliente é inferior a um.
- Consequência: A solicitação é rejeitada e é apresentada a mensagem de ausência de dados obrigatórios.
- Parágrafo: ED010.

10\. Regra: O tipo de conta deve estar preenchido para que a solicitação de abertura de conta prossiga.

- Condição: Quando, na verificação final dos dados, o comprimento informado para o tipo de conta é inferior a um.
- Consequência: A solicitação é rejeitada e é apresentada a mensagem de ausência de dados obrigatórios.
- Parágrafo: ED010.

11\. Regra: A abertura de conta somente é solicitada quando os dados passam pelas validações.

- Condição: Quando nenhuma validação identifica impedimento à solicitação.
- Consequência: A solicitação de criação da conta é encaminhada para processamento.
- Parágrafo: PM010.

12\. Regra: A abertura de conta é solicitada para o número de cliente informado.

- Condição: Quando a solicitação passa pelas validações e é encaminhada para criação.
- Consequência: O número do cliente informado é utilizado na solicitação de abertura da conta.
- Parágrafo: CAD010.

13\. Regra: A conta é solicitada com o tipo de conta informado e validado.

- Condição: Quando a solicitação passa pelas validações e é encaminhada para criação.
- Consequência: O tipo de conta validado é utilizado na solicitação de abertura.
- Parágrafo: CAD010.

14\. Regra: A conta é solicitada com a taxa de juros informada.

- Condição: Quando a solicitação passa pelas validações e é encaminhada para criação.
- Consequência: A taxa de juros informada é utilizada na solicitação de abertura da conta.
- Parágrafo: CAD010.

15\. Regra: A conta é solicitada com o limite de cheque especial informado ou com valor zero quando não preenchido.

- Condição: Quando a solicitação passa pelas validações e é encaminhada para criação.
- Consequência: O limite de cheque especial é utilizado na solicitação de abertura da conta.
- Parágrafo: CAD010.

16\. Regra: A abertura de conta é solicitada com saldo disponível inicial igual a zero.

- Condição: Quando os dados da solicitação de abertura são preparados para criação da conta.
- Consequência: O saldo disponível enviado para criação da conta é zero.
- Parágrafo: CAD010.

17\. Regra: A abertura de conta é solicitada com saldo efetivo inicial igual a zero.

- Condição: Quando os dados da solicitação de abertura são preparados para criação da conta.
- Consequência: O saldo efetivo enviado para criação da conta é zero.
- Parágrafo: CAD010.

18\. Regra: A abertura de conta é solicitada sem uma data de abertura previamente definida.

- Condição: Quando os dados da solicitação de abertura são preparados.
- Consequência: A data de abertura é enviada com valor zero; a definição da data efetiva não está demonstrada neste programa.
- Parágrafo: CAD010.

19\. Regra: A abertura de conta é solicitada sem uma data de último extrato previamente definida.

- Condição: Quando os dados da solicitação de abertura são preparados.
- Consequência: A data do último extrato é enviada com valor zero.
- Parágrafo: CAD010.

20\. Regra: A abertura de conta é solicitada sem uma data de próximo extrato previamente definida.

- Condição: Quando os dados da solicitação de abertura são preparados.
- Consequência: A data do próximo extrato é enviada com valor zero.
- Parágrafo: CAD010.

21\. Regra: Não é possível concluir a abertura de uma conta para um número de cliente inexistente.

- Condição: Quando o processamento da criação retorna insucesso com o código 1.
- Consequência: A conta não é criada e é apresentada uma mensagem informando que o número do cliente não existe.
- Parágrafo: CAD010.

22\. Regra: A abertura de conta não é concluída quando os dados do cliente não podem ser acessados.

- Condição: Quando o processamento da criação retorna insucesso com o código 2.
- Consequência: A conta não é criada e é apresentada uma mensagem informando que os dados do cliente não podem ser acessados.
- Parágrafo: CAD010.

23\. Regra: A abertura de conta pode ser recusada quando o limite de quantidade de contas é atingido.

- Condição: Quando o processamento da criação retorna insucesso com o código 8.
- Consequência: A conta não é criada e é apresentada uma mensagem informando que há contas em quantidade excessiva; o limite numérico não é definido neste programa.
- Parágrafo: CAD010.

24\. Regra: A abertura de conta não é concluída quando o tipo de conta não é suportado pelo processamento de criação.

- Condição: Quando o processamento da criação retorna insucesso com o código A.
- Consequência: A conta não é criada e é apresentada uma mensagem informando que o tipo de conta não é suportado.
- Parágrafo: CAD010.

25\. Regra: A abertura de conta não é confirmada quando o processamento retorna um motivo de insucesso não reconhecido.

- Condição: Quando o processamento da criação indica insucesso e o código de motivo não corresponde a nenhum dos códigos tratados especificamente.
- Consequência: É apresentada uma mensagem informando que a conta não foi criada.
- Parágrafo: CAD010.

26\. Regra: A criação bem-sucedida de uma conta é confirmada ao usuário.

- Condição: Quando o processamento da criação retorna um indicador de sucesso diferente de N.
- Consequência: É apresentada uma mensagem confirmando que a conta foi criada com sucesso.
- Parágrafo: CAD010.

27\. Regra: O banco informa os dados de identificação da conta após sua criação bem-sucedida.

- Condição: Quando o processamento da criação retorna sucesso.
- Consequência: São apresentados o código da agência bancária (sort code) e o número da conta retornados pelo processamento de criação.
- Parágrafo: CAD010.

28\. Regra: A data de abertura da conta é apresentada após a criação bem-sucedida.

- Condição: Quando o processamento da criação retorna sucesso.
- Consequência: A data de abertura retornada pelo processamento é apresentada ao usuário em dia, mês e ano.
- Parágrafo: CAD010.

29\. Regra: A data do próximo extrato é apresentada após a criação bem-sucedida da conta.

- Condição: Quando o processamento da criação retorna sucesso.
- Consequência: A data do próximo extrato retornada pelo processamento é apresentada em dia, mês e ano.
- Parágrafo: CAD010.

30\. Regra: A data do último extrato é apresentada após a criação bem-sucedida da conta.

- Condição: Quando o processamento da criação retorna sucesso.
- Consequência: A data do último extrato retornada pelo processamento é apresentada em dia, mês e ano.
- Parágrafo: CAD010.

31\. Regra: O saldo disponível da nova conta é apresentado após sua criação bem-sucedida.

- Condição: Quando o processamento da criação retorna sucesso.
- Consequência: O saldo disponível retornado pelo processamento é apresentado ao usuário.
- Parágrafo: CAD010.

32\. Regra: O saldo efetivo da nova conta é apresentado após sua criação bem-sucedida.

- Condição: Quando o processamento da criação retorna sucesso.
- Consequência: O saldo efetivo retornado pelo processamento é apresentado ao usuário.
- Parágrafo: CAD010.

33\. Regra: Os dados do cliente e as condições da conta solicitada são apresentados após o processamento da abertura.

- Condição: Quando o processamento de criação retorna, independentemente do indicador de sucesso.
- Consequência: São apresentados o número do cliente, o tipo de conta, a taxa de juros e o limite de cheque especial retornados pelo processamento.
- Parágrafo: CAD010.