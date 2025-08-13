.setcpu "65C02"
.debuginfo
.segment "BIOS"

PORTB   = $C000
PORTA   = $C001
DDRB    = $C002
DDRA    = $C003
PCR_AB  = $C00C         ; Peripheral Control Register
IFA_AB  = $C00D         ; Interrupt flag register
IER_AB  = $C00E         ; Interrupt enable register

ACIA_DATA       = $8000
ACIA_STATUS     = $8001
ACIA_CMD        = $8002
ACIA_CTRL       = $8003

start:
                ; Initialize stack pointer
                ldx #$ff
                txs
via_init:
                lda #$82        ; Set bit 7 (global interrupt enable) and bit 1 (port A interrupt enable)
                sta IER_AB      ; Write to Interrupt Enable Register
                lda #$01        ; Set interrupt trigger mode to negative edge for port A
                sta PCR_AB      ; Write to Peripheral Control Register

                lda #%11111111  ; Set all pins on port B to output
                sta DDRB
                lda #%00000000  ; Set all pins on port A to input
                sta DDRA

                lda #$00
                sta end_low
                lda #$40
                sta addr_high
                lda #$80
                sta end_high

                jsr play_sample

loop:
                jmp loop


.include "keyboard.s"
; .include "lcd.s"
.include "sampler.s"
.include "wozmon.s"

.segment "RESETVEC"
                .word   $0F00          ; NMI vector
                .word   start          ; RESET vector
                .word   irq          ; IRQ vector