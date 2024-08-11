#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

//Aluno: Matheus Lima Rodrigues

void geradorLexemas(char exp[])
{

    char lexemas[15];
    int k = 0, i = 0, nId = 1;

    memset(lexemas, '\0', sizeof(lexemas));

    for (i = 0; i < 50; i++)
    {
        if (isalpha(exp[i]))
        {

            lexemas[k] = exp[i];
            k++;

            if (exp[i + 1] == '=' || exp[i + 1] == '*' || exp[i + 1] == '+' || exp[i + 1] == '\0')
            {

                printf("<ID, %d,> ", nId);
                nId++;
                memset(lexemas, '\0', sizeof(lexemas));
                k = 0;
                if (exp[i + 1] == '\0')
                    break;
                printf("<OP, %c> ", exp[i + 1]);
                i++;
            }
        }
        if (isdigit(exp[i]))
        {
            lexemas[k] = exp[i];
            k++;
            if (exp[i + 1] == '=' || exp[i + 1] == '*' || exp[i + 1] == '+' || exp[i + 1] == '\0')
            {
                printf("<NUM, %s> ", lexemas);
                memset(lexemas, '\0', sizeof(lexemas));
                k = 0;
                if (exp[i + 1] == '\0')
                    break;
                printf("<OP, %c> ", exp[i + 1]);
                i++;
            }
        }
    }
}

int main()
{

    char expressao[] = "position = initial + rate * 60";
    int i = 0, j = 0;

    printf("Expressao: %s\n", expressao);
    // Elimina espaços em branco
    while (1)
    {
        if (expressao[i] == ' ')
        {
            while (expressao[i] == ' ')
            {
                j = i;
                while (expressao[j] != '\0')
                {
                    expressao[j] = expressao[j + 1];
                    j++;
                }
            }
        }

        // printf("%s\n", expressao);

        if (expressao[i] == '\0')
            break;
        i++;
    }

    /* printf("Insira uma expressao:");
    scanf("%[^\n]", expressao); */

    printf("Sem espacos: %s\n", expressao);
    geradorLexemas(expressao);

    return 0;
}