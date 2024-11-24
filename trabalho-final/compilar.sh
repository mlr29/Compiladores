#!/bin/bash

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}Iniciando compilação...${NC}"

# Cria diretório output se não existir
mkdir -p output

# Limpa arquivos anteriores
echo "Limpando arquivos anteriores..."
rm -f output/lex.yy.c output/a-sin-sem-cod-interm.tab.c output/a-sin-sem-cod-interm.tab.h output/compilador output/tsimbolo.txt output/tokens.txt output/codigo-intermediario.txt

# Gera o analisador léxico
echo "Gerando analisador léxico..."
flex -o output/lex.yy.c a-lexica.lex
if [ $? -ne 0 ]; then
    echo -e "${RED}Erro ao gerar analisador léxico${NC}"
    exit 1
fi

# Gera o analisador sintático
echo "Gerando analisador sintático..."
bison -d a-sin-sem-cod-interm.y -b output/a-sin-sem-cod-interm
if [ $? -ne 0 ]; then
    echo -e "${RED}Erro ao gerar analisador sintático/semântico/código intermediário${NC}"
    exit 1
fi

# Compila o programa
echo "Compilando..."
gcc -g output/lex.yy.c output/a-sin-sem-cod-interm.tab.c -o output/compilador -Wall
if [ $? -ne 0 ]; then
    echo -e "${RED}Erro na compilação${NC}"
    exit 1
fi

# Executa o compilador com o arquivo de teste
echo -e "${GREEN}Compilação concluída! Executando testes...${NC}"
cd output
if [ ! -f "../gteste.go" ]; then
    echo -e "${RED}Erro: Arquivo de teste '../gteste.go' não encontrado${NC}"
    exit 1
fi

# Execute com valgrind para debug se necessário
# valgrind --leak-check=full ./compilador ../gteste.go
echo -e "\n${GREEN}Fluxo de Análises:${NC}"
./compilador ../gteste.go
RESULT=$?
cd ..

if [ $RESULT -eq 0 ]; then
    echo -e "${GREEN}Teste concluído com sucesso!${NC}"
    # Move os arquivos gerados para o diretório output
    [ -f output/tokens.txt ] || mv tokens.txt output/ 2>/dev/null
    [ -f output/codigo-intermediario.txt ] || mv codigo-intermediario.txt output/ 2>/dev/null
else
    echo -e "${RED}Erro durante a execução do teste (código de saída: $RESULT)${NC}"
    # Move os arquivos mesmo em caso de erro
    [ -f output/tokens.txt ] || mv tokens.txt output/ 2>/dev/null
    [ -f output/codigo-intermediario.txt ] || mv codigo-intermediario.txt output/ 2>/dev/null
    exit 1
fi

# Lista os arquivos gerados
echo -e "\nArquivos gerados em output/:"
ls -l output/compilador output/tsimbolo.txt output/tokens.txt output/codigo-intermediario.txt 2>/dev/null