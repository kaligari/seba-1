.setcpu "65C02"
.segment "SAMPLER"


addr_low = $a0
addr_high = $a1
tmp_start_high = $a6
tmp_end_high = $a7
idx = $a8

; Tablica 7 elementów po 2 bajty
sample_table = $a9

; Dane tabeli (little-endian)
sample_table_data:
    ; 1. sampel
    .word 4050    ; addr $aa, początek loopa 50xx, koniec 40xx
    ; 2. sampel
    .word 4858    ; addr $ac, koniec loopa 58xx, koniec 48xx
    ; 3. sampel
    .word 5058    ; addr $af, koniec loopa 58xx, koniec 48xx
    ; 4. sampel
    .word 5868    ; addr $b2, koniec loopa 58xx, koniec 48xx
    ; 5. sampel
    .word 6070    ; addr $b5, koniec loopa 58xx, koniec 48xx
    ; 6. sampel
    .word 6878    ; addr $b8, koniec loopa 58xx, koniec 48xx
    ; 7. sampel
    .word 7080    ; addr $bb, koniec loopa 58xx, koniec 48xx

play_sample:
                pha

                lda start_low
                sta addr_low
                lda start_high
                sta addr_high

next_byte:      lda (addr_low)
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
                rts
; -----------------------------
; Opóźnienie ~125 µs (dla 2 MHz)
; -----------------------------
delay_125us:
        ; ldy #$2A
        ldy #$1B
wait:
        dey
        bne wait
        rts