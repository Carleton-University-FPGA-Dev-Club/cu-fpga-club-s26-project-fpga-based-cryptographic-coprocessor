#ifndef SAVINGSACCOUNT_H
#define SAVINGSACCOUNT_H

#include "Account.h"

class SavingsAccount : public Account {
public:
    SavingsAccount(int accNum, string name, double balance, double rate);
    void display() const override;
private:
    double interestRate;
};

#endif // SAVINGSACCOUNT_H
