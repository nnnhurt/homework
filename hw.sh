#!/bin/bash
read -p "Введите название папки: " pictures
read -p "Введите желаемое количество фото: " cphoto
read -p "Нужно ли из фотографий делать гифку Y/n?: " choice
if [[ -z $pictures ]]; then #Проверка на ввод папки
    echo "Вы не ввели папку"
    exit 1
fi
if [[ -z $cphoto ]]; then # Проверка на ввод количества фоток 
    echo "Вы не ввели количество фотографий"
    exit 1 
fi

# Проверяем установлено ли утилита для обработки json из командной строки и устанавливаем если неь
if ! command -v jq &> /dev/null; then
    echo "jq не установлено. Устанавливаем..."
        sudo apt-get update && sudo apt-get install jq
fi
# Скачиваем утилиту которая из jpg формата в гиф
if ! command -v convert &> /dev/null; then # Проверяем устанавлена ли утилита convert
    echo "imagemagick не установлено. Устанавливаем..."
        sudo apt-get update && sudo apt-get install imagemagick
fi

if [[ -d $pictures ]]
then 
    echo "Папка для вывода найдена, продолжаем."

else
    echo "Папка для вывода не найдена, создаем"
    mkdir -p $pictures #Создание папки
fi

# Скачиваем столько чубриков, сколько захотел пользователь, которые сгенерировала нейросеть
for i in $(seq 1 $cphoto); do
  # Получаем ответ от сервера Random User API
  response=$(curl -s "https://randomuser.me/api/")
  if [[ -z $response ]]; then
    echo "Сервер не отвечает :( )" #Проверяем отвечает ли сервер
    exit 1
fi  
  # Из ответа забираем заданное количество фоток
  avatar=$(echo "$response" | jq -r '.results[0].picture.large')
  
  # Скачиваем изображения и сохраняем их
  curl -sS "$avatar" > "$pictures/$i.jpg"
done
# Меняем заданное количество фотографий в гифку
if [[ $choice != "n" ]]; then
read -p "Введите временной перерыв между фотографиями в гифке(в миллисекундах): " speed
if [[ -z $speed ]]; then #Проверка на ввод количества миллисекунд для перерыва между фотографиями
    echo "Вы не ввели количество миллисекунд"
    exit 1
fi
convert -delay $speed -loop 0 $pictures/* $pictures/users.gif #Используем параметр -delay утилиты convert, чтобы сделать перерыв между фото в гифке
fi



