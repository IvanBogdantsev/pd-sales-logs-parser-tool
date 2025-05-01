#!/bin/bash

# Super simplified CSV parser with hardcoded column positions
CSV_FILE="$1"

if [ -z "$CSV_FILE" ]; then
    echo "Usage: $0 <csv_file>"
    exit 1
fi

# Load presets file - or create empty one if not exists
PRESETS_FILE="$(dirname "$0")/presets.json"
if [ ! -f "$PRESETS_FILE" ]; then
    echo "Warning: No presets file found at $PRESETS_FILE."
    echo "Creating empty presets file..."
    echo "[]" > "$PRESETS_FILE"
fi

echo "Processing CSV file: $CSV_FILE"

# Columns are hardcoded for the sample.csv format:
# 1. Código da Loja (Store ID)
# 2. Id do POS (POS ID) 
# 3. Desc Meio Pag (Payment Method)
# 4. Dia Formatado (Date)
# 5. Número da Transacção (Transaction ID)

# Display file information
total_lines=$(wc -l < "$CSV_FILE")
echo "Total lines: $total_lines"
header_line=$(head -n 1 "$CSV_FILE")
echo "Headers: $header_line"

# Count uniques for each column
store_count=$(cut -d, -f1 "$CSV_FILE" | tail -n +2 | sort -u | wc -l | tr -d ' ')
pos_count=$(cut -d, -f2 "$CSV_FILE" | tail -n +2 | sort -u | wc -l | tr -d ' ')
pay_count=$(cut -d, -f3 "$CSV_FILE" | tail -n +2 | sort -u | wc -l | tr -d ' ')
date_count=$(cut -d, -f4 "$CSV_FILE" | tail -n +2 | sort -u | wc -l | tr -d ' ')
tx_count=$(cut -d, -f5 "$CSV_FILE" | tail -n +2 | sort -u | wc -l | tr -d ' ')

echo "Found $store_count unique store IDs"
echo "Found $pos_count unique POS IDs"
echo "Found $pay_count unique payment methods"
echo "Found $date_count unique dates"
echo "Found $tx_count unique transactions"

# Apply each preset
if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed. Please install it with 'brew install jq'"
    exit 1
fi

presets_count=$(jq '. | length' "$PRESETS_FILE")

if [ "$presets_count" -eq 0 ]; then
    echo "No presets found. Displaying all data."
    # Show all unique transactions
    echo "All transactions: $tx_count"
    echo "Dates summary:"
    cut -d, -f4 "$CSV_FILE" | tail -n +2 | sort | uniq -c | sort -nr
    exit 0
fi

echo "Applying presets to data..."

# Loop through each preset
for i in $(seq 0 $((presets_count - 1))); do
    preset_name=$(jq -r ".[$i].name" "$PRESETS_FILE")
    
    # Get filter values
    store_ids_json=$(jq -r ".[$i].storeIds" "$PRESETS_FILE")
    pos_ids_json=$(jq -r ".[$i].posIds" "$PRESETS_FILE")
    payment_methods_json=$(jq -r ".[$i].paymentMethods" "$PRESETS_FILE")
    
    echo "--------------------------------------"
    echo "Applying preset: $preset_name"
    
    # Create temp file for filtering
    temp_file=$(mktemp)
    
    # Start with all data (skipping header)
    tail -n +2 "$CSV_FILE" > "$temp_file"
    total_count=$(wc -l < "$temp_file")
    
    # Process store IDs filter
    if [ "$store_ids_json" != "null" ]; then
        store_ids=$(jq -r ".[$i].storeIds[]" "$PRESETS_FILE" 2>/dev/null | paste -sd "|" -)
        filtered_file=$(mktemp)
        grep -E "^($store_ids)," "$temp_file" > "$filtered_file"
        mv "$filtered_file" "$temp_file"
    fi
    
    # Process POS IDs filter
    if [ "$pos_ids_json" != "null" ]; then
        pos_ids=$(jq -r ".[$i].posIds[]" "$PRESETS_FILE" 2>/dev/null | paste -sd "|" -)
        filtered_file=$(mktemp)
        grep -E "^[^,]*,($pos_ids)," "$temp_file" > "$filtered_file"
        mv "$filtered_file" "$temp_file"
    fi
    
    # Process payment methods filter
    if [ "$payment_methods_json" != "null" ]; then
        payment_methods=$(jq -r ".[$i].paymentMethods[]" "$PRESETS_FILE" 2>/dev/null | paste -sd "|" -)
        filtered_file=$(mktemp)
        grep -E "^[^,]*,[^,]*,($payment_methods)," "$temp_file" > "$filtered_file"
        mv "$filtered_file" "$temp_file"
    fi
    
    # Count filtered rows
    filtered_count=$(wc -l < "$temp_file")
    echo "Filtered rows: $filtered_count of $total_count"
    
    # Count unique transactions
    unique_trans=$(cut -d, -f5 "$temp_file" | sort -u | wc -l | tr -d ' ')
    echo "Unique transactions count: $unique_trans"
    
    # Show date summary
    echo "Dates from filtered data:"
    cut -d, -f4 "$temp_file" | sort | uniq -c | sort -nr
    
    # Clean up
    rm -f "$temp_file"
done 