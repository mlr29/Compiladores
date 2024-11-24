# Compiladores
Repositório da matéria de Compiladores do 6º Período de Ciência da Computação, aqui são encontradas as atividades promovidas na disciplina, como:
- Análise pré-léxica: geração de lexemas (Atv1);
- Análise pré-léxica: geração de tokens e tabela de símbolos (Atv2);

## Trabalho final: Front-End do compilador para a linguagem Go

Trabalho desenvolvido como 3º nota de compiladores. Consiste na parte Front-End do compilador para a linguagem Go.

Instale os programas flex e yacc/bison, caso tenha uma distribuição Linux. Utilize os comandos:

`sudo apt install flex`

`sudo apt install yacc`

`sudo apt install bison`

Certifique-se de estar dentro da pasta `/trabalho-final` para executar o que vem a seguir.

## Execução

- Automatico

Executando o `compilar.sh` será realizado automaticamente a sequência de comandos para compilação e analise do arquivo teste `gteste.go`:

`./compilar.sh`

- Manual

Caso não funcione automaticamente a execução, você pode fazer a compilação manualmentte. Para análisar o arquivo teste `gteste.go` execute a seguinte sequência de instruções:

`flex -o output/lex.yy.c a-lexica.lex`

Isso cria um arquivo `lex.yy.c` que contém o código C gerado pelo Flex.

`bison -d a-sin-sem-cod-interm.y -b output/a-sin-sem-cod-interm`

Isso cria um arquivo `a-sin-sem-cod-interm.tab.c` que contém o código C gerado pelo Yacc.

`gcc -g output/lex.yy.c output/a-sin-sem-cod-interm.tab.c -o output/compilador -Wall`

Estabelece a conexão entre os arquivos gerados do Flex e Yacc e gera o arquivo `compilador` com o analisador final.

`./compilador ../gteste.go`

Executa a análise para o arquivo teste.