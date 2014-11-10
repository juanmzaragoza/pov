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

		LDI	R16,0x02 ;configuramos el mcu control register para que active la interrupción en los dos flancos
		OUT MCUCR,R16

		SBI PORTD,2 ;configuramos la INT0 -> sensor hall

		LDI R20,1<<INT0 ;activamos la interrupcion 0
		OUT GICR,R20

		SEI ;activamos las interrupciones globales

HERE:	JMP HERE
;HERE:	JMP INT0_ENCENDER_LEDS
;		JMP HERE

INT0_ENCENDER_LEDS: ;interrupcion que se encarga de enceder leds

		PUSH R16
		PUSH R17

		LDI ZH,HIGH(FI_TEST)
		LDI ZL,LOW(FI_TEST) ;inicializamos los punteros al principio de la tabla

LEER:	LPM R16,Z+ ;cargamos el valor al registro

		CPI R16,'N' ;si llego al final de la tabla
		BREQ FIN_INT0

		OUT PORTA,R16 ;sacamos el valor por el puerto A
		TST R16
		BREQ RETRASO_ESPACIO ;si es un espacio, esperamos el tiempo de un espacio

RETRASO_LEDS:
		;retrasar tiempo requerido entre leds encendidos
		RJMP LEER

RETRASO_ESPACIO:
		;retrasar tiempor requerido entre letras
		RJMP LEER

FIN_INT0:
		POP R17
		POP R16
		RETI

FI_TEST:
		.DB 0xFF,0x88,0x88,0x88,0x80,0,0xBF,'N';F i