.setcpu "65C02"
.debuginfo
.segment "BIOS"

PORTB = $C000
PORTA = $C001
DDRB = $C002
DDRA = $C003
PCR_AB = $C00C         ; Peripheral Control Register
IFA_AB = $C00D         ; Interrupt flag register
IER_AB = $C00E         ; Interrupt enable register

ACIA_DATA       = $8000
ACIA_STATUS     = $8001
ACIA_CMD        = $8002
ACIA_CTRL       = $8003


kb_wptr  = $0000
kb_rptr  = $0001
kb_flags = $0002

tmp_start_high = $a6
tmp_end_high = $a7

start:
                ; Initialize stack pointer
                ldx #$ff
                txs
via_init:
                lda #$82         ; Set bit 7 (global interrupt enable) and bit 1 (port A interrupt enable)
                sta IER_AB          ; Write to Interrupt Enable Register
                lda #$01         ; Set interrupt trigger mode to negative edge for port A
                sta PCR_AB          ; Write to Peripheral Control Register

                lda #%11111111  ; Set all pins on port B to output
                sta DDRB
                lda #%00000000  ; Set all pins on port A to input
                sta DDRA

                lda #0
                sta kb_rptr
                sta kb_wptr
                sta kb_flags

                start_low = $a2
                start_high = $a3
                end_low = $a4
                end_high = $a5

                lda #$00
                sta start_low
                sta end_low
                sta sample_idx
                lda #$40
                sta start_high
                sta tmp_start_high
                lda #$80
                sta end_high
                sta tmp_end_high

                jsr play_sample

handle_keyboard:
                jmp handle_keyboard
                
                sei
                lda sample_idx
                cmp #%10000000
                cli
                beq end_hdl_kbrd

                lda tmp_start_high
                sta start_high

                lda tmp_end_high
                sta end_high
                
                jsr play_sample
end_hdl_kbrd:   jmp handle_keyboard

                sei
                lda kb_rptr
                cmp kb_wptr
                cli
                bne key_pressed
                jmp handle_keyboard

key_pressed:    ldx kb_rptr
                lda kb_buffer, x

                lda tmp_start_high
                sta start_high

                lda tmp_end_high
                sta end_high

                jsr play_sample
                inc kb_rptr
                jmp handle_keyboard

.include "keyboard.s"
; .include "lcd.s"
.include "sampler.s"
.include "wozmon.s"

.segment "RESETVEC"
                .word   $0F00          ; NMI vector
                .word   start          ; RESET vector
                .word   irq          ; IRQ vector