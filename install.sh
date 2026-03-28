#!/bin/bash
# ══════════════════════════════════════════════════════════
# GLOBAL PULSE — One-Click Installer
# ══════════════════════════════════════════════════════════
# Installs all dependencies and launches the app.
# Works on macOS and Linux. Run with:
#   bash install.sh
# ══════════════════════════════════════════════════════════

set -e
cd "$(dirname "$0")"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[✓]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
fail()  { echo -e "${RED}[✗]${NC} $1"; exit 1; }

echo ""
echo "  ╔══════════════════════════════════════╗"
echo "  ║       GLOBAL PULSE — Installer       ║"
echo "  ╚══════════════════════════════════════╝"
echo ""

# ── 1. Check Python 3 ──
if command -v python3 &>/dev/null; then
  info "Python 3 found: $(python3 --version)"
else
  fail "Python 3 is required but not found. Install it first."
fi

# ── 2. Check & Install Ollama ──
if command -v ollama &>/dev/null; then
  info "Ollama found: $(ollama --version 2>/dev/null || echo 'installed')"
else
  warn "Ollama not found. Installing..."
  if [[ "$OSTYPE" == "darwin"* ]]; then
    if command -v brew &>/dev/null; then
      brew install ollama
    else
      echo "  Please install Ollama from https://ollama.com/download"
      echo "  Then re-run this script."
      exit 1
    fi
  else
    curl -fsSL https://ollama.com/install.sh | sh
  fi
  if command -v ollama &>/dev/null; then
    info "Ollama installed successfully"
  else
    fail "Ollama installation failed. Install manually from https://ollama.com"
  fi
fi

# ── 3. Pull AI model ──
MODEL="qwen2.5:3b"
if ollama list 2>/dev/null | grep -q "$MODEL"; then
  info "Model $MODEL is ready"
else
  warn "Downloading model $MODEL (this may take a few minutes)..."
  ollama pull $MODEL
  info "Model $MODEL downloaded"
fi

# ── 4. Configure CORS ──
if [[ "$OSTYPE" == "darwin"* ]]; then
  launchctl setenv OLLAMA_ORIGINS "*" 2>/dev/null || true
fi
export OLLAMA_ORIGINS="*"

# Add to shell profile if not already there
SHELL_RC=""
if [ -f "$HOME/.zshrc" ]; then SHELL_RC="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then SHELL_RC="$HOME/.bashrc"
fi
if [ -n "$SHELL_RC" ] && ! grep -q "OLLAMA_ORIGINS" "$SHELL_RC" 2>/dev/null; then
  echo 'export OLLAMA_ORIGINS="*"' >> "$SHELL_RC"
  info "Added OLLAMA_ORIGINS to $SHELL_RC"
else
  info "OLLAMA_ORIGINS already configured"
fi

# ── 5. Start Ollama ──
if curl -sf http://localhost:11434/api/tags &>/dev/null; then
  info "Ollama is already running"
else
  warn "Starting Ollama..."
  pkill ollama 2>/dev/null || true
  sleep 1
  OLLAMA_ORIGINS="*" nohup ollama serve &>/dev/null &
  sleep 3
  if curl -sf http://localhost:11434/api/tags &>/dev/null; then
    info "Ollama started"
  else
    warn "Ollama may take a moment to start. Continuing..."
  fi
fi

# ── 6. Make start.command executable ──
chmod +x start.command 2>/dev/null || true
info "start.command is executable (double-click to launch)"

# ── 7. Launch ──
echo ""
echo -e "${GREEN}  Installation complete!${NC}"
echo ""
echo "  Starting GLOBAL PULSE..."
echo ""

PORT=8080
PROXY_PORT=8081

# Kill anything on those ports
lsof -ti tcp:$PORT | xargs kill -9 2>/dev/null || true
lsof -ti tcp:$PROXY_PORT | xargs kill -9 2>/dev/null || true

# Start local CORS proxy
python3 proxy.py $PROXY_PORT &
PROXY_PID=$!

# Start HTTP server
python3 -m http.server $PORT &
SERVER_PID=$!

sleep 1

# Open browser
if [[ "$OSTYPE" == "darwin"* ]]; then
  open "http://localhost:$PORT"
elif command -v xdg-open &>/dev/null; then
  xdg-open "http://localhost:$PORT"
else
  echo "  Open http://localhost:$PORT in your browser"
fi

echo ""
echo "  ┌──────────────────────────────────────┐"
echo "  │  GLOBAL PULSE running!               │"
echo "  │                                      │"
echo "  │  App:   http://localhost:$PORT        │"
echo "  │  Proxy: http://localhost:$PROXY_PORT        │"
echo "  │  Ollama: http://localhost:11434       │"
echo "  │                                      │"
echo "  │  Press Ctrl-C to stop.               │"
echo "  └──────────────────────────────────────┘"
echo ""

trap "kill $SERVER_PID $PROXY_PID 2>/dev/null" EXIT
wait $SERVER_PID
