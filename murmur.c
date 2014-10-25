/******************************************************************************\
 * This is the file that does the hash for MEMCACHED_GET operation			  * 
 * It uses MurMurHash3 as its hashing algorithm because of its simplicity,    *
 * speed, and spread.														  *
 * Created by: Jemmy Gazhenko October 24 2014								  *
\******************************************************************************/

#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include "memcached.h"

uint32_t murmurhash_3(const char *data, uint32_t length, uint32_t seed) 
{

	//printf("Data: %s\n", data);
	//printf("Length: %d\n", length);
	//printf("Seed: %d\n", seed);

	// magical constants
	static const uint32_t c1 = 0xcc9e2d51;
	static const uint32_t c2 = 0x1b873593;
	static const uint32_t c3 = 0xc2b2ae35;
	static const uint32_t r1 = 15;
	static const uint32_t r2 = 13;
	static const uint32_t m = 5;
	static const uint32_t n = 0x36546b64;

	// Initialize the hash to a random value
	uint32_t hash = seed;

	// split data into 1 byte blocks
	const int nblocks = length / 4;
	// add data to blocks
	const uint32_t *blocks = (const uint32_t *) data;
	int i;
	for (i = 0; i < nblocks; i++)
	{
		// for each chunk
		uint32_t cur_data = blocks[i];
		// multiply by 0xcc9e2d51
		cur_data = cur_data * c1;
		// bit shifting magic
		cur_data = (cur_data << r1) | (cur_data >> (32 - r1));
		// multiply by 0x1b873593
		cur_data = cur_data * c2;
		// XOR with running hash
		hash = hash ^ cur_data;
		// some more bit shift magic
		hash = ((hash << r2) | (hash >> (32 - r2)));
		// multiply by 5 + 0x36546b64
		hash = hash * m + n;
	}

	// TO-DO: Support for data not divisible by 4

	hash = hash ^ length;
	hash = hash ^ (hash >> 16);
	hash = hash * 0x85ebca6b;
	hash = hash ^ (hash >> 13);
	hash = hash * c3;
	hash = hash ^ (hash >> 16);


	return hash;

}