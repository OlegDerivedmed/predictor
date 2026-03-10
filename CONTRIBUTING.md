# Contributing to Predictor

Contributions are welcome. The project improves when the community keeps categories, skills, and MCP resources up to date.

---

## What to Contribute

### 1. Categories (`categories.md`)

Add new top-level categories or subcategory items that are missing.

Guidelines:
- Top-level categories use `## Heading` format
- Subcategory items are plain list items under the heading
- Keep names concise and recognizable (technology/tool names, not descriptions)
- Check for duplicates before adding

### 2. Skill Resources (`claude-skills-resources.md`)

Add new sources where Claude skills/commands can be found.

Guidelines:
- Include the URL, a short description, and the section it belongs to
- Prefer sources with multiple skills over single-skill repos
- Verify the link is active before submitting

### 3. MCP Resources (`mcp-resources.md`)

Add new MCP server directories, marketplaces, or notable individual servers.

Guidelines:
- For directories/marketplaces: include URL + approximate server count if known
- For individual servers: include install command and whether an API key is required
- Note the category the server belongs to

### 4. Hook or Skill Improvements

If you improve the logic of `stop.sh`, `predictor.md`, or `scan.md`, please include:
- A clear description of what changed and why
- Any edge cases your change handles

---

## How to Submit

1. Fork this repository
2. Create a branch: `git checkout -b add/my-contribution`
3. Make your changes
4. Open a Pull Request with a short description

---

## What Not to Contribute

- Paid/closed services without a free tier
- Broken or unmaintained links
- Duplicate entries
- Changes to `app/` directory (it's gitignored and user-local)
