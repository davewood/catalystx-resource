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

# DELETE
{
    my $path ='/artists/1/delete';
    my $res = request(POST $path);
    ok($res->is_redirect, "$path returns HTTP 302");
    my $uri = URI->new($res->header('location'));
    is($uri->path, '/artists/list');
    my $content = get($uri->path);
    unlike($content, '/>davewood<\/a>/', 'resource has been deleted');
    TODO: {
        local $TODO = "stash_to_flash appears to not work with Catalyst::Test.";
        like($content, '/davewood deleted/', 'check delete success notification');
    }
    ok(request($path)->code == 404, "Already deleted $path returns HTTP 404");
}

# CREATE
{
    my $path ='/artists/create';
    my $res = request($path);
    ok($res->is_success, "$path returns HTTP 200");
    like($res->decoded_content, '/method="post"/', "$path content contains 'method=\"post\"'");
    $res = request(POST $path, [ name => 'simit' ]);
    ok($res->is_redirect, "$path returns HTTP 302");
    my $uri = URI->new($res->header('location'));
    is($uri->path, '/artists/list');
    my $content = get($uri->path);
    like($content, '/simit/', 'resource has been created');
    TODO: {
        local $TODO = "stash_to_flash appears to not work with Catalyst::Test.";
        like($content, '/davewood created/', 'check create success notification');
    }
}

# EDIT
{
    my $path ='/artists/2/edit';
    my $res = request($path);
    ok($res->is_success, "$path returns HTTP 200");
    like($res->decoded_content, '/method="post"/', "$path content contains 'method=\"post\"'");
    $res = request(POST $path, [ name => 'foobar' ]);
    ok($res->is_redirect, "$path returns HTTP 302");
    my $uri = URI->new($res->header('location'));
    is($uri->path, '/artists/list');
    my $content = get($uri->path);
    like($content, '/foobar/', 'resource has been edited');
    TODO: {
        local $TODO = "stash_to_flash appears to not work with Catalyst::Test.";
        like($content, '/foobar updated/', 'check edit success notification');
    }
}

done_testing;
