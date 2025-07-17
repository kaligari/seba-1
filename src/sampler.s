.setcpu "65C02"
.segment "SAMPLER"


addr_low = $a0
addr_high = $a1

end_low = $a4
end_high = $a5

sample_idx = $a8

; Dane tabeli (little-endian)
sample_table_data:
    ; 1. sampel, addr $aa, początek loopa 50xx, koniec 40xx
    .byte $40
    .byte $50
    ; 2. sampel, addr $ac, początek loopa 58xx, koniec 48xx
    .byte $48
    .byte $60    
    ; 3. sampel, addr $af, początek loopa 58xx, koniec 50xx
    .byte $50
    .byte $68
    ; 4. sampel, addr $b2, początek loopa 68xx, koniec 58xx
    .byte $58
    .byte $70
    ; 5. sampel, addr $b5, początek loopa 70xx, koniec 60xx
    .byte $60
    .byte $78
    ; 6. sampel, addr $b8, początek loopa 78xx, koniec 68xx
    .byte $68
    .byte $80
    ; 7. sampel, addr $bb, początek loopa 80xx, koniec 70xx
    .byte $70
    .byte $80
    ; 8. sampel, addr $bb, początek loopa 00xx, koniec F0xx
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
                sta DDRB
                jsr delay_125us

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
delay_125us:
        ; ldy #$2A
        ldy #$1c
wait:
        dey
        bne wait
        rts