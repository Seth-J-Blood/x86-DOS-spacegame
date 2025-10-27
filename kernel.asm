;************************************************************************************************************************************************************
; WELCOME
; Introduction to the monolithic kernel that I programmed because I got bored
;************************************************************************************************************************************************************
; ( TODO LATER )
;


ORG 0x100       ; 256 bytes of prefixed padding in the .COM output file
BITS 16         ; 16 bit CPU :(

_start_point:
    JMP FUNC_INIT_KERNEL      ; goofy start point because of a .COM file :(

;************************************************************************************************************************************************************
;                                                      ( CONSTANTS )
;************************************************************************************************************************************************************
C_WATCHDOG_IVT_ENTRY        EQU     0x1C * 4        ; INT 0x1C is called every ~55ms, and is by default blank. Just overwrite it with watchdog
C_MAX_CONCURRENT_PROGRAMS   EQU     5

C_CTXT_AX_OFFSET            EQU     0
C_CTXT_BX_OFFSET            EQU     2
C_CTXT_CX_OFFSET            EQU     4
C_CTXT_DX_OFFSET            EQU     6
C_CTXT_SS_OFFSET            EQU     8
C_CTXT_ES_OFFSET            EQU     10
C_CTXT_DS_OFFSET            EQU     12
C_CTXT_SP_OFFSET            EQU     14
C_CTXT_BP_OFFSET            EQU     16
C_CTXT_SI_OFFSET            EQU     18
C_CTXT_DI_OFFSET            EQU     20
C_CTXT_FLAGS_OFFSET         EQU     22
C_CTXT_IP_OFFSET            EQU     24
C_CTXT_CS_OFFSET            EQU     26

;************************************************************************************************************************************************************
;                                                       ( DATA )
;************************************************************************************************************************************************************
; RESERVE CONTEXT-SWITCHER MEMORY
    
    ;*********************************************************
    ;              ( STRUCT CONTEXT_FRAME)
    ;*********************************************************
    ; Used by the watchdog to context switch. Contains space for:
    ; [UINT16] AX       
    ; [UINT16] BX       
    ; [UINT16] CX       
    ; [UINT16] DX       
    ; [UINT16] SS       
    ; [UINT16] ES       
    ; [UINT16] DS       
    ; [UINT16] SP       
    ; [UINT16] BP       
    ; [UINT16] SI       
    ; [UINT16] DI       
    ; [UINT16] FLAGS    
    ; [UINT16] IP
    ; [UINT16] CS
    ;
    DAT_CONTEXT_KERNEL_STATE            RESW 14
    DAT_CONTEXT_FRAME_ARRAY:            TIMES C_MAX_CONCURRENT_PROGRAMS RESW 16     ; 4 extra bytes - we're optimizing for speed not memory usage here.
    DAT_CURRENTLY_ACTIVE_PRGRM          DB  0
    DAT_CURRENTLY_ACTIVE_PRGRM_SLOTS    DB  0b00000000

FUNC_INIT_KERNEL:
    ; SET UP REGISTER-SPACE
    MOV     AX, 0x0050
    MOV     DS, AX
    MOV     
    
;************************************************************************************************************************************************************
; VOID INTERRUPT_WATCHDOG()
; custom interrupt that checks if the currently running program has hung. NEVER CALL IN-CODE.
;************************************************************************************************************************************************************
; ( PARAMS )
; NONE
;
INTERRUPT_WATCHDOG:
    ; TODO: OPTIMIZE THIS IF ONLY ONE PROGRAM IS RUNNING - DON'T SAVE ALL REGISTERS
    CALL    FUNC_SAVE_REGISTER_CONTEXT




; ASSUMED TO BE CALLED AFTER A PIT CALL - DO NOT RUN OTHERWISE
FUNC_SAVE_REGISTER_CONTEXT:
    PUSH    ES
    PUSH    BX

    ; SAVE A BAJILLION REGISTERS
    MOV     BX, 0x0050                                  ; segment for SBOS kernel
    MOV     ES, BX              

    ; find offset in context array 
    ; TODO ENSURE DAT_CURRENTLY_ACTIVE_PRGRM IS VALID
    MOVZX   BX, BYTE ES:[DAT_CURRENTLY_ACTIVE_PRGRM]    
    SHL     BX, 8       ; multiply active prgrm index by 32

    ; HANDLE BASIC REGISTERS MINUS ES AND BX
    MOV     WORD ES:[BX + C_CTXT_AX_OFFSET], AX
    MOV     WORD ES:[BX + C_CTXT_CX_OFFSET], CX
    MOV     WORD ES:[BX + C_CTXT_DX_OFFSET], DX
    MOV     WORD ES:[BX + C_CTXT_SS_OFFSET], SS
    MOV     WORD ES:[BX + C_CTXT_DS_OFFSET], DS
    MOV     WORD ES:[BX + C_CTXT_SP_OFFSET], SP
    MOV     WORD ES:[BX + C_CTXT_BP_OFFSET], BP
    MOV     WORD ES:[BX + C_CTXT_SI_OFFSET], SI
    MOV     WORD ES:[BX + C_CTXT_DI_OFFSET], DI

    ; HANDLE COMPLEX REGISTERS (BX, ES, CS, IP, FLAGS)
    MOV     DI, BX
    MOV     DS, ES
    POP     BX
    POP     ES

    MOV     WORD DS:[DI + C_CTXT_BX_OFFSET], BX
    MOV     WORD DS:[DI + C_CTXT_ES_OFFSET], ES
    MOV     BX, SP
    MOV     AX, WORD SS:[BX]        ; load IP into AX
    MOV     WORD DS:[DI + C_CTXT_IP_OFFSET], AX
    MOV     AX, WORD SS:[BX + 2]    ; load CS into AX
    MOV     WORD DS:[DI + C_CTXT_CS_OFFSET], AX
    MOV     AX, WORD SS:[BX + 4]    ; load FLAGS into AX
    MOV     WORD DS:[DI + C_CTXT_FLAGS_OFFSET], AX

    ; DONE SAVING REGISTERS
    RET