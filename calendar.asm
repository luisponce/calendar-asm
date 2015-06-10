;; simple calendar with Colombian holydays

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
    je .sinArgumentos

    jg .conArgumentos
    
.sinArgumentos:
    mov byte[exec_mode], 0
    jmp .else

.conArgumentos:
    mov eax, [esp + 4]
    mov ebx, year_opt
    
    mov ecx, 3 ; TODO: PONER LA LONGITUD
    mov edx, 3
    
    call strcmp
    
    cmp eax, 0
    je  .parseoptsIsYear
    
    mov eax, [esp + 4]
    mov ebx, date_opt
    
    mov ecx, 3 ; TODO: PONER LA LONGITUD
    mov edx, 3
    
    call strcmp
    
    cmp eax, 0
    je  .parseoptsIsDate
    
    jmp .parseoptsRet
    
    .parseoptsIsYear:
        
        mov byte[exec_mode], 1

        jmp .parseoptsRet
 
    .parseoptsIsDate:
    
        mov byte[exec_mode], 2

    .parseoptsRet:
   

    pop eax     ;pop args[0]
    pop eax     ;pop args[1]
    pop eax     ;pop args[2]

    mov [exec_argv], eax

    ;mov eax, [esp + 8]
    ;mov ebx, [eax]
    ;mov ecx, [eax + 16]
    ;mov [exec_argv], ebx
    ;mov [exec_argv + 16], ecx


.else:

%endmacro

;; Variables inicializadas

section .data

;;; variables
num:	dq 1
	
;;; DEBUG ONLY
str_int:	db "int=%d",10,0

diaHabilStr db " es dia habil",0
diaFestivo db " es festivo",0
diaEl db "El dia ",0
diaDe db " de ",0
diaTrasladado db " trasladado del ", 0

strDomingo db "Domingo", 0
strLunes db "Lunes", 0
strMartes db "Martes", 0
strMiercoles db "Miercoles", 0
strJueves db "Jueves", 0
strViernes db "Viernes", 0
strSabado db "Sabado", 0

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

prueba db "123456"
;; Strings del programa
args_error:	db "Numero de parametros invalidos",0

test_string_1 db "Hola Mundo", 0
test_string_2 db "Hola Munda", 0
;; Strings de comparacion (PARSEOPTS)

year_opt db "-y", 0
date_opt db "-d", 0

;;; strings nombres festivos
nombreAnno db "(Año Nuevo)",0
nombreJueves db "(Jueves Santo)",0
nombreViernes db "(Viernes Santo)",0
nombreTrabajo db "(Dia del Trabajo)",0
nombreIndependencia db "(Independencia Nacional)",0
nombreBatalla db "(Batalla de Boyaca)",0
nombreInmaculada db "(Inmaculada Concepcion)",0
nombreNavidad db "(Navidad)",0
nombreEpifania db "(Epifania del Señor)",0
nombreSanJose db "(Dia de San Jose)",0
nombreAscension db "(Ascension del señor)",0
nombreCorpus db "(Corpus Christi)",0
nombreSagrado db "(Sagrado Corazon de Jesus)",0
nombreSanPedro db "(San Pedro y San Pablo)",0
nombreAsuncion db "(Asuncion de la Virgen)",0
nombreRaza db "(Dia de la Raza)",0
nombreSantos db "(Todos los Santos)",0
nombreCartagena db "(Independencia de Cartagena)",0
nombreDomingo db "(domingo)",0
	
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

;;; variables para la pascua
a:	dw 0
b:	dw 0
c:	dw 0
d:	dw 0
e:	dw 0
f:	dw 0
g:	dw 0
h:	dw 0
i:	dw 0
k:	dw 0
l:	dw 0
m:	dw 0
n:	dw 0
p:	dw 0

	
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
freeMem:	db "aa"
constD:	db "D"
constL:	db "L"
constM:	db "M"
constJ:	db "J"
constV:	db "V"
constS:	db "S"
F:	db "F"
	
;;; arreglos 
diasEnero:	dd 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
diasFebrero:	dd 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
diasMarzo:	dd 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
diasAbril:	dd 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
diasMayo:	dd 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
diasJunio:	dd 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
diasJulio:	dd 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,20,0,0,0,0,0,0,0,0,0,0,0
diasAgosto:	dd 0,0,0,0,0,0,7,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
diasSeptiembre:	dd 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
diasOctubre:	dd 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
diasNoviembre:	dd 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
diasDiciembre:	dd 0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,25,0,0,0,0,0,0

junk:	db "aa"
	
semana_e:	dd 0,3,2,5,0,3,5,1,4,6,2,4
semana_f:	dd 0,5,3,1

dfestivoJueves:	dd 0
mfestivoJueves:	dd 0
dfestivoViernes:	dd 0
mfestivoViernes:	dd 0
dfestivoEpifania:	dd 6
dfestivoSanJose:	dd 19
dfestivoAscension:	dd 0
mfestivoAscension:	dd 0
dfestivoCorpus:	dd 0
mfestivoCorpus:	dd 0
dfestivoSagrado:	dd 0
mfestivoSagrado:	dd 0
dfestivoSanPedro:	dd 29
mfestivoSanPedro:	dd 6
dfestivoAsuncion:	dd 23
mfestivoAsuncion:	dd 8
dfestivoRaza:	dd 12
dfestivoSantos:	dd 1
dfestivoCartagena:	dd 11
	
;; Variables no inicializadas

section .bss
test_to_print: resb 2 ; reservo dos byte para test_to_print

exec_mode:  resb 4 ; Tipo de ejecucion
exec_argv:  resb 120 ; Argumentos de ejecucion
is_cot:     resb 1 ; Esta ubucado en colombia

numero:	resb 50
	
timezone: resb 8 
timeseconds: resb 4

current_year resb 4
current_year_mod resb 4

current_month resb 4
current_day resb 4

current_month_days resb 4

year resb 4
month resb 4
day resb 4

;;; variables para la pascua

;; Codigo (Logica del programa)

section .text

;;main:	
_start:
    ;; Get Timezone && CurrentTime (Timestamp) 
    ; Timezone para colombia es 300
    ; Timestamp es el timepo actual 
    getOpt

    ;mov eax, 4
    ;mov ebx, 1
    ;mov ecx, [exec_argv]
    ;mov edx, 8

    ;sys_call

    cmp byte[exec_mode], 0
    je .isCurrentYear

    cmp byte[exec_mode], 1
    je .isParamYear

    mov edx, [exec_argv]
    call stringToInt

    mov edx, 0

    mov ecx, 10000

    div ecx
    
    mov [year], eax

    mov eax, edx
    mov edx, 0

    mov ecx, 100
    div ecx

    mov [month], eax
    mov [day], edx

	mov eax, [year]
	call festivos

    ;cmp [month], 1
    ;jne .feb

    ;mov ecx, [diasEnero + edx * 4]

    ;cmp ecx, 0
    


    mov ebx, diaEl
    call print

    mov ebx, [month]
    mov ecx, [day]
    mov eax, [year]

    call dayWeek
    
    cmp eax, 0
    jne .lunes

    mov ebx, strDomingo
    call print

    jmp .endDia 
.lunes: 
     mov ebx, [month]
    mov ecx, [day]
    mov eax, [year]

    call dayWeek
    
    cmp eax, 1
    jne .martes

    mov ebx, strLunes
    call print
    
    jmp .endDia

.martes:
    mov ebx, [month]
    mov ecx, [day]
    mov eax, [year]

    call dayWeek
    
    cmp eax, 2
    jne .miercoles

    mov ebx, strMartes
    call print

    jmp .endDia
    
.miercoles:
    mov ebx, [month]
    mov ecx, [day]
    mov eax, [year]

    call dayWeek
    
    cmp eax, 3
    jne .jueves

    mov ebx, strMiercoles
    call print

    jmp .endDia
    
.jueves:
mov ebx, [month]
    mov ecx, [day]
    mov eax, [year]

    call dayWeek
    
    cmp eax, 4
    jne .viernes

    mov ebx, strJueves
    call print

    jmp .endDia
    
.viernes:
mov ebx, [month]
    mov ecx, [day]
    mov eax, [year]

    call dayWeek
    
    cmp eax, 5
    jne .sabado

    mov ebx, strViernes
    call print

    jmp .endDia
    
.sabado:
mov ebx, [month]
    mov ecx, [day]
    mov eax, [year]

    call dayWeek

    mov ebx, strSabado
    call print

    jmp .endDia
    
.endDia:
    mov eax, WS
    call printChar

    mov eax, [day]
    mov edi, numero
    call intToString
    call write_digit
   
    mov ebx, diaDe
    call print

    mov eax, [month]
	call getStrMes
	mov ebx,eax
	call print

.endHabil:

    mov ebx, diaDe
    call print

    mov eax, [year]
    mov edi, numero
    call intToString
    call write_digit
	
		
.festEne:
    mov eax, [month]
    mov ebx, [day]

call getArrFestivo

mov ebx, 0
cmp eax, ebx
    jne .esDiaFestivo

    jmp .esDiaHabil
;***



.esDiaHabil:
    mov ebx, diaHabilStr
    call print

    mov eax, LF
    call printChar 

    sys_exit 0

.esDiaFestivo:
; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 	

mov ebx, diaFestivo
call print

	pusha

	mov eax,WS
	call printChar
	
	mov eax,[month]
	mov ebx, [day]
	call getNombreFestivo
	mov ebx, eax
	call print
	
	popa
	
;;; ----------------------------------------------------------

	mov eax, [month]
	mov ebx, [day]
	call getArrFestivo

	mov ebx,[day]
	cmp eax, ebx
	je .endCmpF

	mov ecx, [month]
	push ecx
	cmp eax, ebx
	jg .decMes

.endCmpM:
	push eax
	mov ebx, diaTrasladado
	call print

	pop eax
	call intToString
	call write_digit

	mov ebx, diaDe
	call print

	pop eax
	call getStrMes
	mov ebx, eax
	call print
	
.endCmpF:
	mov eax,LF
	call printChar
	sys_exit 0

.decMes:
	pop ecx
	dec ecx
	push ecx
	jmp .endCmpM

.isParamYear:
    mov edx, [exec_argv]
    call stringToInt

    call festivos

    mov edx, [exec_argv]
    call stringToInt

    call printYear
    jmp _exit

.isCurrentYear:
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


    mov eax, [current_year]

    call festivos

    mov eax, [current_year]

    call printYear
    ;call

    ;Suma a exec_mode 48 para pasar el numero a char
    ;mov eax, [exec_mode]
    ;add eax, 48
    ;mov [exec_mode], eax

    ;mov eax, 4
    ;mov ebx, 1
    ;mov ecx, [exec_argv]
    ;mov edx, 8

    ;sys_call

_exit:
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

stringToInt:
    xor eax, eax ; Eax = 0 
.top:
    ; Opetener el caracter del string
    movzx ecx, byte[edx]

    inc edx ; Incrementa el puntero del string
    cmp ecx, '0'

    jb .done

    cmp ecx, '9'
    ja .done

    ; Convertir el caracter a un numero
    sub ecx, '0'
    imul eax, 10
    add eax, ecx
    jmp .top

.done:
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
	push ecx
	mov ecx, 3
	cmp ebx,ecx
	jge .normal

	dec eax
.normal:
	dec ebx
	movzx ebx, word[semana_e+ebx*4]
	push ebx

	push eax
	mov ecx, eax
	
	mov ebx,4
	xor edx,edx
	div ebx

	add ecx, eax

	mov ebx,100
	xor edx,edx
	pop eax
	push eax
	div ebx

	sub ecx,eax

	mov ebx,400
	pop eax
	xor edx,edx
	div ebx

	add ecx, eax

	pop eax
	add ecx, eax
	pop eax
	add ecx, eax
	
	mov eax,ecx
	mov ebx,7
	xor edx,edx
	div ebx

	mov eax,edx
	
	
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

;;; input eax = dayWeek, ebx=dias del mes, ecx = mes
imprimirMes:
	push ecx		
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
	pop esi
	pop edi
	pop ecx
	push ecx
	push edi
	push esi
	
	pusha
	mov eax, ecx
	mov ebx, dword[num]

	call getArrFestivo

	mov ebx,0
	cmp eax, ebx
	je .noFest

	mov eax, F
	jmp .endFest
	
.noFest:
	mov eax, WS

.endFest:
	pusha
	call printChar
	popa
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
	pop ecx
	
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

printYear:
	push eax

	;; enero
	;; nombe del mes
	mov ebx, strEnero
	call print

	;; anyo
	pop eax
	push eax
	mov edi, numero
	call intToString
	pusha
	call write_digit
	popa
	
	;; LF
	mov eax, LF
	call printChar

	;; dias del mes

	pop eax			;eax = year
	push eax
	mov ebx, 1
	mov ecx, 1
	call dayWeek

	mov ebx, 31
	mov ecx, 1
	call imprimirMes

	mov eax, LF
	call printChar

	;; Febrero
	;; nombe del mes
	mov ebx, strFebrero
	call print

	;; anyo
	pop eax
	push eax
	mov edi, numero
	call intToString
	pusha
	call write_digit
	popa

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
	mov ecx, 2
	call imprimirMes

	mov eax, LF
	call printChar
	
	;; Marzo
	;; nombe del mes
	mov ebx, strMarzo
	call print

	;; anyo
	pop eax
	push eax
	mov edi, numero
	call intToString
	pusha
	call write_digit
	popa

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
	mov ecx, 3
	call imprimirMes

	mov eax, LF
	call printChar

	;; Abril
	;; nombe del mes
	mov ebx, strAbril
	call print

	;; anyo
	pop eax
	push eax
	mov edi, numero
	call intToString
	pusha
	call write_digit
	popa

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
	mov ecx, 4
	call imprimirMes

	mov eax, LF
	call printChar

	;; Mayo
	;; nombe del mes
	mov ebx, strMayo
	call print

	;; anyo
	pop eax
	push eax
	mov edi, numero
	call intToString
	pusha
	call write_digit
	popa

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
	mov ecx, 5
	call imprimirMes

	mov eax, LF
	call printChar

	;; Junio
	;; nombe del mes
	mov ebx, strJunio
	call print

	;; anyo
	pop eax
	push eax
	mov edi, numero
	call intToString
	pusha
	call write_digit
	popa

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
	mov ecx, 6
	call imprimirMes
	
	mov eax, LF
	call printChar

	;; Julio
	;; nombe del mes
	mov ebx, strJulio
	call print

	;; anyo
	pop eax
	push eax
	mov edi, numero
	call intToString
	pusha
	call write_digit
	popa

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
	mov ecx, 7
	call imprimirMes

	mov eax, LF
	call printChar

	;; Agosto
	;; nombe del mes
	mov ebx, strAgosto
	call print

	;; anyo
	pop eax
	push eax
	mov edi, numero
	call intToString
	pusha
	call write_digit
	popa

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
	mov ecx, 8
	call imprimirMes

	mov eax, LF
	call printChar

	;; Septiembre
	;; nombe del mes
	mov ebx, strSeptiembre
	call print

	;; anyo
	pop eax
	push eax
	mov edi, numero
	call intToString
	pusha
	call write_digit
	popa

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
	mov ecx, 9
	call imprimirMes

	mov eax, LF
	call printChar

	;; Octubre
	;; nombe del mes
	mov ebx, strOctubre
	call print

	;; anyo
	pop eax
	push eax
	mov edi, numero
	call intToString
	pusha
	call write_digit
	popa

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
	mov ecx, 10
	call imprimirMes

	mov eax, LF
	call printChar

	;; Noviembre
	;; nombe del mes
	mov ebx, strNoviembre
	call print

	;; anyo
	pop eax
	push eax
	mov edi, numero
	call intToString
	pusha
	call write_digit
	popa

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
	mov ecx, 11
	call imprimirMes

	mov eax, LF
	call printChar

	;; Diciembre
	;; nombe del mes
	mov ebx, strDiciembre
	call print

	;; anyo
	pop eax
	push eax
	mov edi, numero
	call intToString
	pusha
	call write_digit
	popa

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
	mov ecx, 12
	call imprimirMes

	mov eax, LF
	call printChar
	
	pop eax
	ret
	
;;; eax = year
festivos:			
	push eax
;;; domingos

;;; enero
	mov ebx, 1
	mov ecx, 1
	call dayWeek

	mov ebx,eax
	mov eax, 7
	sub eax, ebx

	mov ebx, 7
	xor edx, edx
	div ebx
	mov eax, edx

	inc eax

.ifEne:
	mov ebx, 31
	cmp eax, ebx
	jg .endIfEne

	mov esi, eax
	dec eax
	mov [diasEnero+eax*4], esi
	inc eax
	mov ebx, 7
	add eax, ebx
	jmp .ifEne

.endIfEne:
	mov ebx, 31
	xor edx, edx
	div ebx

	mov eax, edx

.ifFeb:
	pop edi
	push edi
	pusha
	mov eax, edi
	call isYearLeap
	mov ebx, 0
	cmp eax, ebx
	je .notLeap

	mov esi, 29
	jmp .conti

.notLeap:
	mov esi,28

.conti:
	pop edi
	push esi
	popa
	mov esi, edi
	mov ebx, esi
	cmp eax, ebx
	jg .endIfFeb

	mov esi, eax
	dec eax
	mov [diasFebrero+eax*4], esi
	inc eax
	mov ebx, 7
	add eax, ebx
	jmp .ifFeb

.endIfFeb:
	mov ebx, esi
	xor edx, edx
	div ebx

	mov eax, edx

.ifMar:
	mov ebx, 31
	cmp eax, ebx
	jg .endIfMar

	mov esi, eax
	dec eax
	mov [diasMarzo+eax*4], esi
	inc eax
	mov ebx, 7
	add eax, ebx
	jmp .ifMar

.endIfMar:
	mov ebx, 31
	xor edx, edx
	div ebx

	mov eax, edx

.ifAbr:
	mov ebx, 30
	cmp eax, ebx
	jg .endIfAbr

	mov esi, eax
	dec eax
	mov [diasAbril+eax*4], esi
	inc eax
	mov ebx, 7
	add eax, ebx
	jmp .ifAbr

.endIfAbr:
	mov ebx, 30
	xor edx, edx
	div ebx

	mov eax, edx

.ifMay:
	mov ebx, 31
	cmp eax, ebx
	jg .endIfMay

	mov esi, eax
	dec eax
	mov [diasMayo+eax*4], esi
	inc eax
	mov ebx, 7
	add eax, ebx
	jmp .ifMay

.endIfMay:
	mov ebx, 31
	xor edx, edx
	div ebx

	mov eax, edx

.ifJun:
	mov ebx, 30
	cmp eax, ebx
	jg .endIfJun

	mov esi, eax
	dec eax
	mov [diasJunio+eax*4], esi
	inc eax
	mov ebx, 7
	add eax, ebx
	jmp .ifJun

.endIfJun:
	mov ebx, 30
	xor edx, edx
	div ebx

	mov eax, edx

.ifJul:
	mov ebx, 31
	cmp eax, ebx
	jg .endIfJul

	mov esi, eax
	dec eax
	mov [diasJulio+eax*4], esi
	inc eax
	mov ebx, 7
	add eax, ebx
	jmp .ifJul

.endIfJul:
	mov ebx, 31
	xor edx, edx
	div ebx

	mov eax, edx

.ifAgo:
	mov ebx, 31
	cmp eax, ebx
	jg .endIfAgo

	mov esi, eax
	dec eax
	mov [diasAgosto+eax*4], esi
	inc eax
	mov ebx, 7
	add eax, ebx
	jmp .ifAgo

.endIfAgo:
	mov ebx, 31
	xor edx, edx
	div ebx

	mov eax, edx

.ifSep:
	mov ebx, 30
	cmp eax, ebx
	jg .endIfSep

	mov esi, eax
	dec eax
	mov [diasSeptiembre+eax*4], esi
	inc eax
	mov ebx, 7
	add eax, ebx
	jmp .ifSep

.endIfSep:
	mov ebx, 30
	xor edx, edx
	div ebx

	mov eax, edx

.ifOct:
	mov ebx, 31
	cmp eax, ebx
	jg .endIfOct

	mov esi, eax
	dec eax
	mov [diasOctubre+eax*4], esi
	inc eax
	mov ebx, 7
	add eax, ebx
	jmp .ifOct

.endIfOct:
	mov ebx, 31
	xor edx, edx
	div ebx

	mov eax, edx

.ifNov:
	mov ebx, 30
	cmp eax, ebx
	jg .endIfNov

	mov esi, eax
	dec eax
	mov [diasNoviembre+eax*4], esi
	inc eax
	mov ebx, 7
	add eax, ebx
	jmp .ifNov

.endIfNov:
	mov ebx, 30
	xor edx, edx
	div ebx

	mov eax, edx

.ifDic:
	mov ebx, 31
	cmp eax, ebx
	jg .endIfDic

	mov esi, eax
	dec eax
	mov [diasDiciembre+eax*4], esi
	inc eax
	mov ebx, 7
	add eax, ebx
	jmp .ifDic

.endIfDic:
	mov ebx, 31
	xor edx, edx
	div ebx

	mov eax, edx

;;; fin domingos

;;; 6 de enero - Epifanía del Señor
	pop eax
	push eax
	mov ebx, 1
	mov ecx ,6
	mov edx, diasEnero
	call aproximarFestivos
	mov [dfestivoEpifania],eax

;;; 19 de marzo - Día de San José
	pop eax
	push eax
	mov ebx, 3
	mov ecx, 19
	mov edx, diasMarzo
	call aproximarFestivos
	mov [dfestivoSanJose],eax
	
;;; 29 de Junio San Pedro y San Pablo
	pop eax
	push eax
	mov ebx, 6
	mov ecx, 29
	mov edx, diasJunio
	call aproximarFestivos
	mov [dfestivoSanPedro], eax
	mov [mfestivoSanPedro], ebx

;;; 23 de agosto - Asunción de la Virgen
	pop eax
	push eax
	mov ebx, 8
	mov ecx, 23
	mov edx, diasAgosto
	call aproximarFestivos
	mov [dfestivoAsuncion],eax
	mov [mfestivoAsuncion],ebx

;;; 12 de octubre - Día de la Raza
	pop eax
	push eax
	mov ebx, 10
	mov ecx, 12
	mov edx, diasOctubre
	call aproximarFestivos
	mov [dfestivoRaza],eax

;;; 1 de noviembre - Todos los Santos
	pop eax
	push eax
	mov ebx, 11
	mov ecx, 1
	mov edx, diasNoviembre
	call aproximarFestivos
	mov [dfestivoSantos],eax
	
;;; 11 de noviembre - Independencia de Cartagena.
	pop eax
	push eax
	mov ebx, 11
	mov ecx, 11
	mov edx, diasNoviembre
	call aproximarFestivos
	mov [dfestivoCartagena],eax
	
;;; pascua
	pop eax
	push eax
	mov ebx, 19
	xor edx, edx
	div ebx
	mov eax,edx
.a:	mov [a],eax

	pop eax
	push eax
	mov ebx,100
	xor edx,edx
	div ebx
.b:	mov [b], eax
.c:	mov [c], edx

	movzx eax, word[b]
	mov ebx, 4
	xor edx, edx
	div ebx
.d:	mov [d], eax
.e:	mov [e], edx

	movzx eax, word[b]
	mov ebx, 8
	add eax, ebx
	mov ebx, 25
	xor edx,edx
	div ebx
.f:	mov [f],eax

	movzx eax, word[b]
	movzx ebx, word[f]
	sub eax,ebx
	mov ebx,1
	add eax, ebx
	mov ebx,3
	xor edx,edx
	div ebx
.g:	mov [g], eax

	mov eax,19
	movzx ebx, word[a]
	mul ebx
	movzx ebx, word[b]
	add eax,ebx
	movzx ebx, word[d]
	sub eax,ebx
	movzx ebx, word[g]
	sub eax,ebx
	mov ebx,15
	add eax,ebx
	mov ebx,30
	xor edx,edx
	div ebx
.h:	mov [h],edx

	movzx eax, word[c]
	mov ebx,4
	xor edx,edx
	div ebx
.i:	mov [i],eax
.k:	mov [k],edx

	mov ebx,2
	movzx eax, word[e]
	mul ebx
	push eax
	movzx eax, word[i]
	mul ebx
	pop ebx
	add eax,ebx
	mov ebx,32
	add eax,ebx
	movzx ebx, word[h]
	sub eax,ebx
	movzx ebx, word[k]
	sub eax,ebx
	mov ebx,7
	xor edx,edx
	div ebx
.l:	mov [l], edx

	mov eax,11
	movzx ebx, word[h]
	mul ebx
	push eax
	mov eax,22
	movzx ebx, word[l]
	mul ebx
	pop ebx
	add eax,ebx
	movzx ebx, word[a]
	add eax, ebx
	mov ebx,451
	xor edx,edx
	div ebx
.m:	mov [m],eax

	mov eax,7
	movzx ebx, word[m]
	mul ebx
	push eax
	movzx eax, word[h]
	movzx ebx, word[l]
	add eax,ebx
	pop ebx
	sub eax,ebx
	mov ebx,144
	add eax,ebx
	mov ebx,31
	xor edx,edx
	div ebx
	dec eax
.n:	mov [n],eax		;mes
	inc edx
	inc edx
.p:	mov [p], edx		;dia
.stop:
	
	;; viernes Santo
	xor edx, edx		;cont = 0
	movzx eax, word[p]
	dec eax
	dec eax			;dia-=2
.again:
	mov ebx, 0
	cmp eax, ebx
	jg .noProb

	mov ebx, 31
	add eax, ebx	;dia = 31 + dia
	mov esi,eax
	dec eax
	mov [diasMarzo+eax*4],esi
	mov ebx,3
	push ebx
	jmp .endEaster
	
.noProb:
	movzx ebx, word[n]
	mov ecx, 4
	cmp ebx, ecx
	jne .easterMarzo

	mov esi,eax
	dec eax
	mov [diasAbril+eax*4],esi
	mov ebx,3
	push ebx
	jmp .endEaster

.easterMarzo:
	mov esi, eax
	dec eax
	mov [diasMarzo+eax*4],esi
	mov ebx,3
	push ebx
	
.endEaster:
	mov ebx,0
	cmp edx,ebx
	je .storeViernes

	mov ebx,1
	cmp edx,ebx
	je .storeJueves

	jmp .returnStore

.storeJueves:
	pop ebx
	inc ebx
	inc eax
	mov [dfestivoJueves],eax
	mov [mfestivoJueves],ebx
	dec eax
	jmp .returnStore

.storeViernes:
	pop ebx
	inc ebx
	inc eax
	mov [dfestivoViernes],eax
	mov [mfestivoViernes],ebx
	dec eax
	jmp .returnStore
	
.returnStore:
	
	inc edx
	mov ebx, 2
	cmp edx, ebx
	jne .again


	
;;; festivos que dependen de pascua
	movzx ecx, word[p]		;ecx = dia pascua
	movzx edx, word[n]		;edx = mes pascua
	xor eax, eax		;cont = 0
.repeat:
	mov ebx, 9
	cmp eax, ebx
	jg .endRepeat		;while cont<9

	;; Ascensión del Señor (Sexto domingo después de Pascua)
	mov ebx, 6
	cmp eax, ebx
	je .ponerFestivo

	;; Corpus Christi (Octavo domingo después de Pascua)
	mov ebx, 8
	cmp eax, ebx
	je .ponerFestivo

	;; Sagrado Corazón de Jesús (Noveno domingo después de Pascua)
	mov ebx, 9
	cmp eax, ebx
	je .ponerFestivo
	
.endIfsEaster:

	mov ebx, 7
	add ecx,ebx		;dias+=7

	mov ebx,3
	cmp edx,ebx
	jne .check4		;if mes == 3

	mov ebx, 31
	cmp ecx, ebx
	jle .check4		;if dias > 31

	inc edx			;mes++
	sub ecx, ebx		;dias-=31

.check4:
	mov ebx,4
	cmp edx,ebx
	jne .check5		;if mes == 4

	mov ebx, 30
	cmp ecx, ebx
	jle .check5		;if dias > 30

	inc edx			;mes++
	sub ecx, ebx		;dias-=30

.check5:
	mov ebx,5
	cmp edx,ebx
	jne .check6		;if mes == 5

	mov ebx, 31
	cmp ecx, ebx
	jle .check6		;if dias > 31

	inc edx			;mes++
	sub ecx, ebx		;dias-=31

.check6:
	mov ebx,6
	cmp edx,ebx
	jne .checkEnd		;if mes == 6

	mov ebx, 30
	cmp ecx, ebx
	jle .checkEnd		;if dias > 30

	inc edx			;mes++
	sub ecx, ebx		;dias-=30

.checkEnd:
	mov ebx, 31
	cmp ecx, ebx
	jle .endChecks		;if dias > 31

	inc edx			;mes++
	sub ecx, ebx		;dias-=31

.endChecks:
	inc eax
	jmp .repeat
	
.endRepeat:
	
	pop eax
	ret

.ponerFestivo:
	pop esi
	push esi
	pusha
	push eax
	mov eax, edx
	push edx
	push ecx
	push esi
	call obtenerArrMes
	mov edx, eax
	pop eax
	pop ecx
	pop ebx

	call aproximarFestivos
	pop ecx
	
	mov edx, 6
	cmp ecx,edx
	je .storeAscension

	mov edx, 8
	cmp ecx,edx
	je .storeCorpus

	mov edx, 9
	cmp ecx,edx
	je .storeSagrado

	jmp .returnStoreEaster

.storeAscension:
	mov [dfestivoAscension],eax
	mov [mfestivoAscension],ebx
	jmp .returnStoreEaster

.storeCorpus:
	mov [dfestivoCorpus],eax
	mov [mfestivoCorpus],ebx
	jmp .returnStoreEaster

.storeSagrado:
	mov [dfestivoSagrado],eax
	mov [mfestivoSagrado],ebx
	jmp .returnStoreEaster
	
.returnStoreEaster:
	
	popa
	jmp .endIfsEaster


	
;;; eax= year, ebx = mes, ecx = dia, edx =  ptr a arregloFestivosMes
;;; return eax = dia, ebx = mes
aproximarFestivos:
	push ecx
	mov esi, ebx
	mov edi, edx
	call dayWeek

	mov ebx, 8
	sub ebx, eax
	xor edx, edx
	mov eax, ebx
	mov ebx, 7
	div ebx
	mov eax, edx
	pop ebx
	push ebx
	add eax, ebx

	pop ebx
	
	;; compara si se pasa del mes
	mov ecx, 5
	cmp esi, ecx
	je .mayo

	mov ecx, 6
	cmp esi, ecx
	je .junio

	mov ecx, 7
	cmp esi, ecx
	je .julio

	mov ecx, 8
	cmp esi, ecx
	je .agosto
	
.end:
	
	dec eax
	
	mov [edi+eax*4], ebx
	inc eax
	mov ebx,ecx
.endFinal:
	ret

.mayo:
	mov esi, 31
	cmp eax, esi
	jle .end

	sub eax, esi
	mov edi, diasJunio
	inc ecx
	
	jmp .end
	
.junio:
	mov esi, 30
	cmp eax, esi
	jle .end

	sub eax, esi
	mov edi, diasJulio
	inc ecx
	
	jmp .end

.julio:
	mov esi, 31
	cmp eax, esi
	jle .end

	sub eax, ebx
	mov edi, diasAgosto
	inc ecx
	
	jmp .end

.agosto:
	mov esi, 31
	cmp eax, esi
	jle .end

	sub eax, ebx
	mov edi, diasSeptiembre
	inc ecx
	
	jmp .end

	

;;; eax = mes, ebx = dia
;;; return eax = festivo
getArrFestivo:	
	mov ecx, 1
	cmp eax, ecx
	jne .feb

	dec ebx
	mov eax, [diasEnero+ebx*4]
	inc ebx
	jmp .end
.feb:
	mov ecx, 2
	cmp eax, ecx
	jne .mar

	dec ebx
	mov eax, [diasFebrero+ebx*4]
	inc ebx
	jmp .end	
.mar:
	mov ecx, 3
	cmp eax, ecx
	jne .abr

	dec ebx
	mov eax, [diasMarzo+ebx*4]
	inc ebx
	jmp .end	
.abr:
	mov ecx, 4
	cmp eax, ecx
	jne .may

	dec ebx
	mov eax, [diasAbril+ebx*4]
	inc ebx
	jmp .end	
.may:
	mov ecx, 5
	cmp eax, ecx
	jne .jun

	dec ebx
	mov eax, [diasMayo+ebx*4]
	inc ebx
	jmp .end	
.jun:
	mov ecx, 6
	cmp eax, ecx
	jne .jul

	dec ebx
	mov eax, [diasJunio+ebx*4]
	inc ebx
	jmp .end	

.jul:
	mov ecx, 7
	cmp eax, ecx
	jne .ago

	dec ebx
	mov eax, [diasJulio+ebx*4]
	inc ebx
	jmp .end

.ago:
	mov ecx, 8
	cmp eax, ecx
	jne .sep

	dec ebx
	mov eax, [diasAgosto+ebx*4]
	inc ebx
	jmp .end	
.sep:
	mov ecx, 9
	cmp eax, ecx
	jne .oct

	dec ebx
	mov eax, [diasSeptiembre+ebx*4]
	inc ebx
	jmp .end	

.oct:
	mov ecx, 10
	cmp eax, ecx
	jne .nov

	dec ebx
	mov eax, [diasOctubre+ebx*4]
	inc ebx
	jmp .end	
.nov:
	mov ecx, 11
	cmp eax, ecx
	jne .dic

	dec ebx
	mov eax, [diasNoviembre+ebx*4]
	inc ebx
	jmp .end	
.dic:
	dec ebx
	mov eax, [diasDiciembre+ebx*4]
	inc ebx
	jmp .end	


	
.end:
	ret


;;; eax = mes
;;; return eax = dias<Mes> 
obtenerArrMes:
	mov ebx, 1
	cmp eax, ebx
	jne .febrero

	mov eax, diasEnero
	jmp .return
	
.febrero:
	mov ebx, 2
	cmp eax, ebx
	jne .marzo

	mov eax, diasFebrero
	jmp .return
	
.marzo:
	mov ebx, 3
	cmp eax, ebx
	jne .abril

	mov eax, diasMarzo
	jmp .return
	
.abril:
	mov ebx, 4
	cmp eax, ebx
	jne .mayo

	mov eax, diasAbril
	jmp .return

.mayo:
	mov ebx, 5
	cmp eax, ebx
	jne .junio

	mov eax, diasMayo
	jmp .return

.junio:
	mov ebx, 6
	cmp eax, ebx
	jne .julio

	mov eax, diasJunio
	jmp .return

.julio:
	mov ebx, 7
	cmp eax, ebx
	jne .agosto

	mov eax, diasJulio
	jmp .return

.agosto:
	mov ebx, 8
	cmp eax, ebx
	jne .septiembre

	mov eax, diasAgosto
	jmp .return

.septiembre:
	mov ebx, 9
	cmp eax, ebx
	jne .octubre

	mov eax, diasSeptiembre
	jmp .return

.octubre:
	mov ebx, 10
	cmp eax, ebx
	jne .noviembre

	mov eax, diasOctubre
	jmp .return

.noviembre:
	mov ebx, 11
	cmp eax, ebx
	jne .diciembre

	mov eax, diasNoviembre
	jmp .return

.diciembre:
	mov eax, diasDiciembre

.return:
	ret


;;; eax = mes
;;; return eax = *str msgMes
getStrMes:
	mov ebx, 1
	cmp eax, ebx
	jne .febrero

	mov eax, strEnero
	jmp .return
	
.febrero:
	mov ebx, 2
	cmp eax, ebx
	jne .marzo

	mov eax, strFebrero
	jmp .return
	
.marzo:
	mov ebx, 3
	cmp eax, ebx
	jne .abril

	mov eax, strMarzo
	jmp .return
	
.abril:
	mov ebx, 4
	cmp eax, ebx
	jne .mayo

	mov eax, strAbril
	jmp .return

.mayo:
	mov ebx, 5
	cmp eax, ebx
	jne .junio

	mov eax, strMayo
	jmp .return

.junio:
	mov ebx, 6
	cmp eax, ebx
	jne .julio

	mov eax, strJunio
	jmp .return

.julio:
	mov ebx, 7
	cmp eax, ebx
	jne .agosto

	mov eax, strJulio
	jmp .return

.agosto:
	mov ebx, 8
	cmp eax, ebx
	jne .septiembre

	mov eax, strAgosto
	jmp .return

.septiembre:
	mov ebx, 9
	cmp eax, ebx
	jne .octubre

	mov eax, strSeptiembre
	jmp .return

.octubre:
	mov ebx, 10
	cmp eax, ebx
	jne .noviembre

	mov eax, diasOctubre
	jmp .return

.noviembre:
	mov ebx, 11
	cmp eax, ebx
	jne .diciembre

	mov eax, strNoviembre
	jmp .return

.diciembre:
	mov eax, strDiciembre

.return:
	ret


;;; eax = mes, ebx = dia
;;; return eax = str_nombre
getNombreFestivo:
	movzx ecx, word[mfestivoJueves]
	cmp eax, ecx
	je .jueves
.endJueves:
	movzx ecx, word[mfestivoViernes]
	cmp eax, ecx
	je .viernes
.endViernes:
	movzx ecx, word[mfestivoAscension]
	cmp eax, ecx
	je .ascension
.endAscension:
	movzx ecx, word[mfestivoCorpus]
	cmp eax, ecx
	je .corpus
.endCorpus:
	movzx ecx, word[mfestivoSagrado]
	cmp eax, ecx
	je .sagrado
.endSagrado:
	movzx ecx, word[mfestivoSanPedro]
	cmp eax, ecx
	je .sanPedro
.endSanPedro:
	movzx ecx, word[mfestivoAsuncion]
	cmp eax, ecx
	je .asuncion
.endAsuncion:
	
	mov ecx, 1
	cmp eax,ecx
	je .enero

	mov ecx, 3
	cmp eax,ecx
	je .marzo

	mov ecx, 5
	cmp eax,ecx
	je .mayo

	mov ecx, 7
	cmp eax,ecx
	je .julio

	mov ecx, 8
	cmp eax,ecx
	je .agosto

	mov ecx, 10
	cmp eax,ecx
	je .octubre

	mov ecx, 11
	cmp eax,ecx
	je .noviembre

	mov ecx, 12
	cmp eax,ecx
	je .diciembre
	
.domingo:
	mov eax, nombreDomingo
	ret

.enero:
	mov ecx, 1
	cmp ebx, ecx
	je .anno

	movzx ecx,word[dfestivoEpifania] 
	cmp ebx, ecx
	je .epifania
	
	jmp .domingo

.marzo:
	movzx ecx,word[dfestivoSanJose]
	cmp ebx, ecx
	je .sanJose
	
	jmp .domingo

.mayo:
	mov ecx,1
	cmp ebx,ecx
	je .trabajo
	
	jmp .domingo

.julio:
	mov ecx, 20
	cmp ebx,ecx
	je .independencia
	
	jmp .domingo

.agosto:
	mov ecx, 7
	cmp ebx,ecx
	je .batalla
	
	jmp .domingo

.octubre:
	movzx ecx, word[dfestivoRaza]
	cmp ebx,ecx
	je .raza
	
	jmp .domingo

.noviembre:
	movzx ecx, word[dfestivoSantos]
	cmp ebx,ecx
	je .santos

	movzx ecx, word[dfestivoCartagena]
	cmp ebx, ecx
	je .cartagena
	
	jmp .domingo

.diciembre:
	mov ecx, 25
	cmp ebx, ecx
	je .navidad
	
	jmp .domingo		

.jueves:
	movzx ecx, word[dfestivoJueves]
	cmp ebx, ecx
	jne .endJueves
	
	mov eax, nombreJueves
	ret
	
.viernes:
	movzx ecx, word[dfestivoViernes]
	cmp ebx, ecx
	jne .endViernes
	
	mov eax, nombreViernes
	ret

.ascension:
	movzx ecx, word[dfestivoAscension]
	cmp ebx, ecx
	jne .endAscension

	mov eax, nombreAscension
	ret

.corpus:
	movzx ecx, word[dfestivoCorpus]
	cmp ebx, ecx
	jne .endCorpus

	mov eax, nombreCorpus
	ret

.sagrado:
	movzx ecx, word[dfestivoSagrado]
	cmp ebx, ecx
	jne .endSagrado

	mov eax, nombreSagrado
	ret

.sanPedro:
	movzx ecx, word[dfestivoSanPedro]
	cmp ebx, ecx
	jne .endSanPedro

	mov eax, nombreSanPedro
	ret

.asuncion:
	movzx ecx, word[dfestivoAsuncion]
	cmp ebx, ecx
	jne .endAsuncion

	mov eax, nombreAsuncion
	ret
	
.anno:
	mov eax, nombreAnno
	ret

.epifania:
	mov eax, nombreEpifania
	ret

.sanJose:
	mov eax, nombreSanJose
	ret

.trabajo:
	mov eax, nombreTrabajo
	ret

.independencia:
	mov eax, nombreIndependencia
	ret

.batalla:
	mov eax, nombreBatalla
	ret

	
.raza:
	mov eax, nombreRaza
	ret

.santos:
	mov eax, nombreSantos
	ret

.cartagena:
	mov eax, nombreCartagena
	ret

.navidad:
	mov eax, nombreNavidad
	ret
