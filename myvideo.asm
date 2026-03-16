.model tiny
.code
org 100h
VIDEO_SEG equ 0b800h
LEFT_TOP equ 1340
NEXT_LINE equ 160
WIDTH_FRAME equ 38
LEFT_BOTTOM equ 960
MIDDLE_OF_SCREEN equ 1840





start:
	 
		call setup_video
		call find_len
		call choose_mode

		
		setup_video:		
		mov bx, VIDEO_SEG
		mov es, bx
		mov bx, 0
		ret

		find_len:
		mov bl, ds:[80h]
		mov LEN, bx
		xor bx, bx
		ret

		choose_mode:
		mov al, ds:[82h]
		cmp al, 31h
		je input_textc
		jmp input_textk

		input_textc:
		call draw_frame
		mov bx, MIDDLE_OF_SCREEN
		mov dx, LEN
		shl dx, 1
		sub bx, dx
						;current pose	
		mov di, 2			;we skip the sign of mode('1 ')
		sub LEN, 3			;we don't need to write (' 1 ')
		mov cx, LEN			;the counter is set
		text:
		mov al, ds:[82h+di]		;now we read symbols and go further
		mov byte ptr es:[bx], al	;write symbol on the screen
		add di, 1
		add bx, 2
		loop text
		jmp programm_exit

		input_textk:
		push cx
		push bx
		push ax
			
		add bx, MIDDLE_OF_SCREEN
		mov ax, LEN
		shr ax, 1
		mov LEN, ax
		sub bx, LEN
			
		
		not_yet:
		mov ah, 00h 			; we are waiting for the key
		int 16h
	
		cmp al, 0dh			;if 'enter' - done
		je input_done
		
		cmp al, 08h			; if 'backspace' - rewrite
		je back_space


		mov byte ptr es: [bx], al	; key is in al
		mov byte ptr es: [bx+1], 0ch	; red on black
		add bx, 2

		jmp not_yet

		back_space:
		sub bx, 2
		mov byte ptr es: [bx], ' '	; we just rewrite symbol and
						; set bx on the current pose
		mov byte ptr es: [bx+1], 00h
		jmp not_yet  	

		draw_frame:
		push bx
		
		add bx, LEFT_TOP
		call top_line
		call middle_part
		call bottom_line
		
		pop bx
		ret
		

		top_line:
		push cx
		push bx

		mov byte ptr es: [bx], 0c9h	; left_cornerup
		mov byte ptr es: [bx+1], 29h	; blue on green
		add bx, 2
			
		mov cx, LEN			;amountt of top lines
		sub cx, 2
		top:
		mov byte ptr es: [bx], 	0C4h	; horizontal line
		mov byte ptr es: [bx+1], 1fh	; white on blue
		add bx, 2	
		loop top

		mov byte ptr es: [bx], 0bbh	; right_cornerup
		mov byte ptr es: [bx+1], 29h	; blue on green
		
		pop bx
		pop cx
		ret
		
		middle_part:
		push cx
		push bx
		
		add bx, NEXT_LINE		; second line of the frame
	
		mov cx, 6			; amount of middle lines
		sides:
		mov byte ptr es: [bx], 0b3h	; vertical line
		mov byte ptr es: [bx+1], 1fh	; white on blue
		add bx, LEN
		add bx, LEN
		sub bx, 2					; we are on the next wall
		mov byte ptr es: [bx], 0b3h	; vertical line
		mov byte ptr es: [bx+1], 1fh	; white on blue
		add bx, NEXT_LINE
		sub bx, LEN
		sub bx, LEN
		add bx, 2			; we are on the next line
		loop sides
		
		pop bx
		pop cx
		ret
		
		bottom_line:
		push cx
		push bx
		add bx, LEFT_BOTTOM

		mov byte ptr es: [bx], 	0c8h 	; left_corner down
		mov byte ptr es: [bx+1], 29h	; blue on green
		add bx, 2

		mov cx, LEN
		sub cx, 2			; amount of bottom lines
		bottom:		
		mov byte ptr es: [bx], 0c4h	; horizontal line
		mov byte ptr es: [bx+1], 1fh	; white on blue
		add bx, 2
		loop bottom
		
		mov byte ptr es: [bx], 0bch	; right_cornerdown
		mov byte ptr es: [bx+1], 29h	; blue on green
	
		pop bx
		pop cx
		ret

		input_done:

		pop ax
		pop bx
		pop cx
		jmp programm_exit
			
	
		programm_exit:
		mov ax, 4c00h
		int 21h
.data 
	LEN dw WIDTH_FRAME

end	start	