package CatalystX::Resource::Controller::Resource;
use Moose;
use namespace::autoclean;

# ABSTRACT: Base Controller for Resources

BEGIN { extends 'Catalyst::Controller::ActionRole'; }

use MooseX::Types::Moose qw/ ArrayRef /;
use MooseX::Types::Common::String qw/ NonEmptySimpleStr /;

with qw/
    CatalystX::Component::Traits
/;

# merge traits from app config with local traits
has '+_trait_merge' => (default => 1);

__PACKAGE__->config(
    traits => [qw/
        List
        Show
        Delete
        Form
        Create
        Edit
    /],
    action_roles => ['MatchRequestMethod'],
);

=head1 ATTRIBUTES

=head2 model

required, the DBIC model associated with this resource. (e.g.: 'DB::CDs')

=cut

has 'model' => (
    is       => 'ro',
    isa      => NonEmptySimpleStr,
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

=head2 redirect_mode list|show|show_parent

After a created/edit/delete action a redirect takes place.
The redirect behavior can be controlled with the redirect_mode attribute.

default = 'list'

=cut

has 'redirect_mode' => (
    is      => 'rw',
    isa     => NonEmptySimpleStr,
    default => 'list',
);

=head1 METHODS

=head2 _redirect

redirect request after create/edit/delete/move_next/move_previous

=cut

sub _redirect {
    my ( $self, $c ) = @_;

    my $path;
    my $mode = $self->redirect_mode;
    my @captures = @{ $c->request->captures };
    my $action = $c->action->name;

    ##############################
    # move_next || move_previous #
    ##############################
    # path: /parents/1/resources/1/move_next        => redirect_path: /parents/1/resources/list
    # path: /parents/1/resources/1/move_previous    => redirect_path: /parents/1/resources/list
    # path: /resources/1/move_next                  => redirect_path: /resources/list
    # path: /resources/1/move_previous              => redirect_path: /resources/list
    if ( $action eq 'move_next' || $action eq 'move_previous' ) {
        pop(@captures);
        $path = $c->uri_for_action($self->action_for('list'), \@captures);
    }

    ########################
    # redirect_mode 'list' #
    ########################
    # path: /parents/1/resources/create   => redirect_path: /parents/1/resources/list
    # path: /parents/1/resources/3/edit   => redirect_path: /parents/1/resources/list
    # path: /parents/1/resources/3/delete => redirect_path: /parents/1/resources/list
    elsif ( $mode eq 'list' ) {
        pop(@captures)
            unless $action eq 'create';
        $path = $c->uri_for_action($self->action_for('list'), \@captures);
    }

    ########################
    # redirect_mode 'show' #
    ########################
    # path: /parents/1/resources/create   => redirect_path: /parents/1/resources/<id>/show
    # path: /parents/1/resources/3/edit   => redirect_path: /parents/1/resources/3/show
    # path: /parents/1/resources/3/delete => redirect_path: /parents/1/resources/list
    elsif ( $mode eq 'show' ) {
        if ( $action eq 'create' ) {
            my $id_of_created_resource = $c->stash->{ $self->resource_key }->id;
            push @captures, $id_of_created_resource;
            $path = $c->uri_for_action($self->action_for('show'), \@captures);
        }
        elsif ( $action eq 'edit' ) {
            $path = $c->uri_for_action($self->action_for('show'), \@captures);
        }
        elsif ( $action eq 'delete' ) {
            pop(@captures);
            $path = $c->uri_for_action($self->action_for('list'), \@captures);
        }
    }

    ###############################
    # redirect_mode 'show_parent' #
    ###############################
    # path: /parents/1/resources/create   => redirect_path: /parents/1/show
    # path: /resources/create             => redirect_path: /resources/list
    # path: /parents/1/resources/3/edit   => redirect_path: /parents/1/show
    # path: /resources/3/edit             => redirect_path: /resources/list
    # path: /parents/1/resources/3/delete => redirect_path: /parents/1/show
    # path: /resources/3/delete           => redirect_path: /resources/list
    elsif ( $mode eq 'show_parent' ) {
        if ( $self->has_parent ) {
            my @chain = @{ $c->dispatcher->expand_action( $c->action )->{chain} };

            # base_with_id action of parent
            my $parent_base_with_id_action;
            if ($action eq 'create') {
                $parent_base_with_id_action = $chain[-3];
            }
            elsif ($action eq 'edit' || $action eq 'delete') {
                $parent_base_with_id_action = $chain[-4];
                pop @captures;
            }

            # parent namespace
            my $parent_namespace = $parent_base_with_id_action->{namespace};

            # private path of show action of parent
            my $parent_show_action_private_path = "$parent_namespace/show";
            $path = $c->uri_for_action($parent_show_action_private_path, \@captures);
        }
        else {
            $path = $c->uri_for_action($self->action_for('list'));
        }
    }

    $c->res->redirect($path);
}

=head2 _msg

returns notification msg to be displayed

=cut

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
    elsif ( $action eq 'move_next' ) {
        return $c->can('loc')
            ? $c->loc( 'resources.moved_next', $self->_name($c) )
            : $self->_name($c) . " moved next.";
    }
    elsif ( $action eq 'move_previous' ) {
        return $c->can('loc')
            ? $c->loc( 'resources.moved_previous', $self->_name($c) )
            : $self->_name($c) . " moved previous.";
    }
}

=head2 _name

get a meaningful name for the resource

=cut

sub _name {
    my ( $self, $c ) = @_;
    my $resource = $c->stash->{ $self->resource_key };
    my $name
        = $resource->result_source->has_column('name')
        ? $resource->name
        : ucfirst( $self->resource_key );
    return $name;
}

=head1 ACTIONS

the following actions will be loaded

=head2 base

Starts a chain and puts resultset into stash

For nested resources chain childrens 'base' action
to parents 'base_with_id' action

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

=head2 base_with_id

chains to 'base' and puts resource with id into stash

=cut

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

__PACKAGE__->meta->make_immutable();
1;
