;podzielniki czestotliwosci
TC equ 36060; 1.19MHz/33Hz
TD equ 32162; 1.19MHz/37Hz
TE equ 29024; 1.19MHz/41Hz
TF equ 27045; 1.19MHz/44Hz
TG equ 24285; 1.19MHz/49Hz
TA equ 21636; 1.19MHz/55Hz
TH equ 19193; 1.19MHz/62Hz
TP equ 1;pauza
;Q koniec melodii




kod segment
assume cs:kod,ss:stosik,ds:dane;

;procedury

nuta proc               ;najdluzsze 1s
mov cx,16
mov dx,65535
mov ah,86h
int 15h
ret
nuta endp;

polnuta proc            ;8/16
mov cx,8
mov dx,65535
mov ah,86h
int 15h
ret
polnuta endp;

cwiercnuta proc        ;4/16
mov cx,4
mov dx,65535
mov ah,86h
int 15h
ret
cwiercnuta endp

osemka proc             ;najkrotsze 2/16
mov cx,2
mov dx,65535;
mov ah,86h
int 15h
ret
osemka endp;

        sound proc

        mov ax,ton

        mov dx,42h					; to jest uklad 8255
        out dx,al					; w celu wygenerowania dzwieku daje 42h na wy
        mov al,ah					
        out dx,al					; ; 2 razy ingernecja outem na adres 42h

;Wlaczenie glosnika
        mov dx,61h
        in al,dx;
        or al,00000011B
        out dx,al
        ret
        endp

;Wylaczenie glosnika
        nosound proc
        mov dx,61h
        in al,dx
        and al,11111100B
        out dx,al
        ret
        endp;

;Odtwarzanie                    
        play proc               ;dl - litera, ton - czestotliwosc, czas - czas[1,2,4,8]
        
        call sound              ; wlaczenie glosnika
        
        cmp czas,1              ; ktores z tych skacze na dol
        je cala

        cmp czas,2
        je pol

        cmp czas,4
        je cwierc

        cmp czas,8
        je osem

        jmp endplay

cala:                          ;ktores z tych skacze w gore
        call nuta
        jmp endplay

pol:    
        call polnuta
        jmp endplay

cwierc: 
        call cwiercnuta
        jmp endplay

osem:   
        call osemka
        jmp endplay

endplay:
        call nosound
        ret
        endp


;Program
start:          
                mov ax,dane
                mov ds,ax
                mov ax,stosik
                mov ss,ax
                mov sp,offset szczyt

                
                ; PSP(Program Segment Prefix) to osobny 256 bajtowy blok pamięci który jest tworzony tuż przed wykonaniem programu i znajduję się on
                ; przed pamięcią potrzebną do wykonania programu, jego pierwsza komórka znajduje się pod adresem 80h
                ; [komenda uruchomienia programu] -> [PSP] -> [wykonywany program]
                ; przerwanie poniżej pobiera adres PSP
                mov ah,62h					; dostep do wiersza polecen chyba nie wiem?
                int 21h
                mov es,bx					; pod es mam pspSeg
                mov si,80h					; bajt pod [ds:80h] mówi nam, ile znaków znajduje się na linii poleceń, bez kończącego znaku nowej linii (Enter = 13 ASCII)
                xor ch,ch
                mov cl,es:[si]				        ; ilosc znakow z argumentow
                cmp cl,0					; jesli jest 0 czyli nie ma argumentow to skok do domyslnej nazwy pliku
                je Domyslna

                dec cl						; zmniejszenie o 1 przez ta spacje , dekrementacja dlugosci stringa
                inc si						; (play.exe *) tutaj si ma wartosc 81 od [ds:81h] do [ds:0FFh] jest linia poleceń. Jak widać, ma ona długość 128 znaków i tylko tyle możemy wpisać, uruchamiając nasz program. Teraz również widać, dlaczego programy typu COM zaczynają się od adresu 100h - po prostu wcześniej nie mogą, bo CS=DS. 
                mov di,offset nazwaPliku			; (tymczasowo gama.txt) od adresu 81 mam ta nazwe pliku (bo pod 80 byla spacja), tutaj przepisuje cala reszta do nazwy zmiennej nazwaPliku
                push cx

zapisz:                         
                inc si						;(play.exe *_*****) pomija chyba ta spacje co jest po nazwie pliku czyli play.asm *	i teraz jestem na miejscu gwizdki czyli juz mam nazwe pliku
                mov al,es:[si]
                mov ds:[di],al				        ;(asda.txt) w ds mam zapisana nazwe pliku
                inc di						; przechodze na koljeny znak i petla 
                loop zapisz

                pop cx						; pobieram dlugosc  (16)
                cmp cl,9					; (play.exe[ENTER])jesli jest 9 znakow czyli play.exe = 9 znakow to puszcza domyslna nute, bo nie ma parametru          
                je Domyslna

                mov al,16                                        ; udogdnienie z nazwaPlik, aby pozniej nie popsuly sie nazwy 
                sub al,cl					; al - cl , czyli w al mam ile jest znakow
                mov cl,al					; liczbe znakow, dlugosc przenosze do cl
                xor ch,ch
                xor al,al
uzupelnij:      
                mov ds:[di],al                                  ; wypelnianie naszej nazwy zerami (ds)
                inc di
                loop uzupelnij

Domyslna:       
                mov dx,offset nazwaPliku				; zaladowanie nazwy domyslnego pliku do rejestru DS:DX, lub innej nazwy jesli zostala podana, pod dx mam nazwe pliku, na koncu jest $
                mov ah,3Dh						; funkcja 3D - otwórz istniejący plik, ds:dx adres do pliku, funkcja oddaje handle (uchwyt) pliku, 			
                xor al,al						; pozniej czytanie pliku jest nie wzgledem nazwy a wlasnie tego uchwytu, zeruje al bo tam bedzei ten handle do pliku
                int 21h
                mov bx,ax						; w bx fileHandle czyli 0 bo al byl zerowany, czyli wskazanie na pierwszy element

                jnc plikOk
                        						; w przypadku bledu flaga C = 1, jesli nie ma bledu to znaczy ze plik istnieje
                lea dx,blad						; wyswietlenie lancucha bledu
                mov ah,09H
                int 21h

                jmp exit

plikOk:         
                xor cx,cx
                xor dx,dx                                               ; czysimy dx, poniewaz mamy uchwyt w bx

                mov ah,42h						; (wymaga w bx file handler)funkcja 42h - ustaw bieżącą pozycję w pliku
                mov al,2h						; to jest 2h = End of file, przesuwa na koniec pliku 
                int 21h							; w dx jest ciagle nazwa pliku trzymana
                mov dlugosc,ax					        ; ax 

                xor cx,cx
                xor dx,dx

                mov ah,42h						; funkcja 42h - ustaw bieżącą pozycję w pliku
                xor al,al						; to jest chyba ustawienie zeby czytal od samego poczatku pliku od indeksu 0
                int 21h                                                 ; ax

                mov cx,dlugosc					        ; wykonanie petli tyle razy ile wynosi dlugosc
                mov dx,offset dzwiek					; pobranie dzwieku (czytanie)
                mov ah,3FH						; (wypelnianie dzwiek od 0 pozycji) funkcja 3F - czytaj z pliku
                int 21h

                mov ah,3eh						; funkcja 3E - zamknij plik
                int 21h

                mov dx,offset odtwarzam                                 ; wypisanie stringa
                mov ah,09H
                int 21h


                xor di, di

melodia:        
                mov bx,offset dzwiek                            ; adres dzwiek wypelniony znakami z pliku        
                mov dl,ds:[bx+di]                               ; litera [np C]
                inc di
                cmp dl,'Q'					; jesli jest Q to znaczy koniec odczytu z pliku (Q jest w kazdym na koncu)
                jne do

                jmp exit

do:             
                cmp dl,'C'					
                jne re
                mov ton,TC					; TC to sa te tony zdefiniowane na poczatku, bo tam jest TC equ czyli TC = 34546
                jmp graj
re:             
                cmp dl,'D'
                jne mi
                mov ton,TD
                jmp graj
mi:             
                cmp dl,'E'
                jne fa
                mov ton,TE
                jmp graj
fa:             
                cmp dl,'F'
                jne sol
                mov ton,TF
                jmp graj
sol:            
                cmp dl,'G'
                jne la
                mov ton,TG
                jmp graj
la:             
                cmp dl,'A'
                jne zi
                mov ton,TA
                jmp graj
zi:             
                cmp dl,'H'
                jne pauza
                mov ton,TH
                jmp graj

pauza:          mov ton,1


graj:           
                
                mov cl,ds:[bx+di]				        ; jestem na ton
                inc di							; ide o 1 dalej czyli jestem na oktawie (ton)
                sub cl,30h						; odjecie 0 w kodzie ASCII by uzyskac numer tonu
                shr ton,cl						;(hr działa jak dzielenie przez 2 i dzielimy to tyle razy ile jest w cl) przesuniecie w prawo (z lewej wchodza 0), obrot w prawo w celu okreslenia ktory numer oktway 2 do potegi razy cos to jest to samo co obrot w prawo
												; zeby nie robic obliczen dwa do potegi ktorejs razy cos

                mov cl,ds:[bx+di]				        ; jestem na czas
                inc di							; ide o 1 dalej czyli teraz jestem na czas (jak dlugo glosnik ma byc wlaczony)
                sub cl,30h						; odejmuje '0' w ASCII by uzyskac numer nuty
                mov czas,cl						; przekazuje do zmiennej czas 
               
                call play						; skok do play

                jmp melodia

exit:           mov ax,4c00h
                int 21h

kod ends;


dane segment

dzwiek db 3000 dup('$')

ton dw 0
czas db 0
dlugosc dw 0    ;dlugosc ilosci znaku w pliku

odtwarzam db 'Odtwarzanie pliku: '
nazwaPliku db 'gama.txt'
db 5 dup('$')
blad db 'Brak pliku$'


dane ends


stosik segment stack
dw 100h dup(0)
szczyt label word
stosik ends
end start