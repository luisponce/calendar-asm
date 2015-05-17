;;; simple calendar with Colombian holydays

global _start

;; Macros de llamados al Sistema Operativo
;    Los macros se ayudan del pre-procesador
;
%define sys_write   4
%define sys_stdout  1
%define sys_stdin   0
%define sys_stderr  2

; Interrupcion del sistema (sin argumentos)
;
%macro sys_call 0 
    int 0x80
%endmacro

; Hace el llamado exit() al OS
;   sys_exit (int)[estado de salida]
;
%macro sys_exit 1
    mov eax,  1
    mov ebx, %1

    sys_call
%endmacro

%macro getopts 0 
    pop eax ; Trae a eax argc (int)

    cmp eax, 1
    je  .SinArgumentos
    jg  .parsopts
    jmp .parselse

    .parsopts
    call parsopts
    jmp .ConArgumentos

    .parselse
    mov ebx, args_error
    call print

%endmacro

;; Variables inicializadas

section .data

;; Strings del programa
args_error:	db "Numero de parametros invalidos",0

;; Caracteres especiales ASCII
;
; Notacion: 
; | ASCII CODE db ASCII BYTE |
LF db 0x0A ; Salto de linea
CR db 0x0D ; Retorno de carro
VT db 0x0B ; Tabulador vertical
HT db 0x09 ; Tabulador horizontal
BS db 0x08 ; Retroceso 

;; Variables no inicializadas

section .dss

;; Codigo (Logica del programa)

section .text

_start:
    ;; Llama al macro getops inspirado de C: getopts(int, char **);
    getopts 

.SinArgumentos:
    mov eax, LF
    call printChar

    jmp .exit

.ConArgumentos:
    mov eax, LF
    call printChar

    jmp .exit

.exit:
    ;; salir con exito
    sys_exit 0


;;; funciones 

; Determina las opts con las que fue llamado el programa
; y dependiendo de la opcion establece el STACK con un flag
;
; FLAGS:
;  0 => 
;
parsopts:
    ; WARNING: Esta funcion no preserva los registros EAX ... ESI

    ret

; Input ebx = char * str (termina en null)
print:				;escribe lo que este en ebx
    pusha			

    mov ecx, -1		;i= -1
.while:
    inc ecx			;i++
    cmp byte[ebx + ecx], 0	;while(str[i] != null)
    jne .while

    ;; sys_write(1, ebx, ecx)
    mov edx, ecx		
    mov eax, sys_write		
    mov ecx, ebx
    mov ebx, sys_stdout

    sys_call

    ;; fin de linea
    mov eax, LF
    call printChar

    popa

    ret

;;; intput: eax=number to print (int)
printChar:
    pusha
    mov ebx, sys_stdout
    mov ecx, eax
    mov edx, 1
    mov eax, sys_write

    sys_call

    popa
    ret



