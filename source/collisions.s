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
	sub	r1, #10			//10 pixels wiggle room
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
	push	{r4-r6, lr}		//Store registers and lr to the stack

	ldr	r1, =bumperData		//Get base address of bumper location
	ldr	r2, =ballBottom		//Get base address of ball bottom location

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
	ldr	r6, =ballRight		//right edge of ball
	ldr	r3, [r6,#8]
	cmp	r3, r4			//If right edge of ball is less than left edge of bumper
	blt	exit			//Then collision impossible
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
	pop	{r4-r6, lr}		//Pop registers and lr from the stack
	bx	lr			//Return to calling code



//brickBottomCollide Subroutine
//Tests if the ball has collided with a brick on the bottom
//No inputs
//Returns:
//	the brick number (1-15) if the ball has collided with a brick
//	or 0 if a collision has not occurred

.global brickBottomCollide

brickBottomCollide:
	push	{r4-r9, lr}		//Store registers and lr to the stack

	ballY		.req	r2
	ballLeft	.req	r3
	ballRight	.req	r4	

	mov	r0, #1			//Initialize a counter variable
	ldr	r1, =ballTop		//Load ballTop base address
	ldr	ballY, [r1,#8]		//Load balls y value
	ldr	ballLeft, [r1]		//Load balls leftmost value
	ldr	ballRight, [r1,#4]	//Load balls right most value
	ldr	r5, =brick1		//Load bricks base address
	ldr	r6, [r5, #4]		//Load the brick active flag

	ldr	r1, =#400		//Check if ball y value is in the bricks range
	cmp	ballY, r1		
	movgt	r0, #0			//If not, collision impossible return 0
	bgt	done

loop:
	cmp	r6, #0			//If brick is inactive
	beq	loopTest		//Look at the next brick
	
	ldrh	r1, [r5, #10]		//Load y value of bottom of brick
	cmp	ballY, r1		//Check if in y range
	bgt	loopTest		//If not in the range, check the next brick
	
	ldrh	r1, [r5, #8]		//Load leftmost value of brick
	cmp	ballRight, r1		//Check if the right side of the ball is less than brick
	blt	loopTest		//If so, collision impossible, check next brick

	ldrh	r1, [r5, #12]		//Load rightmost value of brick
	cmp	ballLeft, r1		//If left side of the ball is less than the right side of the brick
	blt	done			//Then a collision has occurred, return brick value	


				

loopTest:
	add	r0, #1			//Increment to the next brick number
	add	r5, #24			//Increment to the next brick address
	ldr	r6, [r5, #4]		//Load the next brick active flag	
	cmp	r0, #30			//Check if have iterated through all the bricks
	ble	loop			//Else continue looping
	mov	r0, #0			//Otherwise return 0

done:
	.unreq	ballY			//Forget register equates
	.unreq	ballLeft
	.unreq	ballRight

	pop	{r4-r9, lr}		//Pop registers and lr from the stack
	bx	lr			//Return to calling code



//brickTopCollide Subroutine
//Tests if the ball has collided with a brick on the top
//No inputs
//Returns:
//	the brick number (1-30) if the ball has collided with a brick
//	or 0 if a collision has not occurred

.global brickTopCollide

brickTopCollide:
	push	{r4-r9, lr}		//Store registers and lr to the stack

	ballY		.req	r2
	ballLeft	.req	r3
	ballRight	.req	r4	

	mov	r0, #1			//Initialize a counter variable
	ldr	r1, =ballData
	ldr	ballY, [r1, #4]
	add	ballY, #29
	//ldr	r1, =ballBottom		//Load ballBottom base address
	//ldr	ballY, [r1,#8]		//Load balls y value
	ldr	r1, =ballData
	ldr	ballLeft, [r1]		//Load balls leftmost value
	add	ballRight, ballLeft, #26
	//ldr	ballRight, [r1,#4]	//Load balls right most value
	ldr	r5, =brick1		//Load bricks base address
	ldr	r6, [r5, #4]		//Load the brick active flag

	ldr	r1, =#400		//Check if ball y value is in the bricks range
	cmp	ballY, r1		
	movgt	r0, #0			//If not, collision impossible return 0
	bgt	$done

$loop:
	cmp	r6, #0			//If brick is inactive
	beq	loopTest		//Look at the next brick
	
	ldrh	r1, [r5, #10]		//Load y value of bottom of brick
	sub	r1, #35			//Bricks are 30 pixels high, 5 pixels wiggle room
	cmp	ballY, r1		//Check if in y range
	bgt	$loopTest		//If not in the range, check the next brick

	ldrh	r1, [r5, #10]		//Load y value of bottom of brick
	sub	r1, #25			//Bricks are 30 pixels high, 5 pixels 
	cmp	ballY, r1		//Check if in y range
	blt	$loopTest		//If not in the range, check the next brick
	
	ldrh	r1, [r5, #8]		//Load leftmost value of brick
	cmp	ballRight, r1		//Check if the right side of the ball is less than brick
	blt	$loopTest		//If so, collision impossible, check next brick

	ldrh	r1, [r5, #12]		//Load rightmost value of brick
	cmp	ballLeft, r1		//If left side of the ball is less than the right side of the brick
	ble	$done			//Then a collision has occurred, return brick value	

				

$loopTest:
	add	r0, #1			//Increment to the next brick number
	add	r5, #24			//Increment to the next brick address
	ldr	r6, [r5, #4]		//Load the next brick active flag	
	cmp	r0, #30			//Check if have iterated through all the bricks
	ble	$loop			//Else continue looping
	mov	r0, #0			//Otherwise return 0

$done:
	.unreq	ballY			//Forget register equates
	.unreq	ballLeft
	.unreq	ballRight

	pop	{r4-r9, lr}		//Pop registers and lr from the stack
	bx	lr			//Return to calling code




//brickLeftCollide Subroutine
//Tests if the ball has collided with a brick on the left side
//No inputs
//Returns:
//	the brick number (1-30) if the ball has collided with a brick
//	or 0 if a collision has not occurred

.global brickLeftCollide

brickLeftCollide:
	push	{r4-r9, lr}		//Store registers and lr to the stack

	ballX		.req	r2
	ballTop		.req	r3
	ballBottom	.req	r4	

	mov	r0, #1			//Initialize a counter variable
	ldr	r1, =ballData		//Load ballData base address
	ldr	ballX, [r1]		//Load balls x value
	add	ballX, #26		//Ball is 26 pixels wide
	ldr	r1, =ballRight		//Load ballRight base address
	ldr	ballTop, [r1]		//Load balls topmost value
	ldr	ballBottom, [r1,#4]	//Load balls bottom most value
	ldr	r5, =brick1		//Load bricks base address
	ldr	r6, [r5, #4]		//Load the brick active flag

	ldr	r1, =#390		//Check if ball y value is in the bricks range
	cmp	ballTop, r1		
	movgt	r0, #0			//If not, collision impossible return 0
	bgt	done

.loop:
	cmp	r6, #0			//If brick is inactive
	beq	.loopTest		//Look at the next brick

	ldrh	r1, [r5, #8]		//Load leftmost value of brick
	sub	r1, #2
	cmp	ballX, r1		//Check if the right side of the ball is greater than brick
	blt	.loopTest		//If so, collision impossible, check next brick
	
	add	r1, #5			//4 pixel wiggle room
	cmp	ballX, r1		//If the right side of the ball is in range for the left side of brick
	bgt	.loopTest		//If not in range, collision impossible, check next brick


	ldrh	r1, [r5, #10]		//Load bottom Y value
	cmp	ballTop, r1		//If the top of the ball is greater than the brick, check next brick
	bgt	.loopTest
	
	sub	r1, #30			//Bricks are 30 pixels tall
	cmp	ballBottom, r1		//If the ball bottom is greater than the top of the brick
	bge	.done			//A collision has occurred
	

.loopTest:
	add	r0, #1			//Increment to the next brick number
	add	r5, #24			//Increment to the next brick address
	ldr	r6, [r5, #4]		//Load the next brick active flag	
	cmp	r0, #30			//Check if have iterated through all the bricks
	ble	.loop			//Else continue looping
	mov	r0, #0			//Otherwise return 0

.done:
	.unreq	ballX			//Forget register equates
	.unreq	ballTop
	.unreq	ballBottom

	pop	{r4-r9, lr}		//Pop registers and lr from the stack
	bx	lr			//Return to calling code



//brickRightCollide Subroutine
//Tests if the ball has collided with a brick on the right side
//No inputs
//Returns:
//	the brick number (1-30) if the ball has collided with a brick
//	or 0 if a collision has not occurred

.global brickRightCollide

brickRightCollide:
	push	{r4-r9, lr}		//Store registers and lr to the stack

	ballX		.req	r2
	ballTop		.req	r3
	ballBottom	.req	r4	

	mov	r0, #1			//Initialize a counter variable
	ldr	r1, =ballData		//Load ballData base address
	ldr	ballX, [r1]		//Load balls x value
	ldr	r1, =ballLeft		//Load ballLeft base address
	ldr	ballTop, [r1]		//Load balls topmost value
	ldr	ballBottom, [r1,#4]	//Load balls bottom most value
	ldr	r5, =brick1		//Load bricks base address
	ldr	r6, [r5, #4]		//Load the brick active flag

	ldr	r1, =#390		//Check if ball y value is in the bricks range
	cmp	ballTop, r1		
	movgt	r0, #0			//If not, collision impossible return 0
	bgt	done

for:
	cmp	r6, #0			//If brick is inactive
	beq	loop_test		//Look at the next brick

	ldrh	r1, [r5, #12]		//Load rightmost value of brick
	add	r1, #2	
	cmp	ballX, r1		//Check if the left side of the ball is greater than brick
	bgt	loop_test		//If so, collision impossible, check next brick
	
	sub	r1, #5			//4 pixel wiggle room
	cmp	ballX, r1		//If the left side of the ball is in range for the right side of brick
	blt	loop_test		//If not in range, collision impossible, check next brick

	ldrh	r1, [r5, #10]		//Load bottom Y value
	cmp	ballTop, r1		//If the top of the ball is greater than the brick, check next brick
	bgt	loop_test
	
	sub	r1, #30			//Bricks are 30 pixels tall
	cmp	ballBottom, r1		//If the ball bottom is greater than top of the brick
	bge	Done			//A collision has occurred


loop_test:
	add	r0, #1			//Increment to the next brick number
	add	r5, #24			//Increment to the next brick address
	ldr	r6, [r5, #4]		//Load the next brick active flag	
	cmp	r0, #30			//Check if have iterated through all the bricks
	ble	for			//Else continue looping
	mov	r0, #0			//Otherwise return 0

Done:
	.unreq	ballX			//Forget register equates
	.unreq	ballTop
	.unreq	ballBottom

	pop	{r4-r9, lr}		//Pop registers and lr from the stack
	bx	lr			//Return to calling code
@ Data section
.section .data

.align
