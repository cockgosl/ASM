.model tiny
.code
org 100h

Start:
		mov ax, 3509h					; we want to find the adres of the interrupt handler (09h exactly)
		int 21h							; the information is put in es, and bx
		mov Old9ofs, bx					; we just safe the address
		mov Old9seg, es 

		push 0
		pop es

		cli
		mov bx, 09h * 4
		mov es:[bx], offset New09		; the table of vectors is on 0000:0000, we are rewriting address, that is responsible fo 09h

		mov ax, cs
		mov es:[bx+2], ax
		sti								; cli - sti are necessary for correct writing (interupts shouldn't be done during rewriting)

		mov ax, 3100h

		mov dx, offset EndOfProgram		; we need some memory for our resident	
		shr dx, 4
		add bx, 16

		int 21h

New09	        proc
		push ax bx es
		push 0b800h
		pop es
		
		mov bx, (5 * 80d + 40d) * 2
		mov ah, 1eh

		in al, 60h
		mov es:[bx], ax
		
		or al, 80h
		out 61h, al

		mov al, 20h
		out 20h, al

		pop es bx ax

		db 0eah
		Old9ofs dw 0
		Old9seg dw 0
		
		dd 90909090h

endp 

EndOfProgram:

end Start		