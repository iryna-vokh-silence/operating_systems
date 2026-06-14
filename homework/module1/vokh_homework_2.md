# Домашнє завдання №2. Файлова система і права доступу

## Завдання 1. Ієрархія каталогів Linux

**Умова:** Перейди в кореневий каталог `/`, в `/etc` та у каталог `/home` і покажи їх вміст.

```bash
cd / && ls -F
```

<img width="619" height="95" alt="Screenshot 2026-04-05 at 19 34 05" src="https://github.com/user-attachments/assets/75223756-a728-482f-949c-cdb1a46b68ff" />

```bash
cd /etc && ls
```

<img width="784" height="394" alt="Screenshot 2026-04-05 at 19 35 05" src="https://github.com/user-attachments/assets/faff3b13-f96b-403e-a39f-12036325239e" />

### 3. Список користувачів

Оскільки робота ведеться в середовищі macOS, де користувачі знаходяться в директорії /Users, виконую команду для перегляду вмісту:

```bash
ls /Users
```
<img width="334" height="45" alt="image" src="https://github.com/user-attachments/assets/538b8167-c4b3-4bc6-bfb5-1f90432f0467" />


<img width="593" height="84" alt="Screenshot 2026-04-05 at 19 36 24" src="https://github.com/user-attachments/assets/05e33281-0ea8-4235-8205-2131da0fce3a" />



## Завдання 2. Файли, каталоги та посилання

**Умова:** Створити каталог, файл, копію, перейменувати, створити жорстке та символічне посилання, знайти файл за іменем.

```bash
mkdir ~/lab2 && cd ~/lab2        # Створення каталогу та перехід
```


```bash
touch file.txt                   # Створення файлу
```

```bash
cp file.txt copy.txt             # Копіювання файлу
```

```bash
mv copy.txt renamed.txt          # Перейменування копії
```

```bash
ln file.txt hard_link.txt        # Створення жорсткого посилання
```

```bash
ln -s file.txt soft_link.txt     # Створення символічного посилання
```

```bash
find ~/lab2 -name "renamed.txt"  # Пошук файлу за іменем
```
<img width="614" height="315" alt="image" src="https://github.com/user-attachments/assets/dcdbea54-c387-4f78-9950-b7a1a6f45556" />


## Завдання 3. Права доступу

**Умова:** Переглянути права доступу, змінити їх на "тільки читання", повернути право на запис власнику та налаштувати umask.

```bash
ls -l file.txt                   # Перегляд поточних прав доступу
```
```bash
chmod 444 file.txt               # Встановлення прав "тільки читання" для всіх
```
```bash
chmod 644 file.txt               # Надання власнику прав на запис (rw-r--r--)
```
```bash
umask                            # Перегляд поточного значення маски
```
```bash
umask 022                        # Встановлення нового значення umask
```
<img width="428" height="215" alt="image" src="https://github.com/user-attachments/assets/c6a25c1b-e30e-4790-aede-6197d6e5021d" />


## Завдання 4. Користувачі (macOS)

**Умова:** Створити нового користувача, додати його до групи адміністраторів та перевірити його існування в системі.

```bash
sudo dscl . -create /Users/trainee             # Створення запису користувача trainee
```
```bash
sudo dscl . -create /Users/trainee UserShell /bin/zsh
sudo dscl . -create /Users/trainee UniqueID 1001        # Налаштування оболонки та UID
```
```bash
sudo dscl . -append /Groups/admin GroupMembership trainee      # Додавання користувача до групи адміністраторів (аналог sudo)
```
```bash
dscl . -read /Users/trainee    # Перевірка створення користувача
```
<img width="852" height="391" alt="image" src="https://github.com/user-attachments/assets/8546e256-8a5b-4b3a-a306-1282367ca014" />

