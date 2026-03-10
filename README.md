# Predictor

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Discovers and suggests relevant **Claude skills** and **MCP servers** based on the context of what you're working on.

Works in two modes:
- **Auto** — after each message, silently detects the domain and adds a one-line suggestion if relevant tools exist
- **Manual** — `/predictor search` or `/scan` to search on demand

---

## How It Works

1. Reads your message or project
2. Semantically matches against ~34 top-level categories (backend, design, scraping, research, etc.)
3. If categories are detected → searches Smithery, GitHub, and curated resources
4. Presents results split into: **Skills** | **MCP (no key)** | **MCP (needs API key)**
5. Installs selected tools and tracks everything in `predictor/app/context.md`

---

## Install

Clone this repo inside your project, then run the install script from your **project root**:

```bash
git clone https://github.com/YOUR_USERNAME/predictor
cd your-project
bash predictor/install.sh
```

This copies the skills and hook into your project's `.claude/` directory.

### Update

```bash
cd predictor && git pull
```

Or from inside Claude Code:

```
/predictor update
```

---

## Commands

### `/predictor`

| Command | What it does |
|---|---|
| `/predictor on` | Enable auto-suggest mode |
| `/predictor off` | Disable auto-suggest mode |
| `/predictor search` | Search for skills/MCPs relevant to the current context |
| `/predictor status` | Show `context.md` — what's suggested and installed |
| `/predictor update` | Pull latest categories and resources from GitHub |
| `/predictor clear` | Reset context.md |

### `/scan`

Scans the entire project — reads `package.json`, `requirements.txt`, `Dockerfile`, `CLAUDE.md`, and more — then suggests tools across all detected domains.

---

## Auto Mode (Stop Hook)

When enabled (`/predictor on`), a project-level `Stop` hook fires after each Claude response.

It calls Claude Haiku to classify the last user message against top-level categories. If any categories match, it appends:

```
💡 Predictor detected: Web Scraping & Data Collection, Research & Knowledge Management
Run /predictor search to find relevant skills and MCP servers.
```

If nothing matches → completely silent.

Requires `ANTHROPIC_API_KEY` to be set in your environment.

---

## Context Tracking

All suggestions and installs are tracked in `predictor/app/context.md`:

```markdown
## Suggested Skills
- [ ] wshobson/commands | dev, testing | https://github.com/wshobson/commands
- [x] pdf (anthropics/skills) | INSTALLED

## MCP Servers — No API Key Required
- [ ] postgres-mcp | Query PostgreSQL | npx @modelcontextprotocol/server-postgres
- [x] filesystem | INSTALLED

## MCP Servers — Requires API Key
- [ ] github | needs: GITHUB_TOKEN | npx @modelcontextprotocol/server-github
```

`context.md` and `.enabled` are gitignored — they're local to your machine.

---

## Files

```
predictor/
  install.sh                     ← run once from your project root
  categories.md                  ← ~34 categories with subcategories
  claude-skills-resources.md     ← curated skill sources
  mcp-resources.md               ← curated MCP directories and marketplaces
  .claude/
    commands/
      predictor.md               ← /predictor skill
      scan.md                    ← /scan skill
    hooks/
      stop.sh                    ← auto-suggest hook
  app/
    context.template.md          ← template for context.md
    context.md                   ← gitignored, your local state
    .enabled                     ← gitignored, on/off flag
```

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

The most valuable contributions are:
- New or updated **categories** in `categories.md`
- New **skill sources** in `claude-skills-resources.md`
- New **MCP directories** in `mcp-resources.md`

---

## Requirements

- Claude Code
- `ANTHROPIC_API_KEY` in environment (for auto mode hook)
- `bash`, `python3`, `curl` (standard on macOS/Linux)
