; EXTERNAL DEPENDENCIES
INCLUDE		Irvine32.inc
INCLUDELIB	Irvine32.lib

; EXECUTION MODE PARAMETERS
.386
.model flat, stdcall
.stack 4096

; PROTOTYPES
ExitProcess PROTO, dwExitCode:DWORD

ENDLINE							EQU		0Dh, 0Ah, 0	; I am NOT typing allat
NEWLINE							EQU		0Dh, 0Ah

; DATA SEGMENT
.data
introText			BYTE		'=====================', NEWLINE, '= SIMPLE CALCULATOR =', NEWLINE, '=====================', NEWLINE, ENDLINE
op1					BYTE		'Please enter your first operand: ', 0
op2					BYTE		'Please enter your second operand: ', 0
choiceText			BYTE		'Enter your choice:', NEWLINE, '1.) Addition', NEWLINE, '2.) Subtraction', NEWLINE, '3.) Multiplication', NEWLINE, ': ', 0
youChose			BYTE		'You chose', 0
addMsg				BYTE		'addition', ENDLINE
subMsg				BYTE		'subtraction', ENDLINE
mulMsg				BYTE		'multiplication', ENDLINE

topCalc				BYTE		' ,-----------------, ', ENDLINE
					BYTE		'|  _______________  |', ENDLINE
					BYTE		'| /               \ |', ENDLINE
					BYTE		'| \_______________/ |', ENDLINE
					BYTE		'|                   |', ENDLINE
					BYTE		'||[ + ] [ - ] [ * ]||', ENDLINE
					BYTE		'||[ 1 ] [ 2 ] [ 3 ]||', ENDLINE
					BYTE		'||[ 4 ] [ 5 ] [ 6 ]||', ENDLINE
					BYTE		'||[ 7 ] [ 8 ] [ 9 ]||', ENDLINE
					BYTE		'||[ C ] [ 0 ] [ E ]||', ENDLINE
					BYTE		'|                   |', ENDLINE
					BYTE		'| | S.E.T.H. INC. | |', ENDLINE
					BYTE		"'-------------------'", ENDLINE

calcStr				BYTE		'               ', 0	; the string displayed in the calculator (15 characters);
cursorX				BYTE		0
errorText			BYTE		'ERROR          ', 0

sampleNum			BYTE		'10501'

flags				BYTE		0
FLAG_NUM_NEGATIVE	EQU			0

operation			BYTE		0
operator1			DWORD		0
operator2			DWORD		0
numCharsWritten		BYTE		0

sizeOfCalcLine		EQU			24						; the length of one line of the calculator ASCII art (21 for the visible text, 3 for the ENDLINE) ;
numberCalcRows		EQU			13						; how many portions (lines) the calculator consists of ;
calcDrawX			EQU			3						; the x-coord where to display calcStr on the screen ;
calcDrawY			EQU			2						; the y-coord where to display calcStr on the screen ;

OPERATION_ADD		EQU			1
OPERATION_SUB		EQU			2
OPERATION_MUL		EQU			3



; ******************** MAIN PROCEDURE ******************** ;
.code
main PROC
	; DRAW THE CALCULATOR TO SCREEN ;
	mov edx, OFFSET topCalc
	mov ecx, numberCalcRows
	calcDraw:
		call WriteString
		add edx, sizeOfCalcLine
	loop calcDraw

	call errorCalc

	call clearCalcOutput

	mov ebx, OFFSET sampleNum
	call strToInt

	call WriteDec

	jmp quit
	; start up main loop ;
	
		
		;call ReadKey
		

	;jmp main_loop

	quit:
	mov dl, 0		; return cursor to original position (so exit message doesn't break calcuator appearance)							'
	mov dh, 14
	call Gotoxy
	INVOKE ExitProcess, 0
main ENDP

; ******************** START PROCEDURE DEFINITIONS ******************** ;

;************************************************************
; Takes in a 6-digit decimal string (or 5-digit if the number contained does not start with a negative symbol), and converts it to a signed DWORD.
;************************************************************
;				( PARAMS )
;	EBX: string
;	ECX: number of characters in string
;************************************************************
;				( RETURNS )
;	EAX: signed number
strToInt PROC 
	push ecx
	push edx

	mov eax, 0

	mov dl, [ebx]	; check if the first character of the string is a minus sign. If so, set FLAG_NUM_NEGATIVE in flags to true, and increment ebx by one to ignore the minus sign.
	cmp dl, '-'	
	jne parse_loop	; if the first symbol is NOT a minus sign, do not do any of the above and just start parsing.

	negative:
	add ebx, 1		; shift string away from negative sign if the number is negative.
	mov dl, [flags]
	bts edx, 0		; bts only accepts 16+ bit registers fsr
	mov [flags], dl	; set flag at bit zero to true to indicate a negative number (at the end of the function, negate number)

	;************************************************************
	; BEGIN PARSING NUMBER
	parse_loop:
		mov cl, BYTE PTR [ebx]		; load next char of ebx into cl
		call IsClDigit				; Check if the character contained in cl is a digit (0-9). Sets ZF if it is.
		jnz stop_parsing			; if the character is not a digit, stop parsing.

		; MULTIPLY TOTAL BY 10
		push edx
		push ecx

			; MULTIPLY TOTAL BY 10
			mov ecx, 10
			mov eax, edx				; load current total into eax (for multiplication)
			mul ecx						; multiply eax by 10

			; EDIT STACK-SAVED EDX (SO TOTAL GOES THROUGH POPPING AND PUSHING)
			mov [esp + 8], eax			; ESP points to next available byte, and ecx was pushed before edx, meaning we have to go up 8 bytes

		; return values to registers
		pop ecx
		pop edx

		; add new digit onto total
		sub cl, '0'					; convert character in cl to a decimal number
		add edx, cl					; add that decimal number to total
	jmp parse_loop

	stop_parsing:
	movzx eax, BYTE PTR [flags]	; check if FLAG_NUM_NEGATIVE is true. If it is, negate result number.
	btr eax						; sets CF to true if the bit was true, and resets the read bit
	mov [flags], al				; update flags variable in-memory
	jnc after					; if FLAG_NUM_NEGATIVE was false, skip negating the number.
	neg edx						; else, negate total.

	after:
	mov eax, edx				; load total into eax (return register)

	pop edx
	pop ecx
	ret

strToInt ENDP

refreshCalcOutput PROC
	push edx

	mov dl, calcDrawX
	mov dh, calcDrawY
	call Gotoxy

	mov edx, OFFSET calcStr
	call WriteString

	pop edx
	ret
refreshCalcOutput ENDP

errorCalc PROC
	push edx
	push eax

	mov dl, calcDrawX
	mov dh, calcDrawY
	call Gotoxy

	mov edx, OFFSET errorText
	call WriteString

	call ReadChar
	call clearCalcOutput
	pop eax
	pop edx
	ret
errorCalc ENDP

IsClDigit PROC
	push eax

	mov al, cl
	call IsDigit

	pop eax
	ret
IsClDigit ENDP

clearCalcOutput PROC
	push ecx
	push edx

	mov edx, 0
	mov [operation], dl
	mov [operator1], edx
	mov [operator2], edx
	mov numCharsWritten, dl

	mov ecx, 15
	mov dl, ' '
	clrLoop:
		mov [calcStr - 15 + ecx], dl
	loop clrLoop
	call refreshCalcOutput

	pop edx
	pop ecx
	ret
clearCalcOutput	ENDP


;************************************************************
; Takes an ASCII code and performs an action based on what was pressed. If the key isn't recognized, ignore it.								'
;************************************************************
;						( PARAMS )
; AL: ASCII code
;************************************************************
handleUserInput PROC

	; if no number has been input for operator1, don't bother checking operation, just assume that the user pressed a number. Prevents user from saying NULL + 10.			'	
	mov ah, numCharsWritten
	test ah, ah
	jz check_numbers

	;************************************************************
	check_add:			; check if the key pressed was +. If it is, we need to check if another operator has already been pressed. If so, ERROR.
	cmp al, '+'
	jne check_sub		; if the key pressed was not +, check minus next.

	mov ah, operation	; check that there is no current operator pressed. If there is, ERROR
	test ah, ah
	jz plus_pressed		; if there was no operator already pressed, then activate code for plus being pressed.
	call errorCalc		; if there was an operator already pressed, ERROR
	ret

	;************************************************************
	check_sub:			; check if the key pressed was -. If it was, check if another operator has already been pressed. If another has already been pressed, ERROR.
	cmp al, '-'
	jne check_mul

	mov ah, operation
	test ah, ah
	jz minus_pressed
	call errorCalc
	ret

	;************************************************************
	check_mul:			; check if the key pressed was *. If it was, check if another operator has already been pressed. If another has already been pressed, ERROR.
	cmp al, '*'
	jne check_clear

	mov ah, operation
	test ah, ah
	jz asterisk_pressed
	call errorCalc
	ret

	;************************************************************
	check_clear:		; check if the key pressed was 'C'. If it was, clear the calculator output.
	cmp al, 'C'
	jne check_enter
	call clearCalcOutput
	ret

	;************************************************************
	cmp al, 'E'		; check if the key pressed was 'E'. If it was, perform the operation and display the result.
	jne check_numbers
	call solveInput
	ret

	;************************************************************
	check_numbers:	; check if the key pressed was a digit. If it was, add that digit to the string.
	call IsDigit
	jz number_pressed

	ret
handleUserInput ENDP

plus_pressed:
	;mov 

	mov al, OPERATION_ADD
	mov operation, al
	
	mov al, 0
	mov numCharsWritten, al

	ret

minus_pressed:
asterisk_pressed:
check_enter:
solveInput:
number_pressed:

END main