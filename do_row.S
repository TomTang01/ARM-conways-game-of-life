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
	.global do_row               // make function global for linking to
	.type do_row, %function      // define as a function
	.equ FP_OFFSET, 32           // (#regs pushed -1) * 4 is distance from sp
	.equ ROW_OFFSET, FP_OFFSET + 4
	.equ ROWS_OFFSET, ROW_OFFSET + 4
	.equ PAD, FP_OFFSET + 4
	.equ EXIT_SUCCESS, 0         // return success (used by main)
	.equ EXIT_FAILURE, 1         // return failure (used by main)
do_row:
	// function prologue
	push {r4-r10,fp, lr}   	     // stack register save minimum: fp,lr (push in pairs!)
	add fp, sp, FP_OFFSET        // set frame pointer to frame base
	
	mov r4, r2			// mov row to r4
	mov r5, r3			// mov rows to r5
	sub sp, sp, 8			// make space for row and rows
//	str r0, [sp, 4]			// store dest in sp + 4
	str r1, [sp]			// store src in sp
	ldr r6, [fp, 4]			// load the 5th input from the back of the caller to r6
	mov r9, 0			// r9 = neighbors = 0

	mov r8, 0			// for(size_t i = 0; i<cols;i++){
	cmp r8, r6			// condition
	bge .Lend_of_for		// if not met then end for loop
.Lfor:
					// Left
					// call mod
	ldr r7, [sp]
	sub r0, r8, 1			// r0 = i - 1
	mov r1, r6			// r1 = cols
	bl  mod				// mod
	mul r10, r4, r6			// get left
	add r10, r10, r0		//
	add r10, r10, r7		// left
	ldrb r10, [r10]			// *left
	add r9, r9, r10			// neighbors += *left

					// Right
					// call mod
	add r0, r8, 1			// r0 = i + 1
	mov r1, r6			// r1 = cols
	bl  mod				// mod
	mul r10, r4, r6			// get right
	add r10, r10, r0		//
	add r10, r10, r7		// right
	ldrb r10, [r10]			// *right
	add r9, r9, r10			// neighbors += *right

					// Top
					// call mod
	sub r0, r4, 1			// r0 = row - 1
	mov r1, r5			// r1 = rows
	bl  mod				// mod
	mul r10, r6, r0			// get top
	add r10, r10, r7		//
	add r10, r10, r8		// top
	ldrb r10, [r10]			// *top
	add r9, r9, r10			// neighbors += *top

					// Bottom
					// call mod
	add r0, r2, 1			// r0 = row + 1
	mov r1, r5			// r1 = rows
	bl  mod				// mod
	mul r10, r6, r0			// get bot
	add r10, r10, r7		//
	add r10, r10, r8		// bot
	ldrb r10, [r10]			// *bot
	add r9, r9, r10			// neighbors += *bot

					// Topleft
					// call mod
	sub r0, r4, 1			// r0 = row - 1
	mov r1, r5			// r1 = rows
	bl  mod				// mod
	mul r10, r6, r0			// get top
	add r10, r10, r7		//
					// call mod for horizontal shift
	sub r0, r8, 1			// r0 = i - 1
	mov r1, r6			// r1 = cols
	bl  mod				// mod
	add r10, r10, r0		// topleft
	ldrb r10, [r10]			// *topleft
	add r9, r9, r10			// neighbors += *topleft

					// Topright
					// call mod
	sub r0, r4, 1			// r0 = row - 1
	mov r1, r5			// r1 = rows
	bl  mod				// mod
	mul r10, r6, r0			// get top
	add r10, r10, r7		//
					// call mod for horizontal shift
	add r0, r8, 1			// r0 = i + 1
	mov r1, r6			// r1 = cols
	bl  mod				// mod
	add r10, r10, r0		// topright
	ldrb r10, [r10]			// *topright
	add r9, r9, r10			// neighbors += *topright
					
					// Botright
					// call mod
	add r0, r4, 1			// r0 = row + 1
	mov r1, r5			// r1 = rows
	bl  mod				// mod
	mul r10, r6, r0			// get bot
	add r10, r10, r7		//
					// call mod for horizontal shift
	add r0, r8, 1			// r0 = i + 1
	mov r1, r6			// r1 = cols
	bl  mod				// mod
	add r10, r10, r0		// botright
	ldrb r10, [r10]			// *botright
	add r9, r9, r10			// neighbors += *botright

					// Botleft
					// call mod
	add r0, r4, 1			// r0 = row + 1
	mov r1, r5			// r1 = rows
	bl  mod				// mod
	mul r10, r6, r0			// get bot
	add r10, r10, r7		//
					// call mod for horizontal shift
	sub r0, r8, 1			// r0 = i - 1
	mov r1, r6			// r1 = cols
	bl  mod				// mod
	add r10, r10, r0		// botleft
	ldrb r10, [r10]			// *botleft
	add r9, r9, r10			// neighbors += *botleft

					// check to see whether the cell should live
	mul r7, r6, r4			// r7 = cols * row
	ldr r1, [sp]
	add r7, r7, r1			// r7 += src
	add r7, r7, r8			// r7 += i. r7 is now current
	
	ldrb r7, [r7]			// load the current cell 1 or 0
	ldr r1, [sp. 4]			// r1 = dest
	mul r10, r6, r2			// r10 = cols * row
	add r10, r10, r1		// r10 += dest
	add r10, r10, r8		// r10 += i, now r10 is the dest cell
	

	cmp r7, 1			// check if alive
	bne .Ldead			//
	cmp r9, 1			// 	if more than 1 alive neighbor
	ble .Lkill			//
	cmp r9, 4			// 	&&if less than 4 alive neighbors
	bge .Lkill			//
	mov r0, 1			// r0 = 1
	strb r0, [r10]			// update the cell as dead in the destination
	b   .Lendif			//
.Lkill:					// 	else
	mov r0, 0			// r0 = 0
	strb r0, [r10]			// update the cell as alive in the destination
	b   .Lendif			//
.Ldead: 				// else
	cmp r9, 3			// 	if not exactly 3 alive nieghbors
	beq .Lrebirth			//
	cmp r9, 6			// 	&&if not exactly 6 alive neighbors
	beq .Lrebirth			//
	mov r0, 0			// r0 = 0
	strb r0, [r10]			// update the cell as alive in the destination
	b   .Lendif			//
.Lrebirth:				//
	mov r0, 1			// 	else{ r0 = 0
	strb r0, [r10]			// update the cell as dead in the destination
.Lendif:				//
	mov r9, 0			// reset neighbors to 0
	add r8, r8, 1			// i++
	cmp r8, r6			// condition
	blt .Lfor			//
.Lend_of_for:
	// function epilogue
	sub sp, fp, FP_OFFSET        // restore stack frame top
	pop {r4-r10, fp, lr}    // remove frame and restore registers
	bx lr                        // return to caller
	// function footer
	.size do_row, (. - do_row)  // set size for function
	// file footer
	.section .note.GNU-stack, "", %progbits // stack/data non-exec
.end
