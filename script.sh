#! /bin/bash

# -h verifica si ofera informatii despre header
# -c verifica sursa

function warning_message {
    echo -e "\033[33m🚧 $1\033[0m"
}

function error_message {
    echo -e "\033[31m⛔ $1\033[0m"
}


if [[ -e $2 ]]
then
    declare -a clase
    declare -i nrclase
    nrclase=0
    if [[ $1 == "-h" ]]
    then
        pragma=`cat $2 | egrep "#pragma once"`
        if [[ -z $pragma ]]
        then
            warning_message "Nu ai inclus #pragma once in header-ul $2"
        fi

        dependencies=`cat $2 | egrep "#include"`
        for i in $dependencies
        do
            headers=`echo $i | egrep "[[:alnum:]]*\.h" | tr \"\<\> " " `
            for j in $headers
            do
                if [[ -e $j ]]
                then
                    jcls=`echo $j | cut -d. -f1`
                    cls=`cat $j | egrep class | cut -d" " -f2`
                    if [[ $jcls != $cls ]]                            # afisez un warning daca numele header-ului este diferit de numele clasei
                    then
                        warning_message "Numele clasei ($cls) este diferit de numele header-ului ($j)."
                    fi
                    clase[$nrclase]=$cls
                    nrclase=$nrclase+1
                else
                    error_message "Fisierul $j inclus in $2 nu exista!"
                fi
            done
        done

        LIMIT=${#clase[@]}
        for ((i=0;i<$LIMIT;i++))
        do  
            cls=${clase[$i]}
            used=`cat $2 | egrep -v "#include" | egrep -m1 "$cls"`
            if [[ -z $used ]]
            then
                warning_message "Clasa $cls nu este folosita in $2, desi este inclusa."
            fi
        done


        lines=$(cat "$2" | egrep "class")

        extract_class_and_parents() {
            local line=$1
            local cls=$(echo $line | cut -d" " -f2)
            local parents=$(echo "$line" | sed -n 's/.*: *//p' | tr ',' '\n' | awk '{print $(NF)}')
            echo "$cls $parents"
        }

        print_tree() {
            local class=$1
            local indent=$2  

            if [ "$3" = true ]; then
                echo "${indent}\\-- ${class}"
                indent="${indent}    "
            else
                echo "${indent}|-- ${class}"
                indent="${indent}|   "
            fi

            parents=$(egrep "class\s\+${class}\s*:" "$4" | sed -n 's/.*: *//p' | tr ',' '\n' | awk '{print $(NF)}')
            count=$(echo "$parents" | wc -w)
            i=1

            for parent in $parents; do
                if [ $i -eq $count ]; then
                    print_tree "$parent" "$indent" true
                else
                    print_tree "$parent" "$indent" false
                fi
                ((i++))
            done
        }


        # Main
        i=1
        while IFS= read -r line; do
            class_and_parents=($(extract_class_and_parents "$line"))
            cls=${class_and_parents[0]}
            parents=${class_and_parents[@]:1}
            
            echo "${cls}"
            indent="   "
            
            count=$(echo "$parents" | wc -w)
            j=1
            
            for parent in $parents; do
                if [ $j -eq $count ]; then
                    print_tree "$parent" "$indent" true $2
                else
                    print_tree "$parent" "$indent" false $2
                fi
                ((j++))
            done
            echo
            ((i++))
        done <<< "$lines"

        #vezi daca e interfata, clasa abstracta sau clasa concreta
        interf=`cat $2 | egrep "virtual.*=.*0"`
        if [[ ! -z $interf ]]
        then
            declare -a vinterf=()
            while IFS= read -r line; do
                class_name=$(echo "$line" | awk '{print $3}')
                vinterf+=("$class_name")
            done <<< "$interf"
        fi
        echo interf
        echo "${vinterf[@]}"

        virtual=`cat $2 | egrep "virtual.*;"`
        if [[ ! -z $virtual ]]
        then
            declare -a vvirtual=()
            while IFS= read -r line; do
                class_name=$(echo "$line" | awk '{print $3}')
                vvirtual+=("$class_name")
            done <<< "$virtual"
        fi
        echo virtual
        echo "${vvirtual[@]}"

        concret_with_override=$(cat $2 | grep "() override")
        concret_without_override=$(cat $2 | grep "();" | grep -v "() override;" | grep -v "virtual")
        declare -a vconcret=()
        if [[ ! -z $concret_with_override ]]
        then
            while IFS= read -r line; do
                class_name=$(echo "$line" | awk '{print $2}')
                vconcret+=("$class_name")
            done <<< "$concret_with_override"
        fi
        if [[ ! -z $concret_without_override ]]
        then
            while IFS= read -r line; do
                class_name=$(echo "$line" | awk '{print $2}')
                vconcret+=("$class_name")
            done <<< "$concret_without_override"
        fi
        echo concret
        echo "${vconcret[@]}"


    elif [[ $1 == "-c" ]]
    then
        dependencies=`cat $2 | egrep "#include"`
        headers=`echo $i | egrep "[[:alnum:]]*\.h" | tr \"\<\> " " `
            for j in $headers
            do
                if [[ -e $j ]]
                then
                    jcls=`echo $j | cut -d. -f1`
                    cls=`cat $j | egrep class | cut -d" " -f2`
                    if [[ $jcls != $cls ]]                            # afisez un warning daca numele header-ului este diferit de numele clasei
                    then
                        warning_message "Numele clasei ($cls) este diferit de numele header-ului ($j)."
                    fi
                    clase[$nrclase]=$cls
                    nrclase=$nrclase+1
                else
                    error_message "Fisierul $j inclus in $2 nu exista!"
                fi
            done
    else
        echo vezi ca n ai pus parametrii corecti
    fi
else
    echo Fisierul $2 nu exista!
    return
fi