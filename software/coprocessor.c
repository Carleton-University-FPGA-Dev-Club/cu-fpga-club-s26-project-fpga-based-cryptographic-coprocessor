#include <string.h>
#include <stdio.h>
#include <stdbool.h>

#include "xil_types.h"
#include "xil_io.h"
#include "xparameters.h"
#include "coprocessor.h"

/*
 * AXI-4 Lite can only transfer 32-bit words at a time.
 * The 128-bit plaintext, key, and ciphertext need to be chunked into 4 registers.
 *
 * The following is the "register map" that PS and PL agree on.
 * Each of the registers contain a 32-bit value.
 * Each of the control and status fields are 1-bit, and they start from the LSB.
 * |------------------------------------------------------|
 * | Register	| Value						| Address	  |
 * |------------------------------------------------------|
 * | R0			| Control (Reset, Start)	| BASE		  |
 * | R1			| Status (Ready)			| BASE + 0x04 |
 * | R2			| Plaintext 0				| BASE + 0x08 |
 * | R3			| Plaintext 1				| BASE + 0x0C |
 * | R4			| Plaintext 2				| BASE + 0x10 |
 * | R5			| Plaintext 3				| BASE + 0x14 |
 * | R6			| Key 0						| BASE + 0x18 |
 * | R7			| Key 1						| BASE + 0x1C |
 * | R8			| Key 2						| BASE + 0x20 |
 * | R9			| Key 3						| BASE + 0x24 |
 * | R10		| Ciphertext 0				| BASE + 0x28 |
 * | R11		| Ciphertext 1				| BASE + 0x2C |
 * | R12		| Ciphertext 2				| BASE + 0x30 |
 * | R13		| Ciphertext 3				| BASE + 0x34 |
 * |------------------------------------------------------|
 */

// AXI Register Definitions
#define CONTROL_REGISTER 0x43C00000
#define STATUS_REGISTER CONTROL_REGISTER + 0x04
#define PLAINTEXT_REGISTER_BASE CONTROL_REGISTER + 0x08
#define KEY_REGISTER_BASE CONTROL_REGISTER + 0x18
#define CIPHERTEXT_REGISTER_BASE CONTROL_REGISTER + 0x28


// Public functions
void encrypt(u32 *ciphertext, char *plaintext, char *key) {
	reset_fsm();
	send_encryption_command(ciphertext, plaintext, key);
}

_Bool is_password_correct(u32 *expected, u32 *actual) {
	for (int i = 0; i < 4; i++) {
		if (expected[i] != actual[i])
			return false;
	}
	return true;
}

// Internal functions
// Encrypts one 128-bit chunk of data
void send_encryption_command(u32 *ciphertext, char *plaintext, char *key) {
	u32 plaintext_blocks[4];
	u32 key_blocks[4];

	chunk_128_into_32_bits(plaintext_blocks, plaintext);
	chunk_128_into_32_bits(key_blocks, key);

	write_to_plaintext_registers(plaintext_blocks);
	write_to_key_registers(key_blocks);

	start_encryption();
	poll_ready_register();

	read_ciphertext_registers(ciphertext);
}

// Interaction with AXI registers
void reset_fsm() {
	Xil_Out32(CONTROL_REGISTER, 0b10); // Reset = 1, Start = 0
	Xil_Out32(CONTROL_REGISTER, 0b00); // Reset = 0, Start = 0
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

void write_to_key_registers(u32 *key) {
	u32 addr = KEY_REGISTER_BASE;
	for (int i = 0; i < 4; i++) {
		Xil_Out32(addr, key[i]);
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

// Reverses endianness
uint32_t reverse_uint32(uint32_t val) {
    return ((val & 0x000000FF) << 24) |
           ((val & 0x0000FF00) << 8)  |
           ((val & 0x00FF0000) >> 8)  |
           ((val & 0xFF000000) >> 24);
}

// Length of chunks is constant 4
void chunk_128_into_32_bits(u32 *chunks, char *block) {
	for (int i = 0; i < 4; i++) {
		memcpy(&chunks[i], &block[i*4], 4);
		chunks[i] = reverse_uint32(chunks[i]);
	}
}
