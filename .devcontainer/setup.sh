#!/bin/bash
# Runs once when the Codespace is created.
# Starts OpenClaw in a container, waits for it to be ready, prints the URL.

set -euo pipefail

echo ""
echo "🦞 Narrative OpenClaw Workshop — setup starting"
echo "=================================================="
echo ""

# 1. Check for OpenRouter API key
if [ -z "${OPENROUTER_API_KEY:-}" ]; then
  echo "No OPENROUTER_API_KEY found in Codespaces secrets."
  echo ""
  echo "Your instructor will provide a key. Paste it below and press Enter."
  echo "(The characters won't show as you paste — that's normal.)"
  echo ""
  read -rsp "OpenRouter API key: " OPENROUTER_API_KEY
  echo ""
  export OPENROUTER_API_KEY
fi

# 2. Write .env for docker compose
cat > .env <<ENV
OPENROUTER_API_KEY=${OPENROUTER_API_KEY}
ENV

# 3. Start the stack
echo "Starting OpenClaw (this takes 2 to 3 minutes on first run — Docker image is ~2 GB)..."
docker compose pull
docker compose up -d

# 4. Wait for OpenClaw to answer
echo -n "Waiting for OpenClaw to be ready"
for i in {1..120}; do
  if curl -sf --max-time 2 "http://localhost:8080/" >/dev/null 2>&1; then
    echo ""
    break
  fi
  echo -n "."
  sleep 2
done

# 5. Print the URL the student should open
CODESPACE_URL="https://${CODESPACE_NAME}-8080.app.github.dev"

cat <<BANNER

==========================================================
✅ OpenClaw is running!

Open this URL in a new browser tab (Cmd+Click / Ctrl+Click):

  ${CODESPACE_URL}/?token=workshop

If it doesn't load straight away:
  - Click the PORTS tab at the bottom of VS Code
  - Right-click port 8080 → "Open in Browser"
  - Add ?token=workshop to the end of the URL

==========================================================

BANNER
