.setcpu "65C02"
.segment "LCD"

LCD_PORT = PORTB
LCD_DDR = DDRB
LCD_PCR = PCR_AB
LCD_IFA = IFA_AB
LCD_IER = IER_AB

E = %00000010
NE = %11111101
RS = %00000100
RW = %00001000
BUSY_FLAG = %10000000

lcd_setup:
                lda #%00100000  ; Set 4-bit mode
                jsr lcd_instruction_part

                lda #%00101000  ; Set 4-bit mode; 2-line display; 5x8 font
                jsr lcd_instruction
                lda #%00001110  ; Display on; cursor on; blink off
                jsr lcd_instruction
                lda #%00000110  ; Increment and shift cursor; don't shift display
                jsr lcd_instruction
lcd_init:
                lda #%00000001  ; Clear display
                jsr lcd_instruction

lcd_loop:

                ldx #0
lcd_send_msg:
                lda lcd_message,x
                beq lcd_done
                jsr lcd_print_char
                inx
                jmp lcd_send_msg
lcd_done:
                rts

lcd_message: .asciiz "Hello, world!"

; Subroutines
lcd_instruction:
                tay             ; copy A to Y, because A will be modified
                and #%11110000  ; and A to get MSB
                jsr lcd_instruction_part  ; print it
                tya             ; restore A
                asl             ; shift LSB to left 4 times
                asl
                asl
                asl
                jsr lcd_instruction_part  ; print it
                rts

lcd_instruction_part:
                jsr lcd_wait                
                sta LCD_PORT
                ora #E
                sta LCD_PORT
                and #NE
                sta LCD_PORT
                rts
lcd_print_char:
                tay             ; copy A to Y, because A will be modified
                and #%11110000  ; and A to get MSB
                jsr lcd_print_char_part  ; print it
                tya             ; restore A
                asl             ; shift LSB to left 4 times
                asl
                asl
                asl
                jsr lcd_print_char_part  ; print it
                rts

lcd_print_char_part:
                jsr lcd_wait
                ora #RS         ; Set RS, clear RW/E bits
                sta LCD_PORT
                ora #(RS | E)   ; Set E and RS bit to send instruction
                sta LCD_PORT
                and #NE
                sta LCD_PORT
                rts

lcd_wait:
                pha
                lda #%01111111  ; Set 7 pin on port B to input
                sta LCD_DDR

lcd_wait_loop:  lda #RW         ; Set RW, clear RS/E bits
                sta LCD_PORT
                lda #(RW | E)   ; Set E bit to send instruction
                sta LCD_PORT
                
                lda PORTB       ; Read flag after first operation
                and #BUSY_FLAG
                pha             ; Push on stack to send second nessecary 4-bit operation

                lda #RW         ; Set RW, clear RS/E bits
                sta LCD_PORT
                lda #(RW | E)   ; Set E bit to send instruction
                sta LCD_PORT

                pla             ; Pull busy flag from stack
                bne lcd_wait_loop

                lda #RW         ; Clear RS/RW/E bits
                sta LCD_PORT
                
                lda #%11111111 ; Set all pins on port B to output
                sta LCD_DDR
                pla
                rts