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

void memcached_set(char *data, int size);
char *memcached_get(uint32_t *key);

int main(int argc, char const *argv[])
{
        
        printf("creating hashmap...\n");
        map = hashmap_new();
        printf("finished creating hashmap!\n");
        printf("--------------------------\n");

        printf("testing memcached_set\n");
        char data[12] = "hello, world";
        memcached_set(data, 12);	
	printf("--------------------------\n");

/*
	printf("testing memcached_set\n");
        char data2[58] = "Lets try another set of data. Maybe this will work better.";
        memcached_set(data2, 58);	
	printf("--------------------------\n");

	printf("testing memcached_set\n");
        char data3[106] = "This is a very long set of data. Let's see if it hashes well and we get a good placement in the hashmap!";
        memcached_set(data3, 106);	
	printf("--------------------------\n");
*/

        printf("testing memcached_get\n");
        uint32_t key1 = jenkins(data, 12);
        //char *dataRes1 = memcached_get(&key1);
        printf("result 1: %s\n", memcached_get(&key1));
        printf("--------------------------\n");

        return 0;
}

void memcached_set(char *data, int size) 
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
                uint32_t key = jenkins(data, size);
                int res = hashmap_set(map, &key, data);
        }
        else if (HASH_FUNCTION == "murmur")
        {
                // not yet implemented
        }

}

char *memcached_get(uint32_t *key) 
{
	/* Pseudocode

                if (isInHashmap(key)) do
                        return hashmap_get(key)
                else
                        return "Key not found in map"

	*/

        char *data = hashmap_get(map, key);
        if (data == "null") return data;
        else return data = "KEY_NOT_FOUND";
}
