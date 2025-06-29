.setcpu "65C02"
.segment "KEYBOARD"

KEYB_PORT = PORTA
KEYB_DDR = DDRA
KEYB_PCR = PCR_AB
KEYB_IFA = IFA_AB
KEYB_IER = IER_AB

RELEASE     = %00000001
NRELEASE     = %10000000
SHIFT       = %00000010
EXTENDED    = %00000100
NEXTENDED    = %11111011

kb_buffer = $0200       ; 256-bytes kb buffer 0x0200 - 0x02ff

                
irq:
                sei                
                pha
                txa
                pha
                lda kb_flags
                and #RELEASE
                beq read_key
                
                lda kb_flags            ; turn off release flag
                and #NRELEASE
                and #NEXTENDED           ; turn off extended flag
                sta kb_flags

handle_up:      lda KEYB_PORT               ; Read key value that's being released, reset interrupt
                cmp #$12
                beq shift_up
                cmp #$59
                beq shift_up
                jmp exit

shift_up:
                lda kb_flags
                eor #SHIFT
                sta kb_flags
                jmp exit

read_key:       lda kb_flags
                and #EXTENDED
                bne read_extended_key
                
                lda KEYB_PORT
                cmp #$e0                ; extended key code
                bne not_extended_down
                jmp extended_down
not_extended_down:
                cmp #$f0                ; release key code
                bne not_key_release
                jmp key_release
not_key_release:
                cmp #$12                ; left shift key code
                bne not_shift_down_1

                jmp shift_down
not_shift_down_1:
                cmp #$59                ; right shift key code
                bne not_shift_down_2
                jmp shift_down
not_shift_down_2:
                cmp #$05
                beq handle_f1
                cmp #$06
                beq handle_f2
                cmp #$04
                beq handle_f3
                cmp #$0C
                beq handle_f4
                cmp #$03
                beq handle_f5
                cmp #$0b
                beq handle_f6
                cmp #$83
                beq handle_f7
                ; cmp #$0a
                ; beq handle_f8
                
                tax
                lda kb_flags
                and #SHIFT
                bne shifted_key

                lda keymap, x
                jmp push_key

shifted_key:
                lda keymap_shifted, x
push_key:
                ldx kb_wptr
                sta kb_buffer, x
                inc kb_wptr
                jmp exit

read_extended_key:
                lda kb_flags            ; turn off extended flag
                and #NEXTENDED
                sta kb_flags
                lda KEYB_PORT
                cmp #$f0                ; release key code
                beq key_release
                jmp exit

handle_f1:
                lda #$40
                sta tmp_start_high
                lda #$50
                sta tmp_end_high
                jmp play_and_exit

handle_f2:
                lda #$48
                sta tmp_start_high
                lda #$58
                sta tmp_end_high
                jmp play_and_exit

handle_f3:
                lda #$50
                sta tmp_start_high
                lda #$58
                sta tmp_end_high
                jmp play_and_exit

handle_f4:
                lda #$58
                sta tmp_start_high
                lda #$68
                sta tmp_end_high
                jmp play_and_exit
                
handle_f5:
                lda #$60
                sta tmp_start_high
                lda #$70
                sta tmp_end_high
                jmp play_and_exit

handle_f6:
                lda #$68
                sta tmp_start_high
                lda #$78
                sta tmp_end_high
                jmp play_and_exit

handle_f7:
                lda #$70
                sta tmp_start_high
                lda #$80
                sta tmp_end_high
                jmp play_and_exit

; handle_f1:
;                 lda #$40
;                 sta tmp_start_high
;                 lda #$48
;                 sta tmp_end_high
;                 jmp play_and_exit

; handle_f2:
;                 lda #$48
;                 sta tmp_start_high
;                 lda #$50
;                 sta tmp_end_high
;                 jmp play_and_exit

; handle_f3:
;                 lda #$50
;                 sta tmp_start_high
;                 lda #$58
;                 sta tmp_end_high
;                 jmp play_and_exit

; handle_f4:
;                 lda #$58
;                 sta tmp_start_high
;                 lda #$60
;                 sta tmp_end_high
;                 jmp play_and_exit
                
; handle_f5:
;                 lda #$60
;                 sta tmp_start_high
;                 lda #$68
;                 sta tmp_end_high
;                 jmp play_and_exit

; handle_f6:
;                 lda #$68
;                 sta tmp_start_high
;                 lda #$70
;                 sta tmp_end_high
;                 jmp play_and_exit

; handle_f7:
;                 lda #$70
;                 sta tmp_start_high
;                 lda #$78
;                 sta tmp_end_high
;                 jmp play_and_exit

; handle_f8:
;                 lda #$78
;                 sta tmp_start_high
;                 lda #$80
;                 sta tmp_end_high
;                 jmp play_and_exit                

handle_escape:
                lda #$50
                sta tmp_start_high
                lda #$70
                sta tmp_end_high
                jmp exit

handle_home:
                lda #$50
                sta tmp_start_high
                lda #$70
                sta tmp_end_high
                jmp exit

handle_enter:
                jmp exit
                
handle_backspace:
                jmp exit

key_release:
                lda kb_flags
                ora #RELEASE
                sta kb_flags
                jmp exit
extended_down:
                lda kb_flags
                ora #EXTENDED
                sta kb_flags
                jmp exit
shift_down:
                lda kb_flags
                ora #SHIFT
                sta kb_flags
                jmp exit

play_and_exit:
                jmp push_key
exit:           pla
                tax
                pla
                cli
                rti

keymap:
    .byte "????????????? `?"       ; 00-0F
    .byte "?????q1???zsaw2?"       ; 10-1F
    .byte "?cxde43?? vftr5?"       ; 20-2F
    .byte "?nbhgy6???mju78?"       ; 30-3F
    .byte "?,kio09??./l;p-?"       ; 40-4F
    .byte "??'?[=?????]?\??"       ; 50-5F
    .byte "?????????1?47???"       ; 60-6F
    .byte "0.2568???+3-*9??"       ; 70-7F
    .byte "????????????????"       ; 80-8F
    .byte "????????????????"       ; 90-9F
    .byte "????????????????"       ; A0-AF
    .byte "????????????????"       ; B0-BF
    .byte "????????????????"       ; C0-CF
    .byte "????????????????"       ; D0-DF
    .byte "????????????????"       ; E0-EF
    .byte "????????????????"       ; F0-FF
keymap_shifted:
    .byte "????????????? ~?"       ; 00-0F
    .byte "?????Q!???ZSAW@?"       ; 10-1F
    .byte "?CXDE$#?? VFTR%?"       ; 20-2F
    .byte "?NBHGY^???MJU&*?"       ; 30-3F
    .byte "?<KIO)(??>?L:P_?"       ; 40-4F
    .byte "????{+?????}?|??"      ; 50-5F
    .byte "?????????1?47???"       ; 60-6F
    .byte "0.2568???+3-*9??"       ; 70-7F
    .byte "????????????????"       ; 80-8F
    .byte "????????????????"       ; 90-9F
    .byte "????????????????"       ; A0-AF
    .byte "????????????????"       ; B0-BF
    .byte "????????????????"       ; C0-CF
    .byte "????????????????"       ; D0-DF
    .byte "????????????????"       ; E0-EF
    .byte "????????????????"       ; F0-FF