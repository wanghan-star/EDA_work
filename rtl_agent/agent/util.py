"""Small shared helpers: subprocess wrapper, logging, file IO."""

import hashlib
import json
import os
import signal
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
        # Yosys launches ABC children. A separate POSIX session lets a timeout stop
        # only this invocation's process tree, including children holding pipe handles.
        with subprocess.Popen(cmd, cwd=cwd, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                              stdin=subprocess.PIPE if input_text is not None else None,
                              text=True, errors="replace", env=env,
                              start_new_session=(os.name == "posix")) as p:
            try:
                out, err = p.communicate(input=input_text, timeout=timeout)
                return p.returncode, out, err, time.time() - t0
            except subprocess.TimeoutExpired:
                if os.name == "posix":
                    try:
                        os.killpg(p.pid, signal.SIGKILL)
                    except ProcessLookupError:
                        pass
                else:
                    p.kill()
                out, err = p.communicate()
                return -9, out, err + "\n[TIMEOUT]", time.time() - t0
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
