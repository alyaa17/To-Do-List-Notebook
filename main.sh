#!/bin/bash
. ./functions.sh

password_file=password.txt

if [[ ! -s $password_file ]]
then
    echo "Привет! Я твой новый помощник в планировании ежедневных дел :)"
    echo "Введи пароль, который будем использовать для доступа к твоим планам" 
    read -sp "Пароль: " password
    if [[ -n $password ]]
    then
        echo
        read -sp "Повтори ввод пароля: " second_password
        if [[ $password -eq second_password ]]
        then
            hash_pswd=$(hash_password $password)
        else 
            echo 
            echo "Пароли не совпадают! Повтори регистрацию."
            sleep 1
            exit
        fi    
        echo $hash_pswd >> $password_file
        echo "Отлично, пароль для входа создан, не забудь его!" 
    else
        echo "Пароль не может быть пустым! Повтори настройку"    
        exit
    fi   
    echo "Выбирай из списка что будем делать" 
else
    read -sp "Привет! Введи пароль доступа: " password
    if [[ $(hash_password $password) == $(cat $password_file) ]]
    then
        echo "Что сегодня будем делать?"
    else
        echo "Пароль не подходит, попробуй повторить"
        exit
    fi    
fi

while true
do
    # прислать напоминания
    remind 

    array_list=("1. Добавить новую задачу" "2. Редактировать планы" "3. Посмотреть мои задачи" "4. Выйти")
    for item in "${array_list[@]}" 
    do
        echo $item
    done

    read -p "Напиши номер элемента в списке: " list_choice

    clear
    case $list_choice in
        "1")   
            add_task
            clear;;
        "2")
            edit_tasks
            clear;;
        "3")
            tasks_output
            echo "--------------------------------";;
        "4")
            exit;;
        *)
            echo "Неправильная цифра, повтори ввод" 
    esac      
done
