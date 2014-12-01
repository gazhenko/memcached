/*
 * This is an example executable harptool program that runs the jenkins hash
 * library functions.
 *
 * Author: Jemmy Gazhenko
 * Date: Dec. 1, 2014
 * Version: 1
 */

 .align 4096
 .perm x
 .entry
 .global

 entry:		

 		/*
 		 * call jenkins_infinite function (twice)
 		 */


 		 ldi %r6, #1
 		 clone %r6

 		 ldi %r6, #2
 		 clone %r6

 		 ldi %r6, #3
 		 clone %r6

 		 ldi %r6, #4
 		 clone %r6

 		 ldi %r6, #5
 		 clone %r6

 		 ldi %r6, #6
 		 clone %r6

 		 ldi %r6, #7
 		 clone %r6

 		 ldi %r5, #8
 		 jalis %r5, call_method

 		/*
 		 * call jenkins_stack function
 		 */

 		 trap

 call_method:

 		jali %r31, jenkins_infinite