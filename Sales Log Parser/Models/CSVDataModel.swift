import Foundation

// Model for CSV/Excel data
struct CSVData {
    // Headers and rows from the file
    var headers: [String] = []
    var rows: [[String]] = []
    
    // Unique values for filter fields
    var uniqueStoreIds: [String] = []
    var uniquePosIds: [String] = []
    var uniquePaymentMethods: [String] = []
    var uniqueDates: [String] = []
    
    // Filtered transaction count
    var filteredTransactionCount: Int = 0
    
    // Column name variants for flexibility
    private let storeIdVariants = ["Código da Loja", "Codigo da Loja", "Store ID", "Store Code", "StoreID", "StoreCode"]
    private let posIdVariants = ["Id do POS", "POS ID", "POSID", "Terminal ID", "Terminal"]
    private let paymentMethodVariants = ["Desc Meio Pag", "Payment Method", "Payment Type", "Method", "Meio Pagamento"]
    private let dateVariants = ["Dia Formatado", "Date", "Transaction Date", "Data", "Data Transação"]
    private let transactionNumberVariants = ["Número da Transacção", "Numero da Transaccao", "Transaction ID", "Transaction Number", "ID"]
    
    // Find the best matching column for a specific concept
    func findColumnIndex(for variants: [String]) -> Int? {
        // First try exact matches
        for variant in variants {
            if let index = headers.firstIndex(of: variant) {
                return index
            }
        }
        
        // If no exact match, try case-insensitive matches
        for variant in variants {
            if let index = headers.firstIndex(where: { $0.lowercased() == variant.lowercased() }) {
                return index
            }
        }
        
        // If still no match, try partial matches
        for variant in variants {
            if let index = headers.firstIndex(where: { $0.lowercased().contains(variant.lowercased()) }) {
                return index
            }
        }
        
        return nil
    }
    
    // Get store ID column index
    func storeIdColumnIndex() -> Int? {
        return findColumnIndex(for: storeIdVariants)
    }
    
    // Get POS ID column index
    func posIdColumnIndex() -> Int? {
        return findColumnIndex(for: posIdVariants)
    }
    
    // Get payment method column index
    func paymentMethodColumnIndex() -> Int? {
        return findColumnIndex(for: paymentMethodVariants)
    }
    
    // Get date column index
    func dateColumnIndex() -> Int? {
        return findColumnIndex(for: dateVariants)
    }
    
    // Get transaction number column index
    func transactionNumberColumnIndex() -> Int? {
        return findColumnIndex(for: transactionNumberVariants)
    }
    
    // Get all unique values for a specific column
    func uniqueValues(for columnName: String) -> [String] {
        guard let index = headers.firstIndex(of: columnName) else { return [] }
        
        return Array(Set(rows.compactMap { row in
            index < row.count ? row[index] : nil
        })).sorted()
    }
    
    // Filter data based on selected criteria
    mutating func applyFilters(storeId: String?, posId: String?, paymentMethod: String?) {
        // Implementation will filter rows and update filteredTransactionCount
        // Will be implemented in the CSV service
    }
    
    // Count unique transactions after applying filters
    func countUniqueTransactions(filteredRows: [[String]]) -> Int {
        guard let transactionColIndex = transactionNumberColumnIndex() else { return 0 }
        
        let uniqueTransactions = Set(filteredRows.compactMap { row in
            transactionColIndex < row.count ? row[transactionColIndex] : nil
        })
        
        return uniqueTransactions.count
    }
}

// Filter preset model
struct FilterPreset: Codable, Identifiable {
    var id = UUID()
    var name: String
    var storeId: String?
    var posId: String?
    var paymentMethod: String?
} 