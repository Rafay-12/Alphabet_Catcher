[org 0x0100]
jmp start

boxloc:  dw 3120
rand: dw 0
randnum: dw 0
alpha: db 'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','v','w','x','y','z'
fail : dw 0
oldisr: dd 0
oldisr1: dd 0
tickcount: dw 0 
tickcount1: dw 0 
tickcount2: dw 0 
tickcount3: dw 0 
tickcount4: dw 0 
tickcount5: dw 0 
loc: dw 0,0,0,0,0,0
selectalpha: db 0,0,0,0,0,0
score: dw 0 
checkflag1: dw 0
checkflag2: dw 0
checkflag3: dw 0
checkflag4: dw 0
checkflag5: dw 0
checkflag6: dw 0
regen: dw 0
msg: db 'Score:',0
msg1: db 'Fail:',0
msg2: db 'Game Over',0
msg3: db 'Your Score is:',0

clrscr1: 
push es
push ax
push cx
push di
mov ax, 0xb800
mov es, ax ; point es to video base
xor di, di ; point di to top left column
mov ax, 0x0720 ; space char in normal attribute
mov cx, 2000 ; number of screen locations
cld ; auto increment mode
rep stosw ; clear the whole screen
pop di
pop cx
pop ax
pop es
ret

clrscr: 
push es
push ax
push cx
push di
mov ax, 0xb800
mov es, ax ; point es to video base
xor di, di ; point di to top left column
mov ax, 0x1f20 ; space char in normal attribute
mov cx, 2000 ; number of screen locations
cld ; auto increment mode
rep stosw ; clear the whole screen
pop di
pop cx
pop ax
pop es
ret

printstr: 
push bp
mov bp, sp
push es
push ax
push cx
push si
push di
push ds
pop es ; load ds in es
mov di, [bp+4] ; point di to string
mov cx, 0xffff ; load maximum number in cx
xor al, al ; load a zero in al
repne scasb ; find zero in the string
mov ax, 0xffff ; load maximum number in ax
sub ax, cx ; find change in cx
dec ax ; exclude null from length
jz exit22 ; no printing if string is empty
mov cx, ax ; load string length in cx
mov ax, 0xb800
mov es, ax ; point es to video base
mov al, 80 ; load al with columns per row
mul byte [bp+8] ; multiply with y position
add ax, [bp+10] ; add x position
shl ax, 1 ; turn into byte offset
mov di,ax ; point di to required location
mov si, [bp+4] ; point si to string
mov ah, [bp+6] ; load attribute in ah
cld ; auto increment mode
nextchar: 
lodsb ; load next char in al
stosw ; print char/attribute pair
loop nextchar ; repeat for the whole string
exit22: 
pop di
pop si
pop cx
pop ax
pop es
pop bp
ret 8 
 
printscore: 
push bp
mov bp, sp
push es
push ax
push bx
push cx
push dx
push di
mov ax, 0xb800
mov es, ax ; point es to video base
mov ax, [bp+4] ; load number in ax
mov bx, 10 ; use base 10 for division
mov cx, 0 ; initialize count of digits
nextdigit: 
mov dx, 0 ; zero upper half of dividend
div bx ; divide by 10
add dl, 0x30 ; convert digit into ascii value
push dx ; save ascii value on stack
inc cx ; increment count of values
cmp ax, 0 ; is the quotient zero
jnz nextdigit ; if no divide it again
mov di, 174
nextpos: 
pop dx ; remove a digit from the stack
mov dh, 0x1A
mov [es:di], dx ; print char on screen
add di, 2 ; move to next screen location
loop nextpos ; repeat for all digits on stack
pop di
pop dx
pop cx
pop bx
pop ax
pop es
pop bp
ret 2 

printfail: 
push bp
mov bp, sp
push es
push ax
push bx
push cx
push dx
push di
mov ax, 0xb800
mov es, ax ; point es to video base
mov ax, [bp+4] ; load number in ax
mov bx, 10 ; use base 10 for division
mov cx, 0 ; initialize count of digits
nextdigit1: 
mov dx, 0 ; zero upper half of dividend
div bx ; divide by 10
add dl, 0x30 ; convert digit into ascii value
push dx ; save ascii value on stack
inc cx ; increment count of values
cmp ax, 0 ; is the quotient zero
jnz nextdigit1 ; if no divide it again
mov di, 12
nextpos1: 
pop dx ; remove a digit from the stack
mov dh, 0x14
mov [es:di], dx ; print char on screen
add di, 2 ; move to next screen location
loop nextpos1 ; repeat for all digits on stack
pop di
pop dx
pop cx
pop bx
pop ax
pop es
pop bp
ret 2

printnum: 
push bp
mov bp, sp
push es
push ax
push bx
push cx
push dx
push di
mov ax, 0xb800
mov es, ax ; point es to video base
mov ax, [bp+4] ; load number in ax
mov bx, 10 ; use base 10 for division
mov cx, 0 ; initialize count of digits
nextdigit2: 
mov dx, 0 ; zero upper half of dividend
div bx ; divide by 10
add dl, 0x30 ; convert digit into ascii value
push dx ; save ascii value on stack
inc cx ; increment count of values
cmp ax, 0 ; is the quotient zero
jnz nextdigit2 ; if no divide it again
mov di, 2010
nextpos2: 
pop dx ; remove a digit from the stack
mov dh, 0x0A
mov [es:di], dx ; print char on screen
add di, 2 ; move to next screen location
loop nextpos2 ; repeat for all digits on stack
pop di
pop dx
pop cx
pop bx
pop ax
pop es
pop bp
ret 2 

; taking n as parameter, generate random number from 0 to n nad return in the stack
randG:
push bp
mov bp, sp
pusha
cmp word [rand], 0
jne next
MOV AH, 00h   ; interrupt to get system timer in CX:DX 
INT 1AH
inc word [rand]
mov [randnum], dx
jmp next1
next:
mov ax, 25173          ; LCG Multiplier
mul word  [randnum]     ; DX:AX = LCG multiplier * seed
add ax, 13849          ; Add LCG increment value
;Modulo 65536, AX = (multiplier*seed+increment) mod 65536
mov [randnum], ax          ; Update seed = return value
next1:
xor dx, dx
mov ax, [randnum]
mov cx, [bp+4]
inc cx
div cx
mov [bp+6], dx
popa
pop bp
ret 2
 
generaterandom:
push bp
mov bp,sp
pusha

mov word [checkflag1],0
mov word [checkflag2],0
mov word [checkflag3],0
mov word [checkflag4],0
mov word [checkflag5],0
mov word [checkflag6],0

mov word [tickcount],0
mov word [tickcount1],0
mov word [tickcount2],0
mov word [tickcount3],0
mov word [tickcount4],0
mov word [tickcount5],0

mov ax,0xb800
mov es,ax
mov cx,6
mov di,482
mov si,0

loopa:

sub sp, 2
push 25
call randG
pop bx

add di,[bp+4]

mov ah,0x1E
mov al,[alpha+bx]
mov word [es:di],ax
mov byte [selectalpha+si],al
add si,1
loop loopa

mov cx,6
mov di,482
mov si,0
loopb:

add di,[bp+4]
mov word [loc + si],di
add si,2

loop loopb

popa
pop bp
ret 2

move1:
pusha

mov ax,0xb800
mov es,ax
mov di,[loc]


mov word [es:di],0x1f20
cmp di,3198
ja fail1
cmp di,[boxloc]
je score1

add di,160
mov word [loc],di

mov ah,0x1e
mov al,[selectalpha]
mov word [es:di],ax
jmp exit10

fail1:
mov word [checkflag1],1
add word [fail],1
add word [regen],1
jmp exit10

score1:
mov word [checkflag1],1
mov word [es:di],0x1fdc
add word [score],1
add word [regen],1

exit10:
popa
ret

move2:
pusha

mov ax,0xb800
mov es,ax
mov di,[loc + 2]

mov word [es:di],0x1f20

cmp di,3198
ja fail2
cmp di,[boxloc]
je score2

add di,160
mov word [loc + 2],di

mov al,[selectalpha + 1]
mov ah,0x1e
mov word [es:di],ax
jmp exit11

fail2:
mov word [checkflag2],1
add word [fail],1
add word [regen],1
jmp exit11

score2:
mov word [checkflag2],1
mov word [es:di],0x1fdc
add word [score],1
add word [regen],1


exit11:
popa
ret

move3:
pusha

mov ax,0xb800
mov es,ax
mov di,[loc + 4]

mov word [es:di],0x1f20

cmp di,3198
ja fail3
cmp di,[boxloc]
je score3

add di,160
mov word [loc + 4],di

mov al,[selectalpha + 2]
mov ah,0x1e
mov word [es:di],ax
jmp exit12

fail3:
mov word [checkflag3],1
add word [fail],1
add word [regen],1
jmp exit12

score3:
mov word [checkflag3],1
mov word [es:di],0x1fdc
add word [score],1
add word [regen],1

exit12:
popa
ret

move4:
pusha

mov ax,0xb800
mov es,ax
mov di,[loc + 6]

mov word [es:di],0x1f20

cmp di,3198
ja fail4
cmp di,[boxloc]
je score4

add di,160
mov word [loc + 6],di

mov al,[selectalpha + 3]
mov ah,0x1e
mov word [es:di],ax
jmp exit13

fail4:
mov word [checkflag4],1
add word [fail],1
add word [regen],1
jmp exit13

score4:
mov word [checkflag4],1
mov word [es:di],0x1fdc
add word [score],1
add word [regen],1

exit13
popa
ret

move5:
pusha

mov ax,0xb800
mov es,ax
mov di,[loc + 8]

mov word [es:di],0x1f20

cmp di,3198
ja fail5
cmp di,[boxloc]
je score5

add di,160
mov word [loc + 8],di

mov ah,0x1e
mov al,[selectalpha + 4]
mov word [es:di],ax


jmp exit14

fail5:
mov word [checkflag5],1
add word [fail],1
add word [regen],1
jmp exit14

score5:
mov word [checkflag5],1
mov word [es:di],0x1fdc
add word [score],1
add word [regen],1

exit14:
popa
ret

move6:
pusha

mov ax,0xb800
mov es,ax
mov di,[loc + 10]

mov word [es:di],0x1f20

cmp di,3198
ja fail6
cmp di,[boxloc]
je score6

add di,160
mov word [loc + 10],di

mov ah,0x1e
mov al,[selectalpha + 5]
mov word [es:di],ax


jmp exit15

fail6:
mov word [checkflag6],1
add word [fail],1
add word [regen],1
jmp exit15

score6:
mov word [checkflag6],1
mov word [es:di],0x1fdc
add word [score],1
add word [regen],1

exit15:
popa
ret

box:
push ax
push es
push di

mov di, 3120
mov ax,0xb800
mov es,ax
mov word [es:di],0x1fdc

pop di
pop es
pop ax
ret

left:
push ax
push es
push di

boxloca:
mov ax, 0xb800
mov es, ax ; point es to video memory
mov di,word [boxloc]

dis1:
cmp di,3040
je border1
mov word [es:di], 0x1f20 ; clear previous box
sub di,2
mov word [es:di], 0x1fdc ; print new box
mov word [boxloc],di
jmp exit1

border1:
add di,2
jmp dis1

exit1:
pop di
pop es
pop ax
ret


right:
push ax
push es
push di

boxloca1:
mov ax, 0xb800
mov es, ax ; point es to video memory
mov di,word [boxloc]

dis:
cmp di,3198
je border
mov word [es:di], 0x1f20 ; clear previous box
add di,2
mov word [es:di], 0x1fdc ; print new box
mov word [boxloc],di
jmp exit2

border:
sub di,2
jmp dis

exit2:
pop di
pop es
pop ax
ret


kbisr: 
push ax
in al, 0x60 ; read a char from keyboard port

cmp al, 0x4b ; has the left key pressed
jne nextcmp ; no, try next comparison

call left

jmp exit ; leave interrupt routine

nextcmp: 
cmp al, 0x4d ; has the right key pressed
jne exit ; no, jump to no match

call right

exit: 
mov al, 0x20
out 0x20, al ; send EOI to PIC
pop ax
jmp far [cs:oldisr] 
iret ; return from interrupt

timer: 
push ax

inc word [cs:tickcount]
cmp word [cs:tickcount],11
jne nextcmp1
cmp word [cs:checkflag1],0
jne nextcmp1
mov word [cs:tickcount],0
call move1
jmp skip

nextcmp1:
inc word [cs:tickcount1]
cmp word [cs:tickcount1],9
jne nextcmp2
cmp word [cs:checkflag2],0
jne nextcmp2
mov word [cs:tickcount1],0
call move2
jmp skip

nextcmp2:
inc word [cs:tickcount2]
cmp word [cs:tickcount2],7
jne nextcmp3
cmp word [cs:checkflag3],0
jne nextcmp3
mov word [cs:tickcount2],0
call move3
jmp skip

nextcmp3:
inc word [cs:tickcount3]
cmp word [cs:tickcount3],4
jne nextcmp4
cmp word [cs:checkflag4],0
jne nextcmp4
mov word [cs:tickcount3],0
call move4
jmp skip

nextcmp4:
inc word [cs:tickcount4]
cmp word [cs:tickcount4],6
jne nextcmp5
cmp word [cs:checkflag5],0
jne nextcmp5
mov word [cs:tickcount4],0
call move5
jmp skip

nextcmp5:
inc word [cs:tickcount5]
cmp word [cs:tickcount5],8
jne skip
cmp word [cs:checkflag6],0
jne skip
mov word [cs:tickcount5],0
call move6


skip:
mov al, 0x20
out 0x20, al ; end of interrupt
pop ax
iret ; return from interrupt

start: 

call clrscr
mov ax,30
push ax
call generaterandom
call box

mov ax, 0
push ax ; push x position
mov ax, 0
push ax ; push y position
mov ax, 0x14 
push ax ; push attribute
mov ax, msg1
push ax ; push address of message
call printstr 

mov ax, 0
push ax ; push x position
mov ax, 1
push ax ; push y position
mov ax, 0x1A 
push ax ; push attribute
mov ax, msg
push ax ; push address of message
call printstr 

xor ax, ax
mov es, ax ; point es to IVT base

mov ax, [es:9*4]
mov [oldisr], ax ; save offset of old routine
mov ax, [es:9*4+2]
mov [oldisr+2], ax ; save segment of old routine

mov ax, [es:8*4]
mov [oldisr1], ax ; save offset of old routine
mov ax, [es:8*4+2]
mov [oldisr1+2], ax

cli ; disable interrupts
mov word [es:9*4], kbisr ; store offset at n*4
mov [es:9*4+2], cs ; store segment at n*4+2
mov word [es:8*4], timer; store offset at n*4
mov [es:8*4+2], cs ; store segment at n*4+2
sti ; enable interrupts

mov ax,20
jmp l1

l2:
add ax,4
push ax
call generaterandom
mov word [regen],0

l1:
push word [fail]
call printfail
push word [score]
call printscore
cmp word [regen],6
je l2
cmp word [fail],10
jne l1

call clrscr1
mov ax, 34
push ax ; push x position
mov ax, 10
push ax ; push y position
mov ax, 0x01 ; blue on black attribute
push ax ; push attribute
mov ax, msg2
push ax ; push address of message
call printstr 

mov ax, 30
push ax ; push x position
mov ax, 12
push ax ; push y position
mov ax, 0x0A 
push ax ; push attribute
mov ax, msg3
push ax ; push address of message
call printstr 

push word [score]
call printnum

xor ax, ax
mov es, ax 

mov ax, [oldisr] ; read old offset in ax
mov bx, [oldisr+2] ; read old segment in bx
cli ; disable interrupts
mov [es:9*4], ax ; restore old offset from ax
mov [es:9*4+2], bx ; restore old segment from bx
sti 

mov ax, [oldisr1] ; read old offset in ax
mov bx, [oldisr1+2] ; read old segment in bx
cli ; disable interrupts
mov [es:8*4], ax ; restore old offset from ax
mov [es:8*4+2], bx ; restore old segment from bx
sti 
 
mov dx, start ; end of resident portion
add dx, 15 ; round up to next para
mov cl, 4
shr dx, cl ; number of paras
mov ax, 0x3100 ; terminate and stay resident
int 0x21 