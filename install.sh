#!/usr/bin/env bash
# Instala o janela-padrao para o usuário atual (sem sudo).
set -e
dir=$(cd "$(dirname "$0")" && pwd)
BIN="$HOME/.local/bin"
RC="$HOME/.xbindkeysrc"
BEGIN="# >>> janela-padrao >>>"; END="# <<< janela-padrao <<<"

echo "== janela-padrao: instalação =="

if [ "${XDG_SESSION_TYPE:-}" = "wayland" ]; then
  echo "AVISO: sessão Wayland detectada. Este projeto usa X11 (wmctrl/xdotool)."
  echo "       Faça login em uma sessão X11 (\"Ubuntu on Xorg\") para funcionar."
fi

missing=""
for c in xdotool wmctrl xprop xrandr xbindkeys; do command -v "$c" >/dev/null || missing="$missing $c"; done
if [ -n "$missing" ]; then
  echo "Faltam programas:$missing"
  if   command -v apt    >/dev/null; then echo "  sudo apt install xdotool wmctrl x11-utils x11-xserver-utils xbindkeys"
  elif command -v dnf    >/dev/null; then echo "  sudo dnf install xdotool wmctrl xorg-x11-utils xrandr xbindkeys"
  elif command -v pacman >/dev/null; then echo "  sudo pacman -S xdotool wmctrl xorg-xprop xorg-xrandr xbindkeys"
  else echo "  instale: xdotool wmctrl xprop xrandr xbindkeys"; fi
  echo "Instale e rode ./install.sh de novo."
  exit 1
fi

# 1) scripts
mkdir -p "$BIN"
install -m 755 "$dir/bin/janela-padrao" "$dir/bin/janela-padrao-mouse" "$BIN/"
echo "✓ scripts em $BIN"
case ":$PATH:" in *":$BIN:"*) ;; *) echo "  (dica: $BIN não está no seu PATH)";; esac

# 2) atalho de teclado (GNOME): Super+Shift+B
if command -v gsettings >/dev/null && gsettings list-schemas | grep -qx org.gnome.settings-daemon.plugins.media-keys; then
  python3 - "$BIN" <<'PY'
import ast, subprocess, sys
K = "org.gnome.settings-daemon.plugins.media-keys"
P = "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/janela-padrao/"
raw = subprocess.check_output(["gsettings", "get", K, "custom-keybindings"], text=True).strip()
lst = ast.literal_eval(raw.replace("@as ", ""))
if P not in lst:
    lst.append(P)
    subprocess.check_call(["gsettings", "set", K, "custom-keybindings", str(lst)])
S = f"{K}.custom-keybinding:{P}"
subprocess.check_call(["gsettings", "set", S, "name", "Janela no padrão"])
subprocess.check_call(["gsettings", "set", S, "command", f"{sys.argv[1]}/janela-padrao"])
subprocess.check_call(["gsettings", "set", S, "binding", "<Super><Shift>b"])
PY
  echo "✓ atalho Super+Shift+B (GNOME)"
else
  echo "• Sem GNOME: crie você mesmo um atalho de teclado para: $BIN/janela-padrao"
fi

# 3) Super+Shift+duplo clique (xbindkeys)
touch "$RC"
if [ -f "$HOME/.xbindkeysrc.scm" ]; then
  echo "AVISO: existe ~/.xbindkeysrc.scm; ele tem prioridade sobre ~/.xbindkeysrc."
  echo "       Adicione manualmente: (xbindkey '(mod4 shift b:1) \"$BIN/janela-padrao-mouse\")"
fi
if ! grep -qF "$BEGIN" "$RC"; then
  cat >> "$RC" <<RCEOF

$BEGIN
# Super + Shift + duplo clique: janela sob o cursor vai pro padrão
"$BIN/janela-padrao-mouse"
    Mod4 + Shift + b:1
$END
RCEOF
fi
AUTO="$HOME/.config/autostart/xbindkeys.desktop"
if [ ! -f "$AUTO" ]; then
  mkdir -p "$(dirname "$AUTO")"
  cat > "$AUTO" <<AEOF
[Desktop Entry]
Type=Application
Name=xbindkeys
Exec=xbindkeys
X-GNOME-Autostart-enabled=true
NoDisplay=true
# criado pelo janela-padrao
AEOF
fi
pkill -x xbindkeys 2>/dev/null || true
sleep 0.3
(setsid xbindkeys >/dev/null 2>&1 &)
echo "✓ Super+Shift+duplo clique (xbindkeys)"

echo
echo "Pronto. Use Super+Shift+B (janela em foco) ou Super+Shift+duplo clique (janela sob o mouse)."
echo "Ajustes: veja o README (arquivo ~/.config/janela-padrao/config)."
