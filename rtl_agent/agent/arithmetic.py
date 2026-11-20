"""Conservative, parameter-preserving source candidates for unsigned add-with-carry.

This is a recognizer, not a Verilog parser. Unsupported syntax is left to the LLM
and synthesis engines. Every result still needs synthesis, simulation and formal
verification; Boolean carry logic can change four-state X propagation.
"""
import re

IDENT = r"[A-Za-z_][A-Za-z0-9_$]*"


def mask_comments(src):
    return re.sub(r'//[^\n]*|/\*.*?\*/|"(?:\\.|[^"\\])*"',
                  lambda m: re.sub(r"[^\n]", " ", m.group()), src, flags=re.S)


def _declarations(body):
    pattern = (r"\b(?:input|output|inout|wire|reg|logic)\s+"
               r"((?:(?:wire|reg|logic|signed|unsigned)\s+)*)"
               r"(\[[^\]\n]+\])?\s*(" + IDENT + r"(?:\s*,\s*" + IDENT + r")*)"
               r"(?=\s*[;,)=])")
    nets = {}
    for m in re.finditer(pattern, body):
        if "signed" in m[1].split():
            continue
        shape = re.sub(r"\s+", "", m[2] or "")
        for name in re.split(r"\s*,\s*", m[3]):
            if name not in ("input", "output", "wire", "reg", "logic"):
                nets[name] = shape
    return nets


def _carry_function(name, width, block):
    return f"""
// Block carry lookahead; loop bounds elaborate at the selected parameter values.
function [{width}:0] {name};
  input [{width}-1:0] a, b;
  input ci;
  reg [{width}-1:0] p, g;
  reg [{width}:0] c;
  reg term, value;
  integer i, j, l;
  begin
    p = a ^ b; g = a & b; c[0] = ci;
    for (i = 0; i < {width}; i = i + 1) begin
      value = g[i];
      for (j = 1; j < {block}; j = j + 1) begin
        if ((i % {block}) >= j) begin
          term = g[i-j];
          for (l = 0; l < j; l = l + 1) term = term & p[i-l];
          value = value | term;
        end
      end
      term = c[i-(i % {block})];
      for (j = 0; j < {block}; j = j + 1)
        if (j <= (i % {block})) term = term & p[i-j];
      c[i+1] = value | term;
    end
    {name} = {{c[{width}], p ^ c[{width}-1:0]}};
  end
endfunction
"""


def candidates(src, top):
    """Yield (strategy, RTL) without baking in a benchmark or default width.

    Match only an entire assignment RHS a+b+ci with equal unsigned packed
    operand ranges and a declared scalar carry. Avoid nested scopes/macros and
    multi-module inputs, whose identifier resolution needs a full parser.
    """
    body = mask_comments(src)
    if (len(re.findall(r"\bmodule\b", body)) != 1
            or re.search(r"\b(?:function|task|generate|signed)\b|`", body)
            or not re.search(r"\bmodule\s+" + re.escape(top) + r"\b", body)):
        return
    nets = _declarations(body)
    matches = []
    pat = r"(?:<=|(?<![=!<>])=(?!=))\s*(" + IDENT + r")\s*\+\s*(" + IDENT + r")\s*\+\s*(" + IDENT + r")\s*;"
    for m in re.finditer(pat, body):
        a, b, ci = m.groups()
        shape = nets.get(a)
        if not shape or shape != nets.get(b) or nets.get(ci) != "":
            continue
        bounds = re.fullmatch(r"\[([^:]+):0\]", shape)
        if not bounds:
            continue
        matches.append((m.start(1), m.end(3), a, b, ci, f"({bounds[1]}+1)"))
    if not matches:
        return
    # Small deterministic portfolio: all operations, then one operation at a time.
    # Single-site alternatives protect critical carry paths in mixed datapaths.
    selections = [list(range(len(matches)))]
    if len(matches) > 1:
        selections += [[i] for i in range(min(len(matches), 4))]
    for block in (0, 4, 8):
        for selected in selections:
            text, functions = src, []
            for i in reversed(selected):
                start, end, a, b, ci, width = matches[i]
                if block == 0:
                    expr = f"(({{1'b0, {a}, 1'b1}} + {{1'b0, {b}, {ci}}}) >> 1)"
                else:
                    name = f"rtlopt_carry_{block}_{i}"
                    while re.search(r"\b" + name + r"\b", body):
                        name += "_x"
                    expr = f"{name}({a}, {b}, {ci})"
                    functions.append(_carry_function(name, width, block))
                text = text[:start] + expr + text[end:]
            if functions:
                end = list(re.finditer(r"\bendmodule\b", mask_comments(text)))[-1].start()
                text = text[:end] + "\n".join(functions) + text[end:]
            tag = "all" if len(selected) == len(matches) else str(selected[0])
            yield f"{'fused' if not block else 'cla' + str(block)}_{tag}", text
