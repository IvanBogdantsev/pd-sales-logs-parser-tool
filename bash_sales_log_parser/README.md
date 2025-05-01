# Bash Sales Log Parser

A command-line version of the Sales Log Parser tool, rewritten in Bash.

## Features

- CSV parsing with automatic delimiter detection (comma, semicolon, tab)
- Column name detection with fuzzy matching
- Filter data by:
  - Store ID
  - POS ID
  - Payment Method
- Display count of unique transactions based on applied filters
- Saved presets system with JSON storage
- Easy to use command-line interface

## Requirements

- Bash shell (macOS, Linux)
- jq (for JSON parsing)

## Installation

1. Clone this repository or download the files
2. Ensure the script files are executable:
   ```bash
   chmod +x parser.sh manage_presets.sh
   ```
3. If you don't have jq installed, install it:
   - macOS: `brew install jq`
   - Linux: `apt-get install jq` or `yum install jq` depending on your distribution

## Usage

### Parsing CSV Files

```bash
./parser.sh path/to/your/sales_data.csv
```

This will:
1. Detect the CSV delimiter automatically
2. Identify column names using fuzzy matching
3. Extract unique values for filtering
4. Apply all saved presets and show the results

### Managing Presets

```bash
./manage_presets.sh list            # List all saved presets
./manage_presets.sh add "My Preset" # Add a new preset
./manage_presets.sh delete 123      # Delete a preset by ID
./manage_presets.sh help            # Show help
```

When adding a preset, you'll be prompted to enter filter values for:
- Store IDs (comma-separated)
- POS IDs (comma-separated)
- Payment Methods (comma-separated)

Leave any field empty to include all values for that filter (equivalent to "Any").

## How It Works

The parser works by:
1. Detecting the CSV delimiter from common options (comma, semicolon, tab)
2. Using fuzzy column name matching to find key fields in various formats
3. Extracting unique values for each filter field
4. Loading and applying each saved preset
5. Counting unique transactions based on the Transaction Number field
6. Displaying date information and transaction counts

## File Structure

- `parser.sh`: Main script for parsing CSV files
- `manage_presets.sh`: Helper script for managing filter presets
- `presets.json`: JSON storage for saved presets

## Preset Format

Presets are stored in JSON format:

```json
[
  {
    "id": "1681234567",
    "name": "Example Preset",
    "storeIds": ["123", "456"],
    "posIds": ["POS1", "POS2"],
    "paymentMethods": ["Credit Card"]
  }
]
```

Each preset can include any combination of filters. Setting a filter to `null` means "Any" (include all values). 