#!/bin/bash
# Runs once when the Codespace is created.
# Installs OpenClaw, writes the right config, pre-creates a shortcut
# for the device-pairing step the student will run after loading the UI.

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
  echo "(The characters won't show as you paste, that's normal.)"
  echo ""
  read -rsp "OpenRouter API key: " OPENROUTER_API_KEY
  echo ""
  export OPENROUTER_API_KEY
fi

# 2. Write .env for docker compose
cat > .env <<ENV
OPENROUTER_API_KEY=${OPENROUTER_API_KEY}
ENV

# 3. Start the stack (pulls ~1.7 GB image on first run)
echo "Starting OpenClaw (this takes 2 to 3 minutes on first run)..."
docker compose pull
docker compose up -d

# 4. Write the config that makes the Control UI work through Codespaces'
#    port-forwarding proxy. The origin the browser sends is https://localhost:8080
#    (Codespaces tunnels it via localhost), and the gateway must recognise that
#    origin and trust the proxy chain.
echo "Configuring OpenClaw gateway..."
sleep 3   # let the container spin up before we exec into it
docker compose exec -u root -T openclaw sh -c 'mkdir -p /data/.openclaw && cat > /data/.openclaw/openclaw.json << "EOF"
{
  "gateway": {
    "trustedProxies": ["127.0.0.1/32", "172.16.0.0/12", "10.0.0.0/8"],
    "controlUi": {
      "allowedOrigins": ["https://localhost:8080", "http://localhost:8080"],
      "dangerouslyAllowHostHeaderOriginFallback": true
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "openrouter/moonshotai/kimi-k2.6"
      }
    }
  },
  "providers": {
    "openrouter": {
      "models": {
        "moonshotai/kimi-k2.6": {
          "contextWindow": 262144,
          "maxOutput": 65536
        }
      }
    }
  }
}
EOF'

# 5. Restart to pick up the config
docker compose restart openclaw

# 6. Wait for the gateway to answer
echo -n "Waiting for OpenClaw gateway to be ready"
for i in {1..60}; do
  if curl -sf --max-time 2 "http://localhost:8080/" >/dev/null 2>&1; then
    echo " ✅"
    break
  fi
  echo -n "."
  sleep 2
done

# 7. Create a convenience script the student can run to approve device pairing
cat > ~/pair.sh <<'PAIR'
#!/bin/bash
# Approves every pending device pairing request. Run this once after you
# see "device pairing required" in your browser.
set -e
cd /workspaces/*/
IDS=$(docker compose exec -T openclaw openclaw devices list --json 2>/dev/null \
      | grep -oE '"requestId":"[^"]+"' \
      | cut -d'"' -f4)
if [ -z "$IDS" ]; then
  echo "No pending pairing requests. Reload the browser tab and try Connect."
  exit 0
fi
for id in $IDS; do
  echo "Approving $id..."
  docker compose exec -T openclaw openclaw devices approve "$id"
done
echo ""
echo "✅ All paired. Reload the browser tab and click Connect."
PAIR
chmod +x ~/pair.sh

# 8. Print instructions
CODESPACE_URL="https://${CODESPACE_NAME}-8080.app.github.dev"

cat <<BANNER

=================================================================
✅ OpenClaw is running!

STEP 1: Open this URL in a new browser tab (Cmd+Click on Mac, Ctrl+Click on Windows):

    ${CODESPACE_URL}/?token=workshop

STEP 2: When you see the screen asking to connect, the first try will show
         "device pairing required". That is normal.

STEP 3: Come back to THIS terminal and run this one command:

    ~/pair.sh

STEP 4: Go back to the browser, reload the page, and click Connect again.

You are now using OpenClaw. Chat away.

If anything misbehaves, ask your instructor, or try:
    docker compose logs openclaw --tail 30

=================================================================

BANNER
