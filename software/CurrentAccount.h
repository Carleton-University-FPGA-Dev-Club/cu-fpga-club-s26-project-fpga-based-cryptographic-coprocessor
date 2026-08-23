#ifndef CURRENTACCOUNT_H
#define CURRENTACCOUNT_H

#include "Account.h"

class CurrentAccount : public Account {
public:
    CurrentAccount(int accNum, string name, double balance, double limit);
    void display() const override;
private:
    double overdraftLimit;
};

#endif // CURRENTACCOUNT_H
