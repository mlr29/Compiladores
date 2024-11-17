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
FUNC        "func"
/* Regras de análise */
%%

"/*"                    { linha = yylineno; BEGIN(COMMENT); }
<COMMENT>"*/"           { BEGIN(INITIAL); }
<COMMENT>(.|\n)         ;  // Ignora o conteúdo dos comentários
<COMMENT><<EOF>>        { fprintf(out, "(%d, ERROR, \"/*\")\n", linha); return ERROR; }

"import" { yylval.str = strdup(yytext); return IMPORT; }

"package" { return PACKAGE; }

"func" { return FUNC; }

"var" { return VAR; }

"int" { yylval.str = strdup(yytext); return INT_TYPE;}

"+"|"-"|"*"|"/"|"<"|"<="|">"|">="|"=="|"!="|"="|";"|","|"("|")"|"["|"]"|"{"|"}"|":"|"." { return yytext[0]; } // Retorna o próprio símbolo

break|case|chan|const|continue|default|defer|else|fallthrough|for|go|goto|if|interface|map|range|select {yylval.str = strdup(yytext); return KEYWORD; } // Use um único token para simplificar

{STRING}                { yylval.str = strdup(yytext); return STRING; }

{WHITESPACE}+|{quebra}|{TAB}+  ; /* Ignora espaços em branco, quebras de linha e tabulações */

{digit}+                { yylval.num = atoi(yytext); return NUMBER_INT; }
{digit}+\.{digit}+      { yylval.num = atoi(yytext); return NUMBER_FLOAT; }
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
