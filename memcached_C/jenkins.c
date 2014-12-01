/*****************************************************************************\
 * This file implements the jenkins one-at-a-time hash function for use in   * 
 * memchaed's get and set functions.                                                                             *
 * By: Jemmy Gazhenko October 25 2014                                                                            *
\*****************************************************************************/


#include <stdint.h>
#include <stdio.h>

uint32_t jenkins(char *data, int length);

int main(int argc, char const *argv[])
{
    char data[2];
    data[0] = 0x12;
    data[1] = 0x12;
    jenkins(data, 2);
    return 0;
}

 uint32_t jenkins(char *data, int length)
 {
        uint32_t hash = 0;
        uint32_t i;
        for (i = 0; i < length; i++)
        {
                printf("In the loop\n");
                hash = hash + data[i];
                printf("%u\n", hash);
                hash = hash + (hash << 10);
                printf("%u\n", hash);
                hash = hash ^ (hash >> 6);
                printf("%u\n", hash);
        }
        hash = hash + (hash << 3);
        printf("%u\n", hash);
        hash = hash ^ (hash >> 11);
        printf("%u\n", hash);
        hash = hash + (hash << 15);
        printf("%u\n", hash);
        return hash;

 }