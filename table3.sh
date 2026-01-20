#!/bin/bash

# 1. SETUP: Filename and Metadata
read -p "Enter database filename: " DB
META=".$DB.meta"
SEP=":"

# Initialize file if it doesn't exist
if [ ! -f "$DB" ]; then
    read -p "How many columns do you need? " count
    header=""
    meta=""
    for (( i=1; i<=$count; i++ )); do
        read -p "Col $i Name: " n
        read -p "Col $i Type (int/str/any): " t
        
        if [ -z "$header" ]; then
            header="$n"
        else
            header="$header$SEP$n"
        fi
        # Adding a pipe at the end to help 'cut' count fields later
        meta="$meta$n$SEP$t|"
    done
    echo "$header" > "$DB"
    echo "$meta" > "$META"
fi

# LOAD: Read constraints from Meta using 'cut' instead of Parameter Expansion
declare -a NAMES
declare -a TYPES
RAW_META=$(cat "$META")

# Count how many columns by counting the pipes
COL_TOTAL=$(echo "$RAW_META" | tr -cd '|' | wc -c)

for (( i=1; i<=$COL_TOTAL; i++ )); do
    # Get the i-th block (e.g., Name:str)
    PAIR=$(echo "$RAW_META" | cut -d'|' -f$i)
    # Extract Name and Type using cut
    NAMES[$i]=$(echo "$PAIR" | cut -d"$SEP" -f1)
    TYPES[$i]=$(echo "$PAIR" | cut -d"$SEP" -f2)
done

# --- FUNCTIONS ---

validate_input() {
    local val="$1"
    local type="$2"
    local is_pk="$3"

    if [ -z "$val" ]; then echo "Required."; return; fi
    
    # Check for separator character
    if echo "$val" | grep -q "$SEP"; then 
        echo "Error: '$SEP' not allowed."
        return
    fi

    # Type Validation using Wildcards and Case
    case "$type" in
        int)
            if [[ "$val" == *[!0-9]* ]]; then
                echo "Must be digits."
                return
            fi
            ;;
        str)
            if [[ "$val" == *[!a-zA-Z\ ]* ]]; then
                echo "Must be letters."
                return
            fi
            ;;
    esac

    # Primary Key Check
    if [ "$is_pk" = "true" ]; then
        exists=$(awk -F"$SEP" -v id="$val" '$1 == id {print "yes"}' "$DB")
        if [ "$exists" = "yes" ]; then
            echo "ID already exists."
            return
        fi
    fi
}

add_row() {
    local row=""
    for (( i=1; i<=$COL_TOTAL; i++ )); do
        valid="false"
        while [ "$valid" = "false" ]; do
            read -p "Enter ${NAMES[$i]} (${TYPES[$i]}): " in
            
            # Set PK check flag for first column
            pk_flag="false"; [ $i -eq 1 ] && pk_flag="true"
            
            err=$(validate_input "$in" "${TYPES[$i]}" "$pk_flag")
            
            if [ -z "$err" ]; then
                valid="true"
                if [ -z "$row" ]; then row="$in"; else row="$row$SEP$in"; fi
            else
                echo "❌ $err"
            fi
        done
    done
    echo "$row" >> "$DB"
    echo "✅ Saved."
}

update_row() {
    read -p "Enter ID to update: " uid
    exists=$(awk -F"$SEP" -v id="$uid" '$1 == id {print "yes"}' "$DB")
    if [ "$exists" != "yes" ]; then echo "❌ ID not found."; return; fi

    current_row=$(grep "^$uid$SEP" "$DB")
    new_row=""

    for (( i=1; i<=$COL_TOTAL; i++ )); do
        # Extract current value using awk
        current_val=$(echo "$current_row" | awk -F"$SEP" -v col=$i '{print $col}')
        
        valid="false"
        while [ "$valid" = "false" ]; do
            read -p "New ${NAMES[$i]} (Current: $current_val): " in
            [ -z "$in" ] && in="$current_val"
            
            pk_flag="false"
            if [ $i -eq 1 ] && [ "$in" != "$uid" ]; then pk_flag="true"; fi
            
            err=$(validate_input "$in" "${TYPES[$i]}" "$pk_flag")
            if [ -z "$err" ]; then
                valid="true"
                if [ -z "$new_row" ]; then new_row="$in"; else new_row="$new_row$SEP$in"; fi
            else
                echo "❌ $err"
            fi
        done
    done
    sed -i "s/^$uid$SEP.*/$new_row/" "$DB"
    echo "✅ Updated."
}

delete_row() {
    read -p "Enter ID to delete: " did
    exists=$(awk -F"$SEP" -v id="$did" '$1 == id {print "yes"}' "$DB")
    
    if [ "$exists" = "yes" ]; then
        sed -i "/^$did$SEP/d" "$DB"
        echo "🗑️ Deleted ID: $did"
    else
        echo "❌ ID not found. Nothing deleted."
    fi
}

view_table() {
    echo -e "\n--- $DB ---"
    if [ -s "$DB" ]; then
        column -t -s "$SEP" "$DB"
    else
        echo "Empty."
    fi
    echo -e "-----------\n"
}

# --- MAIN MENU ---
while true; do
    echo "1)Add 2)View 3)Search 4)Update 5)Delete 6)Exit"
    read -p "Choice: " opt
    case $opt in
        1) add_row ;;
        2) view_table ;;
        3) read -p "ID: " sid; head -n 1 "$DB" | column -t -s "$SEP"; grep "^$sid$SEP" "$DB" | column -t -s "$SEP" ;;
        4) update_row ;;
        5) delete_row ;;
        6) exit 0 ;;
        *) echo "Invalid choice." ;;
    esac
done
