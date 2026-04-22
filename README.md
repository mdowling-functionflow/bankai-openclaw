# Narrative OpenClaw Workshop

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/mdowling-functionflow/bankai-openclaw?quickstart=1)

Your own personal OpenClaw running in GitHub Codespaces. No install, no account setup, no infrastructure. Works on any university or locked-down computer with a browser.

## For students: how to launch your OpenClaw

1. Click the green **Open in GitHub Codespaces** button above
2. If prompted, sign in to GitHub (free account, takes two minutes if you don't have one)
3. Click **Create codespace on main**
4. Wait two to three minutes while everything boots
5. The terminal will print a URL ending in `?token=workshop` — Cmd+Click (or Ctrl+Click on Windows) to open it
6. You are now using your own OpenClaw

If you close the browser tab, your OpenClaw keeps running. Come back to [github.com/codespaces](https://github.com/codespaces), find your workshop codespace, and reopen it.

## If you need an OpenRouter key

The instructor will share a workshop key in class. When the Codespace terminal asks for it, paste it in and press Enter. Nothing will show as you paste — that is a security feature.

If you want your own permanent key, it is free to create: go to [openrouter.ai/settings/keys](https://openrouter.ai/settings/keys), generate a key, and set a credit limit so you never get a surprise bill.

## For the instructor: one-time setup

1. Create a new public GitHub repo (any name, e.g. `bankai-openclaw`)
2. Copy all the files from this folder into the repo root and push
3. Edit the badge URL at the top of this README to point at your repo (two `REPLACE_WITH_...` placeholders)
4. Optional but recommended: set an **organization-level** or **repository-level** Codespaces secret named `OPENROUTER_API_KEY` so students do not have to paste it. Go to the repo → Settings → Secrets and variables → Codespaces → New repository secret.
5. Send students the repo URL. They click the badge and go.

### Cost sanity check

Each student gets up to 120 core-hours per month of Codespaces free tier. A two-machine spec (4-core) uses two core-hours per wall-clock hour, so 60 real hours per month. A three-hour workshop consumes six core-hours, which is five percent of their monthly allowance. Zero cost to you or them.

OpenRouter API calls are the real cost. With 20 students using Claude Sonnet via OpenRouter, budget roughly $15 to $40 for the session depending on how much they iterate. Set a hard credit limit on the OpenRouter key before distributing it.

### What happens under the hood

The Codespace boots Ubuntu, installs Docker, and runs `coollabsio/openclaw:latest`. OpenClaw's Control UI is served on port 8080, which Codespaces auto-forwards to a public HTTPS URL. The student opens that URL with `?token=workshop` appended, and the Control UI connects to the gateway via WebSocket. Because the gateway binds to the Codespace's loopback interface and Codespaces' port-forwarding proxy forwards from localhost, OpenClaw grants full operator scope without requiring device pairing.

### Troubleshooting

**The URL 404s or shows "port not forwarded yet"**: the container is still starting. Wait another minute, then click the **PORTS** tab at the bottom of the Codespace, confirm port 8080 is forwarded, and right-click it to open in browser.

**"origin not allowed" when connecting**: the `dangerouslyAllowHostHeaderOriginFallback` setting in `docker-compose.yml` should prevent this, but if a student sees it, open the Codespace terminal and run `docker compose restart openclaw`.

**Student used their free Codespace hours already**: unlikely for a single workshop but possible if they leave codespaces running. They can delete old codespaces at github.com/codespaces to free up the quota.

**OpenRouter rate limit hit**: a student is spamming requests. Raise the OpenRouter credit limit or add per-key rate limiting at openrouter.ai.
