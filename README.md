# GLOBAL PULSE

An interactive news map that visualizes world news geographically in real time. Articles are pinned to their exact locations on a dark-themed map, with AI-powered connection lines revealing how stories relate across the globe.

![License](https://img.shields.io/badge/license-GPL--3.0-blue)

## Features

- **Three-panel layout** — news list (left), interactive map (center), article reader (right)
- **Exact geocoding** — articles pinned to city-level locations, not just country centroids
- **AI-powered connections** — click any article to see lines connecting related stories worldwide, with shared themes shown on hover
- **Smart zoom** — zoom in to see more local news; zoom out for global headlines. News auto-fetches based on your viewport
- **40+ RSS feeds** — configurable via `feeds.yaml` (BBC, Al Jazeera, Reuters, Guardian, NPR, and many more)
- **Cluster pins** — multiple stories at the same location show as a numbered dot; click to expand the list
- **Topic detection** — articles classified into Conflict, Politics, Economy, Tech, Climate, Health, Sport
- **Local news search** — when zoomed into a city/country, fetches region-specific news via Google News RSS
- **Ollama AI geocoding** — uses a local LLM to determine the precise location of each news event
- **Ollama content analysis** — extracts semantic tags (people, events, organizations) to find deep connections between articles
- **No backend required** — runs entirely in the browser as a single `index.html` file

## Screenshots

| Global view | Zoomed into region | Article connections |
|---|---|---|
| Pins across the world map | Local news with cluster dots | AI-drawn lines between related stories |

## Quick Start

### Option A: One-click (macOS)

Double-click `Open NewsMap.command` — it starts a local server and opens your browser.

### Option B: Manual

```bash
git clone https://github.com/SanghyunPLANiT/newsmap.git
cd newsmap
python3 -m http.server 8080
# Open http://localhost:8080
```

### Option C: Claude Code (automated setup)

If you have [Claude Code](https://claude.ai/code) installed, paste the contents of `CLAUDE.md` to set up everything automatically, including Ollama.

## Ollama Setup (optional but recommended)

Ollama provides AI-powered geocoding and content analysis. Without it, the app falls back to keyword-based geocoding and simpler topic connections.

### Install

```bash
# macOS
brew install ollama

# Linux
curl -fsSL https://ollama.com/install.sh | sh
```

### Pull a model

```bash
ollama pull qwen2.5:3b      # fast, lightweight (recommended)
# or
ollama pull llama3.2         # more accurate, slower
```

### Start with CORS enabled

The app runs in a browser and needs to reach Ollama's local API. Set the CORS origin:

```bash
# Add to ~/.zshrc or ~/.bashrc for persistence
export OLLAMA_ORIGINS="*"

# Start Ollama
ollama serve
```

On macOS, also run this once so it persists across reboots:
```bash
launchctl setenv OLLAMA_ORIGINS "*"
```

### Verify

```bash
curl -s http://localhost:11434/api/tags
```

You should see your installed models listed.

## Customizing Feeds

Edit `feeds.yaml` to add, remove, or reorganize RSS feeds:

```yaml
global:
  - label: BBC World
    url: https://feeds.bbci.co.uk/news/world/rss.xml
  - label: My Custom Feed
    url: https://example.com/rss.xml

tech:
  - label: Ars Technica
    url: https://feeds.arstechnica.com/arstechnica/index

# Add your own categories
gaming:
  - label: IGN
    url: https://feeds.ign.com/ign/all
```

The app loads the `global` category on startup. Other categories are loaded as you zoom into relevant regions or refresh.

## How It Works

1. **RSS feeds** are fetched via a CORS proxy (`corsproxy.io`) and parsed with `DOMParser`
2. **Keyword geocoding** checks article text against 170+ cities and 73 countries for instant location matching
3. **Ollama geocoding** (if available) sends headlines to a local LLM for precise city-level coordinates
4. **Topic detection** classifies articles using keyword matching across 7 categories
5. **Content analysis** (Ollama) extracts semantic tags (people, events, themes) when you click an article
6. **Connection lines** are drawn to other articles whose text contains those same tags
7. **Viewport-aware fetching** — as you zoom, the app fetches more local news and sorts in-view articles first

## Architecture

```
newsmap/
  index.html           # Entire app (single file, ~1300 lines)
  feeds.yaml           # User-configurable RSS feed list
  CLAUDE.md            # Claude Code automation prompt
  prompt.md            # Legacy setup instructions
  Open NewsMap.command  # macOS double-click launcher
  start.command         # Alternative launcher
  LICENSE              # GPL-3.0
```

### Key Dependencies (loaded via CDN)

- [Leaflet.js](https://leafletjs.com/) — interactive map with CartoDB Dark Matter tiles
- [corsproxy.io](https://corsproxy.io/) — CORS proxy for fetching RSS feeds from the browser

### Local Dependencies (optional)

- [Ollama](https://ollama.com/) — local LLM for geocoding and content analysis

## Troubleshooting

| Problem | Solution |
|---------|----------|
| No news loads | Check internet connection; browser console for CORS errors |
| All pins at country centers | Ollama is offline — install it for city-level precision |
| "Loading..." stuck | CORS proxy may be rate-limited; wait 30s and click Refresh |
| Cluster popup hidden behind panel | Fixed — highlight markers are now non-interactive |
| Ollama CORS error | Run `OLLAMA_ORIGINS="*" ollama serve` |
| `ollama: command not found` | Install: `brew install ollama` (macOS) or see [ollama.com](https://ollama.com/) |

## License

[GPL-3.0](LICENSE)
