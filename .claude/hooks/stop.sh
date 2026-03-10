#!/bin/bash
# Predictor Stop Hook
# Reads the last user message, classifies it contextually against top-level
# categories using Claude API, and suggests /predictor search if relevant.
# Silently exits if predictor is disabled or no categories match.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
PREDICTOR_DIR="$PROJECT_ROOT/predictor"
ENABLED_FILE="$PREDICTOR_DIR/app/.enabled"
CATEGORIES_FILE="$PREDICTOR_DIR/categories.md"

# Exit silently if predictor is not enabled
if [ ! -f "$ENABLED_FILE" ]; then
  exit 0
fi

# Exit silently if categories file is missing
if [ ! -f "$CATEGORIES_FILE" ]; then
  exit 0
fi

# Exit silently if no API key
if [ -z "${ANTHROPIC_API_KEY:-}" ]; then
  exit 0
fi

# Read JSON input from stdin
INPUT=$(cat)

# Extract transcript path
TRANSCRIPT_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('transcript_path', ''))
except:
    print('')
" 2>/dev/null || echo "")

if [ -z "$TRANSCRIPT_PATH" ] || [ ! -f "$TRANSCRIPT_PATH" ]; then
  exit 0
fi

# Extract the last user message (max 600 chars to keep API call cheap)
LAST_USER_MSG=$(python3 -c "
import json, sys
try:
    with open('$TRANSCRIPT_PATH') as f:
        data = json.load(f)
    messages = data if isinstance(data, list) else data.get('messages', [])
    for msg in reversed(messages):
        if not isinstance(msg, dict):
            continue
        if msg.get('role') != 'user':
            continue
        content = msg.get('content', '')
        if isinstance(content, list):
            for block in content:
                if isinstance(block, dict) and block.get('type') == 'text':
                    print(block['text'][:600])
                    sys.exit(0)
        elif isinstance(content, str) and content.strip():
            print(content[:600])
            sys.exit(0)
except:
    pass
" 2>/dev/null || echo "")

if [ -z "$LAST_USER_MSG" ]; then
  exit 0
fi

# Extract top-level category names from categories.md
TOP_CATEGORIES=$(grep "^## " "$CATEGORIES_FILE" | sed 's/^## //' | paste -sd "," -)

# Call Claude API — small, fast Haiku model for classification only
RESPONSE=$(curl -sf --max-time 8 https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d "$(python3 -c "
import json, sys
msg = sys.argv[1]
cats = sys.argv[2]
payload = {
    'model': 'claude-haiku-4-5-20251001',
    'max_tokens': 80,
    'messages': [{
        'role': 'user',
        'content': f'Message: \"{msg}\"\n\nCategories: {cats}\n\nWhich categories apply to what the user is trying to accomplish? Return ONLY a comma-separated list of matching category names. Return exactly NONE if nothing matches. No explanation.'
    }]
}
print(json.dumps(payload))
" "$LAST_USER_MSG" "$TOP_CATEGORIES")" 2>/dev/null || echo "")

if [ -z "$RESPONSE" ]; then
  exit 0
fi

# Parse the matched categories from the response
MATCHED=$(echo "$RESPONSE" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    text = d['content'][0]['text'].strip()
    if text.upper() == 'NONE' or not text:
        print('')
    else:
        print(text)
except:
    print('')
" 2>/dev/null || echo "")

if [ -z "$MATCHED" ]; then
  exit 0
fi

# Output the suggestion (appended to Claude's response)
echo ""
echo "---"
echo "💡 **Predictor** detected: *$MATCHED*"
echo "Run \`/predictor search\` to find relevant skills and MCP servers."
