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
			 st %r1, %r10, OFFSET_ELEMENT_DATA
			 st %r0, %r10, OFFSET_ELEMENT_KEY
			 st %r15, %r10, OFFSET_ELEMENT_IN_USE

			/*
			 * Increment size of hashmap
			 */

			 ldi %r10, hashmap 
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
			 rtop @p1, %r17
			 @p1 ? jmpi map_full
			 jmprt %r31

map_full:	 ldi %r0, MAP_FULL
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

 			 mod %r11, %r1, %r11
 			 jmprt %r30

/*
 * Helper function for traversing to the right spot in hashmap
 */

 hashmap_traverse:

 			 ldi %r10, hashmap 		/* Initial load hashmap location */
 			 addi %r10, %r10, OFFSET_ELEMENT
 			 ori %r12, %r11, #0 	/* save the initial index */ 
 			 rtop @p0, %r11
 			 @p0 ? jmpi traverse 	/* jump if r11 == 0 */
 			 
 			 											ldi %r7, debug5
 			 											jali %r5, puts

 			 jmprt %r30

 traverse:	 addi %r10, %r10, OFFSET_ELEMENT_FULL
 			 subi %r12, %r12, #1
 			 rtop @p0, %r12
 			 @p0 ? jmpi traverse
 			 jmprt %r30