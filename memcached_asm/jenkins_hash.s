/* Constants */
.def BIT_MASK_32 0x00000000ffffffff

.align 4096
.perm x
.entry
.global

entry:		
			ldi %r0, vector_a;
			ldi %r1, length;
			ld %r11, %r1, #0;

			andi %r2, %r2, #0; 

loop:
				subi %r11, %r11, #1;			/* length--			*/		
				ld %r10, %r0, #0;				/* hash = 0;		*/
				addi %r0, %r0, __WORD;			/* data++			*/

				add %r2, %r2, %r10;				/* 
				andi %r2, %r2, BIT_MASK_32;

				ori %r3, %r2, #0;
				shli %r2, %r2, #10;
				add %r2, %r2, %r3;
				andi %r2, %r2, BIT_MASK_32;

				ori %r3, %r2, #0;
				shri %r2, %r2, #6;
				xor %r2, %r2, %r3;
				andi %r2, %r2, BIT_MASK_32;

				rtop @p0, %r11;
				@p0 ? jmpi loop;

			ori %r3, %r2, #0;
			shli %r2, %r2, #3;
			add %r2, %r2, %r3;
			

			ori %r3, %r2, #0;
			shri %r2, %r2, #11;
			xor %r2, %r2, %r3;
			andi %r2, %r2, BIT_MASK_32;

			ori %r3, %r2, #0;
			shli %r2, %r2, #15;
			add %r2, %r2, %r3;
			andi %r2, %r2, BIT_MASK_32;

			ori %r7, %r2, #0;		
			jali %r5, printdec;

			ldi %r7, max_int;
			jali %r5, puts;

			trap;

.align 4096
.perm rw
vector_a:	.word 0x12
length: 	.word 1

print_0:	.string "In the loop\n"
max_int:	.string "4294967296 <- Max int size\n"