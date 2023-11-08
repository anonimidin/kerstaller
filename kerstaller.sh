#!/bin/bash

#---------------------MAIN--------------------------#
# Проверка наличия прав суперпользователя
if [ "$EUID" -ne 0 ]; then
  echo "[!] Без root-а никак "
  exit 1
fi

# Определение версии ядра через 
kernel_ver=$(lsb_release -r -s)
if [ -z "$kernel_ver" ]; then
  echo "[-] Не удалось определить версию ядра. Убедись что установлен пакет 'lsb-release'."
  exit 1
fi

#---------------------METHOD_1--------------------------#
method-hwe(){
  # Обновляем до последней версии через HWE
  echo "[!] Обновление до последней версии через HWE..."
  apt update -y && apt install --install-recommends -y linux-generic-hwe-$kernel_ver
  if [ $? -eq 0 ]; then
    echo "[+] Ядро успешно обновлен. Перезапусти компьютер для применения изменений."
    update-grub
  else 
    echo "[-] Произошла ошибка при обновлении ядра." && exit 1
  fi
}
#---------------------METHOD_2--------------------------#
method-image(){
  apt update -y
  apt install -y linux-image-$custom_kernel_ver linux-headers-$custom_kernel_ver linux-modules-$custom_kernel_ver
  if [ $? -eq 0 ]; then
  # Запретить TUI промпты
  #  export DEBIAN_FRONTEND=noninteractive 
  # Удаляет старые версии ядра, оставляет только установленную версию и последнее пакеты HWE    
  # yes | dpkg -l | grep "linux-image-.*-*" | grep -v "$custom_kernel_ver" | awk '{print $2}' | xargs apt-get purge -y
  # yes | dpkg -l | grep "linux-headers-.*-*" | grep -v "$custom_kernel_ver" | awk '{print $2}' | xargs apt-get purge -y
  # yes | dpkg -l | grep "linux-modules-.*-*" | grep -v "$custom_kernel_ver" | awk '{print $2}' | xargs apt-get purge -y
  echo "[+] Ядро версии $custom_kernel_ver успешно установлено и устаревшие версии удалены. Перезапусти компьютер для применения изменений."
  update-grub && apt-get autoremove -y && apt-get clean -y 
  echo && echo "[!] Сделай бэкап перед перезагрузкой" && sleep 1 && exit 1 
  else 
    echo "[-] Произошла ошибка при установке ядра версии $custom_kernel_ver."
  fi
}

#---------------------BANNER--------------------------#
echo
echo "  _  _______ ____  ____ _____  _    _     _     _____ ____   "  
echo " | |/ / ____|  _ \/ ___|_   _|/ \  | |   | |   | ____|  _ \  "
echo " | ' /|  _| | |   \___ \ | | / _ \ | |   | |   |  _| | |   | "
echo " | . \| |___|  _ < ___) || |/ ___ \| |___| |___| |___|  _ <  "
echo " |_|\_\_____|_| \_\____/ |_/_/   \_\_____|_____|_____|_| \_\ " 
echo -e " \n\t\t Автор: https://github.com/anonimidin"
echo 

#---------------------MENU--------------------------#
read -p 'Выбери вариант установления ядра:
[1] Обновить до последней версии через HWE пакет (linux-generic-hwe-*)
[2] Установить определенную версию ядра (linux-image-*)
[>] : ' choice 

#---------------------CHOICE_1--------------------------#
if [ "$choice" == "1" ]; then
  method-hwe
#---------------------CHOICE_2--------------------------#
elif [ "$choice" == "2" ]; then
  # Установка определенной версии ядра и проверка в наличии CVE (Common Vulnerabilities and Exposures) 
  read -p "[!] Введи имя и версию ядра для установки (*.*.*-*-* | например 6.2.0-36-generic): " custom_kernel_ver
  cve_url="https://nvd.nist.gov/vuln/search/results?form_type=Basic&results_type=overview&query=linux+kernel+$custom_kernel_ver"
  echo -e "Проверка доступных уязвимостей выберенной вами ядра в базе NVD\n"
  cve_ids=$(curl -L $cve_url | grep -oE 'CVE-[0-9]{4}-[0-9]{4,7}' | sort | uniq | column -x && echo)
  
  if [ -n "$cve_ids" ]; then
    echo "[!] Уязвимости доступны для версии ядра $custom_kernel_ver:"
    echo "$cve_ids"
    read -p "Установить выбранное ядро? (y/n): " cve_choice
    if [ "$cve_choice" == "y" ]; then
      method-image
    else echo "[!] Установка отменена."
    fi
  else echo -e "\n[+] Не найдены уязвимости в NVD, лучше гуглить.\n" && sleep 3 && method-image
  fi
else echo $'\x5B?\x5D \u041A\u043E\u0441\u043E\u0439' #XD 
fi
