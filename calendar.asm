;;; simple calendar with Colombian holydays

SECTION .data			;variables inicializadas
msgErr:	db "Numero de parametros invalidos",0xa,0
	
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
	mov ebx, msgErr
	call print
	jmp .exit

.SinArgumentos:
	jmp .exit

.ConArgumentos:
	jmp .exit
	
	;; salir
.exit:
	mov eax,1		;sys_exit
	mov ebx,0		
	int 0x80

	
;;; funciones 

print:				;escribe lo que este en ebx como apuntador
	mov ecx, -1		;i= -1
.while:
	inc ecx			;i++
	cmp byte[ebx+ecx],0	;while(str[i] != null)
	jne .while

	;; sys_write(1, ebx, ecx)
	mov edx, ecx		
	mov eax,4		
	mov ecx,ebx
	mov ebx,1
	int 0x80

	mov eax, 4
	mov ebx,1
	mov ecx,0xa
	mov edx,1
	int 0x80

	ret

