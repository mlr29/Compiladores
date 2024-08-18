#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

// Aluno: Matheus Lima Rodrigues

typedef struct sLexemas
{
    char token[20];
    // char tipo[10]; //id, palavra reservada, pontuação
    struct sLexemas *proximo;
} TLexemas;

void limpaCodigo(char exp[])
{
    int i = 0, j;

    while (1)
    {
        if (exp[i] == '\t' || exp[i] == '\n')
        {
            while (exp[i] == '\t' || exp[i] == '\n')
            {
                j = i;
                while (exp[j] != '\0')
                {
                    exp[j] = exp[j + 1];
                    j++;
                }
            }
        }

        if (exp[i] == ' ')
        {
            while (exp[i] == ' ')
            {
                j = i;
                while (exp[j] != '\0')
                {
                    exp[j] = exp[j + 1];
                    j++;
                }
            }
        }

        if (exp[i] == '\0')
            break;
        i++;
    }
}

int palavraReservada(char p[]){
    p[strlen(p) + 1] = '\0';
    //printf("\n%s", p);
    if(strcmp(p, "public") == 0 || strcmp(p, "static") == 0 || 
        strcmp(p, "void") == 0 || strcmp(p, "int") == 0 || strcmp(p, "float") == 0){
        return 1;
    } else {
        return 0;
    }
}

int pontuacao (char p){
    if(p == '(' || p == ')' || p == '{' || p == '}' || p == ';' 
                || p == '/' || p == ',' || p == '.' || p == '=' || p == '[' 
                || p == ']'){
            return 1;
        } else {
            return 0;
        }
}

void geradorLexemas(TLexemas **lexemas, char exp[])
{
    int i = 0, j = 0;
    if (*lexemas == NULL)
    {
        *lexemas = malloc(sizeof(TLexemas));
        (*lexemas)->proximo = NULL;

        for (i = 0; isalnum(exp[i]) != 0; i++)
        {
            (*lexemas)->token[i] = exp[i];
            if(palavraReservada((*lexemas)->token)){
                break;
            }
        }
        //printf("\n%s  %d", (*lexemas)->token, strcmp((*lexemas)->token, "static") == 0);
        i++;
        (*lexemas)->token[i] = '\0';
    }

    TLexemas *novo = malloc(sizeof(TLexemas));
    (*lexemas)->proximo = novo;

    for (i = i; exp[i] != '\0'; i++)
    {
        if (isalpha(exp[i]))
        {
            while (isalnum(exp[i]))
            {
                novo->token[j] = exp[i];
                //printf("%c", novo->token);
                j++;
                if(palavraReservada(novo->token)){
                    //printf("\n%s  %d", novo->token, strcmp(novo->token, "static") == 0);
                    break;
                    }
                if(!(isalnum(exp[i+1])))
                    break;
                i++;
            }
            novo->token[j] = '\0';
            novo->proximo = NULL;
            //printf("\n%s  %d", novo->token, strcmp(novo->token, "static"));
            if (exp[i + 1] == '\0')
                return;
            j = 0;
        }
        else if (isdigit(exp[i]))
        {

            while (isdigit(exp[i]))
            {
                
                novo->token[j] = exp[i];
                
                // if (!(isdigit(exp[i + 1])))
                //     break;
                i++;
                j++;
            }
            novo->token[j] = '\0';
            novo->proximo = NULL;
            if (exp[i + 1] == '\0')
                return;
            j = 0;
        }
        else if (pontuacao(exp[i]))
        {
            novo->token[j] = exp[i];
            novo->token[j + 1] = '\0';
            novo->proximo = NULL;
            
            if (exp[i + 1] == '\0')
                return;
            j = 0;
        }

        novo->proximo = malloc(sizeof(TLexemas));
        novo = novo->proximo;
    }
}

void imprimeLexemas(TLexemas *lex)
{
    TLexemas *proximo = lex;
    int id = 1;
 
    printf("\nLista de Tokens\n");
    while (proximo != NULL)
    {
        //printf("\n%d", strlen(proximo->token));
        if (pontuacao(proximo->token[0]))
        {
            printf("\n<%c>", proximo->token[0]);
        }
        else
        {
            if(palavraReservada(proximo->token)){
                printf("\n<%s>", proximo->token);
            } else if (isdigit(proximo->token[0])){
        
                printf("\n<NUM, %s>", proximo->token);
            } else {
                printf("\n<ID, %d>", id);
                id++;
            }
        }
        proximo = proximo->proximo;
    }
}

void imprimeTabelaSimbolos (TLexemas *lex){
    TLexemas *proximo = lex;
    int i = 1,  lido = 0;

    printf("\n\nTabela de Simbolos\n");
    while (proximo != NULL)
    {
        //printf("\n%d", strlen(proximo->token));
        if (!(pontuacao(proximo->token[0])) && !(palavraReservada(proximo->token)) && !(isdigit(proximo->token[0]))){
            if(proximo->token[0] == 'a' || proximo->token[0] == 'b'){
                
                if(lido == 0)
                    printf("\n%d | %c", i, proximo->token[0]);
                lido = 1;
            } else{
            printf("\n%d | %s", i, proximo->token);
            i++;
            }
        }

        proximo = proximo->proximo;
    }
}

int main()
{
    TLexemas *listaLexemas = NULL;
    char expressao[] = "public static  void main   (String    [] args){\n\tint a = 10, b = 4;\n\tfloat c = a / b;\n\tSystem.out.print(c);\n}";

    printf("Expressao: \n%s\n", expressao);

    // Elimina espaço em branco, quebra de linha e tabulação do código
    limpaCodigo(expressao);

    printf("\nExpressao pre-formatada: \n%s\n", expressao);

    /* printf("Insira uma expressao:");
    scanf("%[^\n]", expressao); */

    geradorLexemas(&listaLexemas, expressao);

    imprimeLexemas(listaLexemas);
    imprimeTabelaSimbolos(listaLexemas);

    return 0;
}

// if(strcmp(novo->token, "public") || strcmp(novo->token, "static") || strcmp(novo->token, "void"))