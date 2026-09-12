# TCP Bot Hosting Guide

This repository contains a **Free Fire TCP automation bot** and an optional Node.js control panel. It is not a Telegram bot. A Telegram bot can be used as a separate controller only if Telegram command-handling code is added.

## Generic bot-hosting panel

Upload or clone the repository, set the startup command to:

```bash
./start.sh bot
```

If the hoster does not execute shell files, use:

```bash
python run_bot.py
```

Set these environment variables in the hoster dashboard:

```env
BOT_UID=your_free_fire_uid
BOT_PASSWORD=your_free_fire_account_password
BOT_REGION=IND
WRITE_CREDENTIAL_FILE=1
```

`run_bot.py` validates the UID, creates the legacy `shadmancodex.txt` file required by `main.py`, and starts the bot without any interactive password prompt. Never put real credentials in GitHub or in public logs.

## Railway

1. Create a Railway project from the GitHub repository `jindhanhiha-hash/tcp`.
2. Add the variables `BOT_UID`, `BOT_PASSWORD`, and `BOT_REGION` in the Railway Variables tab.
3. Use the start command below if Railway does not automatically use `railway.toml`:

```bash
./start.sh bot
```

The included `railway.toml` already configures this worker command and restarts it after failure.

Railway is a worker host for this bot. It does not require the web control panel or an HTTP port. Do not use `AUTO_START_BOT=1` for worker mode.

## Local Linux or Termux

```bash
git clone https://github.com/jindhanhiha-hash/tcp.git
cd tcp
pkg install python nodejs git -y  # Termux only
python -m venv .venv
. .venv/bin/activate
python -m pip install -r requirements.txt
chmod +x start.sh
```

Create `.env` or export the variables, then run:

```bash
./start.sh bot
```

## Optional web control panel

To run the Node.js panel instead of worker mode:

```bash
./start.sh
```

The panel listens on `TCP_PANEL_PORT` (default `8080`). Set `AUTO_START_BOT=1` if the panel should start the bot automatically. For a worker hoster, use `./start.sh bot` instead.

## Troubleshooting

If the hoster says `BOT_UID and BOT_PASSWORD environment variables are required`, add both variables to the host dashboard and redeploy. If Android reports that `psutil` is unsupported, pull the latest repository version; `psutil` has been removed from `requirements.txt` and the source imports.
