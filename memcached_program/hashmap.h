#ifndef __HASHMAP_H__
#define __HASHMAP_H__

#include <stdint.h>

#define MAP_MISSING -3 		/* No such element */
#define MAP_FULL -2 		/* Hashmap is full */
#define MAP_OUT_OF_MEM -1	/* Out of memory */
#define MAP_OK 0			/* OK */

typedef void *any_t;
typedef any_t map_t;

/* Function Declarations */
extern map_t hashmap_new();
extern int hashmap_set(map_t in, uint32_t *key, char *value);
extern char *hashmap_get(map_t in, uint32_t *key);
extern int hashmap_remove(map_t in, uint32_t *key);
extern void hashmap_free(map_t in);
extern int hashmap_length(map_t in);
extern void hashmap_print(map_t in);

#endif