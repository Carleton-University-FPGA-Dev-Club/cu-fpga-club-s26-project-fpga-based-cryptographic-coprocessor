// Bank.h
#ifndef BANK_H
#define BANK_H

#include "Account.h"
#include "SavingsAccount.h"
#include "CurrentAccount.h"
#include <iostream>

using namespace std;

class Bank {
private:
    struct Node {
        Account* account;
        Node* next;
    };

    Node* head;

public:
    Bank();
    void addAccount(Account* acc);
    void displayAccounts() const;
    Account* findAccount(int accNum) const;
    ~Bank();
}

;

#endif // BANK_H
