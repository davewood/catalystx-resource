use strict;
use warnings;
use Test::More;
use Test::Exception;
use HTTP::Request::Common;
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
ok $schema;
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


# test / for no special reason
{
    my $path = '/';
    my $res = request($path);
    ok($res->is_success, "$path returns HTTP 200");
    like($res->decoded_content, '/TestApp/', "$path content contains string 'TestApp'");
}

# SHOW
{
    my $path ='/artists/1/show';
    my $res = request($path);
    ok($res->is_success, "$path returns HTTP 200");
    like($res->decoded_content, '/davewood/', "$path content contains string 'davewood'");
    $path = '/artists/99/show';
    ok(request($path)->code == 404, "Unknown resource $path returns HTTP 404");
}

# LIST
{
    my $path ='/artists/list';
    my $res = request($path);
    ok($res->is_success, "Get $path");
    like($res->decoded_content, '/davewood[\s\S]*flipper/', "$path content contains 'davewood' and 'flipper'");
}

# DELETE
{
    my $path ='/artists/1/delete';
    my $res = request($path);
    ok($res->is_error, "delete with GET returns HTTP 404");
    $res = request(POST $path);
    ok($res->is_redirect, "$path returns HTTP 302");
    ok(request(POST $path)->code == 404, "Already deleted $path returns HTTP 404");
}

# CREATE
{
    my $path ='/artists/create';
    my $res = request($path);
    ok($res->is_success, "$path returns HTTP 200");
    like($res->decoded_content, '/method="post"/', "$path content contains 'method=\"post\"'");
    $res = request(POST $path, [ name => 'simit' ]);
    ok($res->is_redirect, "$path returns HTTP 302");
    $path ='/artists/list';
    $res = request($path);
    like($res->decoded_content, '/simit/', "$path content contains 'simit'");
}

# EDIT
{
    my $path ='/artists/2/edit';
    my $res = request($path);
    ok($res->is_success, "$path returns HTTP 200");
    like($res->decoded_content, '/method="post"/', "$path content contains 'method=\"post\"'");
    like($res->decoded_content, '/flipper/', "$path content contains 'flipper'");
    $res = request(POST $path, [ name => 'willy' ]);
    ok($res->is_redirect, "$path returns HTTP 302");
    $path ='/artists/2/show';
    $res = request($path);
    like($res->decoded_content, '/willy/', "$path content contains 'willy'");
}

done_testing;
