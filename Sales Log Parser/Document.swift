// Sales Log Parser
// Created by Ivan B.

import Cocoa

class Document: NSDocument {
    var csvData: CSVData?
    private let csvParserService = CSVParserService()

    override init() {
        super.init()
    }

    override class var autosavesInPlace: Bool {
        return true
    }

    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! NSWindowController
        
        // Get the view controller and pass any loaded data if available
        if let viewController = windowController.contentViewController as? ViewController, let csvData = csvData {
            viewController.setCsvData(csvData)
        }
        
        self.addWindowController(windowController)
    }

    override func data(ofType typeName: String) throws -> Data {
        // In this app, we don't need to save the document data directly
        // since we're primarily focused on analysis. But we could implement
        // saving of presets or analysis results if needed.
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }

    override func read(from data: Data, ofType typeName: String) throws {
        // Handle loading data from file
        // Note: This will be called when opening a document directly
        guard let fileContent = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "Document", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to read data as UTF-8 text"])
        }
        
        // Parse CSV string
        csvData = csvParserService.parseCSVString(fileContent)
    }
    
    // Handle file types
    override class var readableTypes: [String] {
        return ["public.comma-separated-values-text", "org.openxmlformats.spreadsheetml.sheet"]
    }
    
    override class func canConcurrentlyReadDocuments(ofType typeName: String) -> Bool {
        return true
    }
}

