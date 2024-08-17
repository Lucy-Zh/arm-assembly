//Lucy Zhang
.global _start

	input_array: .word 4, 6, 7, 9, 10, 11, 13, 15
	x: .word 9
	low_index: .word 5
	high_index: .word 7
	
/*
R0: input array
R1: x
R2: low
R3: high
R4/V1: mid calculations + change in index
R5/V2: array with index
*/
	
recursive_binary_search:
	push {A2-A4, V1-V2, lr}
	//if (lowIdx >= highIdx)
	cmp A3, A4
	bge binary_search_done
	
	//int mid = (lowIdx + highIdx)/2;
	add V1, A3, A4
	asr V1, V1, #1 //mid
	
	//if (x == array[mid])
	lsl V2, V1, #2
	ldr V2, [A1, V2]
	cmp V2, A2
	beq return_found_mid
	
	//if (x > array[mid])
	cmp A2, V2
	bgt set_new_low
	//else
	b set_new_high
	
binary_search_done:
	lsl V2, A3, #2
	ldr V2, [A1, V2]
	cmp A2, V2 //if (x == array[lowIdx])
	beq return_found_last
	b return_not_found //else

return_found_last:
	mov A1, A3
	pop {A2-A4, V1-V2, lr}
	bx lr
	
return_found_mid:
	mov A1, V1
	pop {A2-A4, V1-V2, lr}
	bx lr

return_not_found:
	mov A1, #-1
	pop {A2-A4, V1-V2, lr}
	bx lr

set_new_low:
	add A3, V1, #1
	bl recursive_binary_search
	pop {A2-A4, V1-V2, lr}
	bx lr

set_new_high:
	sub A4, A4, #1
	bl recursive_binary_search
	pop {A2-A4, V1-V2, lr}
	bx lr

_start:
	ldr A1, =input_array
	ldr A2, x
	ldr A3, low_index
	ldr A4, high_index
	bl recursive_binary_search
	
infinite_loop:
	b infinite_loop
