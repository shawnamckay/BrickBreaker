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
	
	bl	mainMenu		//Display the main menu

haltLoop:	
	b	haltLoop		//Halt loop to end program





//Main Menu subroutine
//Shows the approriate main menu based on user input
//Inputs none
//Returns nothing

.global mainMenu
mainMenu: 
	push	{lr}			//Store registers and lr to the stack

startLoop:	
	ldr	r0, =startMenu		//Get the base address of the image bitmap
	bl	drawStart		//Draw the start menu

	bl 	Read_SNES		//Read_SNES gets data from the SNES controller
	ldr 	r1, =0xFBFF		//Value of button Down
	cmp 	r0, r1			//Check if equal to button down
	beq	startEnd		//If user presses down, jump to startQuit
	
	ldr 	r1,=0xFF7F		//Value of button A
	cmp	r0, r1			//Check if equal to button A
	bleq	howTo			//If user presses A jump to howTo

	b	startLoop		//Otherwise continue showing start screen

startEnd:
	ldr	r0, =startQuit		//Get the base address of the image bitmap
	bl	drawStart		//Draw the start menu
	
	bl 	Read_SNES		//Read_SNES gets data from the SNES controller
	ldr	r1, =0xF7FF		//Value of button up
	cmp 	r0, r1			//Check if equal to button up
	beq	startLoop		//If user presses up, jump to startLoop
	
	ldr 	r1,=0xFF7F		//Value of button A
	cmp	r0, r1			//Check if equal to button A
	bleq	clearScreen		//If user presses A jump to quit

	b	startEnd		//If not, continue showing start screen

	pop	{lr}			//Pop register and lr from stack
	bx	lr			//return


//howTo Subroutine
//Displays an instruction screen for the use
//No inputs
//Returns nothing
.global howTo
howTo: 
	push	{lr}			//Store registers and lr to the stack
wait:
	ldr	r0, =instructions
	bl	drawStart		//Draw the instruction screen

	bl 	Read_SNES		//Read_SNES gets data from the SNES controller
	
	ldr 	r1, =0xFDFF		//Value of button Left
	cmp 	r0, r1			//Check if equal to button left
	bleq	Game_Play		//If user presses left, jump to gamePlay
	ldr	r1, =0xFEFF		//Value of button right
	cmp 	r0, r1			//Check if equal to button right
	bleq	Game_Play		//If user presses right, jump to gamePlay

	b	wait			//Else continue waiting for user

	pop	{lr}			//Pop register and lr from stack
	bx	lr			//return



//gameEnd subroutine
//Displays the win or lose screen to the user
//Gives the option the play again or exit
//Input r0, 1=win, all other values= loss
//Returns nothing
.global gameEnd
gameEnd:
	push	{r4-r9, lr}		//Store registers and lr to the stack

	cmp	r0, #1			//If the user has won
	bne	lose			//If not show the loss menu
	
win:
	mov	r0, #50000		//Delay added so user can let go of a button
	bl	delayMicroseconds	

	mov	r0, #50000		//Delay added so user can let go of a button
	bl	delayMicroseconds

	mov	r0, #50000		//Delay added so user can let go of a button
	bl	delayMicroseconds

	ldr	r0, =winYay		//Draw the win menu
	bl	drawPauseMenu

	bl 	Read_SNES		//Read_SNES gets data from the SNES controller	
	
	ldr 	r1, =0xFFFF		//Value = no buttons pressed
	cmp	r0, r1			//If user presses a button
	blne	mainMenu		//return to main menu
	b	win



lose:
	bl	drawLives		//Draw the amount of lives the user has
	mov	r0, #50000		//Delay added so user can let go of a button
	bl	delayMicroseconds	

	mov	r0, #50000		//Delay added so user can let go of a button
	bl	delayMicroseconds

	mov	r0, #50000		//Delay added so user can let go of a button
	bl	delayMicroseconds


	ldr	r0, =loseEnd		//Draw the lose menu
	bl	drawPauseMenu
	bl 	Read_SNES		//Read_SNES gets data from the SNES controller	

	ldr 	r1, =0xFFFF		//Value = no buttons pressed
	cmp	r0, r1			//If user presses a button
	blne	mainMenu		//return to main menu
	
	b	lose			//Else continue displaying menu


	pop	{r4-r9, lr}		//Pop register and lr from stack
	bx	lr			//return



//clearScreen subroutine
//Blacks out the game screen then halts the game
//Input none
//Returns nothing

.global clearScreen
clearScreen:
	push 	{lr}

	bl	blackOut		//Draw a black out on the screen

haltLoop$:	
	b	haltLoop$		//Halt loop to end program

	pop	{lr}
	bx	lr



@ Data section
.section .data
 

.global GpioPtr	
GpioPtr:				//Value to store GPIO base addrses
.int	0


.global lives
lives:
	.int	3			//Player starts out with 3 lives

.global score
score:	
	.int	0			//Player starts out with a score of 0

.align
.global frameBufferInfo
frameBufferInfo:
	.int	0		@ frame buffer pointer
	.int	0		@ screen width
	.int	0		@ screen height



 
 