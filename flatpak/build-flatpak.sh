#!/bin/bash

set -e

echo "=== Проверка зависимостей ==="

if ! command -v flatpak &> /dev/null; then
    echo "Flatpak не установлен. Установите: sudo apt install flatpak flatpak-builder"
    exit 1
fi

export PATH="/storage/programs/flutter_sdk_3.29.2/bin:$PATH"
if ! command -v flutter &> /dev/null; then
    echo "Flutter не найден. Проверьте путь к SDK"
    exit 1
fi

echo "=== Сборка Flutter приложения ==="
cd ..
flutter clean
flutter pub get
flutter build linux --release
cd flatpak

echo "Flutter приложение собрано"

echo "=== Установка runtime ==="
flatpak install flathub org.freedesktop.Platform//25.08 -y || true
flatpak install flathub org.freedesktop.Sdk//25.08 -y || true

echo "=== Сборка Flatpak пакета ==="
flatpak-builder --force-clean build-dir ru.yzhjdjq.sws.yaml

echo "=== Создание репозитория ==="
flatpak-builder --repo=repo --force-clean build-dir ru.yzhjdjq.sws.yaml

echo "=== Создание bundle ==="
flatpak build-bundle repo sws.flatpak ru.yzhjdjq.sws

echo "Flatpak пакет создан: sws.flatpak"
echo ""
echo "Для установки выполните: flatpak install sws.flatpak"
echo "Для запуска: flatpak run ru.yzhjdjq.sws"
