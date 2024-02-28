.org 0x0
	rjmp start
.org 0x2
	rjmp button1
.org 0x4
	rjmp button2


start:

; THIS IS SETUP CODE.  DON'T CHANGE IT

	; set up stack
	ldi r16,LOW(RAMEND)
	out SPL,r16
	ldi r16,HIGH(RAMEND)
	out SPH,r16

	; set up the display
	call ledinit

	; a 0->5v on pin 2 will now cause button1 to run
	call setup_button_interrupt

	; set index register Y to 0x100 memory
	ldi r28,LOW(0x100)
	ldi r29,HIGH(0x100)



	; recommended variables:
	;  Y+0 (100): snake head dx
	;  Y+1 (101): snake head dy
	;  Y+2 (102): apple x
	;  Y+3 (103): apple y
	;  Y+4 (104): button press count for random?
	;  Y+5 (105): delay
	;  Y+6 (106): snake size
	;  Y+10 (110): snake head x
	;  Y+11 (111): snake head y
	;  Y+12, Y+13, Y+14, Y+15 ...  snake body x and y

; YOUR SETUP CODE GOES HERE

	
	ldi r16, 1		; initialize dx to 1
	std Y+0, r16   ; store dx value at Y+0
	ldi r16, 0		; initialize dy to 0
	std Y+1, r16   ; store dy value at Y+1

	;head_snake
	ldi r16, 2      ; initialize x to 2
	std Y+10, r16   ; store x value at Y+10
	ldi r16, 5      ; initialize y to 2
	std Y+11, r16   ; store y value at Y+11

	;middle_snake
	ldi r16, 1      ; initialize x to 1
	std Y+12, r16   ; store x value at Y+12
	ldi r16, 5      ; initialize y to 2
	std Y+13, r16   ; store y value at Y+13

	;tail_snake
	ldi r16, 0      ; initialize x to 0
	std Y+14, r16   ; store x value at Y+14
	ldi r16, 5      ; initialize y to 2
	std Y+15, r16   ; store y value at Y+15

	; Turn on pixel at (x,y)
    ldd r20, Y+10   ; load x from Y+10 into r20
    ldd r21, Y+11   ; load y from Y+11 into r21
    ldi r16, 1      ; set pixel on
    call setpixel

	ldd r20, Y+12   ; load x from Y+12 into r20
    ldd r21, Y+13   ; load y from Y+13 into r21
    ldi r16, 1      ; set pixel on
    call setpixel

	ldd r20, Y+14   ; load x from Y+14 into r20
    ldd r21, Y+15   ; load y from Y+15 into r21
    ldi r16, 1      ; set pixel on
    call setpixel

	;initialize apple
	ldi r16, 5      ; initialize apple_x to 1
	std Y+2, r16   ; store apple_x value at Y+2
	ldi r16, 2      ; initialize apple_y to 5
	std Y+3, r16   ; store apple_y value at Y+3

	; turn on apple pixel
	ldd r20, Y+2   
    ldd r21, Y+3   
    ldi r16, 1
    call setpixel

	;middle delay loop
	ldi r16,255
	std Y+5,r16
mainloop:
	
	; turn off tail pixel
	ldd r20, Y+14  
    ldd r21, Y+15   
    ldi r16, 0
    call setpixel

	;head becomes middle
	;middle becomes tail
	ldd r20,Y+12
	std Y+14,r20

	ldd r21,Y+13
	std Y+15,r21

	ldd r20,Y+10
	std Y+12,r20

	ldd r21,Y+11
	std Y+13,r21
		
	; update x and y coordinates
    ldd r20, Y+10 ; load current x
    ldd r21, Y+11 ; load current y
    ldd r22, Y+0  ; load dx
    add r20, r22  ; add dx to x
    ldd r23, Y+1  ; load dy
    add r21, r23  ; add dy to y
    std Y+10, r20 ; store new x
    std Y+11, r21 ; store new y

	; Check for apple eaten or not
	ldd r16, Y+10 ; Load snake's x position
	ldd r17,Y+2
	cp r16, r17 ; Compare with apple x position

	breq apple_eaten_chk1 ; If they're equal, check for y coord!
	

	; check for game over conditions
    cpi r20, 8   ; check if x >= 8
    brge gameover
    cpi r20, 0   ; check if x <= -1
    brlt gameover
    cpi r21, 8   ; check if y >= 8
    brge gameover
    cpi r21, 0   ; check if y <= -1
    brlt gameover
	
	
continueloop:
	; turn on new pixel
	ldd r20, Y+10   
    ldd r21, Y+11   
    ldi r16, 1
    call setpixel
		
	ldd r20, Y+12   
    ldd r21, Y+13   
    ldi r16, 1
    call setpixel

	ldd r20, Y+14   
    ldd r21, Y+15   
    ldi r16, 1
    call setpixel

	; delay for about a second
    ldi r22, 40    ; set up outer loop counter
outerloop:
    ldd r21, Y+5   ; set up middle loop counter
middleloop:
    ldi r20, 255   ; set up inner loop counter
innerloop:
    dec r20        ; decrement inner loop counter
    brne innerloop ; loop if not zero
    dec r21        ; decrement middle loop counter
    brne middleloop; loop if not zero
    dec r22        ; decrement outer loop counter
    brne outerloop ; loop if not zero

	jmp mainloop
apple_eaten_chk1:
	ldd r16, Y+11 ; Load snake's y position
	ldd r17,Y+3
	cp r16, r17 ; Compare with apple y position
	breq apple_eaten
	jmp mainloop
apple_eaten:
; turn off prev apple pixel
	ldd r20, Y+2   
    ldd r21, Y+3   
    ldi r16, 0
    call setpixel

	ldi r16, 23
	add r20,r16      ;applex=applex+23
	andi r20,7 ;applex=applex and 7
	std Y+2,r20

	ldi r16, 29
	add r21,r16      ;appley=appley+29
	andi r21,7 ;appley=appley and 7
	std Y+3,r21

	ldd r20, Y+2  
    ldd r21, Y+3  
    ldi r16, 1 ; turn on new apple
    call setpixel

	;dec middleloop counter by 20
	ldd r16,Y+5
	subi r16,20
	std Y+5,r16

	jmp continueloop
gameover:
	 call fillscreen
	 jmp gameover
button1:
	cli

	; YOUR BUTTON 1 RESPONSE CODE HERE
	push r16
	push r17

	ldd r16,Y+0
	cpi r16,1
	breq move_up
	cpi r16,-1
	breq move_down
	ldd r17,Y+1
	cpi r17,-1
	breq move_left
	cpi r17,1
	breq move_right
b1_done:
	pop r17
	pop r16

	sei
	reti
move_up:
	ldi r16, 0		; initialize dx to 1
	std Y+0, r16   ; store dx value at Y+0
	ldi r16, -1		; initialize dy to 0
	std Y+1, r16   ; store dy value at Y+1
	jmp b1_done
move_down:
	ldi r16, 0		; initialize dx to 1
	std Y+0, r16   ; store dx value at Y+0
	ldi r16, 1		; initialize dy to 0
	std Y+1, r16   ; store dy value at Y+1
	jmp b1_done
move_left:
	ldi r16, -1		; initialize dx to 1
	std Y+0, r16   ; store dx value at Y+0
	ldi r16, 0		; initialize dy to 0
	std Y+1, r16   ; store dy value at Y+1
	jmp b1_done
move_right:
	ldi r16, 1		; initialize dx to 1
	std Y+0, r16   ; store dx value at Y+0
	ldi r16, 0		; initialize dy to 0
	std Y+1, r16   ; store dy value at Y+1
	jmp b1_done

button2:
	cli

	; BUTTON 2 RESPONSE CODE (OPTIONAL)

	sei
	reti

;YOU SHOULD NOT NEED TO MODIFY ANY CODE AFTER THIS POINT

; takes x,y coordinate and sets pixel value
; x in r20, y in r21, pixel on/off (0 or 1) in r16
setpixel:
	push r28
	push r29
	call setdisplayaddress
	st Y,r16
	pop r29
	pop r28
	call ledupdate
	ret

; takes x,y coordinate and returns pixel value
; x in r20, y in r21, returns r16
getpixel:
	push r28
	push r29
	call setdisplayaddress
	ld r16,Y
	pop r29
	pop r28
	ret

	; set up button interrupt
setup_button_interrupt:
	cli
	sbi EIMSK,0
	sbi EIMSK,1
	lds r16,EICRA
	ori r16,0xf
	sts EICRA,r16
	cbi DDRD,2
	cbi DDRD,3
	sei
	ret
fillscreen:
	push r16
	push r20
	push r21
	ldi r16,1
	ldi r20,7
fill_loop1:
	ldi r21,7
fill_loop2:
	call setpixel
	dec r21
	brge fill_loop2
	dec r20
	brge fill_loop1

	pop r21
	pop r20
	pop r16
	ret
	; clear the display
clrscreen:
	push r16
	push r20
	push r21
	ldi r16,0
	ldi r20,7
cls_loop1:
	ldi r21,7
cls_loop2:
	call setpixel
	dec r21
	brge cls_loop2
	dec r20
	brge cls_loop1

	pop r21
	pop r20
	pop r16
	ret

; call at beginning of program to initialize the display
ledinit:
	sbi DDRB,0
	sbi DDRB,1
	sbi DDRB,2
	push r20
	push r22
	ldi r20,0xb	;regscanlimit=7
	ldi r22,7
	call ledwrite
	ldi r20,0x9	;regdecode=0
	ldi r22,0
	call ledwrite
	ldi r20,0xc	;regshutdown=1
	ldi r22,1
	call ledwrite
	ldi r20,0xf	;regdisplaytest=0
	ldi r22,0
	call ledwrite
	ldi r20,0xa	;regintensity=4
	ldi r22,4
	call ledwrite
	; clear all 8 lines
	ldi r22,0
	ldi r20,1
ledinit_clrloop:
	call ledwrite
	inc r20
	cpi r20,9
	brne ledinit_clrloop
	pop r22
	pop r20
	call clrscreen
	ret

; call to read memory from 0x200-0x240 and output to display
ledupdate:
	push r20
	push r21
	push r22

	; r20 is x, r21 is y, r22 is row
	;for x=0 to 8
	ldi r20,0
ledupdate_xloop:
	;row=0
	ldi r22,0
	;for y=0 to 8
	ldi r21,7
ledupdate_yloop:
	; get pixel and shift it into row
	add r22,r22
	push r16
	call getpixel
	add r22,r16
	pop r16

	dec r21
	brge ledupdate_yloop

	inc r20

	; ledwrite(x+1,row)
	call ledwrite

	cpi r20,8
	brne ledupdate_xloop

	pop r22
	pop r21
	pop r20
	ret

; reg in r20, data in r22
ledwrite:
	cbi PORTB,1
	sbi PORTB,1

	push r21
	mov r21,r20
	call ledwrite_sendbyte
	mov r21,r22
	call ledwrite_sendbyte
	pop r21

	cbi PORTB,1
	sbi PORTB,1
	ret

; sends the byte in r21 out to display serially, starting with MSB
ledwrite_sendbyte:
	push r20
	push r22
	ldi r22,0b10000000
ledwrite_sendbyte_loop:
	cbi PORTB,2
	mov r20,r21
	and r20,r22
	cpi r20,0
	breq ledwrite_sendbyte_send0
	sbi PORTB,0
	jmp ledwrite_sendbyte_sent
ledwrite_sendbyte_send0:
	cbi PORTB,0
ledwrite_sendbyte_sent:
	sbi PORTB,2
	lsr r22
	brne ledwrite_sendbyte_loop
	pop r22
	pop r20
	ret

; takes display coordinate x,y in r20,r21, sets Y to address
setdisplayaddress:
	ldi r28,LOW(0x200)
	ldi r29,HIGH(0x200)
	push r22
	push r20
	add r20,r20
	add r20,r20
	add r20,r20
	add r20,r21
	add r28,r20
	pop r20
	pop r22
	ret