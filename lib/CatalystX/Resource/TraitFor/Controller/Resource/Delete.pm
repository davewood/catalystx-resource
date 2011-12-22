package CatalystX::Resource::TraitFor::Controller::Resource::Delete;

use MooseX::MethodAttributes::Role;
use namespace::autoclean;

# ABSTRACT: a delete action for your resource

requires qw/
    resource_key
    _msg
    _redirect
/;

=head1 ACTIONS

=head2 delete

delete a specific resource with a POST request

=cut

sub delete : Method('POST') Chained('base_with_id') PathPart('delete') Args(0) {
    my ( $self, $c ) = @_;
    my $resource = $c->stash->{ $self->resource_key };
    my $msg = $self->_msg( $c, 'delete' );
    $resource->delete;
    $c->flash( msg => $msg );
    $self->_redirect($c);
}

1;
