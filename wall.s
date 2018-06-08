.section .text

.global	drawWall

//DrawWall Subroutine
//Draws the grey border of the gamescreen during gameplay
//No inputs
//Returns nothing

drawWall:
	push	{r4-r5, lr}		//Store registers and lr to the stack
	

	mov	r4, #200		@ x
	mov	r5, #200		@ y

topRow:					//Draws the top of the wall
	mov	r0, r4			//Move x value into r0
	mov	r1, r5			//Move y value into r1
	ldr	r2, =0xFF828282		@ colour
	bl	DrawPixel		//Call drawPixel
	add	r4, #1			//Increment x value by one
	cmp	r4, #700		//Check if x value is less than gameboard size
	blt	topRow			//If have not reached end of gameboard, keep drawing right
	mov	r4, #200		//Restart at left side of the gameboard
	add	r5, #1			//Increment y value by one
	cmp	r5, #215		//Check if at the bottom of the wall height
	blt	topRow			//If not keep drawing

leftCol:				//Draws the left side of the wall
	mov	r0, r4			//Move x value into r0
	mov	r1, r5			//Move y value into r1
	ldr	r2, =0xFF828282		@ colour
	bl	DrawPixel		//Call drawPixel
	add	r4, #1			//Increment x value by one
	cmp	r4, #215		//Check if x value is less than wall width
	blt	leftCol			//If have not reached end of wall width keep drawing right
	mov	r4, #200		//Restart at left side of the gameboard
	add	r5, #1			//Increment y value by one
	cmp	r5, #900		//Check if at the bottom of the gameboard
	blt	leftCol			//If not keep drawing

	mov	r4, #685		//Set x to leftmost side of wall
	mov	r5, #200		//Reset y to top of wall 

rightCol:				//Draws the right side of the wall
	mov	r0, r4			//Move x value into r0
	mov	r1, r5			//Move y value into r1
	ldr	r2, =0xFF828282		@ colour
	bl	DrawPixel		//Call drawPixel
	add	r4, #1			//Increment x value by one
	cmp	r4, #700		//Check if x value is less than gameboard size
	blt	rightCol		//If have not reached end of gameboard, keep drawing right
	mov	r4, #685		//Restart at left side of the wall
	add	r5, #1			//Increment y value by one
	cmp	r5, #900		//Check if at the bottom of the gameboard
	blt	rightCol		//If not keep drawing

	mov	r4, #200		//Set x to left side of gameboard
	mov	r5, #885		//Set y to top of floor

floor:					//Draws the floor of the wall
	mov	r0, r4			//Move x value into r0
	mov	r1, r5			//Move y value into r1
	ldr	r2, =0xFF828282		@ colour
	bl	DrawPixel		//Call drawPixel
	add	r4, #1			//Increment x value by one
	cmp	r4, #700		//Check if x value is less than gameboard size
	blt	floor			//If have not reached end of gameboard, keep drawing right
	mov	r4, #200		//Restart at left side of the gameboard
	add	r5, #1			//Increment y value by one
	cmp	r5, #900		//Check if at the bottom of the gameboard
	blt	floor			//If not keep drawing
	
	pop	{r4-r5, lr}		//Pop registers and lr from the stack
	bx	lr			//Return to calling code


//DrawBlack Subroutine
//Draws the black background of the gamescreen during gameplay
//No inputs
//Returns nothing

.global	drawBlack

drawBlack:
	push	{r4-r7, lr}		//Store registers and lr to the stack
	

	mov	r4, #215		@ x
	mov	r5, #306		@ y
	ldr	r6, =#685
	ldr	r7, =#885

box:
	mov	r0, r4			//Move x value into r0
	mov	r1, r5			//Move y value into r1
	ldr	r2, =0xFF000000		@ colour
	bl	DrawPixel		//Call drawPixel
	add	r4, #1			//Increment x value by one
	cmp	r4, r6			//Check if x value is less than gameboard size
	blt	box			//If have not reached end of gameboard, keep drawing right
	mov	r4, #215		//Restart at left side of the gameboard
	add	r5, #1			//Increment y value by one
	cmp	r5, r7			//Check if at the bottom of the gameboard
	blt	box			//If not keep drawing
	
	pop	{r4-r7, lr}		//Pop registers and lr from the stack
	bx	lr			//Return to calling code



@ Data section
.section .data

.align

.global wallData			//Stores the location of the wall to detect collisions
wallData:
	.int	215			//Left x wall border
	.int	685			//Right x wall border
	.int	200			//Top y wall border
	.int	885			//Bottom y wall border

