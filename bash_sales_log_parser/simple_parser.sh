#!/bin/bash

# A very simple parser script
CSV_FILE="$1"

if [ -z "$CSV_FILE" ]; then
    echo "Usage: $0 <csv_file>"
    exit 1
fi

echo "Processing CSV file: $CSV_FILE"

# Count lines
total_lines=$(wc -l < "$CSV_FILE")
echo "Total lines: $total_lines"

# Display headers
header_line=$(head -n 1 "$CSV_FILE")
echo "Headers: $header_line"

# Count unique values in each column
echo "Counting unique values by column position:"
col_count=$(echo "$header_line" | tr ',' '\n' | wc -l)

for i in $(seq 1 $col_count); do
  column_name=$(echo "$header_line" | cut -d ',' -f $i)
  unique_count=$(cut -d ',' -f $i "$CSV_FILE" | tail -n +2 | sort -u | wc -l)
  echo "Column $i ($column_name): $unique_count unique values"
done

# Count unique transaction IDs (assuming column 5)
tx_count=$(cut -d ',' -f 5 "$CSV_FILE" | tail -n +2 | sort -u | wc -l)
echo "Unique transactions: $tx_count"

# Show date counts (assuming column 4)
echo "Date counts:"
cut -d ',' -f 4 "$CSV_FILE" | tail -n +2 | sort | uniq -c | sort -nr

# Apply example filter - show transactions for store ID 123
echo "Filtered results for store ID 123:"
grep "^123," "$CSV_FILE" | cut -d ',' -f 5 | sort -u | wc -l
echo "Transaction IDs: "
grep "^123," "$CSV_FILE" | cut -d ',' -f 5 | sort -u 