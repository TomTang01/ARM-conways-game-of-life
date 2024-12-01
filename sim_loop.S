// file header
	.arch armv6                  // armv6 architecture
	.arm                         // arm 32-bit instruction set
	.fpu vfp                     // floating point co-processor
	.syntax unified              // modern syntax

	// .extern                   // symbol import - external references
	// .equ                      // file level definitions
	// .bss                      // uncomment if needed
	// .data                     // uncomment if needed
	// .section .rodata          // uncomment if needed

	.text                        // start of text segment
	// function header (change main to function name in 5 places below)
	.global sim_loop             // make function global for linking to
	.type sim_loop, %function    // define as a function
	.equ FP_OFFSET, 32            // (#regs pushed -1) * 4 is distance from sp
	.equ PAD, FP_OFFSET + 0
	.equ O5_OFFSET, PAD + 4	     // parm 5
	.equ FRMADD, O5_OFFSET - FP_OFFSET //
	.equ EXIT_SUCCESS, 0         // return success (used by main)
	.equ EXIT_FAILURE, 1         // return failure (used by main)
sim_loop:
	// function prologue
	push {r4-r10, fp, lr}                // stack register save minimum: fp,lr (push in pairs!)
	add fp, sp, FP_OFFSET        // set frame pointer to frame base
	
	mov r4, r0			// move board to r4
	mov r5, r1			// move steps to r5
	ldr r8, [r4, 8]			// r8 = nrows
	ldr r9, [r4, 12]		// r9 = ncols
	sub sp, sp, 8			// mov sp down 8 bytes to store ncols (PAD)
	str r9, [sp]			// store ncols to the bottom of the stack
	
					// for(unsigned int j=0; j<steps; j++){
	mov r6, 0			// r6 = j = 0
	cmp r6, r5			// see if j is smaller than steps
	bge .Lend_of_outer_loop		// if it is not, exit loop
.Louter_loop:
					// for(unsigned int i=0; i<(*board).nrows; i++){
	mov r7, 0			// r7 = i = 0
	cmp r7, r8			// see if i is smaller than nrows
	bge .Lend_of_inner_loop		// if it is not, exit loop

.Linner_loop:				// call do_row
	ldr r0, [r4, 20]		// r0 = next_buffer
	ldr r1, [r4, 16]		// r1 = buffer
	mov r2, r7			// r2 = i
	mov r3, r8			// r3 = nrows
	bl  do_row			// do_row
	add r7, r7, 1			// i++
	cmp r7, r8			// condition
	blt .Linner_loop		// if met then back into loop
.Lend_of_inner_loop:
					// call swap_buffers
	mov r0, r4			// r0 = board
	bl  swap_buffers		// swap_buffers
	ldr r10, [r4, 24]		// r10 = gen
	add r10, r10, 1			// gen++
	str r10, [r4, 24]		// update the gen in the board
	add r6, r6, 1			// j++
	cmp r6, r5			// condition
	blt .Louter_loop		// if met then back to loop
.Lend_of_outer_loop:

	// function epilogue
	sub sp, fp, FP_OFFSET        // restore stack frame top
	pop {r4-r10, fp, lr}                 // remove frame and restore registers
	bx lr                        // return to caller
	// function footer
	.size sim_loop, (. - sim_loop) // set size for function
	// file footer
	.section .note.GNU-stack, "", %progbits // stack/data non-exec
.end
