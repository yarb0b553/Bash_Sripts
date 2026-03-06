#!/bin/bash

# Цвета (опционально, можно убрать)
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Функция для вывода таблицы с хостами
run_ping() {
    local hosts=("$@")
    local total=0
    local success=0
    local fail=0

    printf "%-8s | %-25s | %s\n" "STATUS" "HOST" "PING (avg)"
    printf "%-8s-+-%-25s-+-%s\n" "--------" "-------------------------" "----------"

    for host in "${hosts[@]}"; do
        total=$((total + 1))
        output=$(ping -c 2 -q "$host" 2>&1)
        if [ $? -eq 0 ]; then
            avg=$(echo "$output" | tail -1 | awk -F'/' '{print $5}')
            printf "%-8s | %-25s | %5s ms\n" "OK" "$host" "$avg"
            success=$((success + 1))
        else
            printf "%-8s | %-25s | %s\n" "FAIL" "$host" "-"
            fail=$((fail + 1))
        fi
    done

    # Разделитель
    printf "\n%.0s-{1..60}\n" | tr ' ' '-'
    printf "\n"

    # Итоговая статистика
    printf "%-8s | %-25s | %s\n" "TESTED" "FAILED" "SUCCESSFUL"
    printf "%-8s | %-25s | %s\n" "$total" "$fail" "$success"

    # Техническая информация
    printf "\n"
    printf "Date: %s\n" "$(date '+%Y-%m-%d %H:%M:%S %Z')"
    printf "Server: $(hostname) | Uptime: $(uptime -p | sed 's/up //')"
}

# Список по умолчанию
default_hosts=(
    8.8.8.8
    1.1.1.1
    8.8.4.4
    77.88.8.8
    208.67.222.222
    google.com
    github.com
    cloudflare.com
    facebook.com
    instagram.com
    whatsapp.com
    youtube.com
    ya.ru
    yandex.ru
    vk.com
    ok.ru
    mail.ru
    rambler.ru
    rostelecom.ru
    megafon.ru
    mts.ru
    beeline.ru
    rbk.ru
    ria.ru
    kinopoisk.ru
    wildberries.ru
    ozon.ru
)

# Разбор аргументов
if [ $# -eq 0 ]; then
    # Без аргументов – используем список по умолчанию
    run_ping "${default_hosts[@]}"
    exit 0
fi

# Обработка флагов
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--default)
            run_ping "${default_hosts[@]}"
            exit 0
            ;;
        -c|--custom)
            shift
            if [ -z "$1" ]; then
                echo "Ошибка: после -c укажите список хостов через запятую"
                exit 1
            fi
            # Разделяем по запятой и убираем пробелы
            IFS=',' read -ra custom_hosts <<< "$1"
            # Удалим возможные пробелы вокруг хостов
            for i in "${!custom_hosts[@]}"; do
                custom_hosts[$i]=$(echo "${custom_hosts[$i]}" | xargs)
            done
            run_ping "${custom_hosts[@]}"
            exit 0
            ;;
        -h|--help)
            echo "Использование: pingtest [ОПЦИИ] [ХОСТЫ...]"
            echo "  -d, --default       пинговать хосты по умолчанию"
            echo "  -c, --custom СПИСОК пинговать хосты, перечисленные через запятую (например: google.com,ya.ru)"
            echo "  -h, --help          показать эту справку"
            echo ""
            echo "Примеры:"
            echo "  pingtest                     # список по умолчанию"
            echo "  pingtest -c google.com,ya.ru # кастомный список"
            echo "  pingtest google.com ya.ru     # тоже кастомный (как отдельные аргументы)"
            exit 0
            ;;
        -*)
            echo "Неизвестная опция: $1"
            echo "Используйте -h для справки."
            exit 1
            ;;
        *)
            # Если аргументы не начинаются с '-', считаем их хостами
            # Собираем все оставшиеся аргументы как хосты
            remaining_hosts=("$@")
            break
            ;;
    esac
done

# Если дошли сюда, значит были переданы хосты как отдельные аргументы
if [ ${#remaining_hosts[@]} -gt 0 ]; then
    run_ping "${remaining_hosts[@]}"
else
    # Если не сработало ни одно условие (например, после опций не было хостов), покажем help
    echo "Ошибка: не указаны хосты. Используйте -h для справки."
    exit 1
fi
