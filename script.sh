#! /bin/bash

# -h verifica si ofera informatii despre header
# -c verifica sursa

function error_message {
    echo -e "\033[33m⚠ $1\033[0m"
}

if [[ $1 == "-h" ]]
then
    declare -a clase
    declare -i nrclase
    nrclase=0
    if [[ -e $2 ]]
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
                    if [[ $jcls != $cls ]]                            # afisez un warning daca numele header-ului este diferit de numele clasei
                    then
                        error_message "Numele clasei ($cls) este diferit de numele header-ului ($j)."
                    fi
                    clase[$nrclase]=$cls
                    nrclase=$nrclase+1
                else
                    error_message "Fisierul $j nu exista!"
                fi
            done
        done

        LIMIT=${#clase[@]}
        for ((i=0;i<$LIMIT;i++))
        do  
            cls=${clase[$i]}
            used=`cat $2 | egrep -v "#include" | egrep "$cls"`
            if [[ -n $used ]]
            then
                echo da
            else
                error_message "Clasa $cls nu este folosita in $2, desi este inclusa."
            fi
        done
    else
        echo Fisierul $2 nu exista!
        return
    fi
elif [[ $1 == "-c" ]]
then
    echo da
else
    echo vezi ca n ai pus parametrii corecti
fi