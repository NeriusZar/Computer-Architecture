.model small
.stack 100h
.data
	senasIP dw ?
	senasCS dw ?
	
	regAX dw ?
	regBX dw ?
	regCX dw ?
	regDX dw ?
	regSP dw ?
	regBP dw ?
	regSI dw ?
	regDI dw ?
	
	baitas1 db ?
	baitas2 db ?
	baitas3 db ?
	baitas4 db ?
	baitas5 db ?
	baitas6 db ?
	ax_s db "ax$"
	al_s db "al$"
	cx_s db "cx$"
	cl_s db "cl$"
	dx_s db "dx$"
	dl_s db "dl$"
	bx_s db "bx$"
	bl_s db "bl$"
	sp_s db "sp$"
	ah_s db "ah$"
	bp_s db "bp$" 
	ch_s db "ch$"
	si_s db "si$"
	dh_s db "dh$"
	di_s db "di$"
	bh_s db "bh$"
	zingsn_pranesimas db 13, 10, "Zingsninis pertraukimas: $"
	add_string db "ADD $"
	enteris db 13,10,"$"
	rg dw 0
	rga dw 0
	rma dw 0
	rm1 dw 0
	kint dw 123h
.code
	mov ax, @data
	mov ds, ax

	;IŠSAUGOME SENUS PETRAUKIMO CS IR IP
	mov ax, 0
	mov es, ax 
	
	mov ax, es:[4]
	mov bx, es:[6]
	mov senasCS, bx
	mov senasIP, ax
	;PERIMAME PERTRAUKIMA
	mov ax, cs
	mov bx, offset pertraukimas
	
	mov es:[4], bx
	mov es:[6], ax

;=================AKTYVUOJAME ZINGSNINI REZIMA===================
	
	pushf ;PUSH SF
	pop ax
	or ax, 100h ;0000 0001 0000 0000 (TF=1, kiti lieka kokie buvo)
	push ax
	popf  ;POP SF ;>Zingsninis rezimas ijungiamas po sios komandos ivykdymo - ivykdzius kiekviena sekancia komanda ivyks zingsninis pertraukimas

;==================BELEKOKIOS KOMANDOS====================
	int 1h
	mov bx,offset kint
	add [bx], ax
	add al, dl
	inc si
	mov bx, 10h
	mov si, 0
	add ax, [bx+si+4433h]
	add sp, bp
	
;==================ISJUNGIAME ZINGSNINI REZIMA======================
	pushf
	pop  ax
	and  ax, 0FEFFh ;1111 1110 1111 1111 (nuliukas priekyj F, nes skaiciai privalo prasideti skaitmeniu, ne raide) - TF=0, visi kiti liks nepakeisti
	push ax
	popf ;
;===================ATSTATOME PERTRAUKIMO CS, IP===================

	mov ax, senasIP
	mov bx, senasCS
	mov es:[4], ax
	mov es:[6], bx
	
uzdaryti_programa:
	mov ah, 4Ch
	int 21h
	
	
	
	
	
;==================================================================
;Pertraukimo apdorojimo procedura
;==================================================================
pertraukimas:		
	mov regAX, ax				
	mov regBX, bx
	mov regCX, cx
	mov regDX, dx
	mov regSP, sp
	mov regBP, bp
	mov regSI, si
	mov regDI, di
	
		pop si
		pop di 
		push di 
		push si
		
		mov ax, cs:[si]
		mov bx, cs:[si+2]
		mov cx, cs:[si+4]
		
		mov baitas1, al
		mov baitas2, ah
		mov baitas3, bl
		mov baitas4, bh
		mov baitas5, cl
		mov baitas6, ch
		and al, 11111100b
		cmp al, 0
		je toliau
		jmp grizti_is_pertraukimo
		toliau:
		mov ah, 9 
		mov dx, offset zingsn_pranesimas
		int 21h
		mov ax, di ;spausdinam CS
		call printAX
		mov ah, 2
		mov dl, ":"
		int 21h ;spausdinam dvitaski
		
		mov ax, si ;spausdinam IP
		call printAX
	
		call printSpace
		mov ah, baitas1
		mov al, baitas2
		call printAX
		mov al, baitas2
		and al, 11000000b
		cmp al, 040h
		je vienasbaitas
		cmp al, 080h
		je dubaitai
		jmp toliau2
		vienasbaitas:
		mov al, baitas3
		call printAL
		jmp toliau2
		dubaitai:
		mov ah, baitas3
		mov al, baitas4
		call printAX
		toliau2:
		call printSpace
		call printSpace
		
		mov ah, 9
		mov dx, offset add_string  
		int 21h
		mov si, 0
		mov bh, baitas1
		and bh, 00000010b
		cmp bh, 0
		jne reg
		jmp rm
		reg:
		mov bl, baitas1
		and bl, 00000001b
		mov al, baitas2
		and al, 00111000b
		cmp al, 08h
		je cx_
		cmp al, 00h
		je ax_
		cmp al, 18h
		je bx_
		cmp al, 10h
		je dx_1
		cmp al, 28h
		je bp_1
		cmp al, 20h
		je sp_1
		cmp al, 38h
		je di_1
		cmp al, 30h
		je si_1
		dx_1:
		jmp dx_
		bp_1:
		jmp bp_
		sp_1:
		jmp sp_
		cx_:
		mov ah, 9
		cmp bl, 0
		je cl_
		mov dx, offset cx_s
		mov cx, regCX
		mov cx, rg
		mov cx, dx
		int 21h
		jmp toliau3
		cl_:
		mov dx, offset cl_s
		mov cx, regCX
		mov ch, 0
		mov rg, cx
		mov cx, dx
		int  21h
		jmp toliau3
		ax_:
		mov ah, 9
		cmp bl, 0
		je al_
		mov dx, offset ax_s
		mov cx, regAX
		mov rg, cx
		mov cx, dx
		int 21h
		jmp toliau3
		al_:
		mov dx, offset al_s
		mov cx, regAX
		mov ch, 0
		mov rg, cx
		mov cx, dx
		int  21h
		jmp toliau3
		di_1:
		jmp di_
		si_1:
		jmp si_
		bx_:
		mov ah, 9
		cmp bl, 0
		je bl_
		mov dx, offset bx_s
		mov cx, regBX
		mov rg, cx
		mov cx, dx
		int 21h
		jmp toliau3
		bl_:
		mov dx, offset bl_s
		mov cx, regBX
		mov ch, 0
		mov cx, dx
		int  21h
		jmp toliau3
		dx_:
		mov ah, 9
		cmp bl, 0
		je dl_
		mov dx, offset dx_s
		mov cx, regDX
		mov rg, cx
		mov cx, dx
		
		int 21h
		jmp toliau3
		dl_:
		mov dx, offset dl_s
		mov cx, regDX
		mov ch, 0
		mov rg, cx
		mov cx, dx
		int  21h
		jmp toliau3
		bp_:
		mov ah, 9
		cmp bl, 0
		je ch_
		mov dx, offset bp_s
		mov cx, regBP
		mov rg, cx
		mov cx, dx
		int 21h
		jmp toliau3
		ch_:
		mov dx, offset ch_s
		mov cx, regCX
		mov cl, 0
		mov rg, cx
		mov cx, dx
		int  21h
		jmp toliau3
		sp_:
		mov ah, 9
		cmp bl, 0
		je ah_
		mov dx, offset sp_s
		mov cx, regSP
		mov rg, cx
		mov cx, dx
		int 21h
		jmp toliau3
		ah_:
		mov dx, offset ah_s
		mov cx, regAX
		mov cl, 0
		mov rg, cx
		mov cx, dx
		int  21h
		jmp toliau3
		di_:
		mov ah, 9
		cmp bl, 0
		je bh_
		mov dx, offset di_s
		mov cx, regDI
		mov rg, cx
		mov cx, dx
		int 21h
		jmp toliau3
		bh_:
		mov dx, offset bh_s
		mov cx, regBX
		mov cl, 0
		mov rg, cx
		mov cx, dx
		int  21h
		jmp toliau3
		si_:
		mov ah, 9
		cmp bl, 0
		je dh_
		mov dx, offset si_s
		mov cx, regSI
		mov rg, cx
		mov cx, dx
		int 21h
		jmp toliau3
		dh_:
		mov dx, offset dh_s
		mov cx, regDX
		mov cl, 0
		mov rg, cx
		mov cx, dx
		int  21h
		jmp toliau3
		point2:
		jmp toliau5
		toliau3:
		mov rga, cx
		cmp si, 1
		je point2
		mov ah, 2
		mov dl, ","
		int 21h
		inc si
		rm:
		mov bh, baitas1
		and bh, 00000001b
		mov al, baitas2
		and al, 00000111b
		mov ah, baitas2
		and ah, 11000000b
		cmp al, 0h
		je _0
		cmp al, 01h
		je _11
		cmp al, 02h
		je _21
		cmp al, 03h
		je _31
		cmp al, 04h
		je _41
		cmp al, 05h
		je _51
		cmp al, 06h
		je _61
		cmp al, 07h
		je _71
		cmp al, 08h
		je _0
		cmp al, 09h
		je _11
		cmp al, 0Ah
		je _21
		cmp al, 0Bh
		je _31
		cmp al, 0Ch
		je _41
		cmp al, 0Dh
		je _51
		cmp al, 0Eh
		je _61
		cmp al, 0Fh
		je _71
		_11:
		jmp _1
		_21:
		jmp _2
		
		_31:
		jmp _3
		_41:
		jmp _4
		_51:
		jmp _5
		_61:
		jmp _6
		_71:
		jmp _7
		_0:
		cmp ah, 0C0h
		je reg0
		call printbracket1
		cmp ah, 0
		je md0
		mov ah, 9h
		mov dx, offset bx_s
		int 21h
		call printplius
		mov dx, offset si_s
		int 21h
		call printplius
		mov cx, regBX
		mov bx, regSI
		add cx, bx
		cmp ah, 40h
		je vienas
		mov ah, baitas4
		mov al, baitas3
		call printAX
		call printbracket2
		add cx, ax
		mov rm1, cx
		jmp toliau4
		vienas:
		mov al, baitas4
		call printAL
		call printbracket2
		mov ah, 0
		mov cx, ax
		mov rm1, cx
		jmp toliau4
		md0:
		mov ah, 9h
		mov dx, offset bx_s
		int 21h
		mov cx, regBX
		mov bx, regSI
		add cx, bx
		mov rm1, cx
		call printplius
		mov dx, offset si_s
		int 21h
		call printbracket2
		jmp toliau4
		reg0:
		cmp bh, 0
		je al_0
		mov ah, 9h
		mov dx, offset ax_s
		mov cx, regAX
		mov rm1, cx
		int 21h
		jmp toliau4
		al_0:
		mov ah, 9h
		mov dx, offset al_s
		mov cx, regAX
		mov ch, 0
		mov rm1,cx
		int 21h
		jmp toliau4
		_1:
		cmp ah, 0C0h
		je reg1
		call printbracket1
		cmp ah, 0
		je md1
		mov ah, 9h
		mov dx, offset bx_s
		int 21h
		call printplius
		mov dx, offset di_s
		int 21h
		call printplius
		cmp ah, 40h
		je vienas1
		mov ah, baitas4
		mov al, baitas3
		call printAX
		call printbracket2
		jmp toliau4
		vienas1:
		mov al, baitas4
		call printAL
		call printbracket2
		jmp toliau4
		md1:
		mov ah, 9h
		mov dx, offset bx_s
		int 21h
		call printplius
		mov dx, offset di_s
		int 21h
		call printbracket2
		jmp toliau4
		reg1:
		cmp bh, 0
		je cl_0
		mov ah, 9h
		mov dx, offset cx_s
		mov cx, regCX
		mov rm1, cx
		int 21h
		jmp toliau4
		cl_0:
		mov ah, 9h
		mov dx, offset cl_s
		mov cx, regCX
		mov ch, 0
		mov rm1, cx
		int 21h
		jmp toliau4
		_2:
		cmp ah, 0C0h
		je reg2
		call printbracket1
		cmp ah, 0
		je md2
		mov ah, 9h
		mov dx, offset bp_s
		int 21h
		call printplius
		mov dx, offset si_s
		int 21h
		call printplius
		cmp ah, 40h
		je vienas2
		mov ah, baitas4
		mov al, baitas3
		call printAX
		call printbracket2
		jmp toliau4
		vienas2:
		mov al, baitas4
		call printAL
		call printbracket2
		jmp toliau4
		md2:
		mov ah, 9h
		mov dx, offset bp_s
		int 21h
		call printplius
		mov dx, offset si_s
		int 21h
		call printbracket2
		jmp toliau4
		reg2:
		cmp bh, 0
		je dl_0
		mov ah, 9h
		mov dx, offset dx_s
		mov cx, regDX
		mov rm1, cx
		int 21h
		jmp toliau4
		dl_0:
		mov ah, 9h
		mov dx, offset dl_s
		mov cx, regDX
		mov ch, 0
		mov rm1, cx
		int 21h
		jmp toliau4
		_3:
		cmp ah, 0C0h
		je reg3
		call printbracket1
		cmp ah, 0
		je md3
		mov ah, 9h
		mov dx, offset bp_s
		int 21h
		call printplius
		mov dx, offset di_s
		int 21h
		call printplius
		cmp ah, 40h
		je vienas3
		mov ah, baitas4
		mov al, baitas3
		call printAX
		call printbracket2
		jmp toliau4
		vienas3:
		mov al, baitas4
		call printAL
		call printbracket2
		jmp toliau4
		md3:
		mov ah, 9h
		mov dx, offset bp_s
		int 21h
		call printplius
		mov dx, offset di_s
		int 21h
		call printbracket2
		jmp toliau4
		reg3:
		cmp bh, 0
		je bl_0
		mov ah, 9h
		mov dx, offset bx_s
		mov cx, regBX
		mov rm1, cx
		int 21h
		jmp toliau4
		bl_0:
		mov ah, 9h
		mov dx, offset bl_s
		mov cx, regBX
		mov ch, 0
		mov rm1, cx
		int 21h
		jmp toliau4
		_4:
		cmp ah, 0C0h
		je reg4
		call printbracket1
		cmp ah, 0
		je md4
		mov ah, 9h
		mov dx, offset si_s
		int 21h
		call printplius
		cmp ah, 40h
		je vienas4
		mov ah, baitas4
		mov al, baitas3
		call printAX
		call printbracket2
		jmp toliau4
		vienas4:
		mov al, baitas4
		call printAL
		call printbracket2
		jmp toliau4
		md4:
		mov ah, 9h
		mov dx, offset si_s
		int 21h
		call printbracket2
		jmp toliau4
		reg4:
		cmp bh, 0
		je ah_0
		mov ah, 9h
		mov dx, offset sp_s
		mov cx, regSP
		mov rm1, cx
		int 21h
		jmp toliau4
		ah_0:
		mov ah, 9h
		mov dx, offset ah_s
		mov cx, regAX
		mov cl, 0
		mov rm1, cx
		int 21h
		jmp toliau4
		_5:
		cmp ah, 0C0h
		je reg5
		call printbracket1
		cmp ah, 0
		je md5
		mov ah, 9h
		mov dx, offset di_s
		int 21h
		call printplius
		cmp ah, 40h
		je vienas5
		mov ah, baitas4
		mov al, baitas3
		call printAX
		call printbracket2
		jmp toliau4
		vienas5:
		mov al, baitas4
		call printAL
		call printbracket2
		jmp toliau4
		md5:
		mov ah, 9h
		mov dx, offset di_s
		int 21h
		call printbracket2
		jmp toliau4
		reg5:
		cmp bh, 0
		je ch_0
		mov ah, 9h
		mov dx, offset bp_s
		mov cx, regBP
		mov rm1, cx
		int 21h
		jmp toliau4
		ch_0:
		mov ah, 9h
		mov dx, offset ch_s
		mov cx, regCX
		mov cl, 0
		mov rm1, cx
		int 21h
		jmp toliau4
		_6:
		cmp ah, 0C0h
		je reg6
		call printbracket1
		cmp ah, 0
		je md6
		mov ah, 9h
		mov dx, offset bp_s
		int 21h
		call printplius
		cmp ah, 40h
		int 21h
		mov cx, regBP
		call printplius
		je vienas6
		mov ah, baitas4
		mov al, baitas3
		call printAX
		call printbracket2
		add cx, ax
		mov rm1, cx
		jmp toliau4
		vienas6:
		mov al, baitas4
		call printAL
		call printbracket2
		mov ah, 0
		add cx, ax
		mov rm1, cx
		jmp toliau4
		md6:
		mov ah, baitas4
		mov al, baitas3
		call printAX
		call printbracket2
		mov rm1, ax
		jmp toliau4
		reg6:
		cmp bh, 0
		je dh_0
		mov ah, 9h
		mov dx, offset si_s
		mov cx, regSI
		mov rm1, cx
		int 21h
		jmp toliau4
		dh_0:
		mov ah, 9h
		mov dx, offset dh_s
		mov cx, regDX
		mov cl, 0
		mov rm1, cx
		int 21h
		jmp toliau4
		_7:
		cmp ah, 0C0h
		je reg7
		call printbracket1
		cmp ah, 0
		je md7
		mov ah, 9h
		mov dx, offset bx_s
		mov cx, regBX
		int 21h
		call printplius
		cmp ah, 40h
		je vienas7
		mov ah, baitas4
		mov al, baitas3
		call printAX
		call printbracket2
		add cx, ax
		mov rm1, cx
		jmp toliau4
		vienas7:
		mov al, baitas4
		call printAL
		call printbracket2
		mov ah, 0
		add cx, ax
		mov ax, rm1
		jmp toliau4
		md7:
		mov ah, 9h
		mov dx, offset bx_s
		mov bx,  regBX
		mov cx, [bx] 
		mov rm1, cx
		int 21h
		call printbracket2
		jmp toliau4
		reg7:
		cmp bh, 0
		je bh_0
		mov ah, 9h
		mov dx, offset di_s
		mov cx, regDI
		mov rm1, cx
		int 21h
		jmp toliau4
		bh_0:
		mov ah, 9h
		mov dx, offset bh_s
		mov cx, regBX
		mov cl, 0
		mov rm1, cx
		int 21h
		jmp toliau4
		point:
		mov ah, 2
		mov dl, ","
		int 21h
		inc si
		jmp reg
		toliau4:
		cmp si, 3h
		je toliau6
		cmp si, 0
		je point
		toliau5:
		
		call printSpace
		mov dx, rga
		mov ah, 9h
		int 21h
		mov ah, 2
		mov dl, "="
		int 21h
		mov ax, rg
		call printAX
		call printSpace
		mov si, 3h
		jmp rm
		toliau6:
		mov ah, 2
		mov dl, "="
		int 21h
		mov ax, rm1
		call printAX
		
	grizti_is_pertraukimo:
	mov ax, regAX
	mov bx, regBX
	mov cx, regCX
	mov dx, regDX
	mov sp, regSP
	mov bp, regBP
	mov si, regSI
	mov di, regDI
IRET ;grizimas is pertraukimo apdorojimo proceduros

;===================PAGALBINES pertraukime naudojamos proceduros================

;>>>Spausdinti AX reiksme
printAX:
	push ax
	mov al, ah
	call printAL
	pop ax
	call printAL
RET

;>>>>Spausdink tarpa
printSpace:
	push ax
	push dx
		mov ah, 2
		mov dl, " "
		int 21h
	pop dx
	pop ax
RET

;>>>Spausdinti AL reiksme
printAL:
	push ax
	push cx
		push ax
		mov cl, 4
		shr al, cl
		call printHexSkaitmuo
		pop ax
		call printHexSkaitmuo
	pop cx
	pop ax
RET

;>>>Spausdina hex skaitmeni pagal AL jaunesniji pusbaiti (4 jaunesnieji bitai - > AL=72, tai 0010)
printHexSkaitmuo:
	push ax
	push dx
	
	and al, 0Fh ;nunulinam vyresniji pusbaiti AND al, 00001111b
	cmp al, 9
	jbe PrintHexSkaitmuo_0_9
	jmp PrintHexSkaitmuo_A_F
	
	PrintHexSkaitmuo_A_F: 
	sub al, 10 ;10-15 ===> 0-5
	add al, 41h
	mov dl, al
	mov ah, 2; spausdiname simboli (A-F) is DL'o
	int 21h
	jmp PrintHexSkaitmuo_grizti
	
	
	PrintHexSkaitmuo_0_9: ;0-9
	mov dl, al
	add dl, 30h
	mov ah, 2 ;spausdiname simboli (0-9) is DL'o
	int 21h
	jmp printHexSkaitmuo_grizti
	
	printHexSkaitmuo_grizti:
	pop dx
	pop ax
RET
printplius:
	push ax
	push dx
		mov ah, 2
		mov dl, "+"
		int 21h
	pop dx
	pop ax
RET
printbracket1:
	push ax
	push dx
		mov ah, 2
		mov dl, "["
		int 21h
	pop dx
	pop ax
RET
printbracket2:
	push ax
	push dx
		mov ah, 2
		mov dl, "]"
		int 21h
	pop dx
	pop ax
RET



END
