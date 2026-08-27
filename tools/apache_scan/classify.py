"""Apply rules to events and accumulate per-signature counts."""

from __future__ import annotations

from collections import Counter, defaultdict
from dataclasses import dataclass, field
from datetime import datetime
from typing import Optional

from .normalize import fingerprint
from .parse import Event
from .rules import Match, match_event


@dataclass
class Bucket:
    name: str
    category: str
    label: str
    count: int = 0
    ips: set[str] = field(default_factory=set)
    sites: Counter = field(default_factory=Counter)
    fingerprints: Counter = field(default_factory=Counter)
    samples: dict[str, Event] = field(default_factory=dict)
    first_time: Optional[datetime] = None
    last_time: Optional[datetime] = None

    def add(self, event: Event, fp: str) -> None:
        self.count += 1
        if event.ip:
            self.ips.add(event.ip)
        if event.site:
            self.sites[event.site] += 1
        self.fingerprints[fp] += 1
        if fp not in self.samples:
            self.samples[fp] = event
        if event.time:
            if self.first_time is None or event.time < self.first_time:
                self.first_time = event.time
            if self.last_time is None or event.time > self.last_time:
                self.last_time = event.time


@dataclass
class FileStats:
    path: str
    lines: int = 0
    parsed: int = 0
    first_time: Optional[datetime] = None
    last_time: Optional[datetime] = None

    def note(self, event: Event) -> None:
        self.parsed += 1
        if event.time:
            if self.first_time is None or event.time < self.first_time:
                self.first_time = event.time
            if self.last_time is None or event.time > self.last_time:
                self.last_time = event.time


@dataclass
class ScanResult:
    files: list[FileStats] = field(default_factory=list)
    buckets: dict[str, Bucket] = field(default_factory=dict)
    unmatched: int = 0
    skipped: int = 0
    traffic: int = 0
    by_category: Counter = field(default_factory=Counter)
    unexpected_events: list[tuple[Match, Event]] = field(default_factory=list)

    def add(self, event: Event, match: Optional[Match]) -> None:
        if match is None:
            self.unmatched += 1
            return
        if match.category == "skip":
            self.skipped += 1
            return
        if match.category == "traffic":
            self.traffic += 1
            return
        self.by_category[match.category] += 1
        bucket = self.buckets.get(match.name)
        if bucket is None:
            bucket = Bucket(match.name, match.category, match.label)
            self.buckets[match.name] = bucket
        fp = fingerprint(event, match.name)
        bucket.add(event, fp)
        if match.category == "unexpected":
            self.unexpected_events.append((match, event))


def classify_events(events, result: ScanResult, stats: FileStats) -> None:
    for event in events:
        stats.lines += 1
        stats.note(event)
        match = match_event(event)
        result.add(event, match)
