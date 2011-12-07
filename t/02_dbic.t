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

# test / for no special reason
ok(request('/')->is_success, 'Get /');
content_like('/', '/TestApp/', 'index action returns "TestApp"');

# SHOW
ok(request('/artists/1/show')->is_success, 'Get /artists/1/show');
content_like('/artists/1/show', '/davewood/', '/artists/1/show contains "davewood"');

ok(request('/artists/99/show')->is_error, 'Unknown resource /artists/99/show should return error');
ok(request('/artists/99/show')->code == 404, 'Unknown resource /artists/99/show should return code 404');

# LIST
ok(request('/artists/list')->is_success, 'Get /artists/list');
content_like('/artists/list', '/davewood[\s\S]*flipper/', '/artists/list contains "davewood" and "flipper"');

# DELETE
#TODO delete should be POST request
my $res = request('/artists/1/delete');
ok($res->is_redirect, 'after successful delete a 302 redirect happens');
#TODO test that redirected URL returns 200
ok(request('/artists/1/show')->code == 404, 'delete resource /artists/1/show should now return code 404');

# CREATE
ok(request('/artists/create')->is_success, 'Get /artists/create');
content_like('/artists/create', '/method="post"/', '/artists/create contains "flipper"');

# EDIT
#ok(request('/artists/2/edit')->is_success, 'Get /artists/2/edit');
#content_like('/artists/2/edit', '/davewood/', '/artists/2/edit contains "flipper"');


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

