/******************************************************************************\
 * This is the file that implements memcached_get and memcached_set			  *
 * functions.															      *
 *       																	  *
 * Created by: Jemmy Gazhenko October 24 2014								  *
\******************************************************************************/

#include <stdio.h>
#include "memcached.h"
#include <time.h>

int main(int argc, char const *argv[])
{

	clock_t start, end;
	double cpu_time_used;
	char data[] = {'H', 'E', 'Y', '!'};
	int length = 4;
	int seed = 435;

	start = clock();
	uint32_t result;

	int i;
	for (i = 0; i < 1000000000; i++)
	{
		result = murmurhash_3(data, length, seed);
	}
	end = clock();
	cpu_time_used = ((double) (end - start)) / CLOCKS_PER_SEC;

	printf("Finished! Result: %d\n", (uint32_t) result);
	printf("Took: %f seconds\n", (double) cpu_time_used);

	return 0;
}