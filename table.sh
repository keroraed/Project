#! /usr/bin/bash

LC_COLLATE=C 
shopt -s extglob 

Reset="\033[0m"
Red="\033[31m"
Green="\033[32m"
Yellow="\033[33m"
Blue="\033[34m"
Cyan="\033[36m"

currentDB="$CURRENT_DB"

menu=("CreateTable" "ListAllTables" "InsertIntoTable" "UpdateTable" "DeleteFromTable" "SelectFromTable" "RemoveTable" "Exit" )
select variable in  ${menu[@]}
do 
    case $REPLY in
    1 | "CreateTable" ) 
        echo "Your Choise is CreateTable ......."
        
        read  -r -p "Enter Table Name :" input 
        input=$(tr " " "_" <<< $input)
        
        if [[ -z $input ]];then 
            echo -e "$Red Error 200: Table Name Cannot be Empty $Reset"
        elif [[ ${#input} -gt 64 ]];then 
            echo -e "$Red Error 205: Table Name Too Long (max 64 characters) $Reset"
        elif [[ $input = [0-9]* ]];then   
            echo -e "$Red Error 201: Name of Table Can't Start Numbers $Reset"
        else 
            case  $input in
            _)
                echo -e "$Red Error 202: Name of Table Can't be _$Reset" 
            ;;
            +([a-zA-Z0-9_]))
                existing=$(ls -F ./.DBMS/$currentDB/ 2>/dev/null | grep -v '/' | grep -v '^\.' | grep -ix "$input")
                if [[ -n $existing ]];then 
                    echo -e "$Red Error 203: Table Already Exists (name is case-insensitive)$Reset"  
                else 
                    echo "Wait Create Table ......"
                    touch ./.DBMS/$currentDB/$input
                    
                    # Define table schema
                    DB="./.DBMS/$currentDB/$input"
                    META="./.DBMS/$currentDB/.$input.meta"
                    SEP=":"
                    
                    read -p "How many columns do you need? " count
                    if [[ ! $count =~ ^[0-9]+$ ]] || [[ $count -lt 1 ]]; then
                        echo -e "$Red Error: Invalid column count $Reset"
                        rm "$DB"
                        continue
                    fi
                    
                    header=""
                    meta=""
                    for (( i=1; i<=$count; i++ )); do
                        read -p "Col $i Name: " n
                        n=$(tr " " "_" <<< $n)
                        if [[ -z $n ]]; then
                            echo -e "$Red Error: Column name cannot be empty $Reset"
                            rm "$DB"
                            continue 2
                        fi
                        
                        valid_type="false"
                        while [ "$valid_type" = "false" ]; do
                            read -p "Col $i Type (int/str): " t
                            t=$(echo "$t" | tr '[:upper:]' '[:lower:]')
                            if [[ ! $t =~ ^(int|str)$ ]]; then
                                echo -e "$Red Error: Invalid type. Use int or str $Reset"
                            else
                                valid_type="true"
                            fi
                        done
                        
                        if [ -z "$header" ]; then
                            header="$n"
                        else
                            header="$header$SEP$n"
                        fi
                        meta="$meta$n$SEP$t|"
                    done
                    echo "$header" > "$DB"
                    echo "$meta" > "$META"
                    
                    sleep 1
                    if (($? == 0));then 
                        echo "Table is Created with schema......"
                    else 
                        echo -e "$Red Error 264: Table Creation Failed $Reset"
                    fi 
                fi 
            ;;
            *)
                echo -e "$Red Error 204: Name of Table Contains Special Character : $Reset"  
            ;;
            esac
        fi
        
        ;;
    2 | "ListAllTables" )
        echo "Your Choise is ListAllTables ......."
        #List All Tables in Current DB
        
        data=$(ls -F ./.DBMS/$currentDB/ 2>/dev/null | grep -v '/' | grep -v '^\.')
        
        if [[ -z $data ]];then 
            echo -e "$Red Error 207: No Tables in Database $Reset"
        else
            echo "$data"
        fi
        
        ;;
    3 | "InsertIntoTable" )
        echo "Your Choise is InsertIntoTable ......."
        
        export PS3="InsertIntoTable>>"
        tableList=$(ls -F ./.DBMS/$currentDB/ 2>/dev/null | grep -v '/' | grep -v '^\.')
        
        if [[ -z $tableList ]];then 
            echo -e "$Red Error 207: No Tables in Database $Reset"
            export PS3="$currentDB>>"
        else
            select tableName in $tableList
            do   
                if [[ -n $tableName && -f ./.DBMS/$currentDB/$tableName ]];then 
                    DB="./.DBMS/$currentDB/$tableName"
                    META="./.DBMS/$currentDB/.$tableName.meta"
                    SEP=":"
                    
                    if [ ! -f "$META" ]; then
                        echo -e "$Red Error: Table metadata not found $Reset"
                        export PS3="$currentDB>>"
                        break
                    fi
                    
                    # LOAD: Read constraints from Meta
                    declare -a NAMES
                    declare -a TYPES
                    RAW_META=$(cat "$META")
                    
                    COL_TOTAL=$(echo "$RAW_META" | tr -cd '|' | wc -c)
                    
                    for (( i=1; i<=$COL_TOTAL; i++ )); do
                        PAIR=$(echo "$RAW_META" | cut -d'|' -f$i)
                        NAMES[$i]=$(echo "$PAIR" | cut -d"$SEP" -f1)
                        TYPES[$i]=$(echo "$PAIR" | cut -d"$SEP" -f2)
                    done
                    
                    # Insert row
                    local row=""
                    for (( i=1; i<=$COL_TOTAL; i++ )); do
                        valid="false"
                        while [ "$valid" = "false" ]; do
                            read -p "Enter ${NAMES[$i]} (${TYPES[$i]}): " in
                            
                            # Validation
                            if [ -z "$in" ]; then 
                                echo "Required."
                                continue
                            fi
                            
                            if echo "$in" | grep -q "$SEP"; then 
                                echo "Error: '$SEP' not allowed."
                                continue
                            fi
                            
                            # Type Validation
                            case "${TYPES[$i]}" in
                                int)
                                    if [[ "$in" == *[!0-9]* ]]; then
                                        echo "Must be digits."
                                        continue
                                    fi
                                    ;;
                                str)
                                    if [[ "$in" == *[!a-zA-Z\ ]* ]]; then
                                        echo "Must be letters."
                                        continue
                                    fi
                                    ;;
                            esac
                            
                            # Primary Key Check (first column)
                            if [ $i -eq 1 ]; then
                                exists=$(awk -F"$SEP" -v id="$in" '$1 == id {print "yes"}' "$DB")
                                if [ "$exists" = "yes" ]; then
                                    echo "ID already exists."
                                    continue
                                fi
                            fi
                            
                            valid="true"
                            if [ -z "$row" ]; then row="$in"; else row="$row$SEP$in"; fi
                        done
                    done
                    echo "$row" >> "$DB"
                    echo "Row inserted successfully."
                else 
                    echo -e "$Red Error 404: Table Not Found $Reset"
                fi 
                export PS3="$currentDB>>"
                break
            done
        fi
        
        ;;
    4 | "UpdateTable" )
        echo "Your Choise is UpdateTable ......."
        
        export PS3="UpdateTable>>"
        tableList=$(ls -F ./.DBMS/$currentDB/ 2>/dev/null | grep -v '/' | grep -v '^\.')
        
        if [[ -z $tableList ]];then 
            echo -e "$Red Error 207: No Tables in Database $Reset"
            export PS3="$currentDB>>"
        else
            select tableName in $tableList
            do   
                if [[ -n $tableName && -f ./.DBMS/$currentDB/$tableName ]];then 
                    DB="./.DBMS/$currentDB/$tableName"
                    META="./.DBMS/$currentDB/.$tableName.meta"
                    SEP=":"
                    
                    if [ ! -f "$META" ]; then
                        echo -e "$Red Error: Table metadata not found $Reset"
                        export PS3="$currentDB>>"
                        break
                    fi
                    
                    # LOAD: Read constraints from Meta
                    declare -a NAMES
                    declare -a TYPES
                    RAW_META=$(cat "$META")
                    
                    COL_TOTAL=$(echo "$RAW_META" | tr -cd '|' | wc -c)
                    
                    for (( i=1; i<=$COL_TOTAL; i++ )); do
                        PAIR=$(echo "$RAW_META" | cut -d'|' -f$i)
                        NAMES[$i]=$(echo "$PAIR" | cut -d"$SEP" -f1)
                        TYPES[$i]=$(echo "$PAIR" | cut -d"$SEP" -f2)
                    done
                    
                    # Update row
                    read -p "Enter ID to update: " uid
                    exists=$(awk -F"$SEP" -v id="$uid" '$1 == id {print "yes"}' "$DB")
                    if [ "$exists" != "yes" ]; then 
                        echo "ID not found."
                        export PS3="$currentDB>>"
                        break
                    fi
                
                    current_row=$(grep "^$uid$SEP" "$DB")
                    new_row=""
                
                    for (( i=1; i<=$COL_TOTAL; i++ )); do
                        current_val=$(echo "$current_row" | awk -F"$SEP" -v col=$i '{print $col}')
                        
                        valid="false"
                        while [ "$valid" = "false" ]; do
                            read -p "New ${NAMES[$i]} (Current: $current_val): " in
                            [ -z "$in" ] && in="$current_val"
                            
                            if echo "$in" | grep -q "$SEP"; then 
                                echo "Error: '$SEP' not allowed."
                                continue
                            fi
                            
                            # Type Validation
                            case "${TYPES[$i]}" in
                                int)
                                    if [[ "$in" == *[!0-9]* ]]; then
                                        echo "Must be digits."
                                        continue
                                    fi
                                    ;;
                                str)
                                    if [[ "$in" == *[!a-zA-Z\ ]* ]]; then
                                        echo "Must be letters."
                                        continue
                                    fi
                                    ;;
                            esac
                            
                            # Primary Key Check if changing ID
                            if [ $i -eq 1 ] && [ "$in" != "$uid" ]; then
                                exists=$(awk -F"$SEP" -v id="$in" '$1 == id {print "yes"}' "$DB")
                                if [ "$exists" = "yes" ]; then
                                    echo "ID already exists."
                                    continue
                                fi
                            fi
                            
                            valid="true"
                            if [ -z "$new_row" ]; then new_row="$in"; else new_row="$new_row$SEP$in"; fi
                        done
                    done
                    sed -i "s/^$uid$SEP.*/$new_row/" "$DB"
                    echo "Row updated successfully."
                else 
                    echo -e "$Red Error 404: Table Not Found $Reset"
                fi 
                export PS3="$currentDB>>"
                break
            done
        fi
        
        ;;
    5 | "DeleteFromTable" )
        echo "Your Choise is DeleteFromTable ......."
        
        export PS3="DeleteFromTable>>"
        tableList=$(ls -F ./.DBMS/$currentDB/ 2>/dev/null | grep -v '/' | grep -v '^\.')
        
        if [[ -z $tableList ]];then 
            echo -e "$Red Error 207: No Tables in Database $Reset"
            export PS3="$currentDB>>"
        else
            select tableName in $tableList
            do   
                if [[ -n $tableName && -f ./.DBMS/$currentDB/$tableName ]];then 
                    DB="./.DBMS/$currentDB/$tableName"
                    SEP=":"
                    
                    read -p "Enter ID to delete: " did
                    exists=$(awk -F"$SEP" -v id="$did" '$1 == id {print "yes"}' "$DB")
                    
                    if [ "$exists" = "yes" ]; then
                        read -p "Are you sure you want to delete row with ID '$did'? (yes/no): " confirm
                        if [[ $confirm =~ ^[Yy][Ee][Ss]$ || $confirm =~ ^[Yy]$ ]];then
                            sed -i "/^$did$SEP/d" "$DB"
                            echo "Row deleted successfully (ID: $did)"
                        else
                            echo "Delete operation cancelled"
                        fi
                    else
                        echo "ID not found. Nothing deleted."
                    fi
                else 
                    echo -e "$Red Error 404: Table Not Found $Reset"
                fi 
                export PS3="$currentDB>>"
                break
            done
        fi
        
        ;;
    6 | "SelectFromTable" )
        echo "Your Choise is SelectFromTable ......."
        
        export PS3="SelectFromTable>>"
        tableList=$(ls -F ./.DBMS/$currentDB/ 2>/dev/null | grep -v '/' | grep -v '^\.')
        
        if [[ -z $tableList ]];then 
            echo -e "$Red Error 207: No Tables in Database $Reset"
            export PS3="$currentDB>>"
        else
            select tableName in $tableList
            do   
                if [[ -n $tableName && -f ./.DBMS/$currentDB/$tableName ]];then 
                    DB="./.DBMS/$currentDB/$tableName"
                    SEP=":"
                    
                    echo "1) View All Rows  2) Search by ID"
                    read -p "Choice: " choice
                    
                    case $choice in
                        1)
                            echo -e "\n--- $tableName ---"
                            if [ -s "$DB" ]; then
                                column -t -s "$SEP" "$DB"
                            else
                                echo -e "$Yellow Table is Empty $Reset"
                            fi
                            echo -e "-----------\n"
                            ;;
                        2)
                            read -p "Enter ID: " sid
                            echo -e "\n--- Search Result ---"
                            head -n 1 "$DB" | column -t -s "$SEP"
                            grep "^$sid$SEP" "$DB" | column -t -s "$SEP"
                            if [ $? -ne 0 ]; then
                                echo "❌ No record found with ID: $sid"
                            fi
                            echo -e "-------------------\n"
                            ;;
                        *)
                            echo "Invalid choice."
                            ;;
                    esac
                else 
                    echo -e "$Red Error 404: Table Not Found $Reset"
                fi 
                export PS3="$currentDB>>"
                break
            done
        fi
        
        ;;
    7 | "RemoveTable" )
        echo "Your Choise is RemoveTable ......."
        #Remove Table
        
        export PS3="RemoveTable>>"
        tableList=$(ls -F ./.DBMS/$currentDB/ 2>/dev/null | grep -v '/' | grep -v '^\.')
        
        if [[ -z $tableList ]];then 
            echo -e "$Red Error 207: No Tables in Database $Reset"
            export PS3="$currentDB>>"
        else
            select tableName in $tableList
            do   
                if [[ -n $tableName && -f ./.DBMS/$currentDB/$tableName ]];then 
                    read -p "Are you sure you want to delete table '$tableName'? (yes/no): " confirm
                    if [[ $confirm =~ ^[Yy][Ee][Ss]$ || $confirm =~ ^[Yy]$ ]];then
                        echo "Wait delete Table ......."
                        rm ./.DBMS/$currentDB/$tableName
                        rm ./.DBMS/$currentDB/.$tableName.meta 2>/dev/null
                        sleep 1 
                        echo "Table is Deleted Successfully ......."
                    else
                        echo "Delete operation cancelled"
                    fi
                else 
                    echo -e "$Red Error 404: Table Not Found $Reset"
                fi 
                export PS3="$currentDB>>"
                break
            done
        fi
        ;;  

    8 | "Exit" )
        echo "Your Choise is Exit ......."
        break 
        ;;
    *)
        echo "Your Choise is  ......." 
        echo -e "...........$Red Error ............$Reset"
        ;;
    esac 
done 