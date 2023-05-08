ORG 800H  
	 LXI H,POWITANIE  		
	 RST 3  
	 LXI H,OPERACJE  
	 RST 3  
	 LXI H,OPERAND1  
	 RST 3  
	 RST 5  
	 LXI H,OPERATOR  
	 RST 3  
	 MOV B,D  
	 MOV C,E  
WCZYTAJ 	 RST 2  
	 CPI 'n'  
	 JZ NEGACJA  
	 CPI '+'  
	 JZ DODAJ  
	 CPI '-'  
	 JZ ODEJMIJ1  
	 JMP BLAD  
	 JNZ WCZYTAJ 			
NEGACJA  
	 LXI H,NEGUJ  
	 RST 3  
	 MOV A,B  
	 CMA  
	 RST 4  
	 MOV A,C  
	 CMA  
	 RST 4  
	 JMP KONIEC  
ODEJMIJ1  
	 LXI H,MINUS  
	 RST 3  
	 LXI H,OPERAND2  
	 RST 3  
	 RST 5  
	 LXI H,WYNIK  
	 RST 3  
ODEJMIJ2  
	 STC  				
	 CMC  
	 MOV A,C  
	 SUB E  
	 MOV L,A  
	 MOV A,B  
	 SBB D  
	 MOV H,A  
	 JC POZYCZKA  
	 MOV A,H  
	 RST 4  
	 MOV A,L  
	 RST 4  
	 JMP KONIEC  
	 JMP KONIEC  
DODAJ  
	 LXI H,DODAWANIE  
	 RST 3  
	 LXI H,OPERAND2  
	 RST 3  
	 RST 5  
	 LXI H,WYNIK  
	 RST 3  
	 XCHG  
	 DAD B  
	 CC PRZEPELNIENIE  
	 MOV A,H  
	 RST 4  
	 MOV A,L  
	 RST 4  
	 JMP KONIEC  
KONIEC  
	 LXI H,KONIECT  
	 RST 3  
	 HLT  
BLAD  
	 LXI H,BLADT  
	 RST 3  
	 JMP WCZYTAJ  
PRZEPELNIENIE  
	 MVI A,01H  
	 RST 4  
	 RET  
POZYCZKA  
	 MOV H,B  
	 MOV L,C  
	 MOV B,D  
	 MOV C,E  
	 XCHG  
	 MVI A,'-'  
	 RST 1  
	 JMP ODEJMIJ2  
POWITANIE 	 DB 'Witaj w kalkulatorze',10,13,'@'             
OPERACJE 	 DB 'Operacje: +, -, n',10,13,'@'            
OPERAND1 	 DB 'Podaj 1 operand:',10,13,'@'              
OPERATOR 	 DB 10,13,'Podaj operator:',10,13,'@'      
MINUS 	 DB 10,13,'Odejmowanie',10,13,'@'        
DODAWANIE 	 DB 10,13,'Dodawanie',10,13,'@'      
NEGUJ 	 DB 10,13,'Negacja',10,13,'@'     
KONIECT 	 DB 10,13,'Koniec programu',10,13,'@'                        
BLADT 	 DB 10,13,'Zly operator, sprobuj jeszcze raz',10,13,'@'          
OPERAND2 	 DB 'Podaj 2 operand: ',10,13,'@'          
WYNIK 	 DB 10,13,'Wynik: ',10,13,'@'