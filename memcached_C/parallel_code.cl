__kernel void vector_add(__global const char *A, 
						 __global uint32_t *C) 
						 //__global char *DEBUG_BUFFER)
{
	// Get the index of the current element to be processed
	int i = get_global_id(0);

	// OpenCL, do the thing
	char *data = (char *)malloc(sizeof(char) * 8);
	strcpy(data, A[i]);
	DEBUG_BUFFER[i] = A[i];
	int length = 8;
	unsigned int hash = 0;
    unsigned int k;
    for (k = 0; k < length; ++k)
    {
            hash = hash + data[k];
            hash = hash + (hash << 10);
            hash = hash ^ (hash >> 6);
    }
    hash = hash + (hash << 3);
    hash = hash ^ (hash >> 11);
    hash = hash + (hash << 15);

	C[i] = hash;
}