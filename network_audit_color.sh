#!/bin/bash

# network_audit_color.sh
# Аналіз мережевих підключень із кольоровим підсвічуванням

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== [1] Активні мережеві підключення (крім localhost) ===${NC}"
ss -tunp | grep -v "127.0.0.1" | grep -v "::1" | while read line; do
    if echo "$line" | grep -qE ':21|:23|:8080|:4444|:6667'; then
        echo -e "${RED}$line${NC}"
    else
        echo -e "${GREEN}$line${NC}"
    fi
done

echo
echo -e "${YELLOW}=== [2] Слухаючі процеси на відкритих портах (крім localhost) ===${NC}"
ss -tuln | grep -v "127.0.0.1" | grep -v "::1" | while read line; do
    if echo "$line" | grep -q '*'; then
        echo -e "${RED}$line${NC}"
    else
        echo -e "${GREEN}$line${NC}"
    fi
done

echo
echo -e "${YELLOW}=== [3] Підозрілі процеси, що слухають усі інтерфейси (*) ===${NC}"
ss -tulnp | grep '*' | while read line; do
    echo -e "${RED}$line${NC}"
done

echo
echo -e "${YELLOW}=== [4] Підключення на незвичних портах (не 80/443/22/53/3306) ===${NC}"
ss -tunp | grep -vE '(:80|:443|:22|:53|:3306)' | grep -v "127.0.0.1" | grep ESTAB | while read line; do
    echo -e "${RED}$line${NC}"
done

echo
echo -e "${YELLOW}=== [5] Активні встановлені з'єднання (через lsof) ===${NC}"
sudo lsof -i -P -n | grep -i established | while read line; do
    echo -e "${GREEN}$line${NC}"
done

echo
echo -e "${YELLOW}=== Аудит завершено ===${NC}"
