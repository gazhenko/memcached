/******************************************************************************\
 * This is the hashmap implementation of hashmap for use in memcached		  *
 * This file does not hash, assumes that key is already hashed				  *
 * Created by: Jemmy Gazhenko Oct 27 2014									  *
 * Thanks to https://github.com/petewarden								 	  *
\******************************************************************************/

 #include "hashmap.h"
 #include <stdio.h>
 #include <stdlib.h>
 #include <stdint.h>

 #define INITIAL_SIZE (4294967296)
 #define MAX_CHAIN_LENGTH (8);

/* We need to keep keys and values */
 typedef struct _hashmap_element
 {
 	uint32_t *key;
 	int in_use;
 	any_t data;
 } hashmap_element;

 /* A hashmap has some maximum size and current size,
  * as well as the data to hold. */
 typedef struct _hashmap_map
 {
 	int table_size;
 	int size;
 	hashmap_element *data;
 } hashmap_map;

/*
 int main(void)
 {
 
 	
  printf("--- WELCOME TO JEMMY'S HASHMAP IMPLEMENTATION ---\n");

  printf("creating hashmap...\n");
  map_t map = hashmap_new();
  printf("finished creating hashmap!\n");
  printf("--------------------------\n");

  printf("What's in the table right now?...\n");
  char key = '0';
  char *res = hashmap_get(map, &key);
  printf("Result: %s\n", res);
  printf("--------------------------\n");

  printf("Let's try adding to the table...\n");
  key = '0';
  char data[12] = "hello, world";
  int res2 = hashmap_set(map, &key, data);
  printf("Result: %d\n", res2);
  printf("--------------------------\n");

  printf("What's in the table right now?...\n");
  key = '0';
  char *res3 = hashmap_get(map, &key);
  printf("Result: %s\n", res3);
  printf("--------------------------\n");

  printf("Let's try removing from the table...\n");
  key = '0';
  int res4 = hashmap_remove(map, &key);
  printf("Result: %d\n", res4);
  printf("--------------------------\n"); 

  printf("What's in the table right now?...\n");
  key = '0';
  char *res5 = hashmap_get(map, &key);
  printf("Result: %s\n", res5);
  printf("--------------------------\n");

  

 	//fill_table(table);
 	//show_table(table, length(table));

 	return 0;
 }
 */

/*
 * Return an empty hashmap, or NULL on failure.
 */
 map_t hashmap_new()
 {
 	hashmap_map* map = (hashmap_map *) malloc(sizeof(hashmap_map));
 	if (!map) goto err;

 	map -> data = 
 		(hashmap_element *) calloc(INITIAL_SIZE, sizeof(hashmap_element));
 	if (!map->data) goto err;

 	map -> table_size = INITIAL_SIZE;
 	map -> size = 0;

 	return map;

 	err:
 		if (map)
 			hashmap_free(map);
 		return NULL;
 }

/*
 * Doubles the size of the hashmap, and rehashes all the elements
 */
 int hashmap_rehash(map_t in)
 {
 	int i;
 	int old_size;
 	hashmap_element *current;

 	/* Setup the new elements */
 	hashmap_map *map = (hashmap_map *) in;
 	hashmap_element *temp = (hashmap_element *)
 		calloc(2 * map -> table_size, sizeof(hashmap_element));
 	if (!temp) return MAP_OUT_OF_MEM;

 	/* Update the array */
 	current = map -> data;
 	map -> data = temp;

 	/* Update the size */
 	old_size = map -> table_size;
 	map -> table_size = 2 * map -> table_size; 
 	map -> size = 0;

 	/* Rehash the elements */
 	for (i = 0; i < old_size; i++)
 	{
 		int status;
 		if (current[i].in_use == 0)
 			continue;

 		status = hashmap_set(map, current[i].key, current[i].data);
 		if (status != MAP_OK) return status;
 	}

 	free(current);
 	return MAP_OK;
 }
 

int hashmap_set(map_t in, uint32_t *key, char *value)
{
  printf("Checkpoint 5\n");
	uint32_t index;
	hashmap_map *map;

  printf("Checkpoint 6\n");
	/* Cast the hashmap */
	map = (hashmap_map *) in;

  printf("Checkpoint 7\n");
	/* Find a place to put our value */
	index = *key;

  printf("Checkpoint 8\n");
	while(index == MAP_FULL)
	{
		if (hashmap_rehash(in) == MAP_OUT_OF_MEM)
		{
			return MAP_OUT_OF_MEM;
		}
		index = *key;
	}

  printf("Checkpoint 9\n");

	/* Set the data */

  printf("Okay, something wrong with setting data. Data: %s\n", value);
  printf("Okay, it's not the value. What is current index? %d\n", index);

	map -> data[index].data = value;
  printf("Checkpoint 10\n");
	map -> data[index].key = key;
  printf("Checkpoint 11\n");
	map -> data[index].in_use = 1;
  printf("Checkpoint 12\n");
	map -> size++;
  printf("Checkpoint 13\n");

  printf("data added! %s\n", (char *)(map -> data[index].data));
  return MAP_OK;
}

/*
 * Get the pointer out of the hashmap with a key
 */
 char *hashmap_get(map_t in, uint32_t *key)
 {
 	  uint32_t current;
 	  int i;
 	  hashmap_map *map;
 	  char *data_found;

   	/* Cast the hashmap */
   	map = (hashmap_map *) in;

   	/* Find data location */
   	// curr = hashmap_hash_int(m, key); THIS SHOULD ALREADY BE HASHED
    current = *key;

   	/* Linear probing, if necessary */
   	for (i = 0; i < 8; i++)
   	{
   		int in_use = map -> data[current].in_use;
   		if (in_use == 1)
   		{
   			if (strcmp(map -> data[current].key, key) == 0)
   			{
   				data_found = (char *)(map -> data[current].data);
          printf("I've found a match! %s\n", data_found);
   				return data_found;
   			}
   		}
   		current = (current + 1) % map -> table_size;
    }

 	data_found = NULL;
  printf("Didn't find anything..\n");

 	/* Not found! */
 	return data_found;
 }

 /*
  * Remove an element with that key from the map
  */
  int hashmap_remove(map_t in, uint32_t *key)
  {
    	int i;
    	uint32_t current;
    	hashmap_map *map;

    	/* cast the hashmap */
    	map = (hashmap_map *) in;

    	/* Find the key */ // We have this already
      current = *key;

    	/*Linear probing, if necessary */
    	for (i = 0; i < 8; i++)
    	{
    		int in_use = map -> data[current].in_use;
    		if (in_use == 1)
    		{
    			if (strcmp(map -> data[current].key, key) == 0)
    			{
    				/* Blank out the fields */
    				map -> data[current].in_use = 0;
    				map -> data[current].data = NULL;
    				map -> data[current].key = NULL;

    				/* Reduce the size */
    				map -> size--;
    				return MAP_OK;
    			}
    		}
    		current = (current + 1) % map -> table_size;
      }

  	/* Data not found */
  	return MAP_MISSING;
  }

  /* Deallocate the hashmap */
  void hashmap_free(map_t in)
  {
  	hashmap_map *map = (hashmap_map *) in;
  	free(map -> data);
  	free(map);
  }

  /* Return the length of the hashmap */
  int hashmap_length(map_t in)
  {
  	hashmap_map *map = (hashmap_map *) in;
  	if (map != NULL) return map -> size;
  	else return 0;
  }