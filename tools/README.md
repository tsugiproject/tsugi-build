Tools
=====

Operational tools that are not part of the server build/start path.

Apache log scanner
------------------

Reads Apache `error.log` and `access.log` and splits events into probes,
normal activity, expected failures, and unexpected failures. Probes and
routine noise are counted; unexpected events are printed.

    ./tools/scan-apache /tmp/apache2
    python3 tools/apache_scan/scan.py /var/log/apache2
    python3 tools/apache_scan/scan.py --rotated /var/log/apache2

Add new signatures in `tools/apache_scan/rules.py` (first match wins).
Run against a sample, look at Unexpected, and promote patterns into probe /
normal / expected as they become familiar.
