Minecraft in Hello Neighbor / Minecraft в «Привете, соседе»
============================================================

РУССКИЙ
-------
Неофициальный фанатский проект. Не связан с tinyBuild, Dynamic Pixels, Mojang
или Microsoft. Нужны свои копии Hello Neighbor (Steam) и Minecraft: Java Edition.

Перед началом
  1. Установи ElyPrism Launcher (https://elyprismlauncher.github.io/), открой,
     войни через аккаунт Ely.by, затем закрой. (Подойдёт и Prism Launcher.)
  2. Hello Neighbor должен быть установлен через Steam. Закрой его, если запущен.

Установка
  Запусти Install.bat (двойной клик). Он сам найдёт Hello Neighbor и лаунчер
  и настроит всё. (Windows может показать предупреждение — выбери
  «Подробнее» > «Всё равно запустить».)
  Первый запуск скачает Minecraft и Java через лаунчер, поэтому нужны
  интернет и несколько минут.

Запуск
  1. Install.bat — ставит мод (один раз).
  2. GUI.bat — открывает окно с кнопками «Запустить» / «Остановить» и FPS.
     Minecraft стартует скрытым, потом открывается Hello Neighbor. Загрузи
     уровень и играй.
  3. Stop.bat — закрывает всё. Или просто закрой Hello Neighbor — остальное
     завершится само.
  Альтернатива без GUI: Play.bat (держи окно открытым, закрой HN — всё
  само закроется).

Управление
  Мышь, W A S D, Space, Shift, Ctrl, 1-9, E, Q, F5, T ... : как в Minecraft
  R (удерживать): взять / взаимодействовать   G: использовать предмет в руке
  X: выбросить предмет в руке
  ПКМ: двери, выключатели...   Space: также «нажми Space» у соседа
  F: тоже отправляется соседу (ты знаешь, где это нужно 🥁🥁🥁)
  Esc: меню соседа   F4: вкл/выкл движение Minecraft   F6: перерисовать блоки
  /hnreset (в чате): убрать блоки, мобов и выброшенные предметы, вернуть стартовый набор

Твоя имя
  Имя в чате и сообщениях о смерти — имя аккаунта Minecraft. Другое имя:
  задай playerName в <папка лаунчера>\instances\HelloCraft\minecraft\config\hnmc.properties
  (обычно %APPDATA%\ElyPrismLauncher\instances\HelloCraft\minecraft\config\hnmc.properties).

Безопасность
  - Мод работает только на твоём ПК: нет сетевого кода, логин Minecraft не трогается
    (лаунчер сам управляет). Minecraft играет в приватный одиночный мир,
    не открытый в LAN и интернет.
  - Мод меняет папку Hello Neighbor (UE4SS, два мода и несколько мелких файлов)
    и добавляет один экземпляр лаунчера. Больше ничего не трогается. Заменённые
    файлы сохраняются как *.before-hnmc; Uninstall.bat всё уберёт.
  - Антивирус или Windows SmartScreen могут ругаться: мод хукает графику игры,
    UE4SS грузится как dwmapi.dll рядом с игрой. Исходники открыты, на странице
    релиза есть SHA-256 чексумма архива (проверить: PowerShell, Get-FileHash).
  - Только одиночная игра. Не используй с онлайн- или мультиплеером.

Проблемы
  GUI-окно открывается пустым/прозрачным:
    Не запускай pythonw.exe напрямую. Используй GUI.bat — он сам скроет
    консоль. Если запускал скрипт руками через pythonw, закрой его и открой
    через GUI.bat.
  Hello Neighbor открывается в прозрачном/белом окне, кадры не идут:
    Закрой Steam полностью (в трее тоже) и запусти через GUI.bat или Play.bat.
    Если помогло один раз, но повторяется — проверь, что Steam Overlay для
    Hello Neighbor выключен (Steam → библиотека → ПКМ по игре → Свойства →
    Встроенный оверлей → снять галку). Логи: <Hello Neighbor>\HelloNeighbor\
    Binaries\Win64\hn_gfx.log — если там «Present hook loop cut» и после
    нет «game Present», оверлей всё ещё мешает.
  Minecraft не стартует / закрывается сразу:
    Проверь, что ElyPrism Launcher установлен и ты входил в аккаунт.
    Лог: logs\gui-play.out или logs\play.out рядом с bat-файлами.
  Краш при броске предмета:
    Обнови мод: закрой всё, запусти Install.bat заново (берёт свежий main.lua).
  Окно GUI не появляется:
    Убедись, что установлен Python 3.11 и pywebview (pip install pywebview).
    Запускай именно GUI.bat, а не HelloCraft.py двойным кликом.
  Полные логи:
    logs\ рядом с Play.bat / GUI.bat — вывод моста и запуска.
    <Hello Neighbor>\HelloNeighbor\Binaries\Win64 — hn_gfx.log, ue4ss\UE4SS.log.
    Приложи их к баг-репорту.
  Uninstall.bat удаляет всё, что добавил установщик, включая UE4SS
    (если ставил его он; твой старый UE4SS остаётся, заменённые файлы возвращаются).

Лицензии: см. LICENSE и THIRD-PARTY-NOTICES.txt. Исходники: страница проекта на GitHub.


ENGLISH
-------
Unofficial fan project; not affiliated with tinyBuild, Dynamic Pixels, Mojang
or Microsoft. You need your own copies of Hello Neighbor (Steam) and Minecraft:
Java Edition.

Before you start
  1. Install ElyPrism Launcher (https://elyprismlauncher.github.io/), open it,
     sign in with your Ely.by account, then close it. (Prism Launcher also works.)
  2. Hello Neighbor must be installed through Steam. Close it if it is running.

Install
  Double-click Install.bat. It finds Hello Neighbor and the launcher by itself
  and sets everything up. (Windows may warn: choose "More info" > "Run anyway".)
  The first start downloads Minecraft and Java through the launcher, so it
  takes a few minutes and needs internet.

Play
  1. Install.bat — installs the mod (once).
  2. GUI.bat — opens a window with "Start" / "Stop" buttons and FPS settings.
     Minecraft starts hidden, then Hello Neighbor opens. Load a level and play.
  3. Stop.bat — closes everything. Or just close Hello Neighbor; the rest
     shuts down by itself.
  Without GUI: Play.bat (keep the window open; close HN and everything closes).

Controls
  Mouse, W A S D, Space, Shift, Ctrl, 1-9, E, Q, F5, T ... : as in Minecraft
  R (hold): pick up / interact    G: use the held item    X: throw the held item
  Right-click: doors, switches... Space: also Hello Neighbor's "press Space"
  F: also sent to Hello Neighbor (you know where we need this 🥁🥁🥁)
  Esc: HN menu   F4: Minecraft movement on/off   F6: redraw Minecraft's blocks
  /hnreset (in chat): remove blocks, mobs, dropped items; get the starting kit back

Your name
  The name in chat and death messages is your Minecraft account name. To use
  another one, set playerName in <launcher data>\instances\HelloCraft\minecraft\
  config\hnmc.properties (usually %APPDATA%\ElyPrismLauncher\instances\
  HelloCraft\minecraft\config\hnmc.properties).

Safety
  - Runs on your PC only: no network code, Minecraft login untouched (the
    launcher handles that). Minecraft runs a private single-player world.
  - Changes Hello Neighbor's folder (UE4SS, two mods, a few small files) and
    adds one launcher instance. Nothing else is touched. Replaced files are
    kept as *.before-hnmc; Uninstall.bat removes everything.
  - Antivirus / SmartScreen may warn: the mod hooks the game's graphics, UE4SS
    loads as dwmapi.dll. Source is public; the release page lists the zip's
    SHA-256 checksum (PowerShell: Get-FileHash).
  - Single-player only. Not for online or multiplayer.

Problems
  GUI window opens empty/transparent:
    Don't run pythonw.exe directly. Use GUI.bat — it hides the console itself.
    If you launched the script manually via pythonw, close it and use GUI.bat.
  Hello Neighbor opens in a transparent/white window, no frames:
    Close Steam completely (including tray) and launch via GUI.bat or Play.bat.
    If it helps once but returns — check Steam Overlay is off for Hello Neighbor
    (Steam → Library → right-click game → Properties → In-game overlay →
    uncheck). Logs: <Hello Neighbor>\HelloNeighbor\Binaries\Win64\hn_gfx.log —
    if you see "Present hook loop cut" with no "game Present" after it, the
    overlay is still interfering.
  Minecraft doesn't start / closes immediately:
    Make sure ElyPrism Launcher is installed and you signed in.
    Log: logs\gui-play.out or logs\play.out next to the bat files.
  Crash when throwing a item:
    Update the mod: close everything, run Install.bat again (picks up the
    latest main.lua).
  GUI window doesn't appear:
    Make sure Python 3.11 and pywebview are installed (pip install pywebview).
    Launch via GUI.bat, not by double-clicking HelloCraft.py.
  Full logs:
    logs\ next to Play.bat / GUI.bat — bridge and launch output.
    <Hello Neighbor>\HelloNeighbor\Binaries\Win64 — hn_gfx.log, ue4ss\UE4SS.log.
    Please attach them to a bug report.
  Uninstall.bat removes everything the installer added, including UE4SS if the
    installer put it there (a UE4SS you had before stays, with its replaced
    files put back).

Licences: see LICENSE and THIRD-PARTY-NOTICES.txt. Source: see the project
page on GitHub.
