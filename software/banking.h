/**
 * banking.h - Contains datatypes and constants for banking.c
 */
#include <stdint.h>
#include "xil_types.h"

#define MAX_NAME_LENGTH 16
#define MAX_PASSWORD_LENGTH 16
#define KEY "m8X!qL2#vP9$kR4" // This needs to be more secure of course 

// --------------------
// Account
// --------------------
typedef struct {
	int is_used;
	int account_number;
	char name[MAX_NAME_LENGTH];
	char password[MAX_PASSWORD_LENGTH];
	u32 password_blocks[4];
	double balance;
} account;



//void display();
//void deposit(double amount);
//void withdraw(double amount);
//int getAccountNumber();
//char *getAccountHolderName();
//double getBalance();

// --------------------
// Bank
// --------------------
//typedef struct bank {
//	char bank_name[30];
//	struct bank *next;
//} bank_t;


//void add_account(Account* account);
//void display_accounts();
//account* find_account(int account_number);
