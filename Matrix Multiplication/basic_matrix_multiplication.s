//Lucy Zhang
.global _start

//initialize memory
aMatrix: .hword -1, 2, 3, -4
bMatrix: .hword 6, -3, 2, 4
cMatrix: .hword 0, 0, 0, 0
size: .word 2

/*
R0: a addess
R1: b addess
R2: c addess
R3: size
R4/V1: row index
R5/V2: col index
R6/V3: iteration index
R7/V4: row*size or iter*size
R8/V5: c
R9/V6: shifted index
R10/V7: a
R11/V8: b
*/

mm:
	 push {A3, V1-V8}
	 mov V1, #0 //row = 0
	 mov V2, #0 //col = 0
	 mov V3, #0 //iter = 0
	 
row_loop:
	cmp V1, A4 //row < size
	mov V2, #0 //col = 0
	bge mm_done //if row >= size
	

col_loop:
	cmp V2, A4 //col < size
	mov V3, #0 // iter = 0
	bge col_loop_done // if col >= size
	
mmIter:
	cmp V3, A4 //iter < size
	bge mmIter_done // if iter >= size
	
	/*getting a value*/
	mla V4, V1, A4, V3 //row*size + iter
	lsl V4, V4, #1 //OFFSET
	ldrsh V7, [A1, V4] //V7=matrix a + OFFSET
	
	/*getting b value*/
	mla V4, V3, A4, V2 // iter*size + row
	lsl V4, V4, #1 //OFFSET
	ldrsh V8, [A2, V4] //V8=matrix b + OFFSET
	
	mul V7, V7, V8 // a=a*b
	ldrsh V8, [A3] //get current value of c
	add V7, V7, V8 //add new c to old c
	strh V7, [A3] //store new c to memory

	add V3, #1
	b mmIter
	
mmIter_done:
	add V2, #1 //col++
	add A3, A3, #2 //next index in c
	b col_loop //branches back to col loop

col_loop_done:
	add V1, #1 //row++
	b row_loop //branches back to row loop

mm_done:
	pop {A3, V1-V8}
	bx lr

_start:
	ldrsh A1, =aMatrix
	ldrsh A2, =bMatrix
	ldrsh A3, =cMatrix
	ldr A4, size
	bl mm
	
infinite_loop:
	b infinite_loop
	
