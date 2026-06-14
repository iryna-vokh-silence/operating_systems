# Домашнє завдання №4. Пакети, сервіси та журнали

> **ОС:** macOS (Darwin 25.5.0)  
> **Оболонка:** zsh  
> **Виконала:** Ірина Вох

> **Адаптація для macOS:**
> | Linux        | macOS еквівалент                        |
> |--------------|-----------------------------------------|
> | `apt`/`yum`  | `brew` (Homebrew)                       |
> | `systemctl`  | `launchctl` + `brew services`           |
> | `journalctl` | `/usr/bin/log show`                     |
> | `/etc/systemd/system/` | `~/Library/LaunchAgents/` (.plist) |

---

## Завдання 1. Менеджери пакетів

### 1.1 Оновлення списку пакетів

```bash
brew update
```

```
openssl@3

You have 9 outdated formulae installed.
You can upgrade them with brew upgrade
or list them with brew outdated.
```

---

### 1.2 Встановлення утиліти `tree`

```bash
brew install tree
```

```
==> Would install 1 formula:
tree
==> Downloading https://ghcr.io/v2/homebrew/core/tree/manifests/2.3.2
==> Fetching downloads for: tree
✔︎ Bottle tree (2.3.2)
==> Pouring tree--2.3.2.arm64_tahoe.bottle.tar.gz
🍺  /opt/homebrew/Cellar/tree/2.3.2: 9 files, 195.2KB
==> Running `brew cleanup tree`...
```

---

### 1.3 Перевірка встановленого пакету та версії

```bash
brew info tree
tree --version
```

```
==> tree: stable 2.3.2 (bottled)
Display directories as trees (with optional color/HTML output)
https://oldmanprogrammer.net/source.php?dir=projects/tree
Installed (on request)
From: https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/t/tree.rb

tree v2.3.2 (c) 1996 - 2026 by Steve Baker, Thomas Moore, Francesc Rocher, Florian Sesser, Kyosuke Tokoro
```

---

### 1.4 Видалення пакету

```bash
brew uninstall tree
```

```
Uninstalling /opt/homebrew/Cellar/tree/2.3.2... (9 files, 195.2KB)
```

---

## Завдання 2. Керування сервісами через `brew services` (аналог systemctl)

> На macOS замість `systemctl` використовується `launchctl` та `brew services`.

### 2.1 Встановлення та перевірка статусу nginx

```bash
brew install nginx
brew services list
```

```
Name  Status User    File
nginx started  silence  ~/Library/LaunchAgents/homebrew.mxcl.nginx.plist
```

---

### 2.2 Зупинка сервісу та перевірка

```bash
brew services stop nginx
brew services list
```

```
Stopping `nginx`... (might take a while)
==> Successfully stopped `nginx` (label: homebrew.mxcl.nginx)

Name  Status  User  File
nginx none
```

Статус `none` — сервіс не активний.

---

### 2.3 Запуск сервісу знову

```bash
brew services start nginx
brew services list
```

```
==> Successfully started `nginx` (label: homebrew.mxcl.nginx)

Name  Status   User     File
nginx started  silence  ~/Library/LaunchAgents/homebrew.mxcl.nginx.plist
```

---

### 2.4 Додавання в автозавантаження

На macOS `brew services start` автоматично реєструє сервіс в автозавантаженні через `launchd` — plist-файл розміщується в `~/Library/LaunchAgents/`.

```bash
ls -la ~/Library/LaunchAgents/homebrew.mxcl.nginx.plist
```

```
-rw-r--r--@ 1 silence  staff  685 Jun 14 23:45 /Users/silence/Library/LaunchAgents/homebrew.mxcl.nginx.plist
```

Наявність plist у `LaunchAgents` = сервіс запускатиметься автоматично при вході в систему.

---

## Завдання 3. Робота з логами

### 3.1 Останні 10 рядків `/var/log/system.log`

```bash
tail -10 /var/log/system.log
```

```
Jun 14 21:34:01 Irynas-MacBook-Air syslogd[559]: ASL Sender Statistics
Jun 14 21:49:46 Irynas-MacBook-Air syslogd[559]: ASL Sender Statistics
Jun 14 22:05:07 Irynas-MacBook-Air syslogd[559]: ASL Sender Statistics
Jun 14 22:21:22 Irynas-MacBook-Air syslogd[559]: ASL Sender Statistics
Jun 14 22:39:20 Irynas-MacBook-Air syslogd[559]: ASL Sender Statistics
Jun 14 22:49:47 Irynas-MacBook-Air syslogd[559]: ASL Sender Statistics
Jun 14 23:04:22 Irynas-MacBook-Air syslogd[559]: ASL Sender Statistics
Jun 14 23:14:26 Irynas-MacBook-Air syslogd[559]: ASL Sender Statistics
Jun 14 23:24:33 Irynas-MacBook-Air syslogd[559]: ASL Sender Statistics
Jun 14 23:36:12 Irynas-MacBook-Air syslogd[559]: ASL Sender Statistics
```

> На macOS аналог `syslog` — `/var/log/system.log`. `journalctl` відсутній, замість нього — `/usr/bin/log show`.

---

### 3.2 Перегляд помилок (аналог `journalctl -p err`)

```bash
/usr/bin/log show --last 1h --predicate 'eventMessage CONTAINS "error" OR eventMessage CONTAINS "Error"'
```

```
Timestamp                       Thread     Type        Activity   PID   TTL
2026-06-14 22:46:25.978302+0300 0x8d38c2   Default     0x19eac3f  588   0
    bluetoothd: [WirelessProximity] Started to advertise for type 9 with error (null)
2026-06-14 22:46:25.978304+0300 0x8d38c2   Default     0x19eac3f  588   0
    bluetoothd: [WirelessProximity] Started to advertise for type 12 with error (null)
2026-06-14 22:46:26.109207+0300 0x8d4a0e   Default     0x0        1073  0
    ContinuityCaptureAgent: RapportErrorFlags : 0
2026-06-14 22:46:28.920131+0300 0xc5c10    Default     0x0        0     0
    kernel: udp connect error: 65
...
```

---

### 3.3 Записи про запуск/зупинку nginx у журналах

```bash
/usr/bin/log show --last 1h --predicate 'process == "launchd" AND eventMessage CONTAINS "nginx"'
```

```
Timestamp                       Thread     Type    PID  TTL
2026-06-14 23:45:38.756404+0300 0x8e0b1b   Default 1    0
    launchd: Setting service homebrew.mxcl.nginx to enabled
2026-06-14 23:45:38.778928+0300 0x8e222d   Default 1    0
    launchd: Successfully spawned nginx[5794] because speculative
2026-06-14 23:45:47.518520+0300 0x8e222d   Default 1    0
    launchd: service inactive: homebrew.mxcl.nginx
2026-06-14 23:45:47.518524+0300 0x8e222d   Default 1    0
    launchd: removing service: homebrew.mxcl.nginx
2026-06-14 23:45:55.022124+0300 0x8e0b1b   Default 1    0
    launchd: Setting service homebrew.mxcl.nginx to enabled
2026-06-14 23:45:55.041774+0300 0x8e2d24   Default 1    0
    launchd: Successfully spawned nginx[6658] because speculative
```

Видно зупинку (`removing service`) та повторний запуск (`Successfully spawned`) nginx.

---

## Завдання 4. Створення власного сервісу

> На macOS замість `/etc/systemd/system/` використовується `~/Library/LaunchAgents/` та `.plist` файли.

### 4.1 Bash-скрипт `~/myscript.sh`

```bash
cat ~/myscript.sh
```

```bash
#!/bin/bash
while true; do
    echo "$(date)" >> ~/mylog.txt
    sleep 1
done
```

```bash
chmod +x ~/myscript.sh
```

---

### 4.2 Файл конфігурації сервісу (аналог `.service` файлу)

На macOS сервіси описуються у форматі `.plist` (Property List XML).

```bash
cat ~/Library/LaunchAgents/com.user.myscript.plist
```

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.myscript</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>/Users/silence/myscript.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/myscript.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/myscript.err</string>
</dict>
</plist>
```

---

### 4.3 Запуск сервісу та перевірка статусу

```bash
launchctl load ~/Library/LaunchAgents/com.user.myscript.plist
launchctl list com.user.myscript
```

```
{
    "StandardOutPath" = "/tmp/myscript.log";
    "Label" = "com.user.myscript";
    "OnDemand" = false;
    "LastExitStatus" = 0;
    "PID" = 7150;
    "Program" = "/bin/bash";
    "ProgramArguments" = (
        "/bin/bash";
        "/Users/silence/myscript.sh";
    );
};
```

`PID = 7150` — сервіс запущено.

---

### 4.4 Перевірка запису даних у файл

```bash
tail -5 ~/mylog.txt
```

```
Sun Jun 14 23:46:58 EEST 2026
Sun Jun 14 23:46:59 EEST 2026
Sun Jun 14 23:47:00 EEST 2026
Sun Jun 14 23:47:01 EEST 2026
Sun Jun 14 23:47:02 EEST 2026
```

Дата щосекунди записується у `~/mylog.txt` — сервіс працює коректно.

---

### 4.5 Зупинка сервісу

```bash
launchctl unload ~/Library/LaunchAgents/com.user.myscript.plist
```
