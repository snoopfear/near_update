#!/bin/bash

# Перейти в директорию nearcore
cd $HOME/nearcore || exit 1

# Получить последний релиз с GitHub
NEWTAG=$(curl -s https://api.github.com/repos/near/nearcore/releases/latest | grep 'tag_name' | cut -d '"' -f 4)

echo "Последняя версия nearcore: $NEWTAG"

# Обновить репозиторий и переключиться на новую версию
git fetch && git checkout $NEWTAG

# Собрать проект
if make release; then
    echo "Сборка успешно завершена! Выполняем дополнительные команды..."
    cd $HOME && sudo systemctl stop neard
    rm /usr/local/bin/neard
    cd $HOME && cp "$HOME/nearcore/target/release/neard" /usr/local/bin/neard
    sudo systemctl restart neard
    journalctl -n 100 -f -u neard | ccze -A
    echo "Текущая версия NEAR:"
    neard --version
else
    echo "Ошибка при сборке nearcore!"
    exit 1
fi

echo "Обновление nearcore завершено!"
