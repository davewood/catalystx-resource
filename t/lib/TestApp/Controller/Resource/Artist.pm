package TestApp::Controller::Resource::Artist;
use Moose;
use namespace::autoclean;

__PACKAGE__->config(
    resultset_key => 'artists_rs',
    resources_key => 'artists',
    resource_key => 'artist',
    form_class => 'TestApp::Form::Resource::Artist',
    model => 'DB::Resource::Artist',
    redirect_mode => 'list',
    traits => ['MergeUploadParams'],
    activate_fields_create => [ qw/ password password_repeat /],
    actions => {
        base => {
            PathPart => 'artists',
        },
    },
);

BEGIN {
    extends 'CatalystX::Resource::Controller::Resource';
    with 'CatalystX::Resource::TraitFor::Controller::Resource::List';
    with 'CatalystX::Resource::TraitFor::Controller::Resource::Show';
    with 'CatalystX::Resource::TraitFor::Controller::Resource::Delete';
    with 'CatalystX::Resource::TraitFor::Controller::Resource::Form';
    with 'CatalystX::Resource::TraitFor::Controller::Resource::Create';
    with 'CatalystX::Resource::TraitFor::Controller::Resource::Edit';
    with 'CatalystX::Resource::TraitFor::Controller::Resource::Sortable';
    with 'CatalystX::Resource::TraitFor::Controller::Resource::MergeUploadParams';
}

1;
