.setcpu "65C02"
.segment "ACIA"

ACIA_DATA       = $8000
ACIA_STATUS     = $8001
ACIA_CMD        = $8002
ACIA_CTRL       = $8003

acia_init:
                lda     #$00
                sta     ACIA_DATA

                lda     #$38           ; 0011 1000: N-7-1, 19200 baud.
                sta     ACIA_CTRL
                lda     #$09           ; 0000 1001: No parity, no echo, rx interrupts
                sta     ACIA_CMD
                rts