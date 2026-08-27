#include "Account.h"

// Define the static member variable outside the class
double Account::totalBankBalance = 0.0;

Account::Account(int accNum, string name, double bal)
    : accountNumber(accNum), accountHolderName(name), balance(bal) {
    totalBankBalance += balance; // Update total bank balance when an account is created
}

void Account::display() const {
    cout << "Account Number: " << accountNumber << endl;
    cout << "Account Holder: " << accountHolderName << endl;
    cout << "Balance: " << balance << endl;
}

void Account::deposit(double amount) {
    balance += amount;
    totalBankBalance += amount; // Update total bank balance on deposit
    cout << "Deposited: " << amount << endl;
    cout << "New Balance: " << balance << endl;
}

void Account::withdraw(double amount) {
    if (amount <= balance) {
        balance -= amount;
        totalBankBalance -= amount; // Update total bank balance on withdrawal
        cout << "Withdrawn: " << amount << endl;
        cout << "New Balance: " << balance << endl;
    } else {
        cout << "Insufficient balance" << endl;
    }
}

double Account::getBalance() const {
    return balance;
}
