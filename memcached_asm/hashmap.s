/*
 * This is a library of functions that implement a hashmap in assembly.
 * 
 * Functions:
 *		- hashmap_new(): Creates a new hashmap on the stack and returns the 
 *						 memory location of the hashmap.
 *		- hashmap_set(): Adds the key and value pair to the hashmap.
 * 		- hashmap_get(): Returns the value from the hashmap.
 *		- hashmap_remove(): Removes the key and value pair from the hashmap.
 *		- hashmap_free(): Clears the hashmap.
 * 		- hashmap_length(): Size of hashmap (number of key/value pairs entered,
 *							not the allocated size).
 *		- hashmap_print(): Prints out the entire hashmap to console.
 *
 * Hashmap Structure in Memory:
 *
 *		0x00	table size of hashmap
 *		0x04	number of elements in hashmap
 *		0x08	element[0]:	key
 *		0x0C				value
 *		0x10 				data location
 *		0x14 	element[1]: key
 *		0x18				value
 *		0x1C				data location
 *		...		...
 *
 * Author: Jemmy Gazhenko
 * Date: Dec. 1, 2014
 * Version: 1
 */

 .perm rw

 /*
  * Constants
  */

 .def MAP_MISSING 3			/* No such element */
 .def MAP_FULL 2			/* Hashmap is full */
 .def MAP_OUT_OF_MEM 1		/* Out of memory */
 .def MAP_OK 0				/* It's all good */

 .def INITIAL_SIZE 10		
 .def MAX_CHAIN_LENGTH 8

 /*
  * To implement a "hashmap_map" struct
  * Offsets are # of words
  */

 .def OFFSET_TABLE_SIZE 0
 .def OFFSET_SIZE 4
 .def OFFSET_ELEMENT 8

/*
 * To implement a "hashmap_element" struct
 */

 .def OFFSET_ELEMENT_KEY 0
 .def OFFSET_ELEMENT_IN_USE 4
 .def OFFSET_ELEMENT_DATA 8
 .def OFFSET_ELEMENT_FULL 12 /* Go to next element */



 .def OFFSET_TABLE_SIZE_WORD 0
 .def OFFSET_SIZE_WORD 8
 .def OFFSET_ELEMENT_WORD 16

/*
 * To implement a "hashmap_element" struct
 */

 .def OFFSET_ELEMENT_KEY_WORD 0
 .def OFFSET_ELEMENT_IN_USE_WORD 8
 .def OFFSET_ELEMENT_DATA_WORD 16
 .def OFFSET_ELEMENT_FULL_WORD 24 /* Go to next element */

/*
 * Set up the function
 */

 .align 4096
 .perm x
 .global

/*
 * This function creates a new hashmap on the stack.
 * Come to think of it, this function isn't really needed because we don't 
 * cast.
 */

 hashmap_new:

 			 ldi %r10, hashmap

 			/*
 			 * Set all the memory locations to initial values
 			 */

 			 ld %r11, %r10, OFFSET_TABLE_SIZE
 			 andi %r11, %r11, #0
 			 addi %r11, %r11, INITIAL_SIZE
 			 st %r11, %r10, OFFSET_TABLE_SIZE

 			 ld %r11, %r10, OFFSET_SIZE
 			 andi %r11, %r11, #0
 			 st %r11, %r10, OFFSET_SIZE

 			 jmprt %r31


/*
 * This function adds the key and value pair to the hashmap.
 * One caveat, the value must be EXACTLY the size of an word (2 bytes). 
 *
 * Input: %r0 (key)
 * 	      %r1 (value)
 * Output: %r0 (error code)
 *
 * Registers Used: %r10 (pointer to hashmap)
 * 				   %r11 (hashed key)
 *				   %r12 (index in hashmap)
 *
 * Calling convention:
 *		
 *		ldi %r0, key
 *		ldi %r1, value
 *		jali %r31, hashmap_set
 */

 .align 4096
 .perm x
 .global

hashmap_set:

															ori %r7, %r0, #0
															jali %r5, printdec 

															ori %r7, %r1, #0 
															jali %r5, printdec



 			/*
 			 * hash the key to find a location in the hashmap
 			 */

			 jali %r30, hashmap_hash_int

 			/*
 			 * If map is full, we need to rehash
 			 */

 			 /* --- TO_DO --- */

 			/*
 			 * Traverse to the right spot in the hashmap
 			 */

		 	 jali %r30, hashmap_traverse

 			/*
 			 * Now we check if the spot is taken
 			 */

 			 andi %r17, %r17, #0 				
 			 addi %r17, %r17, MAX_CHAIN_LENGTH 		

check_in_use:			 
			 ori %r13, %r10, OFFSET_ELEMENT_IN_USE 	

		 												ldi %r7, debug2
		 												jali %r5, puts

		 												ori %r7, %r13, #0
		 												jali %r5, printdec

			 rtop @p0, %r13
			 @p0 ? jmpi not_in_use
			 jmpi in_use

			/*
			 * If not in use, set the values and return
			 */

not_in_use:	 
			
														ldi %r7, debug4
														jali %r5, puts

			 andi %r15, %r15, #0
			 addi %r15, %r15, #1

			 											ldi %r7, debug6
			 											jali %r5, puts

			 											ori %r7, %r10, #0
			 											jali %r5, printdec

			 											ldi %r7, debug7
			 											jali %r5, puts

			 											ldi %r7, hashmap 
			 											jali %r5, printdec

			 st %r1, %r10, OFFSET_ELEMENT_DATA
			 st %r0, %r10, OFFSET_ELEMENT_KEY
			 st %r15, %r10, OFFSET_ELEMENT_IN_USE

			/*
			 * Increment size of hashmap
			 */

			 ldi %r10, hashmap

			 jali %r30, hashmap_print_table_size /* Need this here because of
			 										bug in harptool! Oh no! */

			 ld %r16, %r10, OFFSET_SIZE
			 addi %r16, %r16, #1
			 st %r16, %r10, OFFSET_SIZE

			 /* Check the stack */
			 ldi %r10, hashmap 
			 											ld %r7, %r10, OFFSET_SIZE
			 											jali %r5, printdec

			 ldi %r0, MAP_OK
			 jmprt %r31

 			/*
 			 * If its in use, go to the next spot
 			 */

in_use:		 
														ldi %r7, debug3
														jali %r5, puts

			 subi %r17, %r17, #1
			 addi %r11, %r11, #1
			 addi %r10, %r10, OFFSET_ELEMENT_FULL
			 rtop @p1, %r17
			 @p1 ? jmpi map_full
			 jmpi check_in_use

map_full:	 ldi %r0, MAP_FULL
			 jmprt %r31


.align 4096
 .perm x
 .global

hashmap_set_hack:
															ldi %r7, debug13
															jali %r5, puts

															ori %r7, %r0, #0
															jali %r5, printdec 

															ldi %r7, debug14
															jali %r5, puts

															ori %r7, %r1, #0 
															jali %r5, printdec

			/* hash the key, debug value here is 0 */

			andi %r11, %r11, #0
			addi %r15, %r11, #1

			/* no need to traverse */

			/* no need to check if in use */

			/* just add to hashmap */

			ldi %r20, hashmap 
			st %r15, %r20, OFFSET_SIZE
			addi %r20, %r20, OFFSET_ELEMENT
			st %r0, %r20, OFFSET_ELEMENT_KEY
			st %r1, %r20, OFFSET_ELEMENT_DATA
			st %r15, %r20, OFFSET_ELEMENT_IN_USE

			jmprt %r31



/*
 * Helper function for hashing a key to fit in the current hashmap
 */

 hashmap_hash_int:

 			/*
 			 * load the current table size of hashmap
 			 */

 			 ldi %r10, hashmap
 			 ld %r11, %r10, OFFSET_TABLE_SIZE

 			/*
 			 * return the key % table_size
 			 */

 			 mod %r11, %r0, %r11

 			 											ldi %r7, debug8
 			 											jali %r5, puts

 			 											ori %r7, %r11, #0
 			 											jali %r5, printdec

 			 jmprt %r30

/*
 * Helper function for traversing to the right spot in hashmap
 */

 hashmap_traverse:

 			 ldi %r10, hashmap 		/* Initial load hashmap location */

 			 											ldi %r7, debug7
 			 											jali %r5, puts

 			 											ori %r7, %r10, #0
 			 											jali %r5, printdec

 			 addi %r10, %r10, OFFSET_ELEMENT
 			 ori %r12, %r11, #0 	/* save the initial index */ 

 			 											ldi %r7, debug12
 			 											jali %r5, puts

 			 											ori %r7, %r10, #0
 			 											jali %r5, printdec

 			 iszero @p0, %r12
 			 @p0 ? jmpi finish_traverse 	/* jump if r12 == 0 */
 			 jmpi traverse

 finish_traverse:

 			 jmprt %r30

 traverse:	 

 														ldi %r7, debug11
 														jali %r5, puts

 			 addi %r10, %r10, OFFSET_ELEMENT_FULL
 			 subi %r12, %r12, #1

 			 											ldi %r7, debug12
 			 											jali %r5, puts

 			 											ori %r7, %r10, #0
 			 											jali %r5, printdec


 			 rtop @p0, %r12
 			 @p0 ? jmpi traverse
 			 jmprt %r30


/*
 * This function prints out the entire hashmap to the console.
 * 
 * Input: -none-
 * Output: -none-
 *
 * Registers Used: %r10 (pointer to hashmap)
 *
 * Calling convention:
 *		
 *		jali %r31, hashmap_print
 */

 .align 4096
 .perm x
 .global

hashmap_print:

			/*
			 * Print: "--- Hashmap ---"
			 */
			 ldi %r7, title
			 jali %r5, puts

			/*
			 * Print: "Table Size: "
			 */

			 ldi %r7, table_size
			 jali %r5, puts

			 ldi %r20, hashmap 
			 ld %r7, %r20, OFFSET_TABLE_SIZE
			 jali %r5, printdec

			/*
			 * Print: "Number of elements: "
			 */

			 ldi %r7, num_elements
			 jali %r5, puts

			 ldi %r20, hashmap
			 ld %r7, %r20, OFFSET_SIZE
			 jali %r5, printdec

			/*
			 * Print first element
			 */

			 ldi %r7, element
			 jali %r5, puts
			 andi %r12, %r12, #0
			 ori %r7, %r12, #0
			 jali %r5, printdec

			 ldi %r20, hashmap 						/* r20 = 0 */
			 addi %r11, %r20, OFFSET_ELEMENT 		/* r11 = 12 */

			 ldi %r7, element_loc
			 jali %r5, puts
			 ori %r7, %r20, #0
			 jali %r5, printdec

			 ldi %r7, key
			 jali %r5, puts
			 ld %r7, %r11, OFFSET_ELEMENT_KEY		/* r7 = mem[12] */
			 jali %r5, printdec

			 ldi %r7, value
			 jali %r5, puts
			 ld %r7, %r11, OFFSET_ELEMENT_DATA		/* r7 = mem[20] */
			 jali %r5, printdec

			 ldi %r7, in_use
			 jali %r5, puts
			 ld %r7, %r11, OFFSET_ELEMENT_IN_USE	/* r7 = mem[16] */
			 jali %r5, printdec

			 /*
			 * Print second element
			 */

			 ldi %r7, element
			 jali %r5, puts
			 addi %r12, %r12, #1
			 ori %r7, %r12, #0
			 jali %r5, printdec

			 addi %r11, %r11, OFFSET_ELEMENT 		/* r11 = 12 */

			 ldi %r7, element_loc
			 jali %r5, puts
			 ori %r7, %r11, #0
			 jali %r5, printdec

			 ldi %r7, key
			 jali %r5, puts
			 ld %r7, %r11, OFFSET_ELEMENT_KEY		/* r7 = mem[12] */
			 jali %r5, printdec

			 ldi %r7, value
			 jali %r5, puts
			 ld %r7, %r11, OFFSET_ELEMENT_DATA		/* r7 = mem[20] */
			 jali %r5, printdec

			 ldi %r7, in_use
			 jali %r5, puts
			 ld %r7, %r11, OFFSET_ELEMENT_IN_USE	/* r7 = mem[16] */
			 jali %r5, printdec

			 /*
			 * Print third element
			 */

			 ldi %r7, element
			 jali %r5, puts
			 addi %r12, %r12, #1
			 ori %r7, %r12, #0
			 jali %r5, printdec

			 addi %r11, %r11, OFFSET_ELEMENT 		/* r11 = 12 */

			 ldi %r7, element_loc
			 jali %r5, puts
			 ori %r7, %r11, #0
			 jali %r5, printdec

			 ldi %r7, key
			 jali %r5, puts
			 ld %r7, %r11, OFFSET_ELEMENT_KEY		/* r7 = mem[12] */
			 jali %r5, printdec

			 ldi %r7, value
			 jali %r5, puts
			 ld %r7, %r11, OFFSET_ELEMENT_DATA		/* r7 = mem[20] */
			 jali %r5, printdec

			 ldi %r7, in_use
			 jali %r5, puts
			 ld %r7, %r11, OFFSET_ELEMENT_IN_USE	/* r7 = mem[16] */
			 jali %r5, printdec

			 /*
			 * Print fourth element
			 */

			 ldi %r7, element
			 jali %r5, puts
			 addi %r12, %r12, #1
			 ori %r7, %r12, #0
			 jali %r5, printdec

			 addi %r11, %r11, OFFSET_ELEMENT 		/* r11 = 12 */

			 ldi %r7, element_loc
			 jali %r5, puts
			 ori %r7, %r11, #0
			 jali %r5, printdec

			 ldi %r7, key
			 jali %r5, puts
			 ld %r7, %r11, OFFSET_ELEMENT_KEY		/* r7 = mem[12] */
			 jali %r5, printdec

			 ldi %r7, value
			 jali %r5, puts
			 ld %r7, %r11, OFFSET_ELEMENT_DATA		/* r7 = mem[20] */
			 jali %r5, printdec

			 ldi %r7, in_use
			 jali %r5, puts
			 ld %r7, %r11, OFFSET_ELEMENT_IN_USE	/* r7 = mem[16] */
			 jali %r5, printdec

			 /*
			 * Print fifth element
			 */

			 ldi %r7, element
			 jali %r5, puts
			 addi %r12, %r12, #1
			 ori %r7, %r12, #0
			 jali %r5, printdec

			 addi %r11, %r11, OFFSET_ELEMENT 		/* r11 = 12 */

			 ldi %r7, element_loc
			 jali %r5, puts
			 ori %r7, %r11, #0
			 jali %r5, printdec

			 ldi %r7, key
			 jali %r5, puts
			 ld %r7, %r11, OFFSET_ELEMENT_KEY		/* r7 = mem[12] */
			 jali %r5, printdec

			 ldi %r7, value
			 jali %r5, puts
			 ld %r7, %r11, OFFSET_ELEMENT_DATA		/* r7 = mem[20] */
			 jali %r5, printdec

			 ldi %r7, in_use
			 jali %r5, puts
			 ld %r7, %r11, OFFSET_ELEMENT_IN_USE	/* r7 = mem[16] */
			 jali %r5, printdec

			 /*
			 * Print sixth element
			 */

			 ldi %r7, element
			 jali %r5, puts
			 addi %r12, %r12, #1
			 ori %r7, %r12, #0
			 jali %r5, printdec

			 addi %r11, %r11, OFFSET_ELEMENT 		/* r11 = 12 */

			 ldi %r7, key
			 jali %r5, puts
			 ld %r7, %r11, OFFSET_ELEMENT_KEY		/* r7 = mem[12] */
			 jali %r5, printdec

			 ldi %r7, value
			 jali %r5, puts
			 ld %r7, %r11, OFFSET_ELEMENT_DATA		/* r7 = mem[20] */
			 jali %r5, printdec

			 ldi %r7, in_use
			 jali %r5, puts
			 ld %r7, %r11, OFFSET_ELEMENT_IN_USE	/* r7 = mem[16] */
			 jali %r5, printdec

			 /*
			 * Print seventh element
			 */

			 ldi %r7, element
			 jali %r5, puts
			 addi %r12, %r12, #1
			 ori %r7, %r12, #0
			 jali %r5, printdec

			 addi %r11, %r11, OFFSET_ELEMENT 		/* r11 = 12 */

			 ldi %r7, element_loc
			 jali %r5, puts
			 ori %r7, %r11, #0
			 jali %r5, printdec

			 ldi %r7, key
			 jali %r5, puts
			 ld %r7, %r11, OFFSET_ELEMENT_KEY		/* r7 = mem[12] */
			 jali %r5, printdec

			 ldi %r7, value
			 jali %r5, puts
			 ld %r7, %r11, OFFSET_ELEMENT_DATA		/* r7 = mem[20] */
			 jali %r5, printdec

			 ldi %r7, in_use
			 jali %r5, puts
			 ld %r7, %r11, OFFSET_ELEMENT_IN_USE	/* r7 = mem[16] */
			 jali %r5, printdec

			 /*
			 * Print eigth element
			 */

			 ldi %r7, element
			 jali %r5, puts
			 addi %r12, %r12, #1
			 ori %r7, %r12, #0
			 jali %r5, printdec

			 addi %r11, %r11, OFFSET_ELEMENT 		/* r11 = 12 */

			 ldi %r7, element_loc
			 jali %r5, puts
			 ori %r7, %r11, #0
			 jali %r5, printdec

			 ldi %r7, key
			 jali %r5, puts
			 ld %r7, %r11, OFFSET_ELEMENT_KEY		/* r7 = mem[12] */
			 jali %r5, printdec

			 ldi %r7, value
			 jali %r5, puts
			 ld %r7, %r11, OFFSET_ELEMENT_DATA		/* r7 = mem[20] */
			 jali %r5, printdec

			 ldi %r7, in_use
			 jali %r5, puts
			 ld %r7, %r11, OFFSET_ELEMENT_IN_USE	/* r7 = mem[16] */
			 jali %r5, printdec

			 /*
			 * Print ninth element
			 */

			 ldi %r7, element
			 jali %r5, puts
			 addi %r12, %r12, #1
			 ori %r7, %r12, #0
			 jali %r5, printdec

			 addi %r11, %r11, OFFSET_ELEMENT 		/* r11 = 12 */

			 ldi %r7, element_loc
			 jali %r5, puts
			 ori %r7, %r11, #0
			 jali %r5, printdec

			 ldi %r7, key
			 jali %r5, puts
			 ld %r7, %r11, OFFSET_ELEMENT_KEY		/* r7 = mem[12] */
			 jali %r5, printdec

			 ldi %r7, value
			 jali %r5, puts
			 ld %r7, %r11, OFFSET_ELEMENT_DATA		/* r7 = mem[20] */
			 jali %r5, printdec

			 ldi %r7, in_use
			 jali %r5, puts
			 ld %r7, %r11, OFFSET_ELEMENT_IN_USE	/* r7 = mem[16] */
			 jali %r5, printdec

			 /*
			 * Print tenth element
			 */

			 ldi %r7, element
			 jali %r5, puts
			 addi %r12, %r12, #1
			 ori %r7, %r12, #0
			 jali %r5, printdec

			 addi %r11, %r11, OFFSET_ELEMENT 		/* r11 = 12 */

			 ldi %r7, element_loc
			 jali %r5, puts
			 ori %r7, %r11, #0
			 jali %r5, printdec

			 ldi %r7, key
			 jali %r5, puts
			 ld %r7, %r11, OFFSET_ELEMENT_KEY		/* r7 = mem[12] */
			 jali %r5, printdec

			 ldi %r7, value
			 jali %r5, puts
			 ld %r7, %r11, OFFSET_ELEMENT_DATA		/* r7 = mem[20] */
			 jali %r5, printdec

			 ldi %r7, in_use
			 jali %r5, puts
			 ld %r7, %r11, OFFSET_ELEMENT_IN_USE	/* r7 = mem[16] */
			 jali %r5, printdec

			 ldi %r7, print_end
			 jali %r5, puts

			 jmprt %r31


 .align 4096
 .perm x
 .global

hashmap_print_first:

			/*
			 * Print: "--- Hashmap ---"
			 */
			 ldi %r7, title
			 jali %r5, puts

			/*
			 * Print: "Table Size: "
			 */

			 ldi %r7, table_size
			 jali %r5, puts

			 ldi %r10, hashmap 
			 ld %r7, %r10, OFFSET_TABLE_SIZE
			 jali %r5, printdec

			/*
			 * Print: "Number of elements: "
			 */

			 ldi %r7, num_elements
			 jali %r5, puts

			 ldi %r10, hashmap
			 ld %r7, %r10, OFFSET_SIZE
			 jali %r5, printdec

			/*
			 * Print: "----- END -----"
			 */

			 ldi %r7, print_end
			 jali %r5, puts

			 jmprt %r31


.align 4096
 .perm x
 .global

hashmap_print_hack:

			 /*
			 * Print: "--- Hashmap ---"
			 */
			 ldi %r7, title
			 jali %r5, puts

			 ldi %r0, hashmap 
			 ori %r1, %r0, #200

			 jali %r31, printstack

			 ldi %r7, print_end
			 jali %r5, puts

			 jmprt %r30

 .align 4096
 .perm x
 .global

hashmap_print_table_size:

			/*
			 * Print: "--- Hashmap ---"
			 */
			 ldi %r7, title
			 jali %r5, puts

			/*
			 * Print: "Table Size: "
			 */

			 ldi %r7, table_size
			 jali %r5, puts

			 ldi %r10, hashmap 
			 ld %r7, %r10, OFFSET_TABLE_SIZE
			 jali %r5, printdec

			 jmprt %r30


/*
 * Stack 
 */
 
 .align 4096
 .perm rw

/*
 * Print Strings
 */

 title:			.string "----------------------- HASHMAP ----------------------\n"
 table_size:	.string "Table Size: "
 num_elements:	.string "Number of Elements: "
 element:		.string "o Element "
 element_loc:	.string "     -> Location: "
 key:			.string "     -> Key:    "
 value:			.string "     -> Value:  "
 in_use:		.string "     -> In Use: "
 print_end:		.string "------------------------- END -------------------------\n"

/*
 * Debug Strings
 */

 debug0:	.string "I am here\n"
 debug1:	.string "I am in set\n"
 debug2:	.string "Checking if in use -> "
 debug3:	.string "In use!\n"
 debug4:	.string "Not in use!\n"
 debug5: 	.string "Final index: 0"
 debug6:	.string "Checking save location -> "	
 debug7:	.string "Starting location of hashmap -> "
 debug8:	.string "hashed key is -> "	
 debug9:	.string "index to reach -> "
 debug10:	.string "current index -> " 
 debug11:	.string "in traverse\n"
 debug12:	.string "current location in hashmap datastructure -> "
 debug13:	.string "Input %r0: "
 debug14:	.string "Input %r1: "

/*
 * The Hashmap starts here!
 */
 hashmap: 	.space 4096