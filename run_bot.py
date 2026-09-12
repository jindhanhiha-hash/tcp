#!/usr/bin/env python3
"""Hoster entrypoint for the TCP bot.

Loads account credentials from environment variables, writes the legacy
credential file expected by main.py, and replaces this process with the bot.
"""
from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path

try:
    from dotenv import load_dotenv
except ImportError:
    load_dotenv = None

ROOT = Path(__file__).resolve().parent
os.chdir(ROOT)
if load_dotenv:
    load_dotenv(ROOT / ".env")

uid = os.getenv("BOT_UID", "").strip()
password = os.getenv("BOT_PASSWORD", "").strip()

if not uid or not password:
    print("ERROR: BOT_UID and BOT_PASSWORD environment variables are required.", flush=True)
    sys.exit(2)

if not uid.isdigit():
    print("ERROR: BOT_UID must contain digits only.", flush=True)
    sys.exit(2)

# main.py reads this legacy file format. Keep permissions private on hosts
# that support chmod; do not print the password to logs.
credential_file = ROOT / "shadmancodex.txt"
credential_file.write_text(f"uid={uid},password={password}\n", encoding="utf-8")
try:
    credential_file.chmod(0o600)
except OSError:
    pass

os.environ.setdefault("BOT_REGION", os.getenv("BOT_REGION", "IND"))
print(f"Starting TCP bot for UID {uid}...", flush=True)
os.execv(sys.executable, [sys.executable, str(ROOT / "main.py")])
