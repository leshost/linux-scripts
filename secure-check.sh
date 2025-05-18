#!/bin/bash

# secure-check.sh
# Автоматична перевірка системи на шкідливе ПЗ, підозрілі файли та вразливості

echo "=== [1] ПЕРЕВІРКА СПІЛЬНОЇ ПАМ'ЯТІ (SHM) ==="
ipcs -m | awk 'NR>3 && $5 > 10000000 {print}' || echo "OK"

echo
echo "=== [2] ПЕРЕВІРКА /dev НА ПІДОЗРІЛІ ФАЙЛИ ==="
sudo find /dev -type f ! -name "*socket*" -exec ls -l {} \; 2>/dev/null

echo
echo "=== [3] ПРИХОВАНІ ФАЙЛИ В /dev ==="
sudo find /dev -name ".*" -ls 2>/dev/null

echo
echo "=== [4] ПЕРЕВІРКА /etc/passwd НА НЕЗВИЧАЙНИХ КОРИСТУВАЧІВ ==="
awk -F: '$3 >= 1000 && $1 != "nobody" {print}' /etc/passwd

echo
echo "=== [5] КОРИСТУВАЧІ З ПРАВАМИ СУПЕРКОРИСТУВАЧА ==="
getent group sudo | cut -d: -f4

echo
echo "=== [6] ПЕРЕВІРКА /etc НА ЗМІНИ У ФАЙЛАХ КОРИСТУВАЧІВ ==="
stat /etc/passwd | grep Modify
stat /etc/group | grep Modify

echo
echo "=== [7] ЗАПУЩЕНІ ПРОЦЕСИ З /tmp /dev /var ==="
ps -eo pid,cmd | grep -E '/tmp|/dev|/var' | grep -v grep

echo
echo "=== [8] ROOTKIT HUNTER (rkhunter) ==="
sudo rkhunter --check --sk --nocolors | grep -E "Warning|Found|infected"

echo
echo "=== [9] CHKROOTKIT ==="
sudo chkrootkit | grep -v "not found" | grep -v "not infected"

echo
echo "=== [10] ВІДКРИТІ ПОРТИ З НЕВІДОМИМИ ПРОЦЕСАМИ ==="
sudo ss -tulnp | grep -vE "sshd|cupsd|avahi|systemd|127.0.0.1|localhost"

echo
echo "=== [11] СТОРОННІ ПАКЕТИ pip, не пов’язані з системою ==="
pip list --format=freeze | grep -viE "debian|apt|pygobject|cups|nacl|crypt|sqlalchemy|psutil|numpy|requests|beautifulsoup|lxml|urllib3|idna|certifi|pyyaml|colorama|html5lib"

echo
echo "=== ✅ ПЕРЕВІРКА ЗАВЕРШЕНА ==="
