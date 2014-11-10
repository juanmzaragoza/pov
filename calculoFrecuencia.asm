CALCULO_FRECUENCIA:
	CLR R0
	JMP FLANCO_ASC

FLANCO_ASC_CONTAR:
	INC R0
FLANCO_ASC:
	SBIC PINB,0 ;si es 0, todavia no hubo flanco => vuelvo a leer
	JMP FLANCO_DESC_CONTAR ;si no es 0, hubo un flanco ascendente
	JMP FLANCO_ASC
FLANCO_DESC_CONTAR:
	INC R0 ;cuento un flanco
FLANCO_DESC:
	SBIS PINB,0 ;si esta en 1, todavia no hubo flanco => vuelvo a leer
	JMP FLANCO_ASC_CONTAR ;si no es 1, hubo flanco
	JMP FLANCO_DESC