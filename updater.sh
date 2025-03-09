#!/bin/bash

# Перейти в директорию nearcore
cd $HOME/nearcore || { echo "Ошибка: директория nearcore не найдена"; exit 1; }

# Получить последний релиз с GitHub
NEWTAG=$(curl -s https://api.github.com/repos/near/nearcore/releases/latest | grep 'tag_name' | cut -d '"' -f 4)

if [ -z "$NEWTAG" ]; then
    echo "Ошибка: не удалось получить последнюю версию nearcore"
    exit 1
fi

echo "Последняя версия nearcore: $NEWTAG"

# Обновить репозиторий и переключиться на новую версию
git fetch && git checkout "$NEWTAG"

# Сборка проекта (имитируем ручной ввод команды)
cd $HOME/nearcore
make release

# Проверяем, успешно ли прошла сборка
if [ $? -eq 0 ]; then
    echo "Сборка успешно завершена! Выполняем дополнительные команды..."
    cd $HOME && sudo systemctl stop neard
    rm /usr/local/bin/neard
    cp "$HOME/nearcore/target/release/neard" /usr/local/bin/neard
    sudo systemctl restart neard
    echo "Текущая версия NEAR:"
    neard --version
    journalctl -n 100 -f -u neard | ccze -A
else
    echo "Ошибка при сборке nearcore!"
    exit 1
fi

echo "Обновление nearcore завершено!"
