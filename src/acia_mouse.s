.setcpu "65C02"
.segment "ACIA_MOUSE"


acia_mouse_loop:
                lda ACIA_STATUS
                and #$08        ; check rx buffer status flag
                bne wait_first_byte        ; loop if rx bufer empty
                rts

wait_first_byte:
                ; read 1. byte
                lda ACIA_DATA
                sta mouse_byte_1
                ; check if byte is correct
                and #%01000000
                bne wait_second_byte
                rts
                
wait_second_byte:
                ; wait for ready status
                lda ACIA_STATUS
                and #$08        ; check rx buffer status flag
                beq wait_second_byte

                ; read 2. byte
                lda ACIA_DATA
                ; check if byte is correct
                sta mouse_byte_2
                and #%01000000
                beq store_second_byte
                rts

store_second_byte:
                lda mouse_byte_2
                and #%00111111
                sta mouse_byte_2

wait_third_byte:
                ; wait for ready status
                lda ACIA_STATUS
                and #$08        ; check rx buffer status flag
                beq wait_third_byte

                ; read 3. byte
                lda ACIA_DATA
                sta mouse_byte_3
                ; check if byte is correct
                and #%01000000
                beq store_third_byte
                rts

store_third_byte:
                lda mouse_byte_3
                and #%00111111
                sta mouse_byte_3

                ; manage data
                
                ; Display go to home
                lda #%00000010  
                jsr via_lcd_instruction

                ; Left button
l_button:
                lda #'L'
                jsr via_lcd_print_char
                lda #':'
                jsr via_lcd_print_char

                lda mouse_byte_1
                and #$20
                beq l_no_click

                lda #'1'      ; click on
                jsr via_lcd_print_char

                jmp r_button
l_no_click:
                lda #'0'      ; click off
                jsr via_lcd_print_char

                ; Right button
r_button:
                lda #' '      ; space
                jsr via_lcd_print_char
                lda #'R'
                jsr via_lcd_print_char
                lda #':'
                jsr via_lcd_print_char

                lda mouse_byte_1
                and #$10
                beq r_no_click

                lda #'1'      ; click on
                jsr via_lcd_print_char

                jmp ydir
r_no_click:
                lda #'0'      ; click off
                jsr via_lcd_print_char

                ; UP/DOWN dir
ydir:
                lda #' '
                jsr via_lcd_print_char

                lda mouse_byte_1
                and #$08
                beq ydir_down

                lda #'U'
                jsr via_lcd_print_char
                
                jmp xdir
ydir_down:

                lda #'D'
                jsr via_lcd_print_char

                ; LEFT/RIGHT dir
xdir:
                lda mouse_byte_1
                and #$02
                beq xdir_down

                lda #'L'
                jsr via_lcd_print_char

                jmp next_line
xdir_down:
                lda #'R'
                jsr via_lcd_print_char

next_line:
                lda #' '
                jsr via_lcd_print_char
                lda #' '
                jsr via_lcd_print_char
                lda #' '
                jsr via_lcd_print_char

                lda #%10101000  ; New line
                jsr via_lcd_instruction
xpos:

                lda #'X'
                jsr via_lcd_print_char
                lda #':'
                jsr via_lcd_print_char

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
                jsr via_lcd_print_char

ypos:
                lda #'Y'
                jsr via_lcd_print_char
                lda #':'
                jsr via_lcd_print_char
                
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
                jsr via_lcd_print_char
                lda #' '
                jsr via_lcd_print_char

                rts