.align 4096
.perm x
.global
.entry

entry:
			ldi %r0, #0
			ldi %r1, #1000000

			jali %r31, printstack

			halt