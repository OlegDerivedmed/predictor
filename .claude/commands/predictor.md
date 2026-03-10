# Predictor — Skills & MCP Discovery

Discovers and suggests relevant Claude skills and MCP servers based on the current context. Tracks what has been suggested and installed.

## Usage

```
/predictor on      — enable auto-suggest mode (hook activates on every message)
/predictor off     — disable auto-suggest mode
/predictor search  — manually search skills/MCPs for the current context
/predictor status  — show context.md: what's suggested and installed
/predictor update  — update categories and resources via git pull
/predictor clear   — reset context.md to empty template
```

## Execution Instructions

Parse the argument after `/predictor` and follow the matching section below.

---

### `on`

Create the file `predictor/app/.enabled` (empty file is fine).
Confirm: "Predictor auto-suggest enabled. I'll suggest relevant skills and MCP servers after relevant messages."

---

### `off`

Delete `predictor/app/.enabled` if it exists.
Confirm: "Predictor auto-suggest disabled."

---

### `search` (or no argument — default action)

**Step 1 — Gather context**
Use the most recent user message in this conversation as the context to analyze.
If the user passed additional text after `/predictor search`, use that text instead.

**Step 2 — Top-level category matching (Level 1)**
Read `predictor/categories.md`. Extract only the `## Heading` lines — these are the top-level categories.
Semantically determine which top-level categories apply to the context. Think about what the user is trying to accomplish, not just keywords. A message like "fetch data from a website" should match "Web Scraping & Data Collection" even without those exact words.

If no categories match → output:
```
No relevant categories detected for this context.
```
Then stop.

**Step 3 — Deep matching (Level 2)**
For each matched top-level category, read the subcategory items listed under it in `predictor/categories.md`.
Identify the specific technologies/tools within those categories that are most relevant to the context.
These will be used to form precise search queries.

**Step 4 — Search**
Using the matched categories and specific technologies, search for:

*MCP servers:*
- Search Smithery: `https://smithery.ai/search?q=QUERY` (use 2–3 targeted queries)
- Reference `predictor/mcp-resources.md` for known directories and awesome-lists

*Skills:*
- Search GitHub: `https://github.com/search?q=QUERY+claude+skill` or `QUERY+claude+commands`
- Reference `predictor/claude-skills-resources.md` for known collections

**Step 5 — Present results**

Show matched categories first, then results split into three groups:

```
Detected categories: [list]

── Skills ────────────────────────────────────────────
[1] name — description — URL

── MCP Servers (no API key needed) ──────────────────
[2] name — description — install: npx ...

── MCP Servers (requires API key) ───────────────────
[3] name — needs: VARNAME — install: npx ...

Install all? Enter numbers to select (e.g. 1,3) or "all" or "skip":
```

**Step 6 — Install on confirmation**

For each confirmed item:

- **Skill**: Download the `.md` file to `.claude/commands/` in the project root. If it's a GitHub repo with multiple skills, ask which specific commands the user wants.
- **MCP server**: Add an entry to `.mcp.json` in the project root (create file if it doesn't exist). For servers requiring an API key, add a placeholder value and note the env var name.
- Update `predictor/app/context.md`:
  - Add new suggestions under the appropriate section with `[ ]`
  - Mark installed items with `[x]` and append `| INSTALLED`
  - Update the `updated:` date at the top

---

### `status`

Read and display `predictor/app/context.md`.
If the file doesn't exist: "No context yet. Run `/predictor search` to get started."

---

### `update`

Run: `git -C predictor pull origin main`
Report what files changed. If not a git repo, say: "predictor/ is not a git repository. Clone from GitHub to enable updates."

---

### `clear`

Copy `predictor/app/context.template.md` to `predictor/app/context.md` (overwrite).
Confirm: "Context cleared."
