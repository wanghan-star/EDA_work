"""OpenAI-compatible chat client (stdlib only) with token accounting.

Works with DeepSeek's official endpoint and Alibaba Bailian/DashScope compatible-mode endpoints.
Thinking (reasoning) can be toggled per call; the provider-specific switch is sent as
`enable_thinking` and, if the endpoint rejects unknown parameters, retried without it.
"""

import json
import random
import threading
import time
import urllib.error
import urllib.request

from .util import log, write_text


class Usage:
    def __init__(self):
        self.lock = threading.Lock()
        self.calls = 0
        self.logical_calls = 0
        self.prompt = 0
        self.completion = 0
        self.reasoning = 0
        self.cached = 0
        self.seconds = 0.0
        self.records = []

    def add(self, rec):
        with self.lock:
            self.calls += 1
            self.prompt += rec.get("prompt_tokens", 0)
            self.completion += rec.get("completion_tokens", 0)
            self.reasoning += rec.get("reasoning_tokens", 0)
            self.cached += rec.get("cached_tokens", 0)
            self.seconds += rec.get("seconds", 0.0)
            self.records.append(rec)

    @property
    def total(self):
        return self.prompt + self.completion

    def to_dict(self):
        return {"calls": self.calls, "logical_calls": self.logical_calls, "prompt_tokens": self.prompt,
                "completion_tokens": self.completion, "reasoning_tokens": self.reasoning,
                "cached_tokens": self.cached, "total_tokens": self.total,
                "llm_seconds": round(self.seconds, 1)}


class LLMError(Exception):
    pass


class LLMClient:
    def __init__(self, cfg, usage=None, trace_dir=None):
        self.cfg = cfg
        self.usage = usage or Usage()
        self.trace_dir = trace_dir
        self._send_thinking_flag = True
        self._n = 0
        self._lock = threading.Lock()

    def available(self):
        return bool(self.cfg.llm_key)

    def chat(self, messages, tag="call", thinking=False, temperature=0.2, max_tokens=None,
             model=None):
        """Returns assistant text. Raises LLMError after retries."""
        if not self.available():
            raise LLMError("no API key configured (LLM_API_KEY)")
        model = model or self.cfg.llm_model
        body = {"model": model, "messages": messages,
                "max_tokens": int(max_tokens or self.cfg.llm_max_tokens)}
        if not thinking:
            body["temperature"] = temperature
        url = self.cfg.llm_base + "/chat/completions"
        last_err = None
        with self.usage.lock:
            self.usage.logical_calls += 1
        for attempt in range(4):
            payload = dict(body)
            if self._send_thinking_flag:
                payload["enable_thinking"] = bool(thinking)
            t0 = time.time()
            try:
                req = urllib.request.Request(
                    url, data=json.dumps(payload).encode("utf-8"),
                    headers={"Authorization": f"Bearer {self.cfg.llm_key}",
                             "Content-Type": "application/json"})
                with urllib.request.urlopen(req, timeout=self.cfg.llm_timeout) as resp:
                    data = json.load(resp)
            except urllib.error.HTTPError as e:
                detail = ""
                try:
                    detail = e.read().decode("utf-8", errors="replace")[:400]
                except Exception:  # noqa: BLE001
                    pass
                last_err = f"HTTP {e.code}: {detail}"
                if e.code == 400 and self._send_thinking_flag and "enable_thinking" in detail:
                    self._send_thinking_flag = False
                    continue
                if e.code in (400, 401, 403, 404):
                    raise LLMError(last_err)
                time.sleep(min(30, 2 ** attempt + random.random()))
                continue
            except Exception as e:  # noqa: BLE001  (timeouts, connection resets)
                last_err = repr(e)
                time.sleep(min(30, 2 ** attempt + random.random()))
                continue
            sec = time.time() - t0
            choice = (data.get("choices") or [{}])[0]
            msg = choice.get("message") or {}
            text = msg.get("content") or ""
            u = data.get("usage") or {}
            det = u.get("completion_tokens_details") or {}
            pdet = u.get("prompt_tokens_details") or {}
            rec = {"tag": tag, "model": model, "thinking": bool(thinking),
                   "prompt_tokens": int(u.get("prompt_tokens", 0) or 0),
                   "completion_tokens": int(u.get("completion_tokens", 0) or 0),
                   "reasoning_tokens": int(det.get("reasoning_tokens", 0) or 0),
                   "cached_tokens": int(pdet.get("cached_tokens", 0) or 0),
                   "seconds": round(sec, 2), "finish": choice.get("finish_reason")}
            self.usage.add(rec)
            self._trace(tag, messages, text, msg.get("reasoning_content") or "", rec)
            if choice.get("finish_reason") == "length":
                # never pay twice for a runaway generation; caller decides what to do
                if text.strip():
                    log(f"{tag}: truncated at max_tokens ({rec['completion_tokens']} tok)", "llm")
                    return text
                raise LLMError(f"generation hit max_tokens without an answer "
                               f"({rec['completion_tokens']} tok, {rec['reasoning_tokens']} reasoning)")
            if not text.strip():
                last_err = f"empty response (finish={choice.get('finish_reason')})"
                continue
            log(f"{tag}: {rec['prompt_tokens']}+{rec['completion_tokens']} tok "
                f"({rec['reasoning_tokens']} reasoning), {sec:.1f}s", "llm")
            return text
        raise LLMError(f"LLM call failed after retries: {last_err}")

    def _trace(self, tag, messages, text, reasoning, rec):
        if not self.trace_dir:
            return
        with self._lock:
            self._n += 1
            n = self._n
        parts = [f"# {tag}  {json.dumps(rec)}\n"]
        for m in messages:
            parts.append(f"\n## {m['role']}\n\n{m['content']}\n")
        if reasoning:
            parts.append(f"\n## reasoning\n\n{reasoning}\n")
        parts.append(f"\n## response\n\n{text}\n")
        write_text(f"{self.trace_dir}/{n:03d}_{tag}.md", "".join(parts))
