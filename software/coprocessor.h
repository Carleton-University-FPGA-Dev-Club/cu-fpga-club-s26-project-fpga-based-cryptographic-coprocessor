#ifndef COPROCESSOR_H
#define COPROCESSOR_H

#include "xil_types.h"

// The only public function
void encrypt(char *ciphertext, char *plaintext, char *key);

// Runs the process for one 128-bit block encryption
void send_encryption_command(char *ciphertext, char *plaintext, char *key);

// Interaction with the AXI registers
void reset_fsm();
void start_encryption();
void poll_ready_register();
void write_to_plaintext_registers(char *plaintext);
void write_to_key_registers(char *key);
void read_ciphertext_registers(char *ciphertext);

// Utility functions
void chunk_128_into_32_bits(u32 *chunks, char *block);
void chunk_32_into_128_bits(char *block, u32 *chunks);

#endif
