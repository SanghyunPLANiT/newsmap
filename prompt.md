# GLOBAL PULSE — Setup Prompt for Claude Code

Paste this entire file as a message to Claude Code to set up and run the GLOBAL PULSE news map.

---

## What this project is

A single-file (`index.html`) interactive global news map called **GLOBAL PULSE**.
- Uses **Leaflet.js** for the map (CartoDB Dark Matter tiles)
- Fetches real RSS feeds (BBC, Al Jazeera, DW, NPR) via CORS proxy
- Uses **Google News RSS** filtered by the current map viewport
- Uses **Ollama** (local LLM) for accurate geocoding of news articles
- Pins are color-coded by category; clicking a pin opens a news panel
- User can type keywords to filter/search news globally

The entire app lives in `/Users/sanghyun/github/newsmap/index.html`. No build step needed.

---

## Setup Instructions — do all of these

### 1. Make sure Ollama is installed and running

Check if Ollama is installed:
```
which ollama
```

If not installed, install it:
```
brew install ollama
```

Check if the required model is available:
```
ollama list
```

If `qwen2.5:3b` is not listed, pull it:
```
ollama pull qwen2.5:3b
```

### 2. Set OLLAMA_ORIGINS permanently (required for file:// CORS)

The app can be opened directly as a local file (`file://`). Ollama blocks requests from `file://` origin by default. Fix this permanently:

Add to `~/.zshrc`:
```
export OLLAMA_ORIGINS="*"
```

Then reload:
```
source ~/.zshrc
```

Also set it for the current macOS launch environment so it persists across reboots without needing a terminal:
```
launchctl setenv OLLAMA_ORIGINS "*"
```

### 3. Start Ollama with the correct CORS setting

Kill any existing Ollama process and restart it with the env var active:
```
pkill ollama 2>/dev/null; sleep 1
OLLAMA_ORIGINS="*" ollama serve &
```

Wait 2 seconds, then verify Ollama is running:
```
curl -s http://localhost:11434/api/tags | head -c 200
```

### 4. Open the app

The app runs directly from the filesystem — no server needed:
```
open /Users/sanghyun/github/newsmap/index.html
```

Or serve it locally if you prefer (avoids some browser restrictions):
```
cd /Users/sanghyun/github/newsmap && python3 -m http.server 8080
```
Then open: http://localhost:8080

---

## How to use the app

- **Map loads** with global news pins on startup
- **Zoom in** to a region — it fetches news for that area automatically
- **Type a keyword** in the search box (top right) to filter/search all news for that topic
- **Press Escape** or click ✕ to clear the keyword and return to location mode
- **Click any pin** to read the article summary in the right panel
- **Refresh button** (top left) reloads all feeds

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Ollama badge shows "offline" | Run `OLLAMA_ORIGINS="*" ollama serve` in terminal |
| No pins on map | Wait ~5s for RSS feeds to load; check browser console for errors |
| Pins all in wrong cities | Ollama is offline; keyword geocoding is fallback (less accurate) |
| CORS errors in console | Serving from `file://` without `OLLAMA_ORIGINS="*"` set |
| `ollama: command not found` | Install with `brew install ollama` |

---

## Current model

The app prefers `llama3.2` but auto-detects the first available model. Currently installed: `qwen2.5:3b`.

To add a better model for more accurate geocoding:
```
ollama pull llama3.2
```
