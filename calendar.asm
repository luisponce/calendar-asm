;;; simple calendar with Colombian holydays

global _start			
global main
	
extern printf
	
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

;;; DEBUG ONLY
str_int:	db "int=%d",10,0

;; Strings del programa
args_error:	db "Numero de parametros invalidos",0

test_string_1 db "Hola Mundo", 0
test_string_2 db "Hola Munda", 0
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

;;; enteros
const0:	equ 0
const1:	equ 1
const2:	equ 2
const3:	equ 3
const4:	equ 4
const5:	equ 5
const6:	equ 6
const7:	equ 7
const8:	equ 8
const9:	equ 9
const10:	equ 10
const11:	equ 11
const12:	equ 12
	
const17:	equ 17
const18:	equ 18
const19:	equ 19
const20:	equ 20
const21:	equ 21
const22:	equ 22
const23:	equ 23
const24:	equ 24
const25:	equ 25
const26:	equ 26

const100:	equ 100

const400:	equ 400
	
;; Variables no inicializadas

section .bss
test_to_print: resb 2 ; reservo dos byte para test_to_print

exec_mode:  resb 4 ; Tipo de ejecucion
exec_argv:  resb 50 ; Argumentos de ejecucion
is_cot:     resb 1 ; Esta ubucado en colombia

;; Codigo (Logica del programa)

section .text

main:	
	
;;; _start:
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



;;; funciones 

; Determina las opts con las que fue llamado el programa
; y dependiendo de la opcion establece el STACK con un flag
;
; FLAGS:
;  0 => 
;
parsopts:
    ; WARNING: Esta funcion no preserva los registros EAX ... ESI
    ; compara si el argv[2 es -y

    mov eax, [esp + 8]		; eax = arg[1]
    mov ebx, year_opt		; ebx = "-y",0

    mov ecx, 3 			;TODO: strLen
    mov edx, 3

    call strcmp			;eax = 0 si iguales

    cmp eax, 0			;si -y
    je  .parseoptsIsYear

	;; si no es -y
    mov eax, [esp + 8]		;eax = arg[1]
    mov ebx, date_opt		;ebx = "-d",0

    mov ecx, 3			;TODO: strlen
    mov edx, 3

    call strcmp

    cmp eax, 0			;eax = 0 si son iguales
    je  .parseoptsIsDate 	;si -d

    jmp .parseoptsRet		;si no es -d ni -y

.parseoptsIsYear:
    mov ebx, year_opt_msg
    call print
    jmp .parseoptsRet

.parseoptsIsDate:
    mov ebx, date_opt_msg
    call print

.parseoptsRet:
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


;;; input: eax=year (int, ex: 1993)
;;; ebx = month (int, ex:10)
;;; ecx = day (int, ex:20)
;;; return: eax = dayOfWeek (int, domingo = 0...sabado = 6)
dayWeek:
	push ecx		;guardar el dia para la suma
	
	push eax		;guardar registros para llamar una funcion
	push ebx
	
	call isYearLeap		;obtiene 0 si no es biciesto, 1 si si
	mov ecx, eax

	pop ebx			;vuelve a obtener los datos antes de la funcion
	pop eax

	push ebx
	;; get century number
	xor edx, edx
        CDQ 			;sign-extend eax into edx 
	mov ebx, const100 
	div ebx
	pop ebx
	;; eax = century
	;; edx = last 2 digits
	push edx
	
	call getCentury		;obtener el codigo del siglo
	push eax		;guarda el codigo para la suma

	push ebx
	;; ultimos digitos / 4
	mov eax, edx
	xor edx, edx
	CDQ
	mov ebx, const4
	div ebx
	pop ebx
	push eax		;guarda el resultado para la suma

	;; codigo del mes
	mov eax, ebx		;mes
	mov ebx, ecx 		;si es biciesto
	call getMonth
	
	;; suma de los numeros
	pop ebx
	add eax, ebx 		;mes + digitos anyos/4
	pop ebx
	add eax, ebx		;total + digitos anyos
	pop ebx
	add eax, ebx		;total + siglo
	pop ebx
	add eax, ebx		;total + dia
	
	;; mod 7
	xor edx,edx
	CDQ
	mov ebx, const7
	div ebx
	mov eax, edx
	
	ret

;;; eax = century (ex: 19)
getCentury:
	cmp eax,const17		;XVIII
	je .op4		

	cmp eax, const18	;XIX
	je .op2

	cmp eax, const19	;XX
	je .op0
	
	cmp eax, const20	;XXI
	je .op6

	cmp eax, const21	;XXII
	je .op4

	cmp eax, const22	;XXIII
	je .op2

	cmp eax, const23	;XXIV
	je .op0

	cmp eax, const24	;XXV
	je .op6

	cmp eax, const25	;XXVI
	je .op4

	cmp eax, const26	;XXVII
	je .op2
	
	;; else
	;; error

.op6:
	mov eax, const6
	jmp .end
.op4:
	mov eax, const4
	jmp .end
.op2:
	mov eax, const2
	jmp .end
.op0:
	mov eax, const0
.end:
	ret


;;; input eax = year
;;; return eax = 0 false, 1 true
isYearLeap:
	mov ebx, eax
	push ebx
	xor edx, edx
	CDQ
	mov ebx, const4
	div ebx
	pop ebx
	cmp edx, const0		;mod 4 == 0
	jne .notLeap

	mov eax, ebx
	push ebx
	xor edx, edx
	CDQ
	mov ebx, const100
	div ebx
	pop ebx
	cmp edx, const0 	;mod 100 == 0
	jne .isLeap

	mov eax, ebx
	push ebx
	CDQ
	mov ebx, const400
	div ebx
	pop ebx
	cmp edx, const0
	jne .notLeap

.isLeap:
	mov eax, const1
	jmp .end
.notLeap:
	mov eax, const0
.end:
	ret
	
;;; input eax = month (sep = 09), ebx = esBiciesto? (0 no, 1 si)
;;; return eax = monthCode 
getMonth:
	;; es biciesto?
	cmp ebx, const0
	je .normal

	;; biciesto
	;; enero - 6
	cmp eax, const1
	jne .febL
	mov eax, const6		;si es enero
	jmp .end
	
	;; febrero - 2
.febL:
	cmp eax, const2
	jne .elResto
	mov eax, const2		;si es febrero
	jmp .end
	
.normal:
	;; enero - 0
	cmp eax, const1
	jne .febN
	mov eax, const0		;si es febrero
	jmp .end
	;; febrero - 3
.febN:
	cmp eax, const2
	jne .elResto
	mov eax, const3		;si es febrero
	jmp .end
.elResto:
	;; marzo - 3
	cmp eax, const3
	jne .abril
	mov eax, const3		;si es marzo
	jmp .end
	;; abril - 6
.abril:
	cmp eax, const4
	jne .mayo
	mov eax, const6		;si es abril
	jmp .end
	;; mayo - 1
.mayo:
	cmp eax, const5
	jne .junio
	mov eax, const1		;si es mayo
	jmp .end
	;; junio - 4
.junio:
	cmp eax, const6
	jne .julio
	mov eax, const4		;si es junio
	jmp .end
	;; julio - 6
.julio:
	cmp eax, const7
	jne .agosto
	mov eax, const6		;si es julio
	jmp .end
	;; agosto - 2
.agosto:
	cmp eax, const8
	jne .septiembre
	mov eax, const2		;si es agosto
	jmp .end
	;; septiembre - 5
.septiembre:
	cmp eax, const9
	jne .octubre
	mov eax, const5		;si es septiembre
	jmp .end
	;; octubre - 0
.octubre:
	cmp eax, const10
	jne .noviembre
	mov eax, const0		;si es octubre
	jmp .end
	;; noviembre - 3
.noviembre:
	cmp eax, const11
	jne .diciembre
	mov eax, const3		;si es noviembre
	jmp .end
	;; diciembre - 5
.diciembre:
	cmp eax, const12
	jne .error
	mov eax, const5		;si es diciembre
	jmp .end
.error:
	;; error....
.end:
	ret
