.include "m328Pdef.inc" //นำเข้า AVR definition file

.def zero = r16 
.def temp = r17  // sensor วัดความเข้มข้นแสงสว่าง
.def count = r18

.cseg
.org 0x0000
rjmp INIT		//กระโดดไปยัง function INIT

INIT:
	ldi zero,0b0000_0000	// load ข้อมูล 0b0000_0000 ไปยัง zero
	ldi temp,0b1111_1111	// load ข้อมูล 0b1111_1111 ไปยัง temp
	mov	count,zero			// เก็บค่า zero ลงใน count
	
	out ddrd,temp			// กำหนดให้ Port D เป็น output ขอวงจร
	ldi temp,0b1111_1011	// load ข้อมูล 0b1111_1011 ไปยัง temp
	out ddrc,zero			// กำหนดให้ Port C เป็น output ของวงจร
	rjmp START				// กระโดดไปทำงาน function START

START:
	in temp,pinC			// กำหนดให้ Port C เป็น input ของวงจรโดยเก็บคค่าใน temp
	andi temp,0b0000_0100   /* นำค่า 0b1111_1011 ภายใน temp ที่ได้จาก pin C AND 
								กับ 0b0000_0100 เพื่อใช้ขา 2 ของ port C เป็น input*/
	rcall DELAY				// เรียกใช้งาน function DELAY
	cpi temp,0b0000_0000	// เปรียบเทียบค่า temp กับ 0b0000_0000
	breq CHECK				// หากกค่าที่เปรียบเทียบเท่ากันจะทำการกระโดดไปทำงาน function CHECK
	rjmp START				// กระโดดไปทำงาน function START

CHECK:
	in temp,pinC			// กำหนดให้ Port C เป็น input ของวงจรโดยเก็บคค่าใน temp
	andi temp,0b0000_0100	/* นำค่า 0b1111_1011 ภายใน temp AND กับ 0b0000_0100
								เพื่อใช้ขา 2 ของ port C เป็น input*/
	rcall DELAY				// เรียกใช้งาน function DELAY
	cpi temp,0b0000_0100    // เปรียบเทียบค่า temp กับ 0b0000_0100
	breq CHECKnumber		// หากกค่าที่เปรียบเทียบเท่ากันจะทำการกระโดดไปยัง function CHECKnumber
	rjmp CHECK				// กระโดดไปทำงาน function CHECK

CHECKnumber:
	cpi count,0x09			// เปรียบเทียบค่าใน count กับ 0x09
	breq RESET				// หาก count เท่ากับ 9 ให้ทำการกระโดดไปยัง function RESET
	rjmp COUNTER			// กระโดดไปทำงาน function COUNTER

RESET:
	mov count,zero			// เก็บค่า zero หรือก็คือ 0b0000_0000 ลงใน count
	rjmp DISPLAY			// กระโดดไปทำงาน function DISPLAY

COUNTER:
	inc count				// count + 1
	rjmp DISPLAY			// กระโดดไปทำงาน function DISPLAY
	
DISPLAY:
	ldi ZL,low(TB_7SEGMENT*2)	// เก็บข้อมูลตำแหน่งของ TB_7SEGMENT byte low ลง ZL
	ldi ZH,high(TB_7SEGMENT*2)	// เก็บข้อมูลตำแหน่งของ TB_7SEGMENT byte high ลง ZH
	add ZL,count				// + ค่า ZL กับ count 
	adc ZH,zero					// + ค่า ZH กับ zero โดยมีตัวทดด้วย
								// + เพื่ออ้างอิงค่าจากตำแหน่งใน TB_7SEGMENT
	lpm							// คัดลอกข้อมูล register Z ไปเก็บยัง R0
	com	r0						// ทำการ one's complement ค่าใน RO
	out PORTD, r0				// แสดงค่า R0 ไปยัง Port D ส่งต่อไปยัง 7-segment
	rjmp START					// กระโดดไปทำงาน function START

TB_7SEGMENT:					// โดยแต่ละบิตคือ 0b.gfedcba ของ 7-segment 
	.DB 0b00111111, 0b00000110  //แสดงตัวเลข 0,1
	.DB 0b01011011, 0b01001111	// 2,3
	.DB 0b01100110, 0b01101101	// 4,5
	.DB 0b01111101, 0b00000111	// 6,7
	.DB 0b01111111, 0b01101111	// 8,9
	.DB 0b01110111, 0b01111100  
	.DB 0b00111001, 0b01011110
	.DB 0b01111001, 0b01110001
								
DELAY:							// เรียกใช้านเพื่อไม่ให้รับ input จาก sensor ถี่เกินไป
            ldi		R23, 5		// load ข้อมูล 5 ไปยัง r23
            ldi		R24, 200	// load ข้อมูล 200 ไปยัง R24
            ldi		R25, 200	// load ข้อมูล 200 ไปยัง R25
DELAY_0:
            nop					// no operation
            dec		R25			// ทำการลบค่าใน R25 ลง 1
            brne	DELAY_0		// R25 - 1 ไม่เท่ากับ 0 ทำการกระโดดไปยัง DELAY_0
            nop
            dec		R24         // R24 -1
            brne	DELAY_0     // R24 - 1 ไม่เท่ากับ 0 ทำการกระโดดไปยัง DELAY_0
			nop
            dec		R23		    // R23 - 1
            brne	DELAY_0     // R23 - 1 ไม่เท่ากับ 0 ทำการกระโดดไปยัง DELAY_0
			ret

.DSEG
.ESEG