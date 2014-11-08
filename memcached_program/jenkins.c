/*****************************************************************************\
 * This file implements the jenkins one-at-a-time hash function for use in   * 
 * memchaed's get and set functions.                                                                             *
 * By: Jemmy Gazhenko October 25 2014                                                                            *
\*****************************************************************************/


#include <stdint.h>
#include <stdio.h>


 uint32_t jenkins(char *data, int length)
 {
        uint32_t hash = 0;
        uint32_t i;
        for (i = 0; i < length; i++)
        {
		//printf("hash at [%d]: %d\n", i, hash);
                hash = hash + data[i];
		//printf("	> %d\n", hash);
                hash = hash + (hash << 10);
		//printf("	> %d\n", hash);
                hash = hash ^ (hash >> 6);
		//printf("	> %d\n", hash);
        }
		//printf("hash after adding everything: %d\n", hash);
        hash = hash + (hash << 3);
        //printf("    > %d\n", hash);
        hash = hash ^ (hash >> 11);
        //printf("    > %d\n", hash);
        hash = hash + (hash << 15);
		printf("Final Hash: %d\n", hash);
        return hash;

 }
