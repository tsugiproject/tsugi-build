"""Human-readable (and optional JSON) scan report."""

from __future__ import annotations

import json
from datetime import datetime
from typing import Optional

from .classify import Bucket, ScanResult

CATEGORY_ORDER = ("probe", "normal", "expected", "unexpected")
CATEGORY_TITLE = {
    "probe": "PROBES (security scanners)",
    "normal": "NORMAL (operational notices)",
    "expected": "EXPECTED FAILURES",
    "unexpected": "UNEXPECTED (look at these)",
}


def _fmt_time(value: Optional[datetime]) -> str:
    if value is None:
        return "?"
    return value.strftime("%Y-%m-%d %H:%M:%S")


def _print_files(result: ScanResult) -> None:
    for stats in result.files:
        span = ""
        if stats.first_time or stats.last_time:
            span = f"  {_fmt_time(stats.first_time)} .. {_fmt_time(stats.last_time)}"
        print(f"  {stats.path}: {stats.lines} lines{span}")


def _buckets_for(result: ScanResult, category: str) -> list[Bucket]:
    buckets = [b for b in result.buckets.values() if b.category == category]
    buckets.sort(key=lambda b: (-b.count, b.name))
    return buckets


def _print_summary_category(result: ScanResult, category: str, top_fps: int) -> None:
    buckets = _buckets_for(result, category)
    total = result.by_category.get(category, 0)
    print()
    print(f"=== {CATEGORY_TITLE[category]}: {total} ===")
    if not buckets:
        print("  (none)")
        return
    for bucket in buckets:
        ips = f"{len(bucket.ips)} ip" + ("s" if len(bucket.ips) != 1 else "")
        print(f"  {bucket.count:6d}  {bucket.label}  ({ips})")
        if category in ("probe", "expected") and len(bucket.fingerprints) > 1:
            for fp, count in bucket.fingerprints.most_common(top_fps):
                sample = bucket.samples.get(fp)
                detail = _detail(sample) if sample else fp.split("|", 1)[-1]
                print(f"           {count:5d}  {detail}")
            extra = len(bucket.fingerprints) - top_fps
            if extra > 0:
                print(f"           ... {extra} more variants")


def _detail(event) -> str:
    if event.source == "access":
        path = event.path or "-"
        if len(path) > 70:
            path = path[:67] + "..."
        return f"{event.status} {event.method} {path}"
    text = event.primary_message
    marker = ", referer: "
    if marker in text:
        text = text.rsplit(marker, 1)[0]
    text = text.replace("\\n", " ")
    if len(text) > 90:
        text = text[:87] + "..."
    return text


def _print_unexpected(result: ScanResult, max_samples: int) -> None:
    buckets = _buckets_for(result, "unexpected")
    total = result.by_category.get("unexpected", 0)
    print()
    print(f"=== {CATEGORY_TITLE['unexpected']}: {total} ===")
    if not buckets:
        print("  (none)")
        return
    shown = 0
    for bucket in buckets:
        print()
        print(f"  {bucket.label}  x{bucket.count}  "
              f"({len(bucket.ips)} ips, {_fmt_time(bucket.first_time)} .. {_fmt_time(bucket.last_time)})")
        for fp, count in bucket.fingerprints.most_common():
            sample = bucket.samples[fp]
            print(f"    {count:5d}  {_detail(sample)}")
            print(f"           {sample.short_raw}")
            shown += 1
            if shown >= max_samples:
                remaining = sum(len(b.fingerprints) for b in buckets) - shown
                if remaining > 0:
                    print(f"    ... {remaining} more unexpected variants (use --max-samples)")
                return


def print_report(result: ScanResult, max_samples: int = 40, top_fps: int = 8) -> None:
    print("Apache log scan")
    _print_files(result)
    extras = []
    if result.traffic:
        extras.append(f"{result.traffic} traffic (2xx/3xx)")
    if result.skipped:
        extras.append(f"{result.skipped} stack continuations")
    if result.unmatched:
        extras.append(f"{result.unmatched} unmatched")
    if extras:
        print("  " + ", ".join(extras))

    _print_summary_category(result, "probe", top_fps)
    _print_summary_category(result, "normal", top_fps)
    _print_summary_category(result, "expected", top_fps)
    _print_unexpected(result, max_samples)


def result_to_json(result: ScanResult) -> dict:
    def bucket_dict(bucket: Bucket) -> dict:
        return {
            "name": bucket.name,
            "category": bucket.category,
            "label": bucket.label,
            "count": bucket.count,
            "ips": len(bucket.ips),
            "sites": dict(bucket.sites.most_common()),
            "variants": [
                {
                    "fingerprint": fp,
                    "count": count,
                    "sample": bucket.samples[fp].short_raw,
                }
                for fp, count in bucket.fingerprints.most_common()
            ],
        }

    return {
        "files": [
            {
                "path": s.path,
                "lines": s.lines,
                "first": _fmt_time(s.first_time),
                "last": _fmt_time(s.last_time),
            }
            for s in result.files
        ],
        "counts": dict(result.by_category),
        "traffic": result.traffic,
        "skipped": result.skipped,
        "unmatched": result.unmatched,
        "buckets": [bucket_dict(b) for b in result.buckets.values()],
    }


def print_json(result: ScanResult) -> None:
    print(json.dumps(result_to_json(result), indent=2))
