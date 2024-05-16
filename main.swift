import Foundation

// Custom Error Types
enum AccountError: Error {
    case invalidInput(message: String)
    case insufficientFunds
    case accountNotFound
    case invalidAccountNumber
}

// Transaction Log Structure
struct Transaction {
    let date: Date
    let type: String
    let amount: Double
}

class BankAccount {
    let accountNumber: String
    var accountHolderName: String
    private var balance: Double
    private var transactionHistory: [Transaction]
    
    init(accountNumber: String, accountHolderName: String, initialBalance: Double = 0.0) {
        self.accountNumber = accountNumber
        self.accountHolderName = accountHolderName
        self.balance = initialBalance
        self.transactionHistory = []
    }
    
    func deposit(amount: Double) throws {
        guard amount > 0 else {
            throw AccountError.invalidInput(message: "Deposit amount must be positive.")
        }
        
        balance += amount
        recordTransaction(type: "Deposit", amount: amount)
        print("Deposit of \(amount) successfully credited to account \(accountNumber).")
    }
    
    func withdraw(amount: Double) throws {
        guard amount > 0 else {
            throw AccountError.invalidInput(message: "Withdrawal amount must be positive.")
        }
        
        guard amount <= balance else {
            throw AccountError.insufficientFunds
        }
        
        balance -= amount
        recordTransaction(type: "Withdrawal", amount: -amount)
        print("Withdrawal of \(amount) successfully debited from account \(accountNumber).")
    }
    
    func transfer(amount: Double, toAccount recipientAccount: BankAccount) throws {
        guard amount > 0 else {
            throw AccountError.invalidInput(message: "Transfer amount must be positive.")
        }
        
        guard amount <= balance else {
            throw AccountError.insufficientFunds
        }
        
        self.balance -= amount
        recipientAccount.balance += amount
        
        self.recordTransaction(type: "Transfer to \(recipientAccount.accountNumber)", amount: -amount)
        recipientAccount.recordTransaction(type: "Transfer from \(self.accountNumber)", amount: amount)
        
        print("Transfer of \(amount) from account \(self.accountNumber) to \(recipientAccount.accountNumber) completed successfully.")
    }
    
    func checkBalance() {
        print("Account \(accountNumber) - Balance: \(balance)")
    }
    
    func recordTransaction(type: String, amount: Double) {
        let transaction = Transaction(date: Date(), type: type, amount: amount)
        transactionHistory.append(transaction)
    }
    
    func printTransactionHistory() {
        print("Transaction History for Account \(accountNumber):")
        for transaction in transactionHistory {
            let formattedDate = DateFormatter.localizedString(from: transaction.date, dateStyle: .short, timeStyle: .short)
            print("\(formattedDate) - \(transaction.type): \(transaction.amount)")
        }
    }
}

// Function to validate account number format
func isValidAccountNumber(_ accountNumber: String) -> Bool {
    // Implement your validation logic here (e.g., check length, characters)
    return true // Placeholder for now
}

func runBankApplication() {
    var accounts: [BankAccount] = []
    
    while true {
        print("\nWelcome to Advanced Bank!")
        print("1. Create Account")
        print("2. Deposit")
        print("3. Withdraw")
        print("4. Check Balance")
        print("5. View Transaction History")
        print("6. Transfer Money")
        print("7. Exit")
        print("Choose an option:")
        
        if let choice = readLine(), let option = Int(choice) {
            switch option {
            case 1:
                createAccount(&accounts)
                
            case 2, 3, 4, 5, 6:
                performTransaction(option: option, accounts: &accounts)
                
            case 7:
                print("Thank you for using Advanced Bank!")
                return
                
            default:
                print("Invalid option. Please choose a valid option.")
            }
        } else {
            print("Invalid input. Please enter a valid option.")
        }
    }
}

func createAccount(_ accounts: inout [BankAccount]) {
    do {
        print("Enter account number:")
        guard let accountNumber = readLine(), !accountNumber.isEmpty else {
            print("Invalid account number.")
            return
        }
        
        // Validate account number format (e.g., length, characters)
        if !isValidAccountNumber(accountNumber) {
            throw AccountError.invalidAccountNumber
        }
        
        print("Enter account holder name:")
        let accountHolderName = readLine() ?? ""
        
        let newAccount = BankAccount(accountNumber: accountNumber, accountHolderName: accountHolderName)
        accounts.append(newAccount)
        print("Account created successfully!")
    } catch {
        print("Failed to create account. Error: \(error)")
    }
}

func performTransaction(option: Int, accounts: inout [BankAccount]) {
    print("Enter account number:")
    guard let accountNumber = readLine(), !accountNumber.isEmpty, let account = accounts.first(where: { $0.accountNumber == accountNumber }) else {
        print("Account not found.")
        return
    }
    
    do {
        switch option {
        case 2:
            try deposit(account: account)
            
        case 3:
            try withdraw(account: account)
            
        case 4:
            account.checkBalance()
            
        case 5:
            account.printTransactionHistory()
            
        case 6:
            try transferMoney(senderAccount: account, accounts: &accounts)
            
        default:
            print("Invalid transaction option.")
        }
    } catch let error as AccountError {
        print("Transaction failed. \(error)")
    } catch {
        print("Transaction failed. Unknown error: \(error)")
    }
}

func deposit(account: BankAccount) throws {
    print("Enter deposit amount:")
    guard let amountStr = readLine(), let amount = Double(amountStr), amount > 0 else {
        throw AccountError.invalidInput(message: "Invalid deposit amount.")
    }
    try account.deposit(amount: amount)
}

func withdraw(account: BankAccount) throws {
    print("Enter withdrawal amount:")
    guard let amountStr = readLine(), let amount = Double(amountStr), amount > 0 else {
        throw AccountError.invalidInput(message: "Invalid withdrawal amount.")
    }
    try account.withdraw(amount: amount)
}

func transferMoney(senderAccount: BankAccount, accounts: inout [BankAccount]) throws {
    print("Enter recipient's account number:")
    guard let recipientAccountNumber = readLine(), let recipientAccount = accounts.first(where: { $0.accountNumber == recipientAccountNumber }) else {
        throw AccountError.accountNotFound
    }
    
    print("Enter transfer amount:")
    guard let amountStr = readLine(), let amount = Double(amountStr), amount > 0 else {
        throw AccountError.invalidInput(message: "Invalid transfer amount.")
    }
    
    try senderAccount.transfer(amount: amount, toAccount: recipientAccount)
}
runBankApplication()
