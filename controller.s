.section .text

 

.global Initialize

//Initialize subroutine
//Intializes the clock, latch and data pins
//No inputs
//Returns nothing

Initialize:
	push	{lr}			//Store lr to the stack
	ldr 	r0, =GpioPtr		//Get address of GpioPtr in Memory
	bl	initGpioPtr		//Call subroutine to initialize GpioPtr address
	ldr	r1, =GpioPtr		//load address of "GpioPtr" into r1	
	str	r0, [r1]		//store returned value from initGpioPtr into "GpioPtr"	

	mov	r0, #9			// latch = pin 9
	mov	r1, #1			//output =0b001
	bl	Init_GPIO		//Initialize Latch to Output
 
	mov	r0, #10			//data = pin 10
	mov	r1, #0			//input =0b000
	bl	Init_GPIO		//Initialize Data to Input
	
	mov	r0, #11			//clock = pin 11
	mov	r1, #1			//output=0b001
	bl	Init_GPIO		//Initialize Clock to Output
	pop	{lr}			//Pop lr from the stack
	bx	lr			//Return 



.global Init_GPIO

//Init_GPIO subroutine
//Updates the function stored based on the pin number for GPIO pins
//Inputs: r0=pin number, r1=function - input or output
//Returns nothing
Init_GPIO:
	push 	{r4, r5, lr}		//Store register and lr to the stack
	
	pin 	.req	r4		//Declare register equates to help with readability
	func 	.req	r5
	
	mov	pin, r0			//copy pin number to a variable register
	mov	func, r1		//copy func to a variable registter
 
	ldr	r0, =GpioPtr		//Load address of GpioPtr
	ldr	r0, [r0]		//load value from GpioPtr
 
	cmp	pin, #10		//If pin >= 10
	bge	.Sel1			//jump to Sel1

	b 	.setFunc		//Otherwise in GPFSEL0, jump to .setFunc
 
.Sel1:					
	add	r0, r0, #4		//add 4 to base address to access GPFSEL1
	sub	pin, pin, #10		//subtract 10 from the pin number
 
.setFunc:
	ldr	r1, [r0]		//copy GPFSEL0/GPFSEL1 into r1
	mov	r2, #7			//move 0111 to r2
	mov	r7, #3			//Move 3 into r7
	mul	pin, pin, r7		//Multiply pin by 3 get correct bits for pin
	
	lsl	r2, pin			//Shift bit mask to 1st bit for pin
	bic	r1, r2			//clear correct bits
	
	lsl	func, pin		//Shift the function bits to the 1st pin for the bit
	orr	r1, func		//set correct pin in r1
	str	r1, [r0]		//write back to GPFSEL1/GPFSEL0
 
	.unreq	func			//Remove register equates
	.unreq	pin
	pop	{r4, r5, lr}		//pop registers
	bx	lr

.global Write_Latch

//Write_Latch Subroutine
//Sets or Clears the Latch Pin
//Input: r0=1 if setting, r0=0 if clearing
//Returns nothing
 
Write_Latch:
	push	{lr}			//Store lr to the stack
	
	mov	r1, #9			//Latch = pin #9
	ldr	r2, =GpioPtr		//Get the GPIO base address
	ldr	r2, [r2]		//Load value from the GPIO base address

	mov	r3, #1			//Move 1 to r3, to store in either set or clear
	lsl	r3, r1			//shift bits to match with pin #9
 
	cmp	r0, #0			//Check if r0=0
 
	streq	r3, [r2, #40]		//If r0=0, then store 1 in GPCLR0 to clear the bit
	strne	r3, [r2, #28]		//Otherwise, store 1 in GPSET0 to set the bit
	
	pop	{lr}			//Pop lr from the stack
	bx	lr			//return


.global Write_Clock

//Write_Clock Subroutine
//Sets or Clears the Clock Pin
//Input: r0=1 if setting, r0=0 if clearing
//Returns nothing

Write_Clock:
	push	{lr}
 
	mov	r1, #11			//Clock = pin #11
	ldr	r2, =GpioPtr		//Get the GPIO base address
	ldr	r2, [r2]		//Load value from the GPIO base address

	mov	r3, #1			//Move 1 to r3, to store in either set or clear
	lsl	r3, r1			//shift bits to match with pin #11
 
	cmp	r0, #0			//Check if r0=0
 
	streq	r3, [r2, #40]		//If r0=0, then store 1 in GPCLR0 to clear the bit
	strne	r3, [r2, #28]		//Otherwise, store 1 in GPSET0 to set the bit
	
	pop	{lr}			//Pop lr from the stack
	bx	lr			//return


.global Read_Data

//Read_Data Subroutine
//Reads the Data pin 
//No input
//Returns 1 or 0 depending on what is in the Data pin

Read_Data:
	push	{lr}
	
	mov	r0, #10			//Data= pin #10
	ldr	r2, =GpioPtr		//Get the GPIO base address
	ldr	r2, [r2]		//Load value from the GPIO base address
	ldr	r1, [r2, #52]		//Load the value for GPLEV0 into r1

	mov	r3, #1			//Store 1 in r3
	lsl	r3, r0			//Shift bits to match with pin #10
 
	and	r1, r3			//use a bitmask to mask out all other bits
	cmp	r1, #0			//Check if r1=0
 
	moveq	r0, #0			//If r1=0, return 0
	movne	r0, #1			//Else if r1=1, return 1
	
	pop	{lr}
	bx	lr			//return



.global Read_SNES

//Read_SNES Subroutine
//Contains the loops to get information from the SNES controller of what button is pressed
//No input
//Returns value that of which button has been pushed

Read_SNES:
	push	{r4, r5, lr}		//Store registers and lr to the stack
	counter	.req 	r4		//Initialize register equates to increase readability
	button 	.req 	r5

	mov	 button, #0		//Clear value in button register
	
	mov	r0, #1			//Set the Clock line
	bl	Write_Clock		//write 1 to Clock line	
	
	mov	r0, #1			//Set the Latch line
	bl	Write_Latch		//write 1 to latch line
 
	mov	r0, #12			//pause program for 12 microseconds
	bl	delayMicroseconds	//Call delayMicroseconds
 
	mov	r0, #0			//Clear the Latch Line
	bl	Write_Latch		//write 0 to latch line
 
	mov	counter, #0		//initialize the counter to 0
 
pulseLoop:
 
	mov	r0, #6			//pause program for 6 microseconds
	bl	delayMicroseconds	//Call delayMicroseconds
 
	mov	r0, #0			//Clear the Clock line
	bl	Write_Clock		//write 0 to clock line
 
	mov	r0, #6			//pause program for 6 microseconds
	bl	delayMicroseconds	//Call delayMicroseconds
 
	bl	Read_Data		//get Data Line 
 
	lsl	button, #1		//shift button value left by one
	orr	button, r0		//store the bit from Read_Data in the button register
	
	mov	r0, #1			//Set the Clock line
	bl	Write_Clock		//write 1 to Clock line	
 
	add	counter, counter, #1	//increment counter
	
	cmp	counter, #16		//Check if counter is less than 16
	blt	pulseLoop		//If less that 16, jump back to pulseLoop
 
	mov	r0, button		//Else, return button value
	
	.unreq	button			//Forget register equates
	.unreq	counter
 
	pop	{r4, r5, lr}		//pop registers and lr from the stack
	bx	lr

