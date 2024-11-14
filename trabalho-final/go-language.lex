%{
#include <string.h>
#include <stdio.h>
#include "analisador.tab.h" 

FILE *out;
int linha; // Armazena a linha onde comentários começam
%}

%option yylineno
%x COMMENT

/* Definições de padrões */
digit       [0-9]
letter      [a-zA-Z]
ID          {letter}({letter}|{digit})*
WHITESPACE  [ ]
quebra      \n
TAB         \t
STRING      \"[^\"]*\"

/* Regras de análise */
%%
{quebra}                { /* Ignora quebras de linha */ }

"/*"                    { linha = yylineno; BEGIN(COMMENT); }
<COMMENT>"*/"           { BEGIN(INITIAL); }
<COMMENT>(.|\n)         ;  // Ignora o conteúdo dos comentários
<COMMENT><<EOF>>        { fprintf(out, "(%d, ERROR, \"/*\")\n", linha); return ERROR; }

{STRING}                { yylval.str = strdup(yytext); return STRING; }

break|case|chan|const|continue|default|defer|else|fallthrough|for|func|go|goto|if|import|interface|map|range|select {yylval.str = strdup(yytext); return KEYWORD; } // Use um único token para simplificar

"package" {return PACKAGE;} 

"+"|"-"|"*"|"/"|"<"|"<="|">"|">="|"=="|"!="|"="|";"|","|"("|")"|"["|"]"|"{"|"}"|":"|"." { return yytext[0]; } // Retorna o próprio símbolo

{WHITESPACE}+|{quebra}|{TAB}+  ; /* Ignora espaços em branco, quebras de linha e tabulações */

{digit}+                { yylval.num = atoi(yytext); return NUMBER; }
{ID}                    { yylval.str = strdup(yytext); return IDENTIFIER; }

.                       { fprintf(out, "(%d, ERROR, \"%s\")\n", yylineno, yytext); return ERROR; }
%%

// Implementação da função main e do yywrap
int yywrap() {
    return 1;
}

// int main(int argc, char *argv[]) {
//     if (argc < 3) {
//         printf("Uso: %s <arquivo de entrada> <arquivo de saída>\n", argv[0]);
//         return -1;
//     }
    
//     FILE *arquivo = fopen(argv[1], "r");
//     if (!arquivo) {
//         printf("Arquivo inexistente.\n");
//         return -1;
//     }
    
//     yyin = arquivo;
//     out = fopen(argv[2], "w");
//     if (!out) {
//         printf("Erro ao abrir o arquivo de saída.\n");
//         fclose(arquivo);
//         return -1;
//     }
    
//     yyparse(); // Chamada para o parser Yacc
    
//     fclose(arquivo);
//     fclose(out);
//     return 0;
// }
