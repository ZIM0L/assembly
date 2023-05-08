Progr segment

assume  cs:Progr,ds:dane

Start:	
	mov ax, dane				; (wczytanie danych)
    mov ds, ax
	
	xor ax, ax
	mov es, ax

	xor bx, bx
	mov bl, es:[046Ch]
	mov index, bl
	
petla1:							; nieskonczona petla
	xor ax, ax
	inc index					; od tej lini ktora wylosowal zwiekszamy o 1
	mov al, index				; (wybor indexu z zmiennej losuj)
	mov si, ax					
	xor ax, ax
			   
	mov al, 160					; (to jest ten pocz, czyli numerek [w pierwszym wypadku "11"[2B]] * 160 )
	mul losuj[si] 			    ; mnozenie jest 8 bitowe, poniewaz mnozenie zalezy od zmiennej, a zmienna jest 8bitowa	; AL jest mnozony przez chosenNumber i wynik w AX
	mov bx, ax 					; w BX znajduje sie adres poczatkowy liczby

	call zapisz_orginal

	
	mov es, ax					; offset adresu konsoli
	
petla_main:
	mov si, offset wzortab	    ; (adres wzortab)160bajtow ;w si zapisany offset tablicy160
	call pisz_znaki			; (cala funkcja dziala tak ze pozdmienia wzortab na te znaki,a pozniej z powrotem na te puste) wymień linię tekstu z terminalu na nową linię znaków
	
	call przerwa
			   
	mov si, offset tablica160	; (wpisanie w si adresu tablica160; za drugim razem jest uzywany aby usunac te 'X' i zastapic to pustym/poprzednim znakiem w linijce ? nie jestem pewien)160bajtow ;w si zapisany offset tablicy160
	call pisz_znaki			; wymień nową linię znaków na oryginalny tekst terminala
				
	mov ah, 1h					; Funkcja 01H bada stan bufora klawiatury w celu stwierdzenia czy jest tam znak do odczytu.
	int 16h
	jnz koniec					; jesli zostal wcisniety klawisz to zakoncz
	jmp petla1

koniec: 						; koniec nieskonczonej petli
	mov ah, 4Ch
	mov al, 0h
	int 21h

zapisz_orginal: 
	cld							; czyscie flage kierunku; potrzebne do rep movsw 
	push ds						; 1B
	push ds						; 1B
	pop es						
	mov di, 0000
	mov ax, 0b800h				; Adres konsoli
	mov ds, ax					; (ds to jest co ma zabierac; dalismy movsw co oznacza ze bierzemy WORD [2B] )
	mov si, bx					; (Adres konsoli czyli tam na górze to mox ax 160 ... ; si to jest gdzie zaczac)
	mov cx, 80					; 80 znaków w jedym wierszu a kazdy znak ma 2bajty
	rep movsw					; rep movsw - Operacja blokowa przeniesienia z konsoli do innego miejsca w pamieci 
								; kopiuje z segmentu danych(ds) i zrodla danych(si) do segmentu dodatkowego(es) i przeznaczenia danych(di) (ds(posiada adres poczatku):si -> es:di)
	pop ds						; przy si mamy segment danych, przy di w segmencie dodatkowym es
	ret

przerwa: 					; funkcja ktora czeka 1s
	xor al, al
	xor dx, dx
	mov cx, 16
	mov ah, 86h
	int 15h
	ret

pisz_znaki: 				; wypisanie 80 znakow
	mov di, bx
	mov cx, 80
	rep movsw
	ret
Progr ends




dane segment

tablica160 db 160 dup(0)		; tablica 160 elementowa wypelniona przy starcie programu zerami 
index db 0
losuj db 2, 11, 13, 6, 22, 15, 21, 20, 0, 18, 8, 11, 1, 0, 14, 19, 13, 4, 6, 4, 8, 23, 20, 5, 23, 19, 24, 6, 4, 16, 10, 12, 7, 2, 20, 15, 18, 24, 18, 17, 15, 12, 23, 2, 1, 13, 10, 1, 4, 23, 2, 4, 17, 6, 13, 19, 16, 15, 16, 13, 14, 10, 6, 17, 9, 5, 20, 24, 8, 5, 17, 7, 23, 12, 18, 7, 10, 3, 16, 21, 22, 19, 20, 1, 23, 14, 18, 7, 19, 14, 21, 22, 9, 15, 6, 8, 5, 18, 20, 3, 6, 24, 11, 2, 5, 2, 24, 24, 15, 24, 22, 10, 9, 20, 13, 10, 10, 21, 14, 4, 15, 17, 22, 1, 18, 22, 13, 3, 24, 3, 14, 16, 3, 5, 12, 19, 16, 8, 11, 18, 0, 5, 10, 3, 20, 20, 12, 10, 5, 20, 24, 8, 19, 24, 1, 18, 13, 18, 12, 15, 3, 9, 13, 1, 22, 12, 20, 10, 5, 9, 18, 23, 9, 18, 5, 14, 7, 15, 24, 8, 21, 22, 13, 6, 24, 8, 3, 11, 2, 8, 5, 15, 24, 2, 11, 12, 5, 17, 1, 8, 20, 17, 18, 6, 14, 7, 2, 2, 19, 7, 9, 18, 17, 20, 5, 23, 0, 13, 12, 19, 23, 6, 9, 12, 18, 4, 18, 8, 1, 19, 10, 3, 16, 7, 8, 2, 23, 18, 19, 3, 5, 11, 6, 3, 9, 14, 2, 12, 0, 6, 8, 16, 19, 3, 22, 16
; 256 liczb, liczby od 0 do 24 bo jest 25 wierszy
wzortab db 160 dup('X',78h) ;Wybor wzoru (poprzednio bylo)
dane ends

end start