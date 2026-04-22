# Narrative OpenClaw Workshop

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/mdowling-functionflow/bankai-openclaw?quickstart=1)

Your own personal OpenClaw, running in GitHub Codespaces. No install, no infrastructure. Works on any university computer with a browser.

## How to launch your OpenClaw

1. **Click the green Open in GitHub Codespaces button above**
2. If GitHub asks, sign in (free account, two minutes to create one)
3. Click **Create codespace on main**
4. Wait two to three minutes while everything downloads and starts
5. The Codespace terminal will print a URL ending in `?token=workshop`
6. Cmd+Click (Mac) or Ctrl+Click (Windows) the URL to open it in a new tab
7. The first time you click Connect you will see "device pairing required". That is expected.
8. Come back to the Codespace terminal and run:

   ```
   ~/pair.sh
   ```

9. Reload the browser tab, click Connect again. You are now using OpenClaw.

If you close the browser tab, your OpenClaw keeps running. Go to [github.com/codespaces](https://github.com/codespaces) to find your workshop codespace and reopen it.

## FAQ

**Do I need my own OpenRouter key?**
No. The instructor provides a shared key via Codespaces secrets. If the setup script asks for a key, the instructor will share one on screen.

**What model am I using?**
Kimi K2.6 via OpenRouter. Released 20 April 2026. Good at long-horizon coding, multi-agent orchestration, and most general tasks. The instructor can switch this in `openclaw.json` if needed.

**Does this cost me anything?**
Zero. GitHub Codespaces free tier covers 120 core-hours per month. A three-hour workshop uses about six of those. OpenRouter calls are paid by the instructor from a shared capped key.

## For the instructor

### One-time setup

1. Create a public GitHub repo, copy these files in, push
2. Edit the badge URL at the top of this README so it points at your repo (two `REPLACE_WITH_...` placeholders)
3. In repo Settings → Secrets and variables → Codespaces → New repository secret, add `OPENROUTER_API_KEY` with your OpenRouter key
4. Go to openrouter.ai/settings/keys and set a credit limit on the key (suggest $50 for a 20-person workshop)
5. Share the repo URL with students

### Smoke test (tonight)

Click your own Open in Codespaces badge. Run through steps 4 to 9 above. Confirm the chat interface loads and Kimi responds to "hello".

### Tear down (after class)

Students' codespaces auto-pause after 30 minutes idle and auto-delete after 30 days. If you want to force-delete sooner:
- Go to github.com/codespaces, find ones belonging to your repo, delete
- Or rotate the `OPENROUTER_API_KEY` secret so further usage fails

### What's under the hood (for troubleshooting)

The Codespace runs Ubuntu with Docker. `coollabsio/openclaw:latest` runs as a container on port 8080. Codespaces forwards the port to a public HTTPS URL. The gateway is configured with `dangerouslyAllowHostHeaderOriginFallback` because Codespaces' proxy presents the browser's origin as `https://localhost:8080`, which the gateway wouldn't otherwise recognise.

Device pairing is the one manual step because OpenClaw 2026.2.21+ requires it for non-localhost connections as a security measure. The `~/pair.sh` convenience script approves all pending requests in one command.
