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
void updateSymbolInitialization(char *name);

int labelCount = 0;  // Contador para labels únicos

extern int yylineno;

extern FILE *yyin;

typedef struct {
    char *name;
    char *type;
    int line;
    int initialized;
    int size;          // Tamanho do tipo
    char *scope;       // Escopo (global, local, etc)
    char *category;    // Variável, função, import, etc
} Symbol;

#define MAX_SYMBOLS 100

Symbol symbolTable[MAX_SYMBOLS];
int symbolCount = 0;

/* Buffer para armazenar o código intermediário */
char intermediateCode[1000][100];
int intermediateLine = 0;

extern void init_lexer();
extern void close_lexer();

/* Arquivo para código intermediário */
FILE *intermediate_out = NULL;

void init_intermediate_code() {
    intermediate_out = fopen("codigo-intermediario.txt", "w");
    if (!intermediate_out) {
        fprintf(stderr, "Erro ao criar arquivo de código intermediário\n");
        exit(1);
    }
    fprintf(intermediate_out, "\t\tCódigo Intermediário Gerado\n");
    fprintf(intermediate_out, "+--------------------------------+\n");
}

void close_intermediate_code() {
    if (intermediate_out) {
        fprintf(intermediate_out, "+--------------------------------+\n");
        fclose(intermediate_out);
        intermediate_out = NULL;
    }
}

%}

%union {
    int num;
    char *str;
    struct {
        char *type;
        int value;
        float fvalue;
    } expr;
}

%token <num> NUMBER_INT NUMBER_FLOAT
%token PACKAGE FUNC VAR IF ELSE FOR
%token <str> IDENTIFIER STRING KEYWORD INT_TYPE IMPORT
%token INC DECLARE_ASSIGN LT GT LE GE EQ NE
%token ERROR

%type <expr> expr condition
%type <str> comparison_op

%left LT GT LE GE EQ NE
%left '+' '-'
%left '*' '/'

%debug

%%

program:
    package_stmt import_stmt func_main_stmt
    ;

package_stmt:
    PACKAGE IDENTIFIER { printf("(Análise Sintática/Semântica): reconhecido: pacote %s\n", $2); }
    ;

import_stmt:
    import_stmt IMPORT STRING { addSymbol($3, $2, nId); printf("(Análise Sintática/Semântica): reconhecido: import %s\n", $3); }
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
    | if_stmt
    | if_else_stmt
    | for_stmt
    ;

int_var:
    VAR IDENTIFIER INT_TYPE ';' { addSymbol($2, $3, nId); printf("(Análise Sintática/Semântica): reconhecido: variável int %s\n", $2);}
    ;

atr_var_int:
    IDENTIFIER '=' NUMBER_INT ';'
    {
        checkVariableDeclared($1);
        checkVariableType($1, "int");
        updateSymbolInitialization($1);
        
        printf("(Análise Sintática/Semântica): reconhecido: atribuicao %s = %d\n", $1, $3);
        char code[100];
        sprintf(code, "%s = %d", $1, $3);
        generateIntermediateCode(code);
    }
    | IDENTIFIER '=' NUMBER_FLOAT ';'
    {
        checkVariableDeclared($1);
        checkVariableType($1, "int");
        semanticError("Não é possível atribuir um valor float a uma variável int", yylineno);
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
        
        printf("(Análise Sintática/Semântica): reconhecido: chamada de %s.%s\n", $1, $3);
        char code[100];
        sprintf(code, "CALL %s.%s, %s", $1, $3, $5);
        generateIntermediateCode(code);
    }
    | IDENTIFIER '.' IDENTIFIER '(' IDENTIFIER ')' ';'
    {
        // Verifica se a variável foi inicializada antes de ser usada
        for (int i = 0; i < symbolCount; i++) {
            if (strcmp(symbolTable[i].name, $5) == 0) {
                if (!symbolTable[i].initialized) {
                    char error[100];
                    sprintf(error, "Variável '%s' está sendo usada sem ter sido inicializada", $5);
                    semanticError(error, yylineno);
                }
                break;
            }
        }
        
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
        
        printf("(Análise Sintática/Semântica): reconhecido: chamada de %s.%s com variável %s\n", $1, $3, $5);
        char code[100];
        sprintf(code, "CALL %s.%s, %s", $1, $3, $5);
        generateIntermediateCode(code);
    }
    ;

if_stmt:
    IF condition '{' stmt_list '}'
    {
        char label[20];
        sprintf(label, "L%d", labelCount++);
        generateIntermediateCode("if_start:");
        generateIntermediateCode($2.type);
        generateIntermediateCode("jump_if_false end_if");
        generateIntermediateCode("end_if:");
    }
    ;

if_else_stmt:
    IF condition '{' stmt_list '}' ELSE '{' stmt_list '}'
    {
        char labelIf[20], labelElse[20];
        sprintf(labelIf, "L%d", labelCount++);
        sprintf(labelElse, "L%d", labelCount++);
        generateIntermediateCode("if_start:");
        generateIntermediateCode($2.type);
        generateIntermediateCode("jump_if_false else");
        generateIntermediateCode("else:");
        generateIntermediateCode("end_if:");
    }
    ;

for_stmt:
    FOR for_init condition ';' for_update '{' stmt_list '}'
    {
        generateIntermediateCode("for_start:");
        generateIntermediateCode("check_condition");
        generateIntermediateCode("jump_if_false end_for");
        generateIntermediateCode("update");
        generateIntermediateCode("jump for_start");
        generateIntermediateCode("end_for:");
    }
    ;

for_init:
    IDENTIFIER DECLARE_ASSIGN NUMBER_INT ';'
    {
        char code[100];
        sprintf(code, "init %s = %d", $1, $3);
        generateIntermediateCode(code);
    }
    ;

for_update:
    IDENTIFIER INC
    {
        char code[100];
        sprintf(code, "%s = %s + 1", $1, $1);
        generateIntermediateCode(code);
    }
    ;

condition:
    expr comparison_op expr
    {
        char code[100];
        sprintf(code, "compare %d %s %d", $1.value, $2, $3.value);
        generateIntermediateCode(code);
    }
    ;

comparison_op:
    LT { $$ = "<"; }
    | GT { $$ = ">"; }
    | LE { $$ = "<="; }
    | GE { $$ = ">="; }
    | EQ { $$ = "=="; }
    | NE { $$ = "!="; }
    ;

expr:
    NUMBER_INT
    {
        $$.type = "int";
        $$.value = $1;
    }
    | NUMBER_FLOAT
    {
        $$.type = "float";
        $$.fvalue = $1;
    }
    | IDENTIFIER
    {
        checkVariableDeclared($1);
        for (int i = 0; i < symbolCount; i++) {
            if (strcmp(symbolTable[i].name, $1) == 0) {
                $$.type = symbolTable[i].type;
                break;
            }
        }
    }
    | expr '+' expr
    {
        if (strcmp($1.type, $3.type) != 0) {
            semanticError("Tipos incompatíveis em operação de soma", yylineno);
        }
        $$.type = $1.type;
        if (strcmp($1.type, "int") == 0) {
            $$.value = $1.value + $3.value;
        } else {
            $$.fvalue = $1.fvalue + $3.fvalue;
        }
    }
    | expr '-' expr
    {
        if (strcmp($1.type, $3.type) != 0) {
            semanticError("Tipos incompatíveis em operação de subtração", yylineno);
        }
        $$.type = $1.type;
        if (strcmp($1.type, "int") == 0) {
            $$.value = $1.value - $3.value;
        } else {
            $$.fvalue = $1.fvalue - $3.fvalue;
        }
    }
    | expr '*' expr
    {
        if (strcmp($1.type, $3.type) != 0) {
            semanticError("Tipos incompatíveis em operação de multiplicação", yylineno);
        }
        $$.type = $1.type;
        if (strcmp($1.type, "int") == 0) {
            $$.value = $1.value * $3.value;
        } else {
            $$.fvalue = $1.fvalue * $3.fvalue;
        }
    }
    | expr '/' expr
    {
        if (strcmp($1.type, $3.type) != 0) {
            semanticError("Tipos incompatíveis em operação de divisão", yylineno);
        }
        if ($3.value == 0 || $3.fvalue == 0.0) {
            semanticError("Divisão por zero", yylineno);
        }
        $$.type = $1.type;
        if (strcmp($1.type, "int") == 0) {
            $$.value = $1.value / $3.value;
        } else {
            $$.fvalue = $1.fvalue / $3.fvalue;
        }
    }
    | '(' expr ')'
    {
        $$ = $2;
    }
    ;

%%

/* Função para adicionar símbolos à tabela */
void addSymbol(char *name, char *type, int line) {
    FILE *a = fopen("tsimbolo.txt", "w");

    if (symbolCount < MAX_SYMBOLS) {
        symbolTable[symbolCount].name = strdup(name);
        symbolTable[symbolCount].type = strdup(type);
        symbolTable[symbolCount].line = line;
        symbolTable[symbolCount].initialized = 0;
        
        // Define o tamanho baseado no tipo
        if (strcmp(type, "int") == 0) {
            symbolTable[symbolCount].size = 4;  // 4 bytes para int
        } else if (strcmp(type, "float") == 0) {
            symbolTable[symbolCount].size = 8;  // 8 bytes para float
        } else {
            symbolTable[symbolCount].size = 0;  // 0 para outros tipos
        }
        
        // Define a categoria
        if (strcmp(type, "import") == 0) {
            symbolTable[symbolCount].category = "import";
            symbolTable[symbolCount].scope = "global";
        } else {
            symbolTable[symbolCount].category = "variável";
            symbolTable[symbolCount].scope = "local";
        }

        // Escreve no arquivo com o novo formato
        if (a) {
            fprintf(a, "+-----------------+-----------+--------+-------------+--------+----------+------------+\n");
            fprintf(a, "| Nome            | Tipo      | Linha  | Inicializado| Tamanho| Escopo   | Categoria  |\n");
            fprintf(a, "+-----------------+-----------+--------+-------------+--------+----------+------------+\n");
            
            for (int i = 0; i <= symbolCount; i++) {
                fprintf(a, "| %-15s | %-9s | %-6d | %-11s | %-6d | %-8s | %-10s |\n",
                    symbolTable[i].name,
                    symbolTable[i].type,
                    symbolTable[i].line,
                    symbolTable[i].initialized ? "Sim" : "Não",
                    symbolTable[i].size,
                    symbolTable[i].scope,
                    symbolTable[i].category
                );
            }
            
            fprintf(a, "+-----------------+-----------+--------+-------------+--------+----------+------------+\n");
            fclose(a);
        } else {
            printf("erro ao abrir tabela de simbolos.");
        }

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
        if (intermediate_out) {
            fprintf(intermediate_out, "| %-30s |\n", code);
        }
        printf("(Código intermediário): %s\n", code);
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

// Adicione esta função para atualizar o status de inicialização
void updateSymbolInitialization(char *name) {
    for (int i = 0; i < symbolCount; i++) {
        if (strcmp(symbolTable[i].name, name) == 0) {
            symbolTable[i].initialized = 1;
            
            // Reescreve a tabela para atualizar o status
            addSymbol("", "", 0);  // Força reescrita da tabela
            break;
        }
    }
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

    init_lexer();  // Inicializa o analisador léxico
    init_intermediate_code();  // Inicializa o arquivo de código intermediário
    
    int result = yyparse();


    close_lexer();  // Fecha o arquivo de tokens
    close_intermediate_code();  // Fecha o arquivo de código intermediário
    fclose(yyin);   // Fecha o arquivo de entrada
    
    return result;
}
