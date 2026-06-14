#!/bin/bash

# ───────────────────────────────────────────
# backup.sh — архівує логи з вказаної директорії
# Використання: ./backup.sh <log_dir> <backup_dir>
# ───────────────────────────────────────────

LOCK_FILE="/tmp/backup.lock"

# ── 1. Перевірка аргументів ──────────────────
if [ "$#" -ne 2 ]; then
    echo "Usage: ./backup.sh <log_dir> <backup_dir>"
    exit 1
fi

LOG_DIR="$1"
BACKUP_DIR="$2"

if [ ! -d "$LOG_DIR" ]; then
    echo "Usage: ./backup.sh <log_dir> <backup_dir>"
    exit 1
fi

if [ ! -d "$BACKUP_DIR" ]; then
    echo "Usage: ./backup.sh <log_dir> <backup_dir>"
    exit 1
fi

# ── 2. Захист від паралельного запуску ───────
if [ -f "$LOCK_FILE" ]; then
    echo "Backup already running"
    exit 0
fi

# Створюємо lock-файл і прибираємо його при виході
touch "$LOCK_FILE"
trap "rm -f $LOCK_FILE" EXIT

# ── 3. Створення архіву ───────────────────────
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")
ARCHIVE_NAME="logs_backup_${TIMESTAMP}.tar.gz"
ARCHIVE_PATH="${BACKUP_DIR}/${ARCHIVE_NAME}"

tar -czf "$ARCHIVE_PATH" -C "$LOG_DIR" . 2>/dev/null

# ── 4. Перевірка результату ───────────────────
if [ $? -ne 0 ] || [ ! -f "$ARCHIVE_PATH" ]; then
    echo "Backup failed"
    exit 2
fi

echo "Backup created: $ARCHIVE_PATH"
