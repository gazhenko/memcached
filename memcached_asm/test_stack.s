 /*
  * To implement a "hashmap_map" struct
  * Offsets are # of words
  */

 .def OFFSET_TABLE_SIZE 0
 .def OFFSET_SIZE 8
 .def OFFSET_ELEMENT 16

/*
 * To implement a "hashmap_element" struct
 */

 .def OFFSET_ELEMENT_KEY 0
 .def OFFSET_ELEMENT_IN_USE 8
 .def OFFSET_ELEMENT_DATA 16
 .def OFFSET_ELEMENT_FULL 24 /* Go to next element */

.align 4096
.perm x
.global
.entry

entry:

			ldi %r10, stack

									ldi %r7, debug0
									jali %r5, puts

									ld %r7, %r10, #0
									jali %r5, printdec

 			andi %r11, %r11, #0
 			addi %r11, %r11, #10

					 				ldi %r7, debug1
					 				jali %r5, puts

					 				ori %r7, %r11, #0
					 				jali %r5, printdec

					 				ldi %r7, debug2
					 				jali %r5, puts

					 				ori %r7, %r10, #0
					 				jali %r5, printdec

			ldi %r10, stack
 			st %r11, %r10, #0

 			ldi %r10, stack
 			ld %r10, %r10, #0

					 				ldi %r7, debug3
					 				jali %r5, puts

									ori %r7, %r10, #0
									jali %r5, printdec



			/* Sanity Check */
			ldi %r15, debug_location1
			addi %r15, %r15, #-8
			
									ld %r7, %r15, #0
									jali %r5, printdec


			ldi %r20, stack
			addi 


			halt


.align 4096
.perm rw

debug0: .string "Stack value: "
debug1: .string "value to be saved: "
debug2: .string "save location: "
debug3: .string "new stack value "

debug_location0: .word 0x0004
debug_location1: .word 0x0005
debug_location2: .word 0x0006

stack: .word 0x0000	

adfas: .space 8192