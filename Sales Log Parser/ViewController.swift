// Sales Log Parser
// Created by Ivan B.

import Cocoa
import UniformTypeIdentifiers

class ViewController: NSViewController {
    
    // MARK: - UI Components
    private lazy var loadFileButton: NSButton = {
        let button = NSButton(title: "Load File", target: self, action: #selector(loadFileButtonClicked))
        button.bezelStyle = .rounded
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Add a loading indicator
    private lazy var loadingIndicator: NSProgressIndicator = {
        let indicator = NSProgressIndicator()
        indicator.style = .spinning
        indicator.isIndeterminate = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.isHidden = true // Hidden by default
        indicator.controlSize = .regular
        return indicator
    }()
    
    // Add a status label
    private lazy var statusLabel: NSTextField = {
        let label = NSTextField(labelWithString: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = NSFont.systemFont(ofSize: 12)
        label.textColor = NSColor.secondaryLabelColor
        label.alignment = .center
        label.isHidden = true // Hidden by default
        return label
    }()
    
    private lazy var storeIdPopUp: NSPopUpButton = {
        let popup = NSPopUpButton()
        popup.translatesAutoresizingMaskIntoConstraints = false
        popup.target = self
        popup.action = #selector(storeIdSelected)
        return popup
    }()
    
    private lazy var posIdPopUp: NSPopUpButton = {
        let popup = NSPopUpButton()
        popup.translatesAutoresizingMaskIntoConstraints = false
        popup.target = self
        popup.action = #selector(posIdSelected)
        return popup
    }()
    
    private lazy var paymentMethodPopUp: NSPopUpButton = {
        let popup = NSPopUpButton()
        popup.translatesAutoresizingMaskIntoConstraints = false
        popup.target = self
        popup.action = #selector(paymentMethodSelected)
        return popup
    }()
    
    private lazy var transactionCountLabel: NSTextField = {
        let label = NSTextField(labelWithString: "0")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = NSFont.systemFont(ofSize: 20, weight: .bold)
        label.alignment = .center
        return label
    }()
    
    private lazy var dateLabel: NSTextField = {
        let label = NSTextField(labelWithString: "No data loaded")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = NSFont.systemFont(ofSize: 14)
        return label
    }()
    
    private lazy var presetsPopUp: NSPopUpButton = {
        let popup = NSPopUpButton()
        popup.translatesAutoresizingMaskIntoConstraints = false
        popup.target = self
        popup.action = #selector(presetSelected)
        return popup
    }()
    
    private lazy var savePresetButton: NSButton = {
        let button = NSButton(title: "Save Preset", target: self, action: #selector(savePresetButtonClicked))
        button.bezelStyle = .rounded
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var storeIdLabel: NSTextField = {
        let label = NSTextField(labelWithString: "Store ID:")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var posIdLabel: NSTextField = {
        let label = NSTextField(labelWithString: "POS ID:")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var paymentMethodLabel: NSTextField = {
        let label = NSTextField(labelWithString: "Payment Method:")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var presetsLabel: NSTextField = {
        let label = NSTextField(labelWithString: "Presets:")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var transactionCountTitleLabel: NSTextField = {
        let label = NSTextField(labelWithString: "Unique Transactions:")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = NSFont.systemFont(ofSize: 14, weight: .medium)
        return label
    }()
    
    // MARK: - Properties
    private let csvParserService = CSVParserService()
    private let presetService = PresetService()
    private var csvData: CSVData?
    private var selectedFilePath: URL?
    
    // Filter selections
    private var selectedStoreId: String?
    private var selectedPosId: String?
    private var selectedPaymentMethod: String?
    
    // MARK: - Lifecycle
    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 600, height: 500))
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadPresets()
    }
    
    // Method to receive CSV data from Document
    func setCsvData(_ data: CSVData) {
        self.csvData = data
        
        // Make sure the view is loaded
        loadViewIfNeeded()
        
        // Update UI with data
        updateFilterControls()
        updateResults()
        
        // Enable filter controls
        storeIdPopUp.isEnabled = true
        posIdPopUp.isEnabled = true
        paymentMethodPopUp.isEnabled = true
        savePresetButton.isEnabled = true
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Add components to view
        view.addSubview(loadFileButton)
        view.addSubview(loadingIndicator)
        view.addSubview(statusLabel)
        view.addSubview(storeIdLabel)
        view.addSubview(storeIdPopUp)
        view.addSubview(posIdLabel)
        view.addSubview(posIdPopUp)
        view.addSubview(paymentMethodLabel)
        view.addSubview(paymentMethodPopUp)
        view.addSubview(transactionCountTitleLabel)
        view.addSubview(transactionCountLabel)
        view.addSubview(dateLabel)
        view.addSubview(presetsLabel)
        view.addSubview(presetsPopUp)
        view.addSubview(savePresetButton)
        
        // Layout with Auto Layout
        NSLayoutConstraint.activate([
            // Load File Button
            loadFileButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            loadFileButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            // Loading Indicator
            loadingIndicator.centerYAnchor.constraint(equalTo: loadFileButton.centerYAnchor),
            loadingIndicator.leadingAnchor.constraint(equalTo: loadFileButton.trailingAnchor, constant: 10),
            loadingIndicator.widthAnchor.constraint(equalToConstant: 16),
            loadingIndicator.heightAnchor.constraint(equalToConstant: 16),
            
            // Status Label
            statusLabel.topAnchor.constraint(equalTo: loadFileButton.bottomAnchor, constant: 5),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Store ID Filter
            storeIdLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 15),
            storeIdLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            storeIdLabel.widthAnchor.constraint(equalToConstant: 100),
            
            storeIdPopUp.centerYAnchor.constraint(equalTo: storeIdLabel.centerYAnchor),
            storeIdPopUp.leadingAnchor.constraint(equalTo: storeIdLabel.trailingAnchor, constant: 10),
            storeIdPopUp.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // POS ID Filter
            posIdLabel.topAnchor.constraint(equalTo: storeIdLabel.bottomAnchor, constant: 20),
            posIdLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            posIdLabel.widthAnchor.constraint(equalToConstant: 100),
            
            posIdPopUp.centerYAnchor.constraint(equalTo: posIdLabel.centerYAnchor),
            posIdPopUp.leadingAnchor.constraint(equalTo: posIdLabel.trailingAnchor, constant: 10),
            posIdPopUp.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Payment Method Filter
            paymentMethodLabel.topAnchor.constraint(equalTo: posIdLabel.bottomAnchor, constant: 20),
            paymentMethodLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            paymentMethodLabel.widthAnchor.constraint(equalToConstant: 120),
            
            paymentMethodPopUp.centerYAnchor.constraint(equalTo: paymentMethodLabel.centerYAnchor),
            paymentMethodPopUp.leadingAnchor.constraint(equalTo: paymentMethodLabel.trailingAnchor, constant: 10),
            paymentMethodPopUp.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Results Display
            transactionCountTitleLabel.topAnchor.constraint(equalTo: paymentMethodLabel.bottomAnchor, constant: 40),
            transactionCountTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            transactionCountLabel.topAnchor.constraint(equalTo: transactionCountTitleLabel.bottomAnchor, constant: 5),
            transactionCountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: transactionCountLabel.bottomAnchor, constant: 10),
            dateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Preset Controls
            presetsLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 40),
            presetsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            presetsLabel.widthAnchor.constraint(equalToConstant: 100),
            
            presetsPopUp.centerYAnchor.constraint(equalTo: presetsLabel.centerYAnchor),
            presetsPopUp.leadingAnchor.constraint(equalTo: presetsLabel.trailingAnchor, constant: 10),
            
            savePresetButton.centerYAnchor.constraint(equalTo: presetsPopUp.centerYAnchor),
            savePresetButton.leadingAnchor.constraint(equalTo: presetsPopUp.trailingAnchor, constant: 10),
            savePresetButton.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
        
        // Initialize UI components state
        storeIdPopUp.removeAllItems()
        posIdPopUp.removeAllItems()
        paymentMethodPopUp.removeAllItems()
        presetsPopUp.removeAllItems()
        
        // Add placeholder items
        storeIdPopUp.addItem(withTitle: "Select Store")
        posIdPopUp.addItem(withTitle: "Select POS")
        paymentMethodPopUp.addItem(withTitle: "Select Payment Method")
        presetsPopUp.addItem(withTitle: "Select Preset")
        
        // Disable filter controls until file is loaded
        storeIdPopUp.isEnabled = false
        posIdPopUp.isEnabled = false
        paymentMethodPopUp.isEnabled = false
        savePresetButton.isEnabled = false
        
        // Set initial values
        transactionCountLabel.stringValue = "0"
        dateLabel.stringValue = "No data loaded"
    }
    
    // Show loading state
    private func showLoading(message: String) {
        DispatchQueue.main.async {
            self.loadingIndicator.isHidden = false
            self.loadingIndicator.startAnimation(nil)
            self.statusLabel.stringValue = message
            self.statusLabel.isHidden = false
            self.loadFileButton.isEnabled = false
        }
    }
    
    // Hide loading state
    private func hideLoading() {
        DispatchQueue.main.async {
            self.loadingIndicator.isHidden = true
            self.loadingIndicator.stopAnimation(nil)
            self.loadFileButton.isEnabled = true
        }
    }
    
    // Update status message
    private func updateStatus(message: String) {
        DispatchQueue.main.async {
            self.statusLabel.stringValue = message
            self.statusLabel.isHidden = false
        }
    }
    
    // MARK: - Actions
    @objc func loadFileButtonClicked(_ sender: Any) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        
        // Use allowedContentTypes instead of deprecated allowedFileTypes
        let csvType = UTType(filenameExtension: "csv") ?? UTType.data
        let xlsxType = UTType(filenameExtension: "xlsx") ?? UTType.data
        let xlsType = UTType(filenameExtension: "xls") ?? UTType.data
        openPanel.allowedContentTypes = [csvType, xlsxType, xlsType]
        
        openPanel.beginSheetModal(for: self.view.window!) { (response) in
            if response == .OK, let url = openPanel.url {
                self.showLoading(message: "Loading file...")
                
                // Load file in background to keep UI responsive
                DispatchQueue.global(qos: .userInitiated).async {
                    self.loadFile(at: url)
                    DispatchQueue.main.async {
                        self.hideLoading()
                    }
                }
            }
        }
    }
    
    @objc func storeIdSelected(_ sender: NSPopUpButton) {
        if sender.indexOfSelectedItem > 0 {
            selectedStoreId = sender.titleOfSelectedItem
        } else {
            selectedStoreId = nil
        }
        applyFilters()
    }
    
    @objc func posIdSelected(_ sender: NSPopUpButton) {
        if sender.indexOfSelectedItem > 0 {
            selectedPosId = sender.titleOfSelectedItem
        } else {
            selectedPosId = nil
        }
        applyFilters()
    }
    
    @objc func paymentMethodSelected(_ sender: NSPopUpButton) {
        if sender.indexOfSelectedItem > 0 {
            selectedPaymentMethod = sender.titleOfSelectedItem
        } else {
            selectedPaymentMethod = nil
        }
        applyFilters()
    }
    
    @objc func presetSelected(_ sender: NSPopUpButton) {
        if sender.indexOfSelectedItem > 0 {
            let presets = presetService.loadPresets()
            let selectedIndex = sender.indexOfSelectedItem - 1
            
            if selectedIndex < presets.count {
                let preset = presets[selectedIndex]
                applyPreset(preset)
            }
        }
    }
    
    @objc func savePresetButtonClicked(_ sender: Any) {
        let alert = NSAlert()
        alert.messageText = "Save Filter Preset"
        alert.informativeText = "Enter a name for this preset:"
        
        let textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        textField.placeholderString = "Preset Name"
        alert.accessoryView = textField
        
        alert.addButton(withTitle: "Save")
        alert.addButton(withTitle: "Cancel")
        
        alert.beginSheetModal(for: self.view.window!) { (response) in
            if response == .alertFirstButtonReturn {
                let presetName = textField.stringValue.isEmpty ? "Preset \(Date())" : textField.stringValue
                self.saveCurrentPreset(name: presetName)
            }
        }
    }
    
    // MARK: - Helper Methods
    func loadFile(at url: URL) {
        print("Loading file from: \(url.path)")
        updateStatus(message: "Processing \(url.lastPathComponent)...")
        
        do {
            selectedFilePath = url
            
            // Parse file based on extension
            let fileExtension = url.pathExtension.lowercased()
            print("File extension: \(fileExtension)")
            
            if fileExtension == "csv" {
                print("Parsing as CSV file")
                updateStatus(message: "Parsing CSV data...")
                csvData = try csvParserService.parseCSVFile(at: url)
            } else if fileExtension == "xlsx" || fileExtension == "xls" {
                print("Parsing as Excel file")
                updateStatus(message: "Parsing Excel data...")
                csvData = try csvParserService.parseExcelFile(at: url)
            } else {
                print("Unsupported file format: \(fileExtension)")
                throw NSError(domain: "CSVParser", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unsupported file format"])
            }
            
            print("File parsed successfully, updating UI")
            updateStatus(message: "Updating UI with data...")
            
            // Update UI with data
            DispatchQueue.main.async {
                self.updateFilterControls()
                self.updateResults()
                
                // Enable filter controls
                self.storeIdPopUp.isEnabled = true
                self.posIdPopUp.isEnabled = true
                self.paymentMethodPopUp.isEnabled = true
                self.savePresetButton.isEnabled = true
                
                // Update status with file information
                if let csvData = self.csvData {
                    self.updateStatus(message: "Loaded \(csvData.rows.count) records from \(url.lastPathComponent)")
                } else {
                    self.updateStatus(message: "File loaded, but no valid data found")
                }
            }
            
            print("UI updated with file data")
            
        } catch {
            print("Error loading file: \(error)")
            print("Error details: \(error.localizedDescription)")
            
            DispatchQueue.main.async {
                self.updateStatus(message: "Error: \(error.localizedDescription)")
                self.showError(error.localizedDescription)
            }
        }
    }
    
    private func updateFilterControls() {
        guard let csvData = csvData else { return }
        
        // Update store ID popup
        storeIdPopUp.removeAllItems()
        storeIdPopUp.addItem(withTitle: "All Stores")
        for storeId in csvData.uniqueStoreIds {
            storeIdPopUp.addItem(withTitle: storeId)
        }
        
        // Update POS ID popup
        posIdPopUp.removeAllItems()
        posIdPopUp.addItem(withTitle: "All POS")
        for posId in csvData.uniquePosIds {
            posIdPopUp.addItem(withTitle: posId)
        }
        
        // Update payment method popup
        paymentMethodPopUp.removeAllItems()
        paymentMethodPopUp.addItem(withTitle: "All Payment Methods")
        for method in csvData.uniquePaymentMethods {
            paymentMethodPopUp.addItem(withTitle: method)
        }
        
        // Reset selections
        storeIdPopUp.selectItem(at: 0)
        posIdPopUp.selectItem(at: 0)
        paymentMethodPopUp.selectItem(at: 0)
        selectedStoreId = nil
        selectedPosId = nil
        selectedPaymentMethod = nil
    }
    
    private func applyFilters() {
        guard var csvData = csvData else { return }
        
        // Apply filters
        csvParserService.applyFilters(to: &csvData, storeId: selectedStoreId, posId: selectedPosId, paymentMethod: selectedPaymentMethod)
        self.csvData = csvData
        
        // Update results display
        updateResults()
    }
    
    private func updateResults() {
        guard let csvData = csvData else { return }
        
        // Update transaction count
        transactionCountLabel.stringValue = "\(csvData.filteredTransactionCount)"
        
        // Update date information
        if !csvData.uniqueDates.isEmpty {
            // For simplicity, we're just showing the first date
            // In a real app, you might want to show a date range or more sophisticated presentation
            dateLabel.stringValue = "Date: \(csvData.uniqueDates.first ?? "N/A")"
        } else {
            dateLabel.stringValue = "No valid dates found"
        }
    }
    
    private func loadPresets() {
        // Load presets from user defaults
        let presets = presetService.loadPresets()
        
        // Update preset popup
        presetsPopUp.removeAllItems()
        presetsPopUp.addItem(withTitle: "Select Preset")
        
        for preset in presets {
            presetsPopUp.addItem(withTitle: preset.name)
        }
    }
    
    private func saveCurrentPreset(name: String) {
        presetService.savePreset(
            name: name, 
            storeId: selectedStoreId, 
            posId: selectedPosId, 
            paymentMethod: selectedPaymentMethod
        )
        
        // Reload presets
        loadPresets()
    }
    
    private func applyPreset(_ preset: FilterPreset) {
        // Apply store ID filter
        if let storeId = preset.storeId {
            selectedStoreId = storeId
            if let index = storeIdPopUp.itemTitles.firstIndex(of: storeId) {
                storeIdPopUp.selectItem(at: index)
            }
        } else {
            selectedStoreId = nil
            storeIdPopUp.selectItem(at: 0)
        }
        
        // Apply POS ID filter
        if let posId = preset.posId {
            selectedPosId = posId
            if let index = posIdPopUp.itemTitles.firstIndex(of: posId) {
                posIdPopUp.selectItem(at: index)
            }
        } else {
            selectedPosId = nil
            posIdPopUp.selectItem(at: 0)
        }
        
        // Apply payment method filter
        if let paymentMethod = preset.paymentMethod {
            selectedPaymentMethod = paymentMethod
            if let index = paymentMethodPopUp.itemTitles.firstIndex(of: paymentMethod) {
                paymentMethodPopUp.selectItem(at: index)
            }
        } else {
            selectedPaymentMethod = nil
            paymentMethodPopUp.selectItem(at: 0)
        }
        
        // Apply filters
        applyFilters()
    }
    
    private func showError(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "Error"
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
    }
}

// MARK: - UTType Extension
extension UTType {
    static var commaSeparatedText: UTType {
        UTType(filenameExtension: "csv") ?? UTType.data
    }
    
    static var spreadsheet: UTType {
        UTType(filenameExtension: "xlsx") ?? UTType.data
    }
}

