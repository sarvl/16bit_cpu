#basic test of all alu functions
#failure probably indicates not working alu 

 	mov 	R0, 0
 	mov 	R1, 1
 	mov 	R2, 2
 	mov 	R3, 3
 	mov 	R4, 4
 	mov 	R5, 5
 	mov 	R6, 6
 	mov 	R7, 7

	add 	R0, R1
	add 	R1, R2
	add 	R2, R3
	add 	R3, R4
	add 	R4, R5
	add 	R5, R6
	add 	R6, R7
	add 	R7, R0


	sll 	R0, 1
	sll 	R1, 1
	sll 	R2, 1
	sll 	R3, 1
	sll 	R4, 1
	sll 	R5, 1
	sll 	R6, 1
	sll 	R7, 1


	wrm 	R0, 100
	wrm 	R1, 102
	wrm 	R2, 104
	wrm 	R3, 106
	wrm 	R4, 108
	wrm 	R5, 110
	wrm 	R6, 112
	wrm 	R7, 114
	hlt 	LEG
