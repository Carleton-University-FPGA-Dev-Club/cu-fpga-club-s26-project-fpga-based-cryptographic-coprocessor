#include "Bank.h"
#include "SavingsAccount.h"
#include "CurrentAccount.h"
#include "Account.h"


#include <iostream>
using namespace std;

void addSavingsAccount(Bank& bank) {
    int accNum;
    string name;
    double balance, rate;

    cout << "Enter Account Number: ";
    cin >> accNum;
    if (bank.findAccount(accNum) != nullptr){
        cout << "This account already exists." <<         endl; 
        return; 
    }
    cout << "Enter Account Holder Name: ";    
    cin.ignore(); // Clear the input buffer
    getline(cin, name);
    cout << "Enter Initial Balance: ";
    cin >> balance;
    cout << "Enter Interest Rate: ";
    cin >> rate;

    SavingsAccount* newAccount = new SavingsAccount(accNum, name, balance, rate);
    bank.addAccount(newAccount);
    cout << "Savings Account added successfully!" << endl;
}

void addCurrentAccount(Bank& bank) {
    int accNum;
    string name;
    double balance, limit;

    cout << "Enter Account Number: " << endl;
    cin >> accNum;

    if (bank.findAccount(accNum) != nullptr){
        cout << "This account already exists." <<         endl; 
        return; 
    }

    cout << "Enter Account Holder Name: " << endl;
    cin.ignore(); 
    getline(cin, name);
    cout << "Enter Initial Balance: ";
    cin >> balance;
    cout << "Enter Overdraft Limit: ";
    cin >> limit;

    CurrentAccount* newAccount = new CurrentAccount(accNum, name, balance, limit);
    bank.addAccount(newAccount);
    cout << "Current Account added successfully!" << endl;
}

void displayAllAccounts(const Bank& bank) {
    bank.displayAccounts(); 
    cout << "Total Bank Balance: " << Account::totalBankBalance << endl; // Get the total balance
}

void performTransaction(Bank& bank, bool isDeposit) {
    int accNum;
    double amount;

    cout << "Enter Account Number: ";
    cin >> accNum;
    Account* account = bank.findAccount(accNum);

    if (account == nullptr) {
        cout << "Account not found." << endl;
        return;
    }

    cout << "Enter amount: ";
    cin >> amount;

    if (isDeposit) {
        account->deposit(amount);
    } else {
        account->withdraw(amount);
    }
}

int main() {
    Bank bank;

    int choice;
    do {
        cout << "\nBank Management System\n";
        cout << "1. Add Savings Account\n";
        cout << "2. Add Current Account\n";
        cout << "3. Display All Accounts\n";
        cout << "4. Deposit\n";
        cout << "5. Withdraw\n";
        cout << "6. Exit\n";
        cout << "Enter your choice: ";
        cin >> choice;

        switch (choice) {
            case 1:
                addSavingsAccount(bank);
                break;
            case 2:
                addCurrentAccount(bank);
                break;
            case 3:
                displayAllAccounts(bank);
                break;
            case 4:
                performTransaction(bank, true); // isDeposit = true
                break;
            case 5:
                performTransaction(bank, false); // isDeposit = false
                break;
            case 6:
                cout << "Exiting...\n";
                break;
            default:
                cout << "Invalid choice!\n";
        }
    } while (choice != 6);

    return 0;
}
