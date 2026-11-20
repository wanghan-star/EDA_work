"""Lightweight text-level Verilog helpers (no parsing beyond what we need)."""

import re

_KEYWORDS = {
    "module", "endmodule", "input", "output", "inout", "wire", "reg", "logic", "assign",
    "always", "begin", "end", "if", "else", "case", "endcase", "for", "integer", "parameter",
    "localparam", "generate", "endgenerate", "function", "endfunction", "task", "endtask",
    "initial", "default", "posedge", "negedge", "or", "and", "not", "genvar", "signed",
}


def strip_comments(text):
    text = re.sub(r"/\*.*?\*/", lambda m: "\n" * m.group(0).count("\n"), text, flags=re.S)
    text = re.sub(r"//[^\n]*", "", text)
    return text


def find_modules(text):
    return re.findall(r"^\s*module\s+([A-Za-z_][A-Za-z0-9_$]*)", strip_comments(text), flags=re.M)


def instantiated_modules(text):
    """Names that appear as `<name> [#(...)] <inst> (` -> candidate submodule instantiations."""
    body = strip_comments(text)
    names = set()
    for m in re.finditer(r"^\s*([A-Za-z_][A-Za-z0-9_$]*)\s*(?:#\s*\(.*?\)\s*)?([A-Za-z_][A-Za-z0-9_$]*)\s*\(",
                         body, flags=re.M | re.S):
        if m.group(1) not in _KEYWORDS:
            names.add(m.group(1))
    return names


def detect_top(text, hint=None):
    mods = find_modules(text)
    if hint and hint in mods:
        return hint
    if not mods:
        return None
    inst = instantiated_modules(text)
    roots = [m for m in mods if m not in inst]
    return roots[0] if roots else mods[0]


def has_x_assign(text):
    return bool(re.search(r"\d*'[bBhHoOdD]\s*[xX?]+|'[xX]\b|1'bx", strip_comments(text)))


def count_lines(text):
    return len([ln for ln in text.splitlines() if ln.strip()])


CODE_BLOCK_RE = re.compile(r"```[ \t]*(?:verilog|systemverilog|sv|v)?[ \t]*\n(.*?)```", re.S | re.I)


def extract_verilog(response, top):
    """Pick the last fenced code block that defines `module <top>`; fall back to raw text."""
    blocks = CODE_BLOCK_RE.findall(response or "")
    cands = [b.strip() for b in blocks if re.search(r"\bmodule\s+" + re.escape(top) + r"\b", b)]
    if cands:
        return cands[-1] + "\n"
    # unterminated block (truncated response) -> take what is after the last fence
    m = re.search(r"```[ \t]*(?:verilog|systemverilog|sv|v)?[ \t]*\n(.*)$", response or "", re.S | re.I)
    if m and re.search(r"\bmodule\s+" + re.escape(top) + r"\b", m.group(1)):
        return m.group(1).strip() + "\n"
    if re.search(r"\bmodule\s+" + re.escape(top) + r"\b", response or "") and "endmodule" in (response or ""):
        s = response.index("module")
        e = response.rindex("endmodule") + len("endmodule")
        return response[s:e] + "\n"
    return None


FORBIDDEN = [
    (r"\$(display|write|monitor|strobe|finish|stop|random|urandom|fopen|fwrite|readmem\w*)\b",
     "system tasks/functions are not allowed in the optimized design"),
    (r"\bforce\b|\brelease\b", "force/release is not allowed"),
    (r"`include\b", "`include is not allowed: the design must be self-contained"),
    (r"\bimport\s+\"DPI", "DPI is not allowed"),
    (r"#\s*\d+(\.\d+)?\s*[;a-zA-Z_({]", "delay controls (#N) are not allowed in synthesizable RTL"),
]


def sanity_issues(text, top, original_text):
    """Return a list of human readable problems that make a candidate unacceptable before any tool runs."""
    issues = []
    # the simulation-only time-0 evaluation emitted by resynth.to_single_block is not design logic
    body = re.sub(r"`ifndef\s+SYNTHESIS\b[^`]*?\brtlopt_t0_kick\b[^`]*?`endif", "", strip_comments(text))
    orig = strip_comments(original_text)
    if not re.search(r"\bmodule\s+" + re.escape(top) + r"\b", body):
        issues.append(f"module `{top}` is missing")
    for pat, why in FORBIDDEN:
        if re.search(pat, body) and not re.search(pat, orig):
            issues.append(why)
    if re.search(r"\binitial\b", body) and not re.search(r"\binitial\b", orig):
        issues.append("`initial` blocks are not allowed (they change power-up X behaviour and are not synthesizable)")
    orig_lists = {re.sub(r"\s+", "", m) for m in re.findall(r"always\s*@\s*\(([^)]*)\)", orig)}
    for m in re.findall(r"always\s*@\s*\(([^)]*)\)", body):
        lst = re.sub(r"\s+", "", m)
        if lst != "*" and "posedge" not in lst and "negedge" not in lst and lst not in orig_lists:
            issues.append(f"explicit sensitivity list `always @({m.strip()})` reads stale values in simulation; "
                          f"use `always @(*)` or `assign`")
            break
    if body.count("module") - body.count("endmodule") != 0 and body.count("endmodule") == 0:
        issues.append("missing `endmodule` (response truncated?)")
    return issues
