.MODEL small
.STACK 100h
.DATA 
zinute1 db "Iveskite dvieju baitu skaiciu: $"
endline db 10, 13, "$"
suma dw	0h
.CODE
pradzia:
	mov		ax, @data
	mov		ds, ax

	lea		dx, zinute1
	mov		ah, 9
	int		21h 
	mov		cx, 2
; Ivedimas ir konvertavimas
ivedimas:
	mov		ah, 1
	int		21h
	mov 	ah, 0
	cmp		ax, 0Dh
	je 		pabaiga
	sub		ax, 30h
	mov		bx, suma
	add		ax, bx
	mul		cx
	mov		suma, ax
	mov		ax, 0
	jmp ivedimas
	
pabaiga:
	mov ax, suma
	mov	cx, 2
	div	cx
	push "$$"
	

pabaiga2:
	mov cx, 10
	mov dx, 0

	div cx
	push dx
	cmp ax, 0
	jne pabaiga2
	mov dx, 0
	mov ah, 2

spausdinimas:
	pop dx
	cmp dx, "$$"
	je galas
	add dx, 30h
	int 21h
	jmp spausdinimas

galas:
;baigiame programa su return code 0, o tai reiskia kad vykdymo metu neivyko klaidu
	mov		ax,4C00h
	int		21h

	
END pradzia
