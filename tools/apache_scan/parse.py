"""Parsers for Apache error.log and combined access.log lines."""

from __future__ import annotations

import gzip
import os
import re
from dataclasses import dataclass, field
from datetime import datetime
from typing import Iterator, Optional, TextIO


ERROR_RE = re.compile(
    r"^\[(?P<time>[^\]]+)\] "
    r"\[(?P<module>[^:]+):(?P<level>[^\]]+)\] "
    r"\[pid (?P<pid>\d+)(?::tid (?P<tid>\d+))?\]"
    r"(?: \[client (?P<client>[^\]]+)\])? "
    r"(?P<message>.*)$"
)

ACCESS_RE = re.compile(
    r"^(?P<ip>\S+) \S+ \S+ \[(?P<time>[^\]]+)\] "
    r'"(?P<request>[^"]*)" (?P<status>\d+) (?P<size>\S+)'
    r'(?: "(?P<referer>.*?)" "(?P<ua>.*)")?\s*$'
)

ACCESS_LOOSE_RE = re.compile(
    r"^(?P<ip>\S+) \S+ \S+ \[(?P<time>[^\]]+)\].*?\s(?P<status>\d{3})\s"
)

SITE_RE = re.compile(r"/var/www/sites/([^/\s]+)")
HTML_SITE = "/var/www/html"

ERROR_TIME_FMTS = (
    "%a %b %d %H:%M:%S.%f %Y",
    "%a %b %d %H:%M:%S %Y",
)
ACCESS_TIME_FMTS = (
    "%d/%b/%Y:%H:%M:%S %z",
    "%d/%b/%Y:%H:%M:%S",
)

STACK_RE = re.compile(r"^#\d+\s")


@dataclass
class Event:
    source: str  # error | access
    raw: str
    time: Optional[datetime] = None
    time_raw: str = ""
    module: str = ""
    level: str = ""
    pid: str = ""
    ip: str = ""
    message: str = ""
    method: str = ""
    path: str = ""
    query: str = ""
    status: int = 0
    size: str = ""
    referer: str = ""
    ua: str = ""
    site: str = ""
    garbage: bool = False
    continuation: bool = False
    extras: dict = field(default_factory=dict)

    @property
    def primary_message(self) -> str:
        """Line that should drive display (Fatal/DIE over the warning that preceded it)."""
        parts = (self.message or "").split("\n")
        for part in parts:
            if part.startswith("DIE:") or "PHP Fatal" in part or "PHP Parse" in part:
                return part
        return parts[0] if parts else ""

    @property
    def short_raw(self) -> str:
        lines = self.raw.rstrip("\n").split("\n")
        text = lines[0] if lines else ""
        for line in lines:
            if "PHP Fatal" in line or "DIE:" in line or "PHP Parse" in line:
                text = line
                break
        if len(text) > 240:
            return text[:237] + "..."
        return text


def _parse_time(value: str, fmts: tuple[str, ...]) -> Optional[datetime]:
    for fmt in fmts:
        try:
            return datetime.strptime(value, fmt)
        except ValueError:
            continue
    return None


def _extract_site(text: str) -> str:
    match = SITE_RE.search(text)
    if match:
        return match.group(1)
    if HTML_SITE in text:
        return "default-vhost"
    return ""


def parse_error_line(line: str) -> Optional[Event]:
    match = ERROR_RE.match(line.rstrip("\n"))
    if not match:
        return None
    data = match.groupdict()
    client = data.get("client") or ""
    ip = client.split(":")[0] if client else ""
    message = data["message"]
    event = Event(
        source="error",
        raw=line,
        time=_parse_time(data["time"], ERROR_TIME_FMTS),
        time_raw=data["time"],
        module=data["module"],
        level=data["level"],
        pid=data.get("pid") or "",
        ip=ip,
        message=message,
        referer=_extract_referer(message),
        site=_extract_site(message),
        continuation=_is_continuation(message),
    )
    return event


def _extract_referer(message: str) -> str:
    marker = ", referer: "
    if marker in message:
        return message.rsplit(marker, 1)[-1]
    return ""


def _is_continuation(message: str) -> bool:
    if STACK_RE.match(message):
        return True
    if message.startswith("Stack trace:"):
        return True
    if message.startswith("  thrown in "):
        return True
    return False


def parse_access_line(line: str) -> Optional[Event]:
    raw = line.rstrip("\n")
    match = ACCESS_RE.match(raw)
    if match:
        data = match.groupdict()
        method, path, query = _split_request(data.get("request") or "")
        event = Event(
            source="access",
            raw=line,
            time=_parse_time(data["time"], ACCESS_TIME_FMTS),
            time_raw=data["time"],
            ip=data["ip"],
            method=method,
            path=path,
            query=query,
            status=int(data["status"]),
            size=data.get("size") or "",
            referer=data.get("referer") or "",
            ua=data.get("ua") or "",
            message=data.get("request") or "",
            garbage=_looks_like_garbage(method, path),
        )
        return event

    loose = ACCESS_LOOSE_RE.match(raw)
    if loose:
        return Event(
            source="access",
            raw=line,
            time=_parse_time(loose.group("time"), ACCESS_TIME_FMTS),
            time_raw=loose.group("time"),
            ip=loose.group("ip"),
            status=int(loose.group("status")),
            garbage=True,
            message=raw[:120],
        )
    return None


def _split_request(request: str) -> tuple[str, str, str]:
    if not request or request == "-":
        return "-", "-", ""
    parts = request.split()
    method = parts[0] if parts else "-"
    target = parts[1] if len(parts) > 1 else "-"
    if "?" in target:
        path, query = target.split("?", 1)
    else:
        path, query = target, ""
    return method, path, query


def _looks_like_garbage(method: str, path: str) -> bool:
    if method in ("GET", "POST", "HEAD", "OPTIONS", "PUT", "DELETE", "PATCH", "-", "PRI"):
        return False
    if method.startswith("\\x") or any(ord(ch) < 32 for ch in method[:8] if ch):
        return True
    if method not in ("GET", "POST", "HEAD", "OPTIONS") and len(method) > 12:
        return True
    return False


def open_log(path: str) -> TextIO:
    if path.endswith(".gz"):
        return gzip.open(path, "rt", encoding="utf-8", errors="replace")
    return open(path, "r", encoding="utf-8", errors="replace")


def _same_request(a: Event, b: Event) -> bool:
    if a.pid != b.pid or not a.ip or a.ip != b.ip:
        return False
    if a.time is None or b.time is None:
        return True
    return abs((a.time - b.time).total_seconds()) < 1.5


def _should_attach(current: Event, nxt: Event) -> bool:
    """Dumps, DIE lines, warn+fatal pairs, and stacks for one PHP request."""
    if nxt.continuation and _same_request(current, nxt):
        return True
    if not _same_request(current, nxt):
        return False
    cur = current.message
    new = nxt.message
    if cur.lstrip().startswith("array(") and new.startswith("DIE:"):
        return True
    if "PHP Warning" in cur and ("PHP Fatal" in new or "PHP Parse" in new):
        return True
    if "Failed to open stream" in cur and "Failed opening" in new:
        return True
    return False


def _merge_error(current: Event, nxt: Event) -> None:
    current.message = current.message + "\n" + nxt.message
    current.raw = current.raw.rstrip("\n") + "\n" + nxt.raw
    if nxt.site and not current.site:
        current.site = nxt.site
    current.continuation = False


def iter_error_events(path: str) -> Iterator[Event]:
    current: Optional[Event] = None
    with open_log(path) as handle:
        for line in handle:
            event = parse_error_line(line)
            if event is None:
                continue
            if current is None:
                current = event
                continue
            if _should_attach(current, event):
                _merge_error(current, event)
                continue
            yield current
            current = event
    if current is not None:
        yield current


def iter_access_events(path: str) -> Iterator[Event]:
    with open_log(path) as handle:
        for line in handle:
            event = parse_access_line(line)
            if event is not None:
                yield event


def list_log_files(directory: str, basename: str, rotated: bool) -> list[str]:
    """Return log files for basename (error.log / access.log) in directory."""
    current = os.path.join(directory, basename)
    files = []
    if os.path.isfile(current):
        files.append(current)
    if not rotated:
        return files
    numbered = os.path.join(directory, basename + ".1")
    if os.path.isfile(numbered):
        files.append(numbered)
    for name in sorted(os.listdir(directory)):
        if name.startswith(basename + ".") and name.endswith(".gz"):
            files.append(os.path.join(directory, name))
    return files
