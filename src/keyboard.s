.setcpu "65C02"
.segment "KEYBOARD"

KEYB_PORT = PORTA
KEYB_DDR = DDRA
KEYB_PCR = PCR_AB
KEYB_IFA = IFA_AB
KEYB_IER = IER_AB

kb_flags = $0002

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

exit:           pla
                tax
                pla
                cli
                rti
