#! /usr/bin/bash

path=/home/leandro/UFMS/Monitoria/T1

if [[ "$1" = "-r" ]]; then 
    filename=$2
else
    filename=$1
fi

log_file=$path/Logs/$filename.log

remove_output=false

# Set the color variable
bg_red='\033[0;41m'
bg_green='\033[0;42m'
bg_yellow='\x1B[43m'
# Clear the color after that
clear='\033[0m'

while getopts "r" flag;
do
    if [[ "$flag" = "r" ]]; then
        remove_output=true
    fi
done

shift $((OPTIND-1))

function run_test() {
    test_name="$1"
    test_number="$2"
    remove_file=$3
    
    if [[ "$test_name" = "exemplo" ]]; then
        real_test_number="$2"
    else
        real_test_number="$(($test_number + 3))"
    fi

    echo >> $log_file
    echo "------------------------------------------" >> $log_file
    echo -e "\tRodando caso de teste $real_test_number..."
    echo "Teste #$real_test_number" >> $log_file
    echo >> $log_file

    $path/Assignments/Executable/$filename.o < $path/Solution/$test_name.$test_number.in > $path/$test_name.$test_number.out

    echo -e "\t* Sem espaço" >> $log_file
    diffWhithoutWhitespace=$(diff -w $path/Solution/$test_name.$test_number.sol $path/$test_name.$test_number.out)

    if [[ -z $diffWhithoutWhitespace ]]; then
        echo -e "\t  PASSOU!" >> $log_file
        echo >> $log_file
    else
        echo -e "\t\t$diffWithoutWhitespace" >> $log_file
        echo >> $log_file
    fi

    echo -e "\t* Com espaço" >> $log_file
    diffWhithWhitespace=$(diff $path/Solution/$test_name.$test_number.sol $path/$test_name.$test_number.out)

    if [[ -z $diffWhithWhitespace ]]; then
        echo -e "\t  PASSOU!" >> $log_file
        echo >> $log_file
    else
        echo -e "\t\t$diffWhithWhitespace" >> $log_file
        echo >> $log_file
    fi

    if [[ "$remove_file" = true ]]; then
        rm $path/$test_name.$test_number.out
    fi;

    echo "------------------------------------------" >> $log_file
}

echo "*******************************************"
echo "************** T1 - CORREÇÃO **************"
echo "*******************************************"

echo

echo "Criando log de correção..."

touch $log_file

echo

echo "Compilação em andamento..."

errors=$(gcc $path/Assignments/Source/$1.c -Wall -pedantic --std=c99 -o $path/Assignments/Executable/$1.o 2>&1)

echo "------------------------------------------" > $log_file

echo >> $log_file

echo "COMPILAÇÃO" >> $log_file

if  [[ -z $errors ]]; then
    echo "OK!" >> $log_file
else
    echo -e "${bg_red}Erro de compilação!${clear}"
    echo "$errors" >> $log_file
fi

echo >> $log_file

echo "------------------------------------------" >> $log_file

echo -e "Compilação finalizada."

echo

if  [[ "-z $errors" ]]; then
    echo "Verificação de casos de teste iniciada..."

    for number in 1 2 3
    do
        run_test "exemplo" $number $remove_output
    done

    for number in 1 2 3 4 5 6 7
    do
        run_test "entrada" $number $remove_output
    done

    echo -e "Verificação de casos de teste encerrada."

    echo

    if [[ "$remove_output" = true ]]; then
        echo -e "${bg_yellow}Arquivos de saída removidos!${clear}"

        echo
    fi;
else
    echo "Verificação de casos de teste abortada."

    echo
fi

echo -e "${bg_green}Verifique o log de correção!${clear}"