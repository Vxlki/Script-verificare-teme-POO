#! /bin/bash

# -h verifica si ofera informatii despre header
# -c verifica sursa

function warning_message {
    echo -e "\033[33m🚧 $1\033[0m"
}

function error_message {
    echo -e "\033[31m⛔ $1\033[0m"
}

function mesajcolorat1 {
    echo -e "\033[42m$1\033[0m"
}

function info_message {
    echo -e "\033[96mℹ️ $1\033[0m"
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
        info_message "Functii virtuale pure:"
        if [[ ${#vinterf[@]} -eq 0 ]]
        then
            mesajcolorat1 "Nu exista functii virtuale pure in $2."
        else
            for i in ${vinterf[@]}
            do
                mesajcolorat1 "-$i"
            done
        fi
        

        virtual=`cat $2 | egrep "virtual.*;"`
        if [[ ! -z $virtual ]]
        then
            declare -a vvirtual=()
            while IFS= read -r line; do
                class_name=$(echo "$line" | awk '{print $3}')
                vvirtual+=("$class_name")
            done <<< "$virtual"
        fi
        info_message "Functii virtuale:"
        if [[ ${#vvirtual[@]} -eq 0 ]]
        then
            mesajcolorat1 "Nu exista functii virtuale in $2."
        else
            for i in ${vvirtual[@]}
            do
                mesajcolorat1 "-$i"
            done
        fi

        concret_with_override=$(cat $2 | grep "() override")
        concret_without_override=$(cat $2 | grep "();" | grep -v "() override;" | grep -v "virtual" | tr ";" " ")
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
        echo ${vconcret[@]}
        info_message "Functii concrete:"
        if [[ ${#vconcret[@]} -eq 0 ]]
        then
            mesajcolorat1 "Nu exista functii concrete in $2."
        else
            for i in ${vconcret[@]}
            do
                mesajcolorat1 "-$i"
            done
        fi


    elif [[ $1 == "-c" ]]
    then
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
                    clase[$nrclase]=$cls
                    nrclase=$nrclase+1
                else
                    error_message "Fisierul $j inclus in $2 nu exista!"
                fi
            done
        done

        baseclass=`echo "$2" | cut -d. -f1`
        #echo $baseclass
        fct=`cat $2 | egrep "::.*\(\)" | cut -d: -f3`
        for i in $fct 
        do
            hfct=`cat "$baseclass.h" | egrep "$i"`
            if [[ -z $hfct ]]
            then
                error_message "Functia "$i" nu este definita!"
            fi
        done
        
    elif [[ $1 == "-t" ]]
    then

        if [[ ! -d $2 ]]; then
            error_message "Directorul nu exista!"
            exit 1
        fi

        declare -A classes

        for file in "$2"/*.h; do
            if [[ -f $file ]]; then
                class_name=$(grep -oP 'class\s+\K\w+' $file)
                base_class=$(grep -oP ':\s*public\s+\K\w+' $file)
                
                if [[ -n $class_name ]]; then
                    if [[ -n $base_class ]]; then
                        classes[$class_name]=$base_class
                    else
                        classes[$class_name]=""
                    fi
                fi
            fi
        done

        print_tree() {
            local class=$1
            local indent=$2
            local branch=$3

            echo "${indent}${branch}${class}"
            local sub_indent="${indent}    "
            local sub_branch="|-- "

            local first=true
            for derived_class in "${!classes[@]}"; do
                if [[ ${classes[$derived_class]} == $class ]]; then
                    if $first; then
                        first=false
                        print_tree "$derived_class" "$sub_indent" "├── "
                    else
                        print_tree "$derived_class" "$sub_indent" "└──"
                    fi
                fi
            done
        }

        for class in "${!classes[@]}"; do
            if [[ -z ${classes[$class]} ]]; then
                print_tree "$class" "" ""
            fi
        done
    elif [[ $1 == "-ch" ]] || [[ $1 == "-hc" ]]
    then
        source=$2
        header=$3

        if [[ -e $source ]] && [[ -e $header ]]
        then
            declare -a clase
            declare -i nrclase=0

            dependencies=`cat $header | egrep "#include"`
            for i in $dependencies
            do
                headers=`echo $i | egrep "[[:alnum:]]*\.h" | tr \"\<\> " " `
                for j in $headers
                do
                    if [[ -e $j ]]
                    then
                        jcls=`echo $j | cut -d. -f1`
                        cls=`cat $j | egrep class | cut -d" " -f2`
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
                used=`cat $header | egrep -v "#include" | egrep -m1 "$cls"`
                if [[ -z $used ]]
                then
                    warning_message "Clasa $cls nu este folosita in header ($header), desi este inclusa."
                fi
                used=`cat $source | egrep -v "#include" | egrep -m1 "$cls"`
                if [[ -z $used ]]
                then
                    warning_message "Clasa $cls nu este folosita in sursa ($source)."
                fi
            done

            #baseclass=`cat $header | egrep "class" | cut -d" " -f2`
            #echo $baseclass
            fct=`cat $source | egrep "::.*\(\)" | cut -d: -f3`
            for i in $fct 
            do
                hfct=`cat "$header" | egrep "$i"`
                if [[ -z $hfct ]]
                then
                    error_message "Functia "$i" nu este definita, dar este utilizata in sursa ($source)!"
                fi
            done
            
            fct=$(grep -oP '^\s*\w[\w\s]*\w+\s+\w+\s*\([^)]*\)\s*;' "$header" | sed -E 's/^\s*\w[\w\s]*\w+\s+(\w+)\s*\([^)]*\)\s*;/\1/')

            for i in $fct 
            do
                hfct=$(grep -P "^\s*[\w\s]*::\s*$i\s*\(" "$source")
                if [[ -z $hfct ]]
                then
                    warning_message "Functia '$i' este definita în header, dar nu este implementata in sursa."
                fi
            done
        else
            error_message "Sursa sau header-ul nu exista!"
            exit 1
        fi
    else
        echo vezi ca n ai pus parametrii corecti
    fi
else
    echo Fisierul $2 nu exista!
    return
fi