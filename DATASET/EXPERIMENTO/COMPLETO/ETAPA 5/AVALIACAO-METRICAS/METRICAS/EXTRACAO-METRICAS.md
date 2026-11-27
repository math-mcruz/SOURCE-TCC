# Extração das métricas

Métricas das 72 execuções oficiais (2 modelos × 3 prompts × 4 programas × 3 rodadas), calculadas a partir da classificação dos itens de cada resposta contra o gabarito V12 (35 regras: DBCRFUN 9, XFRFUN 8, BNK1CRA 7, BNK1TFN 11). Extraído em 27/11/2026 da aba Resumo da planilha `EXECUCOES-CLASSIFICADAS`, que calcula tudo a partir da aba Itens (um item por linha, com a categoria dada pelo discente).

Arquivos desta etapa:

- `EXTRACAO-METRICAS.md`: este arquivo, com as tabelas e as fórmulas.
- `EXECUCOES-RESUMO.csv`: a aba Resumo exportada, com os mesmos números.

## Como as métricas são calculadas

Cada item de uma resposta recebe uma categoria, pelas regras de contagem (`regras_de_contagem.md`): Reformulação (R), Enriquecimento (E), Alucinação (A) ou Fora do escopo (F). Os itens Fora do escopo não entram em nenhuma conta.

| Métrica | Fórmula |
| --- | --- |
| Precisão | (R + E) ÷ (R + E + A) |
| Cobertura | regras do gabarito encontradas ÷ 35 |
| F1 | 2 × precisão × cobertura ÷ (precisão + cobertura) |
| Taxa de alucinação | A ÷ (R + E + A), o complemento da precisão |

- Uma rodada de um modelo com um prompt soma as 4 execuções (uma por programa). Cada regra do gabarito conta no máximo uma vez por execução, mesmo que vários itens a descrevam.
- O resultado final de cada modelo e prompt é a média das 3 rodadas, com o mínimo e o máximo.
- Por complexidade, a Reformulação herda o nível da regra do gabarito, e a Alucinação e o Enriquecimento recebem o nível do trecho de código a que se referem. As regras possíveis de um nível são as regras daquele nível vezes as execuções do seu programa (9 por programa e modelo).

## 1. Resultado final por modelo e prompt

Média das 3 rodadas, com o mínimo e o máximo entre parênteses.

| Modelo | Prompt | Precisão | Cobertura | F1 | Taxa de alucinação |
| --- | --- | --- | --- | --- | --- |
| GPT-6 Sol | A (zero-shot) | 98,0% (96,8% a 100,0%) | 80,0% (74,3% a 82,9%) | 88,0% (84,1% a 90,6%) | 2,0% (0,0% a 3,2%) |
| GPT-6 Sol | B (few-shot) | 96,9% (96,8% a 97,0%) | 81,0% (77,1% a 82,9%) | 88,2% (85,9% a 89,4%) | 3,1% (3,0% a 3,2%) |
| GPT-6 Sol | C (chain-of-thought) | 98,1% (97,1% a 100,0%) | 86,7% (85,7% a 88,6%) | 92,0% (91,1% a 93,9%) | 1,9% (0,0% a 2,9%) |
| Claude Sonnet | A (zero-shot) | 96,1% (93,9% a 97,1%) | 81,9% (80,0% a 82,9%) | 88,4% (86,4% a 89,4%) | 3,9% (2,9% a 6,1%) |
| Claude Sonnet | B (few-shot) | 94,5% (88,9% a 100,0%) | 81,0% (74,3% a 85,7%) | 87,0% (85,2% a 90,0%) | 5,5% (0,0% a 11,1%) |
| Claude Sonnet | C (chain-of-thought) | 98,1% (97,1% a 100,0%) | 82,9% (82,9% a 82,9%) | 89,8% (89,4% a 90,6%) | 1,9% (0,0% a 2,9%) |

## 2. Por rodada

Cada linha soma as 4 execuções da rodada (os 4 programas). Regras no gabarito: 35.

| Modelo | Prompt | Rodada | R | E | A | F | Regras encontradas | Precisão | Cobertura | F1 | Taxa de alucinação |
| --- | --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| GPT-6 Sol | A | 1 | 29 | 5 | 0 | 9 | 29 | 100,0% | 82,9% | 90,6% | 0,0% |
| GPT-6 Sol | A | 2 | 26 | 4 | 1 | 9 | 26 | 96,8% | 74,3% | 84,1% | 3,2% |
| GPT-6 Sol | A | 3 | 29 | 5 | 1 | 8 | 29 | 97,1% | 82,9% | 89,4% | 2,9% |
| GPT-6 Sol | B | 1 | 27 | 3 | 1 | 9 | 27 | 96,8% | 77,1% | 85,9% | 3,2% |
| GPT-6 Sol | B | 2 | 29 | 3 | 1 | 8 | 29 | 97,0% | 82,9% | 89,4% | 3,0% |
| GPT-6 Sol | B | 3 | 29 | 3 | 1 | 6 | 29 | 97,0% | 82,9% | 89,4% | 3,0% |
| GPT-6 Sol | C | 1 | 30 | 5 | 1 | 9 | 30 | 97,2% | 85,7% | 91,1% | 2,8% |
| GPT-6 Sol | C | 2 | 31 | 8 | 0 | 10 | 31 | 100,0% | 88,6% | 93,9% | 0,0% |
| GPT-6 Sol | C | 3 | 30 | 4 | 1 | 9 | 30 | 97,1% | 85,7% | 91,1% | 2,9% |
| Claude Sonnet | A | 1 | 29 | 5 | 1 | 8 | 29 | 97,1% | 82,9% | 89,4% | 2,9% |
| Claude Sonnet | A | 2 | 28 | 3 | 2 | 6 | 28 | 93,9% | 80,0% | 86,4% | 6,1% |
| Claude Sonnet | A | 3 | 29 | 5 | 1 | 7 | 29 | 97,1% | 82,9% | 89,4% | 2,9% |
| Claude Sonnet | B | 1 | 29 | 3 | 4 | 13 | 29 | 88,9% | 82,9% | 85,8% | 11,1% |
| Claude Sonnet | B | 2 | 32 | 4 | 2 | 20 | 30 | 94,7% | 85,7% | 90,0% | 5,3% |
| Claude Sonnet | B | 3 | 26 | 6 | 0 | 7 | 26 | 100,0% | 74,3% | 85,2% | 0,0% |
| Claude Sonnet | C | 1 | 29 | 5 | 1 | 7 | 29 | 97,1% | 82,9% | 89,4% | 2,9% |
| Claude Sonnet | C | 2 | 29 | 5 | 0 | 7 | 29 | 100,0% | 82,9% | 90,6% | 0,0% |
| Claude Sonnet | C | 3 | 29 | 5 | 1 | 7 | 29 | 97,1% | 82,9% | 89,4% | 2,9% |

Na rodada 2 do Claude com o prompt B, a Reformulação (32) passa das regras encontradas (30) porque a resposta do DBCRFUN separou duas regras com "ou" (DBCRFUN-008.1 e 009, "MORTGAGE ou LOAN") em dois itens cada (decisão 17 das regras de contagem): cada regra conta uma vez na cobertura, e cada item certo conta na precisão.

## 3. Por complexidade

Todos os prompts e rodadas somados (36 execuções por modelo). Nenhum item ficou sem nível.

| Modelo | Complexidade | Itens avaliados | Alucinações | Taxa de alucinação | Regras possíveis | Regras encontradas | Cobertura |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| GPT-6 Sol | Linear | 128 | 7 | 5,5% | 117 | 91 | 77,8% |
| GPT-6 Sol | Não linear | 179 | 0 | 0,0% | 198 | 169 | 85,4% |
| Claude Sonnet | Linear | 150 | 10 | 6,7% | 117 | 107 | 91,5% |
| Claude Sonnet | Não linear | 163 | 2 | 1,2% | 198 | 151 | 76,3% |

O gabarito tem 13 regras lineares e 22 não lineares.

## Piloto (fora dos resultados)

Teste piloto de 12/11/2026, com uma rodada de DBCRFUN e BNK1CRA (16 regras do gabarito V12). Serviu para ajustar as regras de contagem e não entra nos resultados.

| Modelo | Prompt | R | E | A | F | Regras encontradas | Precisão | Cobertura | F1 | Taxa de alucinação |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| GPT-6 Sol | A | 14 | 5 | 0 | 3 | 14 | 100,0% | 87,5% | 93,3% | 0,0% |
| GPT-6 Sol | B | 13 | 3 | 0 | 4 | 13 | 100,0% | 81,3% | 89,7% | 0,0% |
| GPT-6 Sol | C | 14 | 4 | 0 | 3 | 14 | 100,0% | 87,5% | 93,3% | 0,0% |
| Claude Sonnet | A | 14 | 3 | 1 | 3 | 14 | 94,4% | 87,5% | 90,8% | 5,6% |
| Claude Sonnet | B | 11 | 2 | 1 | 9 | 11 | 92,9% | 68,8% | 79,0% | 7,1% |
| Claude Sonnet | C | 14 | 3 | 0 | 2 | 14 | 100,0% | 87,5% | 93,3% | 0,0% |

## Conferência

Antes da extração, todas as linhas da aba Itens foram conferidas (categoria preenchida, regra do mesmo programa, complexidade, linhas divididas, numeração e tempos), e as métricas foram recalculadas de forma independente a partir da aba Itens. A recontagem bateu com a aba Resumo em todas as linhas.
