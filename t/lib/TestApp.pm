package TestApp;
use Moose;
use namespace::autoclean;

use Catalyst qw/
    +CatalystX::Resource
    Session
    Session::Store::FastMmap
    Session::State::Cookie
/;
extends 'Catalyst';

our $VERSION = '0.01';

__PACKAGE__->config(
    name => 'TestApp',
    #session => { flash_to_stash => 1 },
    'Model::DB' => {
        connect_info => {
            dsn => 'dbi:SQLite:' . __PACKAGE__->path_to('testdbic.db'),
            user => '',
            password => '',
        },
    },
    'View::HTML' => {
        INCLUDE_PATH => [
            __PACKAGE__->path_to( 'root', 'templates' )
        ],
        TEMPLATE_EXTENSION => '.tt',
        WRAPPER => 'wrapper.tt',
        ENCODING => 'UTF-8',
        render_die => 1,
    },
    'Controller::Resource::Artist' => {
        resultset_key => 'artists_rs',
        resources_key => 'artists',
        resource_key => 'artist',
        form_class => 'TestApp::Form::Resource::Artist',
        model => 'DB::Resource::Artist',
        actions => { 
            base => { 
                PathPart => 'artists',
            },
        },
    },
    'Controller::Resource::Album' => {
        resultset_key => 'albums_rs',
        resources_key => 'albums',
        resource_key => 'album',
        form_class => 'TestApp::Form::Resource::Album',
        model => 'DB::Resource::Album',
        traits => ['-Delete'],
        actions => { 
            base => { 
                PathPart => 'albums',
                Chained  => '/resource/artist/base_with_id',
            },
        },
    },
    'Controller::Resource::Song' => {
        resultset_key => 'songs_rs',
        resources_key => 'songs',
        resource_key => 'song',
        form_class => 'TestApp::Form::Resource::Song',
        model => 'DB::Resource::Song',
        actions => { 
            base => { 
                PathPart => 'songs',
                Chained  => '/resource/album/base_with_id',
            },
        },
    },
    'CatalystX::Resource' => {
        controllers => [ qw/ Artist Album Song / ],
     },
);

__PACKAGE__->setup();

1;
