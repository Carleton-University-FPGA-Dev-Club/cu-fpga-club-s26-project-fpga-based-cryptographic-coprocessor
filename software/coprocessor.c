#include "xil_types.h"
#include "xil_io.h"
#include "xparameters.h"
#include "coprocessor.h"
#include "string.h"


// AXI Register Definitions
#define CONTROL_REGISTER XPAR_COPROCESSOR_0_S00_AXI_BASEADDR
#define STATUS_REGISTER CONTROL_REGISTER + 0x04
#define PLAINTEXT_REGISTER_BASE CONTROL_REGISTER + 0x08
#define KEY_REGISTER_BASE CONTROL_REGISTER + 0x18
#define CIPHERTEXT_REGISTER_BASE CONTROL_REGISTER + 0x28


// The only public function, the rest is internal
// In the sense that applications using this module should not call anything else
void encrypt(char *ciphertext, char *plaintext, char *key) {
	reset_fsm();
	char ciphertext[128];
	send_encryption_command(ciphertext, plaintext, key);
}

// Encrypts one 128-bit chunk of data
void send_encryption_command(char *ciphertext, char *plaintext, char *key) {
	u32 plaintext_blocks[4];
	u32 key_blocks[4];

	chunk_128_into_32_bits(plaintext_blocks, plaintext);
	chunk_128_into_32_bits(key_blocks, key);

	write_to_plaintext_registers(plaintext_blocks);
	write_to_key_registers(key_blocks);

	start_encryption();
	poll_ready_register();

	u32 ciphertext_blocks[4];
	read_ciphertext_registers(ciphertext_blocks);
	chunk_32_into_128_bits(ciphertext, ciphertext_blocks);
}

// Interaction with AXI registers
void reset_fsm() {
	Xil_Out32(CONTROL_REGISTER, 0b00);
}

void start_encryption() {
	Xil_Out32(CONTROL_REGISTER, 0b01);
}

void poll_ready_register() {
	u32 status; 
	while (1) {
		status = Xil_In32(STATUS_REGISTER);
		if (status == 0b1)
			return;
	}
}

void write_to_plaintext_registers(u32 *plaintext) {
	u32 addr = PLAINTEXT_REGISTER_BASE;
	for (int i = 0; i < 4; i++) {
		Xil_Out32(addr, plaintext[i]);
		addr = addr + 0x04;
	}
}

void write_to_key_registers(char *key) {
	u32 addr = KEY_REGISTER_BASE;
	for (int i = 0; i < 4; i++) {
		Xil_Out32(addr, plaintext[i]);
		addr = addr + 0x04;
	}
}

void read_ciphertext_registers(u32 *ciphertext) {
	u32 addr = CIPHERTEXT_REGISTER_BASE;
	for (int i = 0; i < 4; i++) {
		ciphertext[i] = Xil_In32(addr);
		addr = addr + 0x04;
	}
}

// Utility functions
// Length of chunks is constant 4
void chunk_128_into_32_bits(u32 *chunks, char *block) {
	for (int i = 0; i < 4; i++)
		memcpy(&chunks[i], &block[i*4], 4);
}

void chunk_32_into_128_bits(char *block, u32 *chunks) {
	for (int i = 0; i < 4; i++)
		memcpy(&block[i*4], &chunks[i], 4);
}
