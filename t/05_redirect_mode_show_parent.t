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
ok(defined $schema, 'got a schema');
lives_ok(sub { $schema->deploy }, 'deploy schema');

# populate DB
$schema->resultset('Resource::Artist')->create({
    id => 1,
    name => 'davewood',
    password => 'asdf',
});
my $artist = $schema->resultset('Resource::Artist')->create({
    id => 2,
    name => 'flipper',
    password => 'asdf',
});
lives_ok(sub { $artist->albums->create({ id => 1, name => 'Mach et einfach!' }); }, 'create album');

# change redirect_mode to 'show_parent'
# 'list' is default but we overwrote it in TestApp.pm
{
    my ($res, $c) = ctx_request(GET '/');
    for my $resource (qw/ Artist Concert Album Song /) {
        my $controller = $c->controller("Resource::$resource");
        $controller->redirect_mode('show_parent');
    }
}

# check redirection for redirect_mode = 'list'
# CREATE
{
    my $path ='/artists/create';
    my $res = request($path);
    ok($res->is_success, "$path returns HTTP 200");
    like($res->decoded_content, '/method="post"/', "$path content contains 'method=\"post\"'");
    $res = request(POST $path, [ name => 'simit', password => 'asdf', password_repeat => 'asdf' ]);
    ok($res->is_redirect, "$path returns HTTP 302");
    my $uri = URI->new($res->header('location'));
    is($uri->path, '/artists/list', 'redirect location is correct');
    my $cookie = $res->header('Set-Cookie');
    my $content = request(GET $uri->path, Cookie => $cookie)->decoded_content;
    like($content, '/show">simit/', 'resource has been created');
    like($content, '/simit created/', 'check create success notification');
}

# DELETE
{
    my $path ='/artists/1/delete';
    my $res = request(POST $path);
    ok($res->is_redirect, "$path returns HTTP 302");
    my $uri = URI->new($res->header('location'));
    is($uri->path, '/artists/list', 'redirect location is correct');
    my $cookie = $res->header('Set-Cookie');
    my $content = request(GET $uri->path, Cookie => $cookie)->decoded_content;
    unlike($content, '/show">davewood/', 'resource has been deleted');
    like($content, '/davewood deleted/', 'check delete success notification');
    ok(request(POST $path)->code == 404, "Already deleted $path returns HTTP 404");
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
    is($uri->path, '/artists/list', 'redirect location is correct');
    my $cookie = $res->header('Set-Cookie');
    my $content = request(GET $uri->path, Cookie => $cookie)->decoded_content;
    like($content, '/show">foobar/', 'resource has been edited');
    like($content, '/foobar updated/', 'check edit success notification');
}

# for nested resources
# CREATE
{
    my $path ='/artists/2/albums/create';
    my $res = request($path);
    ok($res->is_success, "$path returns HTTP 200");
    like($res->decoded_content, '/method="post"/', "$path content contains 'method=\"post\"'");
    $res = request(POST $path, [ name => 'I Brake Together' ]);
    ok($res->is_redirect, "$path returns HTTP 302");
    my $uri = URI->new($res->header('location'));
    is($uri->path, '/artists/2/show', 'redirect location is correct');
    my $cookie = $res->header('Set-Cookie');
    my $content = request(GET $uri->path, Cookie => $cookie)->decoded_content;
    like($content, '/I Brake Together created/', 'check create success notification');
}

# EDIT
{
    my $path ='/artists/2/albums/2/edit';
    my $res = request($path);
    ok($res->is_success, "$path returns HTTP 200");
    like($res->decoded_content, '/method="post"/', "$path content contains 'method=\"post\"'");
    $res = request(POST $path, [ name => 'Es gibt Reis, Baby' ]);
    ok($res->is_redirect, "$path returns HTTP 302");
    my $uri = URI->new($res->header('location'));
    is($uri->path, '/artists/2/show', 'redirect location is correct');
    my $cookie = $res->header('Set-Cookie');
    my $content = request(GET $uri->path, Cookie => $cookie)->decoded_content;
    like($content, '/Es gibt Reis, Baby updated/', 'check edit success notification');
}

# DELETE
{
    my $path ='/artists/2/albums/2/delete';
    my $res = request(POST $path);
    ok($res->is_redirect, "$path returns HTTP 302");
    my $uri = URI->new($res->header('location'));
    is($uri->path, '/artists/2/show', 'redirect location is correct');
    my $cookie = $res->header('Set-Cookie');
    my $content = request(GET $uri->path, Cookie => $cookie)->decoded_content;
    like($content, '/Es gibt Reis, Baby deleted/', 'check delete success notification');
    ok(request(POST $path)->code == 404, "Already deleted $path returns HTTP 404");
}

done_testing;
