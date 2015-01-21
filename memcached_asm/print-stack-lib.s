/* Print stack for debugging. Written by Jemmy Gazhenko, Oct 4, 2014.		  */
/* Convention:																  */
/* 		- %r0, location to start printing									  */
/* 		- %r1, location to end printing										  */
/*		- %r5, %r7, Save before calling this function						  */
/*		- Nothing returned													  */
.align 4096
.perm x
.global

printstack:		
/* Sanity check, make sure %r0 < %r1 										  */
				sub %r2, %r1, %r0;	
				isneg @p0, %r2;
		  @p0 ? jmpi error_1; 
		  		ldi %r7, str_beg_func;
		  		jali %r5, puts;

/* For each entry in the stack, print out the contents of that entry		  */
loop:			sub %r2, %r1, %r0;
				isneg @p1, %r2;
		  @p1 ? jmpi end_func;

				ld %r7, %r0, #0;
				jali %r5, printdec;
				addi %r0, %r0, __WORD; 
				jmpi loop;

end_func:
/* End of function. Return back to caller function.							  */
				ldi %r7, str_end_func;
				jali %r5, puts;
				jmprt %r31;

error_1:
/* %r0 > %r1. Out of bounds													  */
				ldi %r7, str_error_1;
				jali %r5, puts;
				jmprt %r31;

.align 4096
.perm rw

/* Strings */
str_beg_func:	.string "------/  Current Stack Values   \\------\n"
str_end_func:	.string "------/ Finished Printing Stack \\------\n"
str_error_1:	.string "ERROR: Arguments Out of Bounds!\n"

/* Test Print */
				.word 10
				.word 11
				.word 12
				.word 13
				.word 14
stop:			.word 15
