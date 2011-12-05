package TestApp;
use Moose;
use namespace::autoclean;

use Catalyst qw/
    +CatalystX::Resource
/;
extends 'Catalyst';

__PACKAGE__->config(
    name => 'TestApp',
    'Controller::Resource::Artist' => {
        resultset_key => 'artists_rs',
        resources_key => 'artists',
        resource_key => 'artist',
        form_class => 'Form::Artist',
        model => 'DB::Artist',
    },
    'Controller::Resource::Song' => {
        resultset_key => 'songs_rs',
        resources_key => 'songs',
        resource_key => 'song',
        form_class => 'Form::Song',
        model => 'DB::Songs',
        traits => ['-Delete'],
    },
    'CatalystX::Resource' => {
        controllers => ['Artist', 'Song'],
     },
);

__PACKAGE__->setup();

1;
