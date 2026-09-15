#!/usr/bin/env bash
# 在家目录生成 bash ~/start_charge_pile.sh（不装软件、不启动服务）。
# 虚拟机里执行：
#   bash /mnt/hgfs/Small_s3/Charge_pile/scripts/install_start_shortcut.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TARGET="$ROOT/scripts/start_all.sh"
WRAPPER="$HOME/start_charge_pile.sh"

if [[ ! -f "$TARGET" ]]; then
  echo "找不到 $TARGET"
  echo "请用工程里的路径执行，例如："
  echo "  bash /mnt/hgfs/Small_s3/Charge_pile/scripts/install_start_shortcut.sh"
  exit 1
fi

cat > "$WRAPPER" <<EOF
#!/usr/bin/env bash
exec bash "$TARGET" "\$@"
EOF
chmod +x "$WRAPPER" 2>/dev/null || true

COMPLETE_SRC="$ROOT/scripts/start_charge_pile.bash"
if [[ -f "$COMPLETE_SRC" ]]; then
  cp -f "$COMPLETE_SRC" "$HOME/.charge_pile_complete.bash"
  mkdir -p "$HOME/.local/share/bash-completion/completions"
  cp -f "$COMPLETE_SRC" "$HOME/.local/share/bash-completion/completions/start_charge_pile.sh"
  MARKER="# >>> charge-pile-complete"
  if [[ -f "$HOME/.bashrc" ]] && ! grep -q "$MARKER" "$HOME/.bashrc"; then
    {
      echo "$MARKER"
      echo "[[ -f \$HOME/.charge_pile_complete.bash ]] && source \$HOME/.charge_pile_complete.bash"
      echo "# <<< charge-pile-complete"
    } >> "$HOME/.bashrc"
  fi
fi

echo "已写入 $WRAPPER"
echo "指向 $TARGET"
echo
echo "现在可以："
echo "  bash ~/start_charge_pile.sh"
echo "  bash ~/start_charge_pile.sh stop"
echo "  bash ~/start_charge_pile.sh status"
echo
echo "若 Tab 补全还没有，新开一个终端，或执行："
echo "  source ~/.bashrc"
