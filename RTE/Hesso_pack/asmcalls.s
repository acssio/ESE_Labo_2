;/******************************************************************************
; * file:	 	for_asm_calls.S
; * function:	save and restore scratch registers
; * ----------------------------------------------------------------------------
; * comments:	These calls are used in the first assembler laboratories
; * 				to hide the scratch register usage
; *****************************************************************************/
	EXPORT decOut
	EXPORT strOut
	EXPORT decIn
	EXPORT strIn
	IMPORT printf
	IMPORT scanf
	IMPORT getchar

	AREA    |.text|, CODE, READONLY


;/******************************************************************************
; * name:	 	decOut
; * function:	display a decimal value on the debug terminal
; * ----------------------------------------------------------------------------
; * parameters:	r0 - the value to display
; *
; * comments:	use USE_STDIO_NOBUF 1 in config.h to print direclty the value
; * 				on the serial port
; *****************************************************************************/
decOut
	push	{r0-r3,ip,lr}
	mov		r1,r0
	ldr		r0,=strDecOut
	bl		printf
	pop		{r0-r3,ip,pc}


;/******************************************************************************
; * name:	 	strOut
; * function:	display a string on the debug terminal
; * 				The string has to finish with a NULL character
; * ----------------------------------------------------------------------------
; * parameters:	r0 - the string pointer
; *
; * comments:	use USE_STDIO_NOBUF 1 in config.h to print direclty the value
; * 				on the serial port
; *****************************************************************************/
strOut
	push	{r0-r3,ip,lr}
	mov		r1,r0
	ldr		r0,=strStrOut
	bl		printf
	pop		{r0-r3,ip,pc}

;/******************************************************************************
; * name:	 	decIn
; * function:	read a decimal value on the debug terminal
; * 				The value ends with a CR (as standard scanf)
; * ----------------------------------------------------------------------------
; * parameters:	-
; *
; * return:		r0 - the readed value
; *
; * comments:	use USE_STDIO_ECHO 1 in config.h to have an echo
; * 				on the serial port when typing
; *****************************************************************************/
decIn
	push	{r1-r4,ip,lr}
	ldr		r0,=strDecIn
	ldr		r1,=readVal
	bl		scanf
	bl      getchar			; flush CR
	ldr		r1,=readVal
	ldr		r0,[r1]
	pop		{r1-r4,ip,pc}


;/******************************************************************************
; * name:	 	strIn
; * function:	reads a string on the debug terminal
; * 				The string ends with a CR
; * ----------------------------------------------------------------------------
; * parameters:	r0 - the string pointer
; *				r1 - length max
; *
; * comments:	use USE_STDIO_ECHO 1 in config.h to have an echo
; * 				on the serial port when typing
; *****************************************************************************/
strIn
	push	{r0-r5,ip,lr}
	mov		r4,r1
	mov		r5,r0
loopStrIn
	mov		r1,r5
	bl		getchar
	cmp		r0,#0x0D
	beq		replaceCrStrIn
	strb    r0,[r5]
	sub		r4,r4,#1
	cmp		r4,#0
	beq		endNull
	add		r5,r5,#1
	b		loopStrIn
replaceCrStrIn
	mov		r0,#0
	strb	r0,[r5]
	pop		{r0-r5,ip,pc}
endNull
	mov		r1,#0
	strb	r1,[r5,#1]
	pop		{r0-r5,ip,pc}

;/* strings for printf and scanf usage		*/
strDecOut		DCB	"%ld",0
strDecIn		DCB	"%ld",0
strStrOut		DCB	"%s",0,0

	AREA  |.data|, DATA, READWRITE, ALIGN=4
readVal		DCD	0		;/* one word byte for read	*/

	END
		