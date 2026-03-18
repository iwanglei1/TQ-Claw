# CLI

`tqclaw` is the command-line tool for TQ-Claw. This page is organized from
"get-up-and-running" to "advanced management" — read from top to bottom if
you're new, or jump to the section you need.

> Not sure what "channels", "heartbeat", or "cron" mean? See
> [Introduction](./intro) first.

---

## Getting started

These are the commands you'll use on day one.

### tqclaw init

First-time setup. Walks you through configuration interactively.

```bash
tqclaw init              # Interactive setup (recommended for first time)
tqclaw init --defaults   # Non-interactive, use all defaults (good for scripts)
tqclaw init --force      # Overwrite existing config files
```

**What the interactive flow covers (in order):**

1. **Heartbeat** — interval (e.g. `30m`), target (`main` / `last`), optional
   active hours.
2. **Show tool details** — whether tool call details appear in channel messages.
3. **Language** — `zh` / `en` / `ru` for agent persona files (SOUL.md, etc.).
4. **Channels** — optionally configure iMessage / Discord / DingTalk / Feishu /
   QQ / Console.
5. **LLM provider** — select provider, enter API key, choose model (**required**).
6. **Skills** — enable all / none / custom selection.
7. **Environment variables** — optionally add key-value pairs for tools.
8. **HEARTBEAT.md** — edit the heartbeat checklist in your default editor.

### tqclaw app

Start the TQ-Claw server. Everything else — channels, cron jobs, the Console
UI — depends on this.

```bash
tqclaw app                             # Start on 127.0.0.1:8088
tqclaw app --host 0.0.0.0 --port 9090 # Custom address
tqclaw app --reload                    # Auto-reload on code change (dev)
tqclaw app --workers 4                 # Multi-worker mode
tqclaw app --log-level debug           # Verbose logging
```

| Option        | Default     | Description                                                   |
| ------------- | ----------- | ------------------------------------------------------------- |
| `--host`      | `127.0.0.1` | Bind host                                                     |
| `--port`      | `8088`      | Bind port                                                     |
| `--reload`    | off         | Auto-reload on file changes (dev only)                        |
| `--workers`   | `1`         | Number of worker processes                                    |
| `--log-level` | `info`      | `critical` / `error` / `warning` / `info` / `debug` / `trace` |

### Console

Once `tqclaw app` is running, open `http://127.0.0.1:8088/` in your browser to
access the **Console** — a web UI for chat, channels, cron, skills, models,
and more. See [Console](./console) for a full walkthrough.

If the frontend was not built, the root URL returns a JSON message like `{"message": "TQ-Claw Web Console is not available."}` but the API still works.

**To build the frontend:** in the project's `console/` directory run
`npm ci && npm run build`, then copy the output to the package directory:
`mkdir -p src/tqclaw/console && cp -R console/dist/. src/tqclaw/console/`.
Docker images and pip packages already include the Console.

### tqclaw daemon

Inspect status, version, and recent logs without starting a conversation. Same
behavior as sending `/daemon status` etc. in chat (CLI can show local info when
the app is not running).

| Command                      | Description                                                                               |
| ---------------------------- | ----------------------------------------------------------------------------------------- |
| `tqclaw daemon status`        | Status (config, working dir, memory manager)                                              |
| `tqclaw daemon restart`       | Print instructions (in-chat /daemon restart does in-process reload)                       |
| `tqclaw daemon reload-config` | Re-read and validate config (channel/MCP changes need /daemon restart or process restart) |
| `tqclaw daemon version`       | Version and paths                                                                         |
| `tqclaw daemon logs [-n N]`   | Last N lines of log (default 100; from `tqclaw.log` in working dir)                        |

**Multi-Agent Support:** All commands support the `--agent-id` parameter (defaults to `default`).

```bash
tqclaw daemon status                     # Default agent status
tqclaw daemon status --agent-id abc123   # Specific agent status
tqclaw daemon version
tqclaw daemon logs -n 50
```

---

## Models & environment variables

Before using TQ-Claw you need at least one LLM provider configured. Environment
variables power many built-in tools (e.g. web search).

### tqclaw models

Manage LLM providers and the active model.

| Command                                | What it does                                         |
| -------------------------------------- | ---------------------------------------------------- |
| `tqclaw models list`                    | Show all providers, API key status, and active model |
| `tqclaw models config`                  | Full interactive setup: API keys → active model      |
| `tqclaw models config-key [provider]`   | Configure a single provider's API key                |
| `tqclaw models set-llm`                 | Switch the active model (API keys unchanged)         |
| `tqclaw models download <repo_id>`      | Download a local model (llama.cpp / MLX)             |
| `tqclaw models local`                   | List downloaded local models                         |
| `tqclaw models remove-local <model_id>` | Delete a downloaded local model                      |
| `tqclaw models ollama-pull <model>`     | Download an Ollama model                             |
| `tqclaw models ollama-list`             | List Ollama models                                   |
| `tqclaw models ollama-remove <model>`   | Delete an Ollama model                               |

```bash
tqclaw models list                    # See what's configured
tqclaw models config                  # Full interactive setup
tqclaw models config-key modelscope   # Just set ModelScope's API key
tqclaw models config-key dashscope    # Just set DashScope's API key
tqclaw models config-key custom       # Set custom provider (Base URL + key)
tqclaw models set-llm                 # Change active model only
```

#### Local models

TQ-Claw can also run models locally via llama.cpp or MLX — no API key needed.
Install the backend first: `pip install 'tqclaw[llamacpp]'` or
`pip install 'tqclaw[mlx]'`.

```bash
# Download a model (auto-selects Q4_K_M GGUF)
tqclaw models download Qwen/Qwen3-4B-GGUF

# Download an MLX model
tqclaw models download Qwen/Qwen3-4B --backend mlx

# Download from ModelScope
tqclaw models download Qwen/Qwen2-0.5B-Instruct-GGUF --source modelscope

# List downloaded models
tqclaw models local
tqclaw models local --backend mlx

# Delete a downloaded model
tqclaw models remove-local <model_id>
tqclaw models remove-local <model_id> --yes   # skip confirmation
```

| Option      | Short | Default       | Description                                                           |
| ----------- | ----- | ------------- | --------------------------------------------------------------------- |
| `--backend` | `-b`  | `llamacpp`    | Target backend (`llamacpp` or `mlx`)                                  |
| `--source`  | `-s`  | `huggingface` | Download source (`huggingface` or `modelscope`)                       |
| `--file`    | `-f`  | _(auto)_      | Specific filename. If omitted, auto-selects (prefers Q4_K_M for GGUF) |

#### Ollama models

TQ-Claw integrates with Ollama to run models locally. Models are dynamically loaded from your Ollama daemon — install Ollama first from [ollama.com](https://ollama.com).

Install the Ollama SDK: `pip install 'tqclaw[ollama]'` (or re-run the installer with `--extras ollama`)

```bash
# Download an Ollama model
tqclaw models ollama-pull mistral:7b
tqclaw models ollama-pull qwen3:8b

# List Ollama models
tqclaw models ollama-list

# Remove an Ollama model
tqclaw models ollama-remove mistral:7b
tqclaw models ollama-remove qwen3:8b --yes   # skip confirmation

# Use in config flow (auto-detects Ollama models)
tqclaw models config           # Select Ollama → Choose from model list
tqclaw models set-llm          # Switch to a different Ollama model
```

**Key differences from local models:**

- Models come from Ollama daemon (not downloaded by TQ-Claw)
- Use `ollama-pull` / `ollama-remove` instead of `download` / `remove-local`
- Model list updates dynamically when you add/remove via Ollama CLI or TQ-Claw

> **Note:** You are responsible for ensuring the API key is valid. TQ-Claw does
> not verify key correctness. See [Config — LLM Providers](./config#llm-providers).

### tqclaw env

Manage environment variables used by tools and skills at runtime.

| Command                   | What it does                  |
| ------------------------- | ----------------------------- |
| `tqclaw env list`          | List all configured variables |
| `tqclaw env set KEY VALUE` | Set or update a variable      |
| `tqclaw env delete KEY`    | Delete a variable             |

```bash
tqclaw env list
tqclaw env set TAVILY_API_KEY "tvly-xxxxxxxx"
tqclaw env set GITHUB_TOKEN "ghp_xxxxxxxx"
tqclaw env delete TAVILY_API_KEY
```

> **Note:** TQ-Claw only stores and loads these values; you are responsible for
> ensuring they are correct. See
> [Config — Environment Variables](./config#environment-variables).

---

## Channels

Connect TQ-Claw to messaging platforms.

### tqclaw channels

Manage channel configuration (iMessage, Discord, DingTalk, Feishu, QQ,
Console, etc.). **Note:** Use `config` for interactive setup (no `configure`
subcommand); use `remove` to uninstall custom channels (no `uninstall`).

| Command                        | What it does                                                                                                      |
| ------------------------------ | ----------------------------------------------------------------------------------------------------------------- |
| `tqclaw channels list`          | Show all channels and their status (secrets masked)                                                               |
| `tqclaw channels install <key>` | Install a channel into `custom_channels/`: create stub or use `--path`/`--url`                                    |
| `tqclaw channels add <key>`     | Install and add to config; built-in channels only get config entry; supports `--path`/`--url`                     |
| `tqclaw channels remove <key>`  | Remove a custom channel from `custom_channels/` (built-ins cannot be removed); `--keep-config` keeps config entry |
| `tqclaw channels config`        | Interactively enable/disable channels and fill in credentials                                                     |

**Multi-Agent Support:** All commands support the `--agent-id` parameter (defaults to `default`).

```bash
tqclaw channels list                    # See default agent's channels
tqclaw channels list --agent-id abc123  # See specific agent's channels
tqclaw channels install my_channel      # Create custom channel stub
tqclaw channels install my_channel --path ./my_channel.py
tqclaw channels add dingtalk            # Add DingTalk to config
tqclaw channels remove my_channel       # Remove custom channel (and from config by default)
tqclaw channels remove my_channel --keep-config   # Remove module only, keep config entry
tqclaw channels config                  # Configure default agent
tqclaw channels config --agent-id abc123 # Configure specific agent
```

The interactive `config` flow lets you pick a channel, enable/disable it, and enter credentials. It loops until you choose "Save and exit".

| Channel      | Fields to fill in                                                                    |
| ------------ | ------------------------------------------------------------------------------------ |
| **iMessage** | Bot prefix, database path, poll interval                                             |
| **Discord**  | Bot prefix, Bot Token, HTTP proxy, proxy auth                                        |
| **DingTalk** | Bot prefix, Client ID, Client Secret, Message Type, Card Template ID/Key, Robot Code |
| **Feishu**   | Bot prefix, App ID, App Secret                                                       |
| **QQ**       | Bot prefix, App ID, Client Secret                                                    |
| **Console**  | Bot prefix                                                                           |

> For platform-specific credential setup, see [Channels](./channels).

---

## Cron (scheduled tasks)

Create jobs that run on a timed schedule — "every day at 9am", "every 2 hours
ask TQ-Claw and send the reply". **Requires `tqclaw app` to be running.**

### tqclaw cron

| Command                      | What it does                                  |
| ---------------------------- | --------------------------------------------- |
| `tqclaw cron list`            | List all jobs                                 |
| `tqclaw cron get <job_id>`    | Show a job's spec                             |
| `tqclaw cron state <job_id>`  | Show runtime state (next run, last run, etc.) |
| `tqclaw cron create ...`      | Create a job                                  |
| `tqclaw cron delete <job_id>` | Delete a job                                  |
| `tqclaw cron pause <job_id>`  | Pause a job                                   |
| `tqclaw cron resume <job_id>` | Resume a paused job                           |
| `tqclaw cron run <job_id>`    | Run once immediately                          |

**Multi-Agent Support:** All commands support the `--agent-id` parameter (defaults to `default`).

### Creating jobs

**Option 1 — CLI arguments (simple jobs)**

Two task types:

- **text** — send a fixed message to a channel on schedule.
- **agent** — ask TQ-Claw a question on schedule and deliver the reply.

```bash
# Text: send "Good morning!" to DingTalk every day at 9:00 (default agent)
tqclaw cron create \
  --type text \
  --name "Daily 9am" \
  --cron "0 9 * * *" \
  --channel dingtalk \
  --target-user "your_user_id" \
  --target-session "session_id" \
  --text "Good morning!"

# Agent: create task for specific agent
tqclaw cron create \
  --agent-id abc123 \
  --type agent \
  --name "Check todos" \
  --cron "0 */2 * * *" \
  --channel dingtalk \
  --target-user "your_user_id" \
  --target-session "session_id" \
  --text "What are my todo items?"
```

Required: `--type`, `--name`, `--cron`, `--channel`, `--target-user`,
`--target-session`, `--text`.

**Option 2 — JSON file (complex or batch)**

```bash
tqclaw cron create -f job_spec.json
```

JSON structure matches the output of `tqclaw cron get <job_id>`.

### Additional options

| Option                       | Default       | Description                                                              |
| ---------------------------- | ------------- | ------------------------------------------------------------------------ |
| `--timezone`                 | user timezone | Timezone for the cron schedule (defaults to `user_timezone` from config) |
| `--enabled` / `--no-enabled` | enabled       | Create enabled or disabled                                               |
| `--mode`                     | `final`       | `stream` (incremental) or `final` (complete response)                    |
| `--base-url`                 | auto          | Override the API base URL                                                |

### Cron expression cheat sheet

Five fields: **minute hour day month weekday** (no seconds).

| Expression     | Meaning                   |
| -------------- | ------------------------- |
| `0 9 * * *`    | Every day at 9:00         |
| `0 */2 * * *`  | Every 2 hours on the hour |
| `30 8 * * 1-5` | Weekdays at 8:30          |
| `0 0 * * 0`    | Sunday at midnight        |
| `*/15 * * * *` | Every 15 minutes          |

---

## Chats (sessions)

Manage chat sessions via the API. **Requires `tqclaw app` to be running.**

### tqclaw chats

| Command                                | What it does                                                  |
| -------------------------------------- | ------------------------------------------------------------- |
| `tqclaw chats list`                     | List all sessions (supports `--user-id`, `--channel` filters) |
| `tqclaw chats get <id>`                 | View a session's details and message history                  |
| `tqclaw chats create ...`               | Create a new session                                          |
| `tqclaw chats update <id> --name "..."` | Rename a session                                              |
| `tqclaw chats delete <id>`              | Delete a session                                              |

**Multi-Agent Support:** All commands support the `--agent-id` parameter (defaults to `default`).

```bash
tqclaw chats list                        # Default agent's chats
tqclaw chats list --agent-id abc123      # Specific agent's chats
tqclaw chats list --user-id alice --channel dingtalk
tqclaw chats get 823845fe-dd13-43c2-ab8b-d05870602fd8
tqclaw chats create --session-id "discord:alice" --user-id alice --name "My Chat"
tqclaw chats create --agent-id abc123 -f chat.json
tqclaw chats update <chat_id> --name "Renamed"
tqclaw chats delete <chat_id>
```

---

## Skills

Extend TQ-Claw's capabilities with skills (PDF reading, web search, etc.).

### tqclaw skills

| Command               | What it does                                      |
| --------------------- | ------------------------------------------------- |
| `tqclaw skills list`   | Show all skills and their enabled/disabled status |
| `tqclaw skills config` | Interactively enable/disable skills (checkbox UI) |

**Multi-Agent Support:** All commands support the `--agent-id` parameter (defaults to `default`).

```bash
tqclaw skills list                   # See default agent's skills
tqclaw skills list --agent-id abc123 # See specific agent's skills
tqclaw skills config                 # Configure default agent
tqclaw skills config --agent-id abc123 # Configure specific agent
```

In the interactive UI: ↑/↓ to navigate, Space to toggle, Enter to confirm.
A preview of changes is shown before applying.

> For built-in skill details and custom skill authoring, see [Skills](./skills).

---

## Maintenance

### tqclaw clean

Remove everything under the working directory (default `~/.tqclaw`).

```bash
tqclaw clean             # Interactive confirmation
tqclaw clean --yes       # No confirmation
tqclaw clean --dry-run   # Only list what would be removed
```

---

## Global options

Every `tqclaw` subcommand inherits:

| Option          | Default     | Description                                    |
| --------------- | ----------- | ---------------------------------------------- |
| `--host`        | `127.0.0.1` | API host (auto-detected from last `tqclaw app`) |
| `--port`        | `8088`      | API port (auto-detected from last `tqclaw app`) |
| `-h` / `--help` |             | Show help message                              |

If the server runs on a non-default address, pass these globally:

```bash
tqclaw --host 0.0.0.0 --port 9090 cron list
```

## Working directory

All config and data live in `~/.tqclaw` by default:

- **Global config**: `config.json` (providers, environment variables, agent list)
- **Agent workspaces**: `workspaces/{agent_id}/` (each agent's independent config and data)

```
~/.tqclaw/
├── config.json              # Global config
└── workspaces/
    ├── default/             # Default agent workspace
    │   ├── agent.json       # Agent config
    │   ├── chats.json       # Conversation history
    │   ├── jobs.json        # Cron jobs
    │   ├── AGENTS.md        # Persona files
    │   └── memory/          # Memory files
    └── abc123/              # Other agent workspace
        └── ...
```

| Variable            | Description                         |
| ------------------- | ----------------------------------- |
| `TQCLAW_WORKING_DIR` | Override the working directory path |
| `TQCLAW_CONFIG_FILE` | Override the config file path       |

See [Config & Working Directory](./config) and [Multi-Agent Workspace](./multi-agent) for full details.

---

## Command overview

| Command          | Subcommands                                                                                                                            | Requires server? |
| ---------------- | -------------------------------------------------------------------------------------------------------------------------------------- | :--------------: |
| `tqclaw init`     | —                                                                                                                                      |        No        |
| `tqclaw app`      | —                                                                                                                                      |  — (starts it)   |
| `tqclaw models`   | `list` · `config` · `config-key` · `set-llm` · `download` · `local` · `remove-local` · `ollama-pull` · `ollama-list` · `ollama-remove` |        No        |
| `tqclaw env`      | `list` · `set` · `delete`                                                                                                              |        No        |
| `tqclaw channels` | `list` · `install` · `add` · `remove` · `config`                                                                                       |        No        |
| `tqclaw cron`     | `list` · `get` · `state` · `create` · `delete` · `pause` · `resume` · `run`                                                            |     **Yes**      |
| `tqclaw chats`    | `list` · `get` · `create` · `update` · `delete`                                                                                        |     **Yes**      |
| `tqclaw skills`   | `list` · `config`                                                                                                                      |        No        |
| `tqclaw clean`    | —                                                                                                                                      |        No        |

---

## Related pages

- [Introduction](./intro) — What TQ-Claw can do
- [Console](./console) — Web-based management UI
- [Channels](./channels) — DingTalk, Feishu, iMessage, Discord, QQ setup
- [Heartbeat](./heartbeat) — Scheduled check-in / digest
- [Skills](./skills) — Built-in and custom skills
- [Config & Working Directory](./config) — Working directory and config.json
- [Multi-Agent Workspace](./multi-agent) — Multi-agent setup and management
