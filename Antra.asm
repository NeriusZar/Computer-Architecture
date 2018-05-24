.MODEL small
.STACK 256h
.DATA
	fname db 80 dup (0)
	fname2 db 80 dup (0)
	frez db 80 dup (0)
	handle dw 0
	handle2 dw 0
	handle3 dw 0
	fbuf db 255h dup(?)
	fbuf2 db 255h dup(?)
	fbuf3 db 255h dup(?)
	dydis1 dw 0
	dydis2 dw 0
	konst dw 0
	konst2 dw 0
	pap dw 0
	pap2 dw 0
	netiko db 'Norint, kad programa veiktu reikia ivesti parametrus, tarp kuriu butu duomenu failo pavadinimas $'
	netinkamas db 'Duomenu faile ivestas ne sesioliktainis skaicius $'
.CODE
start:

	mov ax, @data
	mov ds, ax
	
	mov ch, 0
	mov	cl, ES:[80h]	;programos paleidimo parametro simbolio skaicius rasomas ES 80h baite
	cmp	cx, 0			;jei paleidimo parametro nera,
	jne	pradzia  		;programa uzbaigia darba
	
	mov ah, 9h
    mov dx, offset netiko	;ismeta klaida
    int 21h
	jmp NoClose
	
pradzia:
    mov	ch, 0			
	mov	cl, es:[80h]
	mov bx, 81h				;parametru pradzia
	mov dl, 00h				;Kiek kartu praejo ciklas 'Parametrai'
	mov si, offset fname	;duomenu failo adresas
	mov dh, 20h				;Tarpo ASCII kodas cmp operacijai
parametrai:
	inc bx					
	mov ah, es:[bx]			;i ah isikeliame parametro simboli
	mov [si], ah			;fname buferio si-taji elementa prisiilyginam ah
	inc si					
	mov ah, es:[bx+1]		;i ah isikeliame sekanti parametro simboli
	cmp ah, dh				; tikriname ar simbolis ne tarpas
    jne parametrai			;jei tarpas taj nuskaitom kita parametra
	inc dl 					;pasizymim kad nuskaitem + viena parametra
	inc bx
	cmp dl, 03h				;ziurime ar jau nuskaiteme visus elementus
	je nuskaityta
	cmp dl, 01h				;Tikriname, kelintas parametras yra skaitomas
	je fragmentas
	mov dh, 0Dh				;i dh persikeliame enterio ASCII kodas
	mov si, offset frez
	jmp parametrai
fragmentas:
	mov si, offset fname2
	jmp parametrai

nuskaityta:
	mov si, 0
	mov dx, offset frez
	mov ah, 3Ch
	mov cx, 6
	int 21h					;sukuriame rezultatu faila
	mov handle2, ax			;deskriptoriu issaugome i handle2 kintamaji
atidarymasirskaitymas:
	cmp si, 1				;tikriname kelinta faila jau nuskaiteme
	je kitas
	mov dx, offset fname 
	mov handle, ax			;issaugome duomenu failo deskriptoriu
	jmp toliau
kitas:
	mov dx, offset fname2
	mov handle3, ax
toliau:
	mov ax, 3d00h			;atidarome faila
	int 21h
	mov bx, ax				;issaugome deskriptoriu
	mov ah, 3fh 			;skaitome failus
	mov cx, 255h			;i cx irasome kiek baitu skaitysime
	cmp si, 1				;tikriname kelinta faila nusktaiteme
	je antras2				;jei pirma jau nuskaiteme tai nuskaitinejam antraji
	mov dx, offset fbuf
	jmp toliau2
antras2:
	mov dx, offset fbuf2
toliau2:
	int 21h
	call Atrinkimas
	inc si
	cmp si, 2				;tikriname ar nuskaiteme visus duomenu failus
	jne atidarymasirskaitymas;jei ne tai nuskaitome kita duomenu faila
	
	mov si, pap2
	cmp si, 1
	je Exit1
	
	call Veiksmai
	mov ax, dydis1			;i ax isikeliame dydis1
	mov si, dydis2			;i si isikeliame dydis2
	cmp ax, si				;juos palyginame
	ja sudetis11			;jeigu pirmas bufferis didesnis uz antra tai sokame i sudetis11 ir prie pirmo pridedame antra
	mov bx, 0				;jeigu pirmas mazesnis uz antra tai vykdome duomenu apkeitima
	mov si, 0
	mov ax, dydis2
apkeitimas:					
	cmp ax, si
	je baigta
	mov bh, [fbuf2+si]		;fbuf2 elementus persikeliame i fbuf3 buferi
	mov [fbuf3+si], bh 
	inc si
	jmp apkeitimas
baigta:
	jmp persokimas3
Exit1:
	jmp NoClose
persokimas3:
	mov si, 0
	mov ax, dydis1
apkeitimas2:
	cmp ax, si
	je baigta2
	mov bh, [fbuf+si]		;fbuf elementus perkeliame i fbuf2 buferi
	mov [fbuf2+si], bh
	inc si
	jmp apkeitimas2	
baigta2:
	mov si, 0
	mov ax, dydis2
apkeitimas3:
	cmp ax, si
	je baigta3	
	mov bh, [fbuf3+si]		;fbuf3 elementus perkialeme i fbuf buferi
	mov [fbuf+si], bh
	inc si
	jmp apkeitimas3
baigta3:
	mov ax, dydis1			;sukeiciame buferiu dydzius
	mov si, dydis2
	mov dydis1, si
	mov dydis2, ax
	mov ax, konst			
	mov si, konst2
	mov konst, si
	mov konst2, ax
sudetis11:

	call sudetis			;vykdome sudeti
	
	jmp back
	
back:
	call PrintBuf			;spausdiname sudeta skaiciu
	mov ah, 3Eh	
	mov	bx, handle2
	int 21h 				;uzdarome rezultatu faila
Exit:
	mov bx, [handle]
	cmp ax, 0
	jz NoClose
	mov ah, 3Eh
	int 21h					;uzdarau duomenu faila
NoClose:
	mov ax, 4C00h
	int 21h					;uzbaigiu programos darba	
PrintBuf PROC
	mov ah, 40h
	mov bx, handle2
	int 21h
	ret
PrintBuf ENDP
Veiksmai PROC
	mov si, 0
elementai:
	mov al, [fbuf + si]		;i al isikeliame pirmo duomenu failo si-taji elementa
	cmp al, 0				;tikriname ar dar yra elementu
	je baiges				;jeigu elementai baigesi sokame i "baiges"
	cmp al, 40h				;tikriname ar al maziau uz 40h
	jl skaicius1	;jeigu taip tai elementas yra skaicius ir atimame 30h
	cmp al, 47h
	ja raidemaz
	sub al, 37h				;jeigu ne tai elementas yra raide ir atimame 37h kad gautume tikraja reiksme o ne ASCII koda
	jmp persokimas1
skaicius1:
	sub al, 30h
	jmp persokimas1
raidemaz:
	sub al, 57h
persokimas1:
	mov [fbuf+si], al		;pakeista reiskme ikeliame atgal i buferi
	inc si
	jmp elementai
baiges:
	mov dydis1, si			;i dydis1 isikeliame pirmo duomenu failo elementu skaicu
	mov konst, si
	
	mov si, 0				;ta pati kartojame su kitu duomenu failu
elementai1:
	mov al, [fbuf2 + si]
	cmp al, 0
	je baiges1
	cmp al, 40h
	jl skaicius
	cmp al, 47h
	ja raidemaz2
	sub al, 37h
	jmp persokimas
skaicius:
	sub al, 30h
	jmp persokimas
raidemaz2:
	sub al, 57h
persokimas:
	mov [fbuf2+si], al
	inc si
	jmp elementai1
baiges1:
	mov dydis2, si
	mov konst2, si
	ret
Veiksmai ENDP
Sudetis PROC
;sudetis
	
Pirmas: ; sudetis kai prie pirmo pridedame antra elementa
	mov ax, 0			;nusinuliname registrus
	mov si, 0
	mov bx, 0
	mov cx, 0
	mov si, dydis1		;i si persikeliame dydis1
	dec si				;vienu sumazinu kad galetume paimti paskutini elementa
	mov dydis1, si		;ir perkialeme sumazinta dydi atgal
	mov al, [fbuf+si]	;i al perkeliame si-taji fbuf elementa
	mov si, dydis2		;i si perkeliame dydis2
	cmp si, 0			;tikriname ar jau visu fbuf2 elementu nepridejome
	je pabaiga			;jeigu taip tai sokame i pabaiga
	dec si				;sumaziname dydis2 vienu skaiciumi
	mov dydis2, si		;ir sugraziname sumazinta reiksme i dydis2
	mov bl, [fbuf2+si]	;i bl persikeliame fbuf2 si-taji
	add	ax, bx			;sudedame skaicius
	mov ch, 16			
	div	ch				;padaliname ta skaiciu ir atskiriame skaiciu kuris bus perkeltas i fbuf ir skaiciu kuris liko minty
	mov si, dydis1		;i si vel persikeliame dydis1
	mov [fbuf+si], ah	;fbuf si-taji elementa pakeiciame sudetu skaiciumi
	cmp al, 0			;tikriname ar yra skaicius minty
	je Pirmas			;jeigu taip tai ta skaiciu pridedame prie sekancio fbuf elemento
liekana:
	cmp si, 0			;tikriname ar yra prie ko prideti skaiciu minty
	je papildomas				
	dec si				;sumaziname si
	mov al, [fbuf+si]	;i al perkeliame sekanti fbuf elementa
	cmp al, 15			;tikriname ar jis nera lygus F
	jne prideti			;jeigu ne tai pridedame viena
	mov al, 0			;jeigu taip tai F pavirsta i 0
	mov [fbuf+si], al
	jmp liekana			;sokame atgal ir ieskom skaiciaus prie kurio galime prideti
prideti:
	add al, 1
	mov [fbuf+si], al
	jmp Pirmas
papildomas:
	mov cx, 0
	mov cx, pap
	add cx, 1
	mov pap, cx
	jmp Pirmas
	
pabaiga:
	mov si, 0
atvertimas:				;atverciame gauto skaiciaus elementus i skaicius pagal ASCII lentele
	mov al, [fbuf+si]
	cmp si, konst
	je toliau3
	cmp al, 10
	jl  skaicius2
	add al, 37h
	jmp persokimas2
skaicius2:
	add al, 30h
persokimas2:
	mov [fbuf+si], al
	inc si
	jmp atvertimas
toliau3:
	mov cx, 0
	mov dx, offset fbuf
	mov cx, si			;i cx persikeliame kiek reiks spausudinti elementu
	mov ax, pap			;tikriname ar nera papildomo skaiciaus kuris padidintu fbuferi
	cmp ax, 0
	jne pertvarkymas	;jeigu yra tai prapleciamme fbuferi papildomu skaiciumi
	jmp print
pertvarkymas:
	cmp si, 0			;tikriname ar jau visus skaicius perkeleme
	je toliau4
	dec si
	mov ah, [fbuf+si]	;i ah persikeliame si-taji fbuf elementa
	inc si				
	mov [fbuf+si], ah	;ji perkialeme viena vieta toliau
	dec si
	jmp pertvarkymas
	toliau4:
	add al, 30h			;prie papildomo skaiciaus pridedame 30h kad jis atitiktu ASCII lenteles koda
	mov [fbuf+si], al	
	inc cx				;padidiname elementu skaiciu
print:
	ret
Sudetis ENDP
Atrinkimas PROC
	push si
	push ax
	push dx
	mov si, dx
	isnaujo:
	mov ah, [si]
	cmp ah, 'g'
	jl tinka
	jmp klaidaa
	tinka:
	cmp ah, 2Fh
	ja tinka2
	jmp klaidaa
	tinka2:
	cmp ah, 3Ah
	jl tinka3
	cmp ah, 40h
	ja tinka4
	jmp klaidaa
	tinka4:
	cmp al, 47h
	jl tinka3
	cmp al, 60h
	ja tinka3
	jmp klaidaa
	tinka3:
	inc si
	mov ah, [si]
	cmp ah, 0
	je baigta4
	jmp isnaujo
	;ikelimas
	klaidaa:
	mov ah, 9h
	mov dx, offset netinkamas
	int 21h
	mov si, 1
	mov pap2, si
	baigta4:
	pop dx
	pop ax
	pop si
	ret
Atrinkimas ENDP
END start