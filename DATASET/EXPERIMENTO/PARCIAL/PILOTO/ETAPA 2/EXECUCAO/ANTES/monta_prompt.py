#!/usr/bin/env python3
"""
monta_prompt.py

Junta um prompt (com o marcador {{CODIGO_COBOL}}) e um programa sem comentários
(<PROGRAMA>_limpo.cbl, gerado pelo limpa_comentarios.py) num único arquivo de
entrada, pronto para copiar e colar no chat. Guarda também o SHA-256 da entrada,
para registro na planilha de execuções.

Uso:
  py monta_prompt.py --prompt prompt_A_zeroshot_v2.txt --codigo CREACC_limpo.cbl
  -> gera entrada_A_zeroshot_v2_CREACC.txt

O código entra exatamente como está no arquivo (sem alterar espaços).
"""
import argparse
import hashlib
import sys
from pathlib import Path

MARCADOR = "{{CODIGO_COBOL}}"


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--prompt", required=True, type=Path)
    ap.add_argument("--codigo", required=True, type=Path)
    ap.add_argument("--saida", type=Path, help="nome do arquivo de saída (opcional)")
    a = ap.parse_args()

    prompt = a.prompt.read_text(encoding="utf-8")
    codigo = a.codigo.read_text(encoding="utf-8").rstrip("\n")
    if prompt.count(MARCADOR) != 1:
        sys.exit(f"O prompt deve ter exatamente um {MARCADOR}; encontrei {prompt.count(MARCADOR)}.")

    entrada = prompt.replace(MARCADOR, codigo)
    programa = a.codigo.stem.replace("_limpo", "")
    estrategia = a.prompt.stem.replace("prompt_", "")
    saida = a.saida or Path(f"entrada_{estrategia}_{programa}.txt")
    saida.write_text(entrada, encoding="utf-8")

    sha = hashlib.sha256(entrada.encode("utf-8")).hexdigest()
    print(f"Gerado: {saida}")
    print(f"Linhas: {entrada.count(chr(10)) + 1} | caracteres: {len(entrada)} | SHA-256: {sha}")


if __name__ == "__main__":
    main()
