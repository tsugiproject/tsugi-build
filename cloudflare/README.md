
Clearing Cache
--------------

If you have heavily cached URLs and want to change that content,
you can log in and clear CloudFlare's entire cache of your site
under 'Caching.  Clearing cache in CloudFlare is not too costly, 
it just means CloudFlare will re-grab all those files once and
start to cache them again.

Of course, Cloudflare cannot convince browsers that think they have
a fine cached copy to re-request files - so if you want to check if
the cache was cleared and you are getting the new version in your
browser, you might have to add a GET parameter to a URL like:

    http://static.tsugi.org/js/tsugiscripts_head.js?x=42

Then you should force your browser to re-retrieve the file.   

CloudFlare does not solve the "force all the browsers to reload
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

