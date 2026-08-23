#include "SavingsAccount.h"
#include <iostream>

SavingsAccount::SavingsAccount(int accNum, string name, double balance, double rate)
    : Account(accNum, name, balance), interestRate(rate) {}

void SavingsAccount::display() const {
    cout << "Savings Account: " << accountNumber << ", "
         << "Account Holder: " << accountHolderName << ", "
         << "Balance: " << balance << ", "
         << "Interest Rate: " << interestRate << endl;
}
