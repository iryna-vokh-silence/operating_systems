# Домашнє завдання №5. Мережа, SSH та копіювання файлів

> **ОС:** macOS (Darwin 25.5.0)  
> **Оболонка:** zsh  
> **Виконала:** Ірина Вох

> **Адаптація для macOS:**
> | Linux команда | macOS еквівалент |
> |---------------|-----------------|
> | `ip a`        | `ifconfig`       |
> | `ss -tulpn`   | `netstat -an \| grep LISTEN` |
> | `journalctl`  | `/usr/bin/log show` |
> | SSH-сервер    | Remote Login (System Settings → Sharing) |

---

## Завдання 1. Мережева діагностика

### 1.1 IP-адреси та інтерфейси (`ifconfig`)

```bash
ifconfig | grep -E "^[a-z]|inet "
```

```
lo0: flags=8049<UP,LOOPBACK,RUNNING,MULTICAST> mtu 16384
    inet 127.0.0.1 netmask 0xff000000
en0: flags=8863<UP,BROADCAST,SMART,RUNNING,SIMPLEX,MULTICAST> mtu 1500
    inet 192.168.88.22 netmask 0xffffff00 broadcast 192.168.88.255
```

> Активний мережевий інтерфейс — **en0** з локальною IP-адресою **192.168.88.22**.  
> Також присутній loopback **lo0** з адресою 127.0.0.1.

---

### 1.2 Перевірка доступності публічного вузла (`ping`)

```bash
ping -c 4 8.8.8.8
```

```
PING 8.8.8.8 (8.8.8.8): 56 data bytes
64 bytes from 8.8.8.8: icmp_seq=0 ttl=118 time=30.761 ms
64 bytes from 8.8.8.8: icmp_seq=1 ttl=118 time=31.099 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=118 time=30.525 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=118 time=50.572 ms

--- 8.8.8.8 ping statistics ---
4 packets transmitted, 4 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 30.525/35.739/50.572/8.566 ms
```

> Втрат пакетів 0%, середній RTT ~35ms. Доступ до інтернету є.

---

### 1.3 Відкриті listening-порти (`netstat`)

```bash
netstat -an | grep LISTEN | head -20
```

```
tcp4       0      0  *.8080     *.*    LISTEN
tcp4       0      0  *.22       *.*    LISTEN
tcp6       0      0  *.22       *.*    LISTEN
tcp46      0      0  *.51501    *.*    LISTEN
tcp46      0      0  *.51500    *.*    LISTEN
tcp4       0      0  *.65296    *.*    LISTEN
tcp6       0      0  *.65120    *.*    LISTEN
tcp4       0      0  *.5432     *.*    LISTEN
tcp4       0      0  *.5000     *.*    LISTEN
tcp4       0      0  *.7000     *.*    LISTEN
```

> Порт **22** (SSH) та **8080** (nginx) слухають на всіх інтерфейсах.  
> Порт **5432** — PostgreSQL, **5000/7000** — локальні сервіси.

---

## Завдання 2. SSH-доступ з ключами та config

### 2.1 Перевірка існуючого SSH-ключа

```bash
ls ~/.ssh/
```

```
agent  id_rsa  id_rsa.pub  known_hosts  known_hosts.old
```

Ключ вже існує. Переглядаємо його параметри:

```bash
ssh-keygen -l -f ~/.ssh/id_rsa.pub
```

```
4096 SHA256:p2mWNNYUzQr05SGuBRY8ZZweioV7CuIU4gyl0Tg3L0Q silence@Irynas-MacBook-Air.local (RSA)
```

> RSA-ключ 4096 біт вже згенерований. Новий генерувати не потрібно.

---

### 2.2 Копіювання ключа на сервер (`ssh-copy-id`)

```bash
ssh-copy-id -i ~/.ssh/id_rsa.pub silence@127.0.0.1
```

> Оскільки сервер — це той самий macOS (localhost), ключ додано до `~/.ssh/authorized_keys` вручну:

```bash
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

```
key added
```

> Публічний ключ додано до списку авторизованих. Тепер SSH не потребуватиме пароля.

---

### 2.3 Файл `~/.ssh/config`

```bash
cat ~/.ssh/config
```

```
Host myserver
    HostName 127.0.0.1
    User silence
    IdentityFile ~/.ssh/id_rsa
```

> Створено запис `myserver` для підключення до localhost.  
> `RunAtLoad` не потрібен — це конфіг клієнта, а не сервісу.

---

### 2.4 Підключення короткою командою

```bash
ssh myserver "echo 'Connected via short ssh myserver command'"
```

```
Connected via short ssh myserver command
```

> Підключення відбулося без запиту пароля завдяки ключу та config.  
> Ім'я Host у config: **myserver**. Пароль не запитується — підтверджено.

---

## Завдання 3. Копіювання файлів між машинами

### 3.1 Створення локального тестового файлу

```bash
echo "test" > /tmp/test.txt
cat /tmp/test.txt
```

```
test
```

---

### 3.2 Передача файлу через `scp`

```bash
scp /tmp/test.txt myserver:/tmp/test_remote.txt
```

```
test.txt    100%    5     4.9KB/s   00:00
```

Перевірка на сервері:

```bash
ssh myserver "ls -la /tmp/test_remote.txt && cat /tmp/test_remote.txt"
```

```
-rw-r--r--  1 silence  wheel  5 Jun 14 23:54 /tmp/test_remote.txt
test
```

> Файл успішно передано на сервер. Шлях на сервері: `/tmp/test_remote.txt`.

---

### 3.3 Створення директорії для синхронізації на сервері

```bash
ssh myserver "mkdir -p ~/sync_dir && echo 'directory created'"
```

```
directory created
```

---

### 3.4 Синхронізація через `rsync`

```bash
mkdir -p /tmp/local_sync
echo "file1" > /tmp/local_sync/file1.txt
echo "file2" > /tmp/local_sync/file2.txt

rsync -avz /tmp/local_sync/ myserver:~/sync_dir/
```

```
Transfer starting: 3 files
./
file1.txt
file2.txt

sent 239 bytes  received 70 bytes  147142 bytes/sec
total size is 12  speedup is 0.04
```

> `rsync -avz`: `-a` — зберігає атрибути, `-v` — verbose, `-z` — стискає дані при передачі.  
> Синхронізовано 2 файли до `~/sync_dir/` на сервері.

---

### 3.5 Перевірка через `sftp`

```bash
sftp myserver
```

```
Connected to myserver.
sftp> ls /tmp/test_remote.txt
/tmp/test_remote.txt

sftp> ls /Users/silence/sync_dir/
/Users/silence/sync_dir/file1.txt
/Users/silence/sync_dir/file2.txt

sftp> exit
```

> Обидва файли присутні на сервері.  
> Шляхи: `/tmp/test_remote.txt` та `/Users/silence/sync_dir/`.  
> Команда перевірки: `ls` в інтерактивному режимі `sftp`.
