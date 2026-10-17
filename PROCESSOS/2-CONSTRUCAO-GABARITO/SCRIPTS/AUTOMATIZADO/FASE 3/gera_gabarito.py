#!/usr/bin/env python3
"""
gera_gabarito.py

Gera a aba "Gabarito" a partir da aba Candidatos da planilha de revisão:
uma linha por regra de negócio atômica, apenas para os pares com
Categoria = "regra de negócio" e Status = "Validado".

- Regras numeradas na coluna "Regra de negócio extraída" (1., 2., ...) são
  divididas em linhas próprias, com ID <par>.1, <par>.2, ... na ordem em que
  aparecem. Um par com uma única regra mantém o ID do par.
- Pares "a discutir" ou "A validar" não entram; a Legenda registra quantos.
- Recalcula a altura das linhas de todas as abas pelo tamanho do texto, para o
  texto não ficar espremido no Google Planilhas (que não ajusta a altura sozinho
  ao importar um .xlsx).
- Não altera a planilha de entrada; grava outra.

Uso:
  py gera_gabarito.py --entrada GABARITO_V5.xlsx --saida GABARITO_V5_com_gabarito.xlsx
Executar de novo sempre que a revisão mudar (por exemplo, após a reunião
com o orientador): a aba Gabarito é recriada do zero.
"""

import argparse
import math
import re
import sys
from datetime import date
from pathlib import Path

from openpyxl import load_workbook
from openpyxl.styles import Alignment, Font, PatternFill
from openpyxl.utils import get_column_letter

RE_NUM = re.compile(r"^\s*\d+\s*[.)]\s*")
COLUNAS = [
    ("ID da regra", 15), ("ID do par", 13), ("Programa", 10),
    ("Linhas do comentário", 11), ("Linhas do código", 12),
    ("Regra de negócio", 80), ("Comentário defasado?", 13),
    ("Origem do par", 16), ("Observação do par", 70),
]


def dividir(texto):
    """Divide o texto em regras: linhas numeradas viram regras próprias."""
    linhas = [l.strip() for l in (texto or "").splitlines() if l.strip()]
    if not linhas:
        return []
    if any(RE_NUM.match(l) for l in linhas):
        regras, atual = [], None
        for l in linhas:
            if RE_NUM.match(l):
                if atual:
                    regras.append(atual)
                atual = RE_NUM.sub("", l)
            elif atual is not None:
                atual += " " + l  # continuação da regra anterior
            else:
                atual = l
        if atual:
            regras.append(atual)
        return [r for r in regras if r]
    return [" ".join(linhas)]


def ajustar_alturas(ws, primeira=2):
    """Estima a altura de cada linha pelo texto, pela largura da coluna e pela fonte.

    Google Planilhas não ajusta a altura de linhas com quebra de texto ao importar
    um .xlsx; sem altura definida, cada linha fica com a altura de uma única linha
    de texto. A estimativa usa cerca de 1,1 caractere por unidade de largura em
    Arial e 0,85 em fontes monoespaçadas (código), 13 pt por linha de texto e
    8 pt de folga, com mínimo de 21 pt e máximo de 409 pt (limite do Excel).
    """
    larguras = {}
    for c in range(1, ws.max_column + 1):
        dim = ws.column_dimensions.get(get_column_letter(c))
        larguras[c] = dim.width if dim is not None and dim.width else 8.43
    for r in range(primeira, ws.max_row + 1):
        maior, tem_texto = 0, False
        for c in range(1, ws.max_column + 1):
            cel = ws.cell(row=r, column=c)
            if cel.value is None or str(cel.value) == "":
                continue
            tem_texto = True
            texto = str(cel.value)
            if texto.startswith("="):  # fórmula: uma linha
                texto = "0" * 8
            mono = "Courier" in (cel.font.name or "")
            por_linha = max(1, int(larguras[c] * (0.85 if mono else 1.1)))
            if cel.alignment.wrap_text:
                n = sum(max(1, math.ceil(len(p) / por_linha)) for p in texto.split("\n"))
            else:
                n = 1
            maior = max(maior, n)
        if tem_texto:
            ws.row_dimensions[r].height = max(21, min(409, maior * 13.0 + 8))
        elif ws.row_dimensions[r].height is not None:
            ws.row_dimensions[r].height = None


def ultima_linha_preenchida(ws, coluna=1):
    """Última linha com valor na coluna (max_row conta linhas vazias formatadas)."""
    for r in range(ws.max_row, 0, -1):
        if ws.cell(row=r, column=coluna).value not in (None, ""):
            return r
    return 0


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--entrada", required=True, type=Path)
    ap.add_argument("--saida", required=True, type=Path)
    ap.add_argument("--forcar", action="store_true", help="permite sobrescrever --saida")
    a = ap.parse_args()

    if not a.entrada.is_file():
        sys.exit(f"Entrada não encontrada: {a.entrada}")
    if a.saida.resolve() == a.entrada.resolve():
        sys.exit("A saída não pode ser igual à entrada.")
    if a.saida.exists() and not a.forcar:
        sys.exit(f"A saída já existe e não foi sobrescrita: {a.saida} (use outro nome ou --forcar)")

    wb = load_workbook(a.entrada)
    wc = wb["Candidatos"]
    cab = [c.value for c in wc[1]]
    ix = {n: i for i, n in enumerate(cab) if n}
    for n in ("ID", "Programa", "Linhas do comentário", "Linhas do código", "Regra de negócio extraída",
              "Categoria", "Status", "Observação", "Tipo", "Comentário defasado?"):
        if n not in ix:
            sys.exit(f"Coluna ausente na aba Candidatos: {n}")

    regras, pares, fora, vazios = [], 0, {}, []
    for row in wc.iter_rows(min_row=2, values_only=True):
        if not row or not row[ix["ID"]]:
            continue
        cat, st = row[ix["Categoria"]], row[ix["Status"]]
        if cat != "regra de negócio" or st != "Validado":
            chave = f"{cat or 'sem categoria'} / {st or 'sem status'}"
            if cat != "infraestrutura (excluída)":
                fora[chave] = fora.get(chave, 0) + 1
            continue
        partes = dividir(row[ix["Regra de negócio extraída"]])
        if not partes:
            vazios.append(row[ix["ID"]])
            continue
        pares += 1
        for k, texto in enumerate(partes, start=1):
            id_regra = row[ix["ID"]] if len(partes) == 1 else f"{row[ix['ID']]}.{k}"
            regras.append([
                id_regra, row[ix["ID"]], row[ix["Programa"]], row[ix["Linhas do comentário"]],
                row[ix["Linhas do código"]], texto, row[ix["Comentário defasado?"]],
                "Reincluído" if row[ix["Tipo"]] == "Reincluído" else "Retido pelo script",
                row[ix["Observação"]],
            ])
    if vazios:
        sys.exit(f"Pares validados como regra de negócio sem regra redigida: {', '.join(vazios)}")

    # --- aba Gabarito (recriada)
    if "Gabarito" in wb.sheetnames:
        del wb["Gabarito"]
    wg = wb.create_sheet("Gabarito", index=wb.sheetnames.index("Candidatos"))
    f_cab = Font(name="Arial", size=10, bold=True, color="FFFFFF")
    f_txt = Font(name="Arial", size=10)
    topo = Alignment(vertical="top", wrap_text=True)
    for c, (titulo, larg) in enumerate(COLUNAS, start=1):
        cel = wg.cell(row=1, column=c, value=titulo)
        cel.font, cel.fill = f_cab, PatternFill("solid", fgColor="2F4F6F")
        cel.alignment = Alignment(vertical="center", wrap_text=True)
        wg.column_dimensions[cel.column_letter].width = larg
    for r, vals in enumerate(regras, start=2):
        for c, v in enumerate(vals, start=1):
            cel = wg.cell(row=r, column=c, value=v)
            cel.font, cel.alignment = f_txt, topo
    wg.freeze_panes = "C2"
    if regras:
        wg.auto_filter.ref = f"A1:{wg.cell(row=1, column=len(COLUNAS)).column_letter}{len(regras) + 1}"

    # --- Legenda: registro da geração
    wl = wb["Legenda"]
    rot = "Gabarito (aba)"
    for r in range(1, wl.max_row + 1):
        if wl.cell(row=r, column=1).value == rot:
            wl.delete_rows(r)
            break
    nao_incl = "; ".join(f"{v} {k}" for k, v in sorted(fora.items())) or "nenhum"
    texto = (f"Gerada em {date.today():%d/%m/%Y} por gera_gabarito.py: {len(regras)} regras atômicas, "
             f"de {pares} pares validados como regra de negócio. Regras numeradas na coluna "
             f"'Regra de negócio extraída' viram linhas próprias (ID do par seguido de .1, .2, ...). "
             f"Pares fora do gabarito, além da infraestrutura: {nao_incl}. "
             f"Recriar a aba sempre que a revisão mudar.")
    modelo = ultima_linha_preenchida(wl)
    linha = modelo + 1
    wl.cell(row=linha, column=1, value=rot)._style = wl.cell(row=modelo, column=1)._style
    wl.cell(row=linha, column=2, value=texto)._style = wl.cell(row=modelo, column=2)._style

    # --- altura das linhas pelo tamanho do texto (exceto o cabeçalho e a aba Resumo)
    for ws in wb.worksheets:
        if ws.title == "Resumo":
            continue
        ajustar_alturas(ws, primeira=1 if ws.title == "Legenda" else 2)

    wb.save(a.saida)
    print(f"{len(regras)} regras atômicas de {pares} pares -> {a.saida}")
    print(f"Fora do gabarito (além da infraestrutura): {nao_incl}")


if __name__ == "__main__":
    main()
