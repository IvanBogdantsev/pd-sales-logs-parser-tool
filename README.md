# Sales Log Parser

A macOS application for analyzing CSV and Excel (coming soon) data files with a focus on filtering and result presentation.

## Features

- Load and parse CSV files (Excel files support in future updates)
- Automatic delimiter detection (comma, semicolon, tab)
- Multiple encoding support (UTF-8, Windows-1252, ISO Latin 1, ASCII)
- Smart column name detection with fuzzy matching
- Filter data by:
  - Store ID (Código da Loja)
  - POS ID (Id do POS)
  - Payment Method (Desc Meio Pag)
- Display count of unique transactions based on applied filters
- Save and load filter presets for quick analysis
- Modern programmatically created UI

## Screenshots

(Screenshots to be added)

## Usage Instructions

1. Launch the application
2. Click "Load File" to select a CSV file
3. Once loaded, use the dropdown menus to filter data by:
   - Store ID
   - POS ID
   - Payment Method
4. The application will automatically display:
   - Dates from the date column
   - Count of unique transactions
5. Save your current filter configuration as a preset by clicking "Save Preset"
6. Apply saved presets from the Presets dropdown

## Technical Details

- Pure Swift implementation
- No storyboards - UI created programmatically
- Robust CSV parsing with delimiter detection
- Fuzzy column name matching for flexibility with different file formats
- Background processing for large files
- User defaults for storing presets

## Project Structure

- **Models**: Data structures for CSV data and filter presets
- **Services**: Handling file parsing and preset management
- **View Controllers**: UI logic and user interaction

## Requirements

- macOS 12.0 or later
- Swift 5.5 or later
- Xcode 13.0 or later (for development)

## Installation

1. Download the latest release from the [Releases](https://github.com/IvanBogdantsev/pd-sales-logs-parser-tool/releases) page
2. Open the .dmg file and drag the application to your Applications folder
3. Launch the app from your Applications folder

## Development Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/IvanBogdantsev/pd-sales-logs-parser-tool.git
   ```
2. Open the Xcode project file
3. Build and run the application

## Roadmap

- [ ] Add Excel (.xlsx, .xls) file support
- [ ] Export filtered results
- [ ] Add additional filter types
- [ ] Save/export filter results
- [ ] Enhanced data visualization
- [ ] Localization

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details. 