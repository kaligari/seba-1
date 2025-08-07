.setcpu "65C02"
.debuginfo
.segment "BIOS"

mouse_byte_1 = $0A
mouse_byte_2 = $0B
mouse_byte_3 = $0C
mouse_pos_x = $0D
mouse_pos_y = $0E

value = $0200
mod10 = $0201   
message = $202      ; 3 bytes

start:
                ; Initialize stack pointer
                ldx #$ff
                txs

                ; Clear decimal arithmetic mode.
                cld
                cli

                jsr via_init
                jsr via_lcd_setup
                jsr acia_init

                lda #0
                sta mouse_pos_x
                sta mouse_pos_y


loop:
                jmp loop

.include "utils.s"
.include "via.s"
.include "via_lcd.s"
.include "acia.s"
.include "acia_mouse.s"
; .include "keyboard.s"
; .include "wozmon.s"

irq:
                jsr acia_mouse_loop
                
                lda ACIA_STATUS
                
                rti

.segment "RESETVEC"
                .word   $0F00          ; NMI vector
                .word   start          ; RESET vector
                .word   irq          ; IRQ vector