#make_bin#

#LOAD_SEGMENT=FFFFh#
#LOAD_OFFSET=0000h#

#CS=0000h#
#IP=0000h#

#DS=0000h#
#ES=0000h#

#SS=0000h#
#SP=FFFEh#

#AX=0000h#
#BX=0000h#
#CX=0000h#
#DX=0000h#
#SI=0000h#
#DI=0000h#
#BP=0000h#

;jump to the start of the code - reset address is kept at 0000:0000
;as this is only a limited simulation
        jmp     st1
;jmp st1 - takes 3 bytes followed by nop that is 4 bytes
        nop                                                        

;int 1  not used so ip and cs initialised to 0000

        dw      0000
        dw      0000
                  
;STOP used as nmi 

        dw      nmi_isr
        dw      0000    
        
;int 3 to 255 unused so fill them with 0000
        db      1012 dup(0)
;main program

st1:    cli               
; intialize ds, es,ss to start of RAM
        mov     ax,0200h
        mov     ds,ax
        mov     es,ax
        mov     ss,ax
        mov     sp,0FFFEH
        mov     si,0000

;initialisation
;8255
        mov     al,10000010b    ;A and C output, B input
        out     06h,al
        
;8254
        mov     al,00000100b    ;Counter 0
        out     0eh,al
        mov     al,01110000b    ;Counter 1
        out     0eh,al
        mov     al,10111010b    ;Counter 2
        out     0eh,al  
               
;Beginning of code

        mov     al,11111111b    ;Turning off all LEDs in the beginning
        out     04h,al
        mov     al,10000000b
        out     00h,al 
        
        ;starting counter 0 
        mov     al,50h             
        out     08h,al
        mov     al,49h
        out     08h,al
        
        mov     dx,00           ;Storing LED count 

       ;call    delay1
       
xstr:   in      al,02h
        cmp     al,0FFh
        jz      xstr   
        call    start
        
;LED lighting code
        mov     al,00h
        out     00h,al
        inc     dx
        call    delay1
        
        mov     al,11111110b
        out     04h,al 
        inc     dx
        call    delay1
        
        mov     al,11111100b
        out     04h,al
        inc     dx
        call    delay1 
        
        mov     al,11111000b
        out     04h,al
        inc     dx
        call    delay1   
        
        mov     al,11110000b
        out     04h,al
        inc     dx
        call    delay1 
        
        mov     al,11100000b
        out     04h,al
        inc     dx
        call    delay1
        
        mov     al,11000000b
        out     04h,al 
        inc     dx
        call    delay1 
        
        mov     al,10000000b
        out     04h,al
        inc     dx
        call    delay1  
        
        mov     al,00000000b
        inc     dx
        out     04h,al 
        
        call    nmi_isr 
        
;End with infinite loop 
xnop:   nop
        jmp     xnop  

        
delay1:                     
        mov     cx,12000;   roughly a 120ms delay - for demonstration         
xd1:    dec     cx 
        jnz     xd1
        ret  
        
start:  

        ;get random number                      
        mov     al,00h
        out     0Eh,al
        in      al,08h
        mov     bl,al
        in      al,08h
        mov     bh,al
          
        ;4 second delay
        mov     al,8
xm:     mov     cx,50000 ; delay generated will be approx 0.45 secs
xn:		loop    xn
        dec     al
        jnz     xm 
        
        ;produce random delay
        mov     al,2                   
xo:     mov     cx,bx  
xp:     loop    xp
        dec     al
        jnz     xo
        
        ret
                
nmi_isr: 
        ;Checking for cheating
        
        cmp     dx,0
        jnz     nocht
        
        ;Blink LEDs
        
        mov     al,00h    
        out     04h,al
        mov     al,00h
        out     00h,al
        
        mov     cx,20000
xd2:    dec     cx
        jnz     xd2 
        
        mov     al,0FFh    
        out     04h,al
        mov     al,80h
        out     00h,al
        
        mov     cx,20000
xd3:    dec     cx
        jnz     xd3
        
        mov     al,00h    
        out     04h,al
        mov     al,00h
        out     00h,al 
        
        mov     cx,20000
xd4:    dec     cx
        jnz     xd4 
        
        mov     al,0FFh    
        out     04h,al
        mov     al,80h
        out     00h,al
        
        mov     cx,20000
xd5:    dec     cx
        jnz     xd5
        
        mov     al,00h    
        out     04h,al
        mov     al,00h
        out     00h,al
        
        mov     cx,20000
xd6:    dec     cx
        jnz     xd6 
        
        mov     al,0FFh    
        out     04h,al
        mov     al,80h
        out     00h,al     
        
        jmp     xstr
        
nocht:  mov     bl,0
        cmp     dx,9
        jnz     eig
        mov     bl,1
        jmp     disp 
        
eig:    cmp     dx,8
        jnz     sev
        mov     bl,2
        jmp     disp
        
sev:    cmp     dx,7
        jnz     six
        mov     bl,2
        jmp     disp
        
six:    cmp     dx,6
        jnz     fiv
        mov     bl,3
        jmp     disp 
        
fiv:    cmp     dx,5
        jnz     fou
        mov     bl,3
        jmp     disp 
        
fou:    cmp     dx,4
        jnz     thr
        mov     bl,4
        jmp     disp 
        
thr:    cmp     dx,3
        jnz     two
        mov     bl,4
        jmp     disp
        
two:    cmp     dx,2
        jnz     one
        mov     bl,5
        jmp     disp
        
one:    mov     bl,5
        jmp     disp
        
disp:   mov     al,bl
        out     00h,al     
    
xend:   nop                 
        jmp     xend
     
        iret
