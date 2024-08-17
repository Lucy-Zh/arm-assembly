//Lucy Zhang
.global _start
	aMatrix: .hword -1, 2, 3, -4
	bMatrix: .hword 6, -3, 2, 4
	cMatrix: .hword 0, 0, 0, 0
/*
R0: a addess/u
R1: b addess/v
R2: c addess
R3: aa
R4/V1: bb
R5/V2: cc
R6/V3: dd
R7/V4: AA
R8/V5: BB
R9/V6: CC
R10/V7: DD
R11/V8: w
*/
wmm22:
	// access each element of a and b
	// value <= *(base address + row number * row size + col number)
	push {A4, V1-V8}
	ldrsh A4, [A1] //aa
	ldrsh V1, [A1, #2] //bb
	ldrsh V2, [A1, #4] //cc
	ldrsh V3, [A1, #6] //dd
	ldrsh V4, [A2] //AA
	ldrsh V5, [A2, #4] //BB
	ldrsh V6, [A2, #2] //CC
	ldrsh V7, [A2, #6] //DD
	//u,v,w calulations
	push {A1-A2}
	push {A3}
	sub A1, V2, A4
	sub A2, V6, V7
	mul A1, A1, A2 //A1=u
	add A2, V2, V3
	sub A3, V6, V4
	mul A2, A2, A3 //A2=v
	add A3, V2, V3
	sub A3, A3, A4
	add V8, V4, V7
	sub V8, V8, V6
	mul A3, A3, V8
	mul V8, A4, V4
	add V8, V8, A3 //V8=w
	pop {A3}
	/*start c value calulations*/
	push {A3} //we use original c address as an argument within calculations
	push {V2, V3}
	//*c = aa*AA + bb*BB;
	mul V2, A4, V4
	mla V2, V1, V5, V2
	strh V2, [A3]
	pop {V2, V3}
	add A3, A3, #2
	//*(c + 0*2 + 1) = w + v + (aa + bb - cc - dd)*DD;
	push {V4}
	add V4, A4, V1
	sub V4, V4, V2
	sub V4, V4, V3
	mla V4, V4, V7, V8
	add V4, V4, A2
	strh V4, [A3]
	pop {V4}
	add A3, A3, #2
	//*(c + 1*2 + 0) = w + u + dd*(BB + CC - AA - DD);
	push {A4}
	add A4, V5, V6
	sub A4, A4, V4
	sub A4, A4, V7
	mla A4, A4, V3, V8
	add A4, A4, A1
	strh A4, [A3]
	pop {A4}
	add A3, A3, #2
	//*(c + 1*2 + 1) = w + u + v;
	add A1, A1, A2
	add A1, A1, V8
	strh A1, [A3]
	//restore state of processors
	pop {A3}
	pop {A1-A2}
	pop {A4, V1-V8}
	bx lr
	
_start:
	ldrsh A1, =aMatrix
	ldrsh A2, =bMatrix
	ldrsh A3, =cMatrix
	bl wmm22
	
infinite_loop:
	b infinite_loop
