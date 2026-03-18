.model tiny
.code
org 100h



START:           
        mov dx, offset MEOW
        mov bx ,dx
        mov byte ptr [bx], 150

        mov ah, 0ah 
        int 21h
        
        call COMPARE
        jmp END_OF_PROGRAMM

MEOW:
        db 20 dup(?)

miuw    db 'you god dame right', '$'
Mewq    db 'get out!!', '$'
COUNTER dw 0

        COMPARE:
        mov di, 1
        mov bx, offset MEOW
        xor cx, cx
        mov byte ptr cl, [bx + di]
        cmp cx, 0
        je HELL_NO

        LOOPM:
        xor ax, ax
        mov al, [bx + di + 1]
        add [COUNTER], ax
        add di, 1
        loop LOOPM
        
        cmp word ptr [COUNTER], 30Ch
        je RIGHT 
        jmp HELL_NO
        
        ret

RIGHT:
        mov dx, offset miuw
        mov ah, 09h
        int 21h
        jmp END_OF_PROGRAMM
HELL_NO:
        mov dx, offset Mewq
        mov ah, 09h
        int 21h
        jmp END_OF_PROGRAMM


END_OF_PROGRAMM:
        mov ax, 4c00h
        int 21h
end START