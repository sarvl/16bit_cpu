#this code simulates the processor that it is running on 
#in particular, this simulator has fibonacci program loaded, stack test commented, ext reg test commented
#
#it is possible for program to work correctly and break inside this simulator
#this can happen for 3 reasons, all are related to memory
#1: program accesses own instructions
#2: program uses almost all memory available to cpu
#3: program accesses stack without using psh/pop or sp 
#reason 1 is fixable but introduces more complexity
#reason 2 is impossible to fix as simulator itself requires some memory for instructions and registers
#reason 3 might be possible to fix but requires changing how the memory is organized and much more complex logic for accessing it
#most programs will not suffer from these problems, the most probable one to cause problems is reason #3
#
#
#yes, this simulator can simulate itself but due to reason #2 its unlikely to work OOB 
#the entire memory is "allocated"
#
#
#wrx/rdx might be broken as they were not tested as well as others instructions

	jmp 	start

#see g01t03.asm
program:
#fib:
	dw  	0x2800
	dw  	0x2901
	dw  	0x2F07
	dw  	0x8F00
	dw  	0xA60A
	dw  	0x0205
	dw  	0x0025
	dw  	0x0158
	dw  	0xCF01
	dw  	0xA305
	dw  	0x3850
	dw  	0x3864
	dw  	0x3966
	dw  	0x3A68
	dw  	0x3B6A
	dw  	0x3C6C
	dw  	0x3D6E
	dw  	0x3E70
	dw  	0x3F72
	dw  	0x0F00
#stack test:
#	dw  	0x280A
#	dw  	0x7000
#	dw  	0xC801
#	dw  	0xA301
#	dw  	0x7900
#	dw  	0x890A
#	dw  	0xA504
#	dw  	0x3864
#	dw  	0x3966
#	dw  	0x3A68
#	dw  	0x3B6A
#	dw  	0x3C6C
#	dw  	0x3D6E
#	dw  	0x3E70
#	dw  	0x3F72
#	dw  	0x0F00
#ext reg test:
#	dw  	0x2805
#	dw  	0x0105
#	dw  	0xF002
#	dw  	0x6C01
#	dw  	0x2A00
#	dw  	0xFA07
#	dw  	0xC001
#	dw  	0x0010
#	dw  	0xCA01
#	dw  	0xA306
#	dw  	0x6C01
#	dw  	0x048C
#	dw  	0x6A14
#	dw  	0xB700
#	dw  	0x2D09
#	dw  	0x8504
#	dw  	0x3D64
#	dw  	0x3664
#	dw  	0x05BD
#	dw  	0x6815
#	dw  	0xAF0E
#	dw  	0x3864
#	dw  	0x3966
#	dw  	0x3A68
#	dw  	0x3B6A
#	dw  	0x3C6C
#	dw  	0x3D6E
#	dw  	0x3E70
#	dw  	0x3F72
#	dw  	0x0F00
registers:
r_0:
	dw  	0x0000	
r_1:
	dw  	0x0000	
r_2:
	dw  	0x0000	
r_3:
	dw  	0x0000	
r_4:
	dw  	0x0000	
r_5:
	dw  	0x0000	
r_6:
	dw  	0x0000	
r_7:
	dw  	0x0000	

jump_table:
	dw  	loop
	dw  	HLT
	dw  	0x0000
	dw  	0x0000
	dw  	0x0000
	dw  	MOV
	dw  	RDM
	dw  	WRM
	dw  	0x0000
	dw  	0x0000
	dw  	0x0000
	dw  	0x0000
	dw  	RDX
	dw  	WRX
	dw  	PSH
	dw  	POP
	dw  	MUL
	dw  	CMP
	dw  	0x0000
	dw  	TST
	dw  	JMP
	dw  	CAL
	dw  	RET
	dw  	0x0000
	dw  	ADD
	dw  	SUB
	dw  	NOT
	dw  	AND
	dw  	ORR
	dw  	XOR
	dw  	SLL
	dw  	SLR


@macro int_ip 
	R7
@end
@macro int_instr 
	R6
@end
@macro int_op
	R6
@end
@macro int_fl 
	R5
@end
@macro int_lr 
	R4
@end
@macro int_ui 
	R3
@end
@macro int_sp
	SP
@end
@macro int_r0
	R0
@end
@macro int_ccc
	R0
@end
@macro int_r1
	R1
@end
@macro int_imm
	R1
@end
@macro temp
	R2
@end

#due to assembler limitations nested macros do not work
#@macro arithmetic(ins)
#	add 	@int_r0, {registers 2 *}
#	rdm 	@temp, @int_r0
#
#	_ins 	@temp, @int_r1
#
#	wrm 	@temp, @int_r0
#@end
@macro arithmetic(ins)
	#loads R0 with correct value
	add 	R0, {registers 2 *}
	rdm 	R2, R0 

	#performs operations 
	_ins 	R2, R1 

	#stores op
	wrm 	R2, R0 
@end

@macro jmp_if_equal(a, b, dest)
	cmp 	_a, _b
	jmp 	E, _dest
@end

start:
	mov 	@int_ip, {program 1 -}
loop:
	#int_instr = mem[(int_ip + prog) * 2] 
	mov 	@temp, @int_ip
	add 	@temp, {program 2 *}
	rdm 	@int_instr, @temp
	add 	@int_ip, 2

	#int_r0 = (int_instr >> 8) & 0x7
	mov 	@int_r0, @int_instr 
	slr 	@int_r0, 7
	and 	@int_r0, 0x0E

	#int_r1 = int_instr & 0xFF
	mov 	@int_r1, @int_instr 
	and 	@int_r1, 0xFF

	#if 0 == (int_instr & 0xF800) goto format_register
	#else goto format_immiediate
	wrx 	UI, 0xF8
	tst 	@int_instr, 0
	jmp 	Z, format_r

format_i:
	#merge immiediate with upper immiediate
	sll 	@int_ui, 8
	orr 	@int_r1, @int_ui

	slr 	@int_op, 11
	jmp 	execute
format_r:
	slr 	@int_r1, 5
	and 	@int_op, 0x1F
	mov 	@temp, @int_r1


	#int_r1 = reg[(registers + int_r1) * 2]
	add 	@int_r1, registers
	sll 	@int_r1, 1
	rdm 	@int_r1, @int_r1

execute:
	mov 	@temp, @int_ui ;used as storage
	mov 	@int_ui, 0
	#jmp mem[(jump_table + int_op) * 2]
	add 	@int_op, {jump_table 256 %}
	sll 	@int_op, 1
	rdm 	@int_op, @int_op
	jmp 	@int_op

NOP:
	;jmp 	loop
	;handled by JT
HLT:
	#if int_fl & ccc != 0
	#then halt 
	slr 	@int_ccc, 1
	tst 	@int_fl, @int_ccc

	jmp 	Z, loop 
	wrx 	UI, {loop_end 256 /}
	jmp 	    {loop_end 256 %}

MOV:
	#mem[(registers + int_r0) * 2] = int_r1
	add 	@int_r0, {registers 2 *}
	wrm 	@int_r1, @int_r0
	
	jmp 	loop
RDM:
	#int_r1 from now on is address
	#0x7F to incorporate shift
	wrx 	UI,      {program_data 0x7F / }
	add 	@int_r1, {program_data 0xFF % 2 *}

	rdm 	@temp, @int_r1

	add 	@int_r0, {registers 2 *}
	wrm 	@temp, @int_r0

	jmp 	loop
WRM:
	#int_r0 = mem[(registers + int_r0) * 2]
	add 	@int_r0, {registers 2 *}
	rdm 	@int_r0, @int_r0
	
	#int_r1 from now on is address
	#0x7F to incorporate shift
	wrx 	UI,      {program_data 0x7F / }
	add 	@int_r1, {program_data 0xFF % 2 *}

	wrm 	@int_r0, @int_r1

	jmp 	loop
RDX:
	add 	@int_r0, {registers 2 *}

	@jmp_if_equal(R2, 0, RDX_IP)
	@jmp_if_equal(R2, 1, RDX_SP)
	@jmp_if_equal(R2, 2, RDX_LR)
	@jmp_if_equal(R2, 4, RDX_UI)
	@jmp_if_equal(R2, 5, RDX_FL)
	@jmp_if_equal(R2, 7, RDX_CF)

	jmp 	loop
RDX_IP:
	#mem[(registers + int_r0) * 2] = int_ip
	slr 	@int_ip, 1
	wrm 	@int_ip, @int_r0
	sll 	@int_ip, 1
	jmp 	loop
RDX_SP:
	#mem[(registers + int_r0) * 2] = int_sp
	rdx 	@temp, SP
	wrm 	@temp, @int_r0
	jmp 	loop
RDX_LR:
	#mem[(registers + int_r0) * 2] = int_lr
	slr 	@int_lr, 1
	wrm 	@int_lr, @int_r0
	sll 	@int_lr, 1
	jmp 	loop
RDX_UI:
	#mem[(registers + int_r0) * 2] = int_ui
	wrm 	@temp, @int_r0
	jmp 	loop
RDX_FL:
	#mem[(registers + int_r0) * 2] = int_fl
	wrm 	@int_fl, @int_r0
	jmp 	loop
RDX_CF:
	mov 	@temp, 0x1
	wrm 	@temp, @int_r0
	jmp 	loop

WRX:
	@jmp_if_equal(R0, 0, WRX_IP)
	@jmp_if_equal(R0, 1, WRX_SP)
	@jmp_if_equal(R0, 2, WRX_LR)
	@jmp_if_equal(R0, 4, WRX_UI)
	@jmp_if_equal(R0, 5, WRX_FL)

	jmp 	loop
WRX_IP:
	mov 	@int_ip, @int_r1
	sll 	@int_ip, 1
	jmp 	loop
WRX_SP:
	wrx 	SP, @int_r1
	jmp 	loop
WRX_LR:
	mov 	@int_lr, @int_r1
	sll 	@int_lr, 1
	jmp 	loop
WRX_UI:
	mov 	@int_ui, @int_r1
	jmp 	loop
WRX_FL:
	mov 	@int_fl, @int_r1
	jmp 	loop

PSH:
	#int_r0 = mem[(registers + int_r0) * 2]
	add 	@int_r0, {registers 2 *}
	rdm 	@int_r0, @int_r0
   
	psh 	@int_r0

	jmp 	loop
POP:
	pop 	@temp

	#mem[(registers + int_r0) * 2] = temp
	add 	@int_r0, {registers 2 *}
	wrm 	@temp, @int_r0

	jmp 	loop
MUL:
	@arithmetic(mul)
	rdx 	@int_fl, FL
	jmp 	loop
CMP:
	#int_r0 = mem[(registers + int_r0) * 2]
	add 	@int_r0, {registers 2 *}
	rdm 	@int_r0, @int_r0
	
	#int_fl = flags(int_r0 - int_r1)
	cmp 	@int_r0, @int_r1
	rdx 	@int_fl, FL

	jmp 	loop

TST:
	#int_r0 = mem[(registers + int_r0) * 2]
	add 	@int_r0, {registers 2 *}
	rdm 	@int_r0, @int_r0
	
	#int_fl = flags(int_r0 - int_r1)
	tst 	@int_r0, @int_r1
	rdx 	@int_fl, FL

	jmp 	loop

JMP:
	#if int_fl & ccc != 0
	#then int_ip = int_r1
	slr 	@int_ccc, 1
	tst 	@int_fl, @int_ccc

	jmp 	Z, loop 
	mov 	@int_ip, @int_r1
	sll 	@int_ip, 1
	jmp 	loop

CAL:
	#if int_fl & ccc != 0
	#then int_ip = int_r1
	#     int_lr = int_ip
	slr 	@int_ccc, 1
	tst 	@int_fl, @int_ccc

	jmp 	Z, loop 
	mov 	@int_lr, @int_ip
	mov 	@int_ip, @int_r1
	sll 	@int_ip, 1
	jmp 	loop

RET:
	#if int_fl & ccc != 0
	#then int_ip = int_lr
	slr 	@int_ccc, 1
	tst 	@int_fl, @int_ccc

	jmp 	Z, loop 
	mov 	@int_ip, @int_lr
	jmp 	loop

ADD:
	@arithmetic(add)
	rdx 	@int_fl, FL
	jmp 	loop
SUB:
	@arithmetic(sub)
	rdx 	@int_fl, FL
	jmp 	loop
NOT:
	@arithmetic(not)
	rdx 	@int_fl, FL
	jmp 	loop
AND:
	@arithmetic(and)
	rdx 	@int_fl, FL
	jmp 	loop
ORR:
	@arithmetic(orr)
	rdx 	@int_fl, FL
	jmp 	loop
XOR:
	@arithmetic(xor)
	rdx 	@int_fl, FL
	jmp 	loop
SLL:
	@arithmetic(sll)
	jmp 	loop
SLR:
	@arithmetic(slr)
	jmp 	loop

loop_end:
;	wrx 	UI, {r_0 2 * 256 /}
	rdm 	R0, {r_0 2 * 256 %}
;	wrx 	UI, {r_1 2 * 256 /}
	rdm 	R1, {r_1 2 * 256 %}
;	wrx 	UI, {r_2 2 * 256 /}
	rdm 	R2, {r_2 2 * 256 %}
;	wrx 	UI, {r_3 2 * 256 /}
	rdm 	R3, {r_3 2 * 256 %}
;	wrx 	UI, {r_4 2 * 256 /}
	rdm 	R4, {r_4 2 * 256 %}
;	wrx 	UI, {r_5 2 * 256 /}
	rdm 	R5, {r_5 2 * 256 %}
;	wrx 	UI, {r_6 2 * 256 /}
	rdm 	R6, {r_6 2 * 256 %}
;	wrx 	UI, {r_7 2 * 256 /}
	rdm 	R7, {r_7 2 * 256 %}


	hlt

#added as offset to all RDM and WRM to NOT destroy code of the program itself
program_data:
	nop

