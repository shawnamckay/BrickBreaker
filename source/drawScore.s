
.section .text

//DrawScore Subroutine
//Shows the users score
//No inputs
//Returns nothing

.global drawScore

drawScore:
	push	{r4-r8, lr}		//Store registers and lr to the stack	
	
	ldr	r0, =score		//Get the base address of the score variable
	ldrh	r4, [r0]		//Load the score
	ldr	r5, =#847		//Top y value of numbers never changes
	
	cmp	r4, #0			//If score == 0
	moveq	r0, #433		//Left x value of number
	moveq	r1, r5			//Top of number
	ldr	r2, =zeroNumber		//Address of number bitmap
	bleq	drawNumber		//Draw zero
	beq	exit

	
	ldr	r0, =#6000
	cmp	r4, r0			//If score is greater than 6000 draw six
	blt	fiveThous		//else jump to five thousand score

	mov	r0, #331		//Left x value of number
	mov	r1, r5			//Top of number
	ldr	r2, =sixNumber		//Address of number bitmap
	bl	drawNumber		//Draw six
	ldr	r0, =#6000
	sub	r4, r0			//Subtract 6000
	b	hundreds		

fiveThous:
	ldr	r0, =#5000
	cmp	r4, r0			//If score is greater than 5000 draw five
	blt	fourThous		//else jump to four thousand score

	mov	r0, #331		//Left x value of number
	mov	r1, r5			//Top of number
	ldr	r2, =fiveNumber		//Address of number bitmap
	bl	drawNumber		//Draw five
	ldr	r0, =#5000
	sub	r4, r0			//Subtract 5000	
	b	hundreds		
	
fourThous:
	ldr	r0, =#4000
	cmp	r4, r0			//If score is greater than 4000 draw four
	blt	threeThous		//else jump to three thousand score

	mov	r0, #331		//Left x value of number
	mov	r1, r5			//Top of number
	ldr	r2, =fourNumber		//Address of number bitmap
	bl	drawNumber		//Draw four
	ldr	r0, =#4000
	sub	r4, r0			//Subtract 4000
	b	hundreds		

threeThous:
	ldr	r0, =#3000
	cmp	r4, r0			//If score is greater than 3000 draw three
	blt	twoThous		//else jump to two thousand score

	mov	r0, #331		//Left x value of number
	mov	r1, r5			//Top of number
	ldr	r2, =threeNumber	//Address of number bitmap
	bl	drawNumber		//Draw three
	ldr	r0, =#3000
	sub	r4, r0			//Subtract 3000
	b	hundreds		

twoThous:
	cmp	r4, #2000		//If score is greater than 2000
	blt	oneThous
		
	mov	r0, #331		//Left x value of number
	mov	r1, r5			//Top of number
	ldr	r2, =twoNumber		//Address of number bitmap
	bl	drawNumber		//Draw two
	sub	r4, #2000		//Subtract 2000
	b	hundreds		

oneThous:
	cmp	r4, #1000		//If score is greater than 1000 draw one
	blt	hundreds		//else jump to hundreds score

	mov	r0, #331		//Left x value of number
	mov	r1, r5			//Top of number
	ldr	r2, =oneNumber		//Address of number bitmap
	bl	drawNumber		//Draw one
	sub	r4, #1000		//Subtract 1000

hundreds:
	cmp	r4, #900		//If score=900
	moveq	r0, #366		//Left x value of number
	moveq	r1, r5			//Top of number
	ldreq	r2, =nineNumber		//Address of number bitmap
	bleq	drawNumber		//Draw nine
	beq	zeros			
	
	cmp	r4, #800		//If score=800
	moveq	r0, #366		//Left x value of number
	moveq	r1, r5			//Top of number
	ldreq	r2, =eightNumber	//Address of number bitmap
	bleq	drawNumber		//Draw eight
	beq	zeros			
	
	cmp	r4, #700		//If score=700
	moveq	r0, #366		//Left x value of number
	moveq	r1, r5			//Top of number
	ldreq	r2, =sevenNumber	//Address of number bitmap
	bleq	drawNumber		//Draw seven
	beq	zeros	
		
	cmp	r4, #600		//If score=600
	moveq	r0, #366		//Left x value of number
	moveq	r1, r5			//Top of number
	ldreq	r2, =sixNumber		//Address of number bitmap
	bleq	drawNumber		//Draw six
	beq	zeros	

	cmp	r4, #500		//If score=500
	moveq	r0, #366		//Left x value of number
	moveq	r1, r5			//Top of number
	ldreq	r2, =fiveNumber		//Address of number bitmap
	bleq	drawNumber		//Draw five
	beq	zeros			

	cmp	r4, #400		//If score=400
	moveq	r0, #366		//Left x value of number
	moveq	r1, r5			//Top of number
	ldreq	r2, =fourNumber		//Address of number bitmap
	bleq	drawNumber		//Draw four
	beq	zeros			

	cmp	r4, #300		//If score=300
	moveq	r0, #366		//Left x value of number
	moveq	r1, r5			//Top of number
	ldreq	r2, =threeNumber	//Address of number bitmap
	bleq	drawNumber		//Draw three
	beq	zeros			

	cmp	r4, #200		//If score=200
	moveq	r0, #366		//Left x value of number
	moveq	r1, r5			//Top of number
	ldreq	r2, =twoNumber		//Address of number bitmap
	bleq	drawNumber		//Draw two
	beq	zeros			

	cmp	r4, #100		//If score=100
	moveq	r0, #366		//Left x value of number
	moveq	r1, r5			//Top of number
	ldreq	r2, =oneNumber		//Address of number bitmap
	bleq	drawNumber		//Draw one
	beq	zeros			

	cmp	r4, #0			//If score=0
	moveq	r0, #366		//Left x value of number
	moveq	r1, r5			//Top of number
	ldreq	r2, =zeroNumber		//Address of number bitmap
	bleq	drawNumber		//Draw zero

zeros:
	mov	r0, #400		//Left x value of number
	mov	r1, r5			//Top of number
	ldr	r2, =zeroNumber		//Address of number bitmap
	bl	drawNumber		//Draw zero	
		
	mov	r0, #433		//Left x value of number
	mov	r1, r5			//Top of number
	ldr	r2, =zeroNumber		//Address of number bitmap
	bl	drawNumber		//Draw zero


exit:
	pop	{r4-r8, lr}		//Pop registers and lr from the stack
	bx	lr			//Return to calling code



//drawNumber subroutine
//draws the numbers
//Inputs r0 = left x value of number, r1 = top y value of number. r2= image bitmap of number
//Returns nothing
.global drawNumber
drawNumber:
	push	{r4-r9, lr}		//Store registers and lr to the stack
	mov	r6, r2
	
	mov	r4, r0			//Store x value
	mov	r5, r1			//Store y value
	mov	r9, r4			//Store leftmost pixel
	add	r7, r4, #34		//Numbers are 34 pixels wide
	add	r8, r5, #38		//Numbers are 34 pixels tall

horizontal:
	mov	r0, r4			//Move x value into r0
	mov	r1, r5			//Move y value into r1
	ldr	r2, [r6]		//Get bit value from eightNumber image
	bl	DrawPixel		//Call drawPixel
	add	r4, #1			//Increment x value by one
	cmp	r4, r7			//Check if x value is less than number size
	add	r6, #4			//Increment address of bitmap to next pixel
	blt	horizontal		//If have not reached end of number, keep drawing right
	mov	r4, r9			//Restart at left side of the number
	add	r5, #1			//Increment y value by one
	cmp	r5, r8			//Check if at the bottom of the number
	blt	horizontal		//If not keep drawing

	pop	{r4-r9, lr}		//Pop registers and lr from the stack
	bx	lr			//Return to calling code



