# Regras de contagem da comparação&#32;

## Para que serve

Define como cada item de uma resposta vira número na comparação com o gabarito. As regras ficam fixas antes do piloto, e só o discente classifica os itens.

## As quatro categorias

Cada item da resposta passa por três perguntas, sempre nesta ordem, e recebe uma única categoria. Três categorias já estão na seção 4.4 do Método; a única nova é "fora do escopo".

&#91;embedded content: classificação de um item · 3 perguntas, 4 categorias\]

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
