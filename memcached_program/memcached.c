/******************************************************************************\
 * This is the file that implements memcached_get and memcached_set           *
 * functions.                                                                 *
 *                                                                            *
 * Created by: Jemmy Gazhenko October 24 2014                                 *
\******************************************************************************/
#include <stdio.h>
#include <time.h>
#include <stdint.h>
#include "jenkins.h"
#include "hashmap.h"

#define HASH_FUNCTION "jenkins"

map_t map;

void memcached_set(char *data);

int main(int argc, char const *argv[])
{
        
        printf("creating hashmap...\n");
        map = hashmap_new();
        printf("finished creating hashmap!\n");
        printf("--------------------------\n");

        printf("testing memcached_set\n");
        char data[12] = "hello, world";
        printf("Checkpoint 1\n");
        memcached_set(data);
        printf("Checkpoint 14\n");

        return 0;
}

void memcached_set(char *data) 
{

        /* Pseudocode

                if HASHFUNCTION == jenkins do
                        key <- jenkins(value, length)
                        hashmap_set(key, value)
                else if HASHFUNCTION == murmur do
                        key <- murmur(value, length, SEED_VALUE)
                        hashmap_set(key, value)
                
        */

        if (HASH_FUNCTION == "jenkins")
        {
                printf("Checkpoint 2\n");
                uint32_t key = jenkins(data, sizeof(data));
                printf("Checkpoint 4\n");
                int res = hashmap_set(map, &key, data);
                printf("res: %d\n", res);
        }
        else if (HASH_FUNCTION == "murmur")
        {
                // not yet implemented
        }

}

char *memcached_get(char *key) 
{

}