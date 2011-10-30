package CatalystX::TraitFor::Controller::Resource;

use strict;
use warnings;

use MooseX::MethodAttributes::Role;
use namespace::autoclean;

use MooseX::Types::Moose qw/ ArrayRef /;
use MooseX::Types::Common::String qw/ NonEmptySimpleStr /;

=head1 NAME

CatalystX::TraitFor::Controller::Resource - CRUD Role for your Controller

=head1 SYNOPSIS

    # a Resource Controller
    package MyApp::Controller::CDs;
    with 'CatalystX::TraitFor::Controller::Resource';
    __PACKAGE__->config(
        resultset_key   => 'cds_rs',
        resources_key   => 'cds',
        resource_key    => 'cd',
        model           => 'DB::CDs',
        form_class      => 'MyApp::Form::CDs',
        form_template   => 'cds/form.tt',
        redirect_mode   => 'show',
        actions         => {
            base => {
                PathPart    => 'cds',
            },
        },
    );
    
    # a nested Resource Controller
    package MyApp::Controller::Tracks;
    with 'CatalystX::TraitFor::Controller::Resource';
    __PACKAGE__->config(
        parent_key         => 'cd',
        parents_accessor   => 'tracks',
        resultset_key      => 'tracks_rs',
        resources_key      => 'tracks',
        resource_key       => 'track',
        model              => 'DB::Tracks',
        form_class         => 'MyApp::Form::Tracks',
        form_template      => 'tracks/form.tt',
        actions            => {
            base => {
                PathPart    => 'tracks',
                Chained     => '/cds/base_with_id',
            },
        },
    );

=head1 DESCRIPTION

CatalystX::TraitFor::Controller::Resource enhances the consuming Controller with CRUD 
functionality. It supports nested Resources and File Uploads.

    base
        index
        create
        base_with_id
            show
            edit
            delete

=head1 File Upload

    if your form includes a file upload you have to
    set the file param so HTML::FormHandler can work its magic
    (e.g.: in the Controller consuming this role)

        before 'form' => sub {
            my ( $self, $c, $resource ) = @_;
            if ($c->req->method eq 'POST') {
                $c->req->params->{'file'} = $c->req->upload('file');
            }
        };

=head1 ATTRIBUTES

=head2 model

required, the DBIC model associated with this resource. (e.g.: 'DB::CDs')

=cut

has 'model' => (
    is       => 'ro',
    required => 1,
);

=head2 resultset_key

stash key used to store the resultset of this resource. (e.g.: 'cds_rs')

=cut

has 'resultset_key' => (
    is       => 'ro',
    isa      => NonEmptySimpleStr,
    required => 1,
);

=head2 resources_key

stash key used to store all results of this resource. (e.g.: 'tracks')
You will need this to access a list of your resources in your template.

=cut

has 'resources_key' => (
    is       => 'ro',
    isa      => NonEmptySimpleStr,
    required => 1,
);

=head2 resource_key

stash key used to store specific result of this resource. (e.g.: 'track')
You will need this to access your resource in your template.

=cut

has 'resource_key' => (
    is       => 'ro',
    isa      => NonEmptySimpleStr,
    required => 1,
);

=head2 parent_key

for a nested resource 'parent_key' is used as stash key to store the parent item
(e.g.: 'cd')
this is required if parent_key is set

=cut

has 'parent_key' => (
    is        => 'ro',
    isa       => NonEmptySimpleStr,
    predicate => 'has_parent',
);

=head2 parents_accessor

the accessor on the parent resource to get a resultset
of this resource (accessor in DBIC has_many)
(e.g.: 'tracks')
this is required if parent_key is set

=cut

has 'parents_accessor' => (
    is  => 'ro',
    isa => NonEmptySimpleStr,
);

=head2 form_class

HTML::FormHandler class to use for this resource. 
e.g.: 'MyApp::Form::Resources'

=cut

has 'form_class' => (
    is       => 'ro',
    required => 1,
);

=head2 form_template

template file for HTML::FormHandler
optional, if you don't supply a form_template a stringified version will be used

=cut

has 'form_template' => (
    is        => 'ro',
    predicate => 'has_form_template',
);

=head2 activate_fields_create

hashref of form fields to activate in the create form
e.g. ['password', 'password_confirm']
default = []
Can be overriden with $c->stash->{activate_form_fields}

=cut

has 'activate_fields_create' => (
    is      => 'ro',
    isa     => ArrayRef,
    default => sub { [] },
);

=head2 activate_fields_edit

hashref of form fields to activate in the edit form
default = []
Can be overriden with $c->stash->{activate_form_fields}

=cut

has 'activate_fields_edit' => (
    is      => 'ro',
    isa     => ArrayRef,
    default => sub { [] },
);

=head2 redirect_mode

redirect after create/edit/delete can be 'show' or 'index'

default = 'show'

redirect_mode = show:
    resources/create   => resources/<id>/show
    resources/1/edit   => resources/1/show
    resources/1/delete => resources/
redirect_mode = index:
    resources/create   => resources/
    resources/1/edit   => resources/
    resources/1/delete => resources/
redirect_mode 'show_parent':
    path: /parents/1/resources/create   => redirect_path: /parents/1/show
    path: /parents/1/resources/3/edit   => redirect_path: /parents/1/show
    path: /parents/1/resources/3/delete => redirect_path: /parents/1/show

ATTENTION: If you add custom edit methods you have to make sure the PathPart starts with 'edit.*'. Otherwise redirection will fail.

=cut

has 'redirect_mode' => (
    is      => 'ro',
    default => 'index',
);

sub _path_part_prefix {
    my ( $self, $c ) = @_;
    my @path = split '/', $c->req->path;
    my $last;

    #if ($c->action->name =~ '^(edit|move|delete).*') {
    #} else {
    #}
    if ( $c->action->name eq 'create' ) {
        $last = @path - 3;
    }
    else {

        # edit*, move, delete
        $last = @path - 4;
    }
    my $path_part = join '/', @path[ 0 .. $last ];
    $path_part .= '/' if $path_part;
    return '/' . $path_part;
}

# redirect_mode 'index':
#   path: /parents/1/resources/create   => redirect_path: /parents/1/resources
#   path: /parents/1/resources/3/edit   => redirect_path: /parents/1/resources
#   path: /parents/1/resources/3/delete => redirect_path: /parents/1/resources
# redirect_mode 'show':
#   path: /parents/1/resources/create   => redirect_path: /parents/1/resources/<id>/show
#   path: /parents/1/resources/3/edit   => redirect_path: /parents/1/resources/3/show
#   path: /parents/1/resources/3/delete => redirect_path: /parents/1/resources
# redirect_mode 'show_parent':
#   path: /parents/1/resources/create   => redirect_path: /parents/1/show
#   path: /parents/1/resources/3/edit   => redirect_path: /parents/1/show
#   path: /parents/1/resources/3/delete => redirect_path: /parents/1/show
sub _redirect {
    my ( $self, $c ) = @_;
    my $path = '/';

    # get the path part array and compute a string
    my $path_part = join '/',
        @{ $self->action_for('base')->attributes->{PathPart} };
    if ( $self->redirect_mode eq 'index' ) {
        $path = $self->_path_part_prefix($c) . $path_part . '/';
    }
    elsif ( $self->redirect_mode eq 'show' ) {
        if ( $c->action->name eq 'delete' ) {
            $path = $self->_path_part_prefix($c) . $path_part . '/';
        }
        else {
            $path
                = $self->_path_part_prefix($c)
                . $path_part . '/'
                . $c->stash->{ $self->resource_key }->id . '/show';
        }
    }
    elsif ( $self->redirect_mode eq 'show_parent' ) {
        $path = $self->_path_part_prefix($c) . 'show';
    }
    $c->res->redirect($path);
}

=head1 PATHS

the following paths will be loaded

=cut

sub base : Chained('') PathPart('') CaptureArgs(0) {
    my ( $self, $c ) = @_;

    # Store the ResultSet in stash so it's available for other methods
    # get the model from the controllers config that consumes this role
    my $resultset;
    if ( $self->has_parent ) {
        $resultset = $c->stash->{ $self->parent_key }
            ->related_resultset( $self->parents_accessor );
    }
    else {
        $resultset = $c->model( $self->model );
    }
    $c->stash( $self->resultset_key => $resultset );
}

sub base_with_id : Chained('base') PathPart('') CaptureArgs(1) {
    my ( $self, $c, $id ) = @_;
    my $resource = $c->stash->{ $self->resultset_key }->find($id);
    if ($resource) {
        $c->stash->{ $self->resource_key } = $resource;
    }
    else {
        $c->stash( error_msg => $self->_msg( $c, 'not_found', $id ) );
        $c->detach('/error404');
    }
}

=head2 index

a list of all resources is accessible as $c->stash->{resources}

=cut

sub index : Chained('base') PathPart('') Args(0) {
    my ( $self, $c ) = @_;
    $c->stash(
        $self->resources_key => [ $c->stash->{ $self->resultset_key }->all ]
    );
}

=head2 show

the resource specified by its id is accessible as $c->stash->{resource}

=cut

sub show : Chained('base_with_id') PathPart('show') Args(0) {
    my ( $self, $c ) = @_;
}

=head2 create

create a resource

=cut

sub create : Chained('base') PathPart('create') Args(0) {
    my ( $self, $c ) = @_;
    my $resource = $c->stash->{ $self->resultset_key }->new_result( {} );
    $c->stash(
        $self->resource_key => $resource,
        set_create_msg      => 1,
    );
    $self->form( $c, $self->activate_fields_create );
}

=head2 delete

delete a specific resource

=cut

sub delete : Chained('base_with_id') PathPart('delete') Args(0) {
    my ( $self, $c ) = @_;
    my $resource = $c->stash->{ $self->resource_key };
    my $msg = $self->_msg( $c, 'delete' );
    $resource->delete($c);
    $c->flash( msg => $msg );
    $self->_redirect($c);
}

=head2 edit

edit a specific resource

=cut

sub edit : Chained('base_with_id') PathPart('edit') Args(0) {
    my ( $self, $c ) = @_;
    $c->stash( set_update_msg => 1 );
    $self->form( $c, $self->activate_fields_edit );
}

# $activate_fields is a hashref with fields to activate
# set $c->stash->{activate_form_fields} to override fields you want activated.
# e.g.: $c->stash->{activate_form_fields} = [ 'password', 'password_repeat' ]
sub form {
    my ( $self, $c, $activate_fields ) = @_;

    my $resource = $c->stash->{ $self->resource_key };

    # activate_form_fields in stash overrides activate_fields from config
    my $activate_form_fields = $c->stash->{activate_form_fields}
        || [@$activate_fields];

    # if you want to pass additional attributes to the form put a hashref in
    # the stash key 'form_attrs'
    my $form_attrs = $c->stash->{form_attrs} || {};

    my $form = $self->form_class->new(%$form_attrs);
    $form->process(
        active => $activate_form_fields,
        item   => $resource,
        params => $c->req->params,
    );

    if ( $self->has_form_template ) {
        $c->stash( template => $self->form_template, form => $form );
    }
    else {
        my $rendered_form = $form->render;
        $c->stash( template => \$rendered_form );
    }

    return unless $form->validated;

    if ( $c->stash->{set_create_msg} ) {
        $c->flash( msg => $self->_msg( $c, 'create' ) );
    }
    elsif ( $c->stash->{set_update_msg} ) {
        $c->flash( msg => $self->_msg( $c, 'update' ) );
    }

    $self->_redirect($c);
}

sub _msg {
    my ( $self, $c, $action, $id ) = @_;

    if ( $action eq 'not_found' ) {
        return $c->can('loc')
            ? $c->loc( 'error.resource_not_found', $id )
            : "No such resource: $id";
    }
    elsif ( $action eq 'create' ) {
        return $c->can('loc')
            ? $c->loc( 'resources.created', $self->_name($c) )
            : $self->_name($c) . " created.";
    }
    elsif ( $action eq 'update' ) {
        return $c->can('loc')
            ? $c->loc( 'resources.updated', $self->_name($c) )
            : $self->_name($c) . " updated.";
    }
    elsif ( $action eq 'delete' ) {
        return $c->can('loc')
            ? $c->loc( 'resources.deleted', $self->_name($c) )
            : $self->_name($c) . " deleted.";
    }
}

sub _name {
    my ( $self, $c ) = @_;
    my $resource = $c->stash->{ $self->resource_key };
    my $name
        = $resource->result_source->has_column('name')
        ? $resource->name
        : ucfirst( $self->resource_key );
    return $name;
}

=head1 AUTHOR

=over

=item David Schmidt (davewood) C<< <davewood@gmx.at> >>

=back

=head1 LICENSE

Copyright 2010 David Schmidt. Some rights reserved.

This software is free software and is licensed under the same terms as perl itself.

=cut

1;
