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

    cmp eax, 2
    je  .parsopts
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

test_string_1 db "Hola Mundo", 0
test_string_2 db "Hola Munda", 0

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

section .bss
test_to_print: resb 2 ; reservo dos byte para test_to_print

;; Codigo (Logica del programa)

section .text

_start:
    ;; Llama al macro getops inspirado de C: getopts(int, char **);
    getopts 

.SinArgumentos:
    ; Probando la funcion strcmp (ver mas abajo)

    pusha
    mov eax, test_string_1
    mov ebx, test_string_2
    mov ecx, 12
    mov edx, 12
    
    call strcmp ; llamar a la funcion
    
    mov [test_to_print], eax
    mov byte[test_to_print + 1], 0

    add byte[test_to_print], 48 ; se suma 48 a eax (resultado) para convertirlo a ASCII
    
    mov ebx, test_to_print
    call print ; llamar a escribir el numero

    mov eax, LF
    call printChar

    popa

    jmp .exit

.ConArgumentos:
    ;mov eax, LF
    ;call printChar

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

; Compara dos Strings haciendo uso de los llamados ESI:EDI del 
; procesador que permiten la operacion con strings en memoria
; (cmpsb) o (cmosw para comparar de a 2 bytes)
;
; Parametros:
;   EAX => char * [Direccion SRC]
;   EBX => char * [Direccion DES]
;   ECX => int [Length SRC]
;   EDX => int [Length DES]
;
; Retorno:
;   EAX => 0 si son iguales; 1 si no son iguales
;
strcmp:
    ; mueve a esi el str1 [eax]
    mov esi, eax
    ; mueve a edi el str2 [ebx]
    mov edi, ebx

    ; se limpia el flag de direccion de strings
    cld
    
    ; el flag de ZERO se setea si ambos str son iguales o se limpia si no 
    repe cmpsb ; va comparando bytes en memoria, hasta el caracter NULL
    
    jecxz .strcmpNotSame

    mov eax, 1 ; movemos 1 a eax, es decir son iguales
    jmp .strcmpExit ; retorna el resulatado [EAX]

.strcmpNotSame:
    mov eax, 0 ; movemos 0 a eax, es decir no son iguales

.strcmpExit:
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
    mov ebx, sys_stdout
    mov ecx, eax
    mov edx, 1
    mov eax, sys_write

    sys_call
    ret



