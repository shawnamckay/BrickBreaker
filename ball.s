.section .text


//updateBallMovement subroutine
//Changes the ballDirect variable if a collision has occurred
//Input current direction of ball
//Output new direction of ball

.global updateBallMovement

updateBallMovement:
	push	{r4-r9, lr}		//Store registers and lr to the stack
	ballDirect .req	r4
	mov	ballDirect, r0		//Save the current ball direction

checkWall:
	bl	wallCollide		//Check if the ball has collided with a wall
	cmp	r0, #0			//If no collisions
	beq	checkBrickBottom	//Then check if hit a brick

	cmp	r0, #1			//If left wall
	beq	sideWall		//Jump to sidewall section
	cmp	r0, #3			//If right wall
	beq	sideWall		//Jump to sidewall section
	cmp	r0, #2			//If top wall
	beq	topWall			//Jump to top wall section
	cmp	r0, #4			//If floor

	bl	decreaseLives		//Call decrease lives
	mov	ballDirect, #3		//Update the ball direction

	b	quit			//Otherwise exit

sideWall:
	cmp	ballDirect, #1		//If moving left down
	moveq	r4, #3			//Move right down
	beq	quit			//Then exit

	cmp	ballDirect, #2		//If moving left up
	moveq	r4, #4			//Move right up
	beq	quit			//Then exit

	cmp	ballDirect, #3		//If moving right down
	moveq	r4, #1			//Move left down
	beq	quit			//Then exit

	cmp	ballDirect, #4		//If moving right up
	moveq	r4, #2			//Move left up
	beq	quit			//Then exit

topWall:

	cmp	ballDirect, #2		//If moving left up
	moveq	r4, #1			//Move left down
	beq	quit			//Then exit

	cmp	ballDirect, #4		//If moving right up
	moveq	ballDirect, #3		//Move right down
	b	quit			//Then exit

leftBump:
	mov	ballDirect, #2		//If left side of bumper is hit, move left up
	b	quit			//Then exit

rightBump:
	mov	ballDirect, #4		//If right side of bumper is hit move right up
	b	quit			//Then exit

midBump:				//If the ball hits the middle of the bumper
	cmp	ballDirect, #1		//If moving left down
	moveq	ballDirect, #2		//Move left up
	beq	quit			//Then exit

	cmp	ballDirect, #3		//If moving right down
	moveq	ballDirect, #4		//Move right up
	b	quit			//Then exit
	

checkBrickBottom:
	bl	brickBottomCollide	//Check for a brick bottom collision	
	cmp	r0, #0			//If no collision
	beq	checkBrickLeft		//Test if the left side of the brick has been hit
	bl	Update_Bricks		//If collision, update the brick values
	bl	increaseScore		//If collision, increase game score
	b	topWall			//Then bounce the ball like it has hit the ceiling

checkBrickLeft:
	bl	brickLeftCollide	//Check for a brick Left collision	
	cmp	r0, #0			//If no collision
	beq	checkBrickRight		//Test if the right side of the brick has been hit
	bl	Update_Bricks		//If collision, update the brick values
	bl	increaseScore		//If collision, increase game score
	b	sideWall		//Then bounce the ball like it has hit a side wall

checkBrickRight:
	bl	brickRightCollide	//Check for a brick Left collision	
	cmp	r0, #0			//If no collision
	beq	checkBrickTop		//Test if the bumper has been hit
	bl	Update_Bricks		//If collision, update the brick values
	bl	increaseScore		//If collision, increase game score
	b	sideWall		//Then bounce the ball like it has hit a side wall

checkBrickTop:
	bl	brickTopCollide		//Check for a brick Left collision	
	cmp	r0, #0			//If no collision
	beq	checkBumper		//Test if the bumper has been hit
	bl	Update_Bricks		//If collision, update the brick values
	bl	increaseScore		//If collision, increase game score
	b	midBump			//Then bounce the ball like it has hit the middle of the bumper

checkBumper:
	bl	bumperCollide		//Check if the ball has collided with the bumper
	cmp	r0, #0			//If not exit
	beq	quit		
	cmp	r0, #2			//If the middle section of the bumper
	beq	midBump
	cmp	r0, #1
	beq	leftBump		//If the left section of the bumper
	cmp	r0, #3	
	beq	rightBump		//If the right section of the bumper	
		
	


quit:
	mov	r0, ballDirect		//Return ball direction	

	.unreq 	ballDirect
	pop	{r4-r9, lr}		//Pop registers and lr from the stack
	bx	lr			//Return to calling code


//moveBall subroutine
//Uses the ball direction to call the correct movement subroutine
//Input r0=ball direction
//Returns nothing
.global moveBall
moveBall:
	push	{r4, lr}		//Store registers and lr to the stack

	mov	r4, r0			//Save the current ball direction

	cmp	r4, #1			//If moving left down
	moveq	r0, #-8
	moveq	r1, #8
	bleq	movementOfBall		//continue moving left down	
	beq	end			//then exit

	cmp	r4, #2			//If moving left up
	moveq	r0, #-8
	moveq	r1, #-8
	bleq	movementOfBall		//continue moving left up	
	beq	end			//then exit

	cmp	r4, #3			//If moving right down
	moveq	r0, #8
	moveq	r1, #8
	bleq	movementOfBall		//continue moving right down
	beq	end			//then exit

	cmp	r4, #4			//If moving right up
	moveq	r0, #8
	moveq	r1, #-8
	bleq	movementOfBall		//continue moving right up
	beq	end			//then exit

end:
	pop	{r4, lr}		//Pop registers and lr from the stack
	bx	lr			//Return to calling code
	



.global	drawBall

//DrawBall Subroutine
//Draws the game ball (26 pixels wide x 29 pixels) during gameplay
//Inputs r0=x (left of ball), r1=y (top of ball)
//Returns nothing

drawBall:
	push	{r4-r9, lr}		//Store registers and lr to the stack
	
	mov	r4, r0			@ x
	mov	r8, r0			//Saves the left side of the ball
	mov	r5, r1			@ y
	mov	r7, #1			//counter for height of the ball

row1:
	add 	r4, r8, #10		//Offset from left corner to draw ball (8 pixels wide in this row)
	add	r6, r8, #18		//Offset from left corner to right corner to draw ball
	
drawLine:
	mov	r0, r4			//Move x value into r0
	mov	r1, r5			//Move y value into r1
	ldr	r2, =0xFFFFFFFF		@ colour
	bl	DrawPixel		//Call DrawPixel
	cmp	r4, r6			//Check if reached right side of ball
	add	r4, #1			//Move one pixel horizontally
	ble	drawLine		//If not the right side of ball continue drawing

	add	r7, #1			//Increment counter to track height of ball
	add	r5, #1			//Increment y value to draw

	cmp	r7, #28			//If the last row
	beq	row1			//Draw the same size row as the first
	cmp	r7, #29			//29 pixels = height of ball
	beq	exit			//If reached height, exit

	cmp	r7, #2			//Rows 2-3 are the same size
	beq	row2
	cmp	r7, #3
	beq	row2
	cmp	r7, #26			//Rows 26-27 are the same size
	beq	row2
	cmp	r7, #27
	beq	row2

	cmp	r7, #4			//Rows 4-5 are same size
	beq	row3
	cmp	r7, #5
	beq	row3
	cmp	r7, #24			//Rows 24-25 are the same size
	beq	row3
	cmp	r7, #25
	beq	row3

	cmp	r7, #6			//Rows 6-9 are the same size
	beq	row4
	cmp	r7, #7
	beq	row4
	cmp	r7, #8
	beq	row4
	cmp	r7, #9
	beq	row4
	cmp	r7, #20			//Rows 20-23 are the same size
	beq	row4
	cmp	r7, #21
	beq	row4
	cmp	r7, #22
	beq	row4
	cmp	r7, #23
	beq	row4

	cmp	r7, #10			//Rows 10-19 are the same size (9 pixels high)
	beq	middle
	cmp	r7, #11
	beq	middle
	cmp	r7, #12

	beq	middle
	cmp	r7, #13
	beq	middle
	cmp	r7, #14
	beq	middle
	cmp	r7, #15
	beq	middle
	cmp	r7, #16
	beq	middle
	cmp	r7, #17
	beq	middle
	cmp	r7, #18
	beq	middle
	cmp	r7, #19
	beq	middle



row2:
	add	r4, r8, #6		//Left side of ball (14 pixels wide)
	add	r6, r8, #20		//Right side of ball
	b	drawLine
row3:
	add	r4, r8, #4		//Left side of ball (18 pixels wide)
	add	r6, r8, #22		//Right side of ball
	b	drawLine

row4:
	add	r4, r8, #2		//Left side of ball (22 pixels wide)
	add	r6, r8, #24		//Right side of ball
	b	drawLine

middle:
	mov	r4, r8			//Left side of ball (26 pixels wide)
	add	r6, r8, #26		//Right side of ball
	b	drawLine


exit:
	
	pop	{r4-r9, lr}		//Pop registers and lr from the stack
	bx	lr			//Return to calling code



//movement of ball Subroutine
//Moves the ball diagonally on the screen 
//Input: r0= x movement, r1 = y movement
//Returns nothing
.global movementOfBall
movementOfBall:
	push	{r4-r5, lr}		//Store registers and lr to the stack

	ldr	r2, =ballData		//Balls leftmost value address
	ldrh	r4, [r2]		//Balls leftmost value
	add	r4, r0			//Move left or right
	strh	r4, [r2]		//Update value in memory
	
	ldrh	r5, [r2, #4]		//Balls top y value
	add	r5, r1			//Move up or down
	strh	r5, [r2, #4]		//Update value in memory

	mov	r0, r4			//Move leftmost x value
	mov	r1, r5			//Move topmost y value
	bl	drawBall		//Draw ball in new position

	mov	r0, r4			//Move leftmost x value
	mov	r1, r5			//Move top most y value
	bl	UpdateBallPosition	//Update ball position markers in memory
	

	pop	{r4-r5, lr}		//Pop registers and lr from the stack
	bx	lr			//Return to calling code 





//UpdateBallPosition Subroutine
//Updates the balls position based on the offsets from the top x value and top y value
//Then stores updated information in ballData
//Inputs r0=leftmost x, r1=top most y
//Returns nothing
.global UpdateBallPosition
UpdateBallPosition:
	push	{r4-r5, lr}		//Store registers and lr to the stack
	
	mov	r4, r0			//Save leftmost x value
	mov	r5, r1			//Save topmost y value
	
	ldr	r0, =ballTop		//Get ball data address
	add	r1, r4, #10		//Top left/bottom x value = leftmost +10 
	strh	r1, [r0]		//Store updated value
	add	r1, #8			//Top right/bottom right x value = top left + 8
	strh	r1, [r0, #4]		//Store updated value
	strh	r5, [r0, #8]		//Store updated value y

	ldr	r0, =ballBottom
	add	r1, r4, #10		//Top left/bottom x value = leftmost +10 	
	strh	r1, [r0]		//Store updated value
	add	r1, #8			//Top right/bottom right x value = top left + 8
	strh	r1, [r0, #4]		//Store updated value
	add	r2, r5, #29		//Bottom y value
	strh	r2, [r0, #8]		//Store updated value

	
	ldr	r0, =ballLeft
	add	r2, r5, #10		//Left top/Right top y = top y + 10
	strh	r2, [r0]		//Store updated value left top
	add	r2, #8			//Left bottom/Right bottom y = top right/top left + 8
	strh	r2, [r0, #4]		//Store left bottom
	strh	r4, [r0, #8]		//left x value

	
	ldr	r0, =ballRight
	add	r2, r5, #10		//Left top/Right top y = top y + 10
	strh	r2, [r0]		//Store updated value right top
	add	r2, #8			//Left bottom/Right bottom y = top right/top left + 8
	strh	r2, [r0, #4]		//Store right bottom
	add	r1, r4, #24		//Right x value
	strh	r1, [r0, #8]		//x value

	
	pop	{r4-r5, lr}		//Pop registers and lr from the stack
	bx	lr			//Return to calling code


@ Data section
.section .data

.align

.global ballData
ballData:				//Ball has four sides (in the game logic)
	.int	400			//Leftmost x value for drawing ball
	.int	500			//Top most value for drawing ball Offset = 4

.global ballTop
ballTop:
	.int 	0			//Top left x value (leftmost + 10) 
	.int	0			//Top right x value (top left + 8) Offset = 4
	.int	0			//Top y value Offset = 8

.global ballBottom
ballBottom:
	.int 	0			//Bottom left x value (leftmost +10) 
	.int	0			//Bottom right x value (bottom left + 8) 
	.int	0			//Bottom y value (top y + 29) 

.global ballRight
ballRight:
	.int	0			//Right top y value (top y +10) 
	.int	0			//Right bottom y value (right top + 9) 
	.int	0			//Right x value  (leftmost +26)

.global ballLeft
ballLeft:
	.int	0			//Left top y value (top	 y + 10) 
	.int	0			//Left bottom y value (left top y + 9) 
	.int	0			//Left x value =leftmost 

