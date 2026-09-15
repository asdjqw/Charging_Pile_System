#!/usr/bin/env bash
# 安装 systemd 服务与 nginx 反向代理，实现开机自启与 80 端口访问
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

VENV_DIR="${VENV_DIR:-}"
if [[ -z "$VENV_DIR" && -f "$ROOT_DIR/deploy/venv_path.sh" ]]; then
  # shellcheck disable=SC1091
  source "$ROOT_DIR/deploy/venv_path.sh"
fi
VENV_DIR="${VENV_DIR:-$ROOT_DIR/.venv}"

SUDO=""
if [[ "$(id -u)" -ne 0 ]] && command -v sudo >/dev/null 2>&1; then SUDO="sudo"; fi

if command -v systemctl >/dev/null 2>&1; then
  CURRENT_USER="${SUDO_USER:-$(id -un)}"
  sed -e "s#__ROOT_DIR__#${ROOT_DIR}#g" -e "s#__USER__#${CURRENT_USER}#g" -e "s#__VENV_DIR__#${VENV_DIR}#g" \
    deploy/systemd/charging-screen.service | $SUDO tee /etc/systemd/system/charging-screen.service >/dev/null
  $SUDO systemctl daemon-reload
  $SUDO systemctl enable charging-screen
  $SUDO systemctl restart charging-screen
  $SUDO systemctl status charging-screen --no-pager | head -n 12
else
  echo "[WARN] 当前系统无 systemd，跳过服务注册"
fi

if command -v nginx >/dev/null 2>&1; then
  sed "s#__ROOT_DIR__#${ROOT_DIR}#g" deploy/nginx/charging-screen.conf | $SUDO tee /etc/nginx/conf.d/charging-screen.conf >/dev/null
  $SUDO nginx -t && ($SUDO systemctl reload nginx 2>/dev/null || $SUDO nginx -s reload)
  echo "[OK] nginx 已配置，访问 http://<虚拟机IP>/"
else
  echo "[WARN] 未安装 nginx，可继续直接访问 5000 端口"
fi
