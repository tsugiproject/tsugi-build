
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

  wget -O /tmp/2020-06-04-ips-v4.txt https://www.cloudflare.com/ips-v4
  wget -O /tmp/2020-06-04-ips-v6.txt https://www.cloudflare.com/ips-v6

  diff <(sort 2018-08-15-ips-v4.txt) <(sort /tmp/2020-06-04-ips-v4.txt)
  diff <(sort 2018-08-15-ips-v6.txt) <(sort /tmp/2020-06-04-ips-v6.txt)

Don't store the new files unless there have been changes - which
are pretty rare.

