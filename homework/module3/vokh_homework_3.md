# Домашнє завдання №3. Управління процесами

> **ОС:** macOS (Darwin 25.5.0)  
> **Оболонка:** zsh  
> **Виконала:** Ірина Вох

---

## Завдання 1. Огляд активних процесів

### 1.1 Список усіх процесів (`ps aux`)

```bash
ps aux
```

```
USER               PID  %CPU %MEM      VSZ    RSS   TT  STAT STARTED      TIME COMMAND
_windowserver      596  46.3  0.3 436667424  86480   ??  Ss   27May26 1062:52.29 /System/Library/PrivateFrameworks/SkyLight.framework/Resources/WindowServer -daemon
silence          65767  25.7  1.9 1957508752 479312   ??  S    11:46PM  16:08.04 /Applications/Claude.app/Contents/Frameworks/Claude Helper (Renderer).app/...
silence          65724  22.3  0.4 486512144 106192   ??  S    11:46PM   6:42.63 /Applications/Claude.app/Contents/Frameworks/Claude Helper.app/...
silence            998  12.7  1.4 508491248 343888   ??  S    11:23PM   0:03.61 claude --output-format stream-json ...
silence          59163   8.1  0.7 436604560 166272   ??  S    Sat04PM 120:40.55 /Applications/Telegram.app/Contents/MacOS/Telegram
silence          11989   7.4  0.5 440279104 115904   ??  S    Tue06PM  14:04.93 /Applications/Grammarly Desktop.app/...
...
```

> Повний список містить понад 540 процесів. Виведені перші рядки, відсортовані за %CPU.

---

### 1.2 Процес з найбільшим споживанням RAM (`top -l 1 -o mem`)

```bash
top -l 1 -o mem | head -25
```

```
Processes: 543 total, 3 running, 540 sleeping, 4333 threads
2026/06/14 23:25:27
Load Avg: 2.83, 3.07, 2.75
CPU usage: 6.11% user, 16.1% sys, 77.86% idle
SharedLibs: 762M resident, 162M data, 117M linkedit.
MemRegions: 1159374 total, 4942M resident, 200M private, 2029M shared.
PhysMem: 23G used (2309M wired, 12G compressor), 251M unused.
VM: 311T vsize, 6144M framework vsize, 1381054(0) swapins, 2815392(0) swapouts.

PID    COMMAND          %CPU  MEM
42111  Figma Helper     0.0   3416M   ← найбільше споживання RAM
63558  Browser Helper   0.0   2126M
63778  VirtualMachine   0.0   1998M
66010  VirtualMachine   0.0   1944M
11746  Arc              0.0   1128M
65450  Figma Helper(Re) 0.0   1013M
88412  Browser Helper   0.0    810M
```

**Процес з найбільшим споживанням RAM:** `Figma Helper` (PID 42111) — **3416 МБ**

Також можна знайти топ-процеси за %MEM через `ps`:
```bash
ps aux | sort -k4 -rn | head -5
```

```
silence  11746  1.1  2.3  487891072  579040  ??  S   Arc
silence  65767 10.4  2.0  1957508752 500144  ??  S   Claude Helper (Renderer)
silence    998  3.3  1.4  508492160  354112  ??  S   claude
silence  65715  3.8  1.2  1951020208 300224  ??  S   Claude.app
silence  63778  0.3  1.2  443712080  303616  ??  Ss  VirtualMachine
```

---

### 1.3 PID поточної оболонки

```bash
echo $$
```

```
1238
```

PID поточного процесу zsh — **1238**.

---

## Завдання 2. Робота у фоні та керування процесами

### 2.1 Запуск команди у фоновому режимі

```bash
sleep 1000 &
```

```
[1] 1266
```

Символ `&` запускає процес у фоні. Shell повертає `[номер_завдання] PID`.

---

### 2.2 Перегляд фонових завдань

```bash
jobs
```

```
[1]+  Running    sleep 1000 &
```

---

### 2.3 Повернення процесу на передній план

```bash
fg %1
```

Команда `fg %1` переводить завдання №1 із фону на передній план. Щоб знову відправити у фон — `Ctrl+Z` (призупинити), потім `bg %1`.

---

### 2.4 Зупинка та примусове завершення процесу

```bash
# Знаходимо PID
SLEEP_PID=$(pgrep -f "sleep 1000" | head -1)

# Звичайне завершення (SIGTERM)
kill $SLEEP_PID
```

```
Killing PID 1266...
Process 1266 terminated
```

```bash
# Примусове завершення (SIGKILL) — процес не може ігнорувати
kill -9 1294
```

```
[1]+  Killed: 9  nohup sleep 999
```

> `kill` (SIGTERM=15) — «м'яке» завершення, процес може завершитися коректно.  
> `kill -9` (SIGKILL) — примусове, негайне завершення без очищення.

---

### 2.5 Запуск через `nohup`

```bash
nohup sleep 500 > /tmp/nohup_test.out 2>&1 &
```

```
nohup PID: 1262
-rw-r--r--  1 silence  wheel  0 Jun 14 23:25 /tmp/nohup_test.out
```

`nohup` ігнорує сигнал SIGHUP, тому процес продовжує роботу після закриття термінала. Вивід перенаправляється у файл.

---

## Завдання 3. Пріоритети та обмеження

### 3.1 Запуск команди зі зміненим `nice`

```bash
nice -n 10 sleep 300 &
```

```
nice sleep PID: 1301
  PID NI STAT COMMAND
 1301  5 RN   nice -n 10 sleep 300
```

> Стовпець `NI` показує значення nice (5 = нижчий пріоритет від стандартного 0).  
> Діапазон: від -20 (найвищий пріоритет) до +19 (найнижчий).  
> Для macOS значення +10 відображається як NI=5 (масштабування).

---

### 3.2 Зміна пріоритету запущеного процесу (`renice`)

```bash
renice -n 15 -p 1301
```

```
1301: old priority 5, new priority 15
  PID NI STAT COMMAND
 1301 20 SN   sleep 300
```

Пріоритет процесу 1301 підвищено до 15 (ще нижчий пріоритет виконання).  
`renice` дозволяє змінювати nice вже запущених процесів. Для зниження nice (підвищення пріоритету) потрібні права root.

---

### 3.3 Поточні обмеження ресурсів (`ulimit`)

```bash
ulimit -a
```

```
-t: cpu time (seconds)              unlimited
-f: file size (blocks)              unlimited
-d: data seg size (kbytes)          unlimited
-s: stack size (kbytes)             8176
-c: core file size (blocks)         0
-v: address space (kbytes)          unlimited
-l: locked-in-memory size (kbytes)  unlimited
-u: processes                       4000
-n: file descriptors                1048576
```

> Ключові обмеження:
> - Стек: **8176 КБ** (~8 МБ)
> - Максимум процесів: **4000**
> - Файлові дескриптори: **1 048 576**
> - Core dump: **0** (вимкнено)

---

## Завдання 4. Моніторинг ресурсів

### 4.1 Використання дискового простору (`df -h`)

```bash
df -h
```

```
Filesystem        Size    Used   Avail Capacity iused ifree %iused  Mounted on
/dev/disk3s1s1   926Gi    12Gi   678Gi     2%    459k  4.3G    0%   /
devfs            202Ki   202Ki     0Bi   100%     698     0  100%   /dev
/dev/disk3s6     926Gi   7.0Gi   678Gi     2%       7  7.1G    0%   /System/Volumes/VM
/dev/disk3s2     926Gi    17Gi   678Gi     3%    2.2k  7.1G    0%   /System/Volumes/Preboot
/dev/disk3s4     926Gi   765Mi   678Gi     1%     484  7.1G    0%   /System/Volumes/Update
/dev/disk3s5     926Gi   209Gi   678Gi    24%    3.3M  7.1G    0%   /System/Volumes/Data
/dev/disk1s2     500Mi   6.0Mi   483Mi     2%       1  4.9M    0%   /System/Volumes/xarts
/dev/disk1s1     500Mi   5.8Mi   483Mi     2%      35  4.9M    0%   /System/Volumes/iSCPreboot
/dev/disk1s3     500Mi   900Ki   483Mi     1%      67  4.9M    0%   /System/Volumes/Hardware
map auto_home      0Bi     0Bi     0Bi   100%       0     0     -   /System/Volumes/Data/home
/dev/disk2s1     5.0Gi   2.1Gi   2.8Gi    44%      71   30M    0%   /System/Volumes/Update/SFR/mnt1
```

> Основний диск: **926 ГБ**, використано **~238 ГБ**, вільно **678 ГБ** (~73% вільно).

---

### 4.2 Оперативна пам'ять (`top -l 1 | grep PhysMem`)

> На macOS немає команди `free`. Замість неї використовується `top` або `vm_stat`.

```bash
top -l 1 | grep PhysMem
```

```
PhysMem: 23G used (2309M wired, 12G compressor), 251M unused.
```

| Показник       | Значення |
|----------------|----------|
| Всього RAM     | ~24 ГБ   |
| Використано    | 23 ГБ    |
| Wired (ядро)   | 2309 МБ  |
| Compressor     | 12 ГБ    |
| Вільно         | 251 МБ   |

```bash
# Детальна статистика через vm_stat
vm_stat
```

```bash
# Для зручного читання можна також використати:
top -l 1 | grep -E "PhysMem|CPU usage|Load Avg"
```

```
Load Avg: 2.83, 3.07, 2.75
CPU usage: 6.11% user, 16.1% sys, 77.86% idle
PhysMem: 23G used (2309M wired, 12G compressor), 251M unused.
```

---

## Нотатки по адаптації для macOS

| Linux команда | macOS еквівалент |
|---------------|-----------------|
| `free -h`     | `top -l 1 \| grep PhysMem` |
| `top` (інтер.)| `top -l 1` (snapshot) або Activity Monitor |
| `htop`        | встановлюється через `brew install htop` |
| `ps aux --sort=-%mem` | `ps aux \| sort -k4 -rn` |
