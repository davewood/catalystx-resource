use strict;
use warnings;
use Test::More;
use Test::Exception;
#use Class::MOP;
#use HTTP::Request::Common;
use FindBin qw/$Bin/;
use lib "$Bin/lib";

#BEGIN {
#    my @needed = qw/
#        Catalyst::Model::DBIC::Schema
#        Catalyst::Authentication::Store::DBIx::Class
#        DBIx::Class::Optional::Dependencies
#    /;
#    plan skip_all => "One of the required classes for this test $@ (" . join(',', @needed) . ") not found."
#        unless eval {
#            Class::MOP::load_class($_) for @needed; 1;
#        };
#    plan skip_all => 'Test needs ' . DBIx::Class::Optional::Dependencies->req_missing_for('admin')
#        unless DBIx::Class::Optional::Dependencies->req_ok_for('admin');
#}

use Catalyst::Test qw/TestApp/;

my $db_file = "$Bin/lib/TestApp/testdbic.db";
unlink $db_file if -e $db_file;

use_ok('TestApp::Schema');

my $schema;
lives_ok { $schema = TestApp::Schema->connect("DBI:SQLite:$db_file") }
    'Connect';
ok $schema;
lives_ok { $schema->deploy } 'deploy schema';

$schema->resultset('Artist')->create({
    id => 1,
    name => 'davewood',
});

ok(request('/')->is_success, 'Get /');
content_like('/', '/TestApp/', 'index action returns "TestApp"');

ok(request('/artists/1/show')->is_success, 'Get /artists/1/show');
content_like('/artists/1/show', '/davewood/', '/artists/1/show contains "davewood"');
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

