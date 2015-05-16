;;; simple calendar with Colombian holydays

SECTION .data			;variables inicializadas
msgErr:	db "Numero de parametros invalidos",0xa,0

endln:	db 0xa
	
sys_write: 	equ 4
sys_exit:	equ 1
stdout:		equ 1
	
SECTION .dss			;variables no inicializadas

SECTION .text			;codigo
global _start

_start:
	pop eax			;obtener argc
	
	;; si no tiene argumentos
	cmp eax, 1
	je .SinArgumentos

	;; si tiene solo 2 argumentos
	cmp eax, 3
	je .ConArgumentos

	
	;; else
	mov ebx, msgErr		;parametros invalidos
	call printString
	jmp .exit

.SinArgumentos:
	mov eax,endln
	call printChar
	
	jmp .exit

.ConArgumentos:
	mov eax,endln
	call printChar
	
	jmp .exit
	
	;; salir
.exit:
	mov eax,sys_exit
	mov ebx,0		
	int 80h

	
;;; funciones 
	
;;; Input ebx = char * str (termina en null)
printString:				;escribe lo que este en ebx
	pusha			
	
	mov ecx, -1		;i= -1
.while:
	inc ecx			;i++
	cmp byte[ebx+ecx],0	;while(str[i] != null)
	jne .while

	;; sys_write(1, ebx, ecx)
	mov edx, ecx		
	mov eax,sys_write		
	mov ecx,ebx
	mov ebx,stdout
	int 80h

	;; fin de linea
	mov eax,endln
	call printChar

	popa
	
	ret


;;; intput: eax=number to print (int)
printChar:
	pusha
	mov ebx, stdout
	mov ecx, eax
	mov edx, 1
	mov eax, sys_write
	int 80h
	popa
	ret



