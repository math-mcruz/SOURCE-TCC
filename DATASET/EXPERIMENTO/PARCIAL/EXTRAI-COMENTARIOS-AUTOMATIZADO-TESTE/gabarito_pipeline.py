"""
Pipeline de limpeza de comentários COBOL + teste de reconstrução.

Uso:
    python gabarito_pipeline.py
        -> processa a lista padrão: DBCRFUN, XFRFUN, BNK1CRA, BNK1TFN

    python gabarito_pipeline.py XFRFUN
        -> processa só o XFRFUN

    python gabarito_pipeline.py XFRFUN BNK1CRA
        -> processa só os que você listar

Cada programa precisa ter o arquivo <PROGRAMA>.cbl na mesma pasta deste
script. Nada é digitado duas vezes: o nome do programa entra uma única
vez (no argumento ou na lista padrão) e o script monta os nomes de
arquivo de saída sozinho.
"""

import sys
import os


def limpar_codigo_cobol(programa):
    arquivo_entrada = f'{programa}.cbl'
    arquivo_codigo = f'{programa}_limpo.cbl'
    arquivo_comentarios = f'comentarios_{programa}.txt'

    with open(arquivo_entrada, 'r', encoding='utf-8') as f_in, \
         open(arquivo_codigo, 'w', encoding='utf-8') as f_codigo, \
         open(arquivo_comentarios, 'w', encoding='utf-8') as f_coment:

        for linha in f_in:
            # Verifica se a linha possui mais de 6 caracteres e checa a posição 7 (índice 6)
            if len(linha) > 6 and linha[6] in ['*', '/']:
                f_coment.write(linha)
            else:
                f_codigo.write(linha)

    return arquivo_entrada, arquivo_codigo, arquivo_comentarios


def testar_reconstrucao(arquivo_original, arquivo_codigo, arquivo_comentarios):
    with open(arquivo_original, 'r', encoding='utf-8') as f_orig:
        linhas_originais = f_orig.readlines()

    with open(arquivo_codigo, 'r', encoding='utf-8') as f:
        it_codigo = iter(f.readlines())
    with open(arquivo_comentarios, 'r', encoding='utf-8') as f:
        it_comentarios = iter(f.readlines())

    ok = True
    for i, linha in enumerate(linhas_originais, start=1):
        if len(linha) > 6 and linha[6] in ['*', '/']:
            fonte, nome_fonte = it_comentarios, 'comentarios'
        else:
            fonte, nome_fonte = it_codigo, 'codigo'
        try:
            linha_reconstruida = next(fonte)
        except StopIteration:
            print(f"  ERRO linha {i}: fim inesperado do arquivo de {nome_fonte}")
            ok = False
            break
        if linha_reconstruida != linha:
            print(f"  DIVERGÊNCIA na linha {i} (esperado de {nome_fonte}):")
            print(f"    original:     {linha!r}")
            print(f"    reconstruído: {linha_reconstruida!r}")
            ok = False

    sobra_codigo = list(it_codigo)
    sobra_comentarios = list(it_comentarios)
    if sobra_codigo:
        print(f"  SOBRARAM {len(sobra_codigo)} linhas não consumidas em {arquivo_codigo}")
        ok = False
    if sobra_comentarios:
        print(f"  SOBRARAM {len(sobra_comentarios)} linhas não consumidas em {arquivo_comentarios}")
        ok = False

    return ok


def processar_programa(programa):
    print(f"=== {programa} ===")
    entrada = f'{programa}.cbl'
    if not os.path.isfile(entrada):
        print(f"  PULADO: não encontrei {entrada} nesta pasta")
        return None

    arquivo_original, arquivo_codigo, arquivo_comentarios = limpar_codigo_cobol(programa)
    print(f"  Gerados: {arquivo_codigo}, {arquivo_comentarios}")

    ok = testar_reconstrucao(arquivo_original, arquivo_codigo, arquivo_comentarios)
    print("  RESULTADO: OK — reconstrução idêntica ao original" if ok
          else "  RESULTADO: FALHOU — ver divergências acima")
    return ok


if __name__ == '__main__':
    programas = sys.argv[1:] if len(sys.argv) > 1 else ['DBCRFUN', 'XFRFUN', 'BNK1CRA', 'BNK1TFN']

    resumo = {}
    for programa in programas:
        resumo[programa] = processar_programa(programa)
        print()

    print("=== RESUMO ===")
    for programa, ok in resumo.items():
        if ok is None:
            status = "PULADO (arquivo .cbl não encontrado)"
        elif ok:
            status = "OK"
        else:
            status = "FALHOU"
        print(f"  {programa}: {status}")