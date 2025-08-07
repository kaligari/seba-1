.setcpu "65C02"
.segment "VIA"

VIA_PORTB   = $C000
VIA_PORTA   = $C001
VIA_DDRB    = $C002
VIA_DDRA    = $C003
VIA_PCR_AB  = $C00C         ; Peripheral Control Register
VIA_IFA_AB  = $C00D         ; Interrupt flag register
VIA_IER_AB  = $C00E         ; Interrupt enable register

via_init:
                lda #$82        ; Set bit 7 (global interrupt enable) and bit 1 (port A interrupt enable)
                sta VIA_IER_AB      ; Write to Interrupt Enable Register
                lda #$01        ; Set interrupt trigger mode to negative edge for port A
                sta VIA_PCR_AB      ; Write to Peripheral Control Register

                lda #%11111111  ; Set all pins on port B to output
                sta VIA_DDRB
                lda #%00000000  ; Set all pins on port A to input
                sta VIA_DDRA
                rts