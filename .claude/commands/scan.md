# Scan — Full Project Analysis

Scans the entire project, detects the tech stack and domain, and suggests relevant Claude skills and MCP servers across all applicable categories.

## Execution Instructions

**Step 1 — Detect what's already installed (skip these later)**

- Read `.mcp.json` if it exists → collect already-configured MCP server names
- Read `.claude/commands/` if it exists → collect already-installed skill names

**Step 2 — Detect tech stack and domain**

Read the following files if they exist, and extract meaningful signals:

| File | Signals |
|---|---|
| `package.json` | dependencies, devDependencies, scripts |
| `requirements.txt` / `pyproject.toml` / `setup.py` | Python packages |
| `Cargo.toml` | Rust crates |
| `go.mod` | Go modules |
| `pom.xml` / `build.gradle` | Java/Kotlin libraries |
| `Gemfile` | Ruby gems |
| `composer.json` | PHP packages |
| `Dockerfile` / `docker-compose.yml` | infrastructure patterns |
| `*.tf` / `*.tfvars` | Terraform / cloud infra |
| `k8s/` / `helm/` directories | Kubernetes |
| `.env.example` | integrations hinted by env var names |
| `CLAUDE.md` | project description and context |
| `README.md` | project description |

Also scan directory names and file extensions in the project root for additional signals (e.g. `migrations/`, `prisma/`, `notebooks/`, `contracts/`, `tests/`).

**Step 3 — Deep category matching**

Read the full `predictor/categories.md`. Based on ALL signals collected in Step 2, map to every applicable category — both top-level and subcategory level. Be thorough: a Node.js + PostgreSQL + Docker project should map to Backend Frameworks, Databases SQL, DevOps & Infrastructure, CI/CD, Testing & QA, and more.

**Step 4 — Comprehensive search**

For each cluster of matched categories, search for relevant tools:

*MCP servers:*
- Search Smithery: `https://smithery.ai/search?q=QUERY`
- Reference `predictor/mcp-resources.md` for known directories

*Skills:*
- Search GitHub for matching skill collections
- Reference `predictor/claude-skills-resources.md` for known sources

Use specific technology names in queries (e.g. "postgresql mcp", "docker mcp server", "prisma claude skill").

**Step 5 — Deduplicate**

Remove from results anything already present in `.mcp.json` or `.claude/commands/`.

**Step 6 — Present results grouped by category**

```
Project analysis complete.

Detected stack: [summary of what was found]

Matched categories:
  • Category A — subcategories: x, y, z
  • Category B — subcategories: ...

─────────────────────────────────────────────────────

[Category A]

  Skills:
  [1] name — description — URL

  MCP Servers (no API key):
  [2] name — description — install: npx ...

  MCP Servers (requires API key):
  [3] name — needs: VARNAME — install: npx ...

[Category B]
  ...

─────────────────────────────────────────────────────
Select items to install (numbers, "all", or "skip"):
```

**Step 7 — Install on confirmation**

For each confirmed item:

- **Skill**: Download the `.md` file to `.claude/commands/` in the project root.
- **MCP server**: Add entry to `.mcp.json` (create if needed). For servers requiring an API key, add a placeholder and note the env var.
- Update `predictor/app/context.md`:
  - Add new entries under the appropriate sections with `[ ]`
  - Mark installed items with `[x]` and append `| INSTALLED`
  - Update the `updated:` date at the top
