#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char const *argv[])
{
    /* code */
    // Create the two input vectors
    int i, j;
    const int LIST_SIZE = 1024;
    const int ELEMENT_SIZE = 255;
    char A[LIST_SIZE][ELEMENT_SIZE];
    char randomstring[ELEMENT_SIZE];
    char randomchar;

    for (i = 0; i < LIST_SIZE; i++)
    {
        for (j = 0; j < ELEMENT_SIZE; j++)
        {

            randomstring[j] = 'A' + (random() % 26);            
        }
        strcpy(A[i], randomstring);
        memset(randomstring, 0, ELEMENT_SIZE * 8);
    }
    return 0;
}