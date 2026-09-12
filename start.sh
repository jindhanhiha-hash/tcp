#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

if [[ -f .env ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

PYTHON_BIN="${PYTHON_BIN:-python3}"
RESTART_DELAY_SECONDS="${RESTART_DELAY_SECONDS:-5}"
BOT_TIMEOUT_SECONDS="${BOT_TIMEOUT_SECONDS:-1800}"
WRITE_CREDENTIAL_FILE="${WRITE_CREDENTIAL_FILE:-1}"

if ! command -v "$PYTHON_BIN" >/dev/null 2>&1; then
  echo "ERROR: Python executable not found: $PYTHON_BIN" >&2
  exit 1
fi

RUN_MODE="${1:-panel}"

if [[ "$RUN_MODE" != "bot" && ! -d node_modules ]]; then
  echo "Installing Node.js control-panel dependencies..."
  npm install --no-audit --no-fund
fi

if [[ ! -d .venv ]]; then
  echo "Creating Python virtual environment..."
  "$PYTHON_BIN" -m venv .venv
fi

source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install --requirement requirements.txt

if [[ "$WRITE_CREDENTIAL_FILE" == "1" && -n "${BOT_UID:-}" && -n "${BOT_PASSWORD:-}" ]]; then
  umask 077
  printf 'uid=%s,password=%s\n' "$BOT_UID" "$BOT_PASSWORD" > shadmancodex.txt
fi

export TCP_PANEL_HOST="${TCP_PANEL_HOST:-0.0.0.0}"
export TCP_PANEL_PORT="${TCP_PANEL_PORT:-8080}"
export AUTO_START_BOT="${AUTO_START_BOT:-0}"
export BOT_TIMEOUT_SECONDS

if [[ "$RUN_MODE" == "bot" ]]; then
  exec python run_bot.py
fi

exec node server.js
