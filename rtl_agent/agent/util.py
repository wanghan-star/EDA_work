"""Small shared helpers: subprocess wrapper, logging, file IO."""

import hashlib
import json
import os
import subprocess
import sys
import threading
import time

_LOG_LOCK = threading.Lock()
VERBOSE = os.environ.get("RTL_AGENT_VERBOSE", "0") == "1"


def log(msg, tag="agent"):
    ts = time.strftime("%H:%M:%S")
    with _LOG_LOCK:
        print(f"[{ts}][{tag}] {msg}", file=sys.stderr, flush=True)


def vlog(msg, tag="agent"):
    if VERBOSE:
        log(msg, tag)


def _to_text(x):
    if x is None:
        return ""
    if isinstance(x, bytes):
        return x.decode("utf-8", errors="replace")
    return x


def run_cmd(cmd, cwd=None, timeout=None, env=None, input_text=None):
    """Run a command; returns (returncode, stdout, stderr, seconds). Never raises on failure."""
    t0 = time.time()
    try:
        p = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True, errors="replace",
                           timeout=timeout, env=env, input=input_text)
        return p.returncode, p.stdout, p.stderr, time.time() - t0
    except subprocess.TimeoutExpired as e:
        return -9, _to_text(e.stdout), _to_text(e.stderr) + "\n[TIMEOUT]", time.time() - t0
    except FileNotFoundError as e:
        return -127, "", f"[NOT FOUND] {e}", time.time() - t0


def read_text(path):
    with open(path, encoding="utf-8", errors="replace") as fh:
        return fh.read()


def write_text(path, text):
    d = os.path.dirname(os.path.abspath(path))
    os.makedirs(d, exist_ok=True)
    with open(path, "w", encoding="utf-8", newline="\n") as fh:
        fh.write(text)


def write_json(path, obj):
    write_text(path, json.dumps(obj, indent=2, ensure_ascii=False, default=str) + "\n")


def sha1(text):
    return hashlib.sha1(text.encode("utf-8", errors="replace")).hexdigest()


def tail(text, n=1500):
    text = text or ""
    return text if len(text) <= n else "..." + text[-n:]
