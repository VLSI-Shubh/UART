# 🧠 UART Communication Module

---

## 📘 Project Overview

This project implements a **UART (Universal Asynchronous Receiver Transmitter)** system in Verilog, enabling asynchronous serial communication between devices.  
It features parameterized baud rate control and uses **16x oversampling** for accurate timing.

The design consists of:  
- UART Transmitter (`uart_tx`)  
- UART Receiver (`uart_rx`)  
- Baud Rate Generator (`baudgen`)  
- Top-level UART module integrating all components  

---

## 📚 Concept

![UART Signal Timing](https://github.com/VLSI-Shubh/UART/blob/9670f21304cc0d88aecab5e8e9da1ba9f72bc4e5/uart.png)  
*UART transmits data serially using start bits, data bits, and stop bits.*

- **Start Bit:** Logic 0 signals start of data frame.  
- **Data Bits:** 8 bits transmitted least significant bit (LSB) first.  
- **Stop Bit:** Logic 1 signals end of frame.  
- **Baud Rate:** Data bits are timed using a baud rate generator, with oversampling (16x) to reduce sampling errors.  

---

## 🔄 Full-Duplex UART Communication

- The UART module uses **separate TX and RX lines**, enabling simultaneous transmission and reception of data.  
- This means the module supports **full-duplex** communication, where data can be sent and received independently at the same time.  

### Why Full Duplex?

- Full duplex allows bidirectional communication without waiting for the other side to finish transmitting.  
- Essential for many real-world UART applications where devices need to send commands and receive responses concurrently.  
- Improves communication efficiency and responsiveness.

### How It Works in This Design

- The **transmitter (`uart_tx`)** drives the `tx` line independently.  
- The **receiver (`uart_rx`)** listens on the `rx` line independently.  
- Both operate concurrently, controlled by their respective FSMs and synchronized with the baud rate generator.  

💡 *In testbench, the `rx` line is connected to the `tx` line (`assign rx = tx;`) to simulate loopback testing, but in a real system, these lines would connect to different devices or separate pins.*


---
## ⚙️ Implementation Details

- **UART Receiver (`uart_rx`):**  
  Implements a 4-state FSM (`idle`, `start`, `data`, `stop`).  
  Samples incoming bits at 16x the baud rate (`baud_tick`) to reliably detect bits.  
  Outputs received byte and asserts `rx_done` when a full byte is received.

- **UART Transmitter (`uart_tx`):**  
  Waits for `start_tx` signal to begin sending data.  
  Sends start bit, 8 data bits, and stop bit serially timed by `baud_tick`.  
  Asserts `tx_done` when transmission finishes.

- **Baud Rate Generator (`baudgen`):**  
  Generates a `baud_tick` pulse at 16x the desired baud rate.  
  Parameters allow configuring clock frequency and baud rate.

- **Top-Level UART Module (`uart`):**  
  Integrates transmitter, receiver, and baud rate generator.  
  Handles serial input/output and provides control/status signals for easy integration.

---

## 🧪 Output Waveform

Here is an example waveform from GTKWave showing UART transmission and reception signals:  

![UART Waveform](https://github.com/VLSI-Shubh/UART/blob/9670f21304cc0d88aecab5e8e9da1ba9f72bc4e5/output%20waveform.png)  

---

## 🧪 VCD Dump Explanation

During simulation, a VCD (Value Change Dump) file named `uart_tb.vcd` is generated to record signal transitions and timing data.  
This file can be viewed using waveform viewers such as GTKWave to analyze the UART operation.

You will see console output like this:

VCD info: dumpfile uart_tb.vcd opened for output.
TX done at 838710000
RX done at 942710000
Received Byte: a5

- **`VCD info`**: Indicates the VCD file was successfully created and opened for dumping simulation data.  
- **`TX done at 838710000`**: Shows the simulation time (in nanoseconds) when the UART transmitter finished sending the byte.  
- **`RX done at 942710000`**: Shows the simulation time when the UART receiver completed receiving the byte.  
- **`Received Byte: a5`**: Confirms that the received data byte matches the transmitted byte (`0xA5`).

---

### Testbench Summary

- The testbench uses a 50 MHz clock (`CLK_PERIOD = 20 ns`) and a baud rate of 9600.  
- Transmission is initiated by asserting `start_tx` and providing the data byte `0xA5`.  
- The transmitter serializes the data on the `tx` line, which is looped back to the receiver input `rx`.  
- The testbench waits for the `tx_done` and `rx_done` signals indicating transmission and reception completion.  
- Once reception is complete, the received byte is displayed in the simulation console.

---

### Timing Details

- The UART receiver samples the serial data at 16 times the baud rate (16x oversampling) to improve bit detection accuracy.  
- This results in the receiver completing after the transmitter by several bit periods, consistent with UART communication timing.

---

## 🖥️ Terminal Screenshot

Example terminal output from simulation showing received data:  

![Terminal Screenshot](https://github.com/VLSI-Shubh/UART/blob/9670f21304cc0d88aecab5e8e9da1ba9f72bc4e5/output.png)  
*Shows successful transmission and reception of ASCII characters via UART.*

---

## 📁 Project Files

| File         | Description                     |
| ------------ | -------------------------------|
| `uart_rx.v`  | UART Receiver module            |
| `uart_tx.v`  | UART Transmitter module         |
| `baudgen.v`  | Baud rate generator             |
| `uart.v`     | Top-level UART module           |
| `uart_tb.v`  | Testbench for UART communication|

---

## 🛠️ Tools Used

- **Icarus Verilog:** RTL simulation and verification  
- **GTKWave:** Waveform visualization and analysis  
- **Vivado:** FPGA synthesis and implementation  

---

## 📐 Parameter Configuration

| Parameter     | Description                  | Default      |
| ------------- | ---------------------------- | ------------ |
| `BAUD_RATE`   | UART baud rate               | 9600         |
| `CLOCK_FREQ`  | System clock frequency (Hz)  | 50,000,000   |

---

## ✅ Conclusion

This project provides a functional UART design suitable for FPGA or ASIC integration.  
It demonstrates serial communication with configurable baud rates, oversampling for reliability, and clean FSM-based design for transmitter and receiver.

---

## 🚀 Future Work

- **Currently working on a UART with FIFO pipeline design, debugging transmission/reception errors.**
- Adding parity bit and configurable data/stop bits.  
- Implementing flow control (RTS/CTS).  
- Adding error detection (framing, parity errors).  


---

## ⚖️ License

Available for personal and educational use under the [MIT License](https://github.com/VLSI-Shubh/UART/blob/4821647ea0092a14593d38e09b6923db8d5b82ec/License.txt)

