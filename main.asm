ORG 0x100       ; 256 bytes of prefixed padding in the .COM output file
BITS 16         ; 16 bit CPU :(

_start_point:
    JMP FUNC_INIT_GAME      ; goofy start point because of a .COM file :(

C_HEAP_SIZE             EQU 256         ; how large, in bytes, the "heap" (just uninitialized, reserved data) is for the program.


;************************************************************************************************************************************************************
;                                                                     ( KEY SCAN CODES )
;************************************************************************************************************************************************************
C_KEY_W_DOWN            EQU 0x11        ; the up key scancode
C_KEY_A_DOWN            EQU 0x1E        ; the right key scancode
C_KEY_S_DOWN            EQU 0x1F        ; the down key scancode
C_KEY_D_DOWN            EQU 0x20        ; the left key scancode
C_KEY_F_DOWN            EQU 0x21        ; the fire key scancode
C_KEY_SPACE_DOWN        EQU 0x39        ; the boost key scancode
C_KEY_BACK_DOWN         EQU 0x0E        ; the dodge key scancode
C_KEY_ESC_DOWN          EQU 0x01        ; the quit key (esc) scancode

C_KEY_W_UP              EQU 0x91        ; the up key released scancode
C_KEY_A_UP              EQU 0x9E        ; the right key released scancode
C_KEY_S_UP              EQU 0x9F        ; the down key released scancode
C_KEY_D_UP              EQU 0xA0        ; the left key released scancode
C_KEY_F_UP              EQU 0xA1        ; the fire key released scancode
C_KEY_SPACE_UP          EQU 0xB9        ; the boost key released scancode
C_KEY_BACK_UP           EQU 0x8E        ; the dodge key released scancode


;************************************************************************************************************************************************************
;                                                                     ( KEY-HELD FLAGS )
;************************************************************************************************************************************************************
C_FLAG_MOVE_UP          EQU 0
C_FLAG_MOVE_RIGHT       EQU 1
C_FLAG_MOVE_DOWN        EQU 2
C_FLAG_MOVE_LEFT        EQU 3
C_FLAG_ATTACK           EQU 4
C_FLAG_BOOST            EQU 5           
C_FLAG_DODGE            EQU 6 
C_FLAG_QUIT             EQU 7

C_ANY_MOVEMENT_FLAG     EQU 0b00001111

;************************************************************************************************************************************************************
;                                                                       ( CONSTANTS )
;************************************************************************************************************************************************************
C_PLAYERDATA_WIDTH          EQU 32          ; player spaceship image is 32x12
C_PLAYERDATA_HEIGHT         EQU 12
C_PLAYERDATA_MIN_POS_X      EQU C_PLAYERDATA_MOVE_BOOST_PIX ; Do NOT set lower than C_PLAYERDATA_MOVE_BOOST_PIX or goofy shit happens
C_PLAYERDATA_MAX_POS_X      EQU (320 - C_PLAYERDATA_WIDTH)
C_PLAYERDATA_MIN_POS_Y      EQU 20          ; 20 pixels of space for score display
C_PLAYERDATA_MAX_POS_Y      EQU (200 - C_PLAYERDATA_HEIGHT)
C_PLAYERDATA_DODGE_FRAMES   EQU 5           ; how many frames the player's ship is invulnerable for when dodging
C_PLAYERDATA_HIT_FRAMES     EQU 30          ; how many frames the player's ship is invulnerable for after being hit
C_PLAYERDATA_MOVE_PIX       EQU 3           ; how many pixels per frame the ship moves when a movement key is held down (and ship is not boosting)
C_PLAYERDATA_MOVE_BOOST_PIX EQU 5           ; how many pixels per frame the ship moves when a movement key is held down (and ship is boosting)
C_PLAYERDATA_BOOST_REFRESH  EQU 2           ; how much the boost refreshes every frame if not being used
C_PLAYERDATA_BOOST_USAGE    EQU 5           ; how much boost gets used every frame while being used
C_PLAYERDATA_MAX_BOOST      EQU 120
C_PLAYERDATA_FIRERATE       EQU 5           ; how many frames in between player attacks. DO NOT MAKE MORE THAN 255
C_PLAYERDATA_BULLET_X_OFF   EQU C_PLAYERDATA_WIDTH      ; how much to add to spawned bullets' x positions
C_PLAYERDATA_BULLET_Y_OFF   EQU C_PLAYERDATA_HEIGHT - 2 ; how much to add to spawned bullets' y positions
C_PLAYERDATA_BULLET_SPEED   EQU 6
C_PLAYERDATA_BULLET_DAMAGE  EQU 5

; PLAYER FLAGS ;
C_PLAYERFLAG_HAS_RELEASED_DODGE EQU 0       ; whether or not the player has released the dodge button since their last dodge (to prevent holding down the dodge button)


; BULLET CONSTANTS ;
C_BULLET_MAX_BULLETS        EQU 20
C_BULLET_SIZE_BYTES         EQU 10
C_BULLET_X_OFFSET           EQU 0       ; word
C_BULLET_Y_OFFSET           EQU 2       ; word
C_BULLET_FLAGS_OFFSET       EQU 4       ; word
C_BULLET_IMAGE_OFFSET       EQU 6       ; word
C_BULLET_SPEED_OFFSET       EQU 8       ; byte
C_BULLET_DAMAGE_OFFSET      EQU 9       ; byte

; BULLET FLAGS ;
C_BULLET_FLAG_MOVEMENT_NEG  EQU 0       ; if true, the bullet subtracts its speed from its position insteading of adding to it
C_BULLET_FLAG_VERTICAL      EQU 1       ; if true, the bullet will move on its Y-axis instead of its X-axis
C_BULLET_FLAG_HOSTILE       EQU 2       ; if true, the bullet will damage the player and ignore enemies


;************************************************************************************************************************************************************
;                                                                   ( .DATA SECTION )
;************************************************************************************************************************************************************
section .data:
    DAT_KEY_STATES      DB  0x00        ; [FLAGS8] contains key states. See C_FLAGs for flag bit offsets

    DAT_PLAYER_FLAGS                    DB  0x00                    ; [FLAGS8] contains states about the player
    DAT_PLAYER_POS_X                    DW  150                     ; [UINT16] the x-position of the top-left pixel of the player
    DAT_PLAYER_POS_Y                    DW  100                     ; [UINT16] the y-position of the top-left pixel of the player
    DAT_PLAYER_HEALTH                   DW  500                     ; [UINT16] the current health of the player. If this reaches zero, the player dies
    DAT_PLAYER_SCORE                    DW  0                       ; [UINT16] the current score of the player
    DAT_PLAYER_BOOST_REMAINING          DW  C_PLAYERDATA_MAX_BOOST  ; [UINT16] how much boost the player has left. Every frame unused, boost goes up 1. Every frame used, boost goes down 5.
    DAT_PLAYER_DODGE_FRAMES_REMAINING   DB  0                       ; [UINT8] how many frames of invulnerability the player has remaining. FPS = 20
    DAT_PLAYER_FRAMES_SINCE_LAST_ATTACK DB  C_PLAYERDATA_FIRERATE   ; [UINT8] how many frames have passed since the user attacked last. Capped at 15

    DAT_DEBUG_PIXEL_X                   DW  0
    DAT_LAST_FRAME_UPDATE               DB  0                       ; the microsecond timestamp of the last frame update that occurred.

    IMG_PLAYER_SPACESHIP                DB  4, 0x00, 2, 0x19, 0
                                        DB  1, 0x00, 3, 0x2A, 1, 0x36, 2, 0x19, 0
                                        DB  2, 0x2A, 2, 0x2B, 1, 0x36, 6, 0x19, 2, 0x0B, 0 
                                        DB  2, 0x00, 2, 0x2A, 1, 0x36, 1, 0x19, 4, 0x1A, 5, 0x19, 0
                                        DB  4, 0x00, 7, 0x19, 2, 0x14, 2, 0x19, 0
                                        DB  5, 0x00, 1, 0x36, 8, 0x19, 0, 0

    IMG_PLAYER_BULLET                   DB  3, 0x44, 0, 0

    IMG_SCORE_TEXT                      DB  1, 0x00, 3, 0x2C, 3, 0x00, 3, 0x2C, 3, 0x00, 3, 0x2C, 3, 0x00, 4, 0x2C, 3, 0x00, 4, 0x2C, 0
                                        DB  1, 0x2C, 5, 0x00, 1, 0x2C, 5, 0x00, 1, 0x2C, 3, 0x00, 1, 0x2C, 2, 0x00, 1, 0x2C, 3, 0x00, 1, 0x2C, 2, 0x00, 1, 0x2C, 5, 0x00, 1, 0x2C, 0
                                        DB  1, 0x2C, 5, 0x00, 1, 0x2C, 5, 0x00, 1, 0x2C, 3, 0x00, 1, 0x2C, 2, 0x00, 1, 0x2C, 3, 0x00, 1, 0x2C, 2, 0x00, 1, 0x2C, 5, 0x00, 0
                                        DB  1, 0x00, 2, 0x2C, 3, 0x00, 1, 0x2C, 5, 0x00, 1, 0x2C, 3, 0x00, 1, 0x2C, 2, 0x00, 4, 0x2C, 3, 0x00, 3, 0x2C, 0
                                        DB  3, 0x00, 1, 0x2C, 2, 0x00, 1, 0x2C, 5, 0x00, 1, 0x2C, 3, 0x00, 1, 0x2C, 2, 0x00, 1, 0x2C, 2, 0x00, 1, 0x2C, 3, 0x00, 1, 0x2C, 0
                                        DB  3, 0x00, 1, 0x2C, 2, 0x00, 1, 0x2C, 5, 0x00, 1, 0x2C, 3, 0x00, 1, 0x2C, 2, 0x00, 1, 0x2C, 3, 0x00, 1, 0x2C, 2, 0x00, 1, 0x2C, 5, 0x00, 1, 0x2C, 0
                                        DB  3, 0x2C, 4, 0x00, 3, 0x2C, 3, 0x00, 3, 0x2C, 3, 0x00, 1, 0x2C, 3, 0x00, 1, 0x2C, 2, 0x00, 4, 0x2C, 0, 0

    IMG_BOOST_TEXT                      DB  3, 0x2D, 3, 0x00, 2, 0x2D, 3, 0x00, 2, 0x2D, 3, 0x00, 2, 0x2D, 1, 0x00, 3, 0x2D, 0
                                        DB  1, 0x2D, 2, 0x00, 1, 0x2D, 1, 0x00, 1, 0x2D, 2, 0x00, 1, 0x2D, 1, 0x00, 1, 0x2D, 2, 0x00, 1, 0x2D, 1, 0x00, 1, 0x2D, 4, 0x00, 1, 0x2D, 2, 0x00, 1, 0x2D, 0
                                        DB  4, 0x2D, 1, 0x00, 1, 0x2D, 2, 0x00, 1, 0x2D, 1, 0x00, 1, 0x2D, 2, 0x00, 1, 0x2D, 1, 0x00, 3, 0x2D, 2, 0x00, 1, 0x2D, 0
                                        DB  1, 0x2D, 2, 0x00, 1, 0x2D, 1, 0x00, 1, 0x2D, 2, 0x00, 1, 0x2D, 1, 0x00, 1, 0x2D, 2, 0x00, 1, 0x2D, 3, 0x00, 1, 0x2D, 2, 0x00, 1, 0x2D, 2, 0x00, 1, 0x2D, 0
                                        DB  3, 0x2D, 3, 0x00, 2, 0x2D, 3, 0x00, 2, 0x2D, 2, 0x00, 2, 0x2D, 3, 0x00, 1, 0x2D, 0, 0

    IMG_BOOST_OUTLINE                   DB  24, 0x15, 0
                                        DB  24, 0x15, 0
                                        DB  24, 0x15, 0
                                        DB  24, 0x15, 0, 0

    IMG_BOOST_UNDERBAR                  DB  22, 0x18, 0
                                        DB  22, 0x18, 0, 0



    DAT_BULLET_ARRAY                    TIMES C_BULLET_MAX_BULLETS * (C_BULLET_SIZE_BYTES / 2) DW 0xFFFF    ; 0xFFFF (above 320/200) for pos data means free slot
    DAT_END_OF_BULLET_ARRAY:

    STR_QUIT_MSG                        DB  'Shutdown was initiated! Error code: ?', 0x0A, 0x0D, '$'
    STR_DEBUG_MSG                       DB  '!DEBUG!', 0x0A, 0x0D, '$'


;************************************************************************************************************************************************************
;                                                               ( UNINITIALIZED DATA SECTION )
;************************************************************************************************************************************************************
section .bss:
    PTR_OLD_KEYHANDLER_ADDRESS          RESW    2       ; [LPTR] contains the memory address of the original IVT keyhandler interrupt
    
;************************************************************************************************************************************************************
;************************************************************************************************************************************************************
;                                                                       ( CODE START )
;************************************************************************************************************************************************************
;************************************************************************************************************************************************************

;************************************************************************************************************************************************************
; VOID INIT_GAME()
; initializes the game by overriding the default keyhandler interrupt and replacing it with HANDLE_KEY(). Then sets up the main loop by calling DRAW_SHIP()
;************************************************************************************************************************************************************
; ( PARAMS )
; NONE
;
FUNC_INIT_GAME:
    CLI ; disable interrupts while changing an interupt

    ; SAVE ORIGINAL KEY HANDLER INTERRUPT ADDRESS IN PTR_OLD_KEYHANDLER_ADDRESS ;
    MOV AX, 0x0000
    MOV ES, AX              ; load segment 0x0000 into ES (have to use a register [AX] as median), which is the segment of the IVT in BIOS memory

    MOV AX, 0x0024  
    MOV DI, AX              ; load offset 0x0024 into DI (have to use a register as median), which is 9 * 4 for overriding the 9th interrupt address (keyhandler address)

    MOV AX, WORD ES:[DI]         ; save first word of original address into AX
    MOV WORD [PTR_OLD_KEYHANDLER_ADDRESS], AX       ; update first word of PTR_OLD_KEYHANDLER_ADDRESS to be the first word of original address

    MOV AX, WORD ES:[DI + 2]     ; save second word of original address into AX
    MOV WORD [PTR_OLD_KEYHANDLER_ADDRESS + 2], AX   ; update second word of PTR_OLD_KEYHANDLER_ADDRESS to be the second word of original address

    ; UPDATE INT 0x09 TO BE CUSTOM KEYHANDLER INTERRUPT HANDLE_KEY() ;
    MOV WORD ES:[DI + 2], CS    ; update segment of IVT[9] to be our code segment
    
    MOV AX, FUNC_HANDLE_KEY ; load offset of HANDLE_KEY() into AX
    MOV WORD ES:[DI], AX    ; update offset of IVT[9] to be our function

    STI ; re-enable interrupts, we finished changing interrupt table

    ; SET DISPLAY MODE TO VGA (PIXEL-LEVEL CONTROL) ;
    ; Set VGA graphics mode (320x200, 256 colors)
	MOV AH, 0x00
	MOV AL, 0x13
	INT 0x10

    ; DRAW TEXT : "SCORE:" ONTO SCREEN
    MOV     AX, 2               ; PARAM: Y POSITION
    MOV     DX, 2               ; PARAM: X POSITION
    MOV     SI, IMG_SCORE_TEXT  ; PARAM: IMAGE (RLE-encoded)
    MOV     BL, 0xFF            ; PARAM: BITMASK
    CALL    FUNC_DRAW_IMAGE

    ; DRAW TEXT: "BOOST:" ONTO SCREEN
    MOV     AX, 2               ; PARAM: Y POSITION
    MOV     DX, 260             ; PARAM: X POSITION
    MOV     SI, IMG_BOOST_TEXT  ; PARAM: IMAGE (RLE-encoded)
    MOV     BL, 0xFF            ; PARAM: BITMASK
    CALL    FUNC_DRAW_IMAGE

    ; DRAW BOOST BAR BACKGROUND ONTO SCREEN
    MOV     AX, 14                  ; PARAM: Y POSITION
    MOV     DX, 260                 ; PARAM: X POSITION
    MOV     SI, IMG_BOOST_OUTLINE   ; PARAM: IMAGE (RLE-encoded)
    MOV     BL, 0xFF                ; PARAM: BITMASK
    CALL    FUNC_DRAW_IMAGE

    ; DRAW BOOST BAR UNDERBAR ONTO SCREEN
    MOV     AX, 16                  ; PARAM: Y POSITION
    MOV     DX, 262                 ; PARAM: X POSITION
    MOV     SI, IMG_BOOST_UNDERBAR  ; PARAM: IMAGE (RLE-encoded)
    MOV     BL, 0xFF                ; PARAM: BITMASK
    CALL    FUNC_DRAW_IMAGE

    

    ; SAVE START TIMESTAMP INTO DAT_LAST_FRAME_UPDATE ;
    MOV     AH, 0x2C        ; INT 0x21 | AH 0x2C: GET SYSTEM TIME. CH = HOUR, CL = MIN, DH = SEC, DL = CENTISECONDS
    INT     0x21

    MOV     BYTE [DAT_LAST_FRAME_UPDATE], DL

    ; START MAIN LOOP ;
    ; * this automatically goes to LOGIC_STEP() * ;


;************************************************************************************************************************************************************
; VOID LOGIC_STEP()
; handles all key flags and updates all entities according to the game's current state. Should be called once a frame, at 20 FPS.
;************************************************************************************************************************************************************
; ( PARAMS )
; NONE
;
FUNC_LOGIC_STEP:
    ; CHECK PLAYER KEY STATES AND UPDATE PLAYER STATS BASED ON THEM ;
    
    MOV     BL, 0x00    ; PARAM: BITMASK
    CALL    FUNC_RENDER_SCREEN

    ; HANDLE KEYBOARD INPUT FROM THE USER ;
    MOVZX   AX, BYTE [DAT_KEY_STATES]
    MOV     CX, C_PLAYERDATA_MOVE_PIX                       ; default movement speed

    LAB_CHECK_PLAYER_BOOSTING:
        BT      AX, C_FLAG_BOOST                            ; check if the player is boosting. If so, check if they CAN boost
        JNC     LAB_INC_BOOST                               ; if the player is not attempting to boost, increment their boost fuel by the refresh rate (if they are not at the max)
        CMP     WORD [DAT_PLAYER_BOOST_REMAINING], C_PLAYERDATA_BOOST_USAGE
        JB      LAB_INC_BOOST                               ; if the player does not have enough boost remaining to boost this frame, increment their boost
        TEST    AX, C_ANY_MOVEMENT_FLAG                     ; check if the player will be moving this frame
        JZ      LAB_INC_BOOST                               ; if the player is not moving, do not subtract from their boost
        SUB     WORD [DAT_PLAYER_BOOST_REMAINING], C_PLAYERDATA_BOOST_USAGE
        MOV     CX, C_PLAYERDATA_MOVE_BOOST_PIX             ; if the player can boost, make their movement boost speed rather than default speed
        JMP     LAB_CHECK_PLAYER_MOVES_UP                   ; continue checking for player states

        LAB_INC_BOOST:
        CMP     WORD [DAT_PLAYER_BOOST_REMAINING], C_PLAYERDATA_MAX_BOOST       ; if the boost has reached max, skip adding boost
        JNB     LAB_CHECK_PLAYER_MOVES_UP
        ADD     WORD [DAT_PLAYER_BOOST_REMAINING], C_PLAYERDATA_BOOST_REFRESH   ; add refresh boost amount to player's remaining boost

    LAB_CHECK_PLAYER_MOVES_UP:
        BT      AX, C_FLAG_MOVE_UP                          ; check if the player needs to move up
        JNC     LAB_CHECK_PLAYER_MOVES_LEFT                 ; if the player does not need to move up, check if they need to move left

        MOV     BX, WORD [DAT_PLAYER_POS_Y]                 ; load player Y into BX
        SUB     BX, CX                                      ; subtract the movement speed from BX to see where the player would end if they moved up
        CMP     BX, C_PLAYERDATA_MIN_POS_Y                  ; check if player's Y can be subtracted from (is new player Y less than minimum Y pos?)
        JNA     LAB_CHECK_PLAYER_MOVES_LEFT                 ; if the player's Y cannot be subtracted from, move onto the next key check
        SUB     WORD [DAT_PLAYER_POS_Y], CX                 ; if the player's Y can be subtracted from, do so

    LAB_CHECK_PLAYER_MOVES_LEFT:
        BT      AX, C_FLAG_MOVE_LEFT                        ; check if the player needs to move left
        JNC     LAB_CHECK_PLAYER_MOVES_DOWN                 ; if the player does not need to move left, check if they need to move down

        MOV     BX, WORD [DAT_PLAYER_POS_X]                 ; load player X into BX
        SUB     BX, CX                                      ; subtract the movement speed from BX to see where the player would end if they moved left
        CMP     BX, C_PLAYERDATA_MIN_POS_X                  ; check if player's X can be subtracted from (is new player X less than minimum X pos?)
        JNA     LAB_CHECK_PLAYER_MOVES_DOWN                 ; if the player's X cannot be subtracted from, move onto the next key check
        SUB     WORD [DAT_PLAYER_POS_X], CX                 ; if the player's X can be subtracted from, do so
        
    LAB_CHECK_PLAYER_MOVES_DOWN:
        BT      AX, C_FLAG_MOVE_DOWN                        ; check if the player needs to move down
        JNC     LAB_CHECK_PLAYER_MOVES_RIGHT                ; if the player does not need to move down, check if they need to move right

        MOV     BX, WORD [DAT_PLAYER_POS_Y]                 ; load player Y into BX
        ADD     BX, CX                                      ; add the movement speed to BX to see where the player would end if they moved down
        CMP     BX, C_PLAYERDATA_MAX_POS_Y                  ; check if player's Y can be added to (is new player Y greater than maximum Y pos?)
        JA      LAB_CHECK_PLAYER_MOVES_RIGHT                ; if the player's Y cannot be added to, move onto the next key check
        ADD     WORD [DAT_PLAYER_POS_Y], CX                 ; if the player's Y can be added to, do so

    LAB_CHECK_PLAYER_MOVES_RIGHT:
        BT      AX, C_FLAG_MOVE_RIGHT                       ; check if the player needs to move right
        JNC     LAB_CHECK_PLAYER_FIRING                     ; if the player does not need to move right, check if the player is firing

        MOV     BX, WORD [DAT_PLAYER_POS_X]                 ; load player X into BX
        ADD     BX, CX                                      ; add the movement speed to BX to see where the player would end if they moved right
        CMP     BX, C_PLAYERDATA_MAX_POS_X                  ; check if player's X can be added to (is new player X greater than maximum X pos?)
        JA      LAB_CHECK_PLAYER_FIRING                     ; if the player's X cannot be added to, move onto the next key check
        ADD     WORD [DAT_PLAYER_POS_X], CX                 ; if the player's X can be added to, do so

    LAB_CHECK_PLAYER_FIRING:
        MOV     BH, BYTE [DAT_PLAYER_FRAMES_SINCE_LAST_ATTACK]
        CMP     BH, C_PLAYERDATA_FIRERATE                   ; check if the player CAN fire. If they cannot, skip flag check and add one to their reload frames.
        JB      LAB_PLAYER_CANNOT_FIRE                      ; if they can fire, check the attack flag.

        ; CHECK ATTACK FLAG ;
        BT      AX, C_FLAG_ATTACK                           ; check if the player is attacking
        JNC     LAB_CHECK_GAME_QUIT                         ; if the player does not need to attack, check if the game needs to quit

        ; SPAWN BULLET ;
        MOV     BH, 0                                       ; set frames since last attack to 15
        MOV     BYTE [DAT_PLAYER_FRAMES_SINCE_LAST_ATTACK], BH  

        MOV     AX, WORD [DAT_PLAYER_POS_Y]                 ; PARAM: DRAW Y
        ADD     AX, C_PLAYERDATA_BULLET_Y_OFF                   ; PARAM: ADD Y OFFSET TO BULLET Y
        MOV     DX, WORD [DAT_PLAYER_POS_X]                 ; PARAM: DRAW X
        ADD     DX, C_PLAYERDATA_BULLET_X_OFF                   ; PARAM: ADD X OFFSET TO BULLET X
        MOV     SI, IMG_PLAYER_BULLET                       ; PARAM: IMAGE (RLE-encoded)
        MOV     CX, 0                                       ; PARAM: FLAGS
        MOV     BH, C_PLAYERDATA_BULLET_SPEED               ; PARAM: BULLET SPEED
        MOV     BL, C_PLAYERDATA_BULLET_DAMAGE              ; PARAM: BULLET DAMAGE
        CALL    FUNC_CREATE_BULLET
        MOVZX   AX, BYTE [DAT_KEY_STATES]                   ; reload key states; we had to overwrite AX for params
        JMP     LAB_CHECK_GAME_QUIT
        
        LAB_PLAYER_CANNOT_FIRE:
            INC     BYTE [DAT_PLAYER_FRAMES_SINCE_LAST_ATTACK]  ; update player frames since last attack. This should never go above C_PLAYERDATA_FIRERATE.

    LAB_CHECK_GAME_QUIT:
        BT      AX, C_FLAG_QUIT                             ; check if the game needs to quit
        JC      FUNC_QUIT_GAME                              ; if so, call QUIT_GAME()


    ; *********************************** ;
    ; HANDLE BULLET MOVEMENT AND COLLISON ;
    ; *********************************** ;
    MOV     SI, DAT_BULLET_ARRAY
    LAB_MOVE_BULLET_LOOP:
        ; CHECK IF BULLET X IS VALID ;
        MOV     AX, WORD [SI + C_BULLET_X_OFFSET]
        CMP     AX, 320     ; if bullet.x > 320, it is invalid and should not be dealt with.
        JA      LAB_CONTINUE_BULLET_LOOP

        ; CHECK IF BULLET Y IS VALID ;
        MOV     AX, WORD [SI + C_BULLET_Y_OFFSET]
        CMP     AX, 200     ; if bullet.y > 200, it is invalid and should not be dealth with.
        JA      LAB_CONTINUE_BULLET_LOOP

        ; ****** UPDATE BULLET ****** ;
        MOV     AX, WORD [SI + C_BULLET_FLAGS_OFFSET]   ; load bullet flags to perform checks on them
        BT      AX, C_BULLET_FLAG_VERTICAL              ; if bullet flag VERTICAL is true, make bullet movement (saved in BX) Y axis.
        JNC     LAB_BULLET_MOVEMENT_HORIZONTAL          ; if bullet flag VERTICAL is false, make it move on the x-axis
        MOV     BX, SI                                  ; set movement field to BULLET.Y
        ADD     BX, C_BULLET_Y_OFFSET
        JMP     LAB_CHECK_BULLET_NEG

        LAB_BULLET_MOVEMENT_HORIZONTAL:
        MOV     BX, SI                                  ; bullet is moving on the x-axis
        ADD     BX, C_BULLET_X_OFFSET                   ; set movement field to BULLET.X

        LAB_CHECK_BULLET_NEG:
        BT      AX, C_BULLET_FLAG_MOVEMENT_NEG          ; if negative movement is true, subtract speed instead of adding it
        JNC     LAB_MOVE_BULLET_POS                     ; if negative movement is false, add speed to [BX]
        LAB_MOVE_BULLET_NEG:
        MOVZX   CX, BYTE [SI + C_BULLET_SPEED_OFFSET]   ; move speed into CX (position field is a word, so speed needs to be a word as well)
        SUB     DS:[BX], CX                             ; subtract speed from axis
        JMP     LAB_CONTINUE_BULLET_LOOP

        LAB_MOVE_BULLET_POS:
        MOVZX   CX, BYTE [SI + C_BULLET_SPEED_OFFSET]   ; move speed into CX (position field is a word, so speed needs to be a word as well)
        ADD     DS:[BX], CX                             ; add speed to axis

        ; ****** HANDLE BULLET COLLISON ****** ;

        LAB_CONTINUE_BULLET_LOOP:
            ADD     SI, C_BULLET_SIZE_BYTES ; iterate to next element
            CMP     SI, DAT_END_OF_BULLET_ARRAY
            JAE     LAB_RENDER_SCREEN       ; if element iterator position >= DAT_END_OF_BULLET_ARRAY, we have reached end of array and need to terminate.
            JMP     LAB_MOVE_BULLET_LOOP

    LAB_RENDER_SCREEN:
    ; UPDATE PLAYER HEALTH BAR AND PLAYER BOOST BAR ;   

    ; DRAW BOOST BAR UNDERBAR ONTO SCREEN
    MOV     AX, 16                  ; PARAM: Y POSITION
    MOV     DX, 262                 ; PARAM: X POSITION
    MOV     SI, IMG_BOOST_UNDERBAR  ; PARAM: IMAGE (RLE-encoded)
    MOV     BL, 0xFF                ; PARAM: BITMASK
    CALL    FUNC_DRAW_IMAGE

    ; DRAW BOOST BAR ONTO SCREEN
    MOV     AX, 0xA000
    MOV     ES, AX                      ; VGA segment
    MOV     AX, (16 * 320) + 262        ; coords (262, 16)
    MOV     DI, AX

    ; GET NUMBER OF PIXELS TO DISPLAY TO SCREEN: (44 * BOOST)/ MAX_BOOST
    MOV     AX, WORD [DAT_PLAYER_BOOST_REMAINING]

    MOV     BX, 44                      ; multiply AX by 44
    MUL     BX

    MOV     BX, C_PLAYERDATA_MAX_BOOST  ; divide AX by MAX_BOOST
    DIV     BX
    
    MOV     BX, AX                      ; save result in BX
    MOV     CX, AX                      ; loop: display AX pixels to screen
    MOV     AL, 0x2B                    ; orange bar
    REP     STOSB

    ADD     DI, 320
    SUB     DI, BX                      ; go to next line
    MOV     CX, BX                      ; loop: display BX pixels to screen
    REP     STOSB

    ADD     DI, 320
    SUB     DI, BX                      ; go to next line
    MOV     CX, BX                      ; loop: display BX pixels to screen
    REP     STOSB

    ADD     DI, 320
    SUB     DI, BX                      ; go to next line
    MOV     CX, BX                      ; loop: display BX pixels to screen
    REP     STOSB

    ; RENDER NEW FRAME
    MOV     BL, 0xFF                    ; PARAM: BITMASK
    CALL    FUNC_RENDER_SCREEN          ; draw new frame to screen
 
    ; WAIT UNTIL A NEW FRAME CAN BE DRAWN ;

;************************************************************************************************************************************************************
; VOID FRAME_WAIT()
; runs a loop until approximately 30 ms has elapsed from the time stored in DAT_LAST_FRAME_UPDATE
;************************************************************************************************************************************************************
; ( PARAMS )
; NONE
;
FUNC_FRAME_WAIT:
    MOV     AH, 0x2C        ; get the system time
    INT     0x21            ; DL = x/100ths of a second

    ; CHECK TO SEE IF A FRAME CAN PASS ;
    MOV     DH, DL          ; store new time in DH, as we will be changing the time in DL for math
    CMP     DL, BYTE [DAT_LAST_FRAME_UPDATE]
    JAE     LAB_NO_TIMEWRAP ; since time wraps from 0-99, we need to check if OLD is bigger than NEW (true if time has wrapped). If so, perform a different operation
    LAB_TIMEWRAP:
        ; PERFORM DIFF = NEW + (100 - OLD) ;
        MOV     AL, 100     ; load 100 into AL for subtraction
        SUB     AL, BYTE [DAT_LAST_FRAME_UPDATE]  ; subtract OLD from AL, or OLD from 100
        ADD     DL, AL      ; add the result of (100 - OLD) to NEW
        JMP     LAB_CHECK_TIMEDIFF  ; see if we can step frame

    LAB_NO_TIMEWRAP:
        ; PERFORM DIFF = NEW - OLD ;
        SUB     DL, BYTE [DAT_LAST_FRAME_UPDATE]    ; sub OLD from NEW

    LAB_CHECK_TIMEDIFF:
        ; IF DIFF >= 3, STEP FRAME. OTHERWISE, LOOP AGAIN ;
        CMP     DL, 3       ; check if the result >= 5 (>= 50 ms, about 20 FPS). Clock resolution may limit this to 20 FPS though (~50 ms resolution)
        JNAE    FUNC_FRAME_WAIT ; loop if frame cannot be passed

        ; STEP FRAME ;
        MOV     BYTE [DAT_LAST_FRAME_UPDATE], DH    ; update LAST_FRAME_UPDATE, we're stepping frames.
        JMP     FUNC_LOGIC_STEP ; STEP FRAME IF ABOVE 30 MS HAS PASSED


;************************************************************************************************************************************************************
; VOID DEBUG_MSG()
; displays the string STR_DEBUG_MSG in the console
;************************************************************************************************************************************************************
; ( PARAMS )
; NONE
;
FUNC_DEBUG_MSG:

    MOV AH, 0x09
	MOV DX, STR_DEBUG_MSG
	INT 0x21

    RET

;************************************************************************************************************************************************************
; VOID DEBUG_VGA()
; displays the a red pixel on the top left of the screen, moving the pixel location by one to the right every time called again.
;************************************************************************************************************************************************************
; ( PARAMS )
; NONE
;
FUNC_DEBUG_VGA:
    PUSH ES
    PUSH DI
    PUSH AX

    MOV AX, 0xA000
    MOV ES, AX

    MOV AX, WORD [DAT_DEBUG_PIXEL_X]
    MOV DI, AX

    MOV AL, 12
    MOV BYTE ES:[DI], AL

    MOV AX, 1
    ADD WORD [DAT_DEBUG_PIXEL_X], AX

    POP AX
    POP DI
    POP ES
    RET

;************************************************************************************************************************************************************
; VOID HANDLE_KEY()
; custom interrupt that handles key presses/releases and updates flags in DAT_KEY_STATES according to the key. NEVER CALL IN-CODE.
;************************************************************************************************************************************************************
; ( PARAMS )
; NONE
;
FUNC_HANDLE_KEY:
    PUSH AX
    PUSH BX

    IN AL, 0x60             ; read scan code from port 0x60 (keyboard).
    TEST AL, 0b10000000     ; test if top bit of scan code is set. If so, a key has been released, otherwise a key was pressed down.

    JZ LAB_CHECK_W          ; if top bit is false, start checking down codes.
    JMP LAB_CHECK_W_UP      ; if top bit is true, start checking up codes.

    LAB_CHECK_W:
        CMP AL, C_KEY_W_DOWN    ; if the scan key is W-DOWN, set C_FLAG_MOVE_UP to true
        JNE LAB_CHECK_A         ; if the scan key is not W-DOWN, check if key is A-DOWN
        MOV BX, C_FLAG_MOVE_UP
        BTS [DAT_KEY_STATES], BX; set C_FLAG_MOVE_UP to true in DAT_KEY_STATES
        JMP LAB_END_KEYCHECKS   ; don't bother checking the rest of the keystates since we already found our keystate

    LAB_CHECK_A:
        CMP AL, C_KEY_A_DOWN    ; if the scan key is A-DOWN, set C_FLAG_MOVE_LEFT to true
        JNE LAB_CHECK_S         ; if the scan key is not A-DOWN, check if key is S-DOWN
        MOV BX, C_FLAG_MOVE_LEFT
        BTS [DAT_KEY_STATES], BX; set C_FLAG_MOVE_LEFT to true in DAT_KEY_STATES
        JMP LAB_END_KEYCHECKS   ; don't bother checking the rest of the keystates since we already found our keystate

    LAB_CHECK_S:
        CMP AL, C_KEY_S_DOWN    ; if the scan key is S-DOWN, set C_FLAG_MOVE_DOWN to true
        JNE LAB_CHECK_D         ; if the scan key is not S-DOWN, check if key is D-DOWN
        MOV BX, C_FLAG_MOVE_DOWN
        BTS [DAT_KEY_STATES], BX; set C_FLAG_MOVE_DOWN to true in DAT_KEY_STATES
        JMP LAB_END_KEYCHECKS   ; don't bother checking the rest of the keystates since we already found our keystate

    LAB_CHECK_D:
        CMP AL, C_KEY_D_DOWN    ; if the scan key is D-DOWN, set C_FLAG_MOVE_RIGHT to true
        JNE LAB_CHECK_F         ; if the scan key is not D-DOWN, check if key is F-DOWN
        MOV BX, C_FLAG_MOVE_RIGHT
        BTS [DAT_KEY_STATES], BX; set C_FLAG_MOVE_RIGHT to true in DAT_KEY_STATES
        JMP LAB_END_KEYCHECKS   ; don't bother checking the rest of the keystates since we already found our keystate

    LAB_CHECK_F:
        CMP AL, C_KEY_F_DOWN    ; if the scan key is F-DOWN, set C_FLAG_ATTACK to true
        JNE LAB_CHECK_SPACE     ; if the scan key is not F-DOWN, check if key is SPACE-DOWN
        MOV BX, C_FLAG_ATTACK
        BTS [DAT_KEY_STATES], BX; set C_FLAG_ATTACK to true in DAT_KEY_STATES
        JMP LAB_END_KEYCHECKS   ; don't bother checking the rest of the keystates since we already found our keystate

    LAB_CHECK_SPACE:
        CMP AL, C_KEY_SPACE_DOWN; if the scan key is SPACE-DOWN, set C_FLAG_BOOST to true
        JNE LAB_CHECK_BACK      ; if the scan key is not SPACE-DOWN, check if key is BACK-DOWN
        MOV BX, C_FLAG_BOOST
        BTS [DAT_KEY_STATES], BX; set C_FLAG_BOOST to true in DAT_KEY_STATES
        JMP LAB_END_KEYCHECKS   ; don't bother checking the rest of the keystates since we already found our keystate

    LAB_CHECK_BACK:
        CMP AL, C_KEY_BACK_DOWN ; if the scan key is BACK-DOWN, set C_FLAG_DODGE to true
        JNE LAB_CHECK_ESC       ; if the scan key is not BACK-DOWN, check if key is ESC-DOWN
        MOV BX, C_FLAG_DODGE
        BTS [DAT_KEY_STATES], BX; set C_FLAG_DODGE to true in DAT_KEY_STATES
        JMP LAB_END_KEYCHECKS   ; don't bother checking the rest of the keystates since we already found our keystate

    LAB_CHECK_ESC:
        CMP AL, C_KEY_ESC_DOWN   ; if the scan key is ESC-DOWN, set C_FLAG_QUIT to true
        JNE LAB_END_KEYCHECKS    ; if the scan key is not ESC-DOWN, stop checking for more keys (this key is the last in a chain of else-ifs)
        MOV BX, C_FLAG_QUIT
        BTS [DAT_KEY_STATES], BX; set C_FLAG_QUIT to true in DAT_KEY_STATES 
        JMP LAB_END_KEYCHECKS   ; end keychecks

    ; **************************************************************** ;
    ; ********************* UP SCANCODE CHECKING ********************* ;
    ; **************************************************************** ;

    LAB_CHECK_W_UP:
        CMP AL, C_KEY_W_UP      ; if the scan key is W-UP, set C_FLAG_MOVE_UP to false
        JNE LAB_CHECK_A_UP      ; if the scan key is not W-UP, check if key is A-UP
        MOV BX, C_FLAG_MOVE_UP
        BTR [DAT_KEY_STATES], BX; set C_FLAG_MOVE_UP to false in DAT_KEY_STATES
        JMP LAB_END_KEYCHECKS   ; don't bother checking the rest of the keystates since we already found our keystate

    LAB_CHECK_A_UP:
        CMP AL, C_KEY_A_UP      ; if the scan key is A-UP, set C_FLAG_MOVE_LEFT to false
        JNE LAB_CHECK_S_UP      ; if the scan key is not A-UP, check if key is S-UP
        MOV BX, C_FLAG_MOVE_LEFT
        BTR [DAT_KEY_STATES], BX; set C_FLAG_MOVE_LEFT to false in DAT_KEY_STATES
        JMP LAB_END_KEYCHECKS   ; don't bother checking the rest of the keystates since we already found our keystate

    LAB_CHECK_S_UP:
        CMP AL, C_KEY_S_UP      ; if the scan key is S-UP, set C_FLAG_MOVE_UP to false
        JNE LAB_CHECK_D_UP      ; if the scan key is not S-UP, check if key is D-UP
        MOV BX, C_FLAG_MOVE_DOWN
        BTR [DAT_KEY_STATES], BX; set C_FLAG_MOVE_DOWN to false in DAT_KEY_STATES
        JMP LAB_END_KEYCHECKS   ; don't bother checking the rest of the keystates since we already found our keystate

    LAB_CHECK_D_UP:
        CMP AL, C_KEY_D_UP      ; if the scan key is D-UP, set C_FLAG_MOVE_RIGHT to false
        JNE LAB_CHECK_F_UP      ; if the scan key is not D-UP, check if key is F-UP
        MOV BX, C_FLAG_MOVE_RIGHT
        BTR [DAT_KEY_STATES], BX; set C_FLAG_MOVE_RIGHT to false in DAT_KEY_STATES
        JMP LAB_END_KEYCHECKS   ; don't bother checking the rest of the keystates since we already found our keystate

    LAB_CHECK_F_UP:
        CMP AL, C_KEY_F_UP      ; if the scan key is F-UP, set C_FLAG_ATTACK to false
        JNE LAB_CHECK_SPACE_UP  ; if the scan key is not F-UP, check if key is SPACE-UP
        MOV BX, C_FLAG_ATTACK
        BTR [DAT_KEY_STATES], BX; set C_FLAG_ATTACK to false in DAT_KEY_STATES
        JMP LAB_END_KEYCHECKS   ; don't bother checking the rest of the keystates since we already found our keystate

    LAB_CHECK_SPACE_UP:
        CMP AL, C_KEY_SPACE_UP  ; if the scan key is SPACE-UP, set C_FLAG_BOOST to false
        JNE LAB_CHECK_BACK_UP   ; if the scan key is not SPACE-UP, check if key is BACK-UP
        MOV BX, C_FLAG_BOOST
        BTR [DAT_KEY_STATES], BX; set C_FLAG_BOOST to false in DAT_KEY_STATES
        JMP LAB_END_KEYCHECKS   ; don't bother checking the rest of the keystates since we already found our keystate

    LAB_CHECK_BACK_UP:
        CMP AL, C_KEY_BACK_UP   ; if the scan key is BACK-UP, set C_FLAG_DODGE to false
        JNE LAB_END_KEYCHECKS   ; if the scan key is not BACK-UP, stop checking
        MOV BX, C_FLAG_DODGE
        BTR [DAT_KEY_STATES], BX; set C_FLAG_DODGE to false in DAT_KEY_STATES

    LAB_END_KEYCHECKS:
        MOV AX, 0x20            ; tell PIC (interrupt handler) that this interrupt has been successfully handled.
        OUT 0x20, AX            ; output message 0x20 (INT success) to port 0x20 (PIC)

    ; END INTERRUPT - RESTORE BX/AX AND CALL INTERRUPT RETURN ;
    POP BX
    POP AX
    IRET

;************************************************************************************************************************************************************
; VOID QUIT_GAME(INT16 ERR_CODE)
; restores the old INT 0x09 keyboard interrupt to the IVT, displays a message containing the error code: "Game terminated with error ?", and kills program
;************************************************************************************************************************************************************
; ( PARAMS )
; AX: ERR_CODE  [CURRENTLY UNUSED]
;
FUNC_QUIT_GAME:
    CLI

    ; RESTORE OLD IVT ENTRY ;
    MOV AX, 0x0000      ; load IVT segment into ES
    MOV ES, AX

    MOV AX, 0x0024      ; load IVT INT 0x09 offset into DI
    MOV DI, AX

    MOV AX, WORD [PTR_OLD_KEYHANDLER_ADDRESS]
    MOV ES:[DI], AX     ; restore first word of original INT 0x09 address

    MOV AX, WORD [PTR_OLD_KEYHANDLER_ADDRESS + 2]
    MOV ES:[DI + 2], AX     ; restore second word of original INT 0x09 address

    STI

    ; RESTORE TEXT MODE (DEFAULT MS-DOS/BIOS MODE) ;
    MOV AX, 0x03        ; switch from video to text mode (AH = 0x0, AL = 0x03)
	INT 0x10
	
	MOV AH, 0x09
	MOV DX, STR_QUIT_MSG; write STR_QUIT_MSG to console to let the user know that a clean program shutdown occurred
	INT 0x21

    INT 0x20            ; return to MS-DOS.


;************************************************************************************************************************************************************
; VOID DRAW_IMAGE(UINT16 YPOS, UINT16 XPOS, NPTR IMAGE, UINT8 DRAWMASK)
; draws a RLE-encoded sprite to the screen, ending on the first double zero. Each line ends at a zero. Images do not wrap around screen.
;************************************************************************************************************************************************************
; ( PARAMS )
; AX: [UINT16]  YPOS    - the y position of the image's top left pixel
; DX: [UINT16]  XPOS    - the x position of the image's top left pixel
; BL: [UINT8]   BITMASK - the bitmask applied to drawn pixels on the screen.
; SI: [NPTR]    IMAGE   - the offset of the image from DS
;
FUNC_DRAW_IMAGE:
    ; SETUP STACK FRAME ;
    PUSH    BP
    MOV     BP, SP

    PUSH ES
    PUSH DI
    PUSH CX

    MOV     CX, 0xA000          ; The segment of the VGA video memory
    MOV     ES, CX
    
    ; GET MEMORY OFFSET OF TOP-LEFT PIXEL (Y * 320) + X ;
    PUSH    DX  ; save DX, it will be used in MUL

    MOV     CX, 320
    MUL     CX

    POP     DX      ; return original DX
    ADD     AX, DX  ; add X to (Y * 320)
    MOV     DI, AX  ; save (Y * 320) + X in DI

    PUSH    DX              ; save DX in the stack, we will retreive this value to keep track of original parameter
    MOV     DX, 0           ; use DX to keep track of how many pixels have been drawn this line
    LAB_DRAW_LOOP:
        MOV     CL, BYTE [SI]   ; load run length into CL, draw pixel into CH
        MOV     CH, BYTE [SI + 1]

        TEST    CH, CH          ; if the draw pixel is zero, just skip ahead CL pixels. Otherwise, draw pixels CL times
        JZ      LAB_PIXEL_ZERO

        TEST    CL, CL          ; if the first pixel is zero, then it is a newline. 
        JZ      LAB_DRAW_NEWLINE

        LAB_DRAW_PIXEL_LOOP:
            MOV     AX, WORD SS:[BP - 8]    ; load X-param into AX, 4 (4 * 2) stack entries before this
            ADD     AX, DX                  ; if Xpos + drawnPixels >= 319, stop drawing this line. 319 because that's the final index of a row
            CMP     AX, 319
            JAE     lAB_FIND_NEXT_LINE

            MOV     BYTE ES:[DI], CH        ; draw pixel
            AND     BYTE ES:[DI], BL
            MOV     BYTE ES:[DI + 1], CH    ; draw pixel again
            AND     BYTE ES:[DI + 1], BL
            MOV     BYTE ES:[DI + 320], CH  ; drawing 2x2 pixel for every "pixel" of image, so we need to MOV and AND 4 pixels
            AND     BYTE ES:[DI + 320], BL
            MOV     BYTE ES:[DI + 321], CH
            AND     BYTE ES:[DI + 321], BL
            ADD     DI, 2               ; add two to DI
            ADD     DX, 2               ; add two to DX, keeping track of how many pixels were drawn on this line

            DEC     CL                  ; subtract one from CL
        TEST    CL, CL
        JZ      LAB_CONTINUE_DRAW_LOOP  ; if CL is zero, stop loop
        JMP     LAB_DRAW_PIXEL_LOOP

        lAB_FIND_NEXT_LINE:
            MOV     AX, WORD [SI]       ; look at current pixel-chunk
            TEST    AH, AH              ; if second byte (color) is zero, check if this is the end of the picture
            JZ      LAB_CHECK_END_OF_IMAGE
            TEST    AL, AL              ; otherwise, check if the first pixel (run length) is zero. If it is, that is the newline (and where we need to end SI at)
            LAB_NOT_END_OF_IMAGE:
            JNZ     LAB_ITERATE_IMAGE_CHECKER   ; if it is not a newline, iterate SI.
            JMP     LAB_DRAW_NEWLINE            ; if we found our newline, continue drawing

            LAB_CHECK_END_OF_IMAGE:
                TEST    AL, AL              ; if first pixel is zero (and second pixel is zero), stop drawing
                JZ      LAB_STOP_DRAW_LOOP
                JMP     LAB_ITERATE_IMAGE_CHECKER   ; otherwise, just continue

            LAB_ITERATE_IMAGE_CHECKER:
                ADD     SI, 2               ; move SI onto the next pixel
                JMP     lAB_FIND_NEXT_LINE  ; continue looping


             
        LAB_DRAW_NEWLINE:
        ADD     DI, 640             ; move DI down two lines
        SUB     DI, DX              ; subtract DX to set the draw cursor to the original x position
        MOV     DX, 0               ; reset drawnPixels counter
        INC     SI                  ; move onto next byte
        JMP     LAB_DRAW_LOOP

        LAB_PIXEL_ZERO:
        TEST    CL, CL      
        JZ LAB_STOP_DRAW_LOOP   ; if both bytes are zero, then the image has ended, stop the loop
        MOV     CH, 0           ; set CH to zero to make CX = CL
        SHL     CX, 1           ; multiply CX by two
        ADD     DI, CX          ; if only the draw byte is zero, then just move draw cursor forward CL * 2 pixels
        ADD     DX, CX          ; we "drew" this many pixels as well

        LAB_CONTINUE_DRAW_LOOP:
        ADD     SI, 2
        JMP     LAB_DRAW_LOOP

    LAB_STOP_DRAW_LOOP:
    POP DX
    POP CX
    POP DI
    POP ES

    ; COLLAPSE STACK FRAME
    POP     BP
    RET


;************************************************************************************************************************************************************
; VOID CREATE_BULLET(UINT16 YPOS, UINT16 XPOS, UINT16 FLAGS, UINT8 SPEED, UINT8 DAMAGE, NPTR IMAGE)
; creates a bullet at X, Y with a SPEED and flags that control the bullet's behavior. Automatically checks bullet buffer and adds the bullet to a free slot.
;************************************************************************************************************************************************************
; ( PARAMS )
; AX: [UINT16]  YPOS    - the y position of the bullets's top left pixel
; DX: [UINT16]  XPOS    - the x position of the bullet's top left pixel
; CX: [UINT16]  FLAGS   - controls certain behaviors of the bullet
; BH: [UINT8]   SPEED   - how much the position of the bullet is incremented by every frame
; BL: [UINT8]   DAMAGE  - how much damage the bullet does if it collides with something
; SI: [NPTR]    IMAGE   - the offset of the bullet's image from DS
;
FUNC_CREATE_BULLET:
    PUSH DI

    ; CHECK FOR A FREE SLOT IN BULLETS ARRAY (XPOS > 320 OR YPOS > 200) ;
    PUSH    AX                  ; save AX, for computational purposes
    MOV     DI, DAT_BULLET_ARRAY; load array offset into DI

    LAB_CHECK_BULLET_X:
        MOV     AX, 320                             ; screen width=320, so max x=320, so anything above this is free
        CMP     WORD [DI + C_BULLET_X_OFFSET], AX   ; check if DI[i].xPos is above 320
        JA      LAB_SPAWN_BULLET                    ; if so, this slot is free and we can spawn something. Otherwise, check bullet Y
    
    LAB_CHECK_BULLET_Y:
        MOV     AX, 200                             ; screen height=200, so max y=200, so anything above this is free
        CMP     WORD [DI + C_BULLET_Y_OFFSET], AX   ; check if DI[i].yPos is above 200
        JA      LAB_SPAWN_BULLET                    ; if so, this slot is free and we can spawn a bullet here. Otherwise, iterate (or end loop)

        ; ITERATE ;
        ADD     DI, C_BULLET_SIZE_BYTES             ; size of a bullet struct is 8 bytes, go on to next element of DAT_BULLET_ARRAY
        CMP     DI, DAT_END_OF_BULLET_ARRAY
        JAE     LAB_DONT_SPAWN_BULLET               ; if DI is at end of the array, we have reached the end of our loop, we need to terminate
        JMP     LAB_CHECK_BULLET_X                  ; otherwise, continue checking array

    LAB_SPAWN_BULLET:
        POP     AX          ; return old AX value, it's important!
        MOV     WORD [DI + C_BULLET_X_OFFSET], DX       ; create bullet : load X
        MOV     WORD [DI + C_BULLET_Y_OFFSET], AX       ; create bullet : load Y
        MOV     WORD [DI + C_BULLET_FLAGS_OFFSET], CX   ; create bullet : load flags
        MOV     WORD [DI + C_BULLET_IMAGE_OFFSET], SI   ; create bullet : load image
        MOV     BYTE [DI + C_BULLET_SPEED_OFFSET], BH   ; create bullet : load speed
        MOV     BYTE [DI + C_BULLET_DAMAGE_OFFSET], BL  ; create bullet : load damage

        JMP LAB_BULLET_RET

    LAB_DONT_SPAWN_BULLET:
    POP AX          ; we cannot spawn a bullet; prevent stack corruption
    LAB_BULLET_RET:
    POP DI
    RET


;************************************************************************************************************************************************************
; VOID RENDER_SCREEN(UINT8 BITMASK)
; renders the entire screen, looping through bullets, enemies, and the player, as well as score. Has a bitmask for clearing old screen.
;************************************************************************************************************************************************************
; ( PARAMS )
; BL: [UINT8]   BITMASK     - the bitmask to apply to any pixels drawn in this function.
;
FUNC_RENDER_SCREEN:
    PUSH    AX
    PUSH    CX
    PUSH    DX
    PUSH    SI
    PUSH    DI

    ; UPDATE PLAYER STATS ;

    ; DRAW PLAYER ;
    MOV     AX, WORD [DAT_PLAYER_POS_Y]     ; PARAM: DRAW Y
    MOV     DX, WORD [DAT_PLAYER_POS_X]     ; PARAM: DRAW X
    MOV     SI, IMG_PLAYER_SPACESHIP        ; PARAM: IMAGE (RLE-encoded)
    CALL    FUNC_DRAW_IMAGE                 ; Draw spaceship

    ; DRAW ENEMIES ;

    
    ; DRAW BULLETS ;
    MOV     DI, DAT_BULLET_ARRAY            ; LOOP THROUGH BULLET ARRAY
    LAB_DRAW_BULLET_LOOP:
        LAB_DRAW_CHECK_BULLET_X:
            MOV     AX, WORD [DI + C_BULLET_X_OFFSET]   ; Check if bullet X is valid (X <= 320)
            CMP     AX, 320
            JA      LAB_DRAW_BULLET_CONTINUE            ; if X is bigger than 320, this bullet is invalid
            
        LAB_DRAW_CHECK_BULLET_Y:
            MOV     AX, WORD [DI + C_BULLET_Y_OFFSET]   ; check if bullet Y is valid (Y <= 200)
            CMP     AX, 200
            JA     LAB_DRAW_BULLET_CONTINUE             ; if Y is bigger than 200, this bullet is invalid

        LAB_DRAW_BULLET:
            MOV     AX, WORD [DI + C_BULLET_Y_OFFSET]       ; PARAM: DRAW Y
            MOV     DX, WORD [DI + C_BULLET_X_OFFSET]       ; PARAM: DRAW X
            MOV     SI, WORD [DI + C_BULLET_IMAGE_OFFSET]   ; PARAM: IMAGE (RLE-encoded)
            CALL    FUNC_DRAW_IMAGE

        LAB_DRAW_BULLET_CONTINUE:
            ADD     DI, C_BULLET_SIZE_BYTES             ; iterate to next element of BULLET ARRAY
            CMP     DI, DAT_END_OF_BULLET_ARRAY         ; if we're at the end of BULLET ARRAY, terminate loop
            JB      LAB_DRAW_BULLET_LOOP                      

    ; DRAW SCORE ;


    POP     DI
    POP     SI
    POP     DX
    POP     CX
    POP     AX
    RET