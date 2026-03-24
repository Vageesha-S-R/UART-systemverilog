# UART IP Core with Wishbone Interface (SystemVerilog)

Designed and verified a UART (Universal Asynchronous Receiver Transmitter) IP core with FIFO buffering and Wishbone bus interface.

##  Features

### 🔹 UART Functionality
- 8-bit data transmission (LSB first)
- Configurable baud rate
- Start and stop bit handling
- Optional parity support (even/odd)

### 🔹 Receiver Enhancements
- 16× oversampling for robust data recovery
- Mid-bit sampling for noise tolerance

### 🔹 FIFO Buffers
- Separate TX and RX FIFOs
- Prevents data loss during burst transfers
- Handles asynchronous producer/consumer rates

### 🔹 Register Interface
- Memory-mapped registers:
  - TX Data Register (write)
  - RX Data Register (read)
  - Status Register
  - Control Register
- Supports parity configuration and interrupt enable

### 🔹 Interrupt Support
- RX data available interrupt
- TX ready interrupt
- Parity error interrupt

### 🔹 Wishbone Bus Interface
- Fully compatible Wishbone slave interface
- Supports read/write transactions
- Proper handling of multi-cycle read latency
- Correct synchronization of `ack` with valid data

##  Tools Used

- SystemVerilog
- Icarus Verilog (iverilog)
- GTKWave (waveform analysis)