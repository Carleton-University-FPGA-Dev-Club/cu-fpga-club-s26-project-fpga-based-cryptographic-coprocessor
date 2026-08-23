#include "CurrentAccount.h"
#include <iostream>

CurrentAccount::CurrentAccount(int accNum, string name, double balance, double limit)
    : Account(accNum, name, balance), overdraftLimit(limit) {}

void CurrentAccount::display() const {
    cout << "Current Account: " << accountNumber << ", "
         << "Account Holder: " << accountHolderName << ", "
         << "Balance: " << balance << ", "
         << "Overdraft Limit: " << overdraftLimit << endl;
}
