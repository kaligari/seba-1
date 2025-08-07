.setcpu "65C02"
.segment "VIA_LCD"

VIA_LCD_PORT = VIA_PORTB
VIA_LCD_DDR = VIA_DDRB
VIA_LCD_PCR = VIA_PCR_AB
VIA_LCD_IFA = VIA_IFA_AB
VIA_LCD_IER = VIA_IER_AB

VIA_LCD_E = %00000010
VIA_LCD_NE = %11111101
VIA_LCD_RS = %00000100
VIA_LCD_RW = %00001000
VIA_LCD_BUSY_FLAG = %10000000

via_lcd_setup:
                lda #%00100000  ; Set 4-bit mode
                jsr via_lcd_instruction_part

                lda #%00101000  ; Set 4-bit mode; 2-line display; 5x8 font
                jsr via_lcd_instruction
                lda #%00001110  ; Display on; cursor on; blink off
                jsr via_lcd_instruction
                lda #%00000110  ; Increment and shift cursor; don't shift display
                jsr via_lcd_instruction
via_lcd_init:
                lda #%00000001  ; Clear display
                jsr via_lcd_instruction

via_lcd_loop:

                ldx #0
via_lcd_send_msg:
                lda via_lcd_message,x
                beq via_lcd_done
                jsr via_lcd_print_char
                inx
                jmp via_lcd_send_msg
via_lcd_done:
                rts

via_lcd_message: .asciiz "Hello, world!"

; Subroutines
via_lcd_instruction:
                tay             ; copy A to Y, because A will be modified
                and #%11110000  ; and A to get MSB
                jsr via_lcd_instruction_part  ; print it
                tya             ; restore A
                asl             ; shift LSB to left 4 times
                asl
                asl
                asl
                jsr via_lcd_instruction_part  ; print it
                rts

via_lcd_instruction_part:
                jsr via_lcd_wait                
                sta VIA_LCD_PORT
                ora #VIA_LCD_E
                sta VIA_LCD_PORT
                and #VIA_LCD_NE
                sta VIA_LCD_PORT
                rts
via_lcd_print_char:
                tay             ; copy A to Y, because A will be modified
                and #%11110000  ; and A to get MSB
                jsr via_lcd_print_char_part  ; print it
                tya             ; restore A
                asl             ; shift LSB to left 4 times
                asl
                asl
                asl
                jsr via_lcd_print_char_part  ; print it
                rts

via_lcd_print_char_part:
                jsr via_lcd_wait
                ora #VIA_LCD_RS         ; Set RS, clear RW/E bits
                sta VIA_LCD_PORT
                ora #(VIA_LCD_RS | VIA_LCD_E)   ; Set E and RS bit to send instruction
                sta VIA_LCD_PORT
                and #VIA_LCD_NE
                sta VIA_LCD_PORT
                rts

via_lcd_wait:
                pha
                lda #%01111111  ; Set 7 pin on port B to input
                sta VIA_LCD_DDR

via_lcd_wait_loop:  lda #VIA_LCD_RW         ; Set RW, clear RS/E bits
                sta VIA_LCD_PORT
                lda #(VIA_LCD_RW | VIA_LCD_E)   ; Set E bit to send instruction
                sta VIA_LCD_PORT
                
                lda VIA_LCD_PORT       ; Read flag after first operation
                and #VIA_LCD_BUSY_FLAG
                pha             ; Push on stack to send second nessecary 4-bit operation

                lda #VIA_LCD_RW         ; Set RW, clear RS/E bits
                sta VIA_LCD_PORT
                lda #(VIA_LCD_RW | VIA_LCD_E)   ; Set E bit to send instruction
                sta VIA_LCD_PORT

                pla             ; Pull busy flag from stack
                bne via_lcd_wait_loop

                lda #VIA_LCD_RW         ; Clear RS/RW/E bits
                sta VIA_LCD_PORT
                
                lda #%11111111 ; Set all pins on port B to output
                sta VIA_LCD_DDR
                pla
                rts