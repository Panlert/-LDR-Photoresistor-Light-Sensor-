.include "m328Pdef.inc" //����� AVR definition file

.def zero = r16 
.def temp = r17  // sensor �Ѵ����������ʧ���ҧ
.def count = r18

.cseg
.org 0x0000
rjmp INIT		//���ⴴ��ѧ function INIT

INIT:
	ldi zero,0b0000_0000	// load ������ 0b0000_0000 ��ѧ zero
	ldi temp,0b1111_1111	// load ������ 0b1111_1111 ��ѧ temp
	mov	count,zero			// �纤�� zero ŧ� count
	
	out ddrd,temp			// ��˹���� Port D �� output ��ǧ��
	ldi temp,0b1111_1011	// load ������ 0b1111_1011 ��ѧ temp
	out ddrc,zero			// ��˹���� Port C �� output �ͧǧ��
	rjmp START				// ���ⴴ价ӧҹ function START

START:
	in temp,pinC			// ��˹���� Port C �� input �ͧǧ�����纤���� temp
	andi temp,0b0000_0100   /* �Ӥ�� 0b1111_1011 ���� temp �����ҡ pin C AND 
								�Ѻ 0b0000_0100 ������� 2 �ͧ port C �� input*/
	rcall DELAY				// ���¡��ҹ function DELAY
	cpi temp,0b0000_0000	// ���º��º��� temp �Ѻ 0b0000_0000
	breq CHECK				// �ҡ���ҷ�����º��º��ҡѹ�зӡ�á��ⴴ价ӧҹ function CHECK
	rjmp START				// ���ⴴ价ӧҹ function START

CHECK:
	in temp,pinC			// ��˹���� Port C �� input �ͧǧ�����纤���� temp
	andi temp,0b0000_0100	/* �Ӥ�� 0b1111_1011 ���� temp AND �Ѻ 0b0000_0100
								������� 2 �ͧ port C �� input*/
	rcall DELAY				// ���¡��ҹ function DELAY
	cpi temp,0b0000_0100    // ���º��º��� temp �Ѻ 0b0000_0100
	breq CHECKnumber		// �ҡ���ҷ�����º��º��ҡѹ�зӡ�á��ⴴ��ѧ function CHECKnumber
	rjmp CHECK				// ���ⴴ价ӧҹ function CHECK

CHECKnumber:
	cpi count,0x09			// ���º��º���� count �Ѻ 0x09
	breq RESET				// �ҡ count ��ҡѺ 9 ���ӡ�á��ⴴ��ѧ function RESET
	rjmp COUNTER			// ���ⴴ价ӧҹ function COUNTER

RESET:
	mov count,zero			// �纤�� zero ���͡��� 0b0000_0000 ŧ� count
	rjmp DISPLAY			// ���ⴴ价ӧҹ function DISPLAY

COUNTER:
	inc count				// count + 1
	rjmp DISPLAY			// ���ⴴ价ӧҹ function DISPLAY
	
DISPLAY:
	ldi ZL,low(TB_7SEGMENT*2)	// �红����ŵ��˹觢ͧ TB_7SEGMENT byte low ŧ ZL
	ldi ZH,high(TB_7SEGMENT*2)	// �红����ŵ��˹觢ͧ TB_7SEGMENT byte high ŧ ZH
	add ZL,count				// + ��� ZL �Ѻ count 
	adc ZH,zero					// + ��� ZH �Ѻ zero ���յ�Ƿ�����
								// + ������ҧ�ԧ��Ҩҡ���˹�� TB_7SEGMENT
	lpm							// �Ѵ�͡������ register Z ����ѧ R0
	com	r0						// �ӡ�� one's complement ���� RO
	out PORTD, r0				// �ʴ���� R0 ��ѧ Port D �觵����ѧ 7-segment
	rjmp START					// ���ⴴ价ӧҹ function START

TB_7SEGMENT:					// �����кԵ��� 0b.gfedcba �ͧ 7-segment 
	.DB 0b00111111, 0b00000110  //�ʴ�����Ţ 0,1
	.DB 0b01011011, 0b01001111	// 2,3
	.DB 0b01100110, 0b01101101	// 4,5
	.DB 0b01111101, 0b00000111	// 6,7
	.DB 0b01111111, 0b01101111	// 8,9
	.DB 0b01110111, 0b01111100  
	.DB 0b00111001, 0b01011110
	.DB 0b01111001, 0b01110001
								
DELAY:							// ���¡��ҹ�����������Ѻ input �ҡ sensor ����Թ�
            ldi		R23, 5		// load ������ 5 ��ѧ r23
            ldi		R24, 200	// load ������ 200 ��ѧ R24
            ldi		R25, 200	// load ������ 200 ��ѧ R25
DELAY_0:
            nop					// no operation
            dec		R25			// �ӡ��ź���� R25 ŧ 1
            brne	DELAY_0		// R25 - 1 �����ҡѺ 0 �ӡ�á��ⴴ��ѧ DELAY_0
            nop
            dec		R24         // R24 -1
            brne	DELAY_0     // R24 - 1 �����ҡѺ 0 �ӡ�á��ⴴ��ѧ DELAY_0
			nop
            dec		R23		    // R23 - 1
            brne	DELAY_0     // R23 - 1 �����ҡѺ 0 �ӡ�á��ⴴ��ѧ DELAY_0
			ret

.DSEG
.ESEG