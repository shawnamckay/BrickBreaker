
.section .text

//increaseScore subroutine
//Increases the score by 100 if a brick is hit
//Then stores it in memory
//Inputs none
//Returns nothing

.global increaseScore

increaseScore:
	push	{lr}			//Store registers and lr to the stack

	ldr	r0, =score		//Get base address for score variable
	ldrh	r1, [r0]		//Load the current score the player has

	add	r1, #100		//Increase score by 100
	strh	r1, [r0]		//Store the new score variable

	pop	{lr}			//Pop register and lr from stack
	bx	lr			//return



//decreaseLives subroutine
//Decreases the lives variable by one if the ball hits the floor
//Then stores it in memory
//Inputs none
//Returns nothing

.global decreaseLives

decreaseLives:
	push	{lr}			//Store registers and lr to the stack

	ldr	r0, =lives		//Get base address for lives variable
	ldrh	r1, [r0]		//Load the current score the player has

	sub	r1, #1			//Decrease lives by one
	strh	r1, [r0]		//Store the new lives variable

	cmp	r1, #0			//If no lives left
	mov	r0, #0			//User lost
	bleq	gameEnd			//End game

	bl	restartBall		//Otherwise place ball back in starting position

	pop	{lr}			//Pop register and lr from stack
	bx	lr			//return


//restartBall subroutine
//Places the ball in the appropriate position after losing a life
//Also delays to give the user a moment to catch up
//Inputs none
//Returns nothing

.global restartBall
restartBall:
	push	{lr}			//Store registers and lr to the stack
	
	ldr	r2, =ballData		//Update the ball position information to the starting point
	mov	r0, #400		//Starting x value
	strh	r0, [r2]		//Update in memory
	mov	r1, #500		//Starting y value
	strh	r1, [r2, #4]		//Update in memory
	bl	UpdateBallPosition

	mov	r0, #400		//Draw the ball in its position
	mov	r1, #500
	bl	drawBall		//call drawBall

wait:
	bl 	Read_SNES		//Read_SNES gets data from the SNES controller	
	ldr 	r1,=0x7FFF		//Value of button B
	cmp	r0, r1			//Wait for the user to press the b button
	bne	wait			
	

	pop	{lr}			//Pop register and lr from stack
	bx	lr			//return



//Game_Play Subroutine
//Main point that controls the game play
//Input:None
//Returns: 1 if user wins, 0 if user loses
.global Game_Play

Game_Play:
	push	{r4-r7, lr}		//Store registers and lr to the stack

					//Left value of bumper
	lives	 	.req	r5	//Number of lives user has
	score		.req	r6
	ballDirect	.req	r7
		

	bl	init_Bricks		//Initialize the brick objects

	ldr	r0, =lives		//Initialize lives to 3
	mov	r1, #3
	strh	r1, [r0]
	
	ldr	r0, =score		//Initialize score to 0
	mov	r1, #0
	strh	r1, [r0]

	bl	drawBlack		//Draw the black background of the gameboard
	bl	drawWall		//Draw the grey border of the gameboard

	ldr	r0, =bumperData		//Get the base address
	ldr	r1, [r0] 		//Get the left bumper value
	ldr	r2, =#400		//Start the bumper in the middle of screen
	strh	r2, [r0]		//Store left value
	
	bl	Move_Bumper		//Show the bumper

	bl	updateBrickColor	//Updates the brick color based on memory
	bl	drawScoreWord		//Draw the word score on the screen
	bl	drawScore		//Draw the users score amount
	bl	drawLives		//Draw the amount of lives the user has

	bl	restartBall		//Starts the ball
	mov	ballDirect, #3		//Initial direction of ball is right down
	

	
.game_movement:

	
	bl	drawBlack		//Draw the black background of the gameboard
	bl	drawWall		//Draw the grey border of the gameboard

	bl	drawScoreWord		//Draw the word score on the screen
	bl	drawScore		//Draw the users score amount
	bl	drawLives		//Draw the amount of lives the user has

	bl	updateBrickColor	//Updates the brick color based on memory
	
	ldr	r0, =score		//Get base address for score variable
	ldr	score, [r0]		//Load the current score the player has
	ldr	r1, =#6000
	cmp	score, r1		//If score=6000
	mov	r0, #1			//Return 1 - user wins
	bleq	gameEnd			//End game


	mov	r0, ballDirect		//Move the current ball direction into r0
	bl	updateBallMovement	//call updateBallmovement

	mov	ballDirect, r0		//move the current ball direction into r0
	bl	moveBall		//call moveBall
	

	bl	Move_Bumper		//Call move bumper

	bl 	Read_SNES		//Read_SNES gets data from the SNES controller
	ldr	r1,=0xDFFF		//Value of button Select
	cmp	r0, r1			//If user presses select
	bleq	mainMenu		///jump to the main menu

	bl 	Read_SNES		//Read_SNES gets data from the SNES controller
	ldr 	r1, =0xEFFF		//Value of button Start
	cmp	r0, r1			//If user presses start
	bleq	Game_Play		///restart game


	ldr	r0, =#50000		//Delay to allow for user to let go of button
	bl 	delayMicroseconds	//Call delayMicroseconds



	b	.game_movement		//Continue looping through gamePlay

					//Forget register equates
	.unreq	lives
	.unreq	score
	.unreq	ballDirect

	pop	{r4-r7, lr}		//Pop register and lr from stack
	bx	lr			//return



