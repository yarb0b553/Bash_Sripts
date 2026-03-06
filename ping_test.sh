#!/bin/bash

# Function to print a table of hosts
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

    # Separator
    printf "\n%.0s-{1..60}\n" | tr ' ' '-'
    printf "\n"

    # Summary statistics
    printf "%-8s | %-25s | %s\n" "TESTED" "FAILED" "SUCCESSFUL"
    printf "%-8s | %-25s | %s\n" "$total" "$fail" "$success"

    # Technical info
    printf "\n"
    printf "Date: %s\n" "$(date '+%Y-%m-%d %H:%M:%S %Z')"
    printf "Server: $(hostname) | Uptime: $(uptime -p | sed 's/up //')"
    printf "\n"
}

# Default host list
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

# Argument parsing
if [ $# -eq 0 ]; then
    # No arguments – use default list
    run_ping "${default_hosts[@]}"
    exit 0
fi

# Flag processing
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--default)
            run_ping "${default_hosts[@]}"
            exit 0
            ;;
        -c|--custom)
            shift
            if [ -z "$1" ]; then
                echo "Error: after -c specify a comma-separated list of hosts"
                exit 1
            fi
            # Split by comma and trim spaces
            IFS=',' read -ra custom_hosts <<< "$1"
            # Remove possible spaces around hosts
            for i in "${!custom_hosts[@]}"; do
                custom_hosts[$i]=$(echo "${custom_hosts[$i]}" | xargs)
            done
            run_ping "${custom_hosts[@]}"
            exit 0
            ;;
        -h|--help)
            echo "Usage: pingtest [OPTIONS] [HOSTS...]"
            echo "  -d, --default       ping default host list"
            echo "  -c, --custom LIST   ping comma‑separated hosts (e.g. google.com,ya.ru)"
            echo "  -h, --help          show this help"
            echo ""
            echo "Examples:"
            echo "  pingtest                     # default list"
            echo "  pingtest -c google.com,ya.ru # custom list"
            echo "  pingtest google.com ya.ru     # also custom (as separate arguments)"
            exit 0
            ;;
        -*)
            echo "Unknown option: $1"
            echo "Use -h for help."
            exit 1
            ;;
        *)
            # If arguments don't start with '-', treat them as hosts
            # Collect all remaining arguments as hosts
            remaining_hosts=("$@")
            break
            ;;
    esac
done

# If we got here, hosts were passed as separate arguments
if [ ${#remaining_hosts[@]} -gt 0 ]; then
    run_ping "${remaining_hosts[@]}"
else
    # If no condition matched (e.g., after options no hosts), show help
    echo "Error: no hosts specified. Use -h for help."
    exit 1
fi
printf "\n"
