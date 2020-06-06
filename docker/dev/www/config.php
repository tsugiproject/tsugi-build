<?php

function __the_end(){
    if(($err=error_get_last()))
        die('<pre>'.print_r($err,true).'</pre>');
}
register_shutdown_function('__the_end');

// allow programmatic access to upgrade scripts
$path = '/var/www/html';
$fullpath = get_include_path() . PATH_SEPARATOR . $path;
ini_set('include_path', $fullpath);

// Grab the config-dist to clean up this file and only show the stuff we've changed
require_once("config-dist.php");
$CFG->apphome   = false;
if ( isset($_SERVER['HTTP_HOST']) ) {
    $CFG->wwwroot   = "http://" . $_SERVER['HTTP_HOST'] . '/tsugi';
}

if ( strlen(getenv('TSUGI_WWWROOT')) > 0 ) {
    $CFG->wwwroot = getenv('TSUGI_WWWROOT');
}

if ( strlen(getenv('TSUGI_APPHOME')) > 0 ) {
    $CFG->apphome = getenv('TSUGI_APPHOME');
}

if ( strlen(getenv('TSUGI_PDO')) > 0 ) {
  $CFG->pdo = getenv('TSUGI_PDO');
}
if ( strlen(getenv('TSUGI_USER')) > 0 ) {
    $CFG->dbuser    = getenv('TSUGI_USER');
}
if ( strlen(getenv('TSUGI_PASSWORD')) > 0 ) {
    $CFG->dbpass    = getenv('TSUGI_PASSWORD');
}

// tsugi is the admin pw
$CFG->adminpw = 'sha256:9c0ccb0d53dd71b896cde69c78cf977acbcb36546c96bedec1619406145b5e9e';
if ( strlen(getenv('TSUGI_ADMINPW')) > 0 ) {
    $CFG->adminpw   = getenv('TSUGI_ADMINPW');
}

$CFG->install_folder = $CFG->dirroot.'/mod';

$CFG->servicename = 'TSUGI';
if ( strlen(getenv('TSUGI_SERVICENAME')) > 0 ) {
    $CFG->servicename = getenv('TSUGI_SERVICENAME');
}

$CFG->servicedesc = "This is a docker instance of the Tsugi Development Environment";

// Record local analytics but don't send anywhere.
$CFG->launchactivity = true;
$CFG->eventcheck = false;

// Set to true to redirect to the upgrading.php script
// Also copy upgrading-dist.php to upgrading.php and add your message
$CFG->upgrading = false;

// Fun colors...
$CFG->bootswatch = 'cerulean';
$CFG->bootswatch_color = rand(0,52);

if ( strlen(getenv('TSUGI_GOOGLE_CLIENT_ID')) > 0 ) {
    $CFG->google_client_id = getenv('TSUGI_GOOGLE_CLIENT_ID');
    $CFG->google_client_secret = getenv('TSUGI_GOOGLE_CLIENT_SECRET');
}

if ( strlen(getenv('TSUGI_MAP_API_KEY')) > 0 ) {
    $CFG->google_map_api_key = getenv('TSUGI_MAP_API_KEY'); // 'Ve8eH490843cIA9IGl8';
}

$CFG->git_command = '/usr/local/bin/gitx';

$CFG->DEVELOPER = true;

$CFG->cookiesecret = 'jTuURh36Fr4sRPnUsHKP4G968H8r3xkzpMsk';
$CFG->cookiename = 'TSUGIAUTO';
$CFG->cookiepad = 'B77trww5PQ';

$CFG->maildomain = false;
$CFG->mailsecret = 'XaWPZvESnNV84FvHpqQ69yhHAkyrNEVjkcF7';
$CFG->maileol = "\n";


$CFG->sessionsalt = "fpmqZWBcp993Ca8RNWtVJfeM82Xf2fwK8uwD";

$CFG->timezone = 'America/New_York';

