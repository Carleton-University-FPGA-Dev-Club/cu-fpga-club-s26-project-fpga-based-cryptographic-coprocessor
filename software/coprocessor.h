#ifndef COPROCESSOR_H
#define COPROCESSOR_H

#include "xil_types.h"
#include <stdbool.h>

void encrypt(u32 *ciphertext, char *plaintext, char *key);
_Bool is_password_correct(u32 *expected, u32 *actual);

// Runs the process for one 128-bit block encryption
void send_encryption_command(u32 *ciphertext, char *plaintext, char *key);

// Interaction with the AXI registers
void reset_fsm();
void start_encryption();
void poll_ready_register();
void write_to_plaintext_registers(u32 *plaintext);
void write_to_key_registers(u32 *key);
void read_ciphertext_registers(u32 *ciphertext);

// Utility functions
void chunk_128_into_32_bits(u32 *chunks, char *block);
uint32_t reverse_uint32(uint32_t val);

#endif
