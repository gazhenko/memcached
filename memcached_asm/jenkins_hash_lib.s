/*
 * This is a library function for the jenkins hash. It has two modes:
 *     - Infinite Random Hashing:
 *	       When called, it runs an infinite loop, hashing a random string of
 * 		   of values.
 *     - Hashing a given input:
 *		   Hashes a given stack location and length (in bytes) of input
 *
 * Author: Jemmy Gazhenko
 * Date: Dec. 1, 2014
 * Version: 1
 */

/*
 * Constants
 */

 .def BIT_MASK_32 0x00000000ffffffff
 .def BIT_MASK_8 0x00000000000000ff

/*
 * Set up the function
 */

 .align 4096
 .perm x
 .global

/*							
 * infinite loop function
 *
 * Input: -none-
 * Output: -none-
 *
 * calling convention:
 *
 *		jali %r5, jenkins_infinite	 
 */							 

 jenkins_infinite:

 		/*
 		 * generate random number
 		 */

 		 jali %r5, rand
		 andi %r0, %r0, BIT_MASK_8

 		/*
 		 * hash the random number
 		 */

 		 ori %r10, %r0, #0

 		 ori %r11, %r10, #0
 		 shli %r10, %r10, #10
 		 add %r10, %r10, %r11
 		 andi %r10, %r10, BIT_MASK_32

 		 ori %r11, %r10, #0
 		 shri %r10, %r10, #6
 		 xor %r10, %r10, %r11
 		 andi %r10, %r10, BIT_MASK_32

 		 ori %r11, %r10, #0
		 shli %r10, %r10, #3
		 add %r10, %r10, %r11
		 andi %r10, %r10, BIT_MASK_32

		 ori %r11, %r10, #0
		 shri %r10, %r10, #11
		 xor %r10, %r10, %r11
		 andi %r10, %r10, BIT_MASK_32

		 ori %r11, %r10, #0
		 shli %r10, %r10, #15
		 add %r10, %r10, %r11
		 andi %r10, %r10, BIT_MASK_32

		 ori %r7, %r10, #0		
		 jali %r5, printhex

		 jmpi jenkins_infinite


/*							
 * stack hash function
 *
 * Input: %r0 (data location in stack)
 *		  %r1 (data length, in bytes)
 * Output: %r0 (hashed data)
 *
 * calling convention:
 *
 *		ldi %r0, data
 *		ldi %r1, length
 *		ld %r1, %r1, #0
 *		jali %r5, jenkins_stack 
 */	

 jenkins_stack:

 		/*
 		 * set up the variables
 		 */

 		/*
 		 * run the loop on the current byte
 		 */

 		/*
 		 * Is there any more left to hash?
 		 */

 		/*
 		 * Do final bit shifting
 		 */

 		/*
 		 * return final hashed value
 		 */

 		 trap

/*							
 * random number generator
 *
 * Input: %r0 (data location in stack)
 *		  %r1 (data length, in bytes)
 * Output: %r0 (hashed data)
 *
 * calling convention:
 *
 *		st %r0, %r9 rand_seed
 *		jali %r5, jenkins_stack 
 */	


.align 4096
.perm rw

value:	.word 0x00

/*
 * Print statements (clean)
 */

/*
 * Print statements (debug)
 */
