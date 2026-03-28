# CLAUDE.md — Automated Setup for GLOBAL PULSE

This file is a prompt for [Claude Code](https://claude.ai/code). Paste it or reference it to have Claude set up and run the entire project automatically.

## Project Overview

GLOBAL PULSE is a single-file (`index.html`) interactive news map. It shows world news as pins on a dark-themed Leaflet.js map, with AI-powered connections between related stories. Feeds are configured in `feeds.yaml`.

## Automated Setup Instructions

Run the following steps in order. If any step fails, diagnose and fix before continuing.

### 1. Check and install Ollama

```bash
# Check if Ollama is installed
which ollama || echo "NOT INSTALLED"
```

If not installed:
```bash
# macOS
brew install ollama

# Linux (if brew not available)
curl -fsSL https://ollama.com/install.sh | sh
```

### 2. Pull the required model

```bash
ollama list 2>/dev/null | grep -q "qwen2.5:3b" && echo "Model ready" || ollama pull qwen2.5:3b
```

The app auto-detects models in this priority order: `qwen2.5:3b` > `llama3.2:3b` > `mistral:7b` > first available.

### 3. Set CORS origins (required for browser access)

```bash
# Add to shell profile if not already there
grep -q "OLLAMA_ORIGINS" ~/.zshrc 2>/dev/null || echo 'export OLLAMA_ORIGINS="*"' >> ~/.zshrc
source ~/.zshrc

# macOS: persist across reboots without terminal
launchctl setenv OLLAMA_ORIGINS "*" 2>/dev/null
```

### 4. Start Ollama

```bash
# Kill any existing instance and restart with CORS
pkill ollama 2>/dev/null
sleep 1
OLLAMA_ORIGINS="*" nohup ollama serve &>/dev/null &
sleep 2

# Verify it's running
curl -sf http://localhost:11434/api/tags | head -c 200
```

### 5. Launch the app

```bash
cd "$(dirname "$0")" 2>/dev/null || cd /Users/sanghyun/github/newsmap

# Kill any existing server on port 8080
lsof -ti tcp:8080 | xargs kill -9 2>/dev/null

# Start HTTP server (needed for CORS proxy to work)
python3 -m http.server 8080 &
sleep 1

# Open in browser
open "http://localhost:8080" 2>/dev/null || xdg-open "http://localhost:8080" 2>/dev/null || echo "Open http://localhost:8080 in your browser"
```

## Verification Checklist

After setup, verify:
- [ ] `curl -s http://localhost:11434/api/tags` returns model list (Ollama running)
- [ ] `curl -s http://localhost:8080` returns HTML (server running)
- [ ] Browser shows the map with news pins loading
- [ ] Clicking a pin shows the article in the right panel
- [ ] Connection lines appear after clicking an article (may take a few seconds if Ollama is analyzing)

## Development Notes

- **Single-file app**: Everything is in `index.html` (~1300 lines). No build step, no npm, no framework.
- **Feeds config**: `feeds.yaml` — add/remove RSS feeds without touching code.
- **CORS proxy**: Uses `corsproxy.io`. Rate-limited at ~8 concurrent requests. Batched fetching (groups of 2-3) with pauses avoids 429/530 errors.
- **Ollama calls**: Two uses — (1) geocoding articles to lat/lng, (2) content analysis for semantic connections. Both use `qwen2.5:3b` with `temperature: 0`.
- **No auto-refresh on move**: News only refreshes on Refresh button click or viewport change. `flyTo()` from article clicks is suppressed.
- **Articles accumulate**: New fetches merge with existing articles (deduped by title).

## Troubleshooting

If Ollama shows "offline" in the app:
```bash
OLLAMA_ORIGINS="*" ollama serve
```

If feeds fail to load (CORS errors):
```bash
# Must use http:// not file:// — the CORS proxy rejects null origins
python3 -m http.server 8080
```

If the proxy is rate-limiting (429/530):
- Wait 30 seconds, then click Refresh
- The app batches requests automatically, but heavy use can still hit limits
