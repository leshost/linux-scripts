#!/bin/bash

DAYS_AGO="${1:-7}"
USER_DIR="${2:-}"
ROOT_DIR="/home"

# Якщо передано ім'я користувача
if [[ -n "$USER_DIR" ]]; then
    ROOT_DIR="/home/$USER_DIR"
    if [[ ! -d "$ROOT_DIR" ]]; then
        echo -e "${RED}Каталог $ROOT_DIR не існує${NC}"
        exit 1
    fi
fi

# Файли логів
DATE_TAG=$(date +'%Y-%m-%d_%H-%M-%S')
LOG_FILE="log_${DATE_TAG}.txt"
TIME_LOG="log_time.txt"

# Кольори
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

# Функція виводу з кольором у консоль і без кольору в лог
log_echo() {
    local msg="$1"
    local color="${2:-$NC}"
    echo -e "${color}${msg}${NC}"
    echo -e "${msg}" >> "$LOG_FILE"
}

log_echo "===== Сканування $DATE_TAG =====" "$BLUE"
log_echo "🔍 Шукаємо PHP-файли:" "$BLUE"
log_echo " - змінені за останні $DAYS_AGO днів" "$BLUE"
log_echo " - або містять підозрілі виклики функцій" "$BLUE"
log_echo ""

SUSPICIOUS_COUNT=0
declare -A printed_files

PATTERN='\b(base64_decode|gzinflate|shell_exec|system|assert|preg_replace)\s*\('
echo "Запуск сканування: $DATE_TAG" >> "$TIME_LOG"

# Знайдені змінені файли
while IFS= read -r -d '' file; do
    if [[ -z "${printed_files[$file]}" ]]; then
        log_echo "📝 Змінений файл: $file" "$GREEN"
        printed_files[$file]=1
    fi
done < <(find "$ROOT_DIR" -type f -iname '*.php' -mtime -"$DAYS_AGO" -print0)

# Пошук підозрілих функцій
while IFS= read -r -d '' file; do
    if [[ -z "${printed_files[$file]}" ]]; then
        if grep -Eiq "$PATTERN" "$file"; then
            log_echo "" ""
            log_echo "⚠️ Підозрілий файл (функції): $file" "$RED"
            log_echo "----- Фрагмент підозрілого коду -----" "$YELLOW"
            grep -Ein -C 3 "$PATTERN" "$file" | sed 's/^/     | /' | tee -a "$LOG_FILE"
            log_echo "----- Кінець фрагменту -----" "$YELLOW"
            printed_files[$file]=1
            ((SUSPICIOUS_COUNT++))
        fi
    fi
done < <(find "$ROOT_DIR" -type f -iname '*.php' -print0)

# Підсумок
log_echo ""
log_echo "✅ Сканування завершено." "$BLUE"
log_echo "🔢 Підозрілих файлів (не змінених нещодавно): $SUSPICIOUS_COUNT" "$RED"
log_echo "📄 Лог збережено у файлі: $LOG_FILE" "$BLUE"
echo "" >> "$TIME_LOG"
