"""Stable fingerprints so repeated events collapse into counts."""

from __future__ import annotations

import re

from .parse import Event

HEX_RE = re.compile(r"\b[a-f0-9]{32,40}\b", re.I)
IP_RE = re.compile(r"\b\d{1,3}(?:\.\d{1,3}){3}\b")
SITE_RE = re.compile(r"/var/www/sites/[^/\s]+")
NUM_RE = re.compile(r"\b\d+\b")
QUERY_ID_RE = re.compile(r"(_LTI_TSUGI|PHPSESSID|token|key)=[^&\s]+", re.I)


def strip_referer(message: str) -> str:
    marker = ", referer: "
    if marker in message:
        return message.rsplit(marker, 1)[0]
    return message


def fingerprint_message(message: str) -> str:
    text = strip_referer(message)
    text = SITE_RE.sub("<site>", text)
    text = text.replace("/var/www/html", "<html>")
    text = HEX_RE.sub("<id>", text)
    text = IP_RE.sub("<ip>", text)
    text = QUERY_ID_RE.sub(r"\1=<id>", text)
    text = NUM_RE.sub("N", text)
    text = re.sub(r"\s+", " ", text).strip()
    if len(text) > 160:
        text = text[:157] + "..."
    return text


def fingerprint_path(path: str) -> str:
    text = path.split("?")[0]
    text = HEX_RE.sub("<id>", text)
    text = NUM_RE.sub("N", text)
    if len(text) > 80:
        text = text[:77] + "..."
    return text


def fingerprint(event: Event, rule_name: str) -> str:
    if event.source == "access":
        path = fingerprint_path(event.path or event.message)
        if event.garbage:
            return f"{rule_name}|garbage"
        return f"{rule_name}|{event.status}|{event.method}|{path}"
    return f"{rule_name}|{fingerprint_message(event.primary_message)}"
