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

# CREATE
{
    my $path ='/artists/create';
    my $res = request($path);
    ok($res->is_success, "$path returns HTTP 200");
    like($res->decoded_content, '/my_custom_field_label/s', q/added field with label 'my_custom_field_label' via $c->stash->{form_attrs_process}/);
    like($res->decoded_content, '/my_custom_name_label/s', q/label of field 'name' changed via $c->stash->{form_attrs_process}/);
}

done_testing;
