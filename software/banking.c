#include <stdio.h>
#include <string.h>
#include <stdbool.h>

#include "platform.h"
#include "xil_printf.h"
#include "xil_types.h"

#include "coprocessor.h"
#include "banking.h"


// The accounts array is initialized to zero at the start
// Account numbers must be positive, non-zero
// So it's a quick way to check that a slot in the array is unused
account *find_account(account *accounts, int account_number) {
	for (int i = 0; i < MAX_ACCOUNTS; i++) {
		if (accounts[i].account_number == 0)
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
	for (int i = 0; i < MAX_ACCOUNTS; i++) {
		if (accounts[i].account_number == 0) {
			index = i;
			break;
		}
	}

	if (index == -1) {
		printf("Sorry, you cannot create any more accounts.\n");
		return NULL;
	}

	printf("\nEnter Account Number: ");
	scanf("%d", &account_number);

	account *existing = find_account(accounts, account_number);
	if (existing != NULL) {
		printf("This account already exists.\n");
		return NULL;
	}

	printf("\nEnter Account Holder Name: ");
	scanf("%29s", name);

	printf("\nEnter Account Password: ");
	scanf("%15s", password);

	if (strlen(password) > MAX_PASSWORD_LENGTH) {
		printf("Passwords cannot be more than 16 characters long.\n");
		return NULL;
	}

	printf("\nEnter Initial Balance: ");
	scanf("%lf", &balance);

	if (balance < 0 || account_number <= 0) {
		printf("Balance and account number must be positive numbers.");
		return NULL;
	}

	account *new_account = &accounts[index];
	new_account->account_number = account_number;
	strncpy(new_account->name, name, MAX_NAME_LENGTH);

	u32 password_blocks[4];
	encrypt(password_blocks, password, KEY);
	for (int i = 0; i < 4; i++) {
		new_account->password_blocks[i] = password_blocks[i];
	}

	new_account->balance = balance;
	printf("\nAccount added successfully!");
	return new_account;
}

void display_all_accounts(account *accounts) {
	for (int i = 0; i < MAX_ACCOUNTS; i++) {
		if (accounts[i].account_number == 0) {
			continue;
		}

		printf("\nAccount Number: %d\n", accounts[i].account_number);
		printf("Account Name: %s\n", accounts[i].name);
		printf("Account Balance: %lf\n", accounts[i].balance);
		printf("------------------------------------------\n");
	}
}

_Bool ask_for_password(account *account) {
	char password[MAX_PASSWORD_LENGTH] = {0};
	printf("\nEnter your password: ");
	scanf("%15s", password);

	u32 password_blocks[4];
	encrypt(password_blocks, password, KEY);

	return is_password_correct(account->password_blocks, password_blocks);
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

	if (amount <= 0) {
		printf("The amount must be a positive, non-zero number.\n");
		return;
	}

	if (is_deposit) {
		deposit(account, amount);
	} else {
		withdraw(account, amount);
	}
}

int main(void) {
	init_platform();

	// Accounts
	account accounts[MAX_ACCOUNTS] = {0};

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
