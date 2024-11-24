%{
#include <string.h>
#include <stdio.h>
#include "a-sin-sem-cod-interm.tab.h" 

FILE *out = NULL;
int linha;

void init_lexer() {
    out = fopen("tokens.txt", "w");
    if (!out) {
        fprintf(stderr, "Erro ao criar arquivo de tokens\n");
        exit(1);
    }
    fprintf(out, "\t\tLista de Tokens Reconhecidos\n");
    fprintf(out, "+-----------------+-----------------+----------+\n");
    fprintf(out, "| Linha          | Token           | Lexema   |\n");
    fprintf(out, "+-----------------+-----------------+----------+\n");
}

void close_lexer() {
    if (out) {
        fprintf(out, "+-----------------+-----------------+----------+\n");
        fclose(out);
        out = NULL;
    }
}

void print_token(const char* token, const char* lexema) {
    if (!out) {
        init_lexer();
    }
    fprintf(out, "| %-15d | %-15s | %-8s |\n", yylineno, token, lexema);
}

%}

%option noinput
%option nounput
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
<COMMENT><<EOF>>        { print_token("ERROR", "/*"); return ERROR; }

"if"        { printf("(Análise Léxica): reconhecido token %s\n", yytext); print_token("IF", yytext); return IF; }
"else"      { printf("(Análise Léxica): reconhecido token %s\n", yytext); print_token("ELSE", yytext); return ELSE; }
"for"       { printf("(Análise Léxica): reconhecido token %s\n", yytext); print_token("FOR", yytext); return FOR; }
"++"        { printf("(Análise Léxica): reconhecido token %s\n", yytext); print_token("INC", yytext); return INC; }
":="        { printf("(Análise Léxica): reconhecido token %s\n", yytext); print_token("DECLARE_ASSIGN", yytext); return DECLARE_ASSIGN; }
"<"         { printf("(Análise Léxica): reconhecido token %s\n", yytext); print_token("LT", yytext); return LT; }
">"         { printf("(Análise Léxica): reconhecido token %s\n", yytext); print_token("GT", yytext); return GT; }
"<="        { printf("(Análise Léxica): reconhecido token %s\n", yytext); print_token("LE", yytext); return LE; }
">="        { printf("(Análise Léxica): reconhecido token %s\n", yytext); print_token("GE", yytext); return GE; }
"=="        { printf("(Análise Léxica): reconhecido token %s\n", yytext); print_token("EQ", yytext); return EQ; }
"!="        { printf("(Análise Léxica): reconhecido token %s\n", yytext); print_token("NE", yytext); return NE; }

"import"    { printf("(Análise Léxica): reconhecido token %s\n", yytext); print_token("IMPORT", yytext); yylval.str = strdup(yytext); return IMPORT; }
"package"   { printf("(Análise Léxica): reconhecido token %s\n", yytext); print_token("PACKAGE", yytext); return PACKAGE; }
"func"      { printf("(Análise Léxica): reconhecido token %s\n", yytext); print_token("FUNC", yytext); return FUNC; }
"var"       { printf("(Análise Léxica): reconhecido token %s\n", yytext); print_token("VAR", yytext); return VAR; }
"int"       { printf("(Análise Léxica): reconhecido token %s\n", yytext); print_token("INT_TYPE", yytext); yylval.str = strdup(yytext); return INT_TYPE; }

"+"|"-"|"*"|"/"|"="|";"|","|"("|")"|"{"|"}"|":"|"." { 
    char token[2] = {yytext[0], '\0'};
    print_token("OPERATOR", token); 
    printf("(Análise Léxica): reconhecido token %s\n", token);
    return yytext[0]; 
}

break|case|chan|const|continue|default|defer|fallthrough|go|goto|interface|map|range|select {
    print_token("KEYWORD", yytext);
    yylval.str = strdup(yytext); 
    return KEYWORD; 
}

{STRING}    { printf("(Análise Léxica): reconhecido token %s\n", yytext); print_token("STRING", yytext); yylval.str = strdup(yytext); return STRING; }
{WHITESPACE}+|{quebra}|{TAB}+  ; /* Ignora espaços em branco */
{digit}+    { printf("(Análise Léxica): reconhecido token %s\n", yytext); print_token("NUMBER_INT", yytext); yylval.num = atoi(yytext); return NUMBER_INT; }
{digit}+\.{digit}+ { printf("(Análise Léxica): reconhecido token %s\n", yytext); print_token("NUMBER_FLOAT", yytext); yylval.num = atoi(yytext); return NUMBER_FLOAT; }
{ID}        { printf("(Análise Léxica): reconhecido token %s\n", yytext); print_token("IDENTIFIER", yytext); yylval.str = strdup(yytext); return IDENTIFIER; }

.           { printf("Reconhecido token de erro: %s\n", yytext); print_token("ERROR", yytext); return ERROR; }

%%

int yywrap() {
    close_lexer();
    return 1;
}
