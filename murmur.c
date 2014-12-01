/******************************************************************************\
 * This is the file that does the hash for MEMCACHED_GET operation			  * 
 * It uses MurMurHash3 as its hashing algorithm because of its simplicity,    *
 * speed, and spread.														  *
 * Created by: Jemmy Gazhenko October 24 2014								  *
\******************************************************************************/

#include <math.h>
#include <stdint.h>
#include <stdio.h>

uint32_t murmurhash_3(const char *data, uint32_t length, uint32_t seed);

int main(int argc, char const *argv[])
{
	char data[4];
	data[0] = 0x01;
	data[1] = 0x02;
	data[2] = 0x03;
	data[3] = 0x04;

	uint32_t seed = 0x1234;
	murmurhash_3(data, 4, seed);
	return 0;
}

uint32_t murmurhash_3(const char *data, uint32_t length, uint32_t seed) 
{

	//printf("Data: %s\n", data);
	//printf("Length: %d\n", length);
	//printf("Seed: %d\n", seed);

	// magical constants
	//static const uint32_t c1 = 0xcc9e2d51;
	static const uint32_t c1 = 3432918353;
	static const uint32_t c2 = 0x1b873593;
	static const uint32_t c3 = 0xc2b2ae35;
	static const uint32_t r1 = 15;
	static const uint32_t r2 = 13;
	static const uint32_t m = 5;
	static const uint32_t n = 0x36546b64;

	// Initialize the hash to a random value
	uint32_t hash = seed;

	// split data into 4 byte blocks
	const int nblocks = length / 4;
	// add data to blocks
	const uint32_t *blocks = (const uint32_t *) data;

	uint32_t data_0 = data[0] << 24;
	uint32_t data_1 = data[1] << 16;
	uint32_t data_2 = data[2] << 8;
	uint32_t data_3 = data[3];

	uint32_t data_new = data_0 | data_1 | data_2 | data_3;

	int i;
	for (i = 0; i < nblocks; i++)
	{
		// for each chunk
		uint32_t cur_data = data_new;
		printf("cur_data: %u\n", cur_data);
		// multiply by 0xcc9e2d51
		cur_data = cur_data * c1;
		printf("c1: %u\n", c1);
		printf("%u\n", cur_data);
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
	printf("%u\n", hash);
	hash = hash ^ (hash >> 16);
	printf("%u\n", hash);
	hash = hash * 0x85ebca6b;
	printf("%u\n", hash);
	hash = hash ^ (hash >> 13);
	printf("%u\n", hash);
	hash = hash * c3;
	printf("%u\n", hash);
	hash = hash ^ (hash >> 16);

	printf("%u\n", hash);

	return hash;

}