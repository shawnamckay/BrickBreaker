.section .text

//DrawLives Subroutine
//Shows the user their lives
//No inputs
//Returns nothing

.global drawLives

drawLives:
	push	{r4-r8, lr}		//Store registers and lr to the stack	
	
	ldr 	r0, =lives		//Load address of the lives variable
	
	ldr	r1, [r0]		//Get value of lives variable

	ldr	r6, =zeroLives		//Draw 0 lives

	cmp	r1, #3			//If have 3 lives 
	ldreq	r6,=threeLives		//Draw 3 lives

	cmp	r1, #2			//If have 2 lives 
	ldreq	r6,=twoLives		//Draw 2 lives

	cmp	r1, #1			//If have 1 life 
	ldreq	r6,=oneLife		//Draw 1 lives


	mov	r4, #555		@ x
	ldr	r5, =#847		@ y
	ldr	r7, =#685
	ldr	r8, =#885

horizontal:
	mov	r0, r4			//Move x value into r0
	mov	r1, r5			//Move y value into r1
	ldr	r2, [r6]		//Get bit value from lives image
	bl	DrawPixel		//Call drawPixel
	add	r4, #1			//Increment x value by one
	cmp	r4, r7			//Check if x value is less than gameboard size
	add	r6, #4			//Increment address of bitmap to next pixel
	blt	horizontal		//If have not reached end of gameboard, keep drawing right
	mov	r4, #555		//Restart at left side of the gameboard
	add	r5, #1			//Increment y value by one
	cmp	r5, r8			//Check if at the bottom of the gameboard
	blt	horizontal		//If not keep drawing

	pop	{r4-r8, lr}		//Pop registers and lr from the stack
	bx	lr			//Return to calling code