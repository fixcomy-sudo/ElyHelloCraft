# -*- coding: utf-8 -*-
"""HelloCraft GUI: запуск/остановка всего мода и настройка FPS для обеих игр.

Двойной клик по GUI.bat (или `python HelloCraft.py`) открывает окно с HTML-интерфейсом.
Кнопки делают ровно то же, что Play.bat и Stop.bat; FPS пишется в конфиги Hello Neighbor
и Minecraft (применяется при следующем запуске игр).
"""
import os
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
SCRIPTS = ROOT / "scripts"
LOGS = ROOT / "logs"
CREATE_NO_WINDOW = 0x08000000

DEFAULT_LAUNCHER_DATA = Path.home() / "AppData" / "Roaming" / "ElyPrismLauncher"
DEFAULT_HN_CFG = Path(os.environ.get("LOCALAPPDATA", str(Path.home()))) / "HelloNeighbor" / "Saved" / "Config" / "WindowsNoEditor" / "GameUserSettings.ini"


def read_settings():
    s = {}
    p = ROOT / "settings.ini"
    if p.exists():
        for line in p.read_text(encoding="utf-8", errors="replace").splitlines():
            line = line.strip()
            if not line or line.startswith(("#", ";")):
                continue
            if "=" in line:
                k, v = line.split("=", 1)
                s[k.strip()] = v.strip()
    return s


S = read_settings()
LAUNCHER_DATA = Path(S.get("LauncherData", str(DEFAULT_LAUNCHER_DATA)))
INSTANCE = S.get("Instance", "HelloCraft")
LAUNCHER_EXE = Path(S.get("LauncherExe", "elyprismlauncher.exe")).name
HN_CFG = DEFAULT_HN_CFG
MC_OPTS = LAUNCHER_DATA / "instances" / INSTANCE / "minecraft" / "options.txt"


def alive(name):
    try:
        r = subprocess.run(["tasklist", "/NH", "/FI", "IMAGENAME eq " + name],
                           capture_output=True, text=True, creationflags=CREATE_NO_WINDOW, timeout=10)
        return name.lower() in r.stdout.lower()
    except Exception:
        return False


def get_fps():
    hn = hn_vsync = mc = mc_vsync = None
    try:
        if HN_CFG.exists():
            t = HN_CFG.read_text(encoding="utf-8", errors="replace")
            m = re.search(r"FrameRateLimit=([\d.]+)", t)
            if m:
                hn = int(float(m.group(1)))
            m = re.search(r"bUseVSync=(\w+)", t)
            if m:
                hn_vsync = m.group(1)
    except Exception:
        pass
    try:
        if MC_OPTS.exists():
            t = MC_OPTS.read_text(encoding="utf-8", errors="replace")
            m = re.search(r"^fpsLimit:(\d+)", t, re.M)
            if m:
                mc = int(m.group(1))
            m = re.search(r"^enableVsync:(\w+)", t, re.M)
            if m:
                mc_vsync = m.group(1)
    except Exception:
        pass
    return {"hn": hn, "hn_vsync": hn_vsync, "mc": mc, "mc_vsync": mc_vsync}


def set_fps(limit):
    limit = int(limit)
    if limit < 0:
        limit = 0
    try:
        if HN_CFG.exists():
            t = HN_CFG.read_text(encoding="utf-8", errors="replace")
            if re.search(r"FrameRateLimit=[\d.]+", t):
                t = re.sub(r"FrameRateLimit=[\d.]+", "FrameRateLimit=%.6f" % limit, t)
            else:
                t = t.replace("[/Script/Engine.GameUserSettings]", "[/Script/Engine.GameUserSettings]\nFrameRateLimit=%.6f" % limit, 1)
            if re.search(r"bUseVSync=\w+", t):
                t = re.sub(r"bUseVSync=\w+", "bUseVSync=False", t)
            else:
                t = re.sub(r"(?m)^bUseDynamicResolution=", "bUseVSync=False\nbUseDynamicResolution=", t)
            HN_CFG.write_text(t, encoding="utf-8")
    except Exception as e:
        return {"ok": False, "error": "Hello Neighbor: %s" % e, "fps": get_fps()}
    try:
        if MC_OPTS.exists():
            lines = MC_OPTS.read_text(encoding="utf-8", errors="replace").splitlines()
            out, has_fps, has_vsync = [], False, False
            for ln in lines:
                if ln.startswith("fpsLimit:"):
                    out.append("fpsLimit:%d" % limit)
                    has_fps = True
                elif ln.startswith("enableVsync:"):
                    out.append("enableVsync:false")
                    has_vsync = True
                else:
                    out.append(ln)
            if not has_fps:
                out.append("fpsLimit:%d" % limit)
            if not has_vsync:
                out.append("enableVsync:false")
            MC_OPTS.write_text("\n".join(out) + "\n", encoding="utf-8")
    except Exception as e:
        return {"ok": False, "error": "Minecraft: %s" % e, "fps": get_fps()}
    return {"ok": True, "fps": get_fps()}


def run_ps(script, logname):
    LOGS.mkdir(exist_ok=True)
    out = LOGS / logname
    with open(out, "w", encoding="utf-8") as f:
        subprocess.Popen(
            ["powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", str(SCRIPTS / script)],
            stdout=f, stderr=subprocess.STDOUT, cwd=str(ROOT), creationflags=CREATE_NO_WINDOW,
        )
    return str(out)


def log_tail(name, n=12):
    p = LOGS / name
    try:
        if p.exists():
            return p.read_text(encoding="utf-8", errors="replace").splitlines()[-n:]
    except Exception:
        pass
    return []


class Api:
    def status(self):
        return {
            "hn": alive("HelloNeighbor-Win64-Shipping.exe"),
            "mc": alive("javaw.exe"),
            "bridge": alive("hn_bridge.exe"),
            "launcher": alive(LAUNCHER_EXE),
            "fps": get_fps(),
            "play_log": log_tail("gui-play.out"),
            "stop_log": log_tail("gui-stop.out"),
        }

    def start(self):
        if alive("HelloNeighbor-Win64-Shipping.exe"):
            return {"ok": False, "error": "Hello Neighbor уже запущен: сначала останови."}
        run_ps("start_mod.ps1", "gui-play.out")
        return {"ok": True, "message": "Запуск пошёл (~30–60 с): мост, Minecraft, затем Hello Neighbor."}

    def stop(self):
        run_ps("stop_mod.ps1", "gui-stop.out")
        return {"ok": True, "message": "Останавливаю всё... (~5–35 с, Minecraft закрывается чисто)."}

    def apply_fps(self, limit):
        return set_fps(limit)


HTML = r"""<!DOCTYPE html>
<html lang="ru">
<head>
<meta charset="utf-8">
<title>HelloCraft</title>
<style>
  :root {
    --bg: #fffaf6;
    --glass: rgba(255,255,255,.60);
    --glass-2: rgba(255,255,255,.78);
    --glass-brd: rgba(255,255,255,.90);
    --glass-sh: 0 16px 40px rgba(216,104,26,.10), 0 2px 8px rgba(70,35,5,.06);
    --accent: #ff7a1a;
    --accent-2: #ff9d2e;
    --accent-3: #ff6b00;
    --grad: linear-gradient(135deg, #ff9d2e 0%, #ff6b00 100%);
    --grad-soft: linear-gradient(135deg, rgba(255,157,46,.24), rgba(255,107,0,.14));
    --text: #241c15;
    --text-2: #8b7f74;
    --text-3: #b3a79c;
    --line: rgba(70,35,5,.10);
    --online: #22c55e;
    --danger: #ff4d4f;
    --font: -apple-system, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
  }
  * { box-sizing: border-box; margin: 0; padding: 0; }
  html, body { height: 100%; }
  body {
    background: var(--bg);
    color: var(--text);
    font: 15px/1.4 var(--font);
    overflow: hidden;
    user-select: none;
    display: flex; justify-content: center; align-items: stretch;
  }
  body::before {
    content: "";
    position: fixed; inset: -25%;
    z-index: -1;
    background:
      radial-gradient(42% 42% at 18% 22%, rgba(255,157,46,.42), transparent 70%),
      radial-gradient(38% 38% at 84% 16%, rgba(255,107,0,.26), transparent 70%),
      radial-gradient(46% 46% at 70% 88%, rgba(255,205,130,.40), transparent 70%),
      radial-gradient(40% 40% at 25% 82%, rgba(255,140,60,.22), transparent 70%),
      var(--bg);
    animation: drift 30s ease-in-out infinite alternate;
  }
  @keyframes drift { to { transform: translate3d(-2.5%, 2%, 0) scale(1.05); } }
  ::selection { background: rgba(255,122,26,.30); }
  ::-webkit-scrollbar { width: 7px; }
  ::-webkit-scrollbar-thumb { background: rgba(120,80,40,.22); border-radius: 4px; }

  #app {
    width: 100%; max-width: 1020px; height: 100%;
    background: rgba(255,255,255,.42);
    backdrop-filter: blur(26px) saturate(165%);
    box-shadow: var(--glass-sh);
    padding: 30px 34px;
    overflow-y: auto;
    opacity: 0; transform: scale(.985);
    animation: appIn .5s ease forwards;
  }
  @keyframes appIn { to { opacity: 1; transform: none; } }

  .head { display: flex; align-items: flex-end; justify-content: space-between; gap: 16px; margin-bottom: 18px; flex-wrap: wrap; }
  h1 {
    font-size: 34px; font-weight: 800; letter-spacing: -0.5px;
    background: linear-gradient(120deg, #ff8a1f, #ff5f00 60%, #ff9d2e);
    -webkit-background-clip: text; background-clip: text; color: transparent;
  }
  .sub { color: var(--text-2); font-size: 14px; margin-top: 3px; }
  .pills { display: flex; gap: 8px; flex-wrap: wrap; }
  .pill {
    display: flex; align-items: center; gap: 7px;
    background: var(--glass-2); border: 1px solid var(--glass-brd);
    border-radius: 999px; padding: 7px 14px; font-size: 13px; color: var(--text-2);
    box-shadow: inset 0 1px 2px rgba(70,35,5,.05);
  }
  .dot { width: 9px; height: 9px; border-radius: 50%; background: var(--text-3); flex: 0 0 9px; }
  .dot.on { background: var(--online); box-shadow: 0 0 8px rgba(34,197,94,.7); }

  .grid { display: grid; grid-template-columns: 1fr 1fr; gap: 18px; }
  .card {
    background: var(--glass);
    backdrop-filter: blur(30px) saturate(170%);
    border: 1px solid var(--glass-brd);
    border-radius: 20px;
    padding: 20px 22px;
    box-shadow: var(--glass-sh);
  }
  .card h2 {
    font-size: 12px; font-weight: 700; letter-spacing: .8px; text-transform: uppercase;
    color: var(--text-3); margin-bottom: 14px;
  }
  .wide { grid-column: 1 / -1; }

  .btn {
    display: flex; align-items: center; justify-content: center; gap: 8px;
    width: 100%; border: 1px solid rgba(255,255,255,.35);
    border-radius: 16px; padding: 15px; font-size: 16px; font-weight: 700;
    cursor: pointer; color: #fff; margin-bottom: 10px;
    transition: transform .12s, box-shadow .15s, opacity .15s;
  }
  .btn:active { transform: scale(.97); }
  .btn:disabled { opacity: .45; cursor: default; transform: none; }
  .btn.go {
    background: linear-gradient(135deg, #4ade80, #16a34a);
    box-shadow: 0 10px 26px rgba(34,197,94,.35), inset 0 1px 3px rgba(255,255,255,.45);
  }
  .btn.go:hover:not(:disabled) { box-shadow: 0 14px 32px rgba(34,197,94,.45); transform: translateY(-1px); }
  .btn.stop {
    background: linear-gradient(135deg, #ff6b6b, #ff3b30);
    box-shadow: 0 10px 26px rgba(255,59,48,.32), inset 0 1px 3px rgba(255,255,255,.4);
  }
  .btn.stop:hover:not(:disabled) { box-shadow: 0 14px 32px rgba(255,59,48,.42); transform: translateY(-1px); }

  .row { display: flex; gap: 8px; align-items: center; flex-wrap: wrap; margin-bottom: 10px; }
  input[type=number] {
    width: 108px; background: rgba(255,255,255,.92); color: var(--text);
    border: 1px solid var(--line); border-radius: 14px; padding: 11px 12px;
    font-size: 17px; text-align: center; outline: none;
    transition: border-color .15s, box-shadow .15s;
  }
  input[type=number]:focus { border-color: rgba(255,122,26,.55); box-shadow: 0 0 0 3px rgba(255,122,26,.15); }
  .apply {
    border: none; background: var(--grad); color: #fff;
    border-radius: 14px; padding: 12px 20px; font-size: 15px; font-weight: 700; cursor: pointer;
    box-shadow: 0 10px 26px rgba(255,107,0,.35), inset 0 1px 3px rgba(255,255,255,.5);
    transition: transform .12s, box-shadow .15s;
  }
  .apply:hover { transform: translateY(-1px); box-shadow: 0 14px 32px rgba(255,107,0,.45); }
  .apply:active { transform: scale(.96); }
  .chip {
    background: rgba(255,255,255,.85); border: 1px solid var(--line); color: var(--text-2);
    border-radius: 12px; padding: 9px 13px; cursor: pointer; font-size: 14px; font-weight: 600;
    transition: .15s;
  }
  .chip:hover { color: var(--accent); border-color: rgba(255,122,26,.5); box-shadow: 0 4px 12px rgba(216,104,26,.15); }
  .chip.gold { color: var(--accent); background: var(--grad-soft); border-color: rgba(255,122,26,.30); }
  .now { color: var(--text-2); font-size: 13.5px; margin-top: 8px; }
  .now b { color: var(--text); }
  .hint { color: var(--text-3); font-size: 12px; margin-top: 10px; line-height: 1.55; }
  .msg { margin-top: 12px; font-size: 13px; color: var(--accent-3); font-weight: 600; min-height: 18px; }
  pre {
    background: var(--glass-2); border: 1px solid var(--glass-brd);
    border-radius: 14px; padding: 12px 14px;
    font: 12px/1.55 Consolas, monospace; color: var(--text-2);
    max-height: 150px; overflow: auto; white-space: pre-wrap;
    box-shadow: inset 0 1px 3px rgba(70,35,5,.06);
    user-select: text;
  }
</style>
</head>
<body>
<div id="app">
  <div class="head">
    <div>
      <h1>HELLOCRAFT</h1>
      <div class="sub">Minecraft в «Привет, соседе» — запуск, остановка и FPS в одном окне</div>
    </div>
    <div class="pills">
      <div class="pill"><div class="dot" id="d-hn"></div>Hello Neighbor</div>
      <div class="pill"><div class="dot" id="d-mc"></div>Minecraft</div>
      <div class="pill"><div class="dot" id="d-br"></div>Мост</div>
      <div class="pill"><div class="dot" id="d-ln"></div>Лаунчер</div>
    </div>
  </div>

  <div class="grid">
    <div class="card">
      <h2>Управление</h2>
      <button class="btn go" id="b-start" onclick="doStart()">▶ ЗАПУСТИТЬ</button>
      <button class="btn stop" id="b-stop" onclick="doStop()">■ ОСТАНОВИТЬ</button>
      <div class="msg" id="msg"></div>
      <div class="hint">Запуск закрывает старую сессию и поднимает всё заново (~30–60 с).
        Остановка закрывает игры чисто — без окна «crashed» в лаунчере.</div>
    </div>

    <div class="card">
      <h2>FPS (обе игры)</h2>
      <div class="row">
        <input type="number" id="fps" min="0" max="1000" step="1" value="144">
        <button class="apply" onclick="doFps()">Применить</button>
      </div>
      <div class="row">
        <div class="chip" onclick="setFps(60)">60</div>
        <div class="chip" onclick="setFps(100)">100</div>
        <div class="chip" onclick="setFps(120)">120</div>
        <div class="chip" onclick="setFps(144)">144</div>
        <div class="chip" onclick="setFps(165)">165</div>
        <div class="chip" onclick="setFps(240)">240</div>
        <div class="chip gold" onclick="setFps(0)">Без лимита</div>
      </div>
      <div class="now">Сейчас: HN <b id="f-hn">?</b> fps, Minecraft <b id="f-mc">?</b> fps</div>
      <div class="hint">0 = без лимита. VSync выключен, лимит держит сам. Применится
        при следующем старте игр — либо нажми «Остановить» и «Запустить» после смены.</div>
    </div>

    <div class="card wide">
      <h2>Лог последних действий</h2>
      <pre id="log">(пока пусто)</pre>
    </div>
  </div>
</div>

<script>
async function py() { return window.pywebview ? window.pywebview.api : null; }
function $(id) { return document.getElementById(id); }
function setMsg(t) { $("msg").textContent = t || ""; }
function setFps(v) { $("fps").value = v; }

async function refresh() {
  const api = await py(); if (!api) return;
  try {
    const s = await api.status();
    $("d-hn").className = "dot" + (s.hn ? " on" : "");
    $("d-mc").className = "dot" + (s.mc ? " on" : "");
    $("d-br").className = "dot" + (s.bridge ? " on" : "");
    $("d-ln").className = "dot" + (s.launcher ? " on" : "");
    $("f-hn").textContent = (s.fps.hn === null || s.fps.hn === undefined) ? "?" : s.fps.hn;
    $("f-mc").textContent = (s.fps.mc === null || s.fps.mc === undefined) ? "?" : s.fps.mc;
    $("b-start").disabled = s.hn;
    $("b-stop").disabled = !(s.hn || s.mc || s.bridge || s.launcher);
    const lines = (s.play_log || []).concat(s.stop_log || []);
    $("log").textContent = lines.length ? lines.join("\n") : "(пока пусто)";
    $("log").scrollTop = $("log").scrollHeight;
  } catch (e) { }
}

async function doStart() {
  const api = await py(); if (!api) return;
  setMsg("...");
  const r = await api.start();
  setMsg(r.ok ? r.message : r.error);
  setTimeout(refresh, 400);
}
async function doStop() {
  const api = await py(); if (!api) return;
  setMsg("...");
  const r = await api.stop();
  setMsg(r.ok ? r.message : (r.error || ""));
  setTimeout(refresh, 400);
}
async function doFps() {
  const api = await py(); if (!api) return;
  const v = parseInt($("fps").value || "0", 10);
  setMsg("...");
  const r = await api.apply_fps(isNaN(v) ? 0 : v);
  if (r.ok) setMsg("FPS записаны: HN " + r.fps.hn + ", Minecraft " + r.fps.mc + ".");
  else setMsg("Ошибка: " + r.error);
  refresh();
}

window.addEventListener("pywebviewready", refresh);
setInterval(refresh, 2000);
</script>
</body>
</html>
"""


def _webview_env():
    """Изолированный профиль WebView2: иначе окно может остаться прозрачным."""
    data = Path(os.environ.get("LOCALAPPDATA", str(Path.home()))) / "HelloCraft" / "webview2"
    data.mkdir(parents=True, exist_ok=True)
    os.environ["WEBVIEW2_USER_DATA_FOLDER"] = str(data)
    # Не даём WebView2 уходить в аппаратный ускоритель, который на некоторых
    # системах даёт пустое/прозрачное окно при запуске из-под pythonw.
    os.environ.setdefault(
        "WEBVIEW2_ADDITIONAL_BROWSER_ARGUMENTS",
        "--disable-gpu --disable-features=UseOzonePlatform",
    )


def _hide_console():
    """Прячем консольное окно (GUI-приложение)."""
    try:
        import ctypes
        k32 = ctypes.windll.kernel32
        u32 = ctypes.windll.user32
        h = k32.GetConsoleWindow()
        if h:
            u32.ShowWindow(h, 0)  # SW_HIDE
    except Exception:
        pass


def _need_relaunch():
    """pythonw (нет консоли вообще) даёт прозрачное окно WebView2."""
    for stream in (sys.stdout, sys.stderr):
        if stream is None:
            return True
        try:
            stream.fileno()
        except Exception:
            return True
    return False


def _relaunch_with_console():
    """Перезапуск через python.exe с новой консолью (скроет её сам при старте)."""
    exe = sys.executable
    if exe.lower().endswith("pythonw.exe"):
        cand = exe.replace("pythonw.exe", "python.exe")
        if Path(cand).exists():
            exe = cand
    subprocess.Popen(
        [exe, str(Path(__file__).resolve())],
        cwd=str(ROOT),
        creationflags=subprocess.CREATE_NEW_CONSOLE,
    )
    sys.exit(0)


def main():
    if _need_relaunch():
        _relaunch_with_console()
        return
    try:
        import webview  # noqa
    except ImportError:
        print("Ставлю pywebview (нужен один раз)...")
        subprocess.run([sys.executable, "-m", "pip", "install", "--user", "pywebview"], check=True)
        import webview  # noqa
    _webview_env()
    _hide_console()
    api = Api()
    webview.create_window("HelloCraft", html=HTML, js_api=api, width=1020, height=700, resizable=True)
    webview.start()


if __name__ == "__main__":
    main()
