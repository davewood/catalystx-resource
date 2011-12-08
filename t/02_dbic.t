use strict;
use warnings;
use Test::More;
use Test::Exception;
#use HTTP::Request::Common;
use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Catalyst::Test qw/TestApp/;

my $db_file = "$Bin/lib/TestApp/testdbic.db";
unlink $db_file if -e $db_file;

use_ok('TestApp::Schema');

my $schema;
lives_ok { $schema = TestApp::Schema->connect("DBI:SQLite:$db_file") }
    'Connect';
ok $schema;
lives_ok { $schema->deploy } 'deploy schema';

$schema->resultset('Resource::Artist')->create({
    id => 1,
    name => 'davewood',
});
$schema->resultset('Resource::Artist')->create({
    id => 2,
    name => 'flipper',
});

my $res;
my $path;

# test / for no special reason
$path = '/';
$res = request($path);
ok($res->is_success, "$path returns HTTP 200");
like($res->decoded_content, '/TestApp/', "$path content contains string 'TestApp'");

# SHOW
$path ='/artists/1/show'; 
$res = request($path);
ok($res->is_success, "$path returns HTTP 200");
like($res->decoded_content, '/davewood/', "$path content contains string 'davewood'");
$path = '/artists/99/show';
ok(request($path)->code == 404, "Unknown resource $path returns HTTP 404");

# LIST
$path ='/artists/list'; 
$res = request($path);
ok($res->is_success, "Get $path");
like($res->decoded_content, '/davewood[\s\S]*flipper/', "$path content contains 'davewood' and 'flipper'");

# DELETE
#TODO delete should be POST request
$path ='/artists/1/delete'; 
$res = request($path);
ok($res->is_redirect, "$path returns HTTP 302");
#TODO test that redirected URL returns 200
ok(request($path)->code == 404, "Already deleted $path returns HTTP 404");

# CREATE
$path ='/artists/create'; 
$res = request($path);
ok($res->is_success, "$path returns HTTP 200");
like($res->decoded_content, '/method="post"/', "$path content contains 'method=\"post\"'");
# check "msg" content after redirect

# EDIT
$path ='/artists/2/edit'; 
$res = request($path);
ok($res->is_success, "$path returns HTTP 200");
like($res->decoded_content, '/method="post"/', "$path content contains 'method=\"post\"'");
like($res->decoded_content, '/flipper/', "$path content contains 'flipper'");
# check "msg" content after redirect


#is(request('/logout')->code, 302, 'Get 302 from /logout');
#
#{
#    my ($res, $c) = ctx_request(POST 'http://localhost/login', [username => 'bob', password => 'aaaa']);
#    is($res->code, 200, 'get 200 ok as login page redisplayed when bullshit');
#
#    ($res, $c) = ctx_request(POST 'http://localhost/login', [username => 'bob', password => 'bbbb']);
#    is($res->code, 302, 'get 302 redirect');
#    my $cookie = $res->header('Set-Cookie');
#    ok($cookie, 'Have a cookie');
#    is($res->header('Location'), 'http://localhost/', 'Redirect to /');
#    ok($c->user, 'Have a user in $c');
#}

done_testing;

