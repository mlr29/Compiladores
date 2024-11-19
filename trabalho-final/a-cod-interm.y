%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);
int yylex(), nId = 0;
void addSymbol(char *name, char *type, int line); 
void generateIntermediateCode(const char *code);
void checkVariableDeclared(char *name);
void checkVariableType(char *name, char *expectedType);
void semanticError(const char *message, int line);

extern int yylineno;

extern FILE *yyin;

typedef struct {
    char *name;
    char *type;
    int line;
    int initialized;
} Symbol;

#define MAX_SYMBOLS 100

Symbol symbolTable[MAX_SYMBOLS];
int symbolCount = 0;

/* Buffer para armazenar o código intermediário */
char intermediateCode[1000][100];
int intermediateLine = 0;

%}

%union {
    int num;
    char *str;
}

%token <num> NUMBER_INT NUMBER_FLOAT
%token PACKAGE FUNC VAR 
%token <str> IDENTIFIER STRING KEYWORD INT_TYPE IMPORT
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
    import_stmt IMPORT STRING { addSymbol($3, $2, nId); printf("Reconhecido: import %s\n", $3); }
    | ;

func_main_stmt:
    FUNC IDENTIFIER '(' ')' '{' stmt_list '}' 
    ;

stmt_list:
    stmt stmt_list
    | /* vazio */
    ;

stmt:
    int_var
    | atr_var_int
    | println_stmt
    ;

int_var:
    VAR IDENTIFIER INT_TYPE ';' { addSymbol($2, $3, nId); printf("Reconhecido: variável int %s\n", $2);}
    ;

atr_var_int:
    IDENTIFIER '=' NUMBER_INT ';'
    {
        checkVariableDeclared($1);
        checkVariableType($1, "int");
        
        for (int i = 0; i < symbolCount; i++) {
            if (strcmp(symbolTable[i].name, $1) == 0) {
                symbolTable[i].initialized = 1;
                break;
            }
        }
        
        printf("Reconhecido: atribuicao %s = %d\n", $1, $3);
        char code[100];
        sprintf(code, "%s = %d", $1, $3);
        generateIntermediateCode(code);
    }
    ;

println_stmt:
    IDENTIFIER '.' IDENTIFIER '(' STRING ')' ';'
    {
        int fmtImported = 0;
        for (int i = 0; i < symbolCount; i++) {
            if (strcmp(symbolTable[i].type, "import") == 0 && 
                strstr(symbolTable[i].name, "fmt") != NULL) {
                fmtImported = 1;
                break;
            }
        }
        if (!fmtImported) {
            semanticError("Pacote 'fmt' não importado", yylineno);
        }
        
        printf("Reconhecido: chamada de %s.%s\n", $1, $3);
        char code[100];
        sprintf(code, "CALL %s.%s, %s", $1, $3, $5);
        generateIntermediateCode(code);
    }
    ;

%%

/* Função para adicionar símbolos à tabela */
void addSymbol(char *name, char *type, int line) {
    FILE *a = fopen("tsimbolo.txt", "a");

    if (a) {
        fprintf(a, "%d %s %s\n", line, name, type);
        fclose(a);
    } else {
        printf("erro ao abrir tabela de simbolos.");
    }

    if (symbolCount < MAX_SYMBOLS) {
        symbolTable[symbolCount].name = strdup(name);
        symbolTable[symbolCount].type = strdup(type);
        symbolTable[symbolCount].line = line;
        symbolTable[symbolCount].initialized = 0;
        symbolCount++;
        nId++;
    } else {
        fprintf(stderr, "Erro: tabela de símbolos cheia\n");
    }
}

/* Função para gerar código intermediário */
void generateIntermediateCode(const char *code) {
    if (intermediateLine < 1000) {
        strcpy(intermediateCode[intermediateLine++], code);
        printf("Código intermediário gerado: %s\n", code);
    } else {
        fprintf(stderr, "Erro: buffer de código intermediário cheio\n");
    }
}

void yyerror(const char *s) {
    extern char *yytext; // `yytext` é definido pelo Flex
    extern int yylineno; // `yylineno` é definido pelo Flex com a opção %option yylineno
    fprintf(stderr, "Erro de sintaxe na linha %d: %s próximo de '%s'\n", yylineno, s, yytext);
}

void checkVariableDeclared(char *name) {
    for (int i = 0; i < symbolCount; i++) {
        if (strcmp(symbolTable[i].name, name) == 0) {
            return;
        }
    }
    char error[100];
    sprintf(error, "Variável '%s' não foi declarada", name);
    semanticError(error, yylineno);
}

void checkVariableType(char *name, char *expectedType) {
    for (int i = 0; i < symbolCount; i++) {
        if (strcmp(symbolTable[i].name, name) == 0) {
            if (strcmp(symbolTable[i].type, expectedType) != 0) {
                char error[100];
                sprintf(error, "Tipo incompatível para variável '%s'", name);
                semanticError(error, yylineno);
            }
            return;
        }
    }
}

void semanticError(const char *message, int line) {
    fprintf(stderr, "Erro semântico na linha %d: %s\n", line, message);
    exit(1);
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

    int result = yyparse();

    /* Imprimir código intermediário */
    printf("\nCódigo intermediário gerado:\n");
    for (int i = 0; i < intermediateLine; i++) {
        printf("%s\n", intermediateCode[i]);
    }

    return result;
}
