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
#include <stdlib.h>
#include <string.h>

#ifdef __APPLE__
#include <OpenCL/opencl.h>
#else
#include <CL/cl.h>
#endif

#define MAX_SOURCE_SIZE (0x100000)

#define HASH_FUNCTION "jenkins"

map_t map;

void memcached_set(char *data, int size);
char *memcached_get(uint32_t *key);
char** create_array (char x, char y);

int main(int argc, char const *argv[])
{

/*        
    printf("creating hashmap...\n");
    map = hashmap_new();
    printf("finished creating hashmap!\n");
    printf("--------------------------\n");

    printf("testing memcached_set\n");
    char data[12] = "hello, world";
    memcached_set(data, 12);	
	printf("--------------------------\n");

	printf("testing memcached_set\n");
    char data2[58] = "Lets try another set of data. Maybe this will work better.";        memcached_set(data2, 58);	
	printf("--------------------------\n");

	printf("testing memcached_set\n");
    char data3[106] = "This is a very long set of data. Let's see if it hashes well and we get a good placement in the hashmap!";
    memcached_set(data3, 106);	
	printf("--------------------------\n");

    printf("testing memcached_get\n");
    uint32_t key1 = jenkins(data2, 58);
    //printf("result 1: %s\n", memcached_get(&key1));
    printf("adfasf %s\n", memcached_get(&key1));
    printf("--------------------------\n");
*/


    // Create the input vector
    int i, j;
    const int LIST_SIZE = 8;
    const int ELEMENT_SIZE = 8;

    char** A = create_array(LIST_SIZE, ELEMENT_SIZE);
    //char** DEBUG_BUFFER = create_array(LIST_SIZE, ELEMENT_SIZE);

    for (i = 0; i < LIST_SIZE; i++)
    {
        for (j = 0; j < ELEMENT_SIZE-1; j++)
        {
            A[i][j] = 'A' + (random() % 26);        
        }
        A[i][ELEMENT_SIZE-1] = '\0';    }


    // Load the kernel source code into the array source_str
    FILE *fp;
    char *source_str;
    size_t source_size;

    fp = fopen("parallel_code.cl", "r");
    if (!fp)
    {
        fprintf(stderr, "Failed to load kernel.\n");
        exit(1);
    }
    source_str = (char *)malloc(MAX_SOURCE_SIZE);
    source_size = fread( source_str, 1, MAX_SOURCE_SIZE, fp);
    fclose(fp);

    // Get platform and device information
    cl_platform_id platform_id = NULL;
    cl_device_id device_id = NULL;
    cl_uint ret_num_devices;
    cl_uint ret_num_platforms;
    cl_int ret = clGetPlatformIDs(1, &platform_id, &ret_num_platforms);
    ret = clGetDeviceIDs(platform_id, CL_DEVICE_TYPE_GPU, 1, &device_id, &ret_num_devices);

    // Create an OpenCL context
    cl_context context = clCreateContext(NULL, 1, &device_id, NULL, NULL, &ret);

    // Create a command queue
    cl_command_queue command_queue = clCreateCommandQueue(context, device_id, 0, &ret);

    // Create memory buffers on the device for each vector
    cl_mem a_mem_obj = clCreateBuffer(context, CL_MEM_READ_ONLY, 
        LIST_SIZE * sizeof(char) * ELEMENT_SIZE, NULL, &ret);
    //cl_mem debug_mem_obj = clCreateBuffer(context, CL_MEM_WRITE_ONLY, 
    //	LIST_SIZE * sizeof(char) * ELEMENT_SIZE, NULL, &ret);
    cl_mem c_mem_obj = clCreateBuffer(context, CL_MEM_WRITE_ONLY, 
        LIST_SIZE * sizeof(uint32_t), NULL, &ret);

    // Copy the list A to its memory buffer
    ret = clEnqueueWriteBuffer(command_queue, a_mem_obj, CL_TRUE, 0,
        LIST_SIZE * sizeof(char) * ELEMENT_SIZE, A, 0, NULL, NULL);

    // Create a program from the kernel source
    cl_program program = clCreateProgramWithSource(context, 1, 
        (const char **)&source_str, (const size_t *)&source_size, &ret);

    // Build the program
    ret = clBuildProgram(program, 1, &device_id, NULL, NULL, NULL);

    // Create the OpenCL kernel
    cl_kernel kernel = clCreateKernel(program, "vector_add", &ret);

    // Set the arguments of the kernel
    ret = clSetKernelArg(kernel, 0, sizeof(cl_mem), (void *)&a_mem_obj);
    ret = clSetKernelArg(kernel, 1, sizeof(cl_mem), (void *)&c_mem_obj);
    //ret = clSetKernelArg(kernel, 2, sizeof(cl_mem), (void *)&debug_mem_obj);

    // Execute the OpenCL kernel on the list
    size_t global_item_size = LIST_SIZE; // Process the entire list
    size_t local_item_size = 1; // Divide work items into groups of 64
    ret = clEnqueueNDRangeKernel(command_queue, kernel, 1, NULL, 
        &global_item_size, &local_item_size, 0, NULL, NULL);

    printf("--------------------------------------\n");
    for (i = 0; i < LIST_SIZE; i++)
    {
    	printf("A[%d]: %s\n", i, A[i]);
    }

    // Read the memory buffer C on the device to the local variable C
    uint32_t *C = (uint32_t *)malloc(sizeof(uint32_t)*LIST_SIZE);
    ret = clEnqueueReadBuffer(command_queue, c_mem_obj, CL_TRUE, 0, 
        LIST_SIZE * sizeof(uint32_t), C, 0, NULL, NULL);
    //ret = clEnqueueReadBuffer(command_queue, debug_mem_obj, CL_TRUE, 0, 
    //    LIST_SIZE * sizeof(char) * ELEMENT_SIZE, DEBUG_BUFFER, 0, NULL, NULL);

    // Display the result to the screen
    printf("--------------------------------------\n");
    for (i = 0; i < LIST_SIZE; i++)
    {
    	printf("hash(%s) = %d\n", A[i], C[i]);
    	printf("hash check: %d\n", jenkins(A[i], 8));
    //	printf("debug%s\n", DEBUG_BUFFER[i]);
    }

    // Clean up
    ret = clFlush(command_queue);
    ret = clFinish(command_queue);
    ret = clReleaseKernel(kernel);
    ret = clReleaseProgram(program);
    ret = clReleaseMemObject(a_mem_obj);
    ret = clReleaseMemObject(c_mem_obj);
    ret = clReleaseCommandQueue(command_queue);
    ret = clReleaseContext(context);
    //free(A);
    //free(DEBUG_BUFFER);
    free(C);

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
    if (data != "null") return data;
    else return data = "KEY_NOT_FOUND";
}


char** create_array (char x, char y)
{

	char i;
	char** arr = (char**) malloc(sizeof (char*) * x);
	for (i = 0; i < x; i++)
	{

		arr[i] = (char*) malloc (sizeof (char) * y);
		memset (arr[i], 0, sizeof (arr[i]));

	}
	return arr;

}