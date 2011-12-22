package CatalystX::Resource::TraitFor::Controller::Resource::Sortable;

use MooseX::MethodAttributes::Role;
use namespace::autoclean;

# ABSTRACT: makes your resource sortable

requires qw/
    _msg
    resource_key
    _redirect
/;

# ABSTRACT: make your Resource sortable

=head1 SYNOPSIS

    # TestApp.pm
    'Controller::Resource::Artist' => {
        resultset_key => 'artists_rs',
        resources_key => 'artists',
        resource_key => 'artist',
        form_class => 'TestApp::Form::Resource::Artist',
        model => 'DB::Resource::Artist',
        redirect_mode => 'list',
        traits => ['Sortable'],
        actions => {
            base => {
                PathPart => 'artists',
            },
        },
    },

    # TestApp/Schema/Result/Resource/Artist.pm
    __PACKAGE__->load_components(qw/ Ordered Core /);
    __PACKAGE__->table('artist');
    __PACKAGE__->add_columns(
        ...,
        'position',
        {
            data_type => 'integer',
            is_numeric => 1,
            is_nullable => 0,
        },
    );

    __PACKAGE__->resultset_attributes({ order_by => 'position' });
    __PACKAGE__->position_column('position');

=head1 DESCRIPTION

adds these paths to your Controller which call move_previous/move_next
on your resource item as provided by L<DBIx::Class::Ordered>

Make sure the schema for your sortable resource has a 'position' column.

    /resource/*/move_previous
    /resource/*/move_next

For nested resources you need to set a grouping_column
Example: Artist has_many Albums has_many Songs

    # TestApp/Schema/Result/Resource/Song.pm
    __PACKAGE__->grouping_column('album_id');

=head1 ACTIONS

=head2 move_next

    will switch the resource with the next one

=cut

sub move_next : Method('POST') Chained('base_with_id') PathPart('move_next') Args(0) {
    my ( $self, $c ) = @_;
    my $resource = $c->stash->{ $self->resource_key };
    $resource->move_next;
    $c->flash( msg => $self->_msg( $c, 'move_next' ) );
    $self->_redirect($c);
}

=head2 move_previous

    will switch the resource with the previous one

=cut

sub move_previous : Method('POST') Chained('base_with_id') PathPart('move_previous') Args(0) {
    my ( $self, $c ) = @_;
    my $resource = $c->stash->{ $self->resource_key };
    $resource->move_previous;
    $c->flash( msg => $self->_msg( $c, 'move_previous' ) );
    $self->_redirect($c);
}

1;
