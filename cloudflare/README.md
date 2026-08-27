
Making a Cloudflare Security Group in Amazon
--------------------------------------------

If you want to have solid DDOS protection, it is nice to block all direct
traffic except SSH to the public IP addresses of youer EC2 instances.  Cloudflare
gives you a list of the IP ranges at these URLs:

  https://www.cloudflare.com/ips-v4
  https://www.cloudflare.com/ips-v6

These change very slowly.  From August 2018 (when I started using this technique)
to June 2020 (when I am writing this documentation) there were *no* changes to
the Cloudflare IP ranges.  I include commands below to check if they have changed
any time you like.  If you notice that they have changed - make sure to let
the Tsugi devloper's list know because a lot of Tsugi servers might be partially
off the air.

To make use of this feature you make an AWS security group (I call my security
group `cloudflare-80`) that allows incoming HTTP
from all these ranges and SSH from any address range and nothing else. Here are some
sample AWS console images:

* <a href="images/security-group-01.png" target="_blank">Page 1</a>
* <a href="images/security-group-02.png" target="_blank">Page 2</a>

If you want to turn this off temporarily - just switch the running instance to a wide open
security group and then when you are done stesting switch back to the `cloudflare-80`
security group.

Page Rules
----------

You get three free page rules in Cloudflare - here are some recommended settings.
We give extra protection to the admin URLs, and in effect turn off Cloudflare
for two pages that function like APIs.

    *.dj4e.com/tsugi/admin
    Browser Integrity Check: On, Security Level: High, Cache Level: Bypass

    *.dj4e.com/tsugi/lti
    Browser Integrity Check: Off, Security Level: Essentially Off, Cache Level: Bypass

    *.dj4e.com/tsugi/api
    Browser Integrity Check: Off, Security Level: Essentially Off, Cache Level: Bypass

Notes:

Disable Browser Integrity Check for your API - 
https://support.cloudflare.com/hc/en-us/articles/200504045

Clearing Cache
--------------

If you have heavily cached URLs and want to change that content,
you can log in and clear Cloudflare's entire cache of your site
under 'Caching.  Clearing cache in Cloudflare is not too costly,
it just means Cloudflare will re-grab all those files once and
start to cache them again.

Of course, Cloudflare cannot convince browsers that think they have
a fine cached copy to re-request files - so if you want to check if
the cache was cleared and you are getting the new version in your
browser, you might have to add a GET parameter to a URL like:

    http://static.tsugi.org/js/tsugiscripts_head.js?x=42

Then you should force your browser to re-retrieve the file.

Cloudflare does not solve the "force all the browsers to reload
the new version" because it can't.   For that you still need to
resort to tricks like GET parameters in static files in your markup.

Checking to see if the Cloudflare IP Ranges have Changed
--------------------------------------------------------

To check if the cloudflare IP address ranged have changed, run the
following commands (must be in bash):

  wget -O /tmp/2023-11-12-ips-v4.txt https://www.cloudflare.com/ips-v4
  wget -O /tmp/2023-11-12-ips-v6.txt https://www.cloudflare.com/ips-v6

  diff <(sort 2018-08-15-ips-v4.txt) <(sort /tmp/2023-11-12-ips-v4.txt)
  diff <(sort 2018-08-15-ips-v6.txt) <(sort /tmp/2023-11-12-ips-v6.txt)

Don't store the new files unless there have been changes - which
are pretty rare.

As a note, you can add CIDR blocks to AWS Security groups all on one
line as comma separated values like this:

2400:cb00::/32,2606:4700::/32,2803:f800::/32,2405:b500::/32,2405:8100::/32

Use this command:

tr '\n' ',' < 2023-11-12-ips-v4.txt | sed 's/,$/\n/'


Blocking Bot Scanners (WordPress, .git, cgi-bin)
------------------------------------------------

There are a lot of fuzzing attacks that blast PHP sites looking for
WordPress, git metadata, `.env` files, and old CGI scripts.  Extremely
large POST bodies at WordPress endpoints can even run a server out of
memory.  Tsugi handles these smoothly but you see log errors when they
happen.  If you are using CloudFlare, block them in the WAF so they
never reach Apache.

Go into Security -> Security rules (older dashboard: Security -> WAF ->
Custom rules) and add one Custom rule.  Free accounts only get five
custom WAF rules per zone, so put every probe path in a single
expression with `or`.  Same Action (Block) either way.

Title: Bot Scan Blockers

Select "Edit expression" and enter this (newlines added for readability).

    (starts_with(http.request.uri.path, "/wp-")) or
    (starts_with(http.request.uri.path, "/wp/")) or
    (http.request.uri.path in {"/wp" "/wordpress" "/wordpress/"}) or
    (http.request.uri.path contains "/wp-admin") or
    (http.request.uri.path contains "/wp-login") or
    (http.request.uri.path contains "/wp-content") or
    (http.request.uri.path contains "/wp-includes") or
    (http.request.uri.path contains "/wp-json") or
    (http.request.uri.path contains "/wp-config") or
    (http.request.uri.path contains "xmlrpc.php") or
    (http.request.uri.path contains "/wordpress/") or
    (http.request.uri.path contains "/.git") or
    (http.request.uri.path contains "/.svn") or
    (http.request.uri.path contains "/.htpasswd") or
    (http.request.uri.path contains "/.env") or
    (http.request.uri.path contains "/cgi-bin")

Set the Action to Block.

The WordPress half is broader than `/wp-admin` and `xmlrpc.php` alone —
scanners also hit `/wp/`, `/wp-json/`, `/wp-content/`, and `/wordpress/`.
CloudFlare's bundled WordPress rules are for *protecting* WordPress, so
they do not fully drop these probes.

`contains "/.git"` (no trailing slash) matches `/.git/config` and also
`/.git`, `/.gitconfig`, `/.git-credentials`, `/.github`, and
`/.gitlab-ci.yml`.  `contains "/cgi-bin"` matches `/cgi-bin/` and
path-traversal tricks like `/cgi-bin/.%2e/.%2e/bin/sh`.  None of those
paths should ever be served from these hosts.

* <a href="images/waf-wp-block.png" target="_blank">Screen shot of WAF configuration</a>
* <a href="images/waf-wp-log.png" target="_blank">Screen shot of WAF log</a>

You can see the WordPress part in action at https://www.py4e.com/wp-admin



