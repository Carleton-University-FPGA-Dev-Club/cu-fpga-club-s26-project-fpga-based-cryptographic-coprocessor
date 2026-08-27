#include <stdio.h>
#include <string.h>
#include <stdbool.h>

#include "platform.h"
#include "xil_printf.h"
#include "xil_types.h"

#include "coprocessor.h"
#include "banking.h"

account *find_account(account *accounts, int account_number) {
	for (int i = 0; i < 5; i++) {
		if (!accounts[i].is_used)
			continue;

		if (accounts[i].account_number == account_number)
			return &accounts[i];
	}

	return NULL;
}

account *create_account(account *accounts) {
	int account_number;
	char name[MAX_NAME_LENGTH];
	char password[MAX_PASSWORD_LENGTH] = {0};
	double balance;

	int index = -1;
	for (int i = 0; i < 5; i++) {
		if (accounts[i].is_used)
			continue;

		index = i;
	}

	if (index == -1) {
		printf("\nSorry, you cannot create any more accounts.");
		return NULL;
	}

	printf("\nEnter Account Number: ");
	scanf("%d", &account_number);

	account *existing = find_account(accounts, account_number);
	if (existing != NULL) {
		printf("\nThis account already exists.");
		return NULL;
	}

	printf("\nEnter Account Holder Name: ");
	scanf("%s", name);

	printf("\nEnter Account Password: ");
	scanf("%s", password);

	if (strlen(password) > MAX_PASSWORD_LENGTH) {
		printf("\nPasswords cannot be more than 16 characters long.");
		return NULL;
	}

	printf("\nEnter Initial Balance: ");
	scanf("%lf", &balance);

	account *new_account;
	new_account->account_number = account_number;
	strncpy(new_account->name, name, MAX_NAME_LENGTH);
	strncpy(new_account->password, password, MAX_PASSWORD_LENGTH);

	//printf("Printing the password...\n");
	//for (int i = 0; i < MAX_PASSWORD_LENGTH; i++) {
	//	printf("%c", password[i]);
	//}

	u32 password_blocks[4];
	encrypt(password_blocks, password, KEY);
	for (int i = 0; i < 4; i++) {
		new_account->password_blocks[i] = password_blocks[i];
	}

	//printf("Looping through password blocks...\n");
	//for (int i = 0; i < 4; i++) {
	//	printf("%0xlx\n", password_blocks[i]);
	//}

	new_account->balance = balance;
	new_account->is_used = 1;

	accounts[index] = *new_account;
	printf("\nAccount added successfully!");
	return new_account;
}

void display_all_accounts(account *accounts) {
	for (int i = 0; i < 5; i++) {
		printf("\nAccount Number: %d\n", accounts[i].account_number);
		printf("Account Name: %s\n", accounts[i].name);
		//printf("Account Password: %s\n", accounts[i].password);
		printf("Account Balance: %lf\n", accounts[i].balance);
		printf("------------------------------------------\n");
	}
}

_Bool ask_for_password(account *account) {
	char password[MAX_PASSWORD_LENGTH] = {0};
	printf("Enter your password: ");
	scanf("%s", password);

	//printf("Printing the password...\n");
	//for (int i = 0; i < MAX_PASSWORD_LENGTH; i++) {
	//	printf("%c", password[i]);
	//}

	u32 password_blocks[4];
	encrypt(password_blocks, password, KEY);

	//printf("Looping through password blocks...\n");
	//for (int i = 0; i < 4; i++) {
	//	printf("%0xlx\n", password_blocks[i]);
	//}

	for (int i = 0; i < 4; i++) {
		if (password_blocks[i] != account->password_blocks[i])
			return false;
	}

	return true;
}


void withdraw(account *account, double amount) {
    if (amount <= account->balance) {
        account->balance -= amount;
        printf("Withdrawn: $%lf\n", amount);
        printf("New Balance: $%lf\n", account->balance);
    } else {
        printf("Insufficient balance\n");
    }	
}


void deposit(account *account, double amount) {
	account->balance += amount;
    printf("Deposited: $%lf\n", amount);
    printf("New Balance: $%lf\n", account->balance);
}


void perform_transaction(account *accounts, _Bool is_deposit) {
	int account_number;
	double amount;

	printf("\nEnter Account Number: ");
	scanf("%d", &account_number);

	account* account = find_account(accounts, account_number);

	if (account == NULL) {
		printf("Account not found.\n");
		return;
	}

	if (!ask_for_password(account)) {
		printf("Incorrect password.\n");
		return;
	}

	printf("\nEnter amount: ");
	scanf("%lf", &amount);

	if (is_deposit) {
		deposit(account, amount);
	} else {
		withdraw(account, amount);
	}
}

int main(void) {
	init_platform();

	// Accounts
	account accounts[5] = {0};

	int choice;
	do {
		printf("\nBank Management System\n");
		printf("1. Add Account\n");
		printf("2. Display All Accounts\n");
		printf("3. Deposit\n");
		printf("4. Withdraw\n");
		printf("5. Exit\n");
		printf("Enter your choice: ");

		scanf("%d", &choice);

		switch (choice) {
			case 1:
				create_account(accounts);
				break;
			case 2:
				display_all_accounts(accounts);
				break;
			case 3:
				perform_transaction(accounts, true); // isDeposit = true
				break;
			case 4:
				perform_transaction(accounts, false); // isDeposit = false
				break;
			case 5:
				printf("Exiting...\n");
				break;
			default:
				printf("Invalid choice!\n");
		}
	} while (choice != 5);

	cleanup_platform();
	return 0;
}
