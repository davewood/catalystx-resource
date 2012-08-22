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
my $artist;
lives_ok(sub { $artist = $schema->resultset('Resource::Artist')->create({ id => 1, name => 'davewood', password => 'asdf' }); }, 'create artist');
lives_ok(sub { $schema->resultset('Resource::Artist')->create({ id => 2, name => 'flipper', password => 'asdf' }); }, 'create artist');

my $album;
lives_ok(sub { $album = $artist->albums->create({ id => 1, name => 'Mach et einfach!' }); }, 'create album');

lives_ok(sub { $album->songs->create({ id => 1, name => 'smack my bitch up' }); }, 'create song 1');
lives_ok(sub { $album->songs->create({ id => 2, name => 'hit me baby one more time' }); }, 'create song 2');
lives_ok(sub { $album->songs->create({ id => 3, name => "drop it like it's hot" }); }, 'create song 3');

lives_ok(sub { $album->artworks->create({ id => 1, name => 'album coverfrontside' }); }, 'create artwork 1');
lives_ok(sub { $album->artworks->create({ id => 2, name => 'album coverbackside' }); }, 'create artwork 2');
lives_ok(sub { $album->artworks->create({ id => 3, name => "bonus pictures" }); }, 'create artwork 3');

lives_ok(sub { $album->lyrics->create({ id => 1, name => "lyric1" }); }, 'create lyric1');
lives_ok(sub { $album->lyrics->create({ id => 2, name => "lyric2" }); }, 'create lyric2');
lives_ok(sub { $album->lyrics->create({ id => 3, name => "lyric3" }); }, 'create lyric3');

# move_next
{
    my $path ='/artists/1/move_next';
    my $res = request($path);
    ok($res->is_error, "GET $path returns HTTP 404");
    $res = request(POST $path);
    ok($res->is_redirect, "$path returns HTTP 302");
    my $uri = URI->new($res->header('location'));
    is($uri->path, '/artists/list');
    my $cookie = $res->header('Set-Cookie');
    my $content = request(GET $uri->path, Cookie => $cookie)->decoded_content;
    like($content, '/davewood moved next/', 'check move_next success notification');
    like($content, '/flipper<\/a>.*davewood/s', 'resource has been moved to next position');
}

# move_previous
{
    my $path ='/artists/1/move_previous';
    my $res = request($path);
    ok($res->is_error, "GET $path returns HTTP 404");
    $res = request(POST $path);
    ok($res->is_redirect, "$path returns HTTP 302");
    my $uri = URI->new($res->header('location'));
    is($uri->path, '/artists/list');
    my $cookie = $res->header('Set-Cookie');
    my $content = request(GET $uri->path, Cookie => $cookie)->decoded_content;
    like($content, '/davewood moved previous/', 'check move_previous success notification');
    like($content, '/davewood<\/a>.*flipper/s', 'resource has been moved to previous position');
}

# nested resources
# move_next
{
    my $path ='/artists/1/albums/1/songs/1/move_next';
    my $res = request($path);
    ok($res->is_error, "GET $path returns HTTP 404");
    $res = request(POST $path);
    ok($res->is_redirect, "$path returns HTTP 302");
    my $uri = URI->new($res->header('location'));
    is($uri->path, '/artists/1/albums/1/songs/list');
    my $cookie = $res->header('Set-Cookie');
    my $content = request(GET $uri->path, Cookie => $cookie)->decoded_content;
    like($content, '/smack my bitch up moved next/', 'check move_next success notification');
    like($content, '/hit me baby one more time<\/a>.*smack my bitch up/s', 'resource has been moved to next position');
}

# move_previous
{
    my $path ='/artists/1/albums/1/songs/1/move_previous';
    my $res = request($path);
    ok($res->is_error, "GET $path returns HTTP 404");
    $res = request(POST $path);
    ok($res->is_redirect, "$path returns HTTP 302");
    my $uri = URI->new($res->header('location'));
    is($uri->path, '/artists/1/albums/1/songs/list');
    my $cookie = $res->header('Set-Cookie');
    my $content = request(GET $uri->path, Cookie => $cookie)->decoded_content;
    like($content, '/smack my bitch up moved previous/', 'check move_previous success notification');
    like($content, '/smack my bitch up<\/a>.*hit me baby one more time/s', 'resource has been moved to previous position');
}

# Nested resource, List trait of child resource is disabled
# redirect_mode = 'show_parent'
{
    my $path ='/artists/1/albums/1/artworks/1/move_next';
    my $res = request($path);
    ok($res->is_error, "GET $path returns HTTP 404");
    $res = request(POST $path);
    ok($res->is_redirect, "$path returns HTTP 302");
    my $uri = URI->new($res->header('location'));
    is($uri->path, '/artists/1/albums/1/show');
    my $cookie = $res->header('Set-Cookie');
    my $content = request(GET $uri->path, Cookie => $cookie)->decoded_content;
    like($content, '/album coverfrontside moved next/', 'check move_next success notification');
    like($content, '/coverbackside.*<strong>album coverfrontside<\/strong>/s', 'child resource coverfrontside listed after coverbackside on parent page');
}

# Nested resource
# redirect_mode = 'show'
{
    my $path ='/artists/1/albums/1/lyrics/1/move_next';
    my $res = request($path);
    ok($res->is_error, "GET $path returns HTTP 404");
    $res = request(POST $path);
    ok($res->is_redirect, "$path returns HTTP 302");
    my $uri = URI->new($res->header('location'));
    is($uri->path, '/artists/1/albums/1/lyrics/1/show');
    my $cookie = $res->header('Set-Cookie');
    my $content = request(GET $uri->path, Cookie => $cookie)->decoded_content;
    like($content, '/lyric1 moved next/', 'check move_next success notification');
}

done_testing;
