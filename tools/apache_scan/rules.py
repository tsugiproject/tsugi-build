"""Classification rules for Apache error.log and access.log.

Rules are evaluated in order; first match wins. Add new signatures near the
matching category rather than burying them in generic catch-alls.

Categories:
  probe      Security scanners / exploit attempts (summarize)
  normal     Operational notices that are not errors (summarize)
  expected   Known / routine failures (summarize)
  unexpected Real problems worth reading (show samples)
"""

from __future__ import annotations

import re
from dataclasses import dataclass
from typing import Callable, Optional

from .parse import Event


Category = str  # probe | normal | expected | unexpected | skip | traffic


@dataclass
class Match:
    name: str
    category: Category
    label: str


Predicate = Callable[[Event], bool]


@dataclass
class Rule:
    name: str
    category: Category
    label: str
    source: str  # error | access | both
    predicate: Predicate


def _msg(event: Event) -> str:
    return event.message or ""


def _path(event: Event) -> str:
    return event.path or ""


def contains(*needles: str) -> Predicate:
    lowered = tuple(n.lower() for n in needles)

    def pred(event: Event) -> bool:
        text = _msg(event).lower()
        return any(n in text for n in lowered)

    return pred


def msg_re(pattern: str, flags: int = re.I) -> Predicate:
    compiled = re.compile(pattern, flags)

    def pred(event: Event) -> bool:
        return bool(compiled.search(_msg(event)))

    return pred


def path_re(pattern: str, flags: int = re.I) -> Predicate:
    compiled = re.compile(pattern, flags)

    def pred(event: Event) -> bool:
        return bool(compiled.search(_path(event)))

    return pred


def all_of(*preds: Predicate) -> Predicate:
    def pred(event: Event) -> bool:
        return all(p(event) for p in preds)

    return pred


def any_of(*preds: Predicate) -> Predicate:
    def pred(event: Event) -> bool:
        return any(p(event) for p in preds)

    return pred


def status_in(*codes: int) -> Predicate:
    def pred(event: Event) -> bool:
        return event.status in codes

    return pred


def method_in(*methods: str) -> Predicate:
    wanted = {m.upper() for m in methods}

    def pred(event: Event) -> bool:
        return event.method.upper() in wanted

    return pred


# Path fragments that are almost never legitimate on these Tsugi hosts.
ACCESS_PROBE_PATH = re.compile(
    r"(?i)("
    r"\.env|\.git|wp-admin|wp-login|wp-content|wp-includes|wp-json|"
    r"/wp(/|$)|wordpress|xmlrpc|phpmyadmin|adminer|autoload_classmap|phpunit|"
    r"cgi-bin|actuator|server-status|\.htpasswd|\.htaccess|"
    r"vendor/|\.aws|secrets\.yml|wp-config|"
    r"eval-stdin|thinkphp|proc/self|etc/passwd|"
    r"debug/default|telescope|_profiler|phpinfo|"
    r"shell\.php|filemanager|graphql|manifest\.json|"
    r"rclone\.conf|service-account\.json|livewire/|"
    r"%2eenv|%2e%2e|\.\./|"
    r"secrets\.json|credentials\.json|serviceAccountKey|service_account|"
    r"config\.json|key\.json|\.ssh/|id_rsa|id_ed25519|id_ecdsa|"
    r"Dockerfile|terraform\.tfstate|firebase-adminsdk"
    r")"
)

# Single-segment PHP files on the default host are webshell/probe names.
LONELY_PHP = re.compile(r"^/[^/]+\.php$", re.I)
PHP_EXT = re.compile(r"\.(?:php[0-9]?|phtml|phar)$", re.I)
APP_PREFIX = re.compile(
    r"(?i)^/(tsugi|tools|mod|assn|lessons|code\d*|lectures\d*|assignments)/"
)


def _access_probe_path(event: Event) -> bool:
    path = _path(event)
    if ACCESS_PROBE_PATH.search(path):
        return True
    if path.startswith("/.") and event.status in (400, 403, 404):
        return True
    if event.status in (400, 403, 404) and PHP_EXT.search(path) and not APP_PREFIX.match(path):
        return True
    if LONELY_PHP.match(path) and event.status in (400, 403, 404):
        return True
    return False


ERROR_RULES: list[Rule] = [
    Rule("stack_continuation", "skip", "PHP stack continuation", "error",
         lambda e: e.continuation),

    # --- normal operational notices ---
    Rule("heartbeat", "normal", "Tsugi heartbeat", "error",
         msg_re(r"^Heartbeat\s")),
    Rule("lti_launch", "normal", "LTI launch", "error",
         msg_re(r"^Launch,")),
    Rule("grade_ok", "normal", "Grade send/store", "error",
         msg_re(r"^Grade (stored|sent)|Result::gradeSend")),
    Rule("hello_grade", "normal", "Hello autograder", "error",
         msg_re(r"^Hello\d+")),
    Rule("lti13", "normal", "LTI 1.3 / OIDC", "error",
         msg_re(r"oidc_login|oidc_launch|issuer_key=|lti_storage_target|target_link_uri")),
    Rule("file_serve", "normal", "Blob/file serve", "error",
         msg_re(r"^file serve id=")),
    Rule("admin_login", "normal", "Admin login", "error",
         msg_re(r"^Admin login")),
    Rule("db_upgrade", "normal", "Schema upgrade", "error",
         msg_re(r"^Upgrading:")),
    Rule("peer_grade", "normal", "Peer-grade notification", "error",
         contains("Peer-grade notification")),
    Rule("dj4e_version", "normal", "dj4e_version debug", "error",
         msg_re(r"^dj4e_version")),
    Rule("ip_trust", "normal", "IP change trusted", "error",
         contains("IP Address changed")),
    Rule("apache_restart", "normal", "Apache graceful restart", "error",
         contains("AH00171:")),
    Rule("session_login", "normal", "Session in login", "error",
         contains("Session in login")),
    Rule("login_ok", "normal", "Login redirect", "error",
         contains("Login.get() successful")),
    Rule("user_profile", "normal", "User/profile insert/update", "error",
         msg_re(r"^(User-Insert|User-Update|Profile-Insert):")),
    Rule("board_cache", "normal", "Board cache", "error",
         msg_re(r"^Board (stored|retrieved)")),
    Rule("tutorial_grade", "normal", "Tutorial autograder", "error",
         msg_re(r"^Tutorial\d+")),
    Rule("event_cleanup", "normal", "Event table cleanup", "error",
         msg_re(r"^(Deleted malformed event|Event table cleanup)")),
    Rule("assertion", "normal", "Assertion log", "error",
         msg_re(r"^Assertion:")),
    Rule("download_tmp", "normal", "Temporary download", "error",
         msg_re(r"^Downloaded /tmp/")),
    Rule("session_already", "normal", "session_start already active", "error",
         contains("Ignoring session_start()")),
    Rule("apache_start", "normal", "Apache start/resume", "error",
         msg_re(r"AH00163:|AH00094:")),

    # --- security probes ---
    Rule("denied_git", "probe", "Blocked .git / secrets path", "error",
         all_of(contains("client denied by server configuration:"),
                msg_re(r"/\.(git|github|gitlab|htpasswd|htaccess|env)"))),
    Rule("denied_vendor", "probe", "Blocked vendor/php path", "error",
         all_of(contains("client denied by server configuration:"),
                msg_re(r"/vendor"))),
    Rule("denied_serverstatus", "probe", "Blocked server-status", "error",
         all_of(contains("client denied by server configuration:"),
                contains("server-status"))),
    Rule("path_traversal", "probe", "Invalid URI / path traversal", "error",
         contains("invalid URI path")),
    Rule("default_vhost_php", "probe", "Missing PHP on default vhost", "error",
         msg_re(r"script '/var/www/html/[^']+' not found or unable to stat")),
    Rule("missing_php_script", "probe", "Missing PHP script on a site", "error",
         msg_re(r"script '.+' not found or unable to stat")),
    Rule("unhandled_post", "probe", "Unhandled POST (bot payload)", "error",
         contains("DIE: Unhandled POST request")),
    Rule("php_request_dump", "probe", "PHP dumped request payload", "error",
         msg_re(r"^array\(")),
    Rule("sqli_require", "probe", "SQLi in require/include path", "error",
         msg_re(r"(UNION\s+ALL\s+SELECT|EXTRACTVALUE|ORDER BY \d+|0x7e)")),
    Rule("exploit_require", "probe", "Garbled require of assignment file", "error",
         msg_re(r"(02cats|20cats)\.php")),
    Rule("androx_payload", "probe", "AndroxGh0st / proto pollution payload", "error",
         msg_re(r"androxgh0st|__proto__|NEXT_REDIRECT")),

    # --- expected application failures ---
    Rule("lti_session_expired", "expected", "LTI session missing/expired", "error",
         msg_re(r"DIE: (Tool session missing or expired|Session is missing, invalid or expired)|"
                r"Session (has expired|address has expired|expired)")),
    Rule("lti_missing_state", "expected", "LTI missing state", "error",
         contains("DIE: Missing state")),
    Rule("lti_direct_launch", "expected", "Tool launched outside LTI", "error",
         contains("This tool should be launched from")),
    Rule("oauth_expired", "expected", "OAuth expired timestamp/nonce", "error",
         msg_re(r"OAuth validation fail.*Expired timestamp|OAuth nonce error")),
    Rule("missing_footer", "expected", "Known missing footer.php", "error",
         all_of(contains("footer.php"), contains("about.php"))),
    Rule("denied_pl", "expected", "Blocked .pl (by design)", "error",
         all_of(contains("client denied by server configuration:"),
                contains(".pl"))),
    Rule("sni_mismatch", "expected", "SNI/HTTP hostname mismatch", "error",
         contains("AH02032:")),
    Rule("failure_is_expected", "expected", "Marked failure_is_expected", "error",
         contains("failure_is_expected")),

    # --- unexpected: real problems, including leftovers from check_errors.sh ---
    Rule("php_fatal", "unexpected", "PHP Fatal error", "error",
         contains("PHP Fatal error:")),
    Rule("php_parse", "unexpected", "PHP Parse error", "error",
         contains("PHP Parse error:")),
    Rule("sqlstate", "unexpected", "SQLSTATE / DB error", "error",
         contains("SQLSTATE")),
    Rule("grade_fail", "unexpected", "Grade send/store failure", "error",
         msg_re(r"Grade (NOT updated|failure|Exception:|read failure:)|"
                r"Failure to store grade|Session not set up for grade return|"
                r"Missing required result data")),
    Rule("die_other", "unexpected", "Other DIE:", "error",
         msg_re(r"^DIE:")),
    Rule("php_warn", "unexpected", "PHP Warning", "error",
         contains("PHP Warning:")),
    Rule("php_notice", "unexpected", "PHP Notice", "error",
         contains("PHP Notice:")),
    Rule("php_error", "unexpected", "PHP error", "error",
         lambda e: e.module == "php" and e.level in ("error", "warn")),
    Rule("apache_error", "unexpected", "Apache error", "error",
         lambda e: e.level in ("error", "crit", "alert", "emerg")),
]

ACCESS_RULES: list[Rule] = [
    Rule("tls_garbage", "probe", "TLS/binary junk on HTTP port", "access",
         lambda e: e.garbage or e.method.startswith("\\x")),
    Rule("about_500", "expected", "HTTP 500 on about.php (missing footer)", "access",
         all_of(status_in(500), path_re(r"/about\.php$"))),
    Rule("crud_assn_500", "probe", "HTTP 500 on crud assignment (junk/SQLi)", "access",
         all_of(status_in(500), path_re(r"/tools/crud/"))),
    Rule("http_500", "unexpected", "HTTP 500", "access",
         status_in(500)),
    Rule("crawler_meta", "normal", "robots/sitemap/favicon 404", "access",
         all_of(status_in(404),
                path_re(r"/(robots\.txt|sitemap\.xml|favicon\.ico|apple-touch-icon.*|service-worker\.js)$"))),
    Rule("probe_path", "probe", "Scanner path", "access",
         _access_probe_path),
    Rule("client_timeout", "expected", "HTTP 408 timeout", "access",
         status_in(408)),
    Rule("misdirected", "expected", "HTTP 421 misdirected", "access",
         status_in(421)),
    Rule("discussions_auth", "expected", "Discussions 401", "access",
         all_of(status_in(401), path_re(r"/discussions/json"))),
    Rule("notify_auth", "expected", "Notifications 403", "access",
         all_of(status_in(403), path_re(r"/tsugi/api/notifications"))),
    Rule("grade_submit_auth", "expected", "Grade submit 403", "access",
         all_of(status_in(403, 401), path_re(r"/tsugi/api/grade-submit"))),
    Rule("redirect", "traffic", "Redirect", "access",
         status_in(301, 302, 303, 307, 308)),
    Rule("not_modified", "traffic", "Not modified / partial", "access",
         status_in(304, 206)),
    Rule("ok", "traffic", "HTTP 2xx/3xx", "access",
         lambda e: 200 <= e.status < 400),
    Rule("options", "traffic", "CORS preflight", "access",
         method_in("OPTIONS")),
    Rule("other_404", "expected", "Other HTTP 404", "access",
         status_in(404)),
    Rule("other_403", "probe", "Other HTTP 403", "access",
         status_in(403)),
    Rule("other_401", "expected", "Other HTTP 401", "access",
         status_in(401)),
    Rule("other_400", "probe", "HTTP 400 bad request", "access",
         status_in(400)),
    Rule("other_4xx", "expected", "Other HTTP 4xx", "access",
         lambda e: 400 <= e.status < 500),
    Rule("other_5xx", "unexpected", "Other HTTP 5xx", "access",
         lambda e: e.status >= 500),
]


def match_event(event: Event) -> Optional[Match]:
    rules = ERROR_RULES if event.source == "error" else ACCESS_RULES
    for rule in rules:
        if rule.predicate(event):
            return Match(rule.name, rule.category, rule.label)
    return None
