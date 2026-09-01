/**
 * banking.h - Contains datatypes and constants for banking.c
 */
#include <stdint.h>
#include "xil_types.h"

#define MAX_NAME_LENGTH 16
#define MAX_PASSWORD_LENGTH 16
#define MAX_ACCOUNTS 10
#define KEY "m8X!qL2#vP9$kR4" // This needs to be more secure of course

// --------------------
// Account
// --------------------
typedef struct {
	int account_number;
	char name[MAX_NAME_LENGTH];
	u32 password_blocks[4];
	double balance;
} account;

