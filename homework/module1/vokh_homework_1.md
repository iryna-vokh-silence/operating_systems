# Домашнє завдання №1. Основи Linux

## Завдання 1. Базові команди
1. **Вміст домашнього каталогу:**
   `ls`

Desktop		Downloads	Movies		Pictures	user
Documents	Library		Music		Public


2. **Перехід у Downloads та перегляд вмісту:**

   `cd Downloads`
   `ls`

0a8b6304-84d8-4c60-ae92-32636f096d48Screenshot 2025-11-24 at 22.08.42.png
1 команда.xlsx.pdf
1- 1024x1024.png
1.svg
2 - 1024x1024.png
2.svg
3 - 1024x1024.png
3.svg
4.1 - 1024x1024.png
4.2 - 1024x1024.png
4.svg
43cae0e8-a93c-4eb4-9954-eaacf8c49c1bScreenshot 2025-11-24 at 22.09.01.png
490763961_18112689679485483_4784030445140113886_n..jpg
494775550_18113171338485483_1064177674702047422_n..jpg
495047521_18113171083485483_3205709567270585473_n..jpg
495338181_18113593960485483_5992671208436055589_n..jpg
5.svg
(і ще купа різних файлів, скопіювала частину)

3. **Створення порожнього файлу:**

   `> test_file.txt`

4. **Перегляд вмісту файлу:**

   `cat test_file.txt`
   Термінал просто перейде на новий рядок (бо всередині нічого немає)

5. **Перехід у домашній каталог (абсолютний шлях):**

   `cd /Users/silence`

6. **Перехід у домашній каталог (відносний шлях):**

   `cd ~`

## Завдання 2. Робота з документацією

Виконані команди:

`man ls`

<img width="660" height="806" alt="man ls " src="https://github.com/user-attachments/assets/b97d3313-54e4-4e17-bea5-968582dafecc" />

`help cd`  -> виконала `man cd` (на macos `help cd` не працює)

<img width="658" height="810" alt="man cd" src="https://github.com/user-attachments/assets/ec7026e2-02d2-4631-9ee7-41e7273ee84f" />

`man cat` 

<img width="651" height="804" alt="man cat" src="https://github.com/user-attachments/assets/0e3ef02f-82fc-4a2a-8b2e-fa578a6488a1" />

`man man `

<img width="648" height="797" alt="man man" src="https://github.com/user-attachments/assets/ee3faf63-9106-4267-bdfd-c4782f209324" />

`cp --help`  -> `man cp` (на macos `cp --help` не працює)

<img width="647" height="796" alt="man cp" src="https://github.com/user-attachments/assets/8e060efd-8c18-436c-ac30-b3f3f5028318" />

`mv --help` -> `man mv`  (на macos `mv --help` не працює)

<img width="645" height="786" alt="man mv" src="https://github.com/user-attachments/assets/f084294f-1ece-4b7c-847c-b362408da40f" />

Загальний скрін терміналу

<img width="637" height="807" alt="general" src="https://github.com/user-attachments/assets/8ea456a4-ff21-4f9b-bfe9-819c5c50debe" />


1. **Ключ ls для прихованих файлів:**

   Відповідь: Ключ `-a` (показує всі файли, включаючи . та ..) або `-A` (показує тільки приховані файли).

2. **Ключ cat для нумерації рядків:**

   Відповідь: `-n`

3. **Різниця між man і --help:**

   `man` — це повний офлайн-довідник, який відкривається в окремому режимі перегляду (як на моєму скріншоті). 
   
   Команда `--help` — це швидка довідка, яка просто виводить текст у термінал і дозволяє відразу писати наступну команду.


## Завдання 3. Міні-сценарій

1. Перехід у домашню папку: `cd /Users/silence`

2. Перегляд вмісту папки silence (щоб знайти my_homework): `ls`

3. Перехід у папку з домашніми завданнями: `cd my_homework`

4. Перегляд вмісту папки my_homework: `ls`

5. Перехід у папку: `cd operating_systems`

6. Перегляд вмісту папки operating_systems: `ls`

7. Створення нового файлу з текстом: `echo "My first draft" > draft.txt`

8. Створення копії цього файлу: `cp draft.txt backup_draft.txt`

9. Перейменування копії у фінальну версію: `mv backup_draft.txt final_homework.txt`

10. Фінальна перевірка вмісту файлу та списку в папці: 
`cat final_homework.txt` 
`ls`
