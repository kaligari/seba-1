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
via_init:
                lda #$82        ; Set bit 7 (global interrupt enable) and bit 1 (port A interrupt enable)
                sta IER_AB      ; Write to Interrupt Enable Register
                lda #$01        ; Set interrupt trigger mode to negative edge for port A
                sta PCR_AB      ; Write to Peripheral Control Register

                lda #%11111111  ; Set all pins on port B to output
                sta DDRB
                lda #%00000000  ; Set all pins on port A to input
                sta DDRA
                
                jsr lcd_setup
                
                cld                     ; Clear decimal arithmetic mode.
                cli

                jsr acia_init

                lda #0
                sta mouse_pos_x
                sta mouse_pos_y


loop:
                lda ACIA_STATUS
                and #$08        ; check rx buffer status flag
                beq loop        ; loop if rx bufer empty

                ; read 1. byte
                lda ACIA_DATA
                sta mouse_byte_1
                ; check if byte is correct
                and #%01000000
                beq loop
                
wait_second_byte:
                ; wait for ready status
                lda ACIA_STATUS
                and #$08        ; check rx buffer status flag
                beq wait_second_byte

                ; read 2. byte
                lda ACIA_DATA
                ; check if byte is correct
                ; and #%01000000
                ; bne loop

                and #%00111111
                sta mouse_byte_2

wait_third_byte:
                ; wait for ready status
                lda ACIA_STATUS
                and #$08        ; check rx buffer status flag
                beq wait_third_byte

                ; read 3. byte
                lda ACIA_DATA
                ; check if byte is correct
                ; and #%01000000
                ; bne loop

                and #%00111111
                sta mouse_byte_3
                ; manage data
                
                ; Display go to home
                lda #%00000010  
                jsr lcd_instruction

                ; Left button
l_button:
                lda #'L'
                jsr lcd_print_char
                lda #':'
                jsr lcd_print_char

                lda mouse_byte_1
                and #$20
                beq l_no_click

                lda #'1'      ; click on
                jsr lcd_print_char

                jmp r_button
l_no_click:
                lda #'0'      ; click off
                jsr lcd_print_char

                ; Right button
r_button:
                lda #' '      ; space
                jsr lcd_print_char
                lda #'R'
                jsr lcd_print_char
                lda #':'
                jsr lcd_print_char

                lda mouse_byte_1
                and #$10
                beq r_no_click

                lda #'1'      ; click on
                jsr lcd_print_char

                jmp ydir
r_no_click:
                lda #'0'      ; click off
                jsr lcd_print_char

                ; UP/DOWN dir
ydir:
                lda #' '
                jsr lcd_print_char

                lda mouse_byte_1
                and #$08
                beq ydir_down

                lda #'U'
                jsr lcd_print_char
                
                jmp xdir
ydir_down:

                lda #'D'
                jsr lcd_print_char

                ; LEFT/RIGHT dir
xdir:
                lda mouse_byte_1
                and #$02
                beq xdir_down

                lda #'L'
                jsr lcd_print_char

                jmp next_line
xdir_down:
                lda #'R'
                jsr lcd_print_char

next_line:
                lda #' '
                jsr lcd_print_char
                lda #' '
                jsr lcd_print_char
                lda #' '
                jsr lcd_print_char

                lda #%10101000  ; New line
                jsr lcd_instruction
xpos:

                lda #'X'
                jsr lcd_print_char
                lda #':'
                jsr lcd_print_char

                ; calc xpos
                lda mouse_byte_1
                and #%00000011
                asl
                asl
                asl
                asl
                asl
                asl
                ora mouse_byte_2
                clc
                adc mouse_pos_x
                sta mouse_pos_x

                tax
                lda ColTab,X

                jsr show_pos

                lda #' '
                jsr lcd_print_char

ypos:
                lda #'Y'
                jsr lcd_print_char
                lda #':'
                jsr lcd_print_char
                
                ; calc ypos
                lda mouse_byte_1
                and #%00001100
                asl
                asl
                asl
                asl
                ora mouse_byte_3
                clc
                adc mouse_pos_y
                sta mouse_pos_y

                tax
                lda RowTab,X

                jsr show_pos

                lda #' '
                jsr lcd_print_char
                lda #' '
                jsr lcd_print_char

                jmp loop


; -- Subroutines ---

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
                jsr lcd_print_char
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

.include "lcd.s"
.include "acia.s"
; .include "keyboard.s"
; .include "wozmon.s"

irq:
                jmp start

.segment "RESETVEC"
                .word   $0F00          ; NMI vector
                .word   start          ; RESET vector
                .word   irq          ; IRQ vector