.setcpu "65C02"
.segment "SAMPLER"


addr_low = $a0
addr_high = $a1

end_low = $a4
end_high = $a5

sample_idx = $a8

; samples start and end pointers
sample_table_data:
    ; 1. sample, F1 key, loop start $40xx, end $50xx
    .byte $40
    .byte $50
    ; 2. sample, F2 key, loop start $48xx, end $60xx
    .byte $48
    .byte $60    
    ; 3. sample, F3 key, loop start $50xx, end $68xx
    .byte $50
    .byte $68
    ; 4. sample, F4 key, loop start $58xx, end $70xx
    .byte $58
    .byte $70
    ; 5. sample, F5 key, loop start $60xx, end $78xx
    .byte $60
    .byte $78
    ; 6. sample, F6 key, loop start $68xx, end $80xx
    .byte $68
    .byte $80
    ; 7. sample, F7 key, loop start $70xx, end $80xx
    .byte $70
    .byte $80
    ; 8. sample, F8 key, loop start $40xx, end $80xx
    .byte $40
    .byte $80

play_sample:
                pha

                lda #0
                sta addr_low

sample_loop:
                sei

                cli

                beq next_byte

next_byte:
                lda (addr_low)
                sta PORTB
                jsr delay

                inc addr_low
                bne skip_high_inc
                inc addr_high

skip_high_inc:  lda addr_low
                cmp end_low
                bne next_byte
                lda addr_high
                cmp end_high
                bne next_byte

                pla

                jmp loop
; -----------------------------
; Delay
; -----------------------------
delay:
        ldy #$0A
wait:
        dey
        bne wait
        rts