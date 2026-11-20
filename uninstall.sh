#!/usr/bin/env bash
# Remove tudo o que o install.sh criou.
BIN="$HOME/.local/bin"; RC="$HOME/.xbindkeysrc"
BEGIN="# >>> janela-padrao >>>"; END="# <<< janela-padrao <<<"

rm -f "$BIN/janela-padrao" "$BIN/janela-padrao-mouse"

if command -v gsettings >/dev/null && gsettings list-schemas | grep -qx org.gnome.settings-daemon.plugins.media-keys; then
  python3 - <<'PY'
import ast, subprocess
K = "org.gnome.settings-daemon.plugins.media-keys"
P = "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/janela-padrao/"
raw = subprocess.check_output(["gsettings", "get", K, "custom-keybindings"], text=True).strip()
lst = [p for p in ast.literal_eval(raw.replace("@as ", "")) if p != P]
subprocess.check_call(["gsettings", "set", K, "custom-keybindings", str(lst)])
for k in ("name", "command", "binding"):
    subprocess.call(["gsettings", "reset", f"{K}.custom-keybinding:{P}", k])
PY
fi

if [ -f "$RC" ]; then sed -i "/^$BEGIN\$/,/^$END\$/d" "$RC"; fi
AUTO="$HOME/.config/autostart/xbindkeys.desktop"
grep -q "criado pelo janela-padrao" "$AUTO" 2>/dev/null && rm -f "$AUTO"
pkill -x xbindkeys 2>/dev/null
if [ -s "$RC" ] && grep -qE '^"' "$RC"; then (setsid xbindkeys >/dev/null 2>&1 &); fi
rm -rf "${XDG_CONFIG_HOME:-$HOME/.config}/janela-padrao"
echo "janela-padrao removido."
