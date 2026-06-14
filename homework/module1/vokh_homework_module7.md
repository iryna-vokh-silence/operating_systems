# Домашнє завдання №7. Аналіз життєвого циклу контейнера

> **Варіант A — Аналіз життєвого циклу контейнера**  
> **Виконала:** Ірина Вох  
> **ОС:** macOS (Darwin 25.5.0), Docker 29.3.1

---

## 1. Запуск контейнера

Запускаємо Python HTTP-сервер на порті 8080:

```bash
docker run -d --name lifecycle-demo -p 8080:8080 python:3.11-slim python3 -m http.server 8080
```

```
3862830abf0aa5418a0a3395f5b93f7dc5d22e34c11162ae59a631150c576749
```

```bash
docker ps --filter name=lifecycle-demo
```

```
CONTAINER ID   IMAGE              COMMAND                  CREATED        STATUS        PORTS                    NAMES
3862830abf0a   python:3.11-slim   "python3 -m http.ser…"  4 seconds ago  Up 3 seconds  0.0.0.0:8080->8080/tcp   lifecycle-demo
```

> Контейнер запущено у фоновому режимі (`-d`). Порт 8080 хоста прокинуто на порт 8080 контейнера.

---

## 2. Процес усередині контейнера (PID 1)

У `python:3.11-slim` немає утиліти `ps`, тому дивимось через `/proc`:

```bash
docker exec lifecycle-demo cat /proc/1/status | head -5
docker exec lifecycle-demo cat /proc/1/cmdline | tr '\0' ' '
```

```
Name:	python3
State:	S (sleeping)
Tgid:	1
Pid:	1
PPid:	0

python3 -m http.server 8080
```

```bash
# Всі процеси всередині контейнера
docker exec lifecycle-demo sh -c \
  'for pid in /proc/[0-9]*; do
     echo "PID $(basename $pid): $(cat $pid/cmdline 2>/dev/null | tr "\0" " ")"
   done'
```

```
PID 1: python3 -m http.server 8080
PID 25: sh -c for pid in /proc/[0-9]* ...
```

**Чому `python3` є PID 1?**

> PID 1 у контейнері — це та команда, яку вказано в `docker run` (або в `CMD`/`ENTRYPOINT` образу).  
> Контейнер — це ізольований namespace Linux. Перший запущений процес отримує PID 1, як і `init`/`systemd` у звичайній ОС.  
> **Поки PID 1 живий — контейнер працює. Коли PID 1 завершується — контейнер зупиняється.**

---

## 3. Перевірка роботи сервера та логи

```bash
curl -s http://localhost:8080/
curl -s http://localhost:8080/test.txt
```

```bash
docker logs lifecycle-demo
```

```
192.168.65.1 - - [14/Jun/2026 21:03:01] "GET / HTTP/1.1" 200 -
192.168.65.1 - - [14/Jun/2026 21:03:01] code 404, message File not found
192.168.65.1 - - [14/Jun/2026 21:03:01] "GET /test.txt HTTP/1.1" 404 -
```

**Звідки беруться логи?**

> `docker logs` збирає все, що процес (PID 1) виводить у `stdout` та `stderr`.  
> Python HTTP-сервер пише access-логи у `stdout` — Docker перехоплює їх і зберігає у JSON-файлі на хості (`/var/lib/docker/containers/<id>/<id>-json.log`).  
> Це стандартна угода Docker: застосунок не повинен писати в файли — лише у stdout/stderr.

---

## 4. Зупинка контейнера

```bash
docker stop lifecycle-demo
```

```
lifecycle-demo
```

```bash
docker ps -a --filter name=lifecycle-demo
```

```
CONTAINER ID   IMAGE              COMMAND                  STATUS
3862830abf0a   python:3.11-slim   "python3 -m http.ser…"   Exited (137) Less than a second ago
```

**Що відбувається при `docker stop`?**

> 1. Docker надсилає **SIGTERM (15)** процесу PID 1 — це "м'який" запит на завершення.  
> 2. Дається **10 секунд** (timeout за замовчуванням) на коректне завершення.  
> 3. Якщо процес не завершився — Docker надсилає **SIGKILL (9)**, який не можна ігнорувати.

**Exit code 137** = 128 + 9 → процес завершено сигналом **SIGKILL (9)**.

> `python3 -m http.server` не обробляє SIGTERM і не завершується коректно,  
> тому Docker через 10 секунд примусово вбив процес через SIGKILL.  
> Якщо б застосунок обробляв SIGTERM — він міг би завершити відкриті з'єднання і вийти з кодом 0.

---

## Підсумок: що визначає життя контейнера

| Подія | Що відбувається |
|-------|----------------|
| `docker run` | Запускає PID 1 в ізольованому namespace |
| PID 1 живий | Контейнер працює |
| PID 1 завершився сам | Контейнер зупиняється з його exit code |
| `docker stop` | SIGTERM → 10s → SIGKILL |
| SIGKILL проігноровано | Неможливо: SIGKILL завжди завершує процес |
| Exit code 137 | Процес завершено через SIGKILL |

> **Головний принцип:** контейнер — це не VM, а ізольований процес.  
> Його "час життя" = час роботи PID 1. Немає процесу — немає контейнера.
