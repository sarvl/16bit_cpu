	jmp 	LEG start

; returns res in R0
; takes arg0 in R0
; takes arg1 in R1
; it is advised to put smaller value into R1 
mult:
	cmp 	R1, 0 
	jmp 	LG, mult_count
	
	mov 	R0, 0
	jmp 	LEG, mult_end

mult_count:
	mov 	R2, R0 

	sub 	R1, 1
mult_loop:
	add 	R0, R2

	sub 	R1, 1
	jmp 	G, mult_loop

mult_end:
	ret

;takes src  in R0
;takes dst  in R1
;takes size in R2
memcpy:
	cmp 	R2, 0
	ret 	LE

	rdm 	R3, R0
	wrm 	R3, R1

	add 	R0, 2
	add 	R1, 2
	sub 	R2, 2
	jmp 	LEG, memcpy

; takes ptr  in R0 
; takes size IN BYTES in R1
bubble_sort:
	mov 	R6, R0
	add 	R6, R1

	cmp 	R1, 2
	ret 	LE

	mov 	R2, R0
	mov 	R3, R0
	add 	R3, 2

bubble_sort_loop:
	rdm 	R4, R2
	rdm 	R5, R3
	
	cmp 	R4, R5
	; R3 is not greater
	jmp 	LE, bubble_sort_loop_cont

	;R3 is greater
	wrm 	R5, R2
	wrm 	R4, R3

bubble_sort_loop_cont:
	add 	R2, 2
	add 	R3, 2
	
	cmp 	R3, R6
	jmp 	L, bubble_sort_loop

	sub 	R1, 2
	jmp 	G, bubble_sort

	ret


start:
	; populate memory 

	mov 	R6, 164
	mov 	R0, 1
start_loop:
	mov 	R1, 123
	cal 	LEG, mult

	sll 	R0, 1
	slr 	R0, 1
	wrm 	R0, R6
	sub 	R6, 2
	cmp 	R6, 150
	jmp 	GZ, start_loop

	mov 	R0, 150
	mov 	R1, 200
	mov 	R2, 16
	cal 	LEG, memcpy

	mov 	R0, 150 
	mov 	R1, 16
	cal 	LEG, bubble_sort

print:
	rdm 	R0, 150 
	rdm 	R1, 152 
	rdm 	R2, 154 
	rdm 	R3, 156 
	rdm 	R4, 158 
	rdm 	R5, 160
	rdm 	R6, 162
	rdm 	R7, 164

	hlt
