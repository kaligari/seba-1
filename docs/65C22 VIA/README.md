# SEBA-1 Sampler Module (VIA 65C22)

This module demonstrates how to use the **WDC 65C22 VIA** chip to play raw 8-bit audio samples from EEPROM.  
It uses a simple **R-2R DAC** connected to Port B and plays back audio by reading bytes from memory and outputting them with precise timing using delay loops.

## 🧠 Overview

- 8-bit audio, mono, 8000 Hz (8 kHz)
- Sample stored in two 8KB EEPROMs (total: 16KB)
- Start and end addresses can be dynamically selected via keyboard
- Output via resistor DAC (R-2R ladder) on Port B

## 🎵 How to prepare your own samples

You can use any WAV file as long as it's mono and 8-bit. Recommended length: **2 seconds** (≈16KB total at 8kHz).  
Use the following `ffmpeg` command to convert audio into raw binary:

```bash
ffmpeg -i your_sample.wav -f u8 -acodec pcm_u8 -ar 8000 -ac 1 output.raw
```

Then split it into two 8KB parts:

```bash
head -c 8192 sample.raw > sampler_start.bin
tail -c 8192 sample.raw > sampler_end.bin
```

Now burn both `.bin` files into two separate EEPROMs (e.g. AT28C64) and install them in the hardware.

## ⌨️ Triggering Samples via Keyboard

- A matrix keyboard is connected to Port A (via shift registers)
- Function keys **F1 to F8** trigger playback of different slices of the sample
- On key press, an **interrupt** is triggered
- The **start and end address** of the slice are written to RAM by the handler
- Playback routine reads bytes sequentially from EEPROM, writes to Port B, and adds a short delay to maintain 8kHz rate

## 🛠️ Hardware used

- WDC 65C22 VIA
- Two AT28C64 EEPROMs (8KB each)
- R-2R DAC (resistor ladder)
- Matrix keyboard (5×8)
- 16×2 LCD (optional)
- Address decoding via 74LS684
- SEBA-1 Bus connector (IDC 40-pin)

## 🧪 Tested Samples

- "Amen Break" drums
- MacOS startup sound
- OIIA OIIA cat 🐱

---

> 📝 This module is a proof of concept and is not planned to be soldered into a permanent board.  
> If you'd like to play with it yourself, all schematics and binaries are provided here!

📡 **Follow the full series on YouTube**: [Too Many Wires](https://www.youtube.com/@kaligari88)
