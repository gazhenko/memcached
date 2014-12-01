/* Constants */
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


.align 4096
.perm x
.entry
.global

entry:		
			ldi %r0, vector_a;
			ldi %r1, length;
			ld %r11, %r1, #0;
			ld %r24, %r1, #0; /* const lenth */

			andi %r2, %r2, #0; 		/* hash = 0 		*/
			addi %r2, %r2, SEED;	/* hash = SEED 		*/

			/* We need to split up the data into 4 byte blocks */
			divi %r11, %r11, #4;

			/* Just in case.. */
			andi %r20, %r20, #0;
			andi %r21, %r21, #0;
			andi %r22, %r22, #0;
			andi %r23, %r23, #0;

loop:		
			ld %r20, %r0, #0;		/* data = *data;	*/
			addi %r0, %r0, __WORD;
			ld %r21, %r0, #0;
			addi %r0, %r0, __WORD;
			ld %r22, %r0, #0;
			addi %r0, %r0, __WORD;
			ld %r23, %r0, #0;
			addi %r0, %r0, __WORD;	/* data += 4		*/

			shli %r20, %r20, #24;
			shli %r21, %r21, #16;
			shli %r22, %r22, #8;

			ori %r10, %r20, #0;
			or %r10, %r10, %r21;
			or %r10, %r10, %r22;
			or %r10, %r10, %r23;	

															ori %r7, %r10, #0;		
															jali %r5, printdec;

			/* multiply by 0xcc9e2d51 */
			muli %r10, %r10, CONST_C1;
			andi %r10, %r10, BIT_MASK_32;

															ori %r7, %r10, #0;		
															jali %r5, printdec;

			/* bit shifting magic */
			shli %r12, %r10, CONST_R1; 	/* data << r1 	*/
			andi %r12, %r12, BIT_MASK_32;
			shri %r13, %r10, CONST_R3; 	/* data >> r3 	*/
			andi %r13, %r13, BIT_MASK_32;
			or %r10, %r12, %r13;

			/* multiply by 0x1b873593 */
			muli %r10, %r10, CONST_C2;
			andi %r10, %r10, BIT_MASK_32;

			/* XOR with running hash */
			xor %r2, %r2, %r10;
			andi %r2, %r2, BIT_MASK_32;

			/* some more bit shift magic */
			shli %r12, %r2, CONST_R2; 		/* data << r2 	*/
			andi %r12, %r12, BIT_MASK_32;
			shri %r13, %r2, CONST_R4; 		/* data >> r4 	*/
			andi %r13, %r13, BIT_MASK_32;
			or %r2, %r12, %r13;

			/* multiply by 5 + 0x36546b64 */
			muli %r2, %r2, CONST_M;
			addi %r2, %r2, CONST_N;
			andi %r2, %r2, BIT_MASK_32;



			/* hash = hash ^ length; */
			xor %r2, %r2, %r24;

															ori %r7, %r2, #0;		
															jali %r5, printdec;

			/* hash = hash ^ (hash >> 16); */
			shri %r12, %r2, #16;
			xor %r2, %r2, %r12;
			andi %r2, %r2, BIT_MASK_32;

															ori %r7, %r2, #0;		
															jali %r5, printdec;

			/* hash = hash * 0x85ebca6b; */
			muli %r2, %r2, CONST_C4;
			andi %r2, %r2, BIT_MASK_32;

															ori %r7, %r2, #0;		
															jali %r5, printdec;

			/* hash = hash ^ (hash >> 13); */
			shri %r12, %r2, #13;
			xor %r2, %r2, %r12;
			andi %r2, %r2, BIT_MASK_32;

															ori %r7, %r2, #0;		
															jali %r5, printdec;

			/* hash = hash * c3; */
			muli %r2, %r2, CONST_C3;
			andi %r2, %r2, BIT_MASK_32;

															ori %r7, %r2, #0;		
															jali %r5, printdec;

			/* hash = hash ^ (hash >> 16); */
			shri %r12, %r2, #16;
			xor %r2, %r2, %r12;
			andi %r2, %r2, BIT_MASK_32;

															ori %r7, %r2, #0;		
															jali %r5, printdec;

			trap;

.align 4096
.perm rw
vector_a:	.word 0x01
			.word 0x02
			.word 0x03
			.word 0x04
length: 	.word 4

string_0:	.string "----------------------\n"