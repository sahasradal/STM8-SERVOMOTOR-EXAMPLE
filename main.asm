stm8/

	#include "mapping.inc"
	#include "stm8s103f.inc"
	
	segment byte at 100 'ram1'
buffer1  ds.b
buffer2  ds.b
buffer3  ds.b
nibble1  ds.b	
pad1     ds.b	
	
	
	segment 'rom'
main.l
	; initialize SP
	ldw X,#stack_end
	ldw SP,X

	#ifdef RAM0	
	; clear RAM0
ram0_start.b EQU $ram0_segment_start
ram0_end.b EQU $ram0_segment_end
	ldw X,#ram0_start
clear_ram0.l
	clr (X)
	incw X
	cpw X,#ram0_end	
	jrule clear_ram0
	#endif

	#ifdef RAM1
	; clear RAM1
ram1_start.w EQU $ram1_segment_start
ram1_end.w EQU $ram1_segment_end	
	ldw X,#ram1_start
clear_ram1.l
	clr (X)
	incw X
	cpw X,#ram1_end	
	jrule clear_ram1
	#endif

	; clear stack
stack_start.w EQU $stack_segment_start
stack_end.w EQU $stack_segment_end
	ldw X,#stack_start
clear_stack.l
	clr (X)
	incw X
	cpw X,#stack_end	
	jrule clear_stack

main_loop.l
							  ; timer2 setup for PWM on PD3 timer2 chanel2 (hardware w/o gpio)
	  mov CLK_CKDIVR,#$0     ; set max internal clock 16mhz
	  mov TIM2_PSCR,#$03      ; timer 2 prescaler div by 8 ,16Mhz/8 =2Mhz
	  mov TIM2_ARRH,#$9c     ; count to 40000-1 ,high byte must be loaded  first,
	  mov TIM2_ARRL,#$3f     ; frequency of signal becomes 50,count value is 2000000/50=40000 = $9C3F
	  mov TIM2_CCR2H,#$07    ; compare register set to 2000-1 =1ms =$07CF of count, duty cycle 
	  mov TIM2_CCR2L,#$cf 	 ; duty cycle is either 5% or 95% bassed on polarity (40000/2000)=20, 2000 gives 5%
;	  bset TIM2_CCER1,#5  ; setting polarity bit of timer2 makes ch2 output active low,comment out if need not  
	  mov TIM2_CCMR2,#$60 	; set to PWM mode 1
	  bset TIM2_CCMR2,#3	; OC2PE: Output compare 2 preload enable
	  bset TIM2_CCER1,#4    ; enable chan 2 as output
	  bset TIM2_CR1,#7		; auto preload enable
	  bset TIM2_CR1,#0      ; set CEN bit to enable the timer
	  
setup						; timer4 setup for delay 1ms base timer
	  bset PD_DDR,#5
	  bset PD_ODR,#5
	  mov TIM4_PSCR,#$07	; select timer 4 prescaler to 128, 7 means 2^7=128
	  mov TIM4_ARR,#124	; 16mhz/128=125000 =1s,125000/1000=125,load 125-1 as 0 is counted=124
	  bset TIM4_IER,#0	; enable update interrupt in interrupt register
	  bset TIM4_CR1,#0	; enable timer4
	  rim				; enable interrupt globally	  



here
	mov buffer2,#6	; array counter
	ldw X,#value	; pointer to array label "value" ,address is loaded in X
	
delay_loop
	ld a,buffer1	; copy buffer 1 value to reg A
	cp a,#250		; compare A to 250 ,has it reached 250ms??
	jrne delay_loop	; if not wait in loop
	clr buffer1		; clear buffer so that next loop starts at 0
	bcpl PD_ODR,#5	; toggle led on PD5 to indicate timer4 is working
loop
	ld a,(x)		; load pwm high byte from array to a
	ld TIM2_CCR2H,a	; load a to capture compare register high , strictly follow sequence
	incw X			; increase pointer to next byte
	ld a,(x)		; load a with low byte of the 16 bit PWM value from address in X
	ld TIM2_CCR2L,a	; load a to capture compare register low,strictly follow sequence	incw x			; increase pointer
	dec buffer2		; decrease array counter
	jreq here		; if array counter reach 0 jump to label "here"to reload
	jp delay_loop	; if array counter not 0 loop through array till counter is 0
;	
;	
;value dc.b  $03,$83,$03,$E7,$07,$cf,$09,$5f,$0a,$27,$0a,$b7,$0c,$7f,$0d ;PWM values array
;value1 dc.b $47,$0e,$0f,$0e,$d7,$0f,$9f,$13,$87   							; PWM values array
value dc.b  $03,$83,$03,$83,$03,$83,$13,$87,$13,$87,$13,$87 ;PWM values array $0383 = -90degree,$1387 =+90 degree



	Interrupt timer4_ISR
timer4_ISR
	bres TIM4_SR,#0	; clear update interrupt flag
	inc buffer1		; increase buffer1 by 1 count every 1ms
	iret			; return from interrupt

	
	
	
	interrupt NonHandledInterrupt
NonHandledInterrupt.l
	iret

	segment 'vectit'
	dc.l {$82000000+main}									; reset
	dc.l {$82000000+NonHandledInterrupt}	; trap
	dc.l {$82000000+NonHandledInterrupt}	; irq0
	dc.l {$82000000+NonHandledInterrupt}	; irq1
	dc.l {$82000000+NonHandledInterrupt}	; irq2
	dc.l {$82000000+NonHandledInterrupt}	; irq3
	dc.l {$82000000+NonHandledInterrupt}	; irq4
	dc.l {$82000000+NonHandledInterrupt}	; irq5
	dc.l {$82000000+NonHandledInterrupt}	; irq6
	dc.l {$82000000+NonHandledInterrupt}	; irq7
	dc.l {$82000000+NonHandledInterrupt}	; irq8
	dc.l {$82000000+NonHandledInterrupt}	; irq9
	dc.l {$82000000+NonHandledInterrupt}	; irq10
	dc.l {$82000000+NonHandledInterrupt}	; irq11
	dc.l {$82000000+NonHandledInterrupt}	; irq12
	dc.l {$82000000+NonHandledInterrupt}	; irq13
	dc.l {$82000000+NonHandledInterrupt}	; irq14
	dc.l {$82000000+NonHandledInterrupt}	; irq15
	dc.l {$82000000+NonHandledInterrupt}	; irq16
	dc.l {$82000000+NonHandledInterrupt}	; irq17
	dc.l {$82000000+NonHandledInterrupt}	; irq18
	dc.l {$82000000+NonHandledInterrupt}	; irq19
	dc.l {$82000000+NonHandledInterrupt}	; irq20
	dc.l {$82000000+NonHandledInterrupt}	; irq21
	dc.l {$82000000+NonHandledInterrupt}	; irq22
;	dc.l {$82000000+NonHandledInterrupt}	; irq23
	dc.l {$82000000+timer4_ISR}	; irq23
	dc.l {$82000000+NonHandledInterrupt}	; irq24
	dc.l {$82000000+NonHandledInterrupt}	; irq25
	dc.l {$82000000+NonHandledInterrupt}	; irq26
	dc.l {$82000000+NonHandledInterrupt}	; irq27
	dc.l {$82000000+NonHandledInterrupt}	; irq28
	dc.l {$82000000+NonHandledInterrupt}	; irq29

	end
