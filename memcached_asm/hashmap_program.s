/*
 * An example file for using the hashmap library. Mostly for testing 
 * purposes but uses actual calling conventions.
 *
 * Author: Jemmy Gazhenko
 * Date: Dec. 1, 2014
 * Version: 1
 */

 .align 4096
 .perm x
 .global
 .entry

 entry:		 ldi %r0, test_key		/* Memory location of key */
 			 ldi %r1, test_value	/* Memory location of value */
 			 ld %r0, %r0, #0
 			 ld %r1, %r1, #0

 			/*
 			 * Create a new hashmap
 			 */

 			 jali %r31, hashmap_new

 			/*
 			 * Print out the current hashmap
 			 */

 			 jali %r31, hashmap_print

 			/*
 			 * Test adding to the hashmap
 			 */

 			 jali %r31, hashmap_set_hack

 			/*
 			 * Print out the current hashmap
 			 */

 			 jali %r31, hashmap_print
	
			 

 			 halt

 .align 4096
 .perm rw

 test_key:		.word 0x0000
 test_value:	.word 0x0005
