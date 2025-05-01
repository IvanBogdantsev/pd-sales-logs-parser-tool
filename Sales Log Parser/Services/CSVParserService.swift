import Foundation
import Cocoa
import UniformTypeIdentifiers

class CSVParserService {
    
    // Parse CSV file
    func parseCSVFile(at url: URL) throws -> CSVData {
        print("Attempting to parse CSV file at: \(url.path)")
        do {
            // Try different encodings if the default fails
            let encodingsToTry: [String.Encoding] = [.utf8, .windowsCP1252, .isoLatin1, .ascii]
            var fileContents: String?
            var encodingError: Error?
            
            for encoding in encodingsToTry {
                do {
                    fileContents = try String(contentsOf: url, encoding: encoding)
                    print("Successfully read file with encoding: \(encoding)")
                    break
                } catch {
                    encodingError = error
                    print("Failed to read with encoding \(encoding): \(error.localizedDescription)")
                }
            }
            
            if let fileContents = fileContents {
                print("Successfully read file with length: \(fileContents.count) characters")
                return parseCSVString(fileContents)
            } else {
                throw encodingError ?? NSError(domain: "CSVParserService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to read file with any supported encoding"])
            }
        } catch {
            print("Error reading CSV file: \(error.localizedDescription)")
            throw error
        }
    }
    
    // Clean and normalize CSV data 
    private func normalizeCSVData(_ rows: [[String]]) -> [[String]] {
        guard !rows.isEmpty else { return [] }
        
        // Get the maximum number of columns in any row
        let maxColumns = rows.map { $0.count }.max() ?? 0
        
        // Normalize all rows to have the same number of columns
        return rows.map { row -> [String] in
            if row.count < maxColumns {
                // Pad with empty strings if necessary
                var paddedRow = row
                paddedRow.append(contentsOf: Array(repeating: "", count: maxColumns - row.count))
                return paddedRow
            } else {
                return row
            }
        }
    }
    
    // Parse CSV content from string
    func parseCSVString(_ content: String) -> CSVData {
        var csvData = CSVData()
        
        // Try to detect delimiter - comma, semicolon, or tab
        let possibleDelimiters = [",", ";", "\t"]
        var bestDelimiter = ","
        var maxColumns = 0
        
        for delimiter in possibleDelimiters {
            let sampleRows = content.components(separatedBy: .newlines).prefix(5)
            let columnsPerRow = sampleRows.map { $0.components(separatedBy: delimiter).count }
            let avgColumns = columnsPerRow.reduce(0, +) / max(columnsPerRow.count, 1)
            
            if avgColumns > maxColumns {
                maxColumns = avgColumns
                bestDelimiter = delimiter
            }
        }
        
        print("Detected delimiter: '\(bestDelimiter)' with average \(maxColumns) columns")
        
        // Split content into rows and then into columns
        var rows = content.components(separatedBy: .newlines)
            .map { $0.components(separatedBy: bestDelimiter) }
            .filter { !$0.isEmpty && $0.count > 1 }
        
        // Clean and normalize CSV data
        rows = normalizeCSVData(rows)
        
        print("Parsed \(rows.count) rows from CSV content")
        
        if rows.isEmpty {
            print("Warning: No valid rows found in CSV content")
            return csvData
        }
        
        // First row is headers - trim whitespace for consistency
        csvData.headers = rows[0].map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        print("Headers: \(csvData.headers)")
        
        // Rest are data rows - trim whitespace from all values
        csvData.rows = Array(rows.dropFirst()).map { row in
            row.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        }
        print("Loaded \(csvData.rows.count) data rows")
        
        // Add debug information about expected column names
        let expectedColumns = ["Código da Loja", "Id do POS", "Desc Meio Pag", "Dia Formatado", "Número da Transacção"]
        for column in expectedColumns {
            if csvData.headers.contains(column) {
                print("Found expected column: \(column)")
            } else {
                print("WARNING: Expected column not found: \(column)")
                // Try to find a similar column to suggest
                let similarColumns = csvData.headers.filter { $0.lowercased().contains(column.lowercased().dropLast(3)) }
                if !similarColumns.isEmpty {
                    print("Possible matches: \(similarColumns)")
                }
            }
        }
        
        // Extract unique values for filters
        extractUniqueValues(for: &csvData)
        
        return csvData
    }
    
    // Parse Excel file (.xlsx, .xls) - placeholder for now
    // In a real implementation, you'd use a third-party library or other method
    func parseExcelFile(at url: URL) throws -> CSVData {
        // This is a placeholder for Excel parsing
        // You would need a library like CoreXLSX or similar
        throw NSError(
            domain: "CSVParserService", 
            code: 1, 
            userInfo: [
                NSLocalizedDescriptionKey: "Excel parsing not implemented yet", 
                NSLocalizedRecoverySuggestionErrorKey: "Please convert the file to CSV format or use a CSV file instead."
            ]
        )
    }
    
    // Extract unique values for filters
    private func extractUniqueValues(for csvData: inout CSVData) {
        print("Extracting unique values for filters")
        
        // Get column indices using the flexible matching
        let storeIdIndex = csvData.storeIdColumnIndex()
        let posIdIndex = csvData.posIdColumnIndex()
        let paymentMethodIndex = csvData.paymentMethodColumnIndex()
        let dateIndex = csvData.dateColumnIndex()
        
        print("Column indices - Store: \(String(describing: storeIdIndex)), POS: \(String(describing: posIdIndex)), Payment: \(String(describing: paymentMethodIndex)), Date: \(String(describing: dateIndex))")
        
        // Extract unique values
        if let storeIdIndex = storeIdIndex {
            csvData.uniqueStoreIds = Array(Set(csvData.rows.compactMap { 
                row in storeIdIndex < row.count ? row[storeIdIndex] : nil 
            })).sorted()
            print("Found \(csvData.uniqueStoreIds.count) unique store IDs")
        } else {
            print("Warning: Could not find store ID column")
        }
        
        if let posIdIndex = posIdIndex {
            csvData.uniquePosIds = Array(Set(csvData.rows.compactMap { 
                row in posIdIndex < row.count ? row[posIdIndex] : nil 
            })).sorted()
            print("Found \(csvData.uniquePosIds.count) unique POS IDs")
        } else {
            print("Warning: Could not find POS ID column")
        }
        
        if let paymentMethodIndex = paymentMethodIndex {
            csvData.uniquePaymentMethods = Array(Set(csvData.rows.compactMap { 
                row in paymentMethodIndex < row.count ? row[paymentMethodIndex] : nil 
            })).sorted()
            print("Found \(csvData.uniquePaymentMethods.count) unique payment methods")
        } else {
            print("Warning: Could not find payment method column")
        }
        
        if let dateIndex = dateIndex {
            // Create array of all valid dates to count occurrences
            let allValidDates = csvData.rows.compactMap { row -> String? in
                guard dateIndex < row.count else { return nil }
                
                let dateString = row[dateIndex]
                // Simple validation - ensure it's not empty and has a certain format
                guard !dateString.isEmpty, dateString.count >= 8 else { return nil }
                return dateString
            }
            
            // Count occurrences of each date
            var dateCounts: [String: Int] = [:]
            for date in allValidDates {
                dateCounts[date, default: 0] += 1
            }
            
            // Find the most common date
            if let (mostCommonDate, count) = dateCounts.max(by: { $0.value < $1.value }) {
                csvData.mostCommonDate = mostCommonDate
                csvData.mostCommonDateCount = count
                print("Most common date: \(mostCommonDate) appears \(count) times")
            }
            
            // Filter out irrelevant date values and keep only valid ones for uniqueDates
            csvData.uniqueDates = Array(Set(allValidDates)).sorted()
            print("Found \(csvData.uniqueDates.count) unique dates")
        } else {
            print("Warning: Could not find date column")
        }
    }
    
    // Apply filters to data
    func applyFilters(to csvData: inout CSVData, storeIds: [String]?, posIds: [String]?, paymentMethods: [String]?) {
        print("Applying filters - Stores: \(String(describing: storeIds)), POS: \(String(describing: posIds)), Payments: \(String(describing: paymentMethods))")
        
        // Get column indices using flexible matching
        let storeIdIndex = csvData.storeIdColumnIndex()
        let posIdIndex = csvData.posIdColumnIndex()
        let paymentMethodIndex = csvData.paymentMethodColumnIndex()
        let transactionColIndex = csvData.transactionNumberColumnIndex()
        
        // Filter rows based on criteria
        var filteredRows = csvData.rows
        
        if let storeIds = storeIds, !storeIds.isEmpty, let index = storeIdIndex {
            filteredRows = filteredRows.filter { row in
                index < row.count && storeIds.contains(row[index])
            }
            print("Filtered to \(filteredRows.count) rows after applying store filter")
        }
        
        if let posIds = posIds, !posIds.isEmpty, let index = posIdIndex {
            filteredRows = filteredRows.filter { row in
                index < row.count && posIds.contains(row[index])
            }
            print("Filtered to \(filteredRows.count) rows after applying POS filter")
        }
        
        if let paymentMethods = paymentMethods, !paymentMethods.isEmpty, let index = paymentMethodIndex {
            filteredRows = filteredRows.filter { row in
                index < row.count && paymentMethods.contains(row[index])
            }
            print("Filtered to \(filteredRows.count) rows after applying payment method filter")
        }
        
        // Count unique transactions
        if let transactionColIndex = transactionColIndex {
            let uniqueTransactions = Set(filteredRows.compactMap { row in
                transactionColIndex < row.count ? row[transactionColIndex] : nil
            })
            
            print(uniqueTransactions)
            
            csvData.filteredTransactionCount = uniqueTransactions.count
            print("Found \(csvData.filteredTransactionCount) unique transactions")
            
        } else {
            csvData.filteredTransactionCount = 0
            print("Warning: Could not find transaction number column")
        }
    }
} 
