package CatalystX::Resource::TraitFor::Controller::Resource::Sortable;

use MooseX::MethodAttributes::Role;
use namespace::autoclean;

requires qw/
    _msg
    resource_key
    _redirect
/;

# ABSTRACT: a Sortable CRUD Role for your Controller

=head1 SYNOPSIS

=cut

=head1 DESCRIPTION

adds these paths to your Controller which call move_previous/move_next
on your resource item as provided by L<DBIx::Class::Ordered>

Make sure the schema for your sortable resource has a 'position' column.

    /resource/*/move_previous
    /resource/*/move_next

=cut

=head2 move_next
    
    will switch the resource with the next one

=cut

sub move_next : Chained('base_with_id') PathPart('move_next') Args(0) {
    my ( $self, $c ) = @_;
    my $resource = $c->stash->{ $self->resource_key };
    $resource->move_next;
    $c->flash( msg => $self->_msg( $c, 'move_next' ) );
    $self->_redirect($c); #TODO redirect behaviour
}

=head2 move_previous
    
    will switch the resource with the previous one

=cut

sub move_previous : Chained('base_with_id') PathPart('move_previous') Args(0)
{
    my ( $self, $c ) = @_;
    my $resource = $c->stash->{ $self->resource_key };
    $resource->move_previous;
    $c->flash( msg => $self->_msg( $c, 'move_previous' ) );
    $self->_redirect($c);
}

1;
