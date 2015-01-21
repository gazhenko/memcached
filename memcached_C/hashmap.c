/******************************************************************************\
 * This is the hashmap implementation of hashmap for use in memcached	      *
 * This file does not hash, assumes that key is already hashed		      *
 * Created by: Jemmy Gazhenko Oct 27 2014				      *
 * Thanks to https://github.com/petewarden			 	      *
\******************************************************************************/

 #include "hashmap.h"
 #include <stdio.h>
 #include <stdlib.h>
 #include <stdint.h>

 #define INITIAL_SIZE (10)
 #define MAX_CHAIN_LENGTH (8);

/* We need to keep keys and values */
 typedef struct _hashmap_element
 {
 	uint32_t *key;
 	int in_use;
 	char *data;
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
 * Hashes the key so it fits in the map
 */
uint32_t hashmap_hash_int(hashmap_map *map, uint32_t *key)
{

  //printf("hashmap_hash_int: initial\n");

	/* cast the hashmap */
	hashmap_map *m = (hashmap_map *) map;

	/* If full, return immediately */
	if (m -> size >= ((m -> table_size)/2) ) {
		return MAP_FULL;
	}

	uint32_t curr = (uint32_t) (*key) % m->table_size;

  //printf("hashmap_hash_int: curr initial = %d\n", curr);

	/* Linear probing */
	int i;
	for (i = 0; i < 8; i++) {
		if (m -> data[curr].in_use == 0) {
			return curr;
		}
		if (m -> data[curr].in_use == 1 && 
			(strcmp(m -> data[curr].key, key) == 0)) {
			return curr;
		}
		curr = (curr + 1) % m -> table_size;
	}

	return MAP_FULL;
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
 	if (!temp) {
    printf("MAP_OUT_OF_MEM\n");
    return MAP_OUT_OF_MEM;
  }

 	//hashmap_check_used_entries(map);

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

    	//printf("hashmap_rehash: Adding the %dth element\n", i);

 		int status;
 		if (current[i].in_use == 1) {
 			
 			//printf("hashmap_rehash: Found a used entry\n");
      		status = hashmap_set(map, current[i].key, current[i].data);
      		//hashmap_check_used_entries(map);
     		if (status != MAP_OK) return status;

    	}
 	}

  	//printf("hashmap_rehash: Finished rehashing, about to free\n");

 	free(current);
 	return MAP_OK;
 }
 

int hashmap_set(map_t in, uint32_t *key, char *value)
{

  	//printf("hashmap_set: Data = %s\n", value);
  	//printf("hashmap_set: Key = %u\n", *key);
	uint32_t index;
	hashmap_map *map;

	/* Cast the hashmap */
	map = (hashmap_map *) in;	

	/* Find a place to put our value */
	index = hashmap_hash_int(in, key);	

  	//printf("hashmap_set: index after hashmap_hash_int: %d\n", index);

	while(index == MAP_FULL)
	{
		if (hashmap_rehash(in) == MAP_OUT_OF_MEM)
		{
			return MAP_OUT_OF_MEM;
		}
    //printf("hashmap_set: Finished rehashing, moving on..\n");
		index = hashmap_hash_int(in, key);
	}


	/* Set the data */

	//printf("Something is wrong with storing the value into the map: %s\n", value);
  //printf("hashmap_set: About to store at this location: %d\n", index);
	map -> data[index].data = value;	
	map -> data[index].key = key;
	map -> data[index].in_use = 1;

	//hashmap_check_used_entries(map);

	map -> size++;

	//hashmap_print(map);
	
	//printf("hashmap_set: Current map size = %d\n", map -> size);
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
	current = hashmap_hash_int(in, key);

	/* Linear probing, if necessary */
	for (i = 0; i < 8; i++)
	{
		printf("hashmap_get: linear probing %dth time\n", i);
		int in_use = map -> data[current].in_use;
		uint32_t *keyy = map -> data[current].key;
		if (in_use == 1)
		{
			if (*keyy == *key)
			{
				data_found = (char *)(map -> data[current].data);
    			printf("I've found a match! %s\n", data_found);
				return map -> data[current].data;
			}
		}
		current = (current + 1) % map -> table_size;
		printf("hashmap_get: linear probing, next index to check = %d\n", current);
	}

 	data_found = "null";
  	printf("Didn't find anything..\n");

  	hashmap_print(map);

 	/* Not found! */
 	return data_found;
 }

 /*
  * Remove an element with that key from the map
  * !!! Not tested !!!
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

  /* Print off hashmap */
  void hashmap_print(map_t in)
  {
  	printf("Current Hashmap\n");
  	printf("---------------\n");
  	hashmap_map *map = (hashmap_map *) in;
  	if (map != NULL) 
  	{
  		int current;
  		int tableSize = map -> table_size;
  		for (current = 0; current < tableSize; current++)
  		{
  			if (map -> data[current].in_use)
  			{
  				uint32_t *keyy = map -> data[current].key;
  				char *dataa = map -> data[current].data;
  				// print hashmap element
  				printf("Element %d:\n", current);
  				printf("     > Key: %u\n", *keyy);
  				printf("     > Data: %s\n", dataa);
  			}
  			else
  			{
  				// print empty hashmap element
  				printf("Element %d:\n", current);
  				printf("     > Key: NULL\n");
  				printf("     > Data: NULL\n");
  			}
  		}
  	}
  }

  /* Traverse through hashmap and check which entries are in use currently */
  void hashmap_check_used_entries(map_t in)
  {

  	printf("====================================\n");
  	printf("Entries currently in use\n");
  	printf("------------------------\n");

  	hashmap_map *map = (hashmap_map *) in;

  	if (map != NULL)
  	{
  		int current;
  		int tableSize = map -> table_size;
  		for (current = 0; current < tableSize; current++)
  		{

  			if (map -> data[current].in_use)
  			{
  				printf("Element %d is currently in use\n", current);
  			}

  		}
  	}

	printf("====================================\n");

  }