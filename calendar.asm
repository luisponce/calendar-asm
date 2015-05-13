;;; simple calendar with Colombian holydays

SECTION .data			;variables inicializadas

SECTION .dss			;variables no inicializadas

SECTION .text			;codigo
global _start

_start:
	
	

	;; salir
	mov eax,1		;sys_exit
	mov ebx,0		
	int 0x80

	
;;; funciones 
