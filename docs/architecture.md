# Architecture

The broad strokes of the system architecture can be divided into three functional blocks.  
* **Application:** Represents any application that needs to work with encrypted data. This project comes with a banking application as a demonstration, where passwords encryption is required before sensitive actions. 
* **Coprocessor Interface:** The C code that commands the FPGA hardware. It is capable of starting or resetting an encryption, loading plaintext and key registers, and reading from the resulting ciphertext registers. 
* **AES Module:** The FPGA hardware that runs the AES algorithm iteratively and raises a ready flag when finished. When finished, the coprocessor interface is able to read the resulting ciphertext. 

AXI-4 Lite was chosen as the form of communication between the hardware and software components. It was chosen due to its simplicity, as it works exactly like memory-mapped I/O [1]. It may need to be reconsidered for different application needs.

```
┌——————————————————————————┐
| Software                 |
|  ┌──────────────────┐    |
│  | Application (C)  │    |
|  └——————————————————┘    |
|           │              |
|           ▼              |
|  ┌──────────────────┐    |
|  │  Coprocessor     |    |
|  |   Interface (C)  │    |
|  └────────┬─────────┘    |
|           │              |        
└——————————————————————————┘           
            |    
┌——————————————————————————┐
| Hardware  |              |
|           ▼              |
|  ┌──────────────────┐    |
│  |    AES Module    |    |
|  |    (Verilog)     │    |
|  └——————————————————┘    |
└——————————————————————————┘
```

> [!NOTE]
> All of the system components interpret the important values as big endian to keep the dataflow readable in a left-to-right manner. The AES module was implemented in Verilog through an iterative FSM approach. Please check out the `aes.md` documentation to learn more.

## Alternative Choices
Upon initial research, many implementations seemed to lean towards a custom CPU approach [4]. However, this was decided against for multiple reasons:
* Consists of a lot more components, hiding the main goal of being a "coprocessor"
* It would need AES programmed as a native instruction for the CPU's custom ISA
* It would certainly involve challenging pipelining concepts, as executing ISA step-by-step is analogous to running high-level code, and it doesn't exploit the parallel nature of the FPGA fabric.

<img width="532" height="191" alt="image" src="https://github.com/user-attachments/assets/1f67d11a-9c87-4c53-bc99-3e221385a3f5" />    

*Figure 1: Alternative Coprocessor Implementation [2]*

Rather, real-life coprocessors usually have dedicated hardware module interacting with the system through a communication protocol [3]. It leads to a much more efficient design by enabling IP reuse, and only the major problem at hand (AES encryption) is offloaded to the FPGA hardware [4].

<img width="530" height="177" alt="image" src="https://github.com/user-attachments/assets/24415b24-b7e4-4ef5-a031-42e1caf01374" />

*Figure 2: Crypto Coprocessor from Cadence Secure-IC [3]*


## Register Map
As mentioned above, AXI-4 Lite was the chosen form of communication between the hardware and software modules. Since AXI-4 Lite uses memory-mapped registers, the data flowing into the AES hardware module needs to be identifiable by an address [5].  

A limitation of AXI-4 Lite is that it uses the General Ports (GP) on Zynq-7000 devices, which is only capable of transferring 32-bit words at a time. Thus, 128-bit values like the plaintext, key, and resulting ciphertext have to be chunked into 4x 32-bit registers at the interface layer.

Note that the `BASE` address may vary based on your generated block design, though it is usually `0x43C00000`, as that marks the start of the first user-defined AXI-4 Lite register. 

> [!NOTE]
> All values in the Control and Status registers are 1-bit values and they are listed in MSB to LSB order. For example, the control register's LSB (`b0`) is the start signal, and the next bit (`b1`) is the reset signal.

_Table 1: Register Map for the FPGA-Based Cryptographic Coprocessor_
| Register | Value                   | Address     |
| -------- | ----------------------- | ----------- |
| R0       | Control (Reset, Start)  | BASE        |
| R1       | Status (Ready)          | BASE + 0x04 | 
| R2       | Plaintext 0             | BASE + 0x08 |
| R3       | Plaintext 1             | BASE + 0x0C |
| R4       | Plaintext 2             | BASE + 0x10 |
| R5       | Plaintext 3             | BASE + 0x14 |
| R6       | Key 0                   | BASE + 0x18 |
| R7       | Key 1                   | BASE + 0x1C |
| R8       | Key 2                   | BASE + 0x20 |
| R9       | Key 3                   | BASE + 0x24 |
| R10      | Ciphertext 0            | BASE + 0x28 |
| R11      | Ciphertext 1            | BASE + 0x2C |
| R12      | Ciphertext 2            | BASE + 0x30 |
| R13      | Ciphertext 3            | BASE + 0x34 |
| R14      | -                       | -           |
| R15      | -                       | -           |

## References
[1] https://en.wikipedia.org/wiki/Memory-mapped_I/O_and_port-mapped_I/O  
[2] https://ijres.iaescore.com/index.php/IJRES/article/view/21556    
[3] https://www.secure-ic.com/products/securyzr/cryptocoprocessors/  
[4] https://www.nature.com/articles/s41598-026-58079-9  
[5] https://backend.orbit.dtu.dk/ws/portalfiles/portal/125849853/tr16_07_Nannarelli_A.pdf
