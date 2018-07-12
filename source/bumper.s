.section .text

.global	drawBumper

//DrawBumper Subroutine
//Draws the game bumper during gameplay
//Inputs r0=x (left of bumper), r1=y (top of bumper)
//Returns nothing

drawBumper:
	push	{r4-r9, lr}		//Store registers and lr to the stack
	

	mov	r4, r0			@ x
	mov	r8, r0			//Saves the left side of the bumper
	mov	r5, r1			@ y
	add	r6, r0, #100		//Bumper is 100 pixels wide
	add	r7, r1, #15		//Bumper is 15 pixels high
	

top:					//Draws the bumper
	mov	r0, r4			//Move x value into r0
	mov	r1, r5			//Move y value into r1
	ldr	r2, =0xFFFFFFFF		@ colour
	bl	DrawPixel		//Call drawPixel
	add	r4, #1			//Increment x value by one
	cmp	r4, r6			//Check if x value is less than bumper size
	blt	top			//If have not reached end of bumper, keep drawing right
	mov	r4, r8			//Restart at left side of the bumper
	add	r5, #1			//Increment y value by one
	cmp	r5, r7			//Check if at the bottom of the bumper height
	blt	top			//If not keep drawing

	
	pop	{r4-r9, lr}		//Pop registers and lr from the stack
	bx	lr			//Return to calling code


//Move_Bumper Subroutine
//Moves the bumper based on user input
//Input: r0= left most side of bumper, r1= right most side of bumper
//Returns:Nothing 

.global Move_Bumper

Move_Bumper:
	push	{r4-r5, lr}		//Store registers and lr to the stack

	bumpLeft 	.req 	r4	//Left value of bumper
	border 	 	.req 	r5	//Edge of the gameboard
	
	ldr	r0, =bumperData		//Get the base address
	ldr	bumpLeft, [r0] 		//Get the left bumper value
	ldr	border, =#583		//Edge of the gameboard on the right side

	bl 	Read_SNES		//Read_SNES gets data from the SNES controller
	
	ldr	r1, =0XFD7F		//Value of left and a buttons being pressed at the same time
	cmp	r0, r1			//If pressing both buttons
	beq	fastLeft		//Move the bumper fast left
	
	ldr	r1, =0XFE7F		//Value of right and a buttons being pressed at the same time
	cmp	r0, r1			//If pressing both buttons
	beq	fastRight		//Move the bumper fast right

	ldr 	r1, =0xFDFF		//Value of button Left
	cmp 	r0, r1			//Check if equal to button left
	subeq	bumpLeft, #10		//Move bumper left

	ldr	r1, =0xFEFF		//Value of button right
	cmp 	r0, r1			//Check if equal to button right
	addeq	bumpLeft, #10		//Move bumper right
	
	b	update			//Show the current position of the bumper


fastLeft:
	sub	bumpLeft, #60		//Move bumper left by 60 pixels
	b	update

fastRight:
	add	bumpLeft, #60		//Move bumper right by 60 pixels

update:
	cmp	bumpLeft, #217		//Check if bumper is still inside gameboard on left side
	movlt	bumpLeft, #217		//If not move bumper to edge of border

	cmp	bumpLeft, border	//Check if bumper is still inside gameboard on the right side 
	movge	bumpLeft, border	//If not move bumper to the edge of the border

	mov	r0, bumpLeft		//Left value of bumper
	mov	r1, #800		//Top of bumper (never changes)
	bl	drawBumper		//Calls drawBumper based on values in r0 and r1

	mov	r0, bumpLeft
	bl	updateBumperPosition	//Update the bumpers position in storage
	b	done


done:
	mov	r0, bumpLeft		//return the bumpLeft value


	.unreq	bumpLeft		//Forget register equates
	.unreq	border

	
	pop	{r4-r5, lr}		//Pop register and lr from stack
	bx	lr			//return





//updateBumperPosition Subroutine
//Updates the location of the bumper stored in memory
//Input, r0=left x value of bumper
//Returns nothing
.global updateBumperPosition

updateBumperPosition:
	push	{r4-r9, lr}		//Store registers and lr to the stack

	ldr	r1, =bumperData		//Get the bumper data base address
	strh	r0, [r1]		//Store the left edge of the bumper
	add	r0, #25			//Left section is 25 pixels wide
	strh	r0, [r1, #4]		//Store left end of middle section
	add	r0, #50			//Middle section is 50 pixels wide
	strh	r0, [r1, #8]		//Store left edge of the right section	
	add	r0, #25			//Right section is 25 pixels wide
	strh	r0, [r1, #12]		//Store right edge of bumper


	pop	{r4-r9, lr}		//Pop registers and lr from the stack
	bx	lr			//Return to calling code

@ Data section
.section .data

.align

.global bumperData

bumperData:				//Stores the location of the bumper to detect collisions
	.int	400			//Left most x value initialized to middle of the gameboard
	.int	0			//Middle left most x value (leftmost + 25)
	.int	0			//Middle right most x value (leftmost + 75)
	.int	0			//Rightmost x value (leftmost + 100)

