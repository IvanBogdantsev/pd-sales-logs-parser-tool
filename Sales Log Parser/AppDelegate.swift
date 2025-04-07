// Sales Log Parser
// Created by Ivan B.

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Set up the application when it launches
        
        // Create a 'Services' menu item
        NSApp.servicesMenu = NSMenu(title: "Services")
        
        // Enable automatic termination when all windows are closed
        NSApp.setActivationPolicy(.regular)
        
        // Create and configure the main window
        let mainWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 500),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        mainWindow.center()
        mainWindow.title = "Sales Log Parser"
        
        // Create and set the view controller
        let viewController = ViewController()
        mainWindow.contentViewController = viewController
        
        // Store the window and show it
        self.window = mainWindow
        mainWindow.makeKeyAndOrderFront(nil)
    }
    
    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        // Don't open an untitled document at launch
        return false
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Clean up any resources before termination
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    // Handle files opened from Finder
    func application(_ application: NSApplication, open urls: [URL]) {
        if let viewController = window?.contentViewController as? ViewController {
            for url in urls {
                viewController.loadFile(at: url)
                break // Just load the first file
            }
        }
    }
}

