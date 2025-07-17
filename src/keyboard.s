.setcpu "65C02"
.segment "KEYBOARD"

KEYB_PORT = PORTA
KEYB_DDR = DDRA
KEYB_PCR = PCR_AB
KEYB_IFA = IFA_AB
KEYB_IER = IER_AB

RELEASE     = %00000001
NRELEASE     = %11111110

kb_buffer = $0200       ; 256-bytes kb buffer 0x0200 - 0x02ff
            
irq:
                sei                
                pha
                txa
                pha

                lda kb_flags            ; check flags
                cmp #0                  ; if not released
                beq read_key            ; then read key
                                        ; otherwise
                lda #0
                sta kb_flags            ; reset flags
                
                lda KEYB_PORT           ; release interrupt
                jmp exit                ; and exit

read_key:
                lda KEYB_PORT
                cmp #$f0                ; release key code
                bne key_not_release

                lda #1
                sta kb_flags

                jmp exit

key_not_release:

handle_f1:      cmp #$05
                bne handle_f2
                ldx #0
                jmp get_sample_config

handle_f2:      cmp #$06
                bne handle_f3
                ldx #2
                jmp get_sample_config

handle_f3:      cmp #$04
                bne handle_f4
                ldx #4
                jmp get_sample_config

handle_f4:      cmp #$0C
                bne handle_f5
                ldx #6
                jmp get_sample_config

handle_f5:      cmp #$03
                bne handle_f6
                ldx #8
                jmp get_sample_config

handle_f6:      cmp #$0b
                bne handle_f7
                ldx #10
                jmp get_sample_config

handle_f7:      cmp #$83
                bne handle_f8
                ldx #12
                jmp get_sample_config

handle_f8:      cmp #$0A
                bne handle_end
                ldx #14
                jmp get_sample_config

handle_end:     jmp exit

get_sample_config:
                stx sample_idx
                
                lda sample_table_data, x
                sta start_high
                inx
                lda sample_table_data, x
                sta end_high

                jmp play_sample

exit:           pla
                tax
                pla
                cli
                rti
