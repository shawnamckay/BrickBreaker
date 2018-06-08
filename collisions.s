.section .text


//wallCollide Subroutine
//Tests if the ball has collided with a wall
//No inputs
//Returns:
//	1 if ball collides with the left side of the wall
//	2 if ball collides with the top of the wall
//	3 if ball collides with right side of wall
//	4 if ball collides with floor  
//	and 0 if a collision has not occurred
.global wallCollide
wallCollide:
	push	{r4, lr}		//Store registers and lr to the stack
	
	mov	r0, #0			//Default returns no collisions

	ldr	r3, =wallData		//Load base address of wall data
	
.checkLeft:
	ldr	r2, [r3]		//Load data for left side of wall
	ldr	r4, =ballLeft		//Load base address of ballLeft
	ldr	r1, [r4, #8]		//Load x value of ballLeft
	cmp	r1, r2
	bge	.checkRight		//If ballLeft>=wall no collision
	mov	r0, #1			//Else return 1
	b	.exit
	
.checkRight:
	ldr	r2, [r3, #4]		//Load data for right side of wall
	ldr	r4, =ballRight		//Load base address of ballRight
	ldr	r1, [r4, #8]		//Load x value of ballRight
	cmp	r1, r2
	ble	.checkTop		//If ballRight<=wall no collision
	mov	r0, #3			//Else return 3
	b	.exit

.checkTop:
	ldr	r2, [r3, #8]		//Load data for top of wall
	ldr	r4, =ballTop		//Load base address of ballTop
	ldr	r1, [r4, #8]		//Load y value of ballTop
	cmp	r1, r2
	bge	.checkBottom		//If balltop>=wall no collision
	mov	r0, #2			//Else return 2
	b	.exit

.checkBottom:
	ldr	r2, [r3, #12]		//Load data for floor
	ldr	r4, =ballBottom		//Load base address of ballBottom
	ldr	r1, [r4, #8]		//Load y value of ballBottom
	cmp	r1, r2
	blt	.exit			//If ballBottom<wall no collision
	mov	r0, #4			//Else return 4


.exit:
	pop	{r4, lr}		//Pop registers and lr from the stack
	bx	lr			//Return to calling code


//bumperCollide Subroutine
//Tests if the ball has collided with a bumper
//No inputs
//Returns:
//	1 if ball collides with the left side of the bumper
//	2 if ball collides with the middle of the bumper
//	3 if ball collides with the right side of the bumper 
//	and 0 if a collision has not occurred

.global bumperCollide
bumperCollide:
	push	{r4, lr}		//Store registers and lr to the stack

	ldr	r1, =bumperData
	ldr	r2, =ballBottom

	ldr	r3, [r2, #8]		//Check if ball is low enough
	ldr	r4, =#790		// y value of bumper is constant 5 pixels wiggle room
	cmp	r3, r4			//If ball not as low as the bumper, collision impossible
	movlt	r0, #0			//Return 0
	blt	exit

	ldr	r4, =#820		// y value of bumper is constant 5 pixels wiggle room
	cmp	r3, r4			//If ball is below the bumper, collision impossible
	movgt	r0, #0			//Return 0
	bgt	exit
	
checkMiddle:
	ldr	r4, [r1, #4]		//Leftmost pixel of middle section of bumper
	ldr	r3, [r2]		//Left edge of ball
	cmp	r3, r4			//If left edge of ball is less than middle of bumper
	blt	checkLeft		//Then check the left edge of the bumper
	add	r3, #8			//Bottom of ball is 8 pixels wide
	add	r4, #50			//Middle of bumper is 50 pixels wide
	cmp	r3, r4			//If right edge of ball is greater than bumper
	bgt	checkRight		//Check the right side of the bumper
	mov	r0, #2			//Otherwise a collision has occurred
	b	exit			//Return 2
	
checkLeft:
	ldr	r4, [r1]		//Leftmost pixel of left section of bumper
	ldr	r3, [r2, #8]		//Right edge of ball
	cmp	r3, r4			//If right edge of ball is less than left edge of bumper
	bge	exit			//Then collision impossible
	mov	r0, #1			//Otherwise a collision has occurred
	b	exit			//Return 1
	

checkRight:
	ldr	r4, [r1, #12]		//Rightmost pixel of right section of bumper
	ldr	r3, [r2]		//Left edge of ball
	cmp	r3, r4			//If left edge of ball is greater than bumper
	bgt	exit			//Then collision is impossible
	mov	r0, #3			//Otherwise a collision has occurred
	b	exit			//Return 1


exit:
	pop	{r4, lr}		//Pop registers and lr from the stack
	bx	lr			//Return to calling code


@ Data section
.section .data

.align
