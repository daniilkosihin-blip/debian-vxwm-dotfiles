#!/bin/bash
# Скрипт автоматического развертывания окружения vxwm для Debian

# Прерывать скрипт при возникновении любой ошибки
set -e

echo "=== [1/6] Обновление системы и установка базовых утилит ==="
sudo apt update
sudo apt install -y git build-essential x11-xserver-utils xinit \
alacritty suckless-tools libx11-dev libxft-dev libxinerama-dev \
fontconfig libfontconfig1-dev

echo "=== [2/6] Клонирование и сборка оконного менеджера vxwm ==="
cd ~
if [ -d ~/vxwm ]; then rm -rf ~/vxwm; fi
git clone https://codeberg.org/wh1tepearl/vxwm
cd ~/vxwm

# Безопасное копирование вашего кастомного config.h
if [ -f ~/debiandots/vxwmconf/config.h ]; then
    rm -f config.h
    cp ~/debiandots/config.h ~/vxwm/config.h
    echo "-> Кастомный config.h для vxwm успешно применен."
else
    echo "-> Внимание: Файл ~/debiandots/vxwmconf/config.h не найден. Будет собран конфиг по умолчанию."
fi

# Компиляция и установка
make
sudo make clean install

echo "=== [3/6] Установка сборочных зависимостей для Picom ==="
sudo apt install -y meson ninja-build libx11-dev libxext-dev libxcb1-dev \
libxcb-damage0-dev libxcb-xfixes0-dev libxcb-shape0-dev libxcb-render-util0-dev \
libxcb-render0-dev libxcb-randr0-dev libxcb-composite0-dev libxcb-image0-dev \
libxcb-present-dev libxcb-xinerama0-dev libxcb-glx0-dev libpixman-1-dev \
libdbus-1-dev libconfig-dev libgl-dev libegl-dev libpcre2-dev libev-dev \
libuthash-dev libepoxy-dev libx11-xcb-dev libxcb-util-dev

echo "=== [4/6] Клонирование и сборка композитного менеджера Picom ==="
cd ~
if [ -d ~/picom ]; then rm -rf ~/picom; fi
git clone https://github.com/yshui/picom
cd ~/picom

meson setup --buildtype=release build
ninja -C build
sudo ninja -C build install

echo "=== [5/6] Применение пользовательских конфигураций (Дотфайлы) ==="
# Настройка Picom
mkdir -p ~/.config/picom
if [ -d ~/debiandots/picom/animations ]; then
    cp -r ~/debiandots/picom/animations ~/.config/picom/
fi
if [ -f ~/debiandots/picom/picom.conf ]; then
    cp ~/debiandots/picom/picom.conf ~/.config/picom/
fi


# Настройка .xinitrc для запуска графики
if [ -f ~/debiandots/.xinitrc ]; then
    cp ~/debiandots/.xinitrc ~/
    chmod +x ~/.xinitrc
    echo "-> .xinitrc скопирован в домашнюю директорию."
fi

echo "=== [6/6] Очистка временных файлов сборки ==="
cd ~
rm -rf ~/vxwm ~/picom
echo "-> Директории сборки ~/vxwm и ~/picom успешно удалены."

echo "======================================================="
echo " Установка успешно завершена!"
echo " Запуск графического окружения..."
echo "======================================================="
sleep 2

startx
