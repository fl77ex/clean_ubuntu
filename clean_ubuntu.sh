#!/bin/bash

# Проверка, установлен ли snap
if command -v snap &> /dev/null; then
  # Очистка старых версий snap пакетов (кроме системных, Firefox и Chrome)
  snap list | awk 'NR>1 {print $1}' | grep -vE 'core|snapd|firefox|chromium' | while read package; do
    # Удаление старых версий пакетов Snap (кроме текущей)
    snap versions $package | grep -E 'disabled|inactive' | awk '{print $1}' | xargs -n1 sudo snap remove --purge
  done
else
  echo "Snap не установлен, пропуск очистки Snap пакетов."
fi

# Очистка системы от ненужных пакетов
sudo apt autoremove -y
sudo apt autoclean -y

# Очистка кеша APT
sudo rm -rf /var/lib/apt/lists/*
sudo apt update

# Очистка кеша журналов
sudo journalctl --vacuum-time=3d

# Очистка временных файлов
sudo rm -rf /tmp/* /var/tmp/*

# Освобождение места за счет удаления старых ядер
sudo apt-get remove --purge $(dpkg -l | awk '/^ii  linux-(image|headers)-[0-9]/{print $2}' | grep -v $(uname -r | cut -d'-' -f1,2)) -y

# Принудительная очистка кеша системы
sudo sync && sudo sysctl -w vm.drop_caches=3

echo "Очистка завершена. Место освобождено."
