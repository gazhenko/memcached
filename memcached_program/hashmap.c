/******************************************************************************\
 * This is the hashmap implementation of hashmap for use in memcached		  *
 * This file does not hash, assumes that key is already hashed				  *
 * Created by: Jemmy Gazhenko Oct 27 2014									  *
 * Thanks to https://github.com/petewarden								 	  *
\******************************************************************************/

 #include "hashmap.h"
 #include <stdio.h>

/* We need to keep keys and values */
 typedef struct _hashmap_element
 {
 	char *key;
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


 int main(void)
 {
 	/* This is our hash table */
 	

 	fill_table(table);
 	show_table(table, length(table));

 	return 0;
 }

/*
 * Return an empty hashmap, or NULL on failure.
 */
 map_t hashmap_new()
 {
 	hashmap_map* map = (hashmap_map *) malloc(sizeof(hashmap_map));
 	if (!m) goto err;

 	m -> data = 
 		(hashmap_element *) calloc(INITIAL_SIZE, sizeof(hashmap_element));
 	if (!m->data) goto err;

 	m -> table_size = INITIAL_SIZE;
 	m -> size = 0;

 	return m;

 	err:
 		if (m)
 			hashmap_free(m);
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

 		status = hashmap_put(m, current[i].key, current[i].data);
 		if (status != MAP_OK) return status;
 	}

 	free(current);
 	return MAP_OK;
 }
 

void hashmap_set(map_t in, char *key, char *value)
{
	int index;
	hashmap_map *map;

	/* Cast the hashmap */
	map = (hashmap_map *) in;

	/* Find a place to put our value */
	index = hashmap_map(in, key);
	while(index == MAP_FULL)
	{
		if (hashmap_rehash(in) == MAP_OMEM)
		{
			return MAP_OUT_OF_MEM;
		}
		index = hashmap_hash(in, key);
	}

	/* Set the data */
	map -> data[index].data = value;
	map -> data[index].key = key;
	map -> data[index].in_use = 1;
	map -> size++;
}

/*
 * Get the pointer out of the hashmap with a key
 */
 char *hashmap_get(map_t in, char *key)
 {
 	int current;
 	int i;
 	hashmap_map *map;
 	char *data_found;

 	/* Cast the hashmap */
 	map = (hashmap_map *) in;

 	/* Find data location */
 	// curr = hashmap_hash_int(m, key); THIS SHOULD ALREADY BE HASHED

 	/* Linear probing, if necessary */
 	for (i = 0; i < MAX_CHAIN_LENGTH; i++)
 	{
 		int in_use = map -> data[current].in_use;
 		if (in_use == 1)
 		{
 			if (strcmp(map -> data[current].key, key) == 0)
 			{
 				*data_found = (map -> data[current].data);
 				return data_found;
 			}
 		}
 		current = (current + 1) % map -> table_size;
 	}

 	data_found = NULL;

 	/* Not found! */
 	return data_found;
 }

 /*
  * Remove an element with that key from the map
  */
  int hashmap_remove(map_t in, char *key)
  {
  	int i;
  	int current;
  	hashmap_map *map;

  	/* cast the hashmap */
  	map = (hashmap_map *) in;

  	/* Find the key */ // We have this already

  	/*Linear probing, if necessary */
  	for (i = 0; i < MAX_CHAIN_LENGTH; i++)
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