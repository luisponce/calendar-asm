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

;;; variables
num:	dq 1
	
;;; DEBUG ONLY
str_int:	db "int=%d",10,0

;;; strings meses
strEnero:	db "Enero ",0
strFebrero:	db "Febrero ",0
strMarzo:	db "Marzo ",0
strAbril:	db "Abril ",0
strMayo:	db "Mayo ",0
strJunio:	db "Junio ",0
strJulio:	db "Julio ",0
strAgosto:	db "Agosto ",0
strSeptiembre:	db "Septiembre ",0
strOctubre:	db "Octubre ",0
strNoviembre:	db "Noviembre ",0
strDiciembre:	db "Diciembre ",0
	
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
WS db 0x20 ; Spacio
	
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

;;; chars
constD:	db "D"
constL:	db "L"
constM:	db "M"
constJ:	db "J"
constV:	db "V"
constS:	db "S"
	
	
;; Variables no inicializadas

section .bss
test_to_print: resb 2 ; reservo dos byte para test_to_print

exec_mode:  resb 4 ; Tipo de ejecucion
exec_argv:  resb 50 ; Argumentos de ejecucion
is_cot:     resb 1 ; Esta ubucado en colombia

numero:	resb 50
	
timezone: resb 8 
timeseconds: resb 4

current_year resb 4
current_year_mod resb 4

current_month resb 4
current_day resb 4

current_month_days resb 4
;; Codigo (Logica del programa)

section .text

;;main:	
_start:
    ;; Get Timezone && CurrentTime (Timestamp) 
    ; Timezone para colombia es 300
    ; Timestamp es el timepo actual 

	;mov eax, 2015
	;call printYear
	;sys_exit

    mov eax, 78
    mov ebx, timeseconds
    mov ecx, timezone

    sys_call

	;mov eax, [timezone]
	;mov edi, numero
	;call intToString
	;call write_digit

    ;mov eax, [timeseconds]
	;mov edi, numero
	;call intToString
	;call write_digit

; Le resto los segundos de un ano al timestamp
    mov edx, 0
    mov eax, [timeseconds]
    mov ecx, 31556926

    div ecx

; Como esa div nos da los anos que han pasado desde 1970,
; le sumo 1970 para obtener el ano actual (ej 2015)
    add eax, 1970

    mov [current_year], eax
    mov [current_year_mod], edx

; Lo que sobra de la div son los segundos trascurridos del 
; ano actual, los divido entre los segundos de un dia y 
; obtengo los dias que han pasado desde el 01 ENE del presente 
; ano.
    mov edx, 0
    mov eax, [current_year_mod]
    mov ecx, 86400

    div ecx

    ; EN EAX ESTAN LOS DIAS PASARON DESDE EL 01 ENER ANO ACTUAL

    mov esi, 0 ; Current Month
    mov edi, eax ; Los dias que faltan por iterar

_date_loop:
    
; Formula de Caro: (Modulo 7)
    mov edx, 0
    mov eax, esi
    mov ecx, 7

    div ecx

; Modulo 2 del resultado del mes
    mov eax, edx
    mov edx, 0
    mov ecx, 2

    div ecx

    mov eax, edx

; Compara si es febrero, en ese caso aplica la exepcion de Feb
    cmp esi, 1
    je _is_febrary
    
    cmp eax, 0 ; compara si es par
    je _is_par
    
; Si es impar se le resta 30 dias al contador de dias
    mov dword[current_month_days], 30
    sub edi, 30
    jmp _is_par_end

; Si es par se le resta 31 dias al contador de dias 
_is_par:
    mov dword[current_month_days], 31
    sub edi, 31
    jmp _is_par_end

; FebNormal le resta 28 dias al contador de dias
_is_febrary:
    mov eax, [current_year]
    call isYearLeap

    cmp eax, 1
    je _is_febrary_leap

    mov dword[current_month_days], 28
    sub edi, 28
    jmp _is_par_end

; FebLeap le resta 29 dias al contador de dias
_is_febrary_leap:
    mov dword[current_month_days], 29
    sub edi, 29

_is_par_end:
    inc esi ; Incremento el contador de meses

    ; Comparamos si la fecha es negativa salimos del ciclo
    cmp edi, 0
    jge _date_loop

    ; Le sumo los dias que resto del ultimo mes
    add edi, [current_month_days]
    
    mov [current_day], edi
    mov [current_month], esi 

    ;;; AQUI TERMINA EL CALCULO DEL CURRENT DATE



    ;mov eax, [current_year_mod]
    ;mov edi, numero
    ;call intToString
    ;call write_digit

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


    popa

    ret

;;; intput: eax=char to print (int)
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

;;; eax = int to write, edi=string destino
;;; return eax = numero de bytes del string (sizet)
intToString:
	push  edx
	push  ecx
	push  edi
	push  ebp
	mov   ebp, esp
	mov   ecx, 10

.pushDigits:
	xor   edx, edx	; zero-extend eax
	div   ecx		; divide by 10; now edx = next digit
	add   edx, '0'	; decimal value + 30h => ascii digit
	push  edx		; push the whole dword, cause that's how x86 rolls
	test  eax, eax	; leading zeros suck
	jnz   .pushDigits

.popDigits:
	pop   eax
	stosb		; don't write the whole dword, just the low byte
	cmp   esp, ebp	; if esp==ebp, we've popped all the digits
	jne   .popDigits

	xor   eax, eax	; add trailing nul
	stosb

	mov   eax, edi
	pop   ebp
	pop   edi
	pop   ecx
	pop   edx
	sub   eax, edi	; return number of bytes written
	ret

;;; eax = size del string
write_digit:
	mov edx, eax
	mov             eax, 4	; system call #4 = sys_write
	mov             ebx, 1	; file descriptor 1 = stdout
	mov             ecx, numero ; store *address* of digit into ecx
	int             80h
	ret

;;; input eax = dayWeek, ebx=dias del mes, (ecx = ptr a festivos)
imprimirMes:
	;; push ecx		
	push ebx
	push eax

	mov eax, WS
	call printChar
	mov eax, constD		;domingo
	call printChar

	mov eax, WS
	call printChar
	mov eax, WS
	call printChar

	mov eax, WS
	call printChar
	mov eax, constL		;lunes
	call printChar

	mov eax, WS
	call printChar
	mov eax, WS
	call printChar
	
	mov eax, WS
	call printChar
	mov eax, constM		;martes
	call printChar

	mov eax, WS
	call printChar
	mov eax, WS
	call printChar

	mov eax, WS
	call printChar
	mov eax, constM		;miercoles
	call printChar

	mov eax, WS
	call printChar
	mov eax, WS
	call printChar

	mov eax, WS
	call printChar
	mov eax, constJ		;jueves
	call printChar

	mov eax, WS
	call printChar
	mov eax, WS
	call printChar

	mov eax, WS
	call printChar
	mov eax, constV		;viernes
	call printChar

	mov eax, WS
	call printChar
	mov eax, WS
	call printChar

	mov eax, WS
	call printChar
	mov eax, constS		;sabado
	call printChar

	mov eax, LF		;fin de linea
	call printChar
		
	xor edx, edx
.if:
	pop eax
	cmp edx, eax
	jge .endIf
	push eax

	push edx
	
	mov eax, WS
	call printChar

	mov eax, WS
	call printChar

	mov eax, WS
	call printChar

	mov eax, WS
	call printChar
	
	pop edx

	inc edx
	jmp .if
.endIf:
	push eax
	mov ecx, 1
	mov dword[num], ecx
.while:
	
	cmp edx, const7
	je .comp7

.endIf2:
	pop eax
	pop ebx

	mov ecx, dword[num]
	cmp ecx, ebx
	push ebx
	push eax

	jg .end

	;; preguntar por digitos
	mov eax, 10
	cmp ecx, eax
	jl .digit
.return:	
	;; preguntar por el festivo
	mov eax, WS
	pusha
	call printChar
	popa
	
	mov eax, dword[num]
	mov edi, numero
	call intToString
	pusha
	call write_digit
	popa
	
	mov eax, WS
	pusha
	call printChar
	popa
	
	mov ecx, dword[num]
	inc ecx
	mov dword[num], ecx
	inc edx
	
	jmp .while

.end:
	pop eax
	pop ebx

	mov eax, LF
	call printChar
	
	
	ret

.digit:
	pusha
	mov eax, WS
	call printChar
	popa
	jmp .return
	
.comp7:
	mov eax, LF
	pusha
	call printChar
	popa
	xor edx, edx
	jmp .endIf2

;;; eax = year
printYear:
	push eax

	;; enero
	;; nombe del mes
	mov ebx, strEnero
	call print

	;; anyo

	;; LF
	mov eax, LF
	call printChar

	;; dias del mes

	pop eax
	push eax
	mov ebx, 1
	mov ecx, 1
	call dayWeek

	mov ebx, 31
	
	call imprimirMes

	mov eax, LF
	call printChar

	;; Febrero
	;; nombe del mes
	mov ebx, strFebrero
	call print

	;; anyo

	;; LF
	mov eax, LF
	call printChar

	;; dias del mes
	pop eax
	push eax
	mov ebx, 2
	mov ecx, 1
	call dayWeek

	pop edx 		;edx = year
	push edx
	pusha
	;; is leap year?
	mov eax, edx
	call isYearLeap
	cmp eax, const0
	je .normal

	;; leap
	popa
	mov ebx, 29
	jmp .endLeap
	
.normal:
	popa
	mov ebx, 28
.endLeap:
	call imprimirMes

	mov eax, LF
	call printChar
	
	;; Marzo
	;; nombe del mes
	mov ebx, strMarzo
	call print

	;; anyo

	;; LF
	mov eax, LF
	call printChar

	;; dias del mes

	pop eax
	push eax
	mov ebx, 3
	mov ecx, 1
	call dayWeek

	mov ebx, 31
	
	call imprimirMes

	mov eax, LF
	call printChar

	;; Abril
	;; nombe del mes
	mov ebx, strAbril
	call print

	;; anyo

	;; LF
	mov eax, LF
	call printChar

	;; dias del mes

	pop eax
	push eax
	mov ebx, 4
	mov ecx, 1
	call dayWeek

	mov ebx, 30
	
	call imprimirMes

	mov eax, LF
	call printChar

	;; Mayo
	;; nombe del mes
	mov ebx, strMayo
	call print

	;; anyo

	;; LF
	mov eax, LF
	call printChar

	;; dias del mes

	pop eax
	push eax
	mov ebx, 5
	mov ecx, 1
	call dayWeek

	mov ebx, 31
	
	call imprimirMes

	mov eax, LF
	call printChar

	;; Junio
	;; nombe del mes
	mov ebx, strJunio
	call print

	;; anyo

	;; LF
	mov eax, LF
	call printChar

	;; dias del mes

	pop eax
	push eax
	mov ebx, 6
	mov ecx, 1
	call dayWeek

	mov ebx, 30
	
	call imprimirMes
	
	mov eax, LF
	call printChar

	;; Julio
	;; nombe del mes
	mov ebx, strJulio
	call print

	;; anyo

	;; LF
	mov eax, LF
	call printChar

	;; dias del mes

	pop eax
	push eax
	mov ebx, 7
	mov ecx, 1
	call dayWeek

	mov ebx, 31
	
	call imprimirMes

	mov eax, LF
	call printChar

	;; Agosto
	;; nombe del mes
	mov ebx, strAgosto
	call print

	;; anyo

	;; LF
	mov eax, LF
	call printChar

	;; dias del mes

	pop eax
	push eax
	mov ebx, 8
	mov ecx, 1
	call dayWeek

	mov ebx, 31
	
	call imprimirMes

	mov eax, LF
	call printChar

	;; Septiembre
	;; nombe del mes
	mov ebx, strSeptiembre
	call print

	;; anyo

	;; LF
	mov eax, LF
	call printChar

	;; dias del mes

	pop eax
	push eax
	mov ebx, 9
	mov ecx, 1
	call dayWeek

	mov ebx, 30
	
	call imprimirMes

	mov eax, LF
	call printChar

	;; Octubre
	;; nombe del mes
	mov ebx, strOctubre
	call print

	;; anyo

	;; LF
	mov eax, LF
	call printChar

	;; dias del mes

	pop eax
	push eax
	mov ebx, 10
	mov ecx, 1
	call dayWeek

	mov ebx, 31
	
	call imprimirMes

	mov eax, LF
	call printChar

	;; Noviembre
	;; nombe del mes
	mov ebx, strNoviembre
	call print

	;; anyo

	;; LF
	mov eax, LF
	call printChar

	;; dias del mes

	pop eax
	push eax
	mov ebx, 11
	mov ecx, 1
	call dayWeek

	mov ebx, 30
	
	call imprimirMes

	mov eax, LF
	call printChar

	;; Diciembre
	;; nombe del mes
	mov ebx, strDiciembre
	call print

	;; anyo

	;; LF
	mov eax, LF
	call printChar

	;; dias del mes

	pop eax
	push eax
	mov ebx, 12
	mov ecx, 1
	call dayWeek

	mov ebx, 31
	
	call imprimirMes

	mov eax, LF
	call printChar
	
	pop eax
	ret
