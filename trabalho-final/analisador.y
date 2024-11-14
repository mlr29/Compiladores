%{
#include <stdio.h>
#include <stdlib.h>

void yyerror(const char *s);
int yylex();
extern FILE *yyin;

%}



%union {
    int num;
    char *str;
}

%token <num> NUMBER
%token <str> PACKAGE IMPORT
%token <str> FUNC IDENTIFIER STRING KEYWORD 
%token ERROR

%debug

%%

program:
    package_stmt import_stmt func_main_stmt
    ;

package_stmt:
    PACKAGE IDENTIFIER { printf("Reconhecido: pacote %s\n", $2); }
    ;

import_stmt:
    IMPORT STRING { printf("Reconhecido: import %s\n", $2); }
    ;

func_main_stmt:
    FUNC IDENTIFIER '(' ')' '{' println_stmt '}' 
    ;

println_stmt:
    IDENTIFIER '.' IDENTIFIER '(' STRING ')' ';' { printf("Reconhecido: chamada de %s.Println\n", $1); }
    ;

%%

void yyerror(const char *s) {
    extern char *yytext; // `yytext` é definido pelo Flex
    extern int yylineno; // `yylineno` é definido pelo Flex com a opção %option yylineno
    fprintf(stderr, "Erro de sintaxe na linha %d: %s próximo de '%s'\n", yylineno, s, yytext);
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Uso: %s <arquivo de entrada>\n", argv[0]);
        return 1;
    }
    
    yyin = fopen(argv[1], "r");
    if (!yyin) {
        fprintf(stderr, "Erro ao abrir o arquivo %s\n", argv[1]);
        return 1;
    }

    return yyparse();
}