#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

// Aluno: Matheus Lima Rodrigues

typedef struct sLexemas
{
    char token[20];
    struct sLexemas *proximo;
} TLexemas;

typedef struct sTabelaSimbolos
{
    char token[20];
    int lido;
    struct sTabelaSimbolos *proximo;
} TTabSimbolo;

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

int palavraReservada(char p[])
{
    p[strlen(p) + 1] = '\0';

    if (strcmp(p, "public") == 0 || strcmp(p, "static") == 0 ||
        strcmp(p, "void") == 0 || strcmp(p, "int") == 0 || strcmp(p, "float") == 0)
    {
        return 1;
    }
    else
    {
        return 0;
    }
}

int pontuacao(char p)
{
    if (p == '(' || p == ')' || p == '{' || p == '}' || p == ';' || p == '/' || p == ',' || p == '.' || p == '=' || p == '[' || p == ']')
    {
        return 1;
    }
    else
    {
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
            if (palavraReservada((*lexemas)->token))
            {
                break;
            }
        }

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
                
                j++;
                if (palavraReservada(novo->token))
                {
                    break;
                }
                if (!(isalnum(exp[i + 1])))
                    break;
                i++;
            }
            novo->token[j] = '\0';
            novo->proximo = NULL;

            if (exp[i + 1] == '\0')
                return;
            j = 0;
        }
        else if (isdigit(exp[i]))
        {

            while (isdigit(exp[i]))
            {

                novo->token[j] = exp[i];

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
       
        if (pontuacao(proximo->token[0]))
        {
            printf("\n<%c>", proximo->token[0]);
        }
        else
        {
            if (palavraReservada(proximo->token))
            {
                printf("\n<%s>", proximo->token);
            }
            else if (isdigit(proximo->token[0]))
            {
                printf("\n<NUM, %s>", proximo->token);
            }
            else
            {
                printf("\n<ID, %d>", id);
                id++;
            }
        }
        proximo = proximo->proximo;
    }
}

void imprimeTabelaSimbolos(TTabSimbolo *tab)
{
    TTabSimbolo *proximo = tab;
    int i = 1;

    printf("\n\nTabela de Simbolos\n");
    while (proximo != NULL)
    {
        
        if (!(pontuacao(proximo->token[0])) && !(palavraReservada(proximo->token)) && !(isdigit(proximo->token[0])) && proximo->lido == 0)
        {
            printf("\n%d | %s", i, proximo->token);
            i++;
        }

        proximo = proximo->proximo;
    }
}

void geradorTabelaSimbolos(TLexemas *lex, TTabSimbolo **tab)
{
    if (*tab == NULL)
    {
        *tab = malloc(sizeof(TTabSimbolo));

        strcpy((*tab)->token, lex->token);
        (*tab)->proximo = NULL;
        (*tab)->lido = 0;
    }

    TLexemas *proximo = lex;
    TTabSimbolo *novo = *tab;
    TTabSimbolo *ultimo = *tab;
    char simboloExistente[20];
    while (novo->proximo != NULL)
    {
        novo = novo->proximo;
    }

    while (proximo != NULL)
    {
        strcpy(simboloExistente, ultimo->token);
        while (strcmp(proximo->token, simboloExistente) != 0 && strcmp(simboloExistente, "inexistente") != 0)
        {
            ultimo = ultimo->proximo;
            if (ultimo == NULL)
            {
                strcpy(simboloExistente, "inexistente");
            }
            else
            {
                strcpy(simboloExistente, ultimo->token);
            }
            
        }

        if (ultimo == NULL)
        {

            novo->proximo = malloc(sizeof(TTabSimbolo));
            novo = novo->proximo;

            strcpy(novo->token, proximo->token);
            novo->lido = 0;
            novo->proximo = NULL;
        }
        ultimo = *tab;
        proximo = proximo->proximo;
    }
}

int main()
{
    TTabSimbolo *tabelaSimbolos = NULL;
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

    geradorTabelaSimbolos(listaLexemas, &tabelaSimbolos);
    imprimeTabelaSimbolos(tabelaSimbolos);

    return 0;
}
