.setcpu "65C02"
.segment "UTILS"


show_pos:
                sta value
                
                lda #0
                sta message
                sta message + 1
                sta message + 2

divide:         lda #0          ; Init reminder
                sta mod10
                clc

                ldx #8
divloop:        rol value       ; Rotate quotient and reminder    
                rol mod10

                sec
                lda mod10
                sbc #10
                bcc ignore_result ; branch if dividend < divisor
                sta mod10

ignore_result:  dex
                bne divloop
                rol value

                lda mod10
                clc
                adc #'0'
                jsr push_char
                lda value
                bne divide
                
                ldx #0
print:          lda message, x
                beq end
                jsr via_lcd_print_char
                inx
                jmp print

end:
                rts

push_char:
                pha
                ldy #0
push_char_loop: lda message,y
                tax
                pla
                sta message,y
                iny
                txa
                pha
                bne push_char_loop
                pla
                sta message,y
                rts

ColTab:
    .repeat 256, I
        .byte ((I * 40) / 256)
    .endrep   ; 0..39

RowTab:
    .repeat 256, I
        .byte ((I * 25) / 256)
    .endrep   ; 0..24