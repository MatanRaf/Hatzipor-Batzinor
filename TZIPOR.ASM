; HATZIPOR BATZINOR

; instructions:
; use number keys to select the number of players (1-4) and space to start
; each color bird is controlled by the apropriate key
; y - yellow bird
; r - red bird 
; g - green bird 
; b - blue bird 

; if a bird hits the pipe it loses and stops being drawn 
; once all the birds lose the game ends
; the player who loses last wins


.model small
.stack 100h
.data
;the number of players who are playing
;the default value is 1 but it can be changed at the start of the game
;the max player count is 4
players db 1

;stores the Y value for each bird
;there are 4 values but only the needed values are used, according to the player amount
birdY dw 30,30,30,30

;stores the X value for each pipe
;there are 5 pipes that loop in order to form an illusion of infinite pipes
;the pipes start off evenly spaced
pipeX dw 54, 118, 182, 246, 310

;stores the Y value of the opening for each of the pipes
pipeY dw 20, 30, 40, 50, 60

; the fall velocity for each of the birds
; every frame the pipe velocity gets added to the birds Y value in order to create a falling animation
; the fall velocity can also be negative if the bird is going up
fallVel dw 0,0,0,0

; this makes sure the fall velocity doesnt get too large
maxVel dw 7

; 1 if running 0 if gameover, the function checkLose changes the value
running db 1 

; for each bird: 1 is playing, 0 is not playing
; the first player is playing by default
playing db 1,0,0,0

; an array of random numbers that loops in order to give the pipes a random Y value 
randNums dw 22, 6, 12, 52, 31, 46, 89, 49, 27, 70, 90, 45, 52, 98, 14, 80, 11, 64, 47, 35, 42, 59, 24, 41, 44, 67, 19, 53, 66, 102, 49, 48, 18, 28, 85, 77, 84, 56, 24, 56, 42, 49, 64, 59, 91, 66, 48, 69, 17, 89

; the index of the random numbers
randIndex db 0

; the score
; the score goes up the longer the game is going on
score dw 0

; the string where the score printed out to the screen is stored
scoreString db 'Score: ', 4 dup(0),'$'

; thank you for playing string
; printed at the end of the game
thankString db 10,'Thank You For Playing HATZIPOR BATZINOR$'

; the main color for each one of the 4 birds
; 44 - yellow, 39 - red, 45 - green, 51 - blue
mainColor db 44, 39, 45, 51

; the secondary color for each one of the 4 birds
; 43 - yellow, 40 - red, 47 - green, 53 - blue
secondColor db	43, 40, 47, 53

; the button that makes each bird jump
; the button is the first letter of each color
jumpButton db 'y','r','g','b'

.code
;clears the screen
proc cls
	mov cx,320*200
	mov di, 0
	mov dl, 11 ;sky color

	clearLoop: call drawPixel
	loop clearLoop
	ret
cls endp

;draws the screen
;this proc is called every frame in order to show the changes that were made to the birds and the pipes
proc drawScreen
call cls ;clears the screen
call drawPipes ;draws the pipes
call drawBirds ; draws the birds
call drawScore ; draws the score in the top right corner
ret
drawScreen endp

; draws the score
proc drawScore
; make the string 
mov ax,score
mov di,10
mov cx,4
mov bl,10
scoreStringLoop: 
div bl ;remainder at ah
add ah,30h
mov scoreString[di],ah
mov ah,0
dec di
loop scoreStringLoop
; move the cursor to the correct location
mov dh, 0 ; row
mov dl, 69 ; width (80) - scoreString length (7 char("Score: ") + 4 digits)
mov ah,2
mov al,0
mov bx,0
int 10h
mov dx,offset scoreString
mov ah,9
int 21h
ret
drawScore endp

;draws the opening screen
;the opening screen consists of a large orange rectangle on it the number of players, and a play triangle
proc drawOpening
call drawOpeningRect
call drawPlayTriangle
call drawPlayerAmount
ret
drawOpening endp

;a small square that has the players color is drawn in order to indicate that the player is playing
;this proc decides how many squares to draw by looking at the player amount
proc drawPlayerAmount
mov al, players
cmp al, 1
je drawOnePlayer
cmp al, 2
je drawTwoPlayer
cmp al, 3
je drawThreePlayer
cmp al, 4
je drawFourPlayer

drawOnePlayer:
call drawYplayer
jmp donedrawingamount

drawTwoPlayer:
call drawYplayer
call drawRplayer
jmp donedrawingamount

drawThreePlayer:
call drawYplayer
call drawRplayer
call drawGplayer
jmp donedrawingamount

drawFourPlayer:
call drawYplayer
call drawRplayer
call drawGplayer
call drawBplayer
jmp donedrawingamount

donedrawingamount:

ret
drawPlayerAmount endp


; indicates the yellow player
proc drawYplayer

mov di, 104
add di, 130*320
mov dl, 44 ; yellow
call indicatePlayer

ret
drawYplayer endp

; indicates the red player
proc drawRplayer

mov di, 138
add di, 130*320
mov dl, 4 ; red
call indicatePlayer

ret
drawRplayer endp

; indicates the blue player
proc drawBplayer

mov di, 206
add di, 130*320
mov dl, 1 ; blue
call indicatePlayer

ret
drawBplayer endp

; indicates the green player
proc drawGplayer

mov di, 172
add di, 130*320
mov dl, 2 ; green
call indicatePlayer

ret
drawGplayer endp

; indicates a player by drawing a square in his color on the opening screen
proc indicatePlayer

mov cx, 10
indicatePlayerRow: push cx
mov cx, 10
indicatePlayerPixel:
call drawPixel
loop indicatePlayerPixel
add di, 310
pop cx
loop indicatePlayerRow

ret
indicatePlayer endp

;draws the play triangle
proc drawPlayTriangle
;draws the top half of the triangle
mov di, 150
add di, 80*320
mov dl, 0fh ; white color
mov cx, 20
playTriangleTopRow: push cx
mov ax, cx
mov cx, 21
sub cx, ax
mov ax, cx
playTriangleTopPixel:
call drawPixel
loop playTriangleTopPixel
;draws the bottom half of the triangle
add di, 320
sub di, ax
pop cx
loop playTriangleTopRow
mov cx, 20
playTriangleBottomRow: push cx
mov ax, cx
playTriangleBottomPixel:
call drawPixel
loop playTriangleBottomPixel
add di, 320
sub di, ax
pop cx
loop playTriangleBottomRow

ret
drawPlayTriangle endp

; in the beginning of the game, a large orange rectangle is drawn in the middle of the screen
; this proc is in charge of drawing the rectangle
proc drawOpeningRect
mov cx, 100
mov dl, 42 ; orange color
mov di, 80
add di, 50*320
orangeRectRow: push cx
mov cx, 160
orangeRectPixel:
call drawPixel
loop orangeRectPixel
add di, 320-160 ; goes down a row
pop cx
loop orangeRectRow

ret
drawOpeningRect endp

proc drawPixel
	mov [es:di], dl
	inc di
	ret
drawPixel endp

;moves each pipe left
proc movePipes
	mov cx, 5
	mov si, 0
	lea bx, pipeX
	movePipe: mov al, [bx]
	inc bx
	mov ah, [bx]
	dec bx
	sub ax, 2
	push bx
	cmp ax,0
	jne notEnd
	call returnPipe
	call addPoint ; the score increases
	notEnd: pop bx
	mov [bx],al
	inc bx
	mov [bx],ah
	inc bx
	inc si
	loop movePipe
	ret
movePipes endp

; moves the pipe back to the beginning and gives it a random height
proc returnPipe
	call rand ; ax equals random number in range (0-109)
	lea bx, pipeY
	add bx, si
	add bx, si
	add ax, 25
	mov [bx], al
	inc bx
	mov [bx], ah
	mov ax,310
	ret
returnPipe endp

; random number generator 0 - 109
proc rand
	lea bx, randNums
	mov ax, 0
	mov al, randIndex
	add bx, ax
	add ax, 2
	cmp ax, 98
	jne noChange
	sub bx,ax
	mov ax, 0
	
	noChange:
	mov randIndex, al
	mov ax,[bx]
	ret
rand endp

; increase the score by 1 points
proc addPoint
	push ax
	mov ax, score
	inc ax
	mov score, ax
	pop ax
	ret
addPoint endp

; draws the pipes on the screen
proc drawPipes
	mov cx, 5 ; there are five pipes
	mov si, 0

	drawPipe: push cx
	mov ax,pipeY[si] ; Y coord
	mov bx,pipeX[si] ; X coord
	mov cx,320
	mul cx; multiply AX by 320 (cx value)
	add ax,bx ; and add X
	mov di,ax
	mov dl,10 ; green color


	mov cx, pipeY[si] ;give cx the height of the top half
	heightLoopTop: push cx
	mov cx, 20
	widthLoopTop:
	call drawPixel
	loop widthLoopTop
	sub di, 340
	pop cx
	loop heightLoopTop
	mov di, ax
	add di, 60*320
	mov bx, pipeY[si]
	add bx, 60
	mov cx, 200
	sub cx, bx ;give cx height of the bottom half
	heightLoopBottom: push cx
	mov cx, 20
	widthLoopBottom:
	call drawPixel
	loop widthLoopBottom
	add di, 300
	pop cx
	loop heightLoopBottom

	add si,2
	pop cx
	loop drawPipe
	ret
drawPipes endp

;moves all the playing birds
proc moveBirds
	mov cx, 0
	mov cl, players
	mov si, 0
	mov di, 0
	moveSingle:
	cmp playing[si], 0
	je notmove
	call moveBird
	notmove:
	inc si
	add di, 2
	loop moveSingle

ret
moveBirds endp

;moves the bird according to its fall velocity
proc moveBird
	mov ax, birdY[di]
	mov bx, fallVel[di]
	mov dx, maxVel
	cmp dx, bx
	jg usual
	mov bx, dx
	usual:
	add ax, bx
	mov birdY[di], ax
	inc bx
	mov fallVel[di], bx
	ret
moveBird endp

;draws all the playing birds
proc drawBirds
	mov cx, 0
	mov cl, players
	mov si, 0
	singleBird:
	cmp playing[si], 0
	je notPlaying
	call drawBird
	notPlaying:
	inc si
	loop singleBird
ret
drawBirds endp

;draws bird pixel art manually
;this is very long but it cannot be put in a loop because the pixels have no order
proc drawBird
	mov di, si
	add si, di
	mov ax, birdY[si]
	sub si, di
	mov bx, 320
	mul bx
	add ax, 40 ; distance from left side of the screen
	mov di, ax
	add di, 6
	mov dl, 0 ; black color
	call drawPixel
	call drawPixel
	call drawPixel
	call drawPixel
	call drawPixel
	mov [es:di], dl;end of row 1
	mov di, ax
	add di, 320
	add di, 4
	call drawPixel
	call drawPixel
	mov dl, mainColor[si]
	call drawPixel
	call drawPixel
	call drawPixel
	call drawPixel
	mov dl, 0 ; black color
	call drawPixel
	mov dl, 15 ; white color
	call drawPixel
	mov dl, 0 ; black color
	mov [es:di], dl ; end of row 2
	mov di, ax
	add di, 320*2
	add di, 3
	call drawPixel
	mov dl, mainColor[si]
	call drawPixel
	call drawPixel
	call drawPixel
	call drawPixel
	call drawPixel
	mov dl, 0 ; black color
	call drawPixel
	mov dl, 15 ; white color
	call drawPixel
	call drawPixel
	call drawPixel
	mov dl, 0 ; black color
	mov [es:di], dl ; end of row 3
	mov di, ax
	add di, 320*3
	inc di
	call drawPixel
	call drawPixel
	call drawPixel
	call drawPixel
	mov dl, mainColor[si]
	call drawPixel
	call drawPixel
	call drawPixel
	call drawPixel
	mov dl, 0 ; black color
	call drawPixel
	mov dl, 15 ; white color
	call drawPixel
	call drawPixel
	mov dl, 0 ; black color
	call drawPixel
	mov dl, 15 ; white color
	call drawPixel
	mov dl, 0 ; black color
	mov [es:di], dl ; end of row 4
	mov di, ax
	add di, 320*4
	mov dl, 0 ; black color
	call drawPixel
	mov dl, 15 ; white color
	call drawPixel
	call drawPixel
	call drawPixel
	call drawPixel
	mov dl, 0 ; black color
	call drawPixel
	mov dl, mainColor[si]
	call drawPixel
	call drawPixel
	call drawPixel
	mov dl, 0 ; black color
	call drawPixel
	mov dl, 15 ; white color
	call drawPixel
	call drawPixel
	mov dl, 0 ; black color
	call drawPixel
	mov dl, 15 ; white color
	call drawPixel
	mov dl, 0 ; black color
	mov [es:di], dl ; end of row 5
	mov di, ax
	add di, 320*5
	mov dl, 0 ; black color
	call drawPixel
	mov dl, 15 ; white color
	call drawPixel
	call drawPixel
	call drawPixel
	call drawPixel
	call drawPixel
	mov dl, 0 ; black color
	call drawPixel
	mov dl, mainColor[si]
	call drawPixel
	call drawPixel
	call drawPixel
	mov dl, 0 ; black color
	call drawPixel
	mov dl, 15 ; white color
	call drawPixel
	call drawPixel
	call drawPixel
	mov dl, 0 ; black color
	mov [es:di], dl ; end of row 6
	mov di, ax
	add di, 320*6
	mov dl, 0 ; black color
	call drawPixel
	mov dl, mainColor[si]
	call drawPixel
	mov dl, 15 ; white color
	call drawPixel
	call drawPixel
	call drawPixel
	mov dl, mainColor[si]
	call drawPixel
	mov dl, 0 ; black color
	call drawPixel
	mov dl, mainColor[si]
	call drawPixel
	call drawPixel
	call drawPixel
	call drawPixel
	mov dl, 0 ; black color
	call drawPixel
	call drawPixel
	call drawPixel
	call drawPixel
	mov [es:di], dl ; end of row 7
	mov di, ax
	add di, 320*7
	inc di
	mov dl, 0 ; black color
	call drawPixel
	mov dl, mainColor[si]
	call drawPixel
	call drawPixel
	call drawPixel
	mov dl, 0 ; black color
	call drawPixel
	mov dl, mainColor[si]
	call drawPixel
	call drawPixel
	call drawPixel
	call drawPixel
	mov dl, 0 ; black color
	call drawPixel
	mov dl, 41 ; orange color
	call drawPixel
	call drawPixel
	call drawPixel
	call drawPixel
	call drawPixel
	mov dl, 0 ; black color
	mov [es:di], dl ; end of row 8
	mov di, ax
	add di, 320*8
	add di, 2
	mov dl, 0 ; black color
	call drawPixel
	call drawPixel
	call drawPixel
	mov dl, secondColor[si]
	call drawPixel
	call drawPixel
	call drawPixel
	call drawPixel
	mov dl, 0 ; black color
	call drawPixel
	mov dl, 41 ; orange color
	call drawPixel
	mov dl, 0 ; black color
	call drawPixel
	call drawPixel
	call drawPixel
	call drawPixel
	mov [es:di], dl ; end of row 9
	mov di, ax
	add di, 320*9
	add di, 4
	mov dl, 0 ; black color
	call drawPixel
	mov dl, secondColor[si]
	call drawPixel
	call drawPixel
	call drawPixel
	call drawPixel
	call drawPixel
	mov dl, 0 ; black color
	call drawPixel
	mov dl, 41 ; orange color
	call drawPixel
	call drawPixel
	call drawPixel
	call drawPixel
	mov dl, 0 ; black color
	mov [es:di], dl ; end of row 10
	mov di, ax
	add di, 320*10
	add di, 5
	mov dl, 0 ; black color
	call drawPixel
	call drawPixel
	mov dl, secondColor[si]
	call drawPixel
	call drawPixel
	call drawPixel
	call drawPixel
	mov dl, 0 ; black color
	call drawPixel
	call drawPixel
	call drawPixel
	call drawPixel
	mov [es:di], dl ; end of row 11
	mov di, ax
	add di, 320*11
	add di, 7
	mov dl, 0 ; black color
	call drawPixel
	call drawPixel
	call drawPixel
	mov [es:di], dl ; end of row 12
	ret
drawBird endp


;checks if each players jump button is pressed
;if the jump button is pressed the apropriate bird jumps
;turns the fall velocity to a negative so the bird goes up
proc jump
	mov cx, 0
	mov cl, players
	mov si, 0
	mov di, 0 
	mov ax, 0
	mov ah, 1
	int 16h
	jz nothingPressed
	checkButton:
	cmp al, jumpButton[si] ; checks if button is pressed
	jne buttonNotPressed
	mov ax, -7
	mov fallVel[di], ax
	buttonNotPressed:
	inc si
	add di, 2
	loop checkButton
	mov ah, 0ch ; clears the buffer
	int 21h
	nothingPressed:

	ret
jump endp

;checks if the bird hits the pipe
proc checkLose
	mov cx, 0
	mov cl, players
	mov di, 0
	
	checkSingleLose:
	push cx
	push di
	add di, di
	mov ax, birdY[di]
	pop di
	cmp ax, 0
	jle top
	cmp ax, 190
	jge bottom
	jmp pipes
	top:
	call hitTop
	jmp notLose
	bottom:
	call lose
	pipes:
	mov si, 0
	mov cx, 5
	checkPipe:
	mov bx, pipeY[si]
	mov dx, pipeX[si]
	cmp dx, 40+15 ; distance from edge plus bird width
	jg pipeOutOfRange
	cmp dx, 40-20 ; distance from edge plus pipe width
	jl pipeOutOfRange
	; now we know that the x value matches
	checkTopPipe:
	cmp ax, bx
	jl hitpipe

	checkBottomPipe:
	add bx, 48
	cmp ax, bx
	jg hitpipe

	jmp pipeOutOfRange
	hitpipe: 
	call lose
	jmp notLose
	pipeOutOfRange:
	add si, 2
	loop checkPipe
	jmp notLose
	notLose:
	
	inc di
	pop cx
	loop checkSingleLose
	ret
checkLose endp

; this proc gets called when the bird hits the top of the screen
proc hitTop
	mov ax, 1
	push di
	add di, di
	mov fallVel[di], ax
	pop di
	ret
hitTop endp

; this proc is called when the bird losses
; the proc ends the game by changing running to 0
proc lose
	mov ah, 0
	mov playing[di], ah
	ret
lose endp


; wait between frames
proc sleep
mov cx, 0
mov dx, 0f060h
mov ah, 86h
int 15h
ret
sleep endp

; a sad pause at the end of the game which shows you how you lost
proc endOfGamePause
mov cx, 10
mov dx, 0
mov ah, 86h
int 15h
ret
endOfGamePause endp

; draws the opening screen at the start of the game
; this screen is in charge of deciding the amount of players
proc openingScreen

opening:
call drawScreen
call drawOpening
mov ah, 08h
int 21h
cmp al, 20h
je doneOpening
sub al, 31h
cmp al, 3
jbe changePlayerCount
jmp opening

changePlayerCount:
inc al
mov players, al
dec al
mov cx, 4
mov si, 0
mov bl, 0
setLivePlayers:
cmp bl, al
ja killPlayer
mov ah, 1
jmp updatePlaying

killPlayer:
mov ah, 0

updatePlaying:
mov playing[si], ah

inc bl
inc si
loop setLivePlayers

jmp opening

doneOpening:
ret
openingScreen endp

; checks if the game should stop according to the amount of players alive
proc checkEnd
mov cx, 4
mov si, 0
; the playing array has a spot for each of the players
; the loop checks if at least one term in the playing array equals 1
; if all the term equal 0 the running variable is changed to 0 indicating the end of the game
checkSingleEnd:
mov ah, 1
cmp playing[si], ah
je gameNotEnded
inc si
loop checkSingleEnd
mov ah, 0
mov running, ah
gameNotEnded:
ret
checkEnd endp

proc endGameProc
; pause in the end of the game
call endOfGamePause

call cls
; return to normal display mode
mov ax, 3
int 10h

; print the final score
mov dx,offset scoreString
mov ah,9
int 21h

; print thank you for playing
mov dx, offset thankString
mov ah, 9
int 21h

mov ah,4ch
int 21h
ret
endGameProc endp


start: mov ax, @data
mov ds,ax
mov ax, 13h
int 10h
mov ax, 0A000h
mov es, ax

call openingScreen

; the main game loop
; continues looping until all the birds lose
; once all the birds lose running changes to 0 and the loop stops
gameLoop:
call jump
call movePipes
call moveBirds
call drawScreen

call checkLose

call sleep ;waste time
call checkEnd
mov ah, running
cmp ah, 1
je gameLoop
; after the player loses
call endGameProc
end start
