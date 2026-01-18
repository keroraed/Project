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

menu=("CreateTable" "ListAllTables" "SelectTable" "RemoveTable" "Exit" )
select variable in  ${menu[@]}
do 
    case $REPLY in
    1 | "CreateTable" ) 
        echo "Your Choise is CreateTable ......."
        
        read  -r -p "Enter Table Name :" input 
        input=$(tr " " "_" <<< $input)
        
        if [[ $input = [0-9]* ]];then   
            echo -e "$Red Error 201: Name of Table Can't Start Numbers $Reset"
        else 
            case  $input in
            _)
                echo -e "$Red Error 202: Name of Table Can't be _$Reset" 
            ;;
            +([a-zA-Z0-9_]))
                if [[ -f ./.DBMS/$currentDB/$input ]];then 
                    echo -e "$Red Error 203: Table Already Exist$Reset"  
                else 
                    echo "Wait Create Table ......"
                    touch ./.DBMS/$currentDB/$input
                    touch ./.DBMS/$currentDB/.$input.meta
                    sleep 1
                    if (($? == 0));then 
                        echo "Table is Created ......"
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
    3 | "SelectTable" )
        echo "Your Choise is SelectTable ......."
        #Display Table Content
        
        read  -r -p "Enter Table Name :" input 
        input=$(tr " " "_" <<< $input)
        
        if [[ $input = [0-9]* ]];then   
            echo -e "$Red Error 201: Name of Table Can't Start Numbers $Reset"
        else 
            case  $input in
            _)
                echo -e "$Red Error 202: Name of Table Can't be _$Reset" 
            ;;
            +([a-zA-Z0-9_]))
                if [[ -f ./.DBMS/$currentDB/$input ]];then 
                    echo "Table Content:"
                    echo "----------------"
                    if [[ -s ./.DBMS/$currentDB/$input ]];then
                        cat ./.DBMS/$currentDB/$input
                    else
                        echo -e "$Yellow Table is Empty $Reset"
                    fi
                else 
                    echo -e "$Red Error 404: Table Not Found $Reset"
                fi 
            ;;
            *)
                echo -e "$Red Error 204: Name of Table Contains Special Character : $Reset"  
            ;;
            esac
        fi
        
        ;;
    4 | "RemoveTable" )
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
                    echo "Wait delete Table ......."
                    rm ./.DBMS/$currentDB/$tableName
                    rm ./.DBMS/$currentDB/.$tableName.meta 2>/dev/null
                    sleep 1 
                    echo "Table is Deleted Successfully ......."
                else 
                    echo -e "$Red Error 404: Table Not Found $Reset"
                fi 
                export PS3="$currentDB>>"
                break
            done
        fi
        ;;  

    5 | "Exit" )
        echo "Your Choise is Exit ......."
        break 
        ;;
    *)
        echo "Your Choise is  ......." 
        echo -e "...........$Red Error ............$Reset"
        ;;
    esac 
done 