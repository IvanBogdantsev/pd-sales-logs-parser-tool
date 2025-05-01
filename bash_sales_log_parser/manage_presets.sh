#!/bin/bash

# Helper script to manage presets for Sales Log Parser

PRESETS_FILE="$(dirname "$0")/presets.json"

# Function to display script usage
show_usage() {
    echo "Usage: $0 <command> [options]"
    echo "Commands:"
    echo "  list                 - List all saved presets"
    echo "  add <name>           - Add a new preset"
    echo "  delete <id>          - Delete a preset by ID"
    echo "  help                 - Show this help message"
    echo ""
    echo "Example: $0 add 'My New Preset'"
    exit 1
}

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed. Please install jq to manage presets."
    echo "You can install it via: brew install jq"
    exit 1
fi

# Check if presets file exists, create if not
if [ ! -f "$PRESETS_FILE" ]; then
    echo "Creating presets file..."
    echo "[]" > "$PRESETS_FILE"
fi

# Function to list all presets
list_presets() {
    echo "Saved Presets:"
    echo "--------------------------------------"
    
    presets_count=$(jq '. | length' "$PRESETS_FILE")
    
    if [ "$presets_count" -eq 0 ]; then
        echo "No presets found."
        return
    fi
    
    for i in $(seq 0 $((presets_count - 1))); do
        id=$(jq -r ".[$i].id" "$PRESETS_FILE")
        name=$(jq -r ".[$i].name" "$PRESETS_FILE")
        
        store_ids_json=$(jq -r ".[$i].storeIds" "$PRESETS_FILE")
        pos_ids_json=$(jq -r ".[$i].posIds" "$PRESETS_FILE")
        payment_methods_json=$(jq -r ".[$i].paymentMethods" "$PRESETS_FILE")
        
        echo "ID: $id"
        echo "Name: $name"
        
        if [ "$store_ids_json" != "null" ]; then
            echo "Store IDs: $(jq -r ".[$i].storeIds | join(\", \")" "$PRESETS_FILE")"
        else
            echo "Store IDs: Any"
        fi
        
        if [ "$pos_ids_json" != "null" ]; then
            echo "POS IDs: $(jq -r ".[$i].posIds | join(\", \")" "$PRESETS_FILE")"
        else
            echo "POS IDs: Any"
        fi
        
        if [ "$payment_methods_json" != "null" ]; then
            echo "Payment Methods: $(jq -r ".[$i].paymentMethods | join(\", \")" "$PRESETS_FILE")"
        else
            echo "Payment Methods: Any"
        fi
        
        echo "--------------------------------------"
    done
}

# Function to add a new preset
add_preset() {
    local name="$1"
    
    if [ -z "$name" ]; then
        echo "Error: Preset name is required."
        show_usage
    fi
    
    # Generate new unique ID (unix timestamp)
    id=$(date +%s)
    
    echo "Adding new preset: $name"
    echo "Select filter values (leave empty for 'Any'):"
    
    # Get Store IDs
    echo "Store IDs (comma-separated, leave empty for 'Any'):"
    read -r store_ids_input
    
    # Get POS IDs
    echo "POS IDs (comma-separated, leave empty for 'Any'):"
    read -r pos_ids_input
    
    # Get Payment Methods
    echo "Payment Methods (comma-separated, leave empty for 'Any'):"
    read -r payment_methods_input
    
    # Process inputs to JSON format
    store_ids_json="null"
    if [ -n "$store_ids_input" ]; then
        # Convert comma-separated list to JSON array
        store_ids_array=$(echo "$store_ids_input" | sed 's/ //g' | tr ',' '\n' | jq -R . | jq -s .)
        store_ids_json="$store_ids_array"
    fi
    
    pos_ids_json="null"
    if [ -n "$pos_ids_input" ]; then
        pos_ids_array=$(echo "$pos_ids_input" | sed 's/ //g' | tr ',' '\n' | jq -R . | jq -s .)
        pos_ids_json="$pos_ids_array"
    fi
    
    payment_methods_json="null"
    if [ -n "$payment_methods_input" ]; then
        payment_methods_array=$(echo "$payment_methods_input" | sed 's/ //g' | tr ',' '\n' | jq -R . | jq -s .)
        payment_methods_json="$payment_methods_array"
    fi
    
    # Create JSON for new preset
    new_preset=$(jq -n \
        --arg id "$id" \
        --arg name "$name" \
        --argjson storeIds "$store_ids_json" \
        --argjson posIds "$pos_ids_json" \
        --argjson paymentMethods "$payment_methods_json" \
        '{id: $id, name: $name, storeIds: $storeIds, posIds: $posIds, paymentMethods: $paymentMethods}')
    
    # Add new preset to existing presets
    jq --argjson new_preset "$new_preset" '. += [$new_preset]' "$PRESETS_FILE" > "${PRESETS_FILE}.tmp" && mv "${PRESETS_FILE}.tmp" "$PRESETS_FILE"
    
    echo "Preset added successfully."
}

# Function to delete a preset
delete_preset() {
    local id="$1"
    
    if [ -z "$id" ]; then
        echo "Error: Preset ID is required."
        show_usage
    fi
    
    # Check if preset exists
    if ! jq -e ".[] | select(.id == \"$id\")" "$PRESETS_FILE" > /dev/null; then
        echo "Error: Preset with ID '$id' not found."
        exit 1
    fi
    
    # Remove preset from file
    jq "map(select(.id != \"$id\"))" "$PRESETS_FILE" > "${PRESETS_FILE}.tmp" && mv "${PRESETS_FILE}.tmp" "$PRESETS_FILE"
    
    echo "Preset deleted successfully."
}

# Main command processing
if [ $# -lt 1 ]; then
    show_usage
fi

COMMAND="$1"
shift

case "$COMMAND" in
    list)
        list_presets
        ;;
    add)
        add_preset "$1"
        ;;
    delete)
        delete_preset "$1"
        ;;
    help)
        show_usage
        ;;
    *)
        echo "Error: Unknown command '$COMMAND'"
        show_usage
        ;;
esac

exit 0 