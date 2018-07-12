.section .text

.global	init_Bricks

//Initialize Bricks Subroutine
//Creates the default values for all of the bricks
//No inputs
//Returns nothing

init_Bricks:
	push	{r4-r9, lr}		//Store registers and lr to the stack
	counter	   .req r4		//Register equate for counter variable
					//r5 is base address of brick
	
	mov	counter, #1		//Initialize counter to 1
	ldr	r5, =brick1		//Get address of first brick
	mov	r6, #215		//Initial left x value of first brick
	mov	r7, #245		//Initial bottom y value of first brick

.loop:
	mov 	r0, counter		//Use counter to determine color value
	bl	set_Colour		//Get color hex value
	str	r0, [r5]		//store color

	mov	r0, #1			//1=Active
	strh	r0, [r5, #4]		//Store active flag to on

	mov	r0, counter		//Use counter to determine health value
	bl	set_Health		//call get_Health
	strh	r0, [r5, #6]		//Store health value

	strh	r6, [r5, #8] 		//Store bottom left x value
	strh	r7, [r5, #10]		//Store bottom y value
	strh	counter, [r5, #14]	//Store brick number

	mov	r0, r6			//Move x value
	mov	r1, r7			//Move y value
	ldr	r2, [r5]		//Load color value
	//bl	draw_Brick		//Call draw_Brick
	
	add	r6, #94			//Increment x value by 94 pixels (width of brick)
	strh	r6, [r5, #12] 		//Store right most x value of brick

	cmp	counter, #5		//If brick value = 5
	addeq	r7, #30			//Increment y value by 30 (height of a brick)
	moveq	r6, #215		//Change x value to left wall of game window

	cmp	counter, #10		//If brick value = 10
	addeq	r7, #30			//Increment y value by 30 (height of a brick)
	moveq	r6, #215		//Change x value to left wall of game window

	cmp	counter, #15		//If brick value = 15
	addeq	r7, #30			//Increment y value by 30 (height of a brick)
	moveq	r6, #215		//Change x value to left wall of game window

	cmp	counter, #20		//If brick value = 20
	addeq	r7, #30			//Increment y value by 30 (height of a brick)
	moveq	r6, #215		//Change x value to left wall of game window

	cmp	counter, #25		//If brick value = 25
	addeq	r7, #30			//Increment y value by 30 (height of a brick)
	moveq	r6, #215		//Change x value to left wall of game window

	add	counter, #1		//Increment counter
	add	r5, #24			//Increment brick base address

	cmp	counter, #30		//If counter <= 30 (number of bricks)
	ble	.loop			//Continue initializing bricks
	
	.unreq	counter			//Forget register equate

	pop	{r4-r9, lr}		//Pop registers and lr from the stack
	bx	lr			//Return to calling code




//Update_Bricks Subroutine
//Uses the brick number to mark it as inactive and update color to black
//Input: brick number that has been collided
//Returns: Nothing
.global Update_Bricks
Update_Bricks:
	push	{r4,lr}			//Store registers and lr to the stack



	mov	r1, #24			//Move 24 into r1 for multiplication
	sub	r0, #1
	mul	r4, r1, r0		//offset= brick number-1 *24

	ldr	r0, =brick1		//get base address of bricks
	add	r4, r0			//Update address to base+offset

	ldrh	r1, [r4, #6]		//Load health amount
	sub	r1, #1			//Health=health-1
	strh	r1, [r4, #6]		//Store updated health

	cmp	r1,#0			//If health=0, update color to black & active flag
	bgt	done			//Else exit
	

	ldr	r0, =0xFF000000		//Load black
	str	r0,[r4]			//update color

	mov	r0, #0			//Load inactive
	strh	r0,[r4, #4]		//update status to inactive


done:


	pop	{r4, lr}		//Pop register and lr from stack
	bx	lr			//return


.global updateBrickColor
//updateBrickColor Subroutine
//Updates the colors of the bricks based on what is stored in memory
//Inputs none
//Returns nothing
updateBrickColor:
	push	{r4-r9, lr}		//Store registers and lr to the stack
	counter	.req 	r4		//Register equate for counter variable


	mov	counter, #1		//Initialize counter to 1
	ldr	r5, =brick1		//Get address of first brick

for:
	ldrh 	r0, [r5, #8]		//Offset to load left x value
	ldrh 	r1, [r5, #10]		//Offset to load bottom y value
	ldr	r2, [r5]		//Color
	bl 	draw_Brick		//Call draw_Brick
	add 	counter, #1		//increment counter
	add	r5, #24			//Offset to the next brick
	cmp	counter, #31		//Check if counter is less than 31 (30 bricks)
	blt	for			//If less keep looping
	
		

	.unreq	counter			//Forget register equates

	pop	{r4-r9, lr}		//Pop registers and lr from the stack
	bx	lr			//Return to calling code


//draw_Brick Subroutine
//Draws brick objects
//input r0=x,r1=y values for bottom left r2= color
//returns nothing
draw_Brick:
	push	{r4-r9, lr}		//Store registers and lr to the stack
	mov	r4, r0			//Save x value
	mov	r5, r1			//save y value
	mov	r6, r2			//save color
	add	r7, r0, #94		//save right border
	sub	r8, r1, #30		//save bottom border
	mov	r9, r0			//save left x value

box:
	mov	r0, r4			//Move x value into r0
	mov	r1, r5			//Move y value into r1
	mov	r2, r6			@ colour
	bl	DrawPixel		//Call drawPixel
	add	r4, #1			//Increment x value by one
	cmp	r4, r7			//Check if x value is less than brick size
	blt	box			//If have not reached end of brick, keep drawing right
	mov	r4, r9			//Restart at left side of the brick
	sub	r5, #1			//Increment y value by one
	cmp	r5, r8			//Check if at the bottom of the brick
	bge	box			//If not keep drawing
	

	pop	{r4-r9, lr}		//Pop registers and lr from the stack
	bx	lr			//Return to calling code




//set_Colour subroutine
//Uses the brick number to assign a colour
//Input r0= brick number
//Returns hex color value

set_Colour:
	push 	{lr}

colorLoop:
	cmp 	r0, #1			//If brick number =1
	beq	purple			//paint it purple

	cmp 	r0, #2			//If brick number =2
	beq	blue			//paint it orange

	cmp	r0,#3			//If brick number =3
	beq	green			//paint it green

	cmp	r0,#4			//If brick number =4
	beq	red			//paint it red

	cmp	r0,#5			//If brick number =5
	beq	orange			//paint it orange
	
	cmp	r0, #6			//If brick number =6
	beq	yellow			//paint it yellow

	sub	r0, #6			//or else subtract 6
	b	colorLoop		//And keep looping


red:
	ldr 	r0, =0xFFFF5B60		//return Hex value for red
	b	end

blue:
	ldr 	r0, =0xFF63DAFF		//return Hex value for blue
	b	end

green:
	ldr 	r0, =0xFF7BCC25		//return Hex value for green
	b	end
orange:
	ldr 	r0, =0xFFFFBB42		//return Hex value for orange
	b	end

purple:
	ldr 	r0, =0xFFD756FF		//return Hex value for purple
	b	end

yellow:
	ldr 	r0, =0xFFFBFF2F		//return Hex value for yellow
	
end:
	pop 	{lr}
	bx	lr


//set_Health subroutine
//Uses the brick number to assign a health value
//Input r0= brick number
//Returns integer health value (1-3)

set_Health:
	push 	{lr}

	cmp 	r0, #10			//If brick number <=10
	ble	three			//health=3

	cmp	r0,#20			//If brick number <=20
	ble	two			//health=2

	mov	r0, #1			//Else health=1
	b	.end

three:
	mov	r0, #3			//Return 3
	b	.end

two:	
	mov	r0, #2			//Return 2
	b	.end
.end:
	pop 	{lr}			//Return to calling code
	bx	lr

@ Data section
.section .data

.align
				//Describes how the data is stored in each brick object

.global brick1			//Brick values
brick1:
	.word			@ color
	.int	0		@ active flag
	.int	0		@ health
	.int	0		@ bottom left x value
	.int	0		@ bottom y value
	.int	0		@ bottom right x value
	.int	0		@ brick number


.global brick2
brick2:
	.word			@ color
	.int	0		@ active flag
	.int	0		@ health
	.int	0		@ bottom left x value
	.int	0		@ bottom y value
	.int	0		@ bottom right x value
	.int	0		@ brick number


.global brick3
brick3:
	.word			@ color
	.int	0		@ active flag
	.int	0		@ health
	.int	0		@ bottom left x value
	.int	0		@ bottom y value
	.int	0		@ bottom right x value
	.int	0		@ brick number

.global brick4
brick4:
	.word			@ color
	.int	0		@ active flag
	.int	0		@ health
	.int	0		@ bottom left x value
	.int	0		@ bottom y value
	.int	0		@ bottom right x value
	.int	0		@ brick number
.global brick5
brick5:
	.word			@ color
	.int	0		@ active flag
	.int	0		@ health
	.int	0		@ bottom left x value
	.int	0		@ bottom y value
	.int	0		@ bottom right x value
	.int	0		@ brick number

.global brick6
brick6:
	.word			@ color
	.int	0		@ active flag
	.int	0		@ health
	.int	0		@ bottom left x value
	.int	0		@ bottom y value
	.int	0		@ bottom right x value
	.int	0		@ brick number

.global brick7
brick7:
	.word			@ color
	.int	0		@ active flag
	.int	0		@ health
	.int	0		@ bottom left x value
	.int	0		@ bottom y value
	.int	0		@ bottom right x value
	.int	0		@ brick number

.global brick8
brick8:
	.word			@ color
	.int	0		@ active flag
	.int	0		@ health
	.int	0		@ bottom left x value
	.int	0		@ bottom y value
	.int	0		@ bottom right x value
	.int	0		@ brick number

.global brick9
brick9:
	.word			@ color
	.int	0		@ active flag
	.int	0		@ health
	.int	0		@ bottom left x value
	.int	0		@ bottom y value
	.int	0		@ bottom right x value
	.int	0		@ brick number

.global brick10
brick10:
	.word			@ color
	.int	0		@ active flag
	.int	0		@ health
	.int	0		@ bottom left x value
	.int	0		@ bottom y value
	.int	0		@ bottom right x value
	.int	0		@ brick number

.global brick11
brick11:
	.word			@ color
	.int	0		@ active flag
	.int	0		@ health
	.int	0		@ bottom left x value
	.int	0		@ bottom y value
	.int	0		@ bottom right x value
	.int	0		@ brick number

.global brick12
brick12:
	.word			@ color
	.int	0		@ active flag
	.int	0		@ health
	.int	0		@ bottom left x value
	.int	0		@ bottom y value
	.int	0		@ bottom right x value
	.int	0		@ brick number

.global brick13
brick13:
	.word			@ color
	.int	0		@ active flag
	.int	0		@ health
	.int	0		@ bottom left x value
	.int	0		@ bottom y value
	.int	0		@ bottom right x value
	.int	0		@ brick number

.global brick14
brick14:
	.word			@ color
	.int	0		@ active flag
	.int	0		@ health
	.int	0		@ bottom left x value
	.int	0		@ bottom y value
	.int	0		@ bottom right x value
	.int	0		@ brick number

.global brick15
brick15:
	.word			@ color
	.int	0		@ active flag
	.int	0		@ health
	.int	0		@ bottom left x value
	.int	0		@ bottom y value
	.int	0		@ bottom right x value
	.int	0		@ brick number

.global brick16
brick16:
	.word			@ color
	.int	0		@ active flag
	.int	0		@ health
	.int	0		@ bottom left x value
	.int	0		@ bottom y value
	.int	0		@ bottom right x value
	.int	0		@ brick number


.global brick17
brick17:
	.word			@ color
	.int	0		@ active flag
	.int	0		@ health
	.int	0		@ bottom left x value
	.int	0		@ bottom y value
	.int	0		@ bottom right x value
	.int	0		@ brick number

.global brick18
brick18:
	.word			@ color
	.int	0		@ active flag
	.int	0		@ health
	.int	0		@ bottom left x value
	.int	0		@ bottom y value
	.int	0		@ bottom right x value
	.int	0		@ brick number

.global brick19
brick19:
	.word			@ color
	.int	0		@ active flag
	.int	0		@ health
	.int	0		@ bottom left x value
	.int	0		@ bottom y value
	.int	0		@ bottom right x value
	.int	0		@ brick number

.global brick20
brick20:
	.word			@ color
	.int	0		@ active flag
	.int	0		@ health
	.int	0		@ bottom left x value
	.int	0		@ bottom y value
	.int	0		@ bottom right x value
	.int	0		@ brick number

.global brick21
brick21:
	.word			@ color
	.int	0		@ active flag
	.int	0		@ health
	.int	0		@ bottom left x value
	.int	0		@ bottom y value
	.int	0		@ bottom right x value
	.int	0		@ brick number
.global brick22
brick22:
	.word			@ color
	.int	0		@ active flag
	.int	0		@ health
	.int	0		@ bottom left x value
	.int	0		@ bottom y value
	.int	0		@ bottom right x value
	.int	0		@ brick number
.global brick23
brick23:
	.word			@ color
	.int	0		@ active flag
	.int	0		@ health
	.int	0		@ bottom left x value
	.int	0		@ bottom y value
	.int	0		@ bottom right x value
	.int	0		@ brick number
.global brick24
brick24:
	.word			@ color
	.int	0		@ active flag
	.int	0		@ health
	.int	0		@ bottom left x value
	.int	0		@ bottom y value
	.int	0		@ bottom right x value
	.int	0		@ brick number
.global brick25
brick25:
	.word			@ color
	.int	0		@ active flag
	.int	0		@ health
	.int	0		@ bottom left x value
	.int	0		@ bottom y value
	.int	0		@ bottom right x value
	.int	0		@ brick number
.global brick26
brick26:
	.word			@ color
	.int	0		@ active flag
	.int	0		@ health
	.int	0		@ bottom left x value
	.int	0		@ bottom y value
	.int	0		@ bottom right x value
	.int	0		@ brick number
.global brick27
brick27:
	.word			@ color
	.int	0		@ active flag
	.int	0		@ health
	.int	0		@ bottom left x value
	.int	0		@ bottom y value
	.int	0		@ bottom right x value
	.int	0		@ brick number
.global brick28
brick28:
	.word			@ color
	.int	0		@ active flag
	.int	0		@ health
	.int	0		@ bottom left x value
	.int	0		@ bottom y value
	.int	0		@ bottom right x value
	.int	0		@ brick number
.global brick29
brick29:
	.word			@ color
	.int	0		@ active flag
	.int	0		@ health
	.int	0		@ bottom left x value
	.int	0		@ bottom y value
	.int	0		@ bottom right x value
	.int	0		@ brick number
.global brick30
brick30:
	.word			@ color
	.int	0		@ active flag
	.int	0		@ health
	.int	0		@ bottom left x value
	.int	0		@ bottom y value
	.int	0		@ bottom right x value
	.int	0		@ brick number
