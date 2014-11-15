/******************************************************************************\
 * This file implements the jenkins one-at-a-time hash function for use in    *
 * memcached's get and set functions.                                         *
 * By: Jemmy Gazhenko November 15, 2014                                       *
\******************************************************************************/

/*         Variables          *\
 * -------------------------- *
   %r0 : data to be hashed
   %r1 : length of data
   %r2 : hash
\******************************/

.align 4096
.perm x
.entry
.global
entry:		ldi %r0, vector_a; 	/* Argument 0 */
			ldi %r1, length;	/* Argument 1 */

			/* create a hash variable, set to 0 */
			andi %r2, %r2, #0; 
			/* set up loop */
loop:		ld %r10, %r0, #0;
			addi %r0, %r0, __WORD; /* increment vector */
			/* hash = hash + data[i] */
			add %r2, %r2, %r10;
			/* hash = hash + (hash << 10) */
			shli %r2, %r2, #10;
			/* hash = hash ^ (hash >> 6) */
			ld %r3, %r2, #0;
			shri %r2, %r2, #6;
			xor %r2, %r2, %r3;

			/* hash = hash + (hash << 3) */
			ld %r3, %r2, #0;
			shli %r2, %r2, #3;
			add %r2, %r2, %r3;
			/* hash = hash ^ (hash >> 11) */
			ld %r3, %r2, #0;
			shri %r2, %r2, #11;
			xor %r2, %r2, %r3;
			/* hash = hash + (hash << 15) */
			ld %r3, %r2, #0;
			shli %r2, %r2, #15;
			add %r2, %r2, %r3;

			/* store hash into stack */
			/* Print result to console */
			ori %r7, %r2, #0;		
			jali %r5, printdec;

			trap;

.align 4096
.perm rw
vector_a:	.word 1
length: 	.word 1