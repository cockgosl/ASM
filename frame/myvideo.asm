.model tiny
.code
org 100h
VIDEO_SEG equ 0b800h
TOP_MIDDLE equ 1340
NEXT_LINE equ 160
FRAME_WIDTH equ 38
LEFT_BOTTOM equ 960
MIDDLE_OF_SCREEN equ 1822





start:
	 
		call setup_video
		call find_len
		call choose_mode

;-------------------------------------------------------------------------
;we want to work with videosegment, so 	segment is to be in 'es', offset 
;is to be in 'bx'. So the function destroys changes 'es', 'bx'
;-------------------------------------------------------------------------

		setup_video:						; we are on the video_seg now	
			
		mov bx, VIDEO_SEG
		mov es, bx
		mov bx, 0
		ret

;-------------------------------------------------------------------------
;to correctly draw the frame(in the first mode), we are to know the len
;the result: len of the string is in LEN, 'bx' = 0
;-------------------------------------------------------------------------

		find_len:							; put len of the line in LEN(80h - is the address)

		mov bl, ds:[80h]
		mov LEN, bx
		xor bx, bx
		ret

;-------------------------------------------------------------------------
;if we put : "myvideo.com 1 'string'", then 'string' will be written in the 
;frame. If we put : "myvideo.com 2(or any number)", we will be given op -
;portunity to put 13 symbols in the given frame.
;Function works with : ax, bx, cx, di, es. Their values are lost
;-------------------------------------------------------------------------

		choose_mode:

		cmp LEN, 2
		jb input_done_p					
		mov al, ds:[82h]					
		cmp al, 31h							;if it's '1' - static
		je input_textc						
		cmp al, 32h							;if it's '2' - dynamic
		je input_textk 	
		jmp input_done				

	input_textc:
		call draw_frame
		mov bx, MIDDLE_OF_SCREEN			;we are writing in the middle

		mov di, 2			
		sub LEN, 3							;we dont need ' 1 ', counter starts immidietly after .com
		mov cx, LEN
		text:
		mov al, ds:[82h+di]					;read symbol in the line, go next
		mov byte ptr es:[bx], al
		add di, 1
		add bx, 2
		loop text
		input_done_p:						;jmp can't reach input_done, it helps
		jmp input_done						;just terminates the programm


	input_textk:
		mov LEN, 15
		call draw_frame		
		xor ax, ax
		xor bx, bx
		xor cx, cx
		mov cx, 13d									; how many symbols can be read			
			
		add bx, MIDDLE_OF_SCREEN
			
		textk:
		mov dx, es:[bx]
		cmp dx, 0b3h
		je input_done
		mov ah, 00h 								; we are waiting for the key
		int 16h
	
		cmp al, 0dh									;if 'enter' - done
		je input_done
		
		cmp al, 08h									; if 'backspace' - rewrite
		je back_space


		mov byte ptr es: [bx], al					; key is in al
		mov byte ptr es: [bx+1], 0ch				; red on black
		add bx, 2

		jmp not_yet

	back_space:
		cmp bx, MIDDLE_OF_SCREEN					;if we can't errase symbols - skip
		je skip
		sub bx, 2									; set bx on the current pose
		mov byte ptr es: [bx], ' '					; we just errase symbol
		mov byte ptr es: [bx+1], 00h				
		add cx, 1
		skip:		
		add cx, 1
		jmp not_yet


	not_yet:									;we are not done, until 'enter' or 13 symbols
		loop textk
		
	input_done:									;we just terminate programm
		jmp programm_exit		
;-------------------------------------------------------------------------
;Line after line we are drawing frame and then putting symbols into it
;function works with bx, cx, bur they are being saved in stack every time
;so nothing is destroyed.
;-------------------------------------------------------------------------
		
		draw_frame:

		push bx
		
		add bx, TOP_MIDDLE

		call top_line
		call middle_part
		call bottom_line
		
		pop bx
		ret
		
	top_line:
		push cx
		push bx

		mov byte ptr es: [bx], 0c9h					; left_cornerup
		mov byte ptr es: [bx+1], 29h				; blue on green
		add bx, 2
			
		mov cx, LEN									;amountt of top lines
		sub cx, 2
		mov ah, 1fh							; horizontal line
		mov al, 0c4h									; white on blue
		mov di, bx									

		rep stosw							;great string function

		mov byte ptr es: [di], 0bbh					; right_cornerup
		mov byte ptr es: [di+1], 29h				; blue on green
		
		pop bx
		pop cx
		ret
		
	middle_part:
		push cx
		push bx
		
		add bx, NEXT_LINE							; second line of the frame
	
		mov cx, 6									; amount of middle lines
		sides:
		mov byte ptr es: [bx], 0b3h					; vertical line
		mov byte ptr es: [bx+1], 1fh    			; white on blue
		mov dx, LEN
		dec dx
		shl dx, 1	
		add bx, dx									; we are on the next wall
		mov byte ptr es: [bx], 0b3h					; vertical line
		mov byte ptr es: [bx+1], 1fh				; white on blue
		add bx, NEXT_LINE
		sub bx, dx									; we are on the next line
		loop sides
		
		pop bx
		pop cx
		ret
		
	bottom_line:
		push cx
		push bx
		add bx, LEFT_BOTTOM

		mov byte ptr es: [bx], 	0c8h 				; left_corner down
		mov byte ptr es: [bx+1], 29h				; blue on green
		add bx, 2

		mov cx, LEN									;amountt of top lines
		sub cx, 2
		mov ah, 1fh								; horizontal line
		mov al, 0c4h									; white on blue
		mov di, bx									

		rep stosw
		
		mov byte ptr es: [di], 0bch					; right_cornerdown
		mov byte ptr es: [di+1], 29h				; blue on green
	
		pop bx
		pop cx
		ret



	
	programm_exit:
		mov ax, 4c00h
		int 21h
.data 
	LEN dw FRAME_WIDTH

end	start	
