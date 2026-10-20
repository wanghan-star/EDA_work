"""Configuration: tool paths (tools.env) and LLM settings (.env).

Priority for every key: CLI override > .env / tools.env file > environment variable > default.
"""

import os
import shutil

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

PLACEHOLDERS = ("your-api-key", "your_api_key", "placeholder", "changeme", "xxxx")


def load_kv(path):
    env = {}
    if not path or not os.path.isfile(path):
        return env
    with open(path, encoding="utf-8") as fh:
        for line in fh:
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            k, v = line.split("=", 1)
            env[k.strip()] = v.strip().strip('"').strip("'")
    return env


def _pick(key, files, default="", aliases=()):
    for src in files:
        for k in (key,) + tuple(aliases):
            v = src.get(k, "")
            if v and not any(p in v.lower() for p in PLACEHOLDERS):
                return v
    for k in (key,) + tuple(aliases):
        v = os.environ.get(k, "")
        if v and not any(p in v.lower() for p in PLACEHOLDERS):
            return v
    return default


def _resolve_bin(name, value):
    if value and os.path.isfile(value):
        return value
    found = shutil.which(value or name)
    return found or (value or name)


class Config:
    def __init__(self, env_file=None, tools_file=None, overrides=None):
        overrides = overrides or {}
        dotenv = load_kv(env_file or os.path.join(ROOT, ".env"))
        tools = load_kv(tools_file or os.path.join(ROOT, "tools.env"))
        files = [overrides, dotenv, tools]

        self.yosys = _resolve_bin("yosys", _pick("YOSYS_BIN", files))
        self.yosys_abc = _resolve_bin("yosys-abc", _pick("YOSYS_ABC_BIN", files))
        self.iverilog = _resolve_bin("iverilog", _pick("IVERILOG_BIN", files))
        self.vvp = _resolve_bin("vvp", _pick("VVP_BIN", files))
        lib = _pick("LIB_FILE", files, default=os.path.join(ROOT, "..", "tech",
                                                            "NangateOpenCellLibrary_typical.lib"))
        if not os.path.isabs(lib):
            lib = os.path.normpath(os.path.join(ROOT, lib))
        self.lib_file = lib

        base = _pick("LLM_BASE_URL", files, default="https://api.deepseek.com",
                     aliases=("DEEPSEEK_BASE_URL", "OPENAI_BASE_URL"))
        self.llm_base = base.rstrip("/")
        self.llm_key = _pick("LLM_API_KEY", files, aliases=("DEEPSEEK_API_KEY", "OPENAI_API_KEY"))
        self.llm_model = _pick("LLM_MODEL", files, default="deepseek-v4.1-flash",
                               aliases=("DEEPSEEK_MODEL",))
        self.llm_thinking = _pick("LLM_THINKING", files, default="off").lower()
        self.llm_timeout = int(_pick("LLM_TIMEOUT", files, default="300"))
        self.llm_max_tokens = int(_pick("LLM_MAX_TOKENS", files, default="12000"))
        self.jobs = int(_pick("RTL_AGENT_JOBS", files, default=str(min(8, os.cpu_count() or 4))))

    def yosys_version(self):
        """(major, minor) of the yosys binary, cached; (0, 0) if unknown."""
        if getattr(self, "_yv", None) is None:
            import re
            import subprocess
            try:
                out = subprocess.run([self.yosys, "-V"], capture_output=True, text=True, timeout=30).stdout
                m = re.search(r"Yosys (\d+)\.(\d+)", out)
                self._yv = (int(m.group(1)), int(m.group(2))) if m else (0, 0)
            except Exception:  # noqa: BLE001
                self._yv = (0, 0)
        return self._yv

    def modern_yosys(self):
        # opt_dff / dffunmap / fine-grained FF types exist since Yosys 0.10
        v = self.yosys_version()
        return v == (0, 0) or v >= (0, 10)

    def check_tools(self):
        missing = []
        for name in ("yosys", "yosys_abc", "iverilog", "vvp"):
            p = getattr(self, name)
            if not (os.path.isfile(p) or shutil.which(p)):
                missing.append(f"{name} ({p})")
        if not os.path.isfile(self.lib_file):
            missing.append(f"LIB_FILE ({self.lib_file})")
        return missing

    def masked_key(self):
        return (self.llm_key[:6] + "****") if self.llm_key else "<unset>"
