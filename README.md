# GLOBAL PULSE

Interactive world news map. See breaking news pinned to exact locations, discover connections between stories, and analyze regional trends with AI.

![License](https://img.shields.io/badge/license-GPL--3.0-blue) ![No Build](https://img.shields.io/badge/build-none-blue) ![Ollama](https://img.shields.io/badge/AI-Ollama-purple)

## Features

- **Live news map** — Articles pinned to their exact locations on a dark-themed world map
- **Multi-scale navigation** — Zoom from global headlines down to city-level local news
- **Smart feed selection** — Automatically picks the right news sources for your zoom level:
  - Global → world news feeds (BBC, Guardian, Al Jazeera, Reuters...)
  - Regional → continent-specific feeds (BBC Europe, DW Asia...)
  - National → country-specific feeds (Korea Herald, NHK, Times of India...)
  - City → Google News search + AI geocoding via Ollama
- **Topic connections** — Click a story to see lines connecting related articles across the map
- **AI analysis** — Chat with a local LLM to analyze news trends in the current region
- **100+ RSS feeds** — Configurable via `feeds.yaml`
- **Zero build step** — Single `index.html` file, no npm, no framework

## Quick Start

### One-click install

```bash
git clone https://github.com/SanghyunPLANiT/newsmap.git
cd newsmap
bash install.sh
```

This will:
1. Check/install [Ollama](https://ollama.com) (local AI)
2. Download the `qwen2.5:3b` model (~2GB)
3. Configure CORS for browser access
4. Start all servers and open your browser

### macOS double-click

Double-click `start.command` — it starts everything and opens your browser.

### Manual setup

```bash
# Install Ollama (https://ollama.com)
ollama pull qwen2.5:3b

# Set CORS (required for browser access)
export OLLAMA_ORIGINS="*"
ollama serve &

# Start the app
python3 proxy.py 8081 &
python3 -m http.server 8080 &
open http://localhost:8080
```

### Claude Code (automated)

If you have [Claude Code](https://claude.ai/code), paste the contents of `CLAUDE.md` — it sets up everything automatically.

## How It Works

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│  RSS Feeds   │────▶│  CORS Proxy  │────▶│   Browser   │
│ (100+ feeds) │     │ corsproxy.io │     │  index.html │
└─────────────┘     └──────────────┘     └──────┬──────┘
                                                │
┌─────────────┐     ┌──────────────┐            │
│ Google News  │────▶│ Local Proxy  │────────────┘
│  (per city)  │     │  proxy.py    │
└─────────────┘     └──────────────┘
                                          ┌──────┴──────┐
┌─────────────┐                           │   Ollama    │
│  Nominatim  │◀──────────────────────────│  (local AI) │
│  (OSM geo)  │   reverse geocode         │ qwen2.5:3b  │
└─────────────┘                           └─────────────┘
```

| Zoom | Scope | News Source | Example |
|------|-------|-------------|---------|
| < 4 | Global | Editorial RSS feeds | BBC World, Guardian, Reuters |
| 4-7 | Region | Regional RSS feeds | BBC Europe, DW Asia |
| 7-9 | Country | National RSS feeds | Korea Herald, NHK, Times of India |
| 10+ | City | Google News + Ollama geocoding | "Sapporo news", "Seoul news" |

## Configuration

### feeds.yaml

Add or remove RSS feeds organized by scope:

```yaml
global:
  - label: BBC World
    url: https://feeds.bbci.co.uk/news/world/rss.xml

national/Japan:
  - label: NHK World
    url: https://www3.nhk.or.jp/rss/news/cat0.xml

national/South Korea:
  - label: Korea Herald
    url: https://www.koreaherald.com/common/rss_xml.php?ct=102
```

Categories: `global`, `topic`, `region/<name>`, `national/<country>`

## Architecture

```
newsmap/
  index.html       # Entire app (single file)
  feeds.yaml       # Hierarchical RSS feed config
  proxy.py         # Local CORS proxy for Google News
  install.sh       # One-click installer
  start.command    # macOS launcher (double-click)
  CLAUDE.md        # Claude Code automation prompt
  LICENSE          # GPL-3.0
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Ollama shows "offline" | `OLLAMA_ORIGINS="*" ollama serve` |
| No news loads | Must use `http://localhost:8080`, not `file://` |
| Google News returns nothing | Make sure `proxy.py` runs on port 8081 |
| Rate limiting (429/503) | Wait 30s and click Refresh |
| `ollama: command not found` | `brew install ollama` (macOS) or [ollama.com](https://ollama.com) |

## License

[GPL-3.0](LICENSE)
