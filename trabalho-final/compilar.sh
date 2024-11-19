#!/bin/bash

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}Iniciando compilação...${NC}"

# Limpa arquivos anteriores
echo "Limpando arquivos anteriores..."
rm -f lex.yy.c a-cod-interm.tab.c a-cod-interm.tab.h compilador tsimbolo.txt

# Gera o analisador léxico
echo "Gerando analisador léxico..."
flex go-language.lex
if [ $? -ne 0 ]; then
    echo -e "${RED}Erro ao gerar analisador léxico${NC}"
    exit 1
fi

# Gera o analisador sintático
echo "Gerando analisador sintático..."
bison -d a-cod-interm.y
if [ $? -ne 0 ]; then
    echo -e "${RED}Erro ao gerar analisador sintático${NC}"
    exit 1
fi

# Compila o programa
echo "Compilando..."
gcc lex.yy.c a-cod-interm.tab.c -o compilador
if [ $? -ne 0 ]; then
    echo -e "${RED}Erro na compilação${NC}"
    exit 1
fi

# Executa o compilador com o arquivo de teste
echo -e "${GREEN}Compilação concluída! Executando testes...${NC}"
./compilador gteste.go

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Teste concluído com sucesso!${NC}"
else
    echo -e "${RED}Erro durante a execução do teste${NC}"
fi

# Lista os arquivos gerados
echo -e "\nArquivos gerados:"
ls -l compilador tsimbolo.txt 