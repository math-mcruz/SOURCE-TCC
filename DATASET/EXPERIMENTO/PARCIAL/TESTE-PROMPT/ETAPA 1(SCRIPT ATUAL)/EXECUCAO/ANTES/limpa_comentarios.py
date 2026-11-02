"""
Pipeline de limpeza de comentários COBOL + teste de reconstrução.

Uso:
    python limpa_comentarios.py
        -> processa a lista padrão: DBCRFUN, XFRFUN, BNK1CRA, BNK1TFN

    python limpa_comentarios.py XFRFUN
        -> processa só o XFRFUN

    python limpa_comentarios.py XFRFUN BNK1CRA
        -> processa só os que você listar

Cada programa precisa ter o arquivo <PROGRAMA>.cbl na mesma pasta deste
script. Nada é digitado duas vezes: o nome do programa entra uma única
vez (no argumento ou na lista padrão) e o script monta os nomes de
arquivo de saída sozinho.

O que sai do código, pela coluna 7 (área de indicador):
- '*' ou '/': linha de comentário -> comentarios_<PROGRAMA>.txt
- 'D' ou 'd': linha de depuração -> depuracao_<PROGRAMA>.txt
  Sem a cláusula WITH DEBUGGING MODE no SOURCE-COMPUTER, o compilador
  trata as linhas de depuração como comentários (IBM Enterprise COBOL,
  Programming Guide, "Generating information about procedures"). Por
  isso o script confere antes se o modo de depuração está ativo; se
  estiver, as linhas D são código de verdade e o programa não é limpo.

O teste de reconstrução junta as três saídas na ordem original e confere
se o resultado é idêntico ao arquivo de entrada.
"""

import sys
import os

INDICADORES_COMENTARIO = ('*', '/')
INDICADORES_DEPURACAO = ('D', 'd')


def tipo_da_linha(linha):
    """Classifica a linha pela coluna 7 (índice 6)."""
    if len(linha) > 6 and linha[6] in INDICADORES_COMENTARIO:
        return 'comentario'
    if len(linha) > 6 and linha[6] in INDICADORES_DEPURACAO:
        return 'depuracao'
    return 'codigo'


def modo_depuracao_ativo(arquivo_entrada):
    """Devolve as linhas (fora de comentário) que citam DEBUGGING.

    Lista vazia = o modo de depuração não está ativo, e as linhas D
    são tratadas como comentário pelo compilador.
    """
    encontradas = []
    with open(arquivo_entrada, 'r', encoding='utf-8') as f:
        for numero, linha in enumerate(f, start=1):
            if tipo_da_linha(linha) != 'comentario' and 'DEBUGGING' in linha.upper():
                encontradas.append((numero, linha.rstrip('\n')))
    return encontradas


def limpar_codigo_cobol(programa):
    arquivo_entrada = f'{programa}.cbl'
    arquivo_codigo = f'{programa}_limpo.cbl'
    arquivo_comentarios = f'comentarios_{programa}.txt'
    arquivo_depuracao = f'depuracao_{programa}.txt'

    contagem = {'codigo': 0, 'comentario': 0, 'depuracao': 0}
    linhas_depuracao = []

    with open(arquivo_entrada, 'r', encoding='utf-8') as f_in, \
         open(arquivo_codigo, 'w', encoding='utf-8') as f_codigo, \
         open(arquivo_comentarios, 'w', encoding='utf-8') as f_coment, \
         open(arquivo_depuracao, 'w', encoding='utf-8') as f_depur:

        saidas = {'codigo': f_codigo, 'comentario': f_coment, 'depuracao': f_depur}
        for numero, linha in enumerate(f_in, start=1):
            tipo = tipo_da_linha(linha)
            saidas[tipo].write(linha)
            contagem[tipo] += 1
            if tipo == 'depuracao':
                linhas_depuracao.append((numero, linha.rstrip('\n')))

    arquivos = (arquivo_entrada, arquivo_codigo, arquivo_comentarios, arquivo_depuracao)
    return arquivos, contagem, linhas_depuracao


def testar_reconstrucao(arquivo_original, arquivo_codigo, arquivo_comentarios, arquivo_depuracao):
    with open(arquivo_original, 'r', encoding='utf-8') as f_orig:
        linhas_originais = f_orig.readlines()

    fontes = {}
    for tipo, arquivo in (('codigo', arquivo_codigo),
                          ('comentario', arquivo_comentarios),
                          ('depuracao', arquivo_depuracao)):
        with open(arquivo, 'r', encoding='utf-8') as f:
            fontes[tipo] = (iter(f.readlines()), arquivo)

    ok = True
    for i, linha in enumerate(linhas_originais, start=1):
        tipo = tipo_da_linha(linha)
        fonte, nome_fonte = fontes[tipo]
        try:
            linha_reconstruida = next(fonte)
        except StopIteration:
            print(f"  ERRO linha {i}: fim inesperado do arquivo {nome_fonte}")
            ok = False
            break
        if linha_reconstruida != linha:
            print(f"  DIVERGÊNCIA na linha {i} (esperado de {nome_fonte}):")
            print(f"    original:     {linha!r}")
            print(f"    reconstruído: {linha_reconstruida!r}")
            ok = False

    for fonte, nome_fonte in fontes.values():
        sobra = list(fonte)
        if sobra:
            print(f"  SOBRARAM {len(sobra)} linhas não consumidas em {nome_fonte}")
            ok = False

    return ok


def processar_programa(programa):
    print(f"=== {programa} ===")
    entrada = f'{programa}.cbl'
    if not os.path.isfile(entrada):
        print(f"  PULADO: não encontrei {entrada} nesta pasta")
        return None, None

    ativas = modo_depuracao_ativo(entrada)
    if ativas:
        print("  PARADO: o programa cita DEBUGGING fora de comentário, então as")
        print("  linhas D podem ser código ativo. Confira estas linhas:")
        for numero, texto in ativas:
            print(f"    linha {numero}: {texto}")
        return False, None

    arquivos, contagem, linhas_depuracao = limpar_codigo_cobol(programa)
    arquivo_original, arquivo_codigo, arquivo_comentarios, arquivo_depuracao = arquivos
    print(f"  Gerados: {arquivo_codigo}, {arquivo_comentarios}, {arquivo_depuracao}")
    print(f"  Linhas: {contagem['codigo']} de código, {contagem['comentario']} de comentário, "
          f"{contagem['depuracao']} de depuração")
    for numero, texto in linhas_depuracao:
        print(f"    depuração removida, linha {numero}: {texto.strip()}")

    ok = testar_reconstrucao(arquivo_original, arquivo_codigo, arquivo_comentarios, arquivo_depuracao)
    print("  RESULTADO: OK — reconstrução idêntica ao original" if ok
          else "  RESULTADO: FALHOU — ver divergências acima")
    return ok, contagem


if __name__ == '__main__':
    programas = sys.argv[1:] if len(sys.argv) > 1 else ['BNK1CAC', 'CREACC']

    resumo = {}
    for programa in programas:
        resumo[programa] = processar_programa(programa)
        print()

    print("=== RESUMO ===")
    for programa, (ok, contagem) in resumo.items():
        if ok is None:
            status = "PULADO (arquivo .cbl não encontrado)"
        elif ok:
            status = (f"OK ({contagem['comentario']} linhas de comentário e "
                      f"{contagem['depuracao']} de depuração removidas)")
        else:
            status = "FALHOU"
        print(f"  {programa}: {status}")
