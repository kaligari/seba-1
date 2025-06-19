.setcpu "65C02"
.debuginfo
.segment "BIOS"

ACIA_DATA       = $8000
ACIA_STATUS     = $8001
ACIA_CMD        = $8002
ACIA_CTRL       = $8003

.include "wozmon.s"

.segment "RESETVEC"
                .word   $0F00          ; NMI vector
                .word   RESET          ; RESET vector
                .word   $0000          ; IRQ vector