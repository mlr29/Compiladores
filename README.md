# Compiladores
Repositório da matéria de Compiladores do 6º Período de Ciência da Computação, aqui são encontradas as atividades promovidas na disciplina, como:
- Análise pré-léxica: geração de lexemas (Atv1);
- Análise pré-léxica: geração de tokens e tabela de símbolos (Atv2);

## Trabalho final

Trabalho desenvolvido como 3º nota de compiladores.
Instale os programs flex e yacc/bison, caso tenha uma distribuição Linux. Utilize os comandos:

`sudo apt install flex`

`sudo apt install yacc`

`sudo apt install bison`

Certifique-se de estar dentro da pasta `/trabalho-final` para executar o que vem a seguir.s

Para análisar o script teste `gteste.go` execute a seguinte sequência de instruções:

`flex go-language.lex`

Isso cria um arquivo `lex.yy.c` que contém o código C gerado pelo Flex.

`bison -d a-cod-interm.y`

Isso cria um arquivo `analisador.tab.c` que contém o código C gerado pelo Yacc.

`gcc lex.yy.c a-cod-interm.tab.c -o compilador -ll`

Estabelece a conexão entre o arquivo gerados do Flex e Yacc e gera o arquivo `compilador` com o analisador final.

`./compilador gteste.go`

Executa a análise para o arquivo teste.