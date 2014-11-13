.INCLUDE "M32DEF.INC"
.INCLUDE "macros.inc"

.EQU DELAY_ON=1700 ;useg
.EQU DELAY_OFF=800 ;useg

;.ESEG
;.DB 0x04,0x05,0x05
;.DB 1,2,3,4,5,6 

.CSEG
.ORG 0x00
		JMP MAIN
.ORG 0x02
		JMP INT0_ENCENDER_LEDS

.ORG 0x100
MAIN:	SET_STACK ;inicializo stack
CONFIG:	LDI R16,0xFF
		OUT DDRA,R16 ;configuramos el puerto A como salida -> leds
		
		LDI	R16,0x02 ;configuramos el mcu control register para que active la interrupci�n en los dos flancos
		OUT MCUCR,R16

		SBI PORTD,2 ;configuramos la INT0 -> sensor hall

		LDI R20,1<<INT0 ;activamos la interrupcion 0
		OUT GICR,R20

		SEI ;activamos las interrupciones globales

HERE:	JMP HERE
;	JMP INT0_ENCENDER_LEDS
;		JMP HERE

RETARDO:
	PUSH R21
	PUSH R22
	.DEF N = R20 ; "N" RETARDOS DE 200uS
	.DEF A = R21 ; VARIABLE UTILIZADA PARA VARIOS PROPOSITOS
	.DEF C = R22 ;VARIABLE UTILIZADA COMO CONTADOR DE OVERFLOWS
	LDI C,0
	LDI A,0B0000001
	OUT TCCR0,A ; SETEO CLOCK EN MODO NORMAL Y CON PRESCALADO

PRE_LOOP:
    LDI A,1
	OUT TIFR,A ; LIMPIO EL REGISTRO DE INTERRUPCIONES PARA UNA NUEVA LECTURA
	LDI A,87
	OUT TCNT0,A ; ABRO EL TIMER EN 0      

LOOP:
	IN A,TIFR ; OBTENGO EL VALOR DEL REGISTRO DE INTERRUPCIONES	
    SBRS A,0 ; SALTEA LA SIGUIENTE INSTRICCION SI EL BIT 0 (TOV0) ES UN 1
	RJMP LOOP ; BUCLE HASTA GENERAR 1 OVERFLOW (CONTAR DE 155 A 255 + 1) 
	INC C ; INCREMENTO EL VALOR DEL CONTADOR
	CP C,N
	BRNE PRE_LOOP ; VUELVO AL LOOP SIN EL CONTADOR NO LLEGO A N.

	POP R22
	POP R21
	RET


INT0_ENCENDER_LEDS: ;interrupcion que se encarga de enceder leds

		PUSH R16
		PUSH R17
		PUSH R20

		LDI ZH,HIGH(FI_TEST<<1)
		LDI ZL,LOW(FI_TEST<<1) ;inicializamos los punteros al principio de la tabla

LEER:	LPM R16,Z+ ;cargamos el valor al registro

		CPI R16,'N' ;si llego al final de la tabla
		BREQ FIN_INT0

		OUT PORTA,R16 ;sacamos el valor por el puerto A
		TST R16
		BREQ RETRASO_ESPACIO ;si es un espacio, esperamos el tiempo de un espacio

RETRASO_LEDS:
		LDI R20,255;retrasar tiempo requerido entre leds encendidos
		CALL RETARDO
		RJMP LEER

RETRASO_ESPACIO:
		LDI R20,255 ;retrasar tiempor requerido entre letras
		CALL RETARDO
		RJMP LEER

FIN_INT0:
		CLR R20
		OUT PORTA,R20
		POP R20
		POP R17
		POP R16
		RETI

.cseg
FI_TEST: .DB 0xF1,0x88,0x88,0x88,0x80,0,0xBF,'N';F i