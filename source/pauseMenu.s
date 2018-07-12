.section .text

//DrawPauseMenu Subroutine
//Shows the user the pause menu
//No inputs
//Returns nothing

.global drawPauseMenu

drawPauseMenu:
	push	{r4-r8, lr}		//Store registers and lr to the stack	
	
	mov	r6, r0		//Load address of the pause menu bitmap

	mov	r4, #290		@ x
	mov	r5, #400		@ y
	ldr	r7,=#607
	ldr	r8, =#699

horizontal:
	mov	r0, r4			//Move x value into r0
	mov	r1, r5			//Move y value into r1
	ldr	r2, [r6]		//Get bit value from startMenu image
	bl	DrawPixel		//Call drawPixel
	add	r4, #1			//Increment x value by one
	cmp	r4, r7		//Check if x value is less than gameboard size
	add	r6, #4			//Increment address of bitmap to next pixel
	blt	horizontal		//If have not reached end of gameboard, keep drawing right
	mov	r4, #290		//Restart at left side of the gameboard
	add	r5, #1			//Increment y value by one
	cmp	r5, r8		//Check if at the bottom of the gameboard
	blt	horizontal		//If not keep drawing

	pop	{r4-r8, lr}		//Pop registers and lr from the stack
	bx	lr			//Return to calling code


