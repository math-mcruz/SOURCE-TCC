def limpar_codigo_cobol(arquivo_entrada, arquivo_codigo, arquivo_comentarios):
    with open(arquivo_entrada, 'r', encoding='utf-8') as f_in, \
         open(arquivo_codigo, 'w', encoding='utf-8') as f_codigo, \
         open(arquivo_comentarios, 'w', encoding='utf-8') as f_coment:
        
        for linha in f_in:
            # Verifica se a linha possui mais de 6 caracteres e checa a posição 7 (índice 6)
            if len(linha) > 6 and linha[6] in ['*', '/']:
                # Salva no arquivo de comentários para você auditar e construir o gabarito
                f_coment.write(linha)
            else:
                # Mantém o código executável no arquivo limpo
                f_codigo.write(linha)

# EXTRACAO DO DBCRFUN
limpar_codigo_cobol('DBCRFUN.cbl', 'DBCRFUN_limpo.cbl', 'comentarios_DBCRFUN.txt')