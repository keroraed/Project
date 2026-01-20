#COMMENT
LC_COLLATE=C 
shopt -s extglob 
export PS3="Kero,BeroDB>>"

# Create DB ==>mkdir 
# List All DB ==>ls Folders
# Connect DB ==>cd ==> Menu  
# Remove DB ==> rm -r folder
# Exit

Reset="\033[0m"
Red="\033[31m"
Green="\033[32m"
Yellow="\033[33m"
Blue="\033[34m"
Cyan="\033[36m"


if [[ ! -d ./.DBMS ]];then 
    echo "Create .DBMS Folder .........."
    mkdir ./.DBMS
    sleep 1 
fi 





menu=("CreateDB" "ListAllDB" "ConnectDB" "RemoveDB" "Exit" )
select variable in  ${menu[@]}
do 
    # menu< 1 #REPLY 1  #Variable  CreateDB
    # menu< 1 #REPLY CreateDB  #Variable 
    # menu< 7 #REPLY 7   #Variable 
     
    case $REPLY in 
    1 | "CreateDB" ) 
        echo "Your Choise is CreateDB ......."
        #Take Name of DB 
        #Check DB Name is Valid 
        #DB Create Already 
        #Create DB 
        if [[ ! -d ./.DBMS ]] ;then 
            # echo -e  "$Red Error 106 : DBMS System Failure ... $Reset"
            # break
            mkdir ./.DBMS
        fi
        read  -r -p "Enter your DB Name :" input 
        input=$(tr " " "_" <<< $input)
        if [[ $input = [0-9]* ]];then   
            echo -e "$Red Error 101: Name of DB Can't Start Numbers $Reset"
        else 
            case  $input in
            _)
                echo -e "$Red Error 102: Name of DB Can't be _$Reset" 
            ;;
            +([a-zA-Z0-9_]))
                if [[ -d ./.DBMS/$input ]];then 
                    echo -e "$Red Error 103: Name of DB Already Exist$Reset"  
                else 
                    echo "Wait Create DB ......"
                    mkdir ./.DBMS/$input
                    sleep 1
                    if (($? == 0));then 
                        echo "DB is Created ......"
                    else 
                        echo "DB Error ??? 164"
                    fi 
                fi 
            ;;
            *)
            echo -e "$Red Error 104: Name of Folder Contains Special Character : $Reset"  
            ;;
            esac
        fi 

    ;;
    2 | "ListAllDB")
        #"List All DB"
        echo "Your Choise is  List All DB ......."
        if [[ ! -d ./.DBMS ]] ;then 
            # echo -e  "$Red Error 106 : DBMS System Failure ... $Reset"
            # break
            mkdir ./.DBMS
        fi 
        ls -F ./.DBMS | grep '/' | tr -d '/'
        data=$(ls -F ./.DBMS | grep '/' | tr -d '/')
        if [[ -z $data ]] ;then 
            echo -e "$Red Error 107 : DBMS Empty No DataBases for Listing $Reset"
        fi 

    ;;
    3 | "ConnectDB")
        #"Connect DB"
        echo "Your Choise is ConnectDB ......."
         if [[ ! -d ./.DBMS ]] ;then 
            # echo -e  "$Red Error 106 : DBMS System Failure ... $Reset"
            # break
            mkdir ./.DBMS
        fi
        read  -r -p "Enter your DB Name :" input #mina nagy
        input=$(tr " " "_" <<< $input) #mina_nagy
        if [[ $input = [0-9]* ]];then   
            echo -e "$Red Error 101: Name of DB Can't Start Numbers $Reset"
        else 
            case  $input in
            _)
                echo -e "$Red Error 102: Name of DB Can't be _$Reset" 
            ;;
            +([a-zA-Z0-9_]))
                if [[ -d ./.DBMS/$input ]];then 
                    #Connect DB
                    export CURRENT_DB="$input"
                    export PS3="$input>>"
                    source ./table.sh
                    export PS3="KeroDB>>"
                else 
                    echo -e "$Red Error 404 : Name DB Not Found $Reset"
                fi 
            ;;
            *)
            echo -e "$Red Error 104: Name of Folder Contains Special Character : $Reset"  
            ;;
            esac
        fi 


    ;;
    4 | "RemoveDB")
        #"Remove DB"
        echo "Your Choise is RemoveDB ......."
        export PS3="RemoveDB>>"
        select dbName in $(ls -F ./.DBMS | grep '/' | tr -d '/')
        do   
            if [[ -n $dbName && -d ./.DBMS/$dbName ]];then 
                echo "Wait delete DB ......."
                rm -r ./.DBMS/$dbName
                sleep 1 
                echo "DB is Deleted Secussfuly  ......."
            else 
                echo -e "$Red Error 404 : Name DB Not Found $Reset"

            fi 
            export PS3="KeroDB>>"
            break
        done 
    ;;
    5 | "Exit")
        #"Exit"
        echo "Your Choise is Exit ......." 
          break
    ;;
    *)
        echo "Your Choise is  ......." 
        echo -e "$Red........... Error ............ $Reset"
    ;;
    esac 

done 
