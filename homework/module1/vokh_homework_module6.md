# Домашнє завдання №6. Bash-скрипт: бекап логів

> **Варіант A — Скрипт бекапу логів**  
> **Виконала:** Ірина Вох  
> **ОС:** macOS (Darwin 25.5.0)

---

## Скрипт `backup.sh`

```bash
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
```

---

## Опис логіки скрипта

| Блок | Що відбувається |
|------|----------------|
| **Перевірка аргументів** | Скрипт перевіряє що передано рівно 2 аргументи і обидві директорії існують. При помилці виводить `Usage:` і завершується з кодом `1`. |
| **Lock-файл** | Перевіряє наявність `/tmp/backup.lock`. Якщо файл є — скрипт вже запущено, виводить попередження і виходить. `trap` гарантує видалення lock-файлу при будь-якому завершенні скрипта. |
| **Архівування** | Формує ім'я архіву з поточною датою та часом (`YYYY-MM-DD_HH-MM`). Команда `tar -czf` архівує всі файли з директорії логів у `.tar.gz`. |
| **Перевірка результату** | Перевіряє код виходу `tar` і наявність файлу архіву. При помилці — `Backup failed` з кодом `2`, при успіху — повний шлях до архіву. |

---

## Запуск та тестування

### Підготовка тестових файлів

```bash
mkdir -p /tmp/test_logs /tmp/test_backup
echo "error: something failed"  > /tmp/test_logs/app.log
echo "warning: disk space low"  > /tmp/test_logs/system.log
echo "info: service started"    > /tmp/test_logs/service.log
```

---

### Тест 1 — Немає аргументів

```bash
./backup.sh
```

```
Usage: ./backup.sh <log_dir> <backup_dir>
Exit code: 1
```

> Скрипт перевіряє кількість аргументів (`$# -ne 2`) і одразу завершується з кодом `1`.

---

### Тест 2 — Неіснуюча директорія

```bash
./backup.sh /tmp/test_logs /tmp/nonexistent_dir
```

```
Usage: ./backup.sh <log_dir> <backup_dir>
Exit code: 1
```

> Перевірка `[ ! -d "$BACKUP_DIR" ]` виявляє що директорія не існує і виводить підказку.

---

### Тест 3 — Успішний бекап

```bash
./backup.sh /tmp/test_logs /tmp/test_backup
```

```
Backup created: /tmp/test_backup/logs_backup_2026-06-14_23-58.tar.gz
Exit code: 0
```

```bash
ls -lh /tmp/test_backup/
```

```
-rw-r--r--  1 silence  wheel  624B Jun 14 23:58 logs_backup_2026-06-14_23-58.tar.gz
```

> Архів створено успішно. Ім'я містить дату і час у форматі `YYYY-MM-DD_HH-MM`.

---

### Тест 4 — Захист від паралельного запуску

```bash
touch /tmp/backup.lock
./backup.sh /tmp/test_logs /tmp/test_backup
```

```
Backup already running
Exit code: 0
```

```bash
rm /tmp/backup.lock
```

> Коли lock-файл існує, скрипт виявляє це і не запускає нову архівацію. `trap EXIT` забезпечує автоматичне видалення lock-файлу при нормальному завершенні.

---

### Тест 5 — Перевірка вмісту архіву

```bash
tar -tzf /tmp/test_backup/logs_backup_2026-06-14_23-58.tar.gz
```

```
./
./service.log
./system.log
./app.log
```

> Архів містить усі три файли логів з директорії `/tmp/test_logs`.

---

## Best practices використані в скрипті

- `set -e` не використовується свідомо — потрібен контроль кодів виходу вручну
- Змінні в лапках `"$1"`, `"$ARCHIVE_PATH"` — захист від пробілів у шляхах
- `trap "rm -f $LOCK_FILE" EXIT` — гарантоване прибирання lock-файлу навіть при аварійному завершенні
- Перевірка і `$?`, і наявності файлу — подвійна валідація результату архівування
- Код виходу `1` для помилок вводу, `2` для помилок виконання — семантично правильні exit codes
