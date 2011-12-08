use strict;
use warnings;
use Test::More;
use Test::Exception;
use HTTP::Request::Common;
use URI;
use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Catalyst::Test qw/TestApp/;

my $db_file = "$Bin/lib/TestApp/testdbic.db";
unlink $db_file if -e $db_file;

use_ok('TestApp::Schema');

my $schema;
lives_ok(
    sub { $schema = TestApp::Schema->connect("DBI:SQLite:$db_file") },
    'Connect'
);
ok($schema);
lives_ok(sub { $schema->deploy }, 'deploy schema');

# populate DB
$schema->resultset('Resource::Artist')->create({
    id => 1,
    name => 'davewood',
});
$schema->resultset('Resource::Artist')->create({
    id => 2,
    name => 'flipper',
});

# check redirection for redirect_mode = 'list'

# CREATE
{
    my $path ='/artists/create';
    my $res = request(POST $path, [ name => 'simit' ]);
    ok($res->is_redirect, "$path returns HTTP 302");
    my $uri = URI->new($res->header('location'));
    is($uri->path , '/artists/list');
    my $content = get($uri->path);
    like($content, '/simit/', "$path content contains 'simit'");
    TODO: {
        local $TODO = "stash_to_flash appears to not work with Catalyst::Test.";
        like($content, '/simit created/', 'check create success notification');
    }
}

# DELETE
{
    #TODO delete should be POST request
    my $path ='/artists/1/delete';
    my ($res, $c) = ctx_request($path);
    ok($res->is_redirect, "$path returns HTTP 302");
    my $uri = URI->new($res->header('location'));
    is($uri->path , '/artists/list');
    my $content = get($uri->path);
    TODO: {
        local $TODO = "stash_to_flash appears to not work with Catalyst::Test.";
        like($content, '/davewood deleted/', 'check delete success notification');
    }
    ok(request($path)->code == 404, "Already deleted $path returns HTTP 404");
}

# EDIT
#{
#}


#TODO test that redirected URL returns 200
#my $expanded = $c->dispatcher->expand_action($c->action);
#use Data::Dumper;
#die Dumper($expanded);
#is($expanded->{chain}->[-3]->{reverse}, 'resource/artist', 'Get namespace for controller');

## CREATE
#$path ='/artists/create';
#$res = request($path);
#ok($res->is_success, "$path returns HTTP 200");
#like($res->decoded_content, '/method="post"/', "$path content contains 'method=\"post\"'");
#$res = request(POST $path, [ name => 'simit' ]);
#ok($res->is_redirect, "$path returns HTTP 302");
#$path ='/artists/list';
#$res = request($path);
#like($res->decoded_content, '/simit/', "$path content contains 'simit'");
## check "msg" content after redirect
#
## EDIT
#$path ='/artists/2/edit';
#$res = request($path);
#ok($res->is_success, "$path returns HTTP 200");
#like($res->decoded_content, '/method="post"/', "$path content contains 'method=\"post\"'");
#like($res->decoded_content, '/flipper/', "$path content contains 'flipper'");
#$res = request(POST $path, [ name => 'willy' ]);
#ok($res->is_redirect, "$path returns HTTP 302");
#$path ='/artists/2/show';
#$res = request($path);
#like($res->decoded_content, '/willy/', "$path content contains 'willy'");
## check "msg" content after redirect


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
