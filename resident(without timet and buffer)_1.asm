.model tiny
	.code
org 100h



Start: 		
		mov ax, 3509h				;now we know the
		int 21h					;address of the old 	
		mov OLD_OFFSET, bx			;09h
		mov OLD_SEGMENT, es
		
		push 0
		pop es

		push 0
		pop bx
			
		cli
		mov bx, 09h * 4
		mov es:[bx], offset NEW_09
		
		mov ax, cs
		mov es:[bx+2], ax
		sti	

		mov ax, 3100h
		mov dx, offset END_OF_PROGRAMM		;we save memory after it
		shr dx, 4
		add dx, 10h	

		int 21h

reg_arr dw 14 dup(0)

regname_arr db 97, 120 , 98, 120, 99, 120, 100, 120, 115, 105, 100, 105, 98, 112, 100, 115, 101, 115, 115, 115
    
			 
NEW_09		proc

		mov cs:[reg_arr+0], ax
		mov cs:[reg_arr+2], bx
		mov cs:[reg_arr+4], cx
		mov cs:[reg_arr+6], dx
		mov cs:[reg_arr+8], si
		mov cs:[reg_arr+10], di
		mov cs:[reg_arr+12], bp
		mov cs:[reg_arr+14], ds
		mov cs:[reg_arr+16], es
		mov cs:[reg_arr+18], ss
 		
		push 	0b800h
		pop es
		xor bx, bx
		
		in al, 60h
		cmp al, 2ah
		je DRAW
		cmp al, 1ch
		je DONE

		jmp STANDART
		
		COMBINATION:

		in al, 61h
		or al, 80h			;strange
		out 61h, al
		and al, not 80h
		out 61h, al

		STANDART:
		
		;mov al, 20h			;unnecassary
		;out 20h, al
		
		mov ax, cs:[reg_arr+0]
		mov bx, cs:[reg_arr+2]
		mov cx, cs:[reg_arr+4]
		mov dx, cs:[reg_arr+6]
		mov si, cs:[reg_arr+8]
		mov di, cs:[reg_arr+10]
		mov bp, cs:[reg_arr+12]
		mov ds, cs:[reg_arr+14]
		mov es, cs:[reg_arr+16]
		mov ss, cs:[reg_arr+18]
		
		db 0eah
		OLD_OFFSET dw 0
		OLD_SEGMENT dw 0
																																																																																																												
		dd 90909090h
		

		DONE:
		jmp STANDART

		DRAW:


		mov cx, 11
		mov di, 12

		BACKGROUND:
		mov byte ptr es:[bx+1], 30h
		add bx, 2
		loop BACKGROUND
		add cx, 11
		add bx, 138
		dec di
		cmp di, 0
		jne BACKGROUND
		
		xor bx, bx

		mov di , 0
		
		mov cx, 10

		PRINTF:

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
		add bp, 2
		pop cx
		loop PRINTF

		jmp STANDART
		

		PRINT:
		mov cx, 4
		mov di, 6

		CONVERT:
		rol ax, 4	
		mov dl, al
		and dl, 0Fh	
	
		cmp dl, 9
		jbe DIGIT

		add dl,	'A' - '9' - 1
		
		DIGIT:
		add dl, '0'							;one more array dw 'ax', 'bx'...
		
		mov byte ptr es:[bx+di], dl
		add di, 2
		loop CONVERT						;flags are in stack
			
		add bx, 160									;there are 7 more screens 	
		ret									;к резиденту функцию: перерисовывает табличку 
endp

END_OF_PROGRAMM:

	end Start