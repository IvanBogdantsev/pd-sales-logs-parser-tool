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
        popup.autoenablesItems = false // Allow manual control of item states
        return popup
    }()
    
    // Add a selections label for store ID
    private lazy var storeIdSelectionsLabel: NSTextField = {
        let label = NSTextField(labelWithString: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = NSFont.systemFont(ofSize: 11)
        label.textColor = NSColor.secondaryLabelColor
        label.cell?.lineBreakMode = .byTruncatingTail
        label.isEditable = false
        label.isSelectable = true
        label.isBordered = false
        label.drawsBackground = false
        return label
    }()
    
    private lazy var posIdPopUp: NSPopUpButton = {
        let popup = NSPopUpButton()
        popup.translatesAutoresizingMaskIntoConstraints = false
        popup.target = self
        popup.action = #selector(posIdSelected)
        popup.autoenablesItems = false // Allow manual control of item states
        return popup
    }()
    
    // Add a selections label for POS ID
    private lazy var posIdSelectionsLabel: NSTextField = {
        let label = NSTextField(labelWithString: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = NSFont.systemFont(ofSize: 11)
        label.textColor = NSColor.secondaryLabelColor
        label.cell?.lineBreakMode = .byTruncatingTail
        label.isEditable = false
        label.isSelectable = true
        label.isBordered = false
        label.drawsBackground = false
        return label
    }()
    
    private lazy var paymentMethodPopUp: NSPopUpButton = {
        let popup = NSPopUpButton()
        popup.translatesAutoresizingMaskIntoConstraints = false
        popup.target = self
        popup.action = #selector(paymentMethodSelected)
        popup.autoenablesItems = false // Allow manual control of item states
        return popup
    }()
    
    // Add a selections label for payment method
    private lazy var paymentMethodSelectionsLabel: NSTextField = {
        let label = NSTextField(labelWithString: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = NSFont.systemFont(ofSize: 11)
        label.textColor = NSColor.secondaryLabelColor
        label.cell?.lineBreakMode = .byTruncatingTail
        label.isEditable = false
        label.isSelectable = true
        label.isBordered = false
        label.drawsBackground = false
        return label
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
    
    private lazy var deletePresetButton: NSButton = {
        let button = NSButton(title: "Delete Preset", target: self, action: #selector(deletePresetButtonClicked))
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
    
    private lazy var copyTransactionCountButton: NSButton = {
        let button = NSButton(image: NSImage(systemSymbolName: "doc.on.doc", accessibilityDescription: "Copy")!, target: self, action: #selector(copyTransactionCount))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.bezelStyle = .inline
        button.isBordered = false
        button.toolTip = "Copy transaction count to clipboard"
        return button
    }()
    
    // Add a results table to display all preset results
    private lazy var presetsResultsLabel: NSTextField = {
        let label = NSTextField(labelWithString: "Results for All Presets:")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = NSFont.systemFont(ofSize: 14, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    // Replace the scroll view with a stack view for preset results
    private lazy var presetsResultsStackView: NSStackView = {
        let stackView = NSStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.orientation = .vertical
        stackView.spacing = 8
        stackView.alignment = .leading
        stackView.distribution = .fillProportionally
        stackView.edgeInsets = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        stackView.isHidden = true
        return stackView
    }()
    
    // MARK: - Properties
    private let csvParserService = CSVParserService()
    private let presetService = PresetService()
    private var csvData: CSVData?
    private var selectedFilePath: URL?
    
    // Filter selections
    private var selectedStoreIds: [String] = []
    private var selectedPosIds: [String] = []
    private var selectedPaymentMethods: [String] = []
    
    // MARK: - Lifecycle
    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 600, height: 700)) // Increased height to accommodate preset results
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
        deletePresetButton.isEnabled = true
        copyTransactionCountButton.isEnabled = true
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Add components to view
        view.addSubview(loadFileButton)
        view.addSubview(loadingIndicator)
        view.addSubview(statusLabel)
        view.addSubview(storeIdLabel)
        view.addSubview(storeIdPopUp)
        view.addSubview(storeIdSelectionsLabel)
        view.addSubview(posIdLabel)
        view.addSubview(posIdPopUp)
        view.addSubview(posIdSelectionsLabel)
        view.addSubview(paymentMethodLabel)
        view.addSubview(paymentMethodPopUp)
        view.addSubview(paymentMethodSelectionsLabel)
        view.addSubview(transactionCountTitleLabel)
        view.addSubview(transactionCountLabel)
        view.addSubview(copyTransactionCountButton)
        view.addSubview(dateLabel)
        view.addSubview(presetsLabel)
        view.addSubview(presetsPopUp)
        view.addSubview(savePresetButton)
        view.addSubview(deletePresetButton)
        
        // Add new components for preset results
        view.addSubview(presetsResultsLabel)
        view.addSubview(presetsResultsStackView)
        
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
            
            storeIdSelectionsLabel.topAnchor.constraint(equalTo: storeIdPopUp.bottomAnchor, constant: 2),
            storeIdSelectionsLabel.leadingAnchor.constraint(equalTo: storeIdLabel.trailingAnchor, constant: 10),
            storeIdSelectionsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // POS ID Filter
            posIdLabel.topAnchor.constraint(equalTo: storeIdSelectionsLabel.bottomAnchor, constant: 10),
            posIdLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            posIdLabel.widthAnchor.constraint(equalToConstant: 100),
            
            posIdPopUp.centerYAnchor.constraint(equalTo: posIdLabel.centerYAnchor),
            posIdPopUp.leadingAnchor.constraint(equalTo: posIdLabel.trailingAnchor, constant: 10),
            posIdPopUp.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            posIdSelectionsLabel.topAnchor.constraint(equalTo: posIdPopUp.bottomAnchor, constant: 2),
            posIdSelectionsLabel.leadingAnchor.constraint(equalTo: posIdLabel.trailingAnchor, constant: 10),
            posIdSelectionsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Payment Method Filter
            paymentMethodLabel.topAnchor.constraint(equalTo: posIdSelectionsLabel.bottomAnchor, constant: 10),
            paymentMethodLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            paymentMethodLabel.widthAnchor.constraint(equalToConstant: 120),
            
            paymentMethodPopUp.centerYAnchor.constraint(equalTo: paymentMethodLabel.centerYAnchor),
            paymentMethodPopUp.leadingAnchor.constraint(equalTo: paymentMethodLabel.trailingAnchor, constant: 10),
            paymentMethodPopUp.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            paymentMethodSelectionsLabel.topAnchor.constraint(equalTo: paymentMethodPopUp.bottomAnchor, constant: 2),
            paymentMethodSelectionsLabel.leadingAnchor.constraint(equalTo: paymentMethodLabel.trailingAnchor, constant: 10),
            paymentMethodSelectionsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Results Display
            transactionCountTitleLabel.topAnchor.constraint(equalTo: paymentMethodSelectionsLabel.bottomAnchor, constant: 30),
            transactionCountTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -15),
            
            copyTransactionCountButton.centerYAnchor.constraint(equalTo: transactionCountTitleLabel.centerYAnchor),
            copyTransactionCountButton.leadingAnchor.constraint(equalTo: transactionCountTitleLabel.trailingAnchor, constant: 5),
            copyTransactionCountButton.widthAnchor.constraint(equalToConstant: 20),
            copyTransactionCountButton.heightAnchor.constraint(equalToConstant: 20),
            
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
            
            deletePresetButton.centerYAnchor.constraint(equalTo: savePresetButton.centerYAnchor),
            deletePresetButton.leadingAnchor.constraint(equalTo: savePresetButton.trailingAnchor, constant: 10),
            deletePresetButton.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            
            // Preset Results Label
            presetsResultsLabel.topAnchor.constraint(equalTo: deletePresetButton.bottomAnchor, constant: 20),
            presetsResultsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            // Presets Results StackView
            presetsResultsStackView.topAnchor.constraint(equalTo: presetsResultsLabel.bottomAnchor, constant: 10),
            presetsResultsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            presetsResultsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            presetsResultsStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -20)
        ])
        
        // Initialize UI components state
        storeIdPopUp.removeAllItems()
        posIdPopUp.removeAllItems()
        paymentMethodPopUp.removeAllItems()
        presetsPopUp.removeAllItems()
        
        // Configure popup behaviors for multi-selection
        [storeIdPopUp, posIdPopUp, paymentMethodPopUp].forEach { popup in
            // Set to pull down menu style
            popup.pullsDown = false
            // Align menu to the item
            popup.preferredEdge = .maxY
        }
        
        // Add placeholder items
        storeIdPopUp.addItem(withTitle: "All Stores")
        posIdPopUp.addItem(withTitle: "All POS")
        paymentMethodPopUp.addItem(withTitle: "All Payment Methods")
        presetsPopUp.addItem(withTitle: "Select Preset")
        
        // Initialize checkmarks
        [storeIdPopUp, posIdPopUp, paymentMethodPopUp].forEach { popup in
            if let menu = popup.menu, let firstItem = menu.items.first {
                firstItem.state = .on
            }
        }
        
        // Disable filter controls until file is loaded
        storeIdPopUp.isEnabled = false
        posIdPopUp.isEnabled = false
        paymentMethodPopUp.isEnabled = false
        savePresetButton.isEnabled = false
        deletePresetButton.isEnabled = false
        copyTransactionCountButton.isEnabled = true
        
        // Set initial values
        transactionCountLabel.stringValue = "0"
        dateLabel.stringValue = "No data loaded"
        
        // Clear selection labels
        storeIdSelectionsLabel.stringValue = ""
        posIdSelectionsLabel.stringValue = ""
        paymentMethodSelectionsLabel.stringValue = ""
        
        // Disable new result components
        presetsResultsLabel.isHidden = true
        presetsResultsStackView.isHidden = true
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
            if let selectedTitle = sender.titleOfSelectedItem {
                // Toggle the selection - add if not present, remove if already selected
                if selectedStoreIds.contains(selectedTitle) {
                    selectedStoreIds.removeAll { $0 == selectedTitle }
                } else {
                    selectedStoreIds.append(selectedTitle)
                }
                // Update checkmarks on menu items
                updateMenuCheckmarks(for: sender, selectedItems: selectedStoreIds)
                // Update selections label
                updateSelectionsLabel(for: .storeId, selectedItems: selectedStoreIds)
            }
        } else {
            // "All Stores" selected, clear the filter
            selectedStoreIds.removeAll()
            updateMenuCheckmarks(for: sender, selectedItems: [])
            updateSelectionsLabel(for: .storeId, selectedItems: [])
        }
        applyFilters()
    }
    
    @objc func posIdSelected(_ sender: NSPopUpButton) {
        if sender.indexOfSelectedItem > 0 {
            if let selectedTitle = sender.titleOfSelectedItem {
                // Toggle the selection - add if not present, remove if already selected
                if selectedPosIds.contains(selectedTitle) {
                    selectedPosIds.removeAll { $0 == selectedTitle }
                } else {
                    selectedPosIds.append(selectedTitle)
                }
                // Update checkmarks on menu items
                updateMenuCheckmarks(for: sender, selectedItems: selectedPosIds)
                // Update selections label
                updateSelectionsLabel(for: .posId, selectedItems: selectedPosIds)
            }
        } else {
            // "All POS" selected, clear the filter
            selectedPosIds.removeAll()
            updateMenuCheckmarks(for: sender, selectedItems: [])
            updateSelectionsLabel(for: .posId, selectedItems: [])
        }
        applyFilters()
    }
    
    @objc func paymentMethodSelected(_ sender: NSPopUpButton) {
        if sender.indexOfSelectedItem > 0 {
            if let selectedTitle = sender.titleOfSelectedItem {
                // Toggle the selection - add if not present, remove if already selected
                if selectedPaymentMethods.contains(selectedTitle) {
                    selectedPaymentMethods.removeAll { $0 == selectedTitle }
                } else {
                    selectedPaymentMethods.append(selectedTitle)
                }
                // Update checkmarks on menu items
                updateMenuCheckmarks(for: sender, selectedItems: selectedPaymentMethods)
                // Update selections label
                updateSelectionsLabel(for: .paymentMethod, selectedItems: selectedPaymentMethods)
            }
        } else {
            // "All Payment Methods" selected, clear the filter
            selectedPaymentMethods.removeAll()
            updateMenuCheckmarks(for: sender, selectedItems: [])
            updateSelectionsLabel(for: .paymentMethod, selectedItems: [])
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
        
        // Update all preset results when a preset is selected
        processAllPresets()
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
    
    @objc func deletePresetButtonClicked(_ sender: Any) {
        // Get the selected preset
        if presetsPopUp.indexOfSelectedItem <= 0 {
            // "Select Preset" is selected, nothing to delete
            let alert = NSAlert()
            alert.messageText = "No Preset Selected"
            alert.informativeText = "Please select a preset to delete."
            alert.addButton(withTitle: "OK")
            alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
            return
        }
        
        // Get the preset name
        let presetName = presetsPopUp.titleOfSelectedItem ?? ""
        
        // Confirm deletion
        let alert = NSAlert()
        alert.messageText = "Delete Preset"
        alert.informativeText = "Are you sure you want to delete the preset '\(presetName)'?"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Delete")
        alert.addButton(withTitle: "Cancel")
        
        alert.beginSheetModal(for: self.view.window!) { (response) in
            if response == .alertFirstButtonReturn {
                // Delete the preset
                let presets = self.presetService.loadPresets()
                if self.presetsPopUp.indexOfSelectedItem > 0 && self.presetsPopUp.indexOfSelectedItem <= presets.count {
                    let presetToDelete = presets[self.presetsPopUp.indexOfSelectedItem - 1] // -1 because of "Select Preset" item
                    
                    // Delete from service
                    self.presetService.deletePreset(withId: presetToDelete.id)
                    
                    // Reload presets
                    self.loadPresets()
                    
                    // Select "Select Preset" item
                    self.presetsPopUp.selectItem(at: 0)
                    
                    // Update all preset results
                    self.processAllPresets()
                }
            }
        }
    }
    
    @objc func copyTransactionCount(_ sender: Any) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(transactionCountLabel.stringValue, forType: .string)
        
        // Show feedback that the count was copied
        let originalFont = transactionCountLabel.font
        let originalColor = transactionCountLabel.textColor
        
        // Briefly change the appearance to indicate success
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.3
            transactionCountLabel.animator().textColor = NSColor.systemGreen
        }, completionHandler: {
            // Revert back to the original appearance
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.3
                self.transactionCountLabel.animator().textColor = originalColor
            })
        })
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
                
                // Process all presets and show results
                self.processAllPresets()
                
                // Enable filter controls
                self.storeIdPopUp.isEnabled = true
                self.posIdPopUp.isEnabled = true
                self.paymentMethodPopUp.isEnabled = true
                self.savePresetButton.isEnabled = true
                self.deletePresetButton.isEnabled = true
                self.copyTransactionCountButton.isEnabled = true
                
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
        
        // Clear selection arrays
        selectedStoreIds.removeAll()
        selectedPosIds.removeAll()
        selectedPaymentMethods.removeAll()
        
        // Reset checkmarks
        updateMenuCheckmarks(for: storeIdPopUp, selectedItems: [])
        updateMenuCheckmarks(for: posIdPopUp, selectedItems: [])
        updateMenuCheckmarks(for: paymentMethodPopUp, selectedItems: [])
        
        // Reset selection labels
        updateSelectionsLabel(for: .storeId, selectedItems: [])
        updateSelectionsLabel(for: .posId, selectedItems: [])
        updateSelectionsLabel(for: .paymentMethod, selectedItems: [])
    }
    
    private func applyFilters() {
        guard var csvData = csvData else { return }
        
        // Apply filters
        csvParserService.applyFilters(to: &csvData, storeIds: selectedStoreIds, posIds: selectedPosIds, paymentMethods: selectedPaymentMethods)
        self.csvData = csvData
        
        // Update results display
        updateResults()
    }
    
    private func updateResults() {
        guard let csvData = csvData else { return }
        
        // Update transaction count
        transactionCountLabel.stringValue = "\(csvData.filteredTransactionCount)"
        
        // Update date information
        if let mostCommonDate = csvData.mostCommonDate, csvData.mostCommonDateCount > 0 {
            // Show the most common date and its frequency
            dateLabel.stringValue = "Most common date: \(mostCommonDate) (\(csvData.mostCommonDateCount) occurrences)"
        } else if !csvData.uniqueDates.isEmpty {
            // Fallback to first date if most common date not available
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
            storeIds: selectedStoreIds.isEmpty ? nil : selectedStoreIds, 
            posIds: selectedPosIds.isEmpty ? nil : selectedPosIds, 
            paymentMethods: selectedPaymentMethods.isEmpty ? nil : selectedPaymentMethods
        )
        
        // Reload presets
        loadPresets()
        
        // Update all preset results
        processAllPresets()
    }
    
    private func applyPreset(_ preset: FilterPreset) {
        // Apply store ID filter
        if let storeIds = preset.storeIds {
            selectedStoreIds = storeIds
            updateMenuCheckmarks(for: storeIdPopUp, selectedItems: storeIds)
            updateSelectionsLabel(for: .storeId, selectedItems: storeIds)
            
            // Select the first item in the dropdown for display
            storeIdPopUp.selectItem(at: 0) // Always show "All Stores" as default
        } else {
            selectedStoreIds.removeAll()
            updateMenuCheckmarks(for: storeIdPopUp, selectedItems: [])
            updateSelectionsLabel(for: .storeId, selectedItems: [])
            storeIdPopUp.selectItem(at: 0)
        }
        
        // Apply POS ID filter
        if let posIds = preset.posIds {
            selectedPosIds = posIds
            updateMenuCheckmarks(for: posIdPopUp, selectedItems: posIds)
            updateSelectionsLabel(for: .posId, selectedItems: posIds)
            
            // Select the first item in the dropdown for display
            posIdPopUp.selectItem(at: 0) // Always show "All POS" as default
        } else {
            selectedPosIds.removeAll()
            updateMenuCheckmarks(for: posIdPopUp, selectedItems: [])
            updateSelectionsLabel(for: .posId, selectedItems: [])
            posIdPopUp.selectItem(at: 0)
        }
        
        // Apply payment method filter
        if let paymentMethods = preset.paymentMethods {
            selectedPaymentMethods = paymentMethods
            updateMenuCheckmarks(for: paymentMethodPopUp, selectedItems: paymentMethods)
            updateSelectionsLabel(for: .paymentMethod, selectedItems: paymentMethods)
            
            // Select the first item in the dropdown for display
            paymentMethodPopUp.selectItem(at: 0) // Always show "All Payment Methods" as default
        } else {
            selectedPaymentMethods.removeAll()
            updateMenuCheckmarks(for: paymentMethodPopUp, selectedItems: [])
            updateSelectionsLabel(for: .paymentMethod, selectedItems: [])
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
    
    // Helper method to update menu item checkmarks based on selection
    private func updateMenuCheckmarks(for popup: NSPopUpButton, selectedItems: [String]) {
        guard let menu = popup.menu else { return }
        
        // Clear all checkmarks first
        for item in menu.items {
            item.state = .off
        }
        
        // Set checkmarks for selected items
        for item in menu.items {
            if selectedItems.contains(item.title) {
                item.state = .on
            }
        }
        
        // Also set checkmark for "All" item if nothing is selected
        if selectedItems.isEmpty {
            menu.items.first?.state = .on
        }
        
        // Update popup appearance to indicate active filters
        if !selectedItems.isEmpty {
            popup.contentTintColor = NSColor.systemBlue
        } else {
            popup.contentTintColor = nil
        }
    }
    
    // Define filter types for the selections label
    private enum FilterType {
        case storeId
        case posId
        case paymentMethod
    }
    
    // Helper method to update the selections label for a filter
    private func updateSelectionsLabel(for filterType: FilterType, selectedItems: [String]) {
        let label: NSTextField
        let defaultText: String
        
        switch filterType {
        case .storeId:
            label = storeIdSelectionsLabel
            defaultText = "All Stores"
        case .posId:
            label = posIdSelectionsLabel
            defaultText = "All POS"
        case .paymentMethod:
            label = paymentMethodSelectionsLabel
            defaultText = "All Payment Methods"
        }
        
        if selectedItems.isEmpty {
            // Nothing selected, clear the label
            label.stringValue = ""
            label.isHidden = true
        } else {
            // Format the selections for display
            let selectionText = selectedItems.joined(separator: ", ")
            label.stringValue = "Selected: \(selectionText)"
            label.isHidden = false
            
            // Apply color to indicate active filters
            label.textColor = NSColor.systemBlue
        }
    }
    
    // Helper method to update the popup button title - This is now simplified since we're using labels
    private func updatePopupTitle(for popup: NSPopUpButton, selectedItems: [String]) {
        if selectedItems.isEmpty {
            // Reset to default title
            if popup == storeIdPopUp {
                popup.setTitle("All Stores")
            } else if popup == posIdPopUp {
                popup.setTitle("All POS")
            } else if popup == paymentMethodPopUp {
                popup.setTitle("All Payment Methods")
            }
        } else {
            // Keep the popup showing the default title regardless of selection
            // This simplifies the UI since we display selections in the separate label
            if popup == storeIdPopUp {
                popup.setTitle("All Stores")
            } else if popup == posIdPopUp {
                popup.setTitle("All POS")
            } else if popup == paymentMethodPopUp {
                popup.setTitle("All Payment Methods")
            }
        }
    }
    
    // Replace processAllPresets method to use the stack view
    private func processAllPresets() {
        guard csvData != nil else { return }
        
        let presets = presetService.loadPresets()
        if presets.isEmpty {
            // No presets to process
            presetsResultsLabel.isHidden = true
            presetsResultsStackView.isHidden = true
            return
        }
        
        // Clear existing results
        presetsResultsStackView.subviews.forEach { $0.removeFromSuperview() }
        
        // Process each preset and create result views
        for preset in presets {
            // Create a temporary copy of the data for filtering
            guard var tempCsvData = self.csvData else { continue }
            
            // Apply preset filters
            csvParserService.applyFilters(to: &tempCsvData, 
                                        storeIds: preset.storeIds, 
                                        posIds: preset.posIds, 
                                        paymentMethods: preset.paymentMethods)
            
            // Format the result
            let transactionCount = tempCsvData.filteredTransactionCount
            
            // Create a container view for the row to establish constraints properly
            let containerView = NSView()
            containerView.translatesAutoresizingMaskIntoConstraints = false
            
            // Create a result row for this preset
            let rowStackView = NSStackView()
            rowStackView.translatesAutoresizingMaskIntoConstraints = false
            rowStackView.orientation = .horizontal
            rowStackView.spacing = 8
            rowStackView.alignment = .centerY
            containerView.addSubview(rowStackView)
            
            // Preset name
            let nameLabel = NSTextField(labelWithString: "\(preset.name):")
            nameLabel.translatesAutoresizingMaskIntoConstraints = false
            nameLabel.font = NSFont.systemFont(ofSize: 13, weight: .medium)
            
            // Transaction count
            let countLabel = NSTextField(labelWithString: "\(transactionCount) unique transactions")
            countLabel.translatesAutoresizingMaskIntoConstraints = false
            countLabel.font = NSFont.systemFont(ofSize: 13)
            
            // Copy button
            let copyButton = NSButton(image: NSImage(systemSymbolName: "doc.on.doc", accessibilityDescription: "Copy")!, target: self, action: #selector(copyPresetResult(_:)))
            copyButton.translatesAutoresizingMaskIntoConstraints = false
            copyButton.bezelStyle = .inline
            copyButton.isBordered = false
            copyButton.toolTip = "Copy result to clipboard"
            
            // Add components to row
            rowStackView.addArrangedSubview(nameLabel)
            rowStackView.addArrangedSubview(countLabel)
            rowStackView.addArrangedSubview(copyButton)
            
            // Set up constraints for row inside container
            NSLayoutConstraint.activate([
                rowStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                rowStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                rowStackView.topAnchor.constraint(equalTo: containerView.topAnchor),
                rowStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
                
                nameLabel.widthAnchor.constraint(equalToConstant: 150),
                copyButton.widthAnchor.constraint(equalToConstant: 24)
            ])
            
            // Add container to main stack view
            presetsResultsStackView.addArrangedSubview(containerView)
            
            // Make container fill width of parent stack view
            containerView.widthAnchor.constraint(equalTo: presetsResultsStackView.widthAnchor).isActive = true
        }
        
        // Show the results components
        presetsResultsLabel.isHidden = false
        presetsResultsStackView.isHidden = false
    }
    
    // Replace the copyAllResults method with individual copy methods
    // We'll create a specific method for each preset result button
    @objc func copyPresetResult(_ sender: NSButton) {
        // Find the parent stack view (the row)
        guard let stackView = sender.superview as? NSStackView else { return }
        
        // Extract the row stack view - might be nested in our container implementation
        let rowStackView: NSStackView
        if stackView.arrangedSubviews.count >= 3 {
            // Direct case - sender is in the row
            rowStackView = stackView
        } else if let containerView = sender.superview?.superview,
                  let parentStackView = containerView.subviews.first as? NSStackView {
            // Container case - sender is in a view inside the container
            rowStackView = parentStackView
        } else {
            return
        }
        
        // Get the count label from the row (position 1)
        guard let countLabel = rowStackView.arrangedSubviews[1] as? NSTextField else { return }
        
        // Extract just the transaction number from the string
        // Format is: "X unique transactions"
        let countText = countLabel.stringValue
        let components = countText.components(separatedBy: " ")
        if let transactionNumber = components.first {
            // Copy just the number to clipboard
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(transactionNumber, forType: .string)
            
            // Show feedback that results were copied
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.3
                sender.contentTintColor = NSColor.systemGreen
            }, completionHandler: {
                // Revert back to the original appearance
                NSAnimationContext.runAnimationGroup({ context in
                    context.duration = 0.3
                    self.view.window?.makeFirstResponder(nil) // Remove focus
                    sender.contentTintColor = nil
                })
            })
        }
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

