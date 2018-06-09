
// Code from CPSC 359 tutorial
@ Draw Pixel
@ Draws a pixel on the screen
@  r0 - x
@  r1 - y
@  r2 - colour
@  Subroutine provided in tutorial exercises

.global DrawPixel

DrawPixel:
	push		{r4, r5}		@ store registers to the stack

	offset		.req	r4		@ Declare register equate for readability

	ldr		r5, =frameBufferInfo	@ Load address of frameBuffer	

	@ offset = (y * width) + x
	
	ldr		r3, [r5, #4]		@ r3 = width
	mul		r1, r3		
	add		offset,	r0, r1
	
	@ offset *= 4 (32 bits per pixel/8 = 4 bytes per pixel)
	lsl		offset, #2

	@ store the colour (word) at frame buffer pointer + offset
	ldr		r0, [r5]		@ r0 = frame buffer pointer
	str		r2, [r0, offset]

	pop		{r4, r5}		@ pop registers off of the stack
	bx		lr			@ return to calling code