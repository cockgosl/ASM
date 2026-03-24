.model tiny
.code
org 100h



Start:	
		mov ax, 351ch					;now we know the
		int 21h							;address of the old 1ch(TIMER)
		mov OLD_OFFSET1c, bx			
		mov OLD_SEGMENT1c, es
		
		mov ax, 3509h					;now we know the
		int 21h							;address of the old 09h(KEYBOARD)	
		mov OLD_OFFSET, bx				
		mov OLD_SEGMENT, es

		cli

		push 0
		pop es

		push 0
		pop bx
			

			
		mov bx, 1ch * 4
		mov es:[bx], offset NEW_1c		;we put the address of our new function in the table of interrupts handler 
		mov ax, cs
		mov es:[bx+2], ax
		
		mov bx, 09h * 4					;we put the address of our new function
		mov es:[bx], offset NEW_09		;in the table of interrupt handler
		
		mov ax, cs
		mov es:[bx+2], ax

		sti	


		mov ax, 3100h
		mov dx, offset END_OF_PROGRAMM		;we save memory after it
		shr dx, 4							;resident is made
		add dx, 10h			
		int 21h



RIGHT_CORNER equ 138 
regname_arr db 97, 120 , 98, 120, 99, 120, 100, 120, 115, 105, 100, 105, 98, 112, 100, 115, 101, 115, 115, 115		;ASCI codes of ax, bx, cx...
reg_arr dw 10 dup(0)
DRAW_SIGN db 0
DRAW_BLOCK db 0	
COUNTER db 0

;------------------------------------------------------------------;
;New function is made to controll current state of registers. Every;
;18ms we check them and if needed put them in the frame(if shift is;
;pressed). The sign of it is stored in DRAW_SIGN. 		           ;
;------------------------------------------------------------------;


NEW_1c		proc
		
		cmp cs:COUNTER, 18
		je SKIP
		mov cs:COUNTER, 0

		mov cs:[reg_arr+0], ax			;1) safe registers in an array
		mov cs:[reg_arr+2], bx
		mov cs:[reg_arr+4], cx
		mov cs:[reg_arr+6], dx
		mov cs:[reg_arr+8], si
		mov cs:[reg_arr+10], di
		mov cs:[reg_arr+12], bp
		mov cs:[reg_arr+14], ds
		mov cs:[reg_arr+16], es
		mov cs:[reg_arr+18], ss


		cmp cs:DRAW_SIGN, 0				;2) check the condition, if needed - draw
		je standart2
		


		call DRAW

		standart2:

		mov ax, cs:[reg_arr+0]			;3) registers are to be in the start condition
		mov bx, cs:[reg_arr+2]
		mov cx, cs:[reg_arr+4]
		mov dx, cs:[reg_arr+6]
		mov si, cs:[reg_arr+8]
		mov di, cs:[reg_arr+10]
		mov bp, cs:[reg_arr+12]
		mov ds, cs:[reg_arr+14]
		mov es, cs:[reg_arr+16]
		
		db 0eah							;4) give the controll to the standart handler (jmp far)
		OLD_OFFSET1c dw 0
		OLD_SEGMENT1c dw 0

		SKIP:
		add cs:COUNTER, 1
		jmp standart2
NEW_1c endp
;---------------------------------------------------------------------;
;This function works with the array, wich contains registers. It draws;
;in a text mode.					              					  ;
;---------------------------------------------------------------------;

DRAW		proc
		cmp cs:DRAW_BLOCK, 1
		je STOP
		mov cs:DRAW_BLOCK, 1

		push 0b800h								;videosegment
		pop es
		mov bx, RIGHT_CORNER
;---------------------------------------------------------------------;
;we draw blue background in the upper left corner of the screen		  ;
;---------------------------------------------------------------------;
		call BACKGROUND
;---------------------------------------------------------------------;
;this function prints registers with their value on the screen. It 	  ;
;works with 2 arrays: one is with registers value(reg_arr), the other ;
;is with their names(regname_arr(it is made just to write them in a   ;
;loop).		  														  ;
;---------------------------------------------------------------------;
		call PRINTF

		STOP:
		cli
		mov cs:DRAW_BLOCK, 0
		sti
		ret

		

		PRINT:
		mov cx, 4
		mov di, 6

		CONVERT:							
		rol ax, 4	
		mov dl, al
		and dl, 0Fh							;everything but the lowest byte in dl is 0
	
		cmp dl, 9
		jbe DIGIT

		add dl,	'A' - '9' - 1
		
		DIGIT:
		add dl, '0'							
		
		mov byte ptr es:[bx+di], dl
		add di, 2
		loop CONVERT					
			
		add bx, 160							;we go on the next line
		ret									

		PRINTF:

		mov di , 0
		mov cx, 10

		PRINTF_F:
		push cx

		mov al, cs:[regname_arr + di]

		mov byte ptr es:[bx], al
		inc di

		mov al, cs:[regname_arr + di]
		mov byte ptr es:[bx+2], al
		mov byte ptr es:[bx+4], ' '
		dec di

		mov ax, cs:[reg_arr + di]

		push di
		call PRINT

		pop di
		add di, 2
		pop cx
		loop PRINTF_F
		ret

		BACKGROUND:
		push bx
		mov cx, 11
		mov di, 12

		BACK_LOOP:
		mov byte ptr es:[bx+1], 30h
		add bx, 2
		loop BACK_LOOP
		add cx, 11
		add bx, 138
		dec di
		cmp di, 0
		jne BACK_LOOP
		pop bx
		ret
DRAW endp
;---------------------------------------------------------------------;
;The function is made to draw a frame with registers on the screen,   ;
;when user presses the button 'shift'. It works with the keyboard int.;
;It checks, wheter the right button was pressed and ,if so, draws     ; 
;frame								      ;
;---------------------------------------------------------------------;
NEW_09		proc

		mov cs:[reg_arr+0], ax			;1) safe registers in an array
		mov cs:[reg_arr+2], bx
		mov cs:[reg_arr+4], cx
		mov cs:[reg_arr+6], dx
		mov cs:[reg_arr+8], si
		mov cs:[reg_arr+10], di
		mov cs:[reg_arr+12], bp
		mov cs:[reg_arr+14], ds
		mov cs:[reg_arr+16], es
		mov cs:[reg_arr+18], ss
 		
		in al, 60h						;it works with the keyboard port
		cmp al, 2ah						;if the pressed button is 'shift' - draw	
		je DRAW_F

		jmp STANDART1
		
		DRAW_F:
		cmp cs:DRAW_SIGN, 1
		je	DONE
		mov cs:DRAW_SIGN, 1 	

		STANDART1:
		
		mov ax, cs:[reg_arr+0]			;3) registers are to be in the start condition
		mov bx, cs:[reg_arr+2]
		mov cx, cs:[reg_arr+4]
		mov dx, cs:[reg_arr+6]
		mov si, cs:[reg_arr+8]
		mov di, cs:[reg_arr+10]
		mov bp, cs:[reg_arr+12]
		mov ds, cs:[reg_arr+14]
		mov es, cs:[reg_arr+16]
		
		db 0eah
		OLD_OFFSET dw 0
		OLD_SEGMENT dw 0

		dd 90909090h
		

		DONE:
		mov cs:DRAW_SIGN, 0
		jmp STANDART1
NEW_09 endp
;-----------------------------------------------------------------------------------------------------------



END_OF_PROGRAMM:

	end Start
