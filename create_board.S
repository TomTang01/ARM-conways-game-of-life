// file header
	.arch armv6                  // armv6 architecture
	.arm                         // arm 32-bit instruction set
	.fpu vfp                     // floating point co-processor
	.syntax unified              // modern syntax

	// .extern                   // symbol import - external references
	// .equ                      // file level definitions
	.equ EOF, -1
	// .bss                      // uncomment if needed
	.data
mode:	.string "r"		     // file open mode
fmt:	.string "%d"		     // fscanf format1
fmtb:	.string "%d %d"		     // fscanf format2
	// .section .rodata          // uncomment if needed

	.text                        // start of text segment
	// function header (change main to function name in 5 places below)
	.global create_board         // make function global for linking to
	.type create_board, %function// define as a function
	.equ FP_OFFSET, 28            // (#regs pushed -1) * 4 is distance from sp
	.equ FILEPTR_OFFSET, FP_OFFEST + 4
	.equ BOARDPTR_OFFSET, FILEPTR_OFFSET + 4
	.equ NUM1_OFFSET, BOARDPTR_OFFSET + 4
	.equ NUM2_OFFSET, NUM1_OFFSET + 4
	.equ PAD, NUM2_OFFSET + 0
	.equ FRMADD, PAD - FP_OFFSET
	.equ EXIT_SUCCESS, 0         // return success (used by main)
	.equ EXIT_FAILURE, 1         // return failure (used by main)
create_board:
	// function prologue
	push {r4-r9, fp, lr}            // stack register save minimum: fp,lr (push in pairs!)
	add fp, sp, FP_OFFSET        // set frame pointer to frame base
	
	mov r4, r0		     	// move the filename charptr to r4
	sub sp, sp, 4		     	// moving sp down 4 bytes
	mov r5, sp		     	// now r5 has an address of a 4 byte space. This loc will hold the file ptr
	sub sp, sp, 4		     	// moving sp down 4 bytes
	mov r6, sp		     	// now r6 has an address of a 4 byte space. This loc will hold the board ptr
	
				     	// Malloc for board
	mov r0, 28		     	// input of malloc = size0f(board) = 4*7
	bl  malloc		     	// malloc
	str r0, [r6]		     	// store the board ptr to the address stored in r6
	mov r6, r0		     	// now r6 is the board ptr
	
				     	// call fopen
	mov r0, r4		     	// move filename back to r0
	ldr r1, =mode		     	// move "r" to r1
	bl  fopen		     	// fopenf
	cmp r0, 0		     	// see if it is NULL
	beq .Lend_of_file	     	// if is NULL then go to the end and return r0=0
	str r0, [r5]		     	// store the file ptr to the address stored in r5
	mov r5, r0		     	// now r5 is the file ptr

				     	// Declare 2 local variables num1 num2 (used for later)
	sub sp, sp, 8		     	// move sp down 8 bytes to make space for 2 ints
	add r7, sp, 4		     	// r7 now has the address of a 4 byte empty space. This loc is for num1
	mov r8, sp		     	// r8 now has the address of a 4 byte empty space. This loc is for num2

				     	// Find nrows and ncols
	mov r0, r5		     	// move the file ptr to r0
	ldr r1, =fmt		     	// move "%d" to r1
	add r2, r6, 8		     	// move &nrows of board to r2
	bl  fscanf		     	// fscanf
	mov r0, r5		     	// all again for ncols
	ldr r1, =fmt		     	//
	add r2, r6, 12		     	// add 12 because &ncols
	bl  fscanf		     	//
		
				    	// Malloc for buf1 and buf2
	ldr r1, [r6, 8]			// r1 = nrows
	ldr r2, [r6, 12]		// r2 = ncols
	mul r9, r1, r2			// r9 = nrows * ncols *sizeof(Cell) which is 1 byte
	mov r0, r9			// move r9 to r0
	bl  malloc			// malloc
	str r0, [r6]			// move the Cell ptr ptr to buf1
	mov r0, r9			// again for buf2
	bl  malloc			//
	str r0, [r6, 4]			// store in &buf2

					// Make buffer and next_buffer = buf1 and buf2
	ldr r9, [r6]			// r9 = buf1
	str r9, [r6, 16]		// buffer = buf1
	ldr r9, [r6, 4]			// r9 = buf2
	str r9, [r6, 20]		// next_buffer = buf2

					// Clear board
	mov r0, r6			// move the board ptr to r0
	bl  clear_board			// call clear_board

					// set the Cells in next_buffer
.Lwhile:
	mov r0, r5			// move the file ptr to r0
	ldr r1, =fmtb			// r1 = "%d %d"
	mov r2, r7			// r2 = &num1
	mov r3, r8			// r3 = &num2
	bl  fscanf			// fscanf
	cmp r0, EOF			// see if it is the end of the file
	beq .Lend_of_while		// if it is then exist while loop
					// call get_index
	ldr r0, [r6, 12]		// r0 = ncols
	ldr r1, [r7]			// r1 = num1
	ldr r2, [r8]			// r2 = num2
	bl  get_index			// get_index
					// change the Cell at that index
	ldr r1, [r6, 20]		// r1 = next_buffer
	mov r2, 1			// r2 = 1
	strb r2, [r1, r0]		// store the byte into next_buffer + get_index
	bl  .Lwhile			// back to the top of the while loop
.Lend_of_while:

					// Finally, other stuff
	mov r2, 0			// r2 = 0
	str r2, [r6, 24]		// set gen to 0

	mov r0, r6			// r0 = board ptr
	bl  swap_buffers		// call swap_buffers

	mov r0, r5			// r0 = file ptr
	bl  fclose			// call fclose
	cmp r0, EOF			// see if it is end of file
	beq .Lend_of_file		// if it is, then exit function with r0 = 0
	mov r0, r6			// move the board ptr to r0 for return
.Lend_of_file:
	// function epilogue
	sub sp, fp, FP_OFFSET        // restore stack frame top
	pop {r4-r9, fp, lr}                 // remove frame and restore registers
	bx lr                        // return to caller
	// function footer
	.size create_board, (. - create_board) // set size for function
	// file footer
	.section .note.GNU-stack, "", %progbits // stack/data non-exec
.end
