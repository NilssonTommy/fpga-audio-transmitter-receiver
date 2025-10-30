# fpga-audio-communication-system



A complete audio transmission system combining analog and digital electronics. It captures sound from a microphone, converts it to digital form, transmits it serially via FPGA logic, and reconstructs it for playback through a headphone amplifier.

## Overview
Transmitter: Microphone amplifier -> Sample & Hold -> A/D converters -> Serial transmitter (VHDL)
- Receiver: Serial receiver (VHDL) -> D/A converter -> Low-pass filter -> Power amplifier
Communication: UART-style asynchronous serial link between two FPGAs.

## Hardware
-FPGA board
-DAC: DAC0808
-Sample & Hold: LF398
- OP-amp: TL071 (used in several stages)
-Transistors: Push-pull output stage for headphone drive
-Supply: +- 15 V analog, + 3.3 V digital
-Clock: 50Mhz
- Baud rate: 100kbit/s

## Features
- 8-bit SAR A/D conversion
-UART-based digital transmission
-Active 4th order Butterworth low-pass filter (12kHz cutoff)
-Microphone and headphone amplification
-Tested with audio frequencies 20 Hz - 12 kHz
