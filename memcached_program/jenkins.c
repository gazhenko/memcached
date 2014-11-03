/*****************************************************************************\
 * This file implements the jenkins one-at-a-time hash function for use in   * 
 * memchaed's get and set functions.                                                                             *
 * By: Jemmy Gazhenko October 25 2014                                                                            *
\*****************************************************************************/


#include <stdint.h>
#include <stdio.h>


 uint32_t jenkins(char *data, int length)
 {
        printf("Checkpoint 3\n");
        uint32_t hash = 0;
        int i;
        for (i = 0; i < length; i++)
        {
                hash = hash + data[i];
                hash = hash = + (hash << 10);
                hash = hash ^ (hash >> 6);
        }
        hash = hash + (hash << 3);
        hash = hash ^ (hash >> 11);
        hash = hash + (hash << 15);
        return hash;

 }
