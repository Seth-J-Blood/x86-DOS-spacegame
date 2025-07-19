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

C_FLAG_VGA_RETRACE      EQU 3       ; bit three of port 0x3DA indicates whether a vertical retrace is occurring

;************************************************************************************************************************************************************
;                                                                       ( CONSTANTS )
;************************************************************************************************************************************************************
; MISC CONSTANTS ;
C_VRETRACE_PORT             EQU 0x3DA  
C_HURT_FLASH_DURATION       EQU 1           ; how many frames a flash effect is displayed for when an entity takes damage

; PLAYER CONSTANTS ;
C_PLAYERDATA_WIDTH          EQU 32          ; player spaceship image is 32x12
C_PLAYERDATA_HEIGHT         EQU 12
C_PLAYERDATA_MIN_POS_X      EQU C_PLAYERDATA_MOVE_BOOST_PIX ; Do NOT set lower than C_PLAYERDATA_MOVE_BOOST_PIX or goofy shit happens
C_PLAYERDATA_MAX_POS_X      EQU (320 - C_PLAYERDATA_WIDTH)
C_PLAYERDATA_MIN_POS_Y      EQU 20          ; 20 pixels of space for score display
C_PLAYERDATA_MAX_POS_Y      EQU (200 - C_PLAYERDATA_HEIGHT)
C_PLAYERDATA_DODGE_FRAMES   EQU 5           ; how many frames the player's ship is invulnerable for when dodging
C_PLAYERDATA_HIT_FRAMES     EQU 30          ; how many frames the player's ship is invulnerable for after being hit
C_PLAYERDATA_MOVE_PIX       EQU 2           ; how many pixels per frame the ship moves when a movement key is held down (and ship is not boosting)
C_PLAYERDATA_MOVE_BOOST_PIX EQU 5           ; how many pixels per frame the ship moves when a movement key is held down (and ship is boosting)
C_PLAYERDATA_BOOST_REFRESH  EQU 2           ; how much the boost refreshes every frame if not being used
C_PLAYERDATA_BOOST_USAGE    EQU 5           ; how much boost gets used every frame while being used
C_PLAYERDATA_MAX_BOOST      EQU 300
C_PLAYERDATA_FIRERATE       EQU 10           ; how many frames in between player attacks. DO NOT MAKE MORE THAN 255
C_PLAYERDATA_BULLET_X_OFF   EQU C_PLAYERDATA_WIDTH      ; how much to add to spawned bullets' x positions
C_PLAYERDATA_BULLET_Y_OFF   EQU C_PLAYERDATA_HEIGHT - 2 ; how much to add to spawned bullets' y positions
C_PLAYERDATA_BULLET_SPEED   EQU 6
C_PLAYERDATA_BULLET_DAMAGE  EQU 3
C_PLAYERDATA_MAX_HEALTH     EQU 500
C_PLAYERDATA_INVULN_FRAMES  EQU 30          ; for how many frames the player is invulnerable after taking damage

; PLAYER FLAGS ;
C_PLAYERFLAG_HAS_RELEASED_DODGE         EQU 0       ; whether or not the player has released the dodge button since their last dodge (to prevent holding down the dodge button)
C_PLAYERFLAG_WAS_DAMAGED_LAST_FRAME     EQU 1       ; name explains it all lol

; BULLET CONSTANTS ;
C_BULLET_MAX_BULLETS        EQU 30
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


; ENEMY CONSTANTS ;
C_ENEMY_MAX_ENEMIES         EQU 15
C_ENEMY_SIZE_BYTES          EQU 20
C_ENEMY_X_OFFSET            EQU 0       ; word
C_ENEMY_Y_OFFSET            EQU 2       ; word
C_ENEMY_HURT_FRAMES_OFFSET  EQU 4       ; byte
C_ENEMY_FLAGS_OFFSET        EQU 5       ; byte
C_ENEMY_IMAGE_OFFSET        EQU 6       ; word
C_ENEMY_HEALTH_OFFSET       EQU 8       ; word
C_ENEMY_SPEED_OFFSET        EQU 10      ; byte
C_ENEMY_DAMAGE_OFFSET       EQU 11      ; byte
C_ENEMY_CODE_OFFSET         EQU 12      ; word
C_ENEMY_SCORE_WORTH_OFFSET  EQU 14      ; word
C_ENEMY_ATTACK_FRAME_OFFSET EQU 16      ; byte
C_ENEMY_FIRERATE_OFFSET     EQU 17      ; byte
C_ENEMY_IMAGE_WIDTH_OFFSET  EQU 18      ; byte
C_ENEMY_IMAGE_HEIGHT_OFFSET EQU 19      ; byte


;************************************************************************************************************************************************************
;                                                                   ( .DATA SECTION )
;************************************************************************************************************************************************************
    DAT_KEY_STATES                      DB  0x00                    ; [FLAGS8] contains key states. See C_FLAGs for flag bit offsets

    DAT_PLAYER_FLAGS                    DB  0x00                    ; [FLAGS8] contains states about the player
    DAT_PLAYER_POS_X                    DW  50                      ; [UINT16] the x-position of the top-left pixel of the player
    DAT_PLAYER_POS_Y                    DW  50                      ; [UINT16] the y-position of the top-left pixel of the player
    DAT_PLAYER_HEALTH                   DW  C_PLAYERDATA_MAX_HEALTH ; [UINT16] the current health of the player. If this reaches zero, the player dies
    DAT_PLAYER_SCORE                    DW  0                       ; [UINT16] the current score of the player
    DAT_PLAYER_BOOST_REMAINING          DW  C_PLAYERDATA_MAX_BOOST  ; [UINT16] how much boost the player has left. Every frame unused, boost goes up 1. Every frame used, boost goes down 5.
    DAT_PLAYER_DODGE_FRAMES_REMAINING   DB  0                       ; [UINT8] how many frames of invulnerability the player has remaining. FPS = 30
    DAT_PLAYER_FRAMES_SINCE_LAST_ATTACK DB  C_PLAYERDATA_FIRERATE   ; [UINT8] how many frames have passed since the user attacked last. Capped at FIRERATE.
    DAT_PLAYER_FRAMES_SINCE_LAST_HURT   DB  0xF0                    ; [UINT8] how many frames have passed since the user got hit last. Capped at INVULN_FRAMES.
                                        DB  0                       ; (placeholder for aligning data)

    DAT_DEBUG_PIXEL_X                   DW  0

    IMG_PLAYER_SPACESHIP                DB  4, 0x00, 2, 0x19, 0
                                        DB  1, 0x00, 3, 0x2A, 1, 0x36, 2, 0x19, 0
                                        DB  2, 0x2A, 2, 0x2B, 1, 0x36, 6, 0x19, 2, 0x0B, 0 
                                        DB  2, 0x00, 2, 0x2A, 1, 0x36, 1, 0x19, 4, 0x1A, 5, 0x19, 0
                                        DB  4, 0x00, 7, 0x19, 2, 0x14, 2, 0x19, 0
                                        DB  5, 0x00, 1, 0x36, 8, 0x19, 0, 0

    IMG_PLAYER_DEAD                     DB 8, 0x00, 1, 0x2A, 0
                                        DB 4, 0x00, 1, 0x19, 3, 0x00, 2, 0x2A, 1, 0x00, 1, 0x2A, 0
                                        DB 4, 0x00, 1, 0x36, 2, 0x19, 1, 0x2A, 1, 0x2B, 2, 0x2A, 1, 0x2B, 0
                                        DB 5, 0x00, 2, 0x19, 1, 0x2A, 1, 0x2B, 1, 0x2A, 2, 0x2B, 1, 0x2A, 1, 0x00, 1, 0x2A, 0
                                        DB 4, 0x00, 1, 0x36, 1, 0x19, 1, 0x2B, 3, 0x1A, 1, 0x19, 1, 0x2B, 1, 0x2A, 1, 0x2B, 1, 0x2A, 0
                                        DB 5, 0x00, 5, 0x19, 1, 0x2B, 2, 0x14, 1, 0x2B, 1, 0x19, 0
                                        DB 7, 0x00, 5, 0x19, 0, 0

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

    IMG_HEALTH_UNDERBAR                 DB  22, 0x0C, 0
                                        DB  22, 0x0C, 0, 0

    IMG_HEALTH_TEXT                     DB 1, 0x26, 1, 0x00, 1, 0x26, 1, 0x00, 3, 0x26, 2, 0x00, 1, 0x26, 2, 0x00, 1, 0x26, 2, 0x00, 3, 0x26, 1, 0x00, 1, 0x26, 1, 0x00, 1, 0x26, 0
                                        DB 1, 0x26, 1, 0x00, 1, 0x26, 1, 0x00, 1, 0x26, 3, 0x00, 1, 0x26, 1, 0x00, 1, 0x26, 1, 0x00, 1, 0x26, 3, 0x00, 1, 0x26, 2, 0x00, 1, 0x26, 1, 0x00, 1, 0x26, 1, 0x00, 1, 0x26, 0
                                        DB 3, 0x26, 1, 0x00, 2, 0x26, 2, 0x00, 3, 0x26, 1, 0x00, 1, 0x26, 3, 0x00, 1, 0x26, 2, 0x00, 3, 0x26, 0
                                        DB 1, 0x26, 1, 0x00, 1, 0x26, 1, 0x00, 1, 0x26, 3, 0x00, 1, 0x26, 1, 0x00, 1, 0x26, 1, 0x00, 1, 0x26, 3, 0x00, 1, 0x26, 2, 0x00, 1, 0x26, 1, 0x00, 1, 0x26, 1, 0x00, 1, 0x26, 0
                                        DB 1, 0x26, 1, 0x00, 1, 0x26, 1, 0x00, 3, 0x26, 1, 0x00, 1, 0x26, 1, 0x00, 1, 0x26, 1, 0x00, 2, 0x26, 2, 0x00, 1, 0x26, 2, 0x00, 1, 0x26, 1, 0x00, 1, 0x26, 0, 0

    ; HEIGHT: 8 (16px)
    ; WIDTH : 13(26px)
                                        DB 26, 8    ; width, height
    IMG_ALIEN_SPITTER                   DB 2, 0x00, 1, 0x22, 2, 0x00, 3, 0x22, 0
                                        DB 1, 0x00, 1, 0x22, 1, 0x00, 6, 0x22, 3, 0x23, 0
                                        DB 2, 0x23, 2, 0x00, 1, 0x22, 2, 0x0F, 1, 0x22, 2, 0x23, 0
                                        DB 3, 0x00, 1, 0x23, 1, 0x0F, 1, 0x26, 2, 0x0F, 1, 0x22, 3, 0x23, 0
                                        DB 3, 0x00, 1, 0x23, 1, 0x0F, 1, 0x26, 2, 0x0F, 1, 0x22, 2, 0x23, 0
                                        DB 2, 0x23, 2, 0x00, 1, 0x22, 2, 0x0F, 1, 0x22, 1, 0x23, 1, 0x22, 3, 0x23, 0
                                        DB 1, 0x00, 1, 0x22, 1, 0x00, 6, 0x22, 2, 0x23, 0
                                        DB 2, 0x00, 1, 0x22, 2, 0x00, 3, 0x22, 0, 0

                                        DB 20, 10   ; width, height
    IMG_ALIEN_CHARGER                   DB 1, 0x06, 1, 0x22, 1, 0x00, 3, 0x22, 0
                                        DB 2, 0x00, 1, 0x22, 3, 0x23, 1, 0x22, 0
                                        DB 1, 0x00, 1, 0x06, 2, 0x22, 1, 0x08, 1, 0x0F, 1, 0x23, 2, 0x22, 2, 0x06, 0
                                        DB 2, 0x00, 1, 0x22, 3, 0x23, 1, 0x22, 0
                                        DB 1, 0x06, 1, 0x22, 1, 0x00, 3, 0x22, 0


    IMG_NUMBERMAP                       DB 0xFF, 0xFF, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
                                        DB 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0x00, 0xFF
                                        DB 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
                                        DB 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0xFF, 0x00, 0x00, 0xFF, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0x00, 0xFF
                                        DB 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF

    DAT_BULLET_ARRAY                    TIMES C_BULLET_MAX_BULLETS * (C_BULLET_SIZE_BYTES / 2) DW 0xFFFF    ; 0xFFFF (above 320/200) for pos data means free slot
    DAT_END_OF_BULLET_ARRAY:

    DAT_ENEMY_ARRAY                     TIMES C_ENEMY_MAX_ENEMIES * (C_ENEMY_SIZE_BYTES / 2) DW 0xFFFF
    DAT_END_OF_ENEMY_ARRAY:

    STR_QUIT_MSG                        DB  'Shutdown was initiated! Error code: ?', 0x0A, 0x0D, '$'
    STR_DEBUG_MSG                       DB  '!DEBUG!', 0x0A, 0x0D, '$'

    ALL_ENEMY_STATS:
    STRUCT_ENEMY_SPITTER:
        DW  150                 ; SCORE WORTH
        DW  35                  ; HEALTH
        DB  0                   ; FLAGS
        DB  15                  ; FIRERATE
        DW  IMG_ALIEN_SPITTER   ; IMAGE
        DB  1                   ; SPEED
        DB  3                   ; DAMAGE
        DW  AI_ALIEN_SPITTER    ; CODE


;************************************************************************************************************************************************************
;                                                               ( UNINITIALIZED DATA SECTION )
;************************************************************************************************************************************************************
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
    XOR AX, AX              ; IVT segment
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

    ; DRAW TEXT : "SCORE:" ONTO SCREEN ;
    MOV     AX, 2               ; PARAM: Y POSITION
    MOV     DX, 2               ; PARAM: X POSITION
    MOV     SI, IMG_SCORE_TEXT  ; PARAM: IMAGE (RL-encoded)
    MOV     BL, 0xFF            ; PARAM: BITMASK
    XOR     BH, BH              ; PARAM: ORMASK
    CALL    FUNC_DRAW_IMAGE

    ; DRAW TEXT: "BOOST:" ONTO SCREEN ;
    MOV     AX, 2               ; PARAM: Y POSITION
    MOV     DX, 260             ; PARAM: X POSITION
    MOV     SI, IMG_BOOST_TEXT  ; PARAM: IMAGE (RL-encoded)
    MOV     BL, 0xFF            ; PARAM: BITMASK
    XOR     BH, BH              ; PARAM: ORMASK
    CALL    FUNC_DRAW_IMAGE

    ; DRAW BOOST BAR BACKGROUND ONTO SCREEN ;
    MOV     AX, 14                  ; PARAM: Y POSITION
    MOV     DX, 260                 ; PARAM: X POSITION
    MOV     SI, IMG_BOOST_OUTLINE   ; PARAM: IMAGE (RL-encoded)
    MOV     BL, 0xFF                ; PARAM: BITMASK
    XOR     BH, BH                  ; PARAM: ORMASK
    CALL    FUNC_DRAW_IMAGE

    ; DRAW TEXT: "HEALTH:" ONTO SCREEN ;
    MOV     AX, 2               ; PARAM: Y POSITION
    MOV     DX, 200             ; PARAM: X POSITION
    MOV     SI, IMG_HEALTH_TEXT ; PARAM: IMAGE (RL-encoded)
    MOV     BL, 0xFF            ; PARAM: BITMASK
    XOR     BH, BH              ; PARAM: ORMASK
    CALL    FUNC_DRAW_IMAGE

    MOV     AX, 4
    MOV     DX, 72
    MOV     BL, 0x2C
    XOR     CX, CX
    CALL    FUNC_DISPLAY_DEC_NUMBER

    ; DRAW HEALTH BAR BACKGROUND ONTO SCREEN ;
    MOV     AX, 14                  ; PARAM: Y POSITION
    MOV     DX, 200                 ; PARAM: X POSITION
    MOV     SI, IMG_BOOST_OUTLINE   ; PARAM: IMAGE (RL-encoded)
    MOV     BL, 0xFF                ; PARAM: BITMASK
    XOR     BH, BH                  ; PARAM: ORMASK
    CALL    FUNC_DRAW_IMAGE

    ; TEST: CREATE ENEMY ;
    MOV     AX, 50                  ; PARAM: Y POSITION
    MOV     DX, 200                 ; PARAM: X POSITION
    MOV     CX, 150                 ; PARAM: SCORE
    PUSH    35                      ; PARAM: HEALTH
    MOV     BL, 3                   ; PARAM: DAMAGE
    MOV     BH, 1                   ; PARAM: SPEED
    MOV     SI, IMG_ALIEN_SPITTER   ; PARAM: IMAGE (RL-encoded)
    PUSH    AI_ALIEN_SPITTER        ; PARAM: AI CODE
    PUSH    0x00 | (60 << 8)        ; PARAM: FLAGS + FIRERATE
    CALL    FUNC_CREATE_ENEMY

    ; START MAIN LOOP ;
    ; * this automatically goes to LOGIC_STEP() * ;


;************************************************************************************************************************************************************
; VOID LOGIC_STEP()
; handles all key flags and updates all entities according to the game's current state. Should be called once a frame, at 30 FPS.
;************************************************************************************************************************************************************
; ( PARAMS )
; NONE
;
FUNC_LOGIC_STEP:
    ; CHECK PLAYER KEY STATES AND UPDATE PLAYER STATS BASED ON THEM ;

    XOR     BL, BL      ; PARAM: BITMASK
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
        BTR     WORD DS:[DAT_KEY_STATES], C_FLAG_BOOST      ; turn off boost hold flag, even if the player is holding it
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
        XOR     BH, BH                                      ; set frames since last attack to 15
        MOV     BYTE [DAT_PLAYER_FRAMES_SINCE_LAST_ATTACK], BH  

        MOV     AX, WORD [DAT_PLAYER_POS_Y]                 ; PARAM: DRAW Y
        ADD     AX, C_PLAYERDATA_BULLET_Y_OFF                   ; PARAM: ADD Y OFFSET TO BULLET Y
        MOV     DX, WORD [DAT_PLAYER_POS_X]                 ; PARAM: DRAW X
        ADD     DX, C_PLAYERDATA_BULLET_X_OFF                   ; PARAM: ADD X OFFSET TO BULLET X
        MOV     SI, IMG_PLAYER_BULLET                       ; PARAM: IMAGE (RL-encoded)
        XOR     CX, CX                                      ; PARAM: FLAGS
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

    ; ********************************** ;
    ; HANDLE ENEMY MOVEMENT AND COLLISON ;
    ; ********************************** ;  
    MOV     SI, DAT_ENEMY_ARRAY
    ; HANDLE PLAYER HURT STATUS ;
    CMP     BYTE DS:[DAT_PLAYER_FRAMES_SINCE_LAST_HURT], C_PLAYERDATA_INVULN_FRAMES  ; don't tick hurt frames past C_PLAYERDATA_INVULN_FRAMES + 1
    JA      LAB_TICK_ENEMY_LOOP
    INC     BYTE DS:[DAT_PLAYER_FRAMES_SINCE_LAST_HURT]

    LAB_TICK_ENEMY_LOOP:
        ; CHECK IF ENEMY X IS VALID ;
        CMP     WORD DS:[SI + C_ENEMY_X_OFFSET], 320    ; if enemy.x >= 320, it is invalid and should not be dealt with.
        JAE     LAB_CONTINUE_ENEMY_LOOP
        
        ; CHECK IF ENEMY Y IS VALID ;
        CMP     WORD DS:[SI + C_ENEMY_Y_OFFSET], 200    ; if enemy.y >= 200, it is invalid and should not be dealt with.
        JAE     LAB_CONTINUE_ENEMY_LOOP
    
        ; **** TICK ENEMY AI **** ;
        MOV     BX, WORD CS:[SI + C_ENEMY_CODE_OFFSET]
        CALL    BX

        ; **** TICK ENEMY HURT FRAMES **** ;
        CMP     BYTE DS:[SI + C_ENEMY_HURT_FRAMES_OFFSET], C_HURT_FLASH_DURATION
        JA      LAB_NO_ENEMY_HURT_TICK                  ; if enemy.hurtFrames >= C_HURT_FLASH_DURATION, do not increment frames.
        INC     BYTE DS:[SI + C_ENEMY_HURT_FRAMES_OFFSET]

        LAB_NO_ENEMY_HURT_TICK:
        ; **** HANDLE COLLISIONS **** ;
        ; CHECK PLAYER INVULNERABILITY STATUS ;
        CMP     BYTE DS:[DAT_PLAYER_FRAMES_SINCE_LAST_HURT], C_PLAYERDATA_INVULN_FRAMES
        JNA     LAB_CONTINUE_ENEMY_LOOP                ; 

        ; CHECK ENEMY X - if enemy.X - player.X >= 0 && enemy.X - player.X < player.width
        MOV     AX, WORD DS:[SI + C_ENEMY_X_OFFSET]     ; load enemy X into AX
        SUB     AX, WORD DS:[DAT_PLAYER_POS_X]          ; perform enemy.X - player.X
        ADD     AX, C_PLAYERDATA_WIDTH - 2
        CMP     AX, (C_PLAYERDATA_WIDTH - 2) * 2        ; compare to player width
        JAE     LAB_CONTINUE_ENEMY_LOOP                 ; if X is not colliding, continue loop

        ; CHECK ENEMY Y - if enemy.Y - player.Y >= 0 && enemy.Y - player.Y < player.height
        MOV     AX, WORD DS:[SI + C_ENEMY_Y_OFFSET]     ; load enemy Y into AX
        SUB     AX, WORD DS:[DAT_PLAYER_POS_Y]          ; perform enemy.Y - player.Y
        ADD     AX, C_PLAYERDATA_HEIGHT
        CMP     AX, (C_PLAYERDATA_HEIGHT) * 2           ; compare to player width
        JAE     LAB_CONTINUE_ENEMY_LOOP                 ; if Y is not colliding, continue loop
        
        ; ENEMY IS COLLIDING, DEAL enemy.health DAMAGE TO player.health ;
        MOV     AX, WORD DS:[SI + C_ENEMY_HEALTH_OFFSET]
        SUB     WORD DS:[DAT_PLAYER_HEALTH], AX
        MOV     AX, WORD DS:[SI + C_ENEMY_SCORE_WORTH_OFFSET]
        MOV     BYTE DS:[DAT_PLAYER_FRAMES_SINCE_LAST_HURT], 0
        ADD     WORD DS:[DAT_PLAYER_SCORE], AX          ; add enemy score worth to player score
        MOV     WORD DS:[SI + C_ENEMY_X_OFFSET], 0xFFFF ; kill enemy, it collided

        LAB_CONTINUE_ENEMY_LOOP:
            ADD     SI, C_ENEMY_SIZE_BYTES      ; increment iterator to point to the next enemy
            CMP     SI, DAT_END_OF_ENEMY_ARRAY  ; if SI >= end of array, terminate loop
            JNAE    LAB_TICK_ENEMY_LOOP

    ; *********************************** ;
    ; HANDLE BULLET MOVEMENT AND COLLISON ;
    ; *********************************** ;
    MOV     SI, DAT_BULLET_ARRAY
    LAB_MOVE_BULLET_LOOP:
        ; CHECK IF BULLET X IS VALID ;
        CMP     WORD [SI + C_BULLET_X_OFFSET], 320     ; if bullet.x > 320, it is invalid and should not be dealt with.
        JA      LAB_CONTINUE_BULLET_LOOP

        ; CHECK IF BULLET Y IS VALID ;
        CMP     WORD [SI + C_BULLET_Y_OFFSET], 200     ; if bullet.y > 200, it is invalid and should not be dealt with.
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
        JMP     LAB_HANDLE_BULLET_COLLISION

        LAB_MOVE_BULLET_POS:
        MOVZX   CX, BYTE [SI + C_BULLET_SPEED_OFFSET]   ; move speed into CX (position field is a word, so speed needs to be a word as well)
        ADD     DS:[BX], CX                             ; add speed to axis

        ; ****** HANDLE BULLET COLLISON ****** ;
        LAB_HANDLE_BULLET_COLLISION:
        BT      AX, C_BULLET_FLAG_HOSTILE               ; if the bullet is hostile, check for collisions against player. Otherwise, check against all enemies.
        JC      LAB_COLLIDE_HOSTILE_BULLET

        LAB_COLLIDE_FRIENDLY_BULLET:
            ; LOOP THROUGH ENEMY ARRAY ;
            MOV     DI, DAT_ENEMY_ARRAY
            LAB_COLLIDE_ENEMY_LOOP:
                
                ; CHECK THAT ENEMY IS VALID ;
                ; CHECK X ;
                MOV     CX, WORD DS:[DI + C_ENEMY_X_OFFSET]     ; load enemy.X into CX
                CMP     CX, 320                                 ; if enemy.X >= 320, enemy is invalid, do not check
                JAE     LAB_COLLIDE_ENEMY_LOOP_CONTINUE         ; continue if enemy is invalid

                ; CHECK Y ;
                MOV     CX, WORD DS:[DI + C_ENEMY_Y_OFFSET]     ; load enemy.Y into CX
                CMP     CX, 200                                 ; if enemy.Y >= 200, enemy is invalid, do not check
                JAE     LAB_COLLIDE_ENEMY_LOOP_CONTINUE         ; continue if enemy is invalid

                ; CHECK COLLISION ;
                ; CHECK BULLET Y ;
                MOV     CX, WORD DS:[SI + C_BULLET_Y_OFFSET]    ; load bullet.Y into CX
                SUB     CX, WORD DS:[DI + C_ENEMY_Y_OFFSET]     ; subtract enemy.Y from bullet.Y
                CMP     CX, 16                                  ; compare bullet Y to enemy height
                JA      LAB_COLLIDE_ENEMY_LOOP_CONTINUE         ; unsigned compare, handles negative values and values above enemy.height

                ; CHECK BULLET X ;
                MOV     CX, WORD DS:[SI + C_BULLET_X_OFFSET]    ; load bullet.X into CX
                SUB     CX, WORD DS:[DI + C_ENEMY_X_OFFSET]     ; subtract enemy.X from bullet.X
                CMP     CX, 26                                  ; compare bullet X to enemy height
                JA      LAB_COLLIDE_ENEMY_LOOP_CONTINUE         ; unsigned compare, handles negative values and values above enemy.height

                ; COLLIDE! ;
                MOV     WORD DS:[SI + C_BULLET_X_OFFSET], 0xFFFF    ; invalidate bullet
                MOVZX   CX, BYTE DS:[SI + C_BULLET_DAMAGE_OFFSET]   ; load damage into CX
                SUB     WORD DS:[DI + C_ENEMY_HEALTH_OFFSET], CX    ; damage enemy
                MOV     BYTE DS:[DI + C_ENEMY_HURT_FRAMES_OFFSET], 0; set enemy hurt frames to zero
                CMP     WORD DS:[DI + C_ENEMY_HEALTH_OFFSET], 0     ; if health is lower than or equal to 0, delete enemy
                JG      LAB_CONTINUE_BULLET_LOOP                    
                MOV     CX, WORD DS:[DI + C_ENEMY_SCORE_WORTH_OFFSET]
                ADD     WORD DS:[DAT_PLAYER_SCORE], CX              ; add enemy score worth to player score
                MOV     WORD DS:[DI + C_ENEMY_X_OFFSET], 0xFFFF     ; invalidate enemy
                JMP     LAB_CONTINUE_BULLET_LOOP                    ; this bullet is dead, continue outer loop

                LAB_COLLIDE_ENEMY_LOOP_CONTINUE:
                    ADD     DI, C_ENEMY_SIZE_BYTES          ; increment iterator to the next element of enemy array
                    CMP     DI, DAT_END_OF_ENEMY_ARRAY      ; if iterator >= end of array, terminate loop
                    JAE     LAB_CONTINUE_BULLET_LOOP
                    JMP     LAB_COLLIDE_ENEMY_LOOP          ; otherwise, continue outer loop

        LAB_COLLIDE_HOSTILE_BULLET:
            ; CHECK PLAYER INVULNERABILITY STATUS ;
            CMP     BYTE DS:[DAT_PLAYER_FRAMES_SINCE_LAST_HURT], C_PLAYERDATA_INVULN_FRAMES  
            JNA     LAB_CONTINUE_BULLET_LOOP                ; if player is still invulnerable (frames since last hurt < INVULN_FRAMES), don't even bother with collisions.

            ; CHECK BULLET Y ;
            ; if(bullet.y - player.y >= 0 && bullet.y - player.y <= player.height), check X axis
            MOV     CX, WORD DS:[SI + C_BULLET_Y_OFFSET]    ; load bullet.Y into CX
            SUB     CX, WORD DS:[DAT_PLAYER_POS_Y]          ; perform bullet.Y - player.Y
            CMP     CX, C_PLAYERDATA_HEIGHT                 ; compare difference to player height
            JA      LAB_CONTINUE_BULLET_LOOP                ; unsigned comparison to handle both values below 0 and above player.height

            ; CHECK BULLET X ;
            ; if(bullet.x - player.x >= 0 && bullet.x - player.x <= player.width), we are colliding
            MOV     CX, WORD DS:[SI + C_BULLET_X_OFFSET]    ; load bullet.X into CX
            SUB     CX, WORD DS:[DAT_PLAYER_POS_X]          ; perform bullet.X - player.X
            CMP     CX, C_PLAYERDATA_WIDTH                  ; compare difference to player width
            JA      LAB_CONTINUE_BULLET_LOOP                ; unsigned comparison to handle both values below 0 and above player.width

            ; COLLIDE! ;
            MOV     WORD DS:[SI + C_BULLET_X_OFFSET], 0xFFFF    ; invalidate bullet
            MOV     WORD DS:[DAT_PLAYER_FRAMES_SINCE_LAST_HURT], 0  ; set frames since last damages to zero
            MOVZX   CX, BYTE DS:[SI + C_BULLET_DAMAGE_OFFSET]   ; load damage into CX
            SUB     WORD DS:[DAT_PLAYER_HEALTH], CX             ; do damage to player

        LAB_CONTINUE_BULLET_LOOP:
            ADD     SI, C_BULLET_SIZE_BYTES ; iterate to next element of bullet array
            CMP     SI, DAT_END_OF_BULLET_ARRAY
            JAE     LAB_RENDER_SCREEN       ; if element iterator position >= DAT_END_OF_BULLET_ARRAY, we have reached end of array and need to terminate.
            JMP     LAB_MOVE_BULLET_LOOP

    LAB_RENDER_SCREEN:
    ; UPDATE PLAYER HEALTH BAR AND PLAYER BOOST BAR ;   
    ; DRAW HEALTH BAR UNDERBAR ONTO SCREEN
    MOV     AX, 16                  ; PARAM: Y POSITION
    MOV     DX, 202                 ; PARAM: X POSITION
    MOV     SI, IMG_HEALTH_UNDERBAR ; PARAM: IMAGE (RL-encoded)
    MOV     BL, 0xFF                ; PARAM: BITMASK
    XOR     BH, BH                  ; PARAM: ORMASK
    CALL    FUNC_DRAW_IMAGE

    ; DRAW HEALTH BAR ONTO SCREEN
    MOV     AX, 0xA000
    MOV     ES, AX                          ; VGA segment
    MOV     AX, (16 * 320) + 202            ; coords (202, 16)
    MOV     DI, AX

    ; GET NUMBER OF PIXELS TO DISPLAY TO SCREEN: (44 * HEALTH)/MAX_HEALTH
    MOV     AX, WORD [DAT_PLAYER_HEALTH]

    MOV     BX, 44                      ; multiply AX by 44
    MUL     BX

    MOV     BX, C_PLAYERDATA_MAX_HEALTH ; divide AX by MAX_HEALTH
    DIV     BX
    
    MOV     BX, AX                      ; save result in BX
    MOV     CX, AX                      ; loop: display AX pixels to screen
    MOV     AL, 0x2F                    ; green bar
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

    ; DRAW BOOST BAR UNDERBAR ONTO SCREEN
    MOV     AX, 16                  ; PARAM: Y POSITION
    MOV     DX, 262                 ; PARAM: X POSITION
    MOV     SI, IMG_BOOST_UNDERBAR  ; PARAM: IMAGE (RL-encoded)
    MOV     BL, 0xFF                ; PARAM: BITMASK
    XOR     BH, BH                   ; PARAM: ORMASK
    CALL    FUNC_DRAW_IMAGE

    ; DRAW BOOST BAR ONTO SCREEN
    MOV     AX, 0xA000
    MOV     ES, AX                      ; VGA segment
    MOV     AX, (16 * 320) + 262        ; coords (262, 16)
    MOV     DI, AX

    ; GET NUMBER OF PIXELS TO DISPLAY TO SCREEN: (44 * BOOST)/MAX_BOOST
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
; burns cycles until a new frame can be stepped, as determined by the VGA screen's V-REFRESH rate (usually 60Hz). Skips every other frame for 30 FPS.
;************************************************************************************************************************************************************
; ( PARAMS )
; NONE
;
FUNC_FRAME_WAIT:
    XOR     CX, CX                      ; use this as our retrace counter - we want to run at about 30 FPS, so wait for two retraces before drawing
    MOV     DX, C_VRETRACE_PORT     
    LAB_CHECK_VGA_STATUS:
        IN      AX, DX                  ; load VGA status flags into AL
        BT      AX, C_FLAG_VGA_RETRACE  ; check if a VGA retrace is occurring. If it is, wait until it is not (to ensure we don't start at the end of a retrace and lose time)
        JC      LAB_CHECK_VGA_STATUS
    INC     CX                      ; oop- a VGA retrace is no longer occurring! Wait until a new one does occur and then loop this again (skip one refesh)
    LAB_WAIT_FOR_VGA_DRAW:
        IN      AX, DX                  ; load VGA status flags into AL
        BT      AX, C_FLAG_VGA_RETRACE  ; check if a VGA retrace is occurring. If it is, check if CX == 2. If it is not, loop LAB_CHECK_VGA_STATUS again. Otherwise, call FUNC_LOGIC_STEP
        JNC     LAB_WAIT_FOR_VGA_DRAW   ; if a VGA retrace has not occurred yet, check again
        CMP     CX, 2                   
        JNE     LAB_CHECK_VGA_STATUS    ; if CX != 2, wait for another retrace to occur before stepping login
        JMP     FUNC_LOGIC_STEP         ; if CX == 2, we can step logic


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
    XOR AX, AX          ; load IVT segment into ES
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
; draws a RL-encoded sprite to the screen, ending on the first double zero. Each line ends at a zero. Images do not wrap around screen.
;************************************************************************************************************************************************************
; ( PARAMS )
; AX: [UINT16]  YPOS    - the y position of the image's top left pixel
; DX: [UINT16]  XPOS    - the x position of the image's top left pixel
; BL: [UINT8]   BITMASK - the bitmask applied to drawn pixels on the screen.
; BH: [UINT8]   ORMASK  - the value to be or'd onto any pixel value displayed in the entity (besides transparent pixels). Applied before bitmask.
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
    XOR     DX, DX          ; use DX to keep track of how many pixels have been drawn this line
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
            OR      BYTE ES:[DI], BH
            AND     BYTE ES:[DI], BL
            MOV     BYTE ES:[DI + 1], CH    ; draw pixel again
            OR      BYTE ES:[DI + 1], BH
            AND     BYTE ES:[DI + 1], BL
            MOV     BYTE ES:[DI + 320], CH  ; drawing 2x2 pixel for every "pixel" of image, so we need to MOV and AND 4 pixels
            OR      BYTE ES:[DI + 320], BH
            AND     BYTE ES:[DI + 320], BL
            MOV     BYTE ES:[DI + 321], CH
            OR      BYTE ES:[DI + 321], BH
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
        XOR     DX, DX              ; reset drawnPixels counter
        INC     SI                  ; move onto next byte
        JMP     LAB_DRAW_LOOP

        LAB_PIXEL_ZERO:
        TEST    CL, CL      
        JZ LAB_STOP_DRAW_LOOP   ; if both bytes are zero, then the image has ended, stop the loop
        XOR     CH, CH          ; set CH to zero to make CX = CL
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

    ; CHECK FOR A FREE SLOT IN BULLETS ARRAY (XPOS >= 320 OR YPOS >= 200) ;
    PUSH    AX                  ; save AX, for computational purposes
    MOV     DI, DAT_BULLET_ARRAY; load array offset into DI

    LAB_CHECK_BULLET_X:
        MOV     AX, 320                             ; screen width=320, so max x=320, so anything above this is free
        CMP     WORD [DI + C_BULLET_X_OFFSET], AX   ; check if DI[i].xPos is above 320
        JAE     LAB_SPAWN_BULLET                    ; if so, this slot is free and we can spawn something. Otherwise, check bullet Y
    
    LAB_CHECK_BULLET_Y:
        MOV     AX, 200                             ; screen height=200, so max y=200, so anything above this is free
        CMP     WORD [DI + C_BULLET_Y_OFFSET], AX   ; check if DI[i].yPos is above 200
        JAE     LAB_SPAWN_BULLET                    ; if so, this slot is free and we can spawn a bullet here. Otherwise, iterate (or end loop)

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
    PUSH    ES

    ; UPDATE PLAYER STATS ;

    ; DRAW PLAYER ;
    XOR     BH, BH                          ; PARAM: ORMASK
    MOV     AX, WORD [DAT_PLAYER_POS_Y]     ; PARAM: DRAW Y
    MOV     DX, WORD [DAT_PLAYER_POS_X]     ; PARAM: DRAW X
    MOV     SI, IMG_PLAYER_SPACESHIP        ; PARAM: IMAGE (RL-encoded)
    TEST    BL, BL                          ; if the screen being rendered is clearing old sprites, don't flash stuff
    JZ      LAB_DRAW_PLAYER

    ; check player hurt status. If they were hurt within HURT_FLASH_DURATION, make them white. Otherwise, check if they should be drawn at all.
    CMP     BYTE DS:[DAT_PLAYER_FRAMES_SINCE_LAST_HURT], C_HURT_FLASH_DURATION
    JA      LAB_CHECK_PLAYER_FLASHING
    PUSH    BX
    MOV     BH, 0xFF                        ; make player white
    MOV     BL, 0x0F
    CALL    FUNC_DRAW_IMAGE
    POP     BX
    JMP     LAB_AFTER_PLAYER_DRAWN
    
    ; toggle visibility every 4 frames.
    LAB_CHECK_PLAYER_FLASHING:
    MOV     CL, BYTE DS:[DAT_PLAYER_FRAMES_SINCE_LAST_HURT]
    CMP     CL, C_PLAYERDATA_INVULN_FRAMES  ; if the player isn't invulnerable, display them
    JA      LAB_DRAW_PLAYER
    BT      CX, 2                           ; if the result would be even (bit two [shr 2 for division] is cleared), show the player. Otherwise, don't.
    JC      LAB_AFTER_PLAYER_DRAWN

    LAB_DRAW_PLAYER:
    CALL    FUNC_DRAW_IMAGE                 ; Draw spaceship
    LAB_AFTER_PLAYER_DRAWN:

    ; DRAW ENEMIES ;
    MOV     DI, DAT_ENEMY_ARRAY             ; LOOP THROUGH ENEMY ARRAY
    LAB_DRAW_ENEMY_LOOP:
        LAB_DRAW_CHECK_ENEMY_X:
            CMP     WORD [DI + C_ENEMY_X_OFFSET], 320   ; Check if enemy X is valid (X < 320)
            JAE     LAB_DRAW_ENEMY_CONTINUE             ; if X is bigger than or equal to 320, this bullet is invalid

        LAB_DRAW_CHECK_ENEMY_Y:                 
            CMP     WORD [DI + C_ENEMY_Y_OFFSET], 200   ; Check if enemy Y is valid (Y < 200)
            JAE     LAB_DRAW_ENEMY_CONTINUE             ; if Y is bigger than or equal to 200, this bullet is invalid

        LAB_DRAW_ENEMY:
            MOV     AX, WORD [DI + C_ENEMY_Y_OFFSET]        ; PARAM: DRAW Y
            MOV     DX, WORD [DI + C_ENEMY_X_OFFSET]        ; PARAM: DRAW X
            MOV     SI, WORD [DI + C_ENEMY_IMAGE_OFFSET]    ; PARAM: IMAGE
            XOR     BH, BH                                  ; PARAM: ORMASK
            CMP     BYTE DS:[DI + C_ENEMY_HURT_FRAMES_OFFSET], C_HURT_FLASH_DURATION
            JNBE    LAB_NO_ENEMY_HURT_FLASH                 ; if the enemy was last hurt within C_HURT_FLASH_DURATION frames, display them as a white flash
            TEST    BL, BL                                  ; if BL == 0, this means we are clearing old sprites and should not flash
            JZ      LAB_NO_ENEMY_HURT_FLASH
            PUSH    BX
            MOV     BH, 0xFF                                ; FLASH ENEMY: set ORMASK to 0xFF to control display colors and set BITMASK
            MOV     BL, 0x0F
            CALL    FUNC_DRAW_IMAGE
            POP     BX
            JMP     LAB_AFTER_FLASH_DRAWN
            LAB_NO_ENEMY_HURT_FLASH:
            CALL    FUNC_DRAW_IMAGE
            LAB_AFTER_FLASH_DRAWN:

        LAB_DRAW_ENEMY_CONTINUE:
            ADD     DI, C_ENEMY_SIZE_BYTES          ; iterate to next element of ENEMY ARRAY
            CMP     DI, DAT_END_OF_ENEMY_ARRAY      ; if we're at the end of ENEMY ARRAY, terminate loop
            JB      LAB_DRAW_ENEMY_LOOP             ; otherwise, continue looping
    
    ; DRAW BULLETS ;
    MOV     DI, DAT_BULLET_ARRAY            ; LOOP THROUGH BULLET ARRAY
    LAB_DRAW_BULLET_LOOP:
        LAB_DRAW_CHECK_BULLET_X:
            CMP     WORD [DI + C_BULLET_X_OFFSET], 320  ; Check if bullet X is valid (X < 320)
            JAE     LAB_DRAW_BULLET_CONTINUE            ; if X is bigger than or equal to 320, this bullet is invalid
            
        LAB_DRAW_CHECK_BULLET_Y:
            CMP     WORD [DI + C_BULLET_Y_OFFSET], 200  ; Check if bullet Y is valid (Y < 200)
            JAE    LAB_DRAW_BULLET_CONTINUE             ; if Y is bigger than or equal to 200, this bullet is invalid

        LAB_DRAW_BULLET:
            MOV     AX, WORD [DI + C_BULLET_Y_OFFSET]       ; PARAM: DRAW Y
            MOV     DX, WORD [DI + C_BULLET_X_OFFSET]       ; PARAM: DRAW X
            MOV     SI, WORD [DI + C_BULLET_IMAGE_OFFSET]   ; PARAM: IMAGE (RL-encoded)
            XOR     BH, BH                                  ; PARAM: ORMASK
            CALL    FUNC_DRAW_IMAGE

        LAB_DRAW_BULLET_CONTINUE:
            ADD     DI, C_BULLET_SIZE_BYTES             ; iterate to next element of BULLET ARRAY
            CMP     DI, DAT_END_OF_BULLET_ARRAY         ; if we're at the end of BULLET ARRAY, terminate loop
            JB      LAB_DRAW_BULLET_LOOP                      

    ; CLEAR SCORE FROM SCREEN ;
    MOV     DX, 10              ; each number is 5 pixels tall
    MOV     AX, 0xA000          
    MOV     ES, AX              ; load VGA segment into ES
    MOV     AX, 0x0000          ; clearing screen, print black pixels
    MOV     DI, (4 * 320) + 72  ; DS:[4 * 320 + 72] or coordinates (72, 4) is where the numbers start being drawn

    LAB_CLEAR_SCORE_LOOP:
    MOV     CX, 25              ; the numbers each take up 5 pixels, and the longest a number can be is 5 characters (65535)
    REP STOSW
    ADD     DI, 320 - 50        ; move to the next line to clear
    DEC     DX    
    JNZ     LAB_CLEAR_SCORE_LOOP

    ; DISPLAY SCORE ONTO SCREEN ;
    MOV     AX, 4                           ; PARAM: Y POSITION
    MOV     DX, 72                          ; PARAM: X POSITION
    MOV     BL, 0x2C                        ; PARAM: NUMBER COLOR
    MOV     CX, WORD DS:[DAT_PLAYER_SCORE]  ; PARAM: NUMBER TO DISPLAY
    CALL    FUNC_DISPLAY_DEC_NUMBER

    POP     ES
    POP     DI
    POP     SI
    POP     DX
    POP     CX
    POP     AX
    RET


;************************************************************************************************************************************************************
; VOID CREATE_ENEMY(UINT16 YPOS, UINT16 XPOS, UINT16 FLAGS, NPTR IMAGE, UINT16 HEALTH, UINT8 SPEED, UINT8 DAMAGE, NPTR CODE, UINT8 FIRERATE)
; creates an enemy at x, y with the passed stats. Automatically cleans up passed stack parameters.
;************************************************************************************************************************************************************
; ( PARAMS )
; AX    : [UINT16]  YPOS    - the y position of the bullets's top left pixel
; DX    : [UINT16]  XPOS    - the x position of the bullet's top left pixel
; CX    : [UINT16]  SCORE   - the amount of score gained when this enemy is killed
; [BP+6]: [INT16]   HEALTH  - how much damage the enemy can take before being deleted
; BH    : [UINT8]   SPEED   - how much the position of the enemy is incremented by every frame
; BL    : [UINT8]   DAMAGE  - how much damage the enemy's bullets do if they collide with something
; SI    : [NPTR]    IMAGE   - the offset of the bullet's image from DS
; [BP+4]: [NPTR]    CODE    - the function executed every frame by the enemy - VOID ENEMY_AI(ENEMY* ENEMY_PTR)
; [BP+1]: [UINT8]   FIRERATE- how often, in frames (30 FPS), the enemy can fire
; [BP+2]: [UINT8]   FLAGS   - controls certain behaviors of the enemy
FUNC_CREATE_ENEMY:
    ; SET UP STACK FRAME
    PUSH    BP
    MOV     BP, SP
    PUSH    DI

    ; LOOP THROUGH ENEMY ARRAY, FIND FIRST FREE SLOT (X >= 320 OR Y >= 200)
    MOV     DI, DAT_ENEMY_ARRAY
    LAB_CREATE_ENEMY_LOOP:
        ; CHECK STRUCT X (CREATE ENEMY IF X >= 320)
        CMP     WORD DS:[DI + C_ENEMY_X_OFFSET], 320    ; compare enemy.X to 320
        JAE     LAB_CREATE_ENEMY                        ; if enemy.X >= 320, this slot is unused - create an enemy in this slot

        ; CHECK STRUCT Y (CREATE ENEMY IF Y >= 200)
        CMP     WORD DS:[DI + C_ENEMY_Y_OFFSET], 200    ; compare enemy.Y to 200
        JAE     LAB_CREATE_ENEMY                        ; if enemy.Y >= 200, this slot is unused - create an enemy in this slot

        LAB_CREATE_ENEMY_CONTINUE:
        ADD     DI, C_ENEMY_SIZE_BYTES      ; iterate DI to the next enemy position
        CMP     DI, DAT_END_OF_ENEMY_ARRAY  ; if iterator >= end of array, terminate loop
        JAE     LAB_END_CREATE_ENEMY
        JMP     LAB_CREATE_ENEMY_LOOP       ; if iterator < end of array, continue loop

        LAB_CREATE_ENEMY:
        MOV     WORD DS:[DI + C_ENEMY_X_OFFSET], DX         ; ENEMY X
        MOV     WORD DS:[DI + C_ENEMY_Y_OFFSET], AX         ; ENEMY Y
        MOV     WORD DS:[DI + C_ENEMY_SCORE_WORTH_OFFSET], CX   ; ENEMY SCORE
        MOV     AX, WORD SS:[BP + 4]; load PARAM:FLAGS and PARAM:FIRERATE in AX
        MOV     BYTE DS:[DI + C_ENEMY_FLAGS_OFFSET], AL     ; ENEMY FLAGS
        MOV     BYTE DS:[DI + C_ENEMY_FIRERATE_OFFSET], AH  ; ENEMY FIRERATE
        MOV     AX, SS:[BP + 8]; load PARAM:HEALTH in AX
        MOV     WORD DS:[DI + C_ENEMY_HEALTH_OFFSET], AX    ; ENEMY HEALTH
        MOV     BYTE DS:[DI + C_ENEMY_SPEED_OFFSET], BH     ; ENEMY SPEED
        MOV     BYTE DS:[DI + C_ENEMY_DAMAGE_OFFSET], BL    ; ENEMY DAMAGE
        MOV     WORD DS:[DI + C_ENEMY_IMAGE_OFFSET], SI     ; ENEMY IMAGE
        MOV     AX, SS:[BP + 6]; load PARAM:CODE in AX
        MOV     WORD DS:[DI + C_ENEMY_CODE_OFFSET], AX      ; ENEMY CODE
        MOV     BYTE DS:[DI + C_ENEMY_ATTACK_FRAME_OFFSET], 0xFF    ; set enemy time since attack to be max (so it is reloaded upon creation)
        MOV     BX, WORD DS:[DI + C_ENEMY_IMAGE_OFFSET]
        MOV     AX, WORD DS:[BX - 2]                        ; load image height into AH, image width into AL
        MOV     BYTE DS:[DI + C_ENEMY_IMAGE_HEIGHT_OFFSET], AL
        MOV     BYTE DS:[DI + C_ENEMY_IMAGE_WIDTH_OFFSET], AH
        MOV     BYTE DS:[DI + C_ENEMY_HURT_FRAMES_OFFSET], 0xFF     ; set enemy time since hurt to be max (so it doesn't flash upon creation)

    LAB_END_CREATE_ENEMY:
    POP     DI
    ; COLLAPSE STACK FRAME
    MOV     BX, SS:[BP + 2] ; load return address into BX
    ADD     SP, 8           ; clear last 8 bytes of stack (4 push calls were made, including return address, not including original BP)
    POP     BP              ; return original BP
    JMP     BX              ; RET


;************************************************************************************************************************************************************
; VOID AI_ALIEN_SPITTER(NPTR ME)
; Should be called every frame. Makes the struct ME move and do stuff.
;************************************************************************************************************************************************************
; ( PARAMS )
; SI : [NPTR]   ME      - a near pointer to the struct that needs to be updated
;
AI_ALIEN_SPITTER:
    PUSH    AX
    PUSH    BX  
    PUSH    CX
    PUSH    DX
    PUSH    SI

    ; UPDATE POSITION ;
    ; for x, if spitter is not in front of player, make it move backwards (+x), otherwise, make it move to player (-x) until it is within 10 pixels of the player
    MOVZX   CX, BYTE DS:[SI + C_ENEMY_SPEED_OFFSET]
    LAB_MOVE_SPITTER_X:
        MOV     AX, WORD DS:[SI + C_ENEMY_X_OFFSET] ; load me.X into AX
        SUB     AX, C_PLAYERDATA_WIDTH              ; subtract player.width from me.X
        CMP     AX, WORD DS:[DAT_PLAYER_POS_X]      ; if me.X - player.width > player.x, we are in front of player
        JG      LAB_SPITTER_IN_FRONT_OF_PLAYER      ; signed comparison, me.X - player.width could go negative
        JMP     LAB_SPITTER_MOVE_BACKWARDS          ; if we are not in front, try to move backwards

        LAB_SPITTER_IN_FRONT_OF_PLAYER:
        ; check if me.X - player.x >= 10. If it is not, then move closer.
        SUB     AX, 10                              ; get me.X - 10
        CMP     AX, WORD DS:[DAT_PLAYER_POS_X]      ; compare me.X - 10 to player.width, if we are not greater, then move forwards
        JGE     LAB_SPITTER_MOVE_FORWARDS
        JMP     LAB_MOVE_SPITTER_Y                  ; if we are fine on the x-axis, go on to Y axis

        LAB_SPITTER_MOVE_FORWARDS:
        SUB     WORD DS:[SI + C_ENEMY_X_OFFSET], CX     ; subtract speed from X axis
        ; subtracting from our X could have caused an underflow! Check carry flag if this is the case
        JNC     LAB_MOVE_SPITTER_Y                      ; if there was no underflow, continue logic flow
        MOV     WORD DS:[SI + C_ENEMY_X_OFFSET], 0      ; if there was an underflow, set me.X to 0
        JMP     LAB_MOVE_SPITTER_Y

        LAB_SPITTER_MOVE_BACKWARDS:
        ADD     WORD DS:[SI + C_ENEMY_X_OFFSET], CX     ; add speed to X axis
        ; adding to our X could have made our X position greater than or equal to 320! Check if this is the case
        CMP     WORD DS:[SI + C_ENEMY_X_OFFSET], 320     
        JNGE    LAB_MOVE_SPITTER_Y                      ; if me.X is not greater than or equal to 320, continue logic flow
        MOV     WORD DS:[SI + C_ENEMY_X_OFFSET], 319    ; if me.X is greater than or equal to 320, set me.X to 319
        JMP     LAB_MOVE_SPITTER_Y  
        

    LAB_MOVE_SPITTER_Y:
        ; rules: spitter always tries to match player y
        MOV     AX, WORD DS:[SI + C_ENEMY_Y_OFFSET] ; load ME.Y into AX
        SUB     AX, WORD DS:[DAT_PLAYER_POS_Y]      ; subtract PLAYER.Y from ME.Y
        JZ      LAB_SPITTER_ATTEMPT_FIRE            ; if they are equal, the spitter will attempt to fire (obviously)

        ; HANDLE MOVEMENT ;
        JNS     LAB_NO_ABS                          ; if ME.Y - PLAYER.Y isn't negative, don't perform AX = abs(AX)
        NEG     AX                                  ; otherwise, perform abs(AX)
        CMP     AX, CX                              ; if |PLAYER.Y - ME.Y| < SPEED, just move PLAYER.Y - ME.Y distance down
        JLE     LAB_ABS_MATCH_Y_LEVEL
        ADD     WORD DS:[SI + C_ENEMY_Y_OFFSET], CX ; otherwise, subtract SPEED from ME.Y (move down SPEED distance)
        JMP     LAB_SPITTER_ATTEMPT_FIRE            ; try to fire

        LAB_ABS_MATCH_Y_LEVEL:
        ADD     WORD DS:[SI + C_ENEMY_Y_OFFSET], AX ; match player Y level
        JMP     LAB_SPITTER_ATTEMPT_FIRE

        LAB_NO_ABS:
        CMP     AX, CX                              ; if PLAYER.Y - ME.Y < SPEED, just move PLAYER.Y - ME.Y distance up
        JL      LAB_NO_ABS_MATCH_Y_LEVEL
        SUB     WORD DS:[SI + C_ENEMY_Y_OFFSET], CX ; otherwise, add SPEED to ME.Y (move up SPEED distance)
        JMP     LAB_SPITTER_ATTEMPT_FIRE            ; try to fire

        LAB_NO_ABS_MATCH_Y_LEVEL:
        SUB     WORD DS:[SI + C_ENEMY_Y_OFFSET], AX ; match player Y level
        JMP     LAB_SPITTER_ATTEMPT_FIRE

    LAB_SPITTER_ATTEMPT_FIRE:
    ; UPDATE TIMING VARIABLES ;
    MOV     AL, BYTE DS:[SI + C_ENEMY_ATTACK_FRAME_OFFSET]  ; load # of frames since last shot into AL
    MOV     AH, BYTE DS:[SI + C_ENEMY_FIRERATE_OFFSET]      ; load firerate into AH
    CMP     AL, AH              ; if # of frames < firerate, increase frames
    JAE     LAB_SPITTER_CHECK_X ; attempt to attack
    INC     BYTE DS:[SI + C_ENEMY_ATTACK_FRAME_OFFSET]   ; otherwise, add one to frames and don't do anything
    JMP     LAB_SPITTER_END_AI

    ; CHECK X POSITION ;
    LAB_SPITTER_CHECK_X:
    MOV     AX, DS:[SI + C_ENEMY_X_OFFSET]          ; if ME.X - PLAYER.WIDTH > PLAYER.X, we are in front of them and may be able to shoot
    SUB     AX, C_PLAYERDATA_WIDTH                  ; subtract PLAYER.WIDTH from ME.X
    CMP     AX, DS:[DAT_PLAYER_POS_X]
    JLE     LAB_SPITTER_END_AI                      ; signed compare, as ME.X - PLAYER.WIDTH could go negative. If ME.X - PLAYER.WIDTH <= PLAYER.X, don't shoot.

    ; CHECK Y POSITION ;
    MOV     AX, DS:[SI + C_ENEMY_Y_OFFSET]          ; if ME.Y - PLAYER.Y + PLAYER.HEIGHT/2 <= 32 and >= 0, we can shoot the player.
    SUB     AX, DS:[DAT_PLAYER_POS_Y]               ; subtract PLAYER.Y from ME.Y
    ADD     AX, C_PLAYERDATA_HEIGHT / 2             ; add PLAYER.HEIGHT/2 to ME.Y - PLAYER.Y
    CMP     AX, 32
    JNBE    LAB_SPITTER_END_AI                      ; unsigned compare, so a negative value is not less than 32. 

    ; ATTACK ;
    MOV     BYTE DS:[SI + C_ENEMY_ATTACK_FRAME_OFFSET], 0   ; RESET LAST FRAME SHOT
    MOV     AX, DS:[SI + C_ENEMY_Y_OFFSET]          ; PARAM: Y
    ADD     AX, 10
    MOV     DX, DS:[SI + C_ENEMY_X_OFFSET]          ; PARAM: X
    SUB     DX, 6
    MOV     CX, (1 << C_BULLET_FLAG_HOSTILE) | (1 << C_BULLET_FLAG_MOVEMENT_NEG)  ; PARAM: FLAGS
    MOV     BH, 5                                   ; PARAM: SPEED
    MOV     BL, 5                                   ; PARAM: DAMAGE
    MOV     SI, IMG_PLAYER_BULLET                   ; PARAM: IMAGE
    CALL    FUNC_CREATE_BULLET

    LAB_SPITTER_END_AI:
    POP     SI
    POP     DX
    POP     CX
    POP     BX
    POP     AX
    RET

;************************************************************************************************************************************************************
; VOID KILL_PLAYER()
; Stops the game, displays a cool transition effect, and says "YOU DIED!" and the player's score on the screen.
;************************************************************************************************************************************************************
; ( PARAMS )
; NONE
;
FUNC_KILL_PLAYER:



    RET

;************************************************************************************************************************************************************
; VOID DISPLAY_DEC_NUMBER(UINT16 NUM, UINT16 X, UINT16 Y, UINT8 COLOR)
; Displays a decimal number to the screen at (x, y), given an unsigned int16, with the passed color.
;************************************************************************************************************************************************************
; ( PARAMS )
; CX : [UINT16] NUM     - the unsigned 16-bit number to be displayed to the screen
; DX : [UINT16] X       - the x-position of the top left corner of the first digit
; AX : [UINT16] Y       - the y-position of the top left corner of the first digit
; BL : [UINT8]  COLOR   - the VGA-pallete color that the number should be displayed in
;
FUNC_DISPLAY_DEC_NUMBER:
    PUSH    AX
    PUSH    DX
    PUSH    SI
    PUSH    0x0000          ; local variable, used to keep track of division results after FUNC_DISPLAY_DEC_DIGIT calls

    XOR     BH, BH          ; clear BH, we will be using it for flags and parameters
    MOV     AX, CX          ; use AX as y-param for consistency, but we're just gonna slap display number into AX anyways
    MOV     SI, SP          ; load SP into SI because for some dumb reason SP cannot be used for addressing
    MOV     CX, 10000       ; biggest multiple of 10 that we can store in a uint16 is 10k, start by dividing by that

    LAB_DISPLAY_DIGIT_LOOP:
        XOR     DX, DX          ; because div divides DX:AX. >:(
        DIV     CX              ; AX : result, DX : remainder
        MOV     WORD SS:[SI], DX; save remainer in local variable
        TEST    AX, AX          ; if result = 0, don't print anything. Otherwise, print out a digit (and increase x-position)
        JNZ     LAB_PRINT_DIGIT
        TEST    BH, BH          ; if BH is not zero, that means something has already been printed (so print our digit anyways)
        JNZ     LAB_PRINT_DIGIT
        TEST    CX, 0x0001      ; check our divisor. If divisor is equal to one, that means we must print the last digit even if it is zero (so a value of 0 is printed)
        JNZ     LAB_PRINT_DIGIT
        ; otherwise, divide CX by 10 and loop

    LAB_CONTINUE_DIGIT_LOOP:
        XOR     DX, DX          ; DIV divides DX:AX cuz its poopy >:(
        MOV     AX, CX          ; NOTE TO SELF: AVOID BACKSLASHES AT THE END OF THE LINE :(
        MOV     word CX, 10     ; divide divisor by 10
        DIV     CX              
        TEST    AX, AX          ; if divisor is zero, terminate display loop
        JZ      LAB_END_PRINT_DIGIT
        
        MOV     CX, AX          ; load result back into CX
        MOV     AX, WORD SS:[SI]; get old remainder from last division, load into AX
        JMP     LAB_DISPLAY_DIGIT_LOOP

    LAB_PRINT_DIGIT:
        MOV     BH, AL                  ; PARAM : NUM
                                        ; PARAM : BITMASK ALREADY PASSED
        MOV     AX, WORD SS:[SI + 6]    ; PARAM : Y
        MOV     DX, WORD SS:[SI + 4]    ; PARAM : X
        CALL    FUNC_DISPLAY_DEC_DIGIT
        ADD     WORD SS:[SI + 4], 10    ; increase next digit X-position by 5, 2 pixels of padding between digits
        MOV     BH, 1                   ; make sure program knows to print next digit even if it is zero
        JMP     LAB_CONTINUE_DIGIT_LOOP

    LAB_END_PRINT_DIGIT:
    ADD     SP, 2       ; delete local variable off of stack
    POP     SI
    POP     DX          ; this value is garbage, but whatever, just send it back to DX
    POP     AX
    RET

;************************************************************************************************************************************************************
; VOID DISPLAY_DEC_DIGIT(UINT8 NUM, UINT8 BITMASK, UINT16 X, UINT16 Y)
; Displays a singular decimal digit to the screen, with top left coordinates (X, Y), and bitmask BITMASK. NUM should not be more than 9.
;************************************************************************************************************************************************************
; ( PARAMS )
; BH : [UINT8]  NUM     - the digit to be displayed (max value 9)
; BL : [UINT8]  BITMASK - the bitmask to be applied to the digit color (color = 0xFF)
; DX : [UINT16] X       - the x-position of the top left corner of the digit
; AX : [UINT16] Y       - the y-position of the top left corner of the digit
;
FUNC_DISPLAY_DEC_DIGIT:
    ; we want to preserve passed parameters
    PUSH    DX
    PUSH    AX
    PUSH    ES
    PUSH    DI
    PUSH    BX

    ; GET 1D INDEX FROM 2D COORDINATE ;
    MOV     DX, 320             ; load 320 into DX, which is the number of pixels in one row of VGA 
    MUL     DX                  ; multiply Y-coord by 320. This clears DX.
    MOV     DI, SP              ; get address of DX value
    ADD     AX, WORD SS:[DI + 8]; get DX's original value and add it to AX.
    MOV     DI, AX              ; load index into DI
    MOV     DX, 0xA000          ; load VGA segment into DX, because for some dumb reason ES can't be assigned constants
    MOV     ES, DX              ; VGA segment

    ; GET DIGIT X-INDEX ;
    MOV     AL, BH              ; move digit into AL
    MOV     DL, 3               ; multiply num by three (x-size of one digit)
    MUL     DL                  ; this clears AH, AL = pixel offset of digit image

    MOV     DX, BX              ; save param value into DX to free up BX for addressing
    MOVZX   BX, AL              ; load offset into BX (I hate this shit)

    ; START DRAWING ;
    LAB_DRAW_DIGIT_ROW:
    MOV     AL, BYTE DS:[IMG_NUMBERMAP + BX]    ; load pixel value into AL
    AND     AL, DL                              ; apply bitmask to DL
    MOV     BYTE ES:[DI], AL                    ; draw pixel 1 of 4 into memory
    MOV     BYTE ES:[DI + 1], AL                ; draw pixel 2 of 4 into memory
    MOV     BYTE ES:[DI + 320], AL              ; draw pixel 3 of 4 into memory
    MOV     BYTE ES:[DI + 321], AL              ; draw pixel 4 of 4 into memory

    MOV     AL, BYTE DS:[IMG_NUMBERMAP + 1 + BX]; load pixel value into Al
    AND     AL, DL                              ; apply bitmask to AL
    MOV     BYTE ES:[DI + 2], AL                ; draw pixel 1 of 4 into memory
    MOV     BYTE ES:[DI + 3], AL                ; draw pixel 2 of 4 into memory
    MOV     BYTE ES:[DI + 322], AL              ; draw pixel 3 of 4 into memory
    MOV     BYTE ES:[DI + 323], AL              ; draw pixel 4 of 4 into memory

    MOV     AL, BYTE DS:[IMG_NUMBERMAP + 2 + BX]; load pixel value into Al
    AND     AL, DL                              ; apply bitmask to AL
    MOV     BYTE ES:[DI + 4], AL                ; draw pixel 1 of 4 into memory
    MOV     BYTE ES:[DI + 5], AL                ; draw pixel 2 of 4 into memory
    MOV     BYTE ES:[DI + 324], AL              ; draw pixel 3 of 4 into memory
    MOV     BYTE ES:[DI + 325], AL              ; draw pixel 4 of 4 into memory

    ; DRAW NEXT ROW ;
    ADD     DI, 640                             ; go down 2 pixels on screen
    ADD     BX, 30                              ; go to next row of image
    CMP     BX, 150                             ; if AL >= 150 after drawing (meaning we have passed bottom row of numbermap), terminate draw loop
    JNAE    LAB_DRAW_DIGIT_ROW                  ; otherwise, continue loop

    POP     BX
    POP     DI
    POP     ES
    POP     AX
    POP     DX
    RET