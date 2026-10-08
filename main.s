;-----------------------------------------------------------------
; I5.12-ESE-Lab02-PTR
; Student code
;-----------------------------------------------------------------

	AREA |.text|, CODE, READONLY

		EXPORT	asm_main
		EXPORT	Answer
		EXPORT	Header
		EXPORT	Heap

		IMPORT	strOut
		IMPORT	strIn
		IMPORT	decIn
		IMPORT	decOut

next	EQU	0
name	EQU	4
age		EQU	12
	
dataSize EQU 4+8+4
	
ptrReg	RN 8				; name for register alias
ptrReg2 RN 9
ptrReg3 RN 10
swapCount RN 11
	


asm_main PROC
	push	{lr}		; save return address
;------------------------ FIRST HEAP INIT ------------------------
	ldr	r0,=Heap		; get start of heap
	add	r1,r0,#4		; add 4 for next free block
	str	r1,[r0]			; store in start of heap
	
;------------------------ ASK CHOICE -----------------------------
loop
	ldr	r0,=MsgAsk
	bl	strOut			; display message
	ldr r0,=Answer
	mov	r1,#1
	bl	strIn			; read answer
	ldr	r0,=Answer
	ldrb	r0,[r0]		; get first char
;------------------------ CHECK CHOICE ---------------------------
	cmp	r0,#'N'
	beq	NewEntry		; new entry
	cmp	r0,#'n'
	beq	NewEntry		; new entry
	cmp	r0,#'V'
	beq	ViewDatabase	; view database
	cmp	r0,#'v'
	beq	ViewDatabase	; view database
	cmp	r0,#'D'
	beq	DeleteEntry		; delete an entry
	cmp	r0,#'d'
	beq	DeleteEntry		; delete an entry
	cmp	r0,#'S'
	beq	SortDatabase	; sort database
	cmp	r0,#'s'
	beq	SortDatabase	; sort database
	cmp	r0,#'Q'
	ldreq pc,=Quit
	;beq	Quit			; quit
	cmp	r0,#'q'
	ldreq pc,=Quit
	;beq	Quit			; quit
	b	loop
;=================================================================
;------------------------ NEW ENTRY ------------------------------
;=================================================================
NewEntry
	mov r0, #dataSize	; Set parameter
	bl New				; Do new funct
	mov ptrReg,r0		; Register the position
	
	; Ask Name
	ldr	r0,=MsgName
	bl	strOut			; display message	
	mov r0,ptrReg
	add r0,r0, #4 		; Offset of the name	
	mov	r1,#8-1
	bl	strIn			; read answer, register in name
	
	; Ask Age
	ldr	r0,=MsgAge
	bl	strOut			; display message
	bl	decIn			; read answer, in R0
	str r0,[ptrReg, #12]		; Register value

	; Find last in list 
	ldr ptrReg2,=Header 	; Get Header adress
	
CheckNullPtrNE
	ldr r0, [ptrReg2]		; Read Content r0 = *ptrReg2
	cmp r0, #0 				; Check Header is set / r0 == 0 ?
	streq ptrReg,[ptrReg2]	; if = 0 : *ptr2 = ptrReg
	mov ptrReg2,r0			; ptr2 = r0
	bne CheckNullPtrNE
		
	b	loop


;=================================================================
;------------------------ VIEW DATABASE --------------------------
;=================================================================
ViewDatabase
; Go to first entry
	ldr ptrReg,=Header 	; Get Header adress 
	ldr ptrReg,[ptrReg] 
	
; Check if the list is empty
	cmp ptrReg, #0 			; Check Header is set r0 == 0 ?.
	beq ListEmpty
		
CheckNullPtrVD
	; Print name in the value
	mov	r0, ptrReg		; Set first parameter
	add r0, r0, #4		; add offset
	bl	strOut			; display message
	ldr	r0,=Msgdotdot	; " : "
	bl	strOut			; display message	
	
	
	; Print Age
	ldr	r0, [ptrReg, #12]	; Get the value with offset
	bl	decOut				; display Age
	ldr	r0,=MsgSpace	; " "
	bl	strOut			; display message	
	
	ldr r0, [ptrReg]		; Read Content r0 = *ptrReg2
	cmp r0, #0 				; Check Header is set r0 == 0 ?
	mov ptrReg,r0			; ptr2 = r0
	bne CheckNullPtrVD

	B	loop			; yes -> return


;=================================================================
;------------------------ DELETE ENTRY ---------------------------
;=================================================================

DeleteEntry
	; Ask Name to Delete
	ldr	r0,=MsgToDelete ; Load the adress of MsgToDelete
	bl	strOut			; display message	
	ldr r0,=NameToDel	; Register the afress of the name to delete
	mov	r1,#8-1			; Max Lenght of name
	bl	strIn			; read answer, register in NameToDel

	;Load name in r4 and r5
	ldr r4,[r0],#4		; Load first 4 caracters of the name in R8, and post index
	ldr r5,[r0]			; Load last 4 caracters

; Go to first entry
	ldr ptrReg2,=Header 	; Get Header adress (First list adress)
	ldr ptrReg,[ptrReg2] 
	
; Check if the list is empty
	cmp ptrReg, #0 			; Check Header is set r0 == 0 ?.
	beq ListEmpty
		
		
CheckNullPtrDE
	; Print name in the value
	mov	r0, ptrReg		; Set first parameter
	add r0, r0, #4		; add offset
	
	;Load name in r2 and r3
	ldr r2,[r0],#4		; Load first 4 caracters of the name in R8, and post index
	ldr r3,[r0]			; Load last 4 caracters
	
	ldr r0, [ptrReg]	; Read Content r0 = *ptrReg
	
	cmp r2,r4			; Compare if R2 and R4 are identicals
	cmpeq r3,r5			; Then compare if R3 == R5
	streq r0,[ptrReg2] 	; Save the value of the next data in the last data
	
	ldreq r0, =MsgNamDel
	bleq  strOut			; display message
	
	cmp r0, #0 			; Check Header is set r0 == 0 ?

	mov ptrReg2, ptrReg ; Save last value of ptrReg
	mov ptrReg,r0		; ptr = r0
	bne CheckNullPtrDE
	
	; Reset answer 
	mov r1, #0
	ldr	r0,=NameToDel ; Load the adress of MsgToDelete
	str r1,[r0],#4		; Store 0 to reset answer
	str r1,[r0]			

	B	loop

;=================================================================
;------------------------ SORT DATABASE --------------------------
;=================================================================
SortDatabase
	mov swapCount,#0	;Reset Swap Count

; Go to first entry
	ldr ptrReg2,=Header 	; Get Header adress (First list adress)
	ldr ptrReg,[ptrReg2] 
	
; Check if the list is empty
	cmp ptrReg, #0 			; Check Header is set r0 == 0 ?.
	beq ListEmpty
		
CheckNullPtrSD
	; Print name in the value
	mov	r0, ptrReg		; Set first parameter
	
	;Load age 1 in r2
	add r0, r0, #age	; add offset
	ldr r2, [r0]
	
	;Load age 2 in r3
	ldr r0, [ptrReg]
	add r0, r0, #age	; add offset
	ldr r3, [r0]
	
	cmp r2,r3
	addhi swapCount,swapCount,#1 ; Increment nbr of swap
	
	ldr r0, [ptrReg]	; r0 = *ptrReg
	ldrhi ptrReg3, [ptrReg]	; ptrReg3 = ptrReg1*
	ldrhi r1, [ptrReg3]	; r1 = *ptrReg3
	strhi r1, [ptrReg]	; *ptrReg1 = *ptrReg3
	strhi ptrReg, [ptrReg3]	; *ptrReg3 = ptrReg1
	strhi ptrReg3,[ptrReg2] ; *ptrReg2 = ptrReg3
	
	cmp r0, #0 			; Check if last element ?
	mov ptrReg2, ptrReg ; Save last value of ptrReg
	mov ptrReg,r0		; ptr = r0
	bne CheckNullPtrSD
	
	; Control if last swap
	cmp swapCount, #0 ; If there was no swaps this time, return
	bne	SortDatabase
	
	B loop
	

;=================================================================
;------------------------ QUIT -----------------------------------
;=================================================================
Quit
	pop	{pc}			; restore return address

	ENDP
;=================================================================
; Function  : New
; Goal      : Allocate memory from Heap
; Input     : r0 - size in bytes to allocate
; Output    : r0 - Address of reserved zone
;=================================================================
New
	push  {r1-r2,lr}	  ; save registers
	ldr	  r1,=Heap		  ; get heap address
	ldr	  r2,[r1]		  ; get free address
	add	  r0,r0,r2		  ; add offset to free address
	str	  r0,[r1]	  	  ; store it in heap address
	mov	  r0,r2			  ; return free address
	pop	  {r1-r2,pc}	  ; restore registers and return

;=================================================================

;=================================================================
; Function  : ListEmpty
; Goal      : Indicate to user that the list is empty
;=================================================================
ListEmpty
	; print Name
	ldr	r0, =MsgMtList
	bl	strOut			; display message
	
	B	loop
;=================================================================


MsgAsk		DCB	"\nMake your choice (N,V,D,S,Q) :",0
MsgName		DCB	"\nEnter the name : ",0
MsgAge		DCB	"\nEnter the age : ",0
MsgDspName	DCB	"\nName : ",0
MsgDspAge	DCB	" Age : ",0
MsgToDelete	DCB	"\nName to delete : ",0
MsgSpace	DCB "    ", 0
Msgdotdot	DCB " : ", 0
MsgMtList	DCB "\nList is empty",0
MsgNamDel	DCB "\nDeleted",0

GetChar		DCB	"%c",0

;-----------------------------------------------------------------
; Data section
;-----------------------------------------------------------------
	AREA  |.data|, DATA, READWRITE, ALIGN=8
Header		DCD 	0
Heap		SPACE	4096


	ALIGN 8
		
NameToDel	SPACE	8
Answer		SPACE	8

	END