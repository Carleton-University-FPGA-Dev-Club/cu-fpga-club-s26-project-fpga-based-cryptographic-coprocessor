# Compiler and flags
CXX = g++
CXXFLAGS = -Wall -std=c++11

# List of object files
OBJS = Account.o Bank.o CurrentAccount.o SavingsAccount.o main.o

# Target executable
TARGET = main

# Default rule: Build the target executable
$(TARGET): $(OBJS)
	$(CXX) $(CXXFLAGS) $(OBJS) -o $(TARGET)

# Rule for building Account.o
Account.o: Account.cc Account.h
	$(CXX) $(CXXFLAGS) -c Account.cc

# Rule for building Bank.o
Bank.o: Bank.cc Bank.h
	$(CXX) $(CXXFLAGS) -c Bank.cc

# Rule for building CurrentAccount.o
CurrentAccount.o: CurrentAccount.cc CurrentAccount.h
	$(CXX) $(CXXFLAGS) -c CurrentAccount.cc

# Rule for building SavingsAccount.o
SavingsAccount.o: SavingsAccount.cc SavingsAccount.h
	$(CXX) $(CXXFLAGS) -c SavingsAccount.cc

# Rule for building main.o
main.o: main.cc Bank.h Account.h SavingsAccount.h CurrentAccount.h
	$(CXX) $(CXXFLAGS) -c main.cc

# Clean rule: Remove all object files and the executable
clean:
	rm -f *.o $(TARGET)

# Phony target for clean to avoid conflicts with file names
.PHONY: clean
