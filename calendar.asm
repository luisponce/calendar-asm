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


; Determina si se tienen argumentos, y de ser asi que argumento es (-y / -d) en exec_mode  y
; guarda el otro argumento (año / dia) ingresado en exec_argv
; exec_mode = 0 no tiene argumentos
; exec_mode = 1 el primer argumento es -y
; exec_mode = 2 el priimer argumento es -d

%macro getOpt 0
    pop eax 

    cmp eax, 1
    je _sinArgumentos

    jg _conArgumentos
    
_sinArgumentos:
    mov byte[exec_mode], 0
    jmp _else

_conArgumentos:
    mov eax, [esp + 4]
    mov ebx, year_opt
    
    mov ecx, 3 ; TODO: PONER LA LONGITUD
    mov edx, 3
    
    call strcmp
    
    cmp eax, 0
    je  _parseoptsIsYear
    
    mov eax, [esp + 4]
    mov ebx, date_opt
    
    mov ecx, 3 ; TODO: PONER LA LONGITUD
    mov edx, 3
    
    call strcmp
    
    cmp eax, 0
    je  _parseoptsIsDate
    
    jmp _parseoptsRet
    
    _parseoptsIsYear:
    
        mov byte[exec_mode], 1

        jmp _parseoptsRet
 
    _parseoptsIsDate:
    
        mov byte[exec_mode], 2

    _parseoptsRet:
   
    pop eax     ;pop args[0]
    pop eax     ;pop args[1]
    pop eax     ;pop args[2]

    mov [exec_argv], eax

_else:

%endmacro

;; Variables inicializadas

section .data

;; Strings del programa
args_error:	db "Numero de parametros invalidos",0

;; Strings de comparacion (PARSEOPTS)

year_opt db "-y", 0
date_opt db "-d", 0

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

exec_mode:  resb 4 ; Tipo de ejecucion
exec_argv:  resb 50 ; Argumentos de ejecucion
is_cot:     resb 1 ; Esta ubucado en colombia

;; Codigo (Logica del programa)

section .text

_start:
    ;; Llama al macro getops inspirado de C: getopts(int, char **);
    getOpt 

    ;Suma a exec_mode 48 para pasar el numero a char
    mov eax, [exec_mode]
    add eax, 48
    mov [exec_mode], eax

    mov eax, 4
    mov ebx, 1
    mov ecx, [exec_argv]
    mov edx, 8

    sys_call

.exit:
    ;; salir con exito
    sys_exit 0


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



