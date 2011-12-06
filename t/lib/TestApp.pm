package TestApp;
use Moose;
use namespace::autoclean;

use Catalyst qw/
    +CatalystX::Resource
/;
extends 'Catalyst';

our $VERSION = '0.01';

__PACKAGE__->config(
    name => 'TestApp',
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
        form_class => 'Form::Artist',
        model => 'DB::Artist',
        actions => { 
            base => { 
                PathPart => 'artists',
            },
        },
    },
    'Controller::Resource::Song' => {
        resultset_key => 'songs_rs',
        resources_key => 'songs',
        resource_key => 'song',
        form_class => 'Form::Song',
        model => 'DB::Songs',
        traits => ['-Delete'],
        actions => { 
            base => { 
                PathPart => 'songs',
                Chained  => '/resource/artist/base_with_id',
            },
        },
    },
    'CatalystX::Resource' => {
        controllers => ['Artist', 'Song'],
     },
);

__PACKAGE__->setup();

1;
