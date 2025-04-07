import Foundation

class PresetService {
    private let userDefaultsKey = "savedFilterPresets"
    
    // Save a new preset
    func savePreset(name: String, storeId: String?, posId: String?, paymentMethod: String?) {
        let preset = FilterPreset(
            name: name, 
            storeId: storeId, 
            posId: posId, 
            paymentMethod: paymentMethod
        )
        
        var presets = loadPresets()
        presets.append(preset)
        savePresets(presets)
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
            return []
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