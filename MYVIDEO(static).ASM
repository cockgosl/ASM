.model tiny
.code
org 100h
VIDEO_SEG equ 0b800h
LEFT_TOP equ 1340
NEXT_LINE equ 160
WIDTH_FRAME equ 38
LEFT_BOTTOM equ 960
MIDDLE_OF_FRAME equ 1822





start:
	 
		call setup_video
		call draw_frame
		
		mov al, ds:[82h]	;the first element of line is read
		cmp al, 31h		;if it's 1 - input from console
		je input_textce

		call input_textk	;if it didn't jump, we do input
					;from keyboard

		input_textce:
		call input_textc
		call programm_exit
		
		setup_video:		
		mov bx, VIDEO_SEG
		mov es, bx
		mov bx, 0
		ret



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
			
		mov cx, 18			;amountt of top lines
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
		add bx, WIDTH_FRAME		; we are on the next wall
		mov byte ptr es: [bx], 0b3h	; vertical line
		mov byte ptr es: [bx+1], 1fh	; white on blue
		add bx, NEXT_LINE
		sub bx, WIDTH_FRAME		; we are on the next line
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

		mov cx, 18			; amount of bottom lines
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


		input_textk:
		push cx
		push bx
		push ax
			
		add bx, MIDDLE_OF_FRAME
		
		not_yet:
		mov ah, 00h 			; we are waiting for the key
		int 16h
	
		cmp al, 0dh			;if 'enter' - done
		je input_done
		
		cmp al, 08h			; if 'backspace' - rewrite
		je back_space

		;cmp al, 0b3h
		;je make_width

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

		;make_width:




		input_done:

		pop ax
		pop bx
		pop cx
		ret
			
		input_textc:
		mov bx, MIDDLE_OF_FRAME		;current pose
		mov al, ds:[80h]		;amount of elements in line
		mov di, 2			;we skip the sign of mode('1 ')
		sub ax, 3			;we don't need to write (' 1 ')
		mov cx, ax			;the counter is set
		text:
		mov al, ds:[82h+di]		;now we read symbols and go further
		mov byte ptr es:[bx], al	;write symbol on the screen
		add di, 1
		add bx, 2
		loop text
		ret 
		
		
	
		programm_exit:
		mov ax, 4c00h
		int 21h
.data 
	;STR_LEN db 0

end	start	