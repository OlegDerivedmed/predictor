#!/bin/bash
# Predictor Install Script
# Installs the /predictor and /scan skills and the stop hook into your project.
# Run this from inside your project root:
#   bash path/to/predictor/install.sh

set -euo pipefail

PREDICTOR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(pwd)"

# Don't install into the predictor repo itself
if [ "$PROJECT_ROOT" = "$PREDICTOR_DIR" ]; then
  echo "Run this script from your project root, not from inside predictor/."
  echo "Example: cd ~/my-project && bash predictor/install.sh"
  exit 1
fi

echo "Installing Predictor into: $PROJECT_ROOT"
echo ""

# Create .claude directories
mkdir -p "$PROJECT_ROOT/.claude/commands"
mkdir -p "$PROJECT_ROOT/.claude/hooks"

# Install skills
cp "$PREDICTOR_DIR/.claude/commands/predictor.md" "$PROJECT_ROOT/.claude/commands/predictor.md"
cp "$PREDICTOR_DIR/.claude/commands/scan.md" "$PROJECT_ROOT/.claude/commands/scan.md"
echo "✓ Skills installed: /predictor, /scan"

# Install stop hook
HOOK_TARGET="$PROJECT_ROOT/.claude/hooks/stop.sh"

if [ -f "$HOOK_TARGET" ]; then
  echo ""
  echo "⚠  A stop hook already exists at .claude/hooks/stop.sh"
  echo "   Overwrite? [y/N]"
  read -r REPLY
  if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
    echo "   Skipped. Manually append predictor/stop.sh logic to your existing hook."
  else
    cp "$PREDICTOR_DIR/.claude/hooks/stop.sh" "$HOOK_TARGET"
    chmod +x "$HOOK_TARGET"
    echo "✓ Stop hook installed"
  fi
else
  cp "$PREDICTOR_DIR/.claude/hooks/stop.sh" "$HOOK_TARGET"
  chmod +x "$HOOK_TARGET"
  echo "✓ Stop hook installed"
fi

# Initialize context file if not present
mkdir -p "$PREDICTOR_DIR/app"
if [ ! -f "$PREDICTOR_DIR/app/context.md" ]; then
  cp "$PREDICTOR_DIR/app/context.template.md" "$PREDICTOR_DIR/app/context.md"
  echo "✓ Context file initialized"
else
  echo "✓ Context file already exists, skipping"
fi

echo ""
echo "Done. Next steps:"
echo "  /predictor on     — enable auto-suggest after each message"
echo "  /predictor search — manually search for tools based on current context"
echo "  /scan             — analyze your whole project and get suggestions"
