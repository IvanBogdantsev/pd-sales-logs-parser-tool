#!/bin/bash

# Sales Log Parser - Bash Edition
# A script to parse CSV files with simplified column detection

# Function to display script usage
show_usage() {
    echo "Usage: $0 <path_to_csv_file>"
    echo "Example: $0 sales_data.csv"
    exit 1
}

# Check if path to CSV is provided
if [ -z "$1" ]; then
    show_usage
fi

# Validate if file exists
CSV_FILE="$1"
if [ ! -f "$CSV_FILE" ]; then
    echo "Error: File '$CSV_FILE' not found."
    exit 1
fi

# Load presets from presets.json
PRESETS_FILE="$(dirname "$0")/presets.json"
if [ ! -f "$PRESETS_FILE" ]; then
    echo "Warning: No presets file found at $PRESETS_FILE."
    echo "Creating empty presets file..."
    echo "[]" > "$PRESETS_FILE"
fi

# Function to detect CSV delimiter
detect_delimiter() {
    local file="$1"
    
    # Check first few lines for common delimiters
    local comma_count=$(head -n 5 "$file" | grep -o "," | wc -l)
    local semicolon_count=$(head -n 5 "$file" | grep -o ";" | wc -l)
    local tab_count=$(head -n 5 "$file" | grep -o $'\t' | wc -l)
    
    local delimiter=","
    if [ "$semicolon_count" -gt "$comma_count" ] && [ "$semicolon_count" -gt "$tab_count" ]; then
        delimiter=";"
    elif [ "$tab_count" -gt "$comma_count" ] && [ "$tab_count" -gt "$semicolon_count" ]; then
        delimiter=$'\t'
    fi
    
    echo "$delimiter"
}

# Function to find a column index by name pattern
find_column() {
    local header_line="$1"
    local delimiter="$2"
    local pattern="$3"
    
    # Convert header line to lowercase for case-insensitive matching
    local header_lower=$(echo "$header_line" | tr '[:upper:]' '[:lower:]')
    
    # Use awk to find matching column
    echo "$header_line" | awk -F "$delimiter" -v pattern="$pattern" '
    BEGIN {
        split(tolower($0), headers)
        for (i=1; i<=NF; i++) {
            if (tolower(headers[i]) ~ pattern) {
                print i
                exit
            }
        }
    }'
}

# Function to parse a CSV file
parse_csv() {
    local file="$1"
    
    # Detect delimiter
    local delimiter=$(detect_delimiter "$file")
    echo "Detected delimiter: '$delimiter'"
    
    # Get headers line
    local header_line=$(head -n 1 "$file")
    echo "Headers: $header_line"
    
    # Find column indexes for key fields
    STORE_COL=$(find_column "$header_line" "$delimiter" "codigo.*loja|store.*id|store.*code")
    POS_COL=$(find_column "$header_line" "$delimiter" "id.*pos|pos.*id|terminal")
    PAY_COL=$(find_column "$header_line" "$delimiter" "meio.*pag|payment.*method|method|pagamento")
    DATE_COL=$(find_column "$header_line" "$delimiter" "dia.*formatado|date|data")
    TRANS_COL=$(find_column "$header_line" "$delimiter" "n[uú]mero.*transac|transaction.*id|transaction.*number")
    
    echo "Column indices - Store: $STORE_COL, POS: $POS_COL, Payment: $PAY_COL, Date: $DATE_COL, Transaction: $TRANS_COL"
    
    # Extract unique values counts for filters
    if [ -n "$STORE_COL" ]; then
        local store_count=$(cut -d "$delimiter" -f "$STORE_COL" "$file" | tail -n +2 | sort -u | wc -l)
        echo "Found $store_count unique store IDs"
    else
        echo "Warning: Could not find store ID column"
    fi
    
    if [ -n "$POS_COL" ]; then
        local pos_count=$(cut -d "$delimiter" -f "$POS_COL" "$file" | tail -n +2 | sort -u | wc -l)
        echo "Found $pos_count unique POS IDs"
    else
        echo "Warning: Could not find POS ID column"
    fi
    
    if [ -n "$PAY_COL" ]; then
        local pay_count=$(cut -d "$delimiter" -f "$PAY_COL" "$file" | tail -n +2 | sort -u | wc -l)
        echo "Found $pay_count unique payment methods"
    else
        echo "Warning: Could not find payment method column"
    fi
    
    # Apply presets to the data
    echo "Applying presets to data..."
    apply_presets "$file" "$delimiter" "$STORE_COL" "$POS_COL" "$PAY_COL" "$DATE_COL" "$TRANS_COL"
}

# Function to apply filter presets
apply_presets() {
    local file="$1"
    local delimiter="$2"
    local store_col="$3"
    local pos_col="$4"
    local pay_col="$5"
    local date_col="$6"
    local trans_col="$7"
    
    # Check for jq command
    if ! command -v jq &> /dev/null; then
        echo "Error: jq is not installed. Please install jq to parse JSON presets."
        echo "You can install it via: brew install jq"
        exit 1
    fi
    
    # Get preset count
    local presets_count=$(jq '. | length' "$PRESETS_FILE")
    
    if [ "$presets_count" -eq 0 ]; then
        echo "No presets found. Displaying all data."
        count_transactions "$file" "$delimiter" "" "" "" "$store_col" "$pos_col" "$pay_col" "$date_col" "$trans_col"
        return
    fi
    
    # Loop through each preset
    for i in $(seq 0 $((presets_count - 1))); do
        local preset_name=$(jq -r ".[$i].name" "$PRESETS_FILE")
        
        # Get filter values
        local store_ids_json=$(jq -r ".[$i].storeIds" "$PRESETS_FILE")
        local pos_ids_json=$(jq -r ".[$i].posIds" "$PRESETS_FILE")
        local payment_methods_json=$(jq -r ".[$i].paymentMethods" "$PRESETS_FILE")
        
        echo "--------------------------------------"
        echo "Applying preset: $preset_name"
        
        # Process store IDs filter
        local store_ids_filter=""
        if [ "$store_ids_json" != "null" ]; then
            local ids=$(jq -r ".[$i].storeIds[]" "$PRESETS_FILE" 2>/dev/null)
            store_ids_filter=$(echo "$ids" | paste -sd "|" -)
        fi
        
        # Process POS IDs filter
        local pos_ids_filter=""
        if [ "$pos_ids_json" != "null" ]; then
            local ids=$(jq -r ".[$i].posIds[]" "$PRESETS_FILE" 2>/dev/null)
            pos_ids_filter=$(echo "$ids" | paste -sd "|" -)
        fi
        
        # Process payment methods filter
        local payment_methods_filter=""
        if [ "$payment_methods_json" != "null" ]; then
            local methods=$(jq -r ".[$i].paymentMethods[]" "$PRESETS_FILE" 2>/dev/null)
            payment_methods_filter=$(echo "$methods" | paste -sd "|" -)
        fi
        
        # Apply filters and count transactions
        count_transactions "$file" "$delimiter" "$store_ids_filter" "$pos_ids_filter" "$payment_methods_filter" "$store_col" "$pos_col" "$pay_col" "$date_col" "$trans_col"
    done
}

# Function to count transactions with filters
count_transactions() {
    local file="$1"
    local delimiter="$2"
    local store_ids_filter="$3"
    local pos_ids_filter="$4"
    local payment_methods_filter="$5"
    local store_col="$6"
    local pos_col="$7"
    local pay_col="$8"
    local date_col="$9"
    local trans_col="${10}"
    
    # Create temp file for filtering
    local temp_file=$(mktemp)
    
    # Start with all data (skipping header)
    tail -n +2 "$file" > "$temp_file"
    local total_count=$(wc -l < "$temp_file")
    
    # Apply store filter if provided
    if [ -n "$store_col" ] && [ -n "$store_ids_filter" ]; then
        local filtered_file=$(mktemp)
        grep -E "^([^$delimiter]*$delimiter){$((store_col-1))}($store_ids_filter)($delimiter|$)" "$temp_file" > "$filtered_file"
        mv "$filtered_file" "$temp_file"
    fi
    
    # Apply POS filter if provided
    if [ -n "$pos_col" ] && [ -n "$pos_ids_filter" ]; then
        local filtered_file=$(mktemp)
        grep -E "^([^$delimiter]*$delimiter){$((pos_col-1))}($pos_ids_filter)($delimiter|$)" "$temp_file" > "$filtered_file"
        mv "$filtered_file" "$temp_file"
    fi
    
    # Apply payment method filter if provided
    if [ -n "$pay_col" ] && [ -n "$payment_methods_filter" ]; then
        local filtered_file=$(mktemp)
        grep -E "^([^$delimiter]*$delimiter){$((pay_col-1))}($payment_methods_filter)($delimiter|$)" "$temp_file" > "$filtered_file"
        mv "$filtered_file" "$temp_file"
    fi
    
    # Count filtered rows
    local filtered_count=$(wc -l < "$temp_file")
    echo "Filtered rows: $filtered_count of $total_count"
    
    # Count unique transactions
    if [ -n "$trans_col" ]; then
        local unique_trans=$(cut -d "$delimiter" -f "$trans_col" "$temp_file" | sort -u | wc -l)
        echo "Unique transactions count: $unique_trans"
    else
        echo "Error: Could not find transaction number column"
    fi
    
    # Count and display dates if date column exists
    if [ -n "$date_col" ]; then
        echo "Dates from filtered data:"
        cut -d "$delimiter" -f "$date_col" "$temp_file" | sort | uniq -c | sort -nr | head -10
    fi
    
    # Clean up
    rm -f "$temp_file"
}

# Main execution
echo "Processing file: $CSV_FILE"
parse_csv "$CSV_FILE" 