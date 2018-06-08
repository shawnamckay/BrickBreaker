//CPSC 359
//Assignment 2
//Arkanoid (Brick Breaker Game) for SNES using ARM v7 and a Raspberry Pi3
//Shawna McKay

.section .text

 
.global main
main: 
	bl 	Initialize		//Sets the GPIO pins for SNES gameplay
	
	ldr 	r0, =frameBufferInfo 	@ frame buffer information structure
	bl	initFbInfo		//Initialize the frame buffer information
	
	bl	Game_Play	//FOR DEBUGGING		
	

startLoop:	
	bl	drawStart		//Draw the start menu

	bl 	Read_SNES		//Read_SNES gets data from the SNES controller
	ldr 	r1, =0xFBFF		//Value of button Down
	cmp 	r0, r1			//Check if equal to button down
	beq	startQuit		//If user presses down, jump to startQuit
	
	ldr 	r1,=0xFF7F		//Value of button A
	cmp	r0, r1			//Check if equal to button A
	beq	howTo			//If user presses A jump to howTo

	b	startLoop		//Otherwise continue showing start screen

startQuit:
	
	bl	drawMenuQuit
	
	bl 	Read_SNES		//Read_SNES gets data from the SNES controller
	ldr	r1, =0xF7FF		//Value of button up
	cmp 	r0, r1			//Check if equal to button up
	beq	startLoop		//If user presses down, jump to startQuit
	
	ldr 	r1,=0xFF7F		//Value of button A
	cmp	r0, r1			//Check if equal to button A
	beq	quit			//If user presses A jump to quit
	
	
	b	startQuit		//If not, continue showing start screen


howTo:
	
	bl	drawInstructions	//Draw the instruction screen

	bl 	Read_SNES		//Read_SNES gets data from the SNES controller
	
	ldr 	r1, =0xFDFF		//Value of button Left
	cmp 	r0, r1			//Check if equal to button left
	bleq	Game_Play		//If user presses left, jump to gamePlay
	ldr	r1, =0xFEFF		//Value of button right
	cmp 	r0, r1			//Check if equal to button right
	bleq	Game_Play		//If user presses right, jump to gamePlay

	b	howTo			//Else continue waiting for user



	


.start:

	bl 	Read_SNES		//Read_SNES gets data from the SNES controller
	ldr 	r1, =0xFFFF		//Value = no buttons pressed
	cmp 	r0, r1			//If no buttons are pressed 
	beq 	.start			//branch back to start
	
	bl	Write_Message		//If a button has been pressed, output a message to screen
	cmp	r0, #5			//If button=start
	beq 	quit			//Jump to exit
	
	ldr	r0, =#100000		//Delay to allow for user to let go of button
	bl 	delayMicroseconds	//Call delayMicroseconds	
	
	ldr	 r0, =pressButton	//Prompt user to press a button
	bl 	printf			//Call printf

	b 	.start			//Loop back to .start


quit:	
  	ldr 	r0, =end		//Display a program terminating message to screen
	bl 	printf			//Call printf



haltLoop$:	
	b	haltLoop$		//Halt loop to end program


//Game_Play Subroutine
//
//Input:None
//Returns: 
Game_Play:
	push	{r4-r8, lr}		//Store registers and lr to the stack

	bumpLeft 	.req 	r4		//Left value of bumper
	border 	 	.req 	r5		//Top value of bumper
	lives	 	.req	r6		//Number of lives user has
	score		.req	r7
	ballDirect	.req	r8
		
	mov	lives, #3		//Initialize lives to 3
	mov	bumpLeft, #400		//Starting position of the bumper left side
	ldr	border, =#583		//Edge of the gameboard on the right side

	bl	init_Bricks		//Initialize the brick objects
	
	mov	ballDirect, #1		//Ball starts moving leftdown
	mov	score, #0		//Initialize score to zero
	

	
	
.game_movement:
	bl	drawBlack		//Draw the black background of the gameboard
	bl	drawWall		//Draw the grey border of the gameboard
		
	bl	updateBrickColor	//Updates the brick color based on memory

	mov	r0, ballDirect		//Move the current ball direction into r0
	bl	updateBallMovement	//call updateBallmovement

	mov	ballDirect, r0		//move the current ball direction into r0
	bl	moveBall		//call moveBall

	bl	wallCollide		//Check for collisions

//	mov	r1, r0
//	ldr	r0, =wallTest
//	bl	printf	

//	ldr	r0, =wallData
//	ldr	r1,[r0]
//	ldr	r0, =ballLeft
//	ldr	r2, [r0, #8]
//	mov	r3, #0
//	ldr	r0, =ballTest
//	bl	printf	

	
	mov	r0, bumpLeft		//Move the left side of the bumper into r0
	mov	r1, border		//Move the border into r0
	bl	Move_Bumper		//Call move bumper
	mov	bumpLeft, r0		//Store the left side of the bumper in r0

	

	ldr	r0, =#100000		//Delay to allow for user to let go of button
	bl 	delayMicroseconds	//Call delayMicroseconds

	b	.game_movement		//Continue looping through gamePlay

	.unreq	bumpLeft		//Forget register equates
	.unreq	border
	.unreq	lives
	.unreq	score
	.unreq	ballDirect
	pop	{r4-r8, lr}		//Pop register and lr from stack
	bx	lr			//return


//Move_Bumper Subroutine
//Moves the bumper based on user input
//Input: r0= left most side of bumper, r1= right most side of bumper
//Returns:Nothing 

Move_Bumper:
	push	{r4-r5, lr}			//Store registers and lr to the stack

	bumpLeft 	.req 	r4		//Left value of bumper
	border 	 	.req 	r5		//Top value of bumper
	
	mov	bumpLeft, r0
	mov	border, r1



	bl 	Read_SNES		//Read_SNES gets data from the SNES controller
	
	ldr 	r1, =0xFDFF		//Value of button Left
	cmp 	r0, r1			//Check if equal to button left
	subeq	bumpLeft, #20		//Move bumper left

	ldr	r1, =0xFEFF		//Value of button right
	cmp 	r0, r1			//Check if equal to button right
	addeq	bumpLeft, #20		//Move bumper right
	
	cmp	bumpLeft, #217		//Check if bumper is still inside gameboard on left side
	movlt	bumpLeft, #217		//If not move bumper to edge of border

	cmp	bumpLeft, border	//Check if bumper is still inside gameboard on the right side 
	movge	bumpLeft, border	//If not move bumper to the edge of the border

	mov	r0, bumpLeft		//Left value of bumper
	mov	r1, #800		//Top of bumper (never changes)
	bl	drawBumper		//Calls drawBumper based on values in r0 and r1

	mov	r0, bumpLeft
	bl	updateBumperPosition	//Update the bumpers position in storage

	mov	r0, bumpLeft		//return the bumpLeft value

	.unreq	bumpLeft		//Forget register equates
	.unreq	border

	
	pop	{r4-r5, lr}			//Pop register and lr from stack
	bx	lr			//return


//Update_Bricks Subroutine
//Uses the brick number to mark it as inactive and update color to black
//Input: brick number that has been collided
//Returns: Nothing
Update_Bricks:
	push	{r4,lr}			//Store registers and lr to the stack



	mov	r1, #24			//Move 24 into r1 for multiplication
	sub	r0, #1
	mul	r4, r1, r0		//offset= brick number-1 *24

	ldr	r0, =brick1		//get base address of bricks
	add	r4, r0			//Update address to base+offset
		

	ldr	r0, =brick1	//testing data storage
	ldr	r1, [r0]	//color
	ldrh	r2, [r0, #4]	//active
	ldrh	r3, [r0, #6]	//health
	ldr	r0, =test1
	bl	printf

	ldr	r0, =brick1	
	ldrh	r1, [r0, #8]	//left
	ldrh	r2, [r0, #10]	//bottom
	ldrh	r3, [r0, #12]	//right
	ldr	r0, =test2
	bl	printf

	ldr	r0, =brick1	
	ldrh	r1, [r0, #14]
	ldr	r0, =test3
	bl	printf
	
	ldrh	r1, [r4, #6]		//Load health amount
	sub	r1, #1			//Health=health-1
	strh	r1, [r4, #6]		//Store updated health
	cmp	r1,#0			//If health=0, update color to black & active flag
	bne	done			//Else exit
	

	ldr	r0, =0xFF000000		//Load black
	str	r0,[r4]			//update color

	mov	r0, #0			//Load inactive
	strh	r0,[r4, #4]		//update status to inactive
	

				//to be removed

	ldr	r0, =brick1	//testing data storage
	ldr	r1, [r0]	//color
	ldrh	r2, [r0, #4]	//active
	ldrh	r3, [r0, #6]	//health
	ldr	r0, =test1
	bl	printf

	ldr	r0, =brick1	
	ldrh	r1, [r0, #8]	//left
	ldrh	r2, [r0, #10]	//bottom
	ldrh	r3, [r0, #12]	//right
	ldr	r0, =test2
	bl	printf

	ldr	r0, =brick1	
	ldrh	r1, [r0, #14]
	ldr	r0, =test3
	bl	printf




	//Multiply offset by 24
	//Load x value
	// Load y value
	// Load color value =black
	// bl draw_Brick
	//Store 0 in active
	//Store color in offset	
done:

	pop	{r4, lr}		//Pop register and lr from stack
	bx	lr			//return




//Write_Message Subroutine
//Displays output message to user telling them which button was pressed on the SNES controller
//Input r0=data read from SNES controller
//Returns 5 if the Select button is pressed

Write_Message:
	push	{r4, lr}		//Store registers and lr to the stack
	
	button 	.req 	r4		//Initialize register equates to increase readability
	mov 	button, r0		//Copy input into button register to save value
	
	ldr 	r1,=0x7FFF		//Value of button B
	cmp	button, r1		//Check if equal to button b
	ldreq	r0, =pressB		//If equal output message to user telling them pressed b
	bleq 	printf			//Call printf

	ldr 	r1,=0xBFFF		//Value of button Y
	cmp 	button, r1		//Check if equal to button Y
	ldreq	r0, =pressY		//If equal output message to user telling them pressed y
	bleq 	printf			//Call printf

	ldr 	r1,=0xFF7F		//Value of button A
	cmp	button, r1		//Check if equal to button A
	ldreq 	r0, =pressA		//If equal output message to user telling them pressed a
	bleq 	printf			//Call printf

	ldr 	r1,=0xFFBF		//Value of button X
	cmp 	button, r1		//Check if equal to button X
	ldreq 	r0, =pressX		//If equal output message to user telling them pressed x
	bleq 	printf			//Call printf


	ldr	r1,=0xDFFF		//Value of button Select
	cmp 	button, r1		//Check if equal to button Select
	ldreq	r0, =pressSelect	//If equal output message to user telling them pressed select
	bleq 	printf			//Call printf
 
	ldr 	r1, =0xEFFF		//Value of button Start
	cmp 	button, r1		//Check if equal to button start
	ldreq 	r0, =pressStart		//If equal output message to user telling them pressed start
	bleq 	printf			//Call printf
	moveq	r0, #5			//Return 5, start button has been pressed
	beq 	exit			//Jump to exit

	ldr	r1, =0xF7FF		//Value of button up
	cmp 	button, r1		//Check if equal to button up
	ldreq 	r0, =pressUp		//If equal output message to user telling them pressed up
	bleq 	printf			//Call printf

	ldr	r1, =0xFBFF		//Value of button down
	cmp	button, r1		//Check if equal to button down
	ldreq 	r0, =pressDown		//If equal output message to user telling them pressed down
	bleq 	printf			//Call printf
	
	ldr	r1, =0xFDFF		//Value of button left
	cmp 	button, r1		//Check if equal to button left
	ldreq 	r0, =pressLeft		//If equal output message to user telling them pressed left
	bleq 	printf			//Call printf
	
	ldr	r1, =0xFEFF		//Value of button right
	cmp 	button, r1		//Check if equal to button right
	ldreq 	r0, =pressRight		//If equal output message to user telling them pressed right
	bleq 	printf			//Call printf
	
	ldr	r1, =0xFFEF		//Value of button right trigger
	cmp 	button, r1		//Check if equal to button right trigger
	ldreq 	r0, =pressRTrigger	//If equal output message to user telling them pressed right trigger
	bleq 	printf			//Call printf
	
	ldr	r1, =0xFFDF		//Value of button left trigger
	cmp 	button, r1		//Check if equal to button left trigger
	ldreq	r0, =pressLTrigger	//If equal output message to user telling them pressed left trigger
	bleq 	printf			//Call printf




	ldr	r0, =ballData	//testing data storage
	ldrh	r1, [r0]	//leftmost
	ldrh	r2, [r0, #4]	//top most
	mov	r3, #0
	ldr	r0, =ballTest
	bl	printf

	ldr	r0, =ballTop	
	ldrh	r1, [r0]	//top y
	ldrh	r2, [r0, #4]	//left top y
	ldrh	r3, [r0, #8]	//right top y
	ldr	r0, =ballTest
	bl	printf




	ldr	r0, =ballLeft	
	ldrh	r1, [r0]	//top y
	ldrh	r2, [r0, #4]	//left top y
	ldrh	r3, [r0, #8]	//right top y
	ldr	r0, =ballTest
	bl	printf


	ldr	r0, =ballRight	
	ldrh	r1, [r0]	//top y
	ldrh	r2, [r0, #4]	//left top y
	ldrh	r3, [r0, #8]	//right top y
	ldr	r0, =ballTest
	bl	printf

exit:
	.unreq 	button			//Remove register equates
	pop	{r4, lr}		//Pop register and lr from stack
	bx	lr			//return




@ Data section
.section .data
 

.global GpioPtr	
GpioPtr:				//Value to store GPIO base addrses
.int	0


wallTest:
	.asciz "%hd \n"

ballTest:
	.asciz "   %hd %hd %hd \n"

test1:
	.asciz "   %x %hd %hd "
test2:
	.asciz "   %hd %hd %hd"	
test3:
	.asciz "  %hd \n"	
	
welcome:			
	.asciz "   Created by: Shawna McKay\n"	

end:					
	.asciz "   Program is terminating...\n"  

pressButton:			
	.asciz "   Please press a button...\n"

pressB:
	.asciz "You pressed B \n" 

pressY:
	.asciz "You pressed Y \n" 

pressSelect:
	.asciz "You pressed Select \n" 

pressStart:
	.asciz "You pressed Start \n" 

pressUp:
	.asciz "You pressed Up \n" 

pressDown:
	.asciz "You pressed Down \n" 

pressLeft:
	.asciz "You pressed Left \n" 

pressRight:
	.asciz "You pressed Right \n" 

pressA:
	.asciz "You pressed A \n" 

pressX:
	.asciz "You pressed X \n" 

pressRTrigger:
	.asciz "You pressed the Right Trigger \n" 

pressLTrigger:
	.asciz "You pressed the Left Trigger \n" 

.align
.global frameBufferInfo
frameBufferInfo:
	.int	0		@ frame buffer pointer
	.int	0		@ screen width
	.int	0		@ screen height



 
 