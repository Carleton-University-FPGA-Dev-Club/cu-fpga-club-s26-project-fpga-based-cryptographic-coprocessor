#ifndef ACCOUNT_H
#define ACCOUNT_H
#include <iostream>
#include <string>

using namespace std;

class Account {
public:
    int accountNumber;
    string accountHolderName;
    double balance;
    Account(int accNum, string name, double bal);

    virtual void display() const; 
    virtual void deposit(double amount);
    virtual void withdraw(double amount);
    int getAccountNumber() const { return accountNumber; }
    string getAccountHolderName() const { return accountHolderName; }
    double getBalance() const; 
    static double totalBankBalance; // Static member for total bank balance
};

#endif // ACCOUNT_H
