# Construção do gabarito (ground truth) — TCC

Scripts usados para construir o gabarito de regras de negócio a partir de quatro
programas COBOL da CICS Bank Sample Application (CBSA). O gabarito é a referência
contra a qual a documentação gerada pelos LLMs (Claude Sonnet 5.5 e GPT-5.5) será
comparada, conforme o Capítulo 4 da monografia.

## Base de dados

- Repositório de origem: `ijmitch/cics-banking-sample-application-cbsa`,
  commit `e22475691524ef72a92ee77f7040233e098ab1b9`, pasta `src/base`.
- Programas selecionados (seleção provisória, a validar com o orientador):
  `DBCRFUN`, `XFRFUN`, `BNK1CRA`, `BNK1TFN`.
- Pasta de origem (cópia sem edições do original) usada na extração: `EXPERIMENTO\COMPLETO\cobol_src`. 
- SHA-256 dos fontes processados (também registrados na aba Legenda da planilha):

| Arquivo | SHA-256 |
|---|---|
| DBCRFUN.cbl | `632917d17138331d540b05823c840eb204675ddb79ac9eac0d8d6d847982056f` |
| XFRFUN.cbl | `9c642ade5e1211b77b7c264eaea18f8cf88cb035af32ed55c66278482e51013e` |
| BNK1CRA.cbl | `061d73de30c1a3635db44b1f9dc8faebc71ea8e024fee48db499ad1ecda4ab97` |
| BNK1TFN.cbl | `8bbc799b498a756a367ccf6dfb52d1d15579fe72332efbb86906e729edf519e2` |

Os números de linha da planilha referem-se a esses arquivos, com comentários.

## Ambiente

- Windows, Python `3.14.2`, openpyxl 3.1.5.
- Instalação: `py -m pip install openpyxl`.
- Observação: neste ambiente, o comando `python` aponta para o Python embutido no
  GnuCOBOL (`C:\GnuCOBOL\bin\python.exe`), que não tem pip nem openpyxl. Usar `py`.
  Se `py script.py` ainda não encontrar o openpyxl, executar com o caminho completo
  do interpretador obtido por `py -c "import sys; print(sys.executable)"`.

## Ordem de execução

### 1. `gabarito_pipeline.py` — separação de código e comentários (Camada A)

Separa cada programa em código sem comentários (entrada dos LLMs) e comentários,
e verifica que a reconstrução das duas partes é idêntica ao original.

```
py gabarito_pipeline.py                     # os quatro programas
py gabarito_pipeline.py XFRFUN BNK1CRA      # apenas os listados
```

- Deve ser executado na pasta que contém os arquivos `<PROGRAMA>.cbl`.
- Gera `<PROGRAMA>_limpo.cbl` e `comentarios_<PROGRAMA>.txt` na mesma pasta.
- Critério de comentário: `*` ou `/` na coluna 7 (formato fixo).
- Resultado registrado: reconstrução OK para os quatro programas.

### 2. `monta_planilha.py` — extração dos pares comentário-código (Camada B)

Pareia cada bloco de comentário da PROCEDURE DIVISION ao código que o segue e
filtra os pares com estrutura de decisão ou tratamento de falha.

```
py monta_planilha.py --origem "<pasta>\cobol_src" --saida gabarito_candidatos_v3.xlsx
py monta_planilha.py --origem "<pasta>\cobol_src" --saida novo.xlsx --comparar planilha_anterior.xlsx
```

| Opção | Função |
|---|---|
| `--origem` | pasta com os `.cbl` (somente leitura) |
| `--saida` | planilha gerada; não sobrescreve arquivo existente |
| `--programas` | programas a processar (padrão: os quatro) |
| `--comparar` | lista, por ID, o que mudou em relação a uma planilha anterior |
| `--forcar` | permite sobrescrever a saída |

Regras de extração:

- O par vai do comentário até o próximo comentário com texto.
- Retém o par se o bloco contém `IF`, `EVALUATE` ou `WHEN`, ou tratamento de falha
  (`ABEND`, `SQLCODE`, `HANDLE`, `DFHRESP`, `EIBRESP`, `EIBRCODE`). Os demais vão
  para a aba Descartados, para que o filtro seja auditável.
- A classificação considera o bloco inteiro; o trecho exibido é limitado a 50 linhas.
- Quando o comentário vem logo após uma linha `IF`, `ELSE`, `WHEN` ou `EVALUATE`,
  essa linha (cabeçalho) é usada para reter o par e aparece com o prefixo `[cab.]`.
- Aborta se o fonte tiver tabulação ou se não houver PROCEDURE DIVISION.
- Imprime a cobertura por programa (linhas de código dentro e fora de pares).

Resultado da extração:

| Programa | Blocos com texto | Retidos pelo script | Descartados |
|---|---|---|---|
| DBCRFUN | 33 | 21 | 12 |
| XFRFUN | 70 | 54 | 16 |
| BNK1CRA | 43 | 31 | 12 |
| BNK1TFN | 49 | 33 | 16 |
| **Total** | **195** | **139** | **56** |

### 3. `migrar_revisao.py` — transferência da revisão manual

Copia, por ID, a revisão manual de uma planilha anterior para a planilha gerada no
passo 2. Usado uma vez, ao substituir a planilha gerada pela versão anterior do
extrator.

```
py migrar_revisao.py --antiga planilha_anterior.xlsx --nova gabarito_candidatos_v3.xlsx --saida gabarito_candidatos_v3_migrado.xlsx
```

- Copia: Regra de negócio extraída, Categoria, Status, Observação, ID atômico,
  Comentário defasado? e, na aba Descartados, Reavaliação.
- Anexa ao fim de Candidatos as linhas reincluídas manualmente que o script
  continua descartando.
- Cria a aba Migração com tudo o que mudou de situação, para conferência manual.
- Não altera as planilhas de entrada.

## Revisão manual

Feita na planilha, coluna a coluna (Regra de negócio extraída, Categoria, Status,
Observação, ID atômico, Comentário defasado?).

- **Regra de negócio:** decisão com semântica bancária, registrada como uma
  condição e uma consequência por regra.
- **Infraestrutura (excluída):** tratamento de erro padrão, que apareceria em
  qualquer outro programa COBOL (rollback, ABEND de DB2/VSAM, storm drain,
  retentativa por deadlock). Proposta de refinamento, pendente de validação com o
  orientador: a execução mecânica de acesso a dados (gravação, inserção,
  atualização) e a montagem de registros também são infraestrutura; a decisão de
  quando registrar uma transação, o que caracteriza seu sucesso e o cálculo dos
  saldos permanecem regras de negócio.
- **A discutir:** casos levados ao orientador.
- Ocorrências repetidas no fonte são mantidas como entradas separadas.
- Blocos descartados podem ser marcados como Reincluir; são anexados ao fim de
  Candidatos com Tipo `Reincluído`. Após a revisão dos descartados: 5 reincluídos,
  144 candidatos e 51 descartados.

## Limitações conhecidas

- A triagem é heurística e não substitui a revisão dupla (discente e orientador).
- Regras sem comentário associado não geram par e ficam fora do gabarito.
- Regras cuja condição está implícita no fluxo (o código só é alcançado após um
  `GO TO` ou `ABEND` de falha) não têm `IF` no trecho e são descartadas pelo
  filtro; só são recuperadas pelo alerta "comentário menciona condição".
- O par vai até o próximo comentário, mesmo cruzando o limite de uma SECTION.
- O tipo (Decisão, Falha) é atribuído ao bloco inteiro; um `IF` ou `ELSE` no fim
  do trecho pode pertencer ao comentário seguinte.
- `PERFORM ABEND-THIS-TASK` não é reconhecido como tratamento de falha; blocos de
  coleta de dados de ABEND que usam essa chamada ficaram em Descartados, enquanto
  os que usam `EXEC CICS ABEND` foram retidos. Ambos são infraestrutura.
- A compilação com GnuCOBOL não foi usada para validar a remoção de comentários:
  `EXEC CICS` e `EXEC SQL` exigem pré-processador indisponível no GnuCOBOL.
- Os copybooks (`cobol_copy`) não passam pelo `gabarito_pipeline.py`. Se forem
  enviados aos modelos, precisam da mesma remoção de comentários.
