function hash_password {
    echo $1 | sha256sum | awk '{print $1}'
}

function add_task {
    read -p "Задача: " task
    read -p "Дополнительная информация: " information

    echo "Выбери список, в который хочешь добавить задачу:"
    # Вывод всех файлов в папке tasks
    folder_path="tasks"
    c=1
    for item in "$folder_path"/*
    do
        echo "$c. $(basename "$item")"
        c=$(($c+1))
    done
    echo "$c. Добавить в новый список"
    echo "$(($c+1)). Не добавлять в список"
    
    f=0
    while [ $f == 0 ]
    do
        read -p "Введи номер элемента в списке: " list_choice
        if [[ $list_choice -eq $c ]] # добавление нового списка
        then
            read -p "Введи название нового списка: " name_list
            touch "$folder_path/$name_list"
            echo "$task|$information" >> "$folder_path/$name_list"
            f=1
        elif [[ $list_choice -eq $(($c+1)) ]] # добавление в список all_tasks
        then
            echo "$task|$information" >> "$folder_path/all_tasks"
            f=1
        elif [[ $list_choice -ge 0 && $list_choice -lt $c ]]
        then
            # добавление в нужный список
            c=1
            for item in "$folder_path"/*
            do
                if [[ $list_choice -eq $c ]]
                then
                    echo "$task|$information" >> "$item"
                fi
                c=$(($c+1))
            done
            f=1
        else
            echo "Нет такого списка"    
        fi
    done

    echo "Хочешь поставить напоминание?"
    echo "1. Да"
    echo "2. Нет"
    read -p "Введи номер элемента в списке: " list_choice
    # добавление напоминания
    if [[ $list_choice -eq 1 ]] 
    then
        flag=0
        while [ $flag == 0 ]
        do
            read -p "Введи дату в формате день.месяц: " remind_day

            if [[ $remind_day == *"."* ]] # проверка на наличие разделителя
            then
                IFS="."
                read -r day month <<< "$remind_day"
                # проверка на корректность введенного дня и месяца
                if [[ $day =~ ^[1-9][0-9]*$ && 1 -le $day && $day -le 31 && $month =~ ^[1-9][0-9]*$ && 1 -le $month && $month -le 12 ]]
                then
                    flag=1       
                else
                    echo "Неверные значения. Повтори ввод"
                fi    
            else
                echo "Неверный формат. Повтори ввод"
            fi
        done
        flag=0
        while [ $flag == 0 ]
        do
            read -p "Введи время в формате часы.минуты: " remind_time

            if [[ $remind_time == *"."* ]] # проверка на наличие разделителя
            then
                IFS="."
                read -r hour minute <<< "$remind_time"
                # проверка на корректность введенного часа и минуты
                if [[ $hour =~ ^[0-9]+$ && 0 -le $hour && $hour -le 24 && $minute =~ ^[1-9][0-9]*$ && 0 -le $minute && $minute -le 59 ]]
                then
                    echo "$minute.$hour.$day.$month | $task | $information" >> remind.txt
                    flag=1       
                else
                    echo "Неверные значения. Повтори ввод"
                fi
            else
                echo "Неверный формат. Повтори ввод"
            fi       
        done

    # не ставим напоминание
    elif [[ $list_choice -eq 2 ]]
    then
        echo 2 >> /dev/null
    # неверный формат    
    else 
        echo "Значит, не очень хочешь"
    fi           
}

function edit_tasks {
    # Вывод всех файлов в папке 
    folder_path="tasks"
        for item in "$folder_path"/*
        do
            echo "$(basename "$item")"
        done
    read -p "Напиши название списка, в котором хочешь редактировать задачи: " file_name
    file="/Users/alina/programming/planner/tasks/$file_name"
    echo "--------------------------------"
    if [ -f "$file" ]
        then
            c=1
            # считывание файла по-строчно
            while IFS= read -r line
            do
                IFS='|'
                read -r task information <<< "$line"
                echo "$c. Задача: $task"
                c=$(($c+1))
            done < "$file"
            # если список пустой, выход из функции
            if [ ! -s $file ]
            then
                echo "Этот список пустой"
                sleep 1
                return
            fi    
            read -p "Напиши номер задачи, которую хочешь изменить: " num_task
            c=1
            f=0
            # пока не закончится список задач или не найдем нужную
            while IFS= read -r line && [ $f == 0 ]
            do  
                if [[ $c == $num_task ]]
                then
                    f=1
                    IFS='|'
                    read -r task information <<< "$line"
                    echo "--------------------------------"
                    echo "Задача: $task"
                    echo "Пояснение: $information"
                    echo "--------------------------------"
                fi 
                c=$(($c+1))
            done < "$file"   
            if [[ $f == 0 ]]
            then
                echo "Нет такой задачи"
                sleep 1
                return
            fi   
            # Вывод списка действий над задачей     
            echo "1. Изменить название"
            echo "2. Изменить пояснение"
            echo "3. Удалить задачу"
            echo "4. Ничего не делать"
            read -p "Выбери действие: " act
            case $act in
                "1")   
                    c=1
                    read -p "Напишите новое название для задачи: " new_task
                    while IFS= read -r line
                    do
                        if [[ $c == $num_task ]]
                        then
                            new_line="$new_task|$information"
                            # замена строки на новую с другим названием задачи
                            sed -i '' "${c}s/.*/$new_line/" "$file"
                        fi    
                        c=$(($c+1))
                    done < "$file";;
                "2")
                    c=1
                    read -p "Напишите новое пояснение к задаче: " new_information
                    while IFS= read -r line
                    do
                        if [[ $c == $num_task ]]
                        then
                            new_line="$task|$new_information"
                            # замена строки на новую с другой доп. информацией
                            sed -i '' "${c}s/.*/$new_line/" "$file"
                        fi    
                        c=$(($c+1))
                    done < "$file";;
                "3")
                    # Удаление строки (задачи)
                    sed -i "" "/$task|$information/d" "$file"
                    echo "Удалил задачу $task";;
                "4")
                    echo "Ничего не делаем" >> /dev/null;;
                *)
                    echo "Неправильная цифра, повтори ввод";;
            esac       
    else
        echo "Файл $file не найден"
    fi
}

function tasks_output {
    echo "1. Вывести список всех задач"
    echo "2. Вывести конкретный список"
    echo "3. Вывести задачи из всех списков"
    read -p "Выбери элемент в списке: " list_choice
    case $list_choice in
        # вывод задач из списка all_tasks
        "1")   
            echo "--------------------------------"
            echo "Список: all_tasks"
            echo "--------------------------------"
            file_all_tasks="/Users/alina/programming/planner/tasks/all_tasks"
            while IFS= read -r line
            do
                IFS='|'
                read -r task information <<< "$line"
                echo "Задача: $task"
                echo "Пояснение: $information"
                sleep 1
            done < "$file_all_tasks";;
        # вывод задач из конкретного списка   
        "2")
            folder_path="tasks"
            for item in "$folder_path"/*
            do
                echo "$(basename "$item")"
            done

            # выбор списка
            read -p "Введи название списка, который хочешь вывести: " file_name
            file="/Users/alina/programming/planner/tasks/$file_name"
            echo "--------------------------------"
            echo "Список: $file_name"
            echo "--------------------------------"
            # если такой список существует, выводим задачи
            if [ -f "$file" ]
            then
                while IFS= read -r line
                do
                    IFS='|'
                    read -r task information <<< "$line"
                    echo "Задача: $task"
                    echo "Пояснение: $information"
                    sleep 1
                done < "$file"
            else
                echo "Файл $file не найден"
            fi;;
        # вывод всех задач
        "3")
            folder_path="/Users/alina/programming/planner/tasks"
            # проход по всем файлам папки tasks
            for file in "$folder_path"/*
            do
                echo "Список: $(basename "$file")"
                echo "--------------------------------"
                while IFS= read -r line
                    do
                        IFS='|'
                        read -r task information <<< "$line"
                        echo "Задача: $task"
                        echo "Пояснение: $information"
                        # промежуток между выводами задач - 1 сек
                        sleep 1
                    done < "$file"
                echo "--------------------------------"
            done;;
        *)
            echo "Неправильная цифра" 
    esac   
}

function remind {
    file_remind="remind.txt"
    while IFS= read -r line
    do
        # получение текущей даты
        current_date=$(date +"%M.%H.%d.%m")
        IFS='.' 
        read -r cur_minute cur_hour cur_day cur_month <<< "$current_date"
        # удаление нулей в начале дат
        cur_minute="${cur_minute#0}"
        cur_hour="${cur_hour#0}"
        cur_day="${cur_day#0}"
        cur_month="${cur_month#0}"
        total_cur_date=$(($cur_minute+$cur_hour*60+$cur_day*24*60+$cur_month*30*24*60))

        read -r rem_minute rem_hour rem_day other <<< "$line"
        IFS='|'
        read -r rem_month task information <<< "$other"
        total_rem_date=$((rem_minute + rem_hour * 60 + rem_day * 24 * 60 + rem_month * 30 * 24 * 60))

        if [[ $total_cur_date -ge $total_rem_date ]]
        then
            file="/Users/alina/programming/planner/remind.txt"
            #отправка напоминаний
            osascript -e "display notification \"$information\" with title \"$task\""
            # удаление отправленных напоминаний
            sed -i "" "/$rem_minute.$rem_hour.$rem_day.$rem_month|$task|$information/d" "$file_remind"
        fi
    done < "$file_remind"
}
