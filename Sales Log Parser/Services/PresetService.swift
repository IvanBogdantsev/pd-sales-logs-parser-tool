import Foundation

class PresetService {
    private let userDefaultsKey = "savedFilterPresets"
    
    // Save a new preset
    func savePreset(name: String, storeIds: [String]?, posIds: [String]?, paymentMethods: [String]?) {
        let preset = FilterPreset(
            name: name, 
            storeIds: storeIds, 
            posIds: posIds, 
            paymentMethods: paymentMethods
        )
        
        var presets = loadPresets()
        presets.append(preset)
        savePresets(presets)
    }
    
    // For backward compatibility with older versions
    func savePreset(name: String, storeId: String?, posId: String?, paymentMethod: String?) {
        // Convert single values to arrays
        let storeIds = storeId != nil ? [storeId!] : nil
        let posIds = posId != nil ? [posId!] : nil
        let paymentMethods = paymentMethod != nil ? [paymentMethod!] : nil
        
        savePreset(name: name, storeIds: storeIds, posIds: posIds, paymentMethods: paymentMethods)
    }
    
    // Load all saved presets
    func loadPresets() -> [FilterPreset] {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else {
            return []
        }
        
        do {
            let presets = try JSONDecoder().decode([FilterPreset].self, from: data)
            return presets
        } catch {
            print("Error loading presets: \(error)")
            // Try to load and migrate legacy presets
            if let legacyPresets = loadLegacyPresets() {
                print("Successfully migrated \(legacyPresets.count) legacy presets")
                savePresets(legacyPresets)
                return legacyPresets
            }
            return []
        }
    }
    
    // Attempt to load and migrate legacy presets
    private func loadLegacyPresets() -> [FilterPreset]? {
        // Legacy preset structure (for decoder)
        struct LegacyPreset: Codable {
            var id = UUID()
            var name: String
            var storeId: String?
            var posId: String?
            var paymentMethod: String?
        }
        
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else {
            return nil
        }
        
        do {
            let legacyPresets = try JSONDecoder().decode([LegacyPreset].self, from: data)
            // Convert to new format
            return legacyPresets.map { legacy in
                FilterPreset(
                    id: legacy.id,
                    name: legacy.name,
                    storeIds: legacy.storeId != nil ? [legacy.storeId!] : nil,
                    posIds: legacy.posId != nil ? [legacy.posId!] : nil,
                    paymentMethods: legacy.paymentMethod != nil ? [legacy.paymentMethod!] : nil
                )
            }
        } catch {
            print("Error loading legacy presets: \(error)")
            return nil
        }
    }
    
    // Delete a preset
    func deletePreset(withId id: UUID) {
        var presets = loadPresets()
        presets.removeAll { $0.id == id }
        savePresets(presets)
    }
    
    // Save presets to UserDefaults
    private func savePresets(_ presets: [FilterPreset]) {
        do {
            let data = try JSONEncoder().encode(presets)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            print("Error saving presets: \(error)")
        }
    }
} 