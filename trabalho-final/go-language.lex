%{
#include <string.h>
#include <stdio.h>
#include "a-cod-interm.tab.h" 

FILE *out;
int linha;
%}

%option yylineno
%x COMMENT
%x LINE_COMMENT

/* Definições de padrões */
digit       [0-9]
letter      [a-zA-Z]
ID          {letter}({letter}|{digit})*
WHITESPACE  [ ]
quebra      \n
TAB         \t
STRING      \"[^\"]*\"
FUNC        "func"

%%

"//"                    { BEGIN(LINE_COMMENT); }
<LINE_COMMENT>\n       { BEGIN(INITIAL); }
<LINE_COMMENT>.        ; /* Ignora tudo até o fim da linha */

"/*"                    { linha = yylineno; BEGIN(COMMENT); }
<COMMENT>"*/"           { BEGIN(INITIAL); }
<COMMENT>(.|\n)         ;  /* Ignora o conteúdo dos comentários */
<COMMENT><<EOF>>        { fprintf(out, "(%d, ERROR, \"/*\")\n", linha); return ERROR; }

"import" { yylval.str = strdup(yytext); return IMPORT; }

"package" { return PACKAGE; }

"func" { return FUNC; }

"var" { return VAR; }

"int" { yylval.str = strdup(yytext); return INT_TYPE;}

"+"|"-"|"*"|"/"|"<"|"<="|">"|">="|"=="|"!="|"="|";"|","|"("|")"|"["|"]"|"{"|"}"|":"|"." { return yytext[0]; }

break|case|chan|const|continue|default|defer|else|fallthrough|for|go|goto|if|interface|map|range|select {yylval.str = strdup(yytext); return KEYWORD; }

{STRING}                { yylval.str = strdup(yytext); return STRING; }

{WHITESPACE}+|{quebra}|{TAB}+  ; /* Ignora espaços em branco, quebras de linha e tabulações */

{digit}+                { yylval.num = atoi(yytext); return NUMBER_INT; }
{digit}+\.{digit}+      { yylval.num = atoi(yytext); return NUMBER_FLOAT; }
{ID}                    { yylval.str = strdup(yytext); return IDENTIFIER; }

.                       { fprintf(out, "(%d, ERROR, \"%s\")\n", yylineno, yytext); return ERROR; }

%%

int yywrap() {
    return 1;
}
