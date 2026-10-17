#!/usr/bin/env python3
"""
inventario_cbsa.py

Gera o inventário dos programas COBOL da CBSA para apoiar a seleção de dados
(passo 1 do método). Somente leitura: nada na origem é alterado.

Métricas por programa (contagens aproximadas, feitas por expressões regulares):
  linhas, linhas_codigo, linhas_comentario_pd
  n_if, n_evaluate, n_when
  blocos_comentario_pd   : blocos contíguos de comentário na PROCEDURE DIVISION
  blocos_antes_decisao   : desses, os seguidos imediatamente por IF/EVALUATE/WHEN/ELSE
                           (piso do nº de pares comentário-decisão candidatos)
  aninhamento_max        : profundidade máxima de IF/EVALUATE (por IF/END-IF)
  n_goto, n_perform
  chama                  : programas acionados por PROGRAM('X')

Uso (Windows):
  python inventario_cbsa.py --origem "...\\DATABASE\\ORIGINAL\\DATABASE\\cobol_src" --saida inventario.csv

Apenas biblioteca padrão do Python 3.8+. Formato fixo: comentário = '*' ou '/'
na coluna 7; código nas colunas 8 a 72.
"""

import argparse
import csv
import re
import sys
from pathlib import Path

RE_IF = re.compile(r"(?<![-\w])IF(?![-\w])")
RE_EVAL = re.compile(r"(?<![-\w])EVALUATE(?![-\w])")
RE_WHEN = re.compile(r"(?<![-\w])WHEN(?![-\w])")
RE_ABRE_FECHA = re.compile(r"(?<![-\w])(END-IF|END-EVALUATE|IF|EVALUATE)(?![-\w])")
RE_GOTO = re.compile(r"GO\s+TO")
RE_PERFORM = re.compile(r"(?<![-\w])PERFORM(?![-\w])")
RE_PROGRAM = re.compile(r"PROGRAM\s*\(\s*'?([A-Z0-9]+)'?\s*\)")
RE_PD = re.compile(r"^\s*PROCEDURE\s+DIVISION")
RE_DECISAO = re.compile(r"(IF|EVALUATE|WHEN|ELSE|END-IF)\b")
RE_LITERAL = re.compile(r"'[^']*'")


def eh_comentario(l):
    return len(l) > 6 and l[6] in "*/"


def eh_debug(l):
    return len(l) > 6 and l[6] in "Dd"


def texto_codigo(l):
    """Colunas 8-72, sem literais entre apóstrofos (evita falsos positivos)."""
    return RE_LITERAL.sub("''", l[7:72])


def analisar(caminho: Path):
    dados = caminho.read_bytes().decode("latin-1").replace("\r", "")
    linhas = dados.split("\n")
    if linhas and linhas[-1] == "":
        linhas.pop()

    codigo = [l for l in linhas if not eh_comentario(l) and l.strip()]
    pd = next((i for i, l in enumerate(linhas) if not eh_comentario(l) and RE_PD.search(l)), None)
    corpo = linhas[pd:] if pd is not None else []

    ativo = [texto_codigo(l) for l in corpo if not eh_comentario(l) and not eh_debug(l)]
    n_if = sum(len(RE_IF.findall(t)) for t in ativo)
    n_eval = sum(len(RE_EVAL.findall(t)) for t in ativo)
    n_when = sum(len(RE_WHEN.findall(t)) for t in ativo)
    n_goto = sum(len(RE_GOTO.findall(t)) for t in ativo)
    n_perform = sum(len(RE_PERFORM.findall(t)) for t in ativo)

    profundidade = maxima = 0
    for t in ativo:
        for m in RE_ABRE_FECHA.finditer(t):
            if m.group(1) in ("IF", "EVALUATE"):
                profundidade += 1
                maxima = max(maxima, profundidade)
            else:
                profundidade -= 1

    blocos = antes_decisao = 0
    i = 0
    while i < len(corpo):
        if eh_comentario(corpo[i]):
            j = i
            while j < len(corpo) and (eh_comentario(corpo[j]) or not corpo[j].strip()):
                j += 1
            tem_texto = any(
                eh_comentario(x) and x[7:].strip("* ").strip() for x in corpo[i:j]
            )
            if tem_texto:
                blocos += 1
                proxima = corpo[j][7:72].strip() if j < len(corpo) else ""
                if RE_DECISAO.match(proxima):
                    antes_decisao += 1
            i = j
        else:
            i += 1

    chama = sorted(
        set(RE_PROGRAM.findall("\n".join(l[7:72] for l in linhas if not eh_comentario(l))))
    )

    return {
        "programa": caminho.stem,
        "linhas": len(linhas),
        "linhas_codigo": len(codigo),
        "linhas_comentario_pd": sum(1 for l in corpo if eh_comentario(l)),
        "n_if": n_if,
        "n_evaluate": n_eval,
        "n_when": n_when,
        "blocos_comentario_pd": blocos,
        "blocos_antes_decisao": antes_decisao,
        "aninhamento_max": maxima,
        "n_goto": n_goto,
        "n_perform": n_perform,
        "chama": ",".join(chama),
    }


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--origem", required=True, type=Path, help="pasta cobol_src (somente leitura)")
    ap.add_argument("--saida", required=True, type=Path, help="arquivo CSV de saída")
    args = ap.parse_args()

    if not args.origem.is_dir():
        sys.exit(f"Origem não encontrada: {args.origem}")
    arquivos = sorted(p for p in args.origem.iterdir() if p.suffix.lower() in {".cbl", ".cob"})
    if not arquivos:
        sys.exit("Nenhum arquivo .cbl encontrado.")

    linhas = [analisar(p) for p in arquivos]
    with open(args.saida, "w", newline="", encoding="utf-8-sig") as f:
        w = csv.DictWriter(f, fieldnames=list(linhas[0].keys()), delimiter=";")
        w.writeheader()
        w.writerows(linhas)

    print(f"{len(linhas)} programas -> {args.saida}")
    print(f"{'programa':10}{'linhas':>7}{'IF':>5}{'EVAL':>6}{'blocos':>8}{'antes_dec':>10}{'nivel':>6}{'GOTO':>6}")
    for r in linhas:
        print(
            f"{r['programa']:10}{r['linhas']:>7}{r['n_if']:>5}{r['n_evaluate']:>6}"
            f"{r['blocos_comentario_pd']:>8}{r['blocos_antes_decisao']:>10}"
            f"{r['aninhamento_max']:>6}{r['n_goto']:>6}"
        )


if __name__ == "__main__":
    main()
