#!/usr/bin/env python3
"""Scan Apache error.log and access.log; summarize noise, show real failures.

Usage:
  python3 tools/apache_scan/scan.py /tmp/apache2
  python3 tools/apache_scan/scan.py --dir /var/log/apache2
  python3 tools/apache_scan/scan.py --error /tmp/apache2/error.log
"""

from __future__ import annotations

import argparse
import os
import sys

# Allow `python3 tools/apache_scan/scan.py` from anywhere.
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from apache_scan.classify import FileStats, ScanResult, classify_events
from apache_scan.parse import (
    iter_access_events,
    iter_error_events,
    list_log_files,
    parse_access_line,
    parse_error_line,
)
from apache_scan.report import print_json, print_report
from apache_scan.rules import match_event


def _add_file(result: ScanResult, path: str, kind: str) -> None:
    stats = FileStats(path)
    events = iter_error_events(path) if kind == "error" else iter_access_events(path)
    classify_events(events, result, stats)
    result.files.append(stats)


def resolve_inputs(args: argparse.Namespace) -> tuple[list[str], list[str]]:
    error_files: list[str] = []
    access_files: list[str] = []

    if args.error:
        error_files.append(args.error)
    if args.access:
        access_files.append(args.access)

    directories = []
    if args.dir:
        directories.append(args.dir)
    for path in args.paths:
        if os.path.isdir(path):
            directories.append(path)
        elif os.path.basename(path).startswith("error.log"):
            error_files.append(path)
        elif os.path.basename(path).startswith("access.log"):
            access_files.append(path)
        else:
            raise SystemExit(f"Not a log directory or Apache log file: {path}")

    if not error_files and not access_files and not directories:
        directories.append("/var/log/apache2")

    only_error = args.error_only
    only_access = args.access_only
    for directory in directories:
        if not only_access:
            error_files.extend(list_log_files(directory, "error.log", args.rotated))
        if not only_error:
            access_files.extend(list_log_files(directory, "access.log", args.rotated))

    if only_error:
        access_files = []
    if only_access:
        error_files = []

    if not error_files and not access_files:
        raise SystemExit("No log files found. Pass a directory like /tmp/apache2 or --error/--access.")
    return error_files, access_files


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Summarize Apache probes and normal noise; show unexpected failures.",
    )
    parser.add_argument(
        "paths",
        nargs="*",
        help="Log directory (e.g. /tmp/apache2) or a specific error.log / access.log",
    )
    parser.add_argument("--dir", "--log-dir", dest="dir",
                        help="Log directory (default: /var/log/apache2 if no paths)")
    parser.add_argument("--error", help="Specific error.log path")
    parser.add_argument("--access", help="Specific access.log path")
    parser.add_argument("--rotated", action="store_true",
                        help="Also read error.log.1 / access.log.1 and *.gz rotations")
    parser.add_argument("--error-only", action="store_true", help="Skip access.log")
    parser.add_argument("--access-only", action="store_true", help="Skip error.log")
    parser.add_argument("--json", action="store_true", help="JSON instead of text")
    parser.add_argument("--max-samples", type=int, default=40,
                        help="Max unexpected variants to print (default 40)")
    parser.add_argument("--top", type=int, default=8,
                        help="Variants shown under each summary rule (default 8)")
    parser.add_argument("--self-test", action="store_true",
                        help="Run classifier checks on sample lines and exit")
    return parser


def self_test() -> int:
    cases = [
        (
            "error",
            "[Thu Aug 27 00:27:22.590438 2026] [access_compat:error] [pid 1:tid 1] "
            "[client 1.2.3.4:1] AH01797: client denied by server configuration: "
            "/var/www/sites/audio.dig4e.com/.git/config",
            "probe", "denied_git",
        ),
        (
            "error",
            "[Thu Aug 27 00:06:26.027006 2026] [php:notice] [pid 1:tid 1] "
            "[client 1.2.3.4:1] Heartbeat abcdefabcdefabcdefabcdefabcdefab 16234 "
            "/var/www/sites/www.dj4e.com/tsugi.php",
            "normal", "heartbeat",
        ),
        (
            "error",
            "[Thu Aug 27 00:05:26.019202 2026] [php:notice] [pid 1:tid 1] "
            "[client 1.2.3.4:1] DIE: Tool session missing or expired - please re-launch  "
            "https://www.coursera.org/",
            "expected", "lti_session_expired",
        ),
        (
            "error",
            "[Thu Aug 27 12:26:28.279665 2026] [php:error] [pid 1:tid 1] "
            "[client 1.2.3.4:1] script '/var/www/html/index.php' not found or unable to stat",
            "probe", "default_vhost_php",
        ),
        (
            "error",
            "[Thu Aug 27 11:29:55.808900 2026] [php:error] [pid 1:tid 1] "
            "[client 1.2.3.4:1] PHP Fatal error:  Uncaught Error: Call to a member "
            "function bodyStart() on null in /var/www/sites/www.wd4e.com/nav.php:2",
            "unexpected", "php_fatal",
        ),
        (
            "access",
            '1.2.3.4 - - [27/Aug/2026:00:00:03 +0000] "GET /.git/config HTTP/1.1" '
            '403 123 "-" "curl/8.0"',
            "probe", "probe_path",
        ),
    ]
    failed = 0
    for source, raw, category, name in cases:
        event = parse_error_line(raw) if source == "error" else parse_access_line(raw)
        if event is None:
            print(f"FAIL parse: {raw[:80]}")
            failed += 1
            continue
        match = match_event(event)
        got = (match.category, match.name) if match else (None, None)
        if got != (category, name):
            print(f"FAIL expected {category}/{name} got {got[0]}/{got[1]}")
            print(f"  {raw[:120]}")
            failed += 1
    if failed:
        print(f"{failed} self-test failure(s)")
        return 1
    print("self-test ok")
    return 0


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    if args.self_test:
        return self_test()
    error_files, access_files = resolve_inputs(args)
    result = ScanResult()
    for path in error_files:
        _add_file(result, path, "error")
    for path in access_files:
        _add_file(result, path, "access")
    if args.json:
        print_json(result)
    else:
        print_report(result, max_samples=args.max_samples, top_fps=args.top)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
