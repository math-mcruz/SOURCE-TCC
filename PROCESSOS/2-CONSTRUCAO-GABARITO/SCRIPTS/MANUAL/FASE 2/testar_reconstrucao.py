def testar_reconstrucao(arquivo_original, arquivo_codigo, arquivo_comentarios):
    with open(arquivo_original, 'r', encoding='utf-8') as f_orig:
        linhas_originais = f_orig.readlines()

    with open(arquivo_codigo, 'r', encoding='utf-8') as f:
        it_codigo = iter(f.readlines())
    with open(arquivo_comentarios, 'r', encoding='utf-8') as f:
        it_comentarios = iter(f.readlines())

    reconstruida = []
    ok = True
    for i, linha in enumerate(linhas_originais, start=1):
        if len(linha) > 6 and linha[6] in ['*', '/']:
            fonte, nome_fonte = it_comentarios, 'comentarios'
        else:
            fonte, nome_fonte = it_codigo, 'codigo'
        try:
            linha_reconstruida = next(fonte)
        except StopIteration:
            print(f"ERRO linha {i}: fim inesperado do arquivo de {nome_fonte}")
            ok = False
            break
        reconstruida.append(linha_reconstruida)
        if linha_reconstruida != linha:
            print(f"DIVERGÊNCIA na linha {i} (esperado de {nome_fonte}):")
            print(f"  original:     {linha!r}")
            print(f"  reconstruído: {linha_reconstruida!r}")
            ok = False

    sobra_codigo = list(it_codigo)
    sobra_comentarios = list(it_comentarios)
    if sobra_codigo:
        print(f"SOBRARAM {len(sobra_codigo)} linhas não consumidas em {arquivo_codigo}")
        ok = False
    if sobra_comentarios:
        print(f"SOBRARAM {len(sobra_comentarios)} linhas não consumidas em {arquivo_comentarios}")
        ok = False

    print("RESULTADO:", "OK — reconstrução idêntica ao original" if ok else "FALHOU — ver divergências acima")
    return ok

testar_reconstrucao('DBCRFUN.cbl', 'DBCRFUN_limpo.cbl', 'comentarios_DBCRFUN.txt')