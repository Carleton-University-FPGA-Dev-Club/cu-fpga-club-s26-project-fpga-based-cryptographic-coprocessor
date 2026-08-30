# AES-128
The overall goal of this project is to accelerate an encryption algorithm on the FPGA fabric, and have the results be useful elsewhere, such as an ARM processor running an ordinary application. AES-128 was chosen as the encryption algorithm to implement due to its widespread usage, as well as it being declared the official federal security standard by the National Institute of Standards and Technology  [1].

Some quick facts about AES-128:
* **Symmetric**: Same key to encrypt and decrypt
* **Block size:** It works with a 128-bit plaintext block and a 128-bit key block, resulting in a 128-bit ciphertext block
* **Rounds:** It performs 10 repetitive rounds of scrambling the plaintext

## Blackbox
For all intents and purposes, the AES module being programmed in Verilog and being synthesized into flip-flops and combinatory logic is a blackbox to the ARM processor. It can be summarized as the following inputs and outputs.
```
                               ┌──────────────────┐
   Plaintext (128-bit) ─▶     │ AES Module       |
   Key (128-bit) ─▶           |                  |   ─▶ Ciphertext (128-bit)
   Clock (1-bit) ─▶           |                  |   ─▶ Ready (1-bit)
   Reset (1-bit) ─▶           |                  |
   Start (1-bit) ─▶           └──────────────────┘
```

## Implementation
Due to the round-based nature of the AES-128 algorithm, it was implemented as a finite-state machine (FSM). The diagram representing the FSM is shown below. By nature, it is a Moore-based FSM, since the output is only tied to the state.

All steps belong to the official AES-128 specification, apart from `IDLE` and `READY`. These two states are to enable communication with the soft processor. For example, the result should only be read by the processor when the FPGA sets the ready flag high.  

For a simpler sticky-figure introduction to the AES algorithm, you can visit the following website: https://www.moserware.com/2009/09/stick-figure-guide-to-advanced.html [2]. 
```
┌──────────────────┐
│ IDLE             │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ INITIAL ROUND    │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ SUB BYTES        │◀ ─┐
└────────┬─────────┘    |
         │              |
         ▼              |
┌──────────────────┐    |
│ SHIFT ROWS       │    |   
└────────┬─────────┘    |
         │              |
         ▼              |
┌──────────────────┐    |
│ MIX COLUMNS      │    |
└────────┬─────────┘    |
         │              |
         ▼              |
┌──────────────────┐    | (Round Number < 10)
│ ADD ROUND KEY    │────┘
└────────┬─────────┘
         │  (Round Number = 10)
         ▼
┌──────────────────┐
│ READY (Done = 1) │
└──────────────────┘
```

## Interpretation
Since AES-128 works with 128-bit plaintext and key, it is beneficial to visualize them as 16 bytes. The AES-128 calls the following matrix *the state*. It is the main data structure that gets modified through the 10 rounds. By the end of the 10 rounds, this matrix is the ciphertext. Note that it is stored in column-major order.
|     |     |    |      |
|---- | ----|----| ---- | 
| b15 | b11 | b7 | b3   |
| b14 | b10 | b6 | b2   |
| b13 | b9  | b5 | b1   |
| b12 | b8  | b4 | b0   |

It is also possible for `b0` to be the first element in the matrix, as opposed to `b15`. However, this was a design choice to keep everything in big endian format, to keep the data readable from left-to-right.   

While the data was visualized using the state matrix, it was programmed in Verilog using a 128-bit number. This is due to a Verilog implementation detail, where passing a matrix is 2D array by ports is not allowed.  

Let's go through an example:
* **Plaintext:** `accomplishments`
* **Hexadecimal Value (ASCII):** `0x61 63 63 6F 6D 70 6C 69 73 68 6D 65 6E 74 73 00`

Note that the plaintext is 15 characters, which means 15 bytes. Thus, 0x00 was added at the end to simulate the null terminator for a C programming language approach. *The state* table now gets populated:
|      |      |      |        |
|----  | ---- |------| ------ | 
| 0x61 | 0x6D | 0x73 | 0x6E   |
| 0x63 | 0x70 | 0x68 | 0x74   |
| 0x63 | 0x6C | 0x6D | 0x73   |
| 0x6F | 0x69 | 0x65 | 0x00   |

## References
[1] https://www.nist.gov/publications/advanced-encryption-standard-aes  
[2] https://www.moserware.com/2009/09/stick-figure-guide-to-advanced.html
