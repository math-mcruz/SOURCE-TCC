# Regras de contagem da comparação

## Para que serve

Define como cada item de uma resposta vira número na comparação com o gabarito. As regras ficaram fixas antes do piloto e foram ajustadas ao fim dele (seção "Ajustes após o piloto"), e só o discente classifica os itens.

## As quatro categorias

Cada item da resposta passa por três perguntas, sempre nesta ordem, e recebe uma única categoria. As quatro categorias estão na seção 4.6 do Método (Critérios de validação e correção); "fora do escopo" foi acrescentada por causa do comportamento dos modelos nos testes dos prompts.

Fluxo de classificação de um item (no documento original, um diagrama):

```text
1. É regra de negócio?        não → Fora do escopo
   sim ↓
2. Está certo pelo código?    não → Alucinação
   sim ↓
3. Está no gabarito, com a mesma condição e a mesma consequência?
                              sim → Reformulação
                              não → Enriquecimento
```

| Categoria | O que significa | Exemplo |
| --- | --- | --- |
| Fora do escopo | O item não é regra de negócio, então não entra na conta | "Se o acesso ao banco de dados falhar, o programa encerra com erro" (falha técnica) |
| Alucinação | O item diz algo que o código não faz | "Todo débito exige saldo suficiente", quando o código só exige saldo em pagamento (DBCRFUN-008) |
| Reformulação | O item diz o mesmo que uma regra do gabarito, com outras palavras | Gabarito: contas de origem e destino iguais, transferência recusada. Modelo: "não é permitido transferir para a própria conta" |
| Enriquecimento | O item está certo, mas a regra não está no gabarito | Uma regra verdadeira de um trecho sem comentário próprio, como o BNK1CRA-038 |

Como responder cada pergunta:

1. **É regra de negócio?** Usar os mesmos critérios do gabarito: falha técnica, gravação de registro (PROCTRAN), teclas, navegação e formato do campo digitado ficam fora.
2. **Está certo pelo código?** Abrir o trecho e conferir a condição e a consequência. A planilha do gabarito ajuda a achar o trecho. Vale o código, mesmo quando o comentário diz outra coisa.
3. **Está no gabarito?** Está quando o item tem a mesma condição e a mesma consequência de uma regra do gabarito, mesmo com outras palavras.

## As métricas

Todas saem das categorias. Itens fora do escopo não entram em nenhuma conta.

- **Precisão:** quanto do que o modelo disse está certo. (reformulação + enriquecimento) ÷ (reformulação + enriquecimento + alucinação).
- **Cobertura** (revocação, ou *recall*): quanto do gabarito o modelo encontrou. Regras do gabarito encontradas ÷ total de regras do gabarito.
- **F1:** junta precisão e cobertura num número só. 2 × precisão × cobertura ÷ (precisão + cobertura).
- **Taxa de alucinação:** alucinações ÷ (reformulação + enriquecimento + alucinação). É o complemento da precisão: precisão de 80% significa alucinação de 20%.

Exemplo: o DBCRFUN tem 9 regras no gabarito, e o modelo devolve 10 itens.

| Categoria | Itens |
| --- | --- |
| Reformulação (cada uma de uma regra diferente) | 6 |
| Enriquecimento | 1 |
| Alucinação | 1 |
| Fora do escopo | 2 |

- Precisão = (6 + 1) ÷ (6 + 1 + 1) = 87,5%
- Cobertura = 6 ÷ 9 = 66,7%
- F1 = 2 × 0,875 × 0,667 ÷ (0,875 + 0,667) = 75,7%
- Taxa de alucinação = 1 ÷ 8 = 12,5%

Para os Resultados, os itens dos 4 programas são somados em cada execução de um modelo com uma estratégia, e o número final é a média das 3 repetições.

Também se registram o mínimo e o máximo das 3 rodadas. Uma diferença entre os modelos só é tratada como relevante se for maior que essa variação (terceira pergunta de pesquisa).

## Complexidade

Responde à segunda pergunta de pesquisa: a taxa de alucinação muda com a complexidade da lógica? A hipótese fala em lógicas não lineares, como condições aninhadas e desvios de fluxo, então são dois níveis.

- **Linear:** a regra depende de um único teste (um IF ou um WHEN), sem GO TO no caminho.
- **Não linear:** a regra depende de dois ou mais testes combinados (IF dentro de IF, AND/OR, WHEN dentro de IF) ou o caminho passa por um GO TO.

Cada uma das regras do gabarito (35 na V12) recebe um nível, uma vez, antes do piloto, conferido no fim do piloto (ver "Ajustes após o piloto"). A reformulação herda o nível da regra; a alucinação e o enriquecimento recebem o nível do trecho de código a que se referem. Um item que inventa algo sem trecho fica sem nível.

Por nível, calculam-se a taxa de alucinação (alucinações ÷ itens avaliados daquele nível) e a cobertura (regras encontradas ÷ regras daquele nível).

## Antes de classificar

Os arquivos das respostas ficam como foram salvos. Antes de olhar os itens, dois passos:

1. **Recortar:** no prompt C, avaliar só a lista final. A seção "Análise" não entra na conta.
2. **Numerar** os itens na ordem da resposta. Cada item é classificado sozinho.

## Casos para anotar

Quando uma destas situações aparecer, anotar na coluna de observações da planilha e seguir o tratamento abaixo. O piloto confirma ou muda cada um; mudanças entram com data e motivo.

| Situação | O que fazer |
| --- | --- |
| Item sem condição ou sem consequência ("o programa valida a conta") | Não é uma regra completa: na planilha, categoria "Fora do escopo", com a observação "incompleto" |
| Mesma regra repetida na resposta | Conta uma vez: a cópia não ganha linha na planilha; anotar na observação do primeiro item |
| Um item cobre duas regras do gabarito | Vira duas linhas na planilha (ex.: 3a e 3b), uma para cada regra, e cada parte é classificada sozinha |
| Dois itens cobrem a mesma regra do gabarito | A regra conta uma vez na cobertura; cada item certo conta na precisão |
| Regra que aparece em dois lugares do código (o gabarito as separa) | Um item genérico cobre só uma; para cobrir as duas, o modelo precisa citar as duas |
| O modelo está certo e o gabarito está errado | Vale o código: corrigir o gabarito numa nova versão e anotar o motivo |
| Item que corresponde a uma regra retirada do gabarito por dúvida ou por defeito do código (BNK1CRA-040, BNK1CRA-042, BNK1TFN-047) | Na planilha, categoria "Fora do escopo", com a observação "regra retirada"; não entra nas métricas (decidida em 09/11/2026, mas ausente da versão deste arquivo registrada em 10/11/2026; incluída e ampliada para defeito do código em 14/11/2026) |

## Ajustes após o piloto (14/11/2026)

Estes ajustes saíram da classificação das 12 respostas do piloto (12 a 14/11/2026) e valem para todas as respostas oficiais. As quatro categorias, as três perguntas e as métricas não mudam: os ajustes esclarecem casos e corrigem o gabarito e a complexidade pelo critério já escrito.

Princípio usado em todos eles: a resposta à pergunta 1 segue o que o gabarito fez com coisas do mesmo tipo, incluindo as observações da aba Candidatos do GABARITO.xlsx.

### Gabarito V12

O gabarito passa da V11 (37 regras, 29 pares) para a V12: 35 regras, de 27 pares (DBCRFUN 9, XFRFUN 8, BNK1CRA 7, BNK1TFN 11).

| Mudança | Motivo |
| --- | --- |
| BNK1CRA-042 e BNK1TFN-047 retiradas (recusa de valor com mais de duas casas decimais) | Defeito do código: o teste não conta o dígito 9 depois do ponto. Executando o VA010 no GnuCOBOL 3.1.2, 12.345 é recusado, mas 1.239 é aceito. Mesmo critério da regra dos espaços embutidos (BNK1CRA-040), retirada na construção |
| Texto da DBCRFUN-018.2 corrigido: "crédito **e a solicitação não vier por pagamento (COMM-FACILTYPE diferente de 496)** → tipo CRE" | Com 496, o IF aninhado troca CRE por PCR (DBCRFUN-019). É o caso "modelo certo e gabarito errado": as respostas do piloto já traziam a condição completa |

Item que corresponda a uma regra retirada do gabarito por defeito do código ou por incerteza sobre o seu comportamento (040, 042, 047): **Fora do escopo**, com a observação "regra retirada", sem efeito nas métricas. Isso não vale para regras excluídas por não ter comentário próprio (ex.: valor igual a zero, BNK1CRA-043; tipo DEB, DBCRFUN-017): essas seguem as três perguntas e, se certas, são Enriquecimento.

### Decisões de classificação

Tomadas pelo discente entre 12 e 14/11/2026, ao classificar o piloto. A numeração é a do registro do piloto, onde estão os exemplos e o motivo de cada uma.

| # | Situação | O que fazer |
| --- | --- | --- |
| 1 | Item que diz que uma verificação não se aplica a um caso ("o débito que não é 496 não é barrado por falta de saldo") | É regra de negócio, como a DBCRFUN-007. Na pergunta 3, só é a mesma regra se cobrir os mesmos casos |
| 2 | Item que explicita partes do caminho até a regra ("valor negativo" dentro do bloco do débito) | Não muda a condição. Limite: se o item omite um desvio e existe caso que o contradiz, vale a decisão 13 |
| 3 | Quando dividir um item (3a, 3b) | Só quando ele afirma duas consequências. O teste de outra regra no caminho ou uma nota sem consequência própria não dividem |
| 4 | Regra em dois lugares do código | O item cobre o lugar que descreve (ex.: falha 4 no DBCRFUN, 008.1 e 009) |
| 5 | Condição que só depende de o sistema ter funcionado (SQLCODE, gravação na PROCTRAN), inclusive o lado de sucesso | Fora do escopo. O SQLCODE +100 que significa "a conta não existe" continua regra (DBCRFUN-005) |
| 6 | Tradução de valores ou citação do campo testado (MORTGAGE → financiamento imobiliário; "AMTI só com espaços") | Não é invenção. Na pergunta 2, conferir se os valores batem com o código |
| 7 | Tipo e descrição da transação na PROCTRAN (PDR, CRE, PCR, DEB) | É regra de negócio, como a DBCRFUN-018 e a 019. Fica fora só a parte técnica da gravação (INSERT, data, hora, referência) |
| 8 | Item que descreve o mesmo teste do gabarito com mais detalhe | Reformulação, se cobre os mesmos casos. Enriquecimento é regra que não está no gabarito, não "mais detalhe" |
| 9 | Outro lado de uma regra de fluxo ("dados inválidos não seguem para a atualização") | Enriquecimento, com a complexidade da regra do mesmo IF |
| 10 | Mensagem de erro genérico ou técnico devolvido pelo programa de fundo (falha 2, WHEN OTHER) | Fora do escopo, como falha técnica. O gabarito retirou essas regras na construção |
| 11 | Dúvida do classificador sobre o que o código faz | Não leva a Fora do escopo. Resolver na pergunta 2, lendo ou executando o trecho; sem solução, anotar e decidir no fim |
| 12 | Validação de formato de um campo digitado (sinal '+' ou '-', NOT NUMERIC) | Fora do escopo. Obrigatoriedade pergunta "o campo está vazio?" (regra); formato pergunta "está escrito do jeito errado?" (fora) |
| 13 | Item que generaliza um teste que o código só faz em parte dos casos | Alucinação. Teste: existe entrada em que a condição do item vale e a consequência não acontece? (ex.: "valor zero é recusado", quando "0" digitado é aceito) |
| 14 | Item que corresponde a uma regra retirada do gabarito (040, 042, 047) | Fora do escopo, observação "regra retirada" (ver Gabarito V12) |
| 15 | Item com o parágrafo errado ou sem parágrafo | Não muda a categoria; anotar "parágrafo citado errado". Se o parágrafo não bate com a condição, vale o lugar que a condição descreve |

### Complexidade

No fim do piloto, as 35 marcações de 10/11 foram conferidas com o critério da seção Complexidade. Em 27 o nível já seguia a condição da própria regra. As 8 abaixo tinham sido marcadas pelo trecho inteiro e foram corrigidas só aplicando o critério escrito; o critério não mudou.

| Regra | Antes | Depois | Por quê |
| --- | --- | --- | --- |
| DBCRFUN-018.1 | Linear | Não linear | Débito e 496 (IF dentro de IF) |
| DBCRFUN-018.2 | Linear | Não linear | Crédito e não 496 |
| DBCRFUN-019 | Linear | Não linear | Crédito e 496 |
| XFRFUN-043 | Linear | Não linear | IF SQLCODE NOT = 0 seguido de IF SQLCODE = +100, o mesmo código da DBCRFUN-005 e da XFRFUN-034 |
| XFRFUN-001 | Não linear | Linear | Um IF só (COMM-AMT <= ZERO) |
| BNK1CRA-018 | Não linear | Linear | Um IF só (ACCNOI = ZERO); o GO TO de antes é de saída |
| BNK1CRA-025.3 | Não linear | Linear | O ELSE de um IF só, como a BNK1TFN-026.4 |
| BNK1TFN-014 | Não linear | Linear | Um IF só (VALID-DATA), como a BNK1CRA-013 |

Testes aninhados sobre a mesma variável contam como dois testes. A contagem por variável foi considerada e não foi adotada. O nível das 35 regras fica em `complexidade_regras.csv`, no mesmo commit.
