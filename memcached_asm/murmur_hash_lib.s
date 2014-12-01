/*
 * This is a library function for the murmur3 hash. It has two modes:
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

.def CONST_C1 0x512d9ecc
.def CONST_C2 0x1b873593
.def CONST_C3 0xc2b2ae35
.def CONST_R1 15
.def CONST_R3 17
.def CONST_R2 13
.def CONST_R4 19
.def CONST_M 5
.def CONST_N 0x36546b64
.def CONST_C4 0x85ebca6b
.def SEED 0x1234
.def BIT_MASK_32 0x00000000ffffffff

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
 *		jali %r5, murmur_infinite	 
 */

 murmur_infinite:

 		/*
 		 * generate random number
 		 */

 		 jali %r5, rand
 		 ori %r1, %r0, #0
 		 jali %r5, rand
 		 shli %r1, %r1, #16
 		 or %r0, %r0, %r1

 		/*
 		 * hash the random number
 		 */

 		 /* start with seed */
 		 andi %r10, %r10, #0
 		 addi %r10, %r10, SEED

 		 /* multiply by 0xcc9e2d51 */
 		 muli %r0, %r0, CONST_C1
 		 andi %r0, %r0, BIT_MASK_32

 		 /* bit shifting magic */
 		 shli %r1, %r0, CONST_R1
 		 andi %r1, %r1, BIT_MASK_32
 		 shri %r2, %r0, CONST_R3
 		 andi %r2, %r2, BIT_MASK_32
 		 or %r0, %r1, %r2

 		 /* multiply by 0x1b873593 */
 		 muli %r0, %r0, CONST_C2
 		 andi %r0, %r0, BIT_MASK_32

 		 /* XOR with running hash */
 		 xor %r10, %r10, %r0
 		 andi %r10, %r10, BIT_MASK_32

 		 /* some more bit shift magic */
 		 shli %r1, %r10, CONST_R2
 		 andi %r1, %r1, BIT_MASK_32
 		 shri %r2, %r10, CONST_R4
 		 andi %r2, %r2, BIT_MASK_32
 		 or %r10, %r1, %r2

 		 /* multiply by 5 + 0x36546b64 */
 		 muli %r10, %r10, CONST_M
 		 addi %r10, %r10, CONST_N
 		 andi %r2, %r2, BIT_MASK_32

 		 /* hash = hash ^ length */
 		 xori %r10, %r10, #4;

 		 /* hash = hash ^ (hash >> 16) */
 		 shri %r1, %r10, #16
 		 xor %r10, %r10, %r1
 		 andi %r10, %r10, BIT_MASK_32

 		 /* hash = hash * 0x85ebca6b */
 		 muli %r10, %r10, CONST_C4
 		 andi %r10, %r10, BIT_MASK_32

 		 /* hash = hash ^ (hash >> 13) */
 		 shri %r1, %r10, #13
 		 xor %r10, %r10, %r1
 		 andi %r10, %r10, BIT_MASK_32

 		 /* hash = hash * c3 */
 		 muli %r10, %r10, CONST_C3
 		 andi %r10, %r10, BIT_MASK_32

 		 /* hash = hash ^ (hash >> 16) */
 		 shri %r1, %r10, #16
 		 xor %r10, %r10, %r1
 		 andi %r10, %r10, BIT_MASK_32

 		 ori %r7, %r10, #0
 		 jali %r5, printhex

 		 jmpi murmur_infinite

 		 trap


.align 4096
.perm rw

/*
 * Print statements (clean)
 */

/*
 * Print statements (debug)
 */
 
 debug:	.string "Running murmur_infinite\n"