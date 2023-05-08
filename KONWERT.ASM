Progr segment
  assume  cs:Progr, ds:dane, ss:stosik

  start:          
    mov ax, dane  ;wstepna definicja
    mov ds, ax
    mov ax, stosik
    mov ss, ax
    mov sp, offset szczyt

    mov ah, 09h								; wyswietlenie lancucha
    mov dx, offset powitanie
    int 21h
    mov dx, offset max  ;
    mov ah, 0ah         					;czytanie z klawiatury
    int 21h             ;

  petla:          
    mov bl, len
    cmp i, bl
      jz wynikd 							;skok po sprawdzeniu calego lancucha
    mov bl, i
    xor bh, bh
    mov cl, znaki[bx]
    cmp cl, '0' 							;sprawdzenie czy wieksze od 0
      jb  nie_liczba
    cmp cl, '9' 							;czy mniejsze od 9
      ja  nie_liczba
    sub cl, '0' 							;zamiana znaku na liczbe
    xor ax, ax
    mov al, cl
    add suma, ax
      jc  za_duza 							;male przekroczenie wartosci
    mov dx, 10
    mov ax, suma
    mov bl, len
    sub bl, 1
    cmp i, bl
      jz  omin 								;pominiecie dla koncowego znaku
    mul dx
      jc za_duza 							;duze przekroczenie wartosci
  omin:           
    mov suma, ax
    inc i
      jmp petla

  nie_liczba:           
    mov ah, 09h								; tu sa same wyswietlenia lancucha
    mov dx, offset bladznak
    int 21h
      jmp wyjdz
  za_duza:           
    mov ah, 09h
    mov dx, offset zaduzo
    int 21h
      jmp wyjdz

;DEC
  wynikd:
    mov dx, offset decimal
    mov ah, 09h
    int 21h
    xor bh, bh           ;
    mov bl, len          ;
    mov znaki[bx], '$'   ;
    mov ah, 09           					; wypisanie decymalne
    mov dx, offset znaki ;
    int 21h              ;

;BIN
    mov dx, offset binary
    mov ah, 09h
    int 21h				; rozkaz wypisania
    mov ah, 2									
    mov bx, suma			; zaladowanie liczby do bx
    mov cx, 16				; ile jest miejsc czyli 16 zer
  kolejb:
    mov dl, '0'
    rcl bx, 1				; to jest to przesuniecie z uwzglednieniem pozyczki
      jnc ominb				; jesli nie ma przeniesienia to skok do ominb
    inc dl				; zwiekszenie dl czyli chyba tego na ktorym bicie jestem
  ominb:          
    int 21h
    loop kolejb

;HEX
    mov dx, offset hexadecimal
    mov ah, 09h
    int 21h
    mov ah, 2
    mov bx, suma			; tak samo zaladowanie liczby do bx
    mov cx, 4				; ile jest miejsc czyli 4
  kolejh:         
    mov si, 000Fh			; si to jest chyba przez co mnoze czyli dziele przez max wartosc 1 miejsca czyli przez F 
    rol bx, 4				; mam bx (sume) i wycigam z niego 4 znaki
    and si, bx				; mnoze bx * si = index
    mov dl, hex[si]			; na podstawie tego mnozenia
  ominh:          
    int 21h
      loop kolejh

  wyjdz:         
    mov ah, 4ch
    mov al, 0
    int 21h
Progr ends

dane segment
  powitanie  db 'Podaj liczbe dziesietna (0-65535): ','$'
  bladznak db 10,13,'Podane dane nie sa liczba dziesietna.',10,13,'$'
  zaduzo db 10,13,'Podano za duza liczba.',10,13,'$'
  decimal     db 10,13, 'Twoja liczba to: $'
  binary     db 10,13, 'Twoja liczba binarnie to: $'
  hexadecimal     db 10,13, 'Twoja liczba hexdecimal to: $'
  hex    db '0123456789ABCDEF'
  max    db 6
  len    db ?
  znaki  db 6 dup(0)
  i      db 0
  suma   dw 0
dane ends

stosik segment
  dw 100h dup(0)
  szczyt Label word
stosik ends

end start