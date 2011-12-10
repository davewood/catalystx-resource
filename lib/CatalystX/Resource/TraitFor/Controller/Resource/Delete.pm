package CatalystX::Resource::TraitFor::Controller::Resource::Delete;

use MooseX::MethodAttributes::Role;
use namespace::autoclean;

requires qw/
    resource_key
    _msg
    _redirect
/;

=head1 ACTIONS

=head2 delete

delete a specific resource with a POST request

=cut

sub delete : Chained('base_with_id') PathPart('delete') Args(0) {
    my ( $self, $c ) = @_;
    if ($c->req->method eq 'POST') {
        my $resource = $c->stash->{ $self->resource_key };
        my $msg = $self->_msg( $c, 'delete' );
        $resource->delete;
        $c->flash( msg => $msg );
        $self->_redirect($c);
    }
    else {
        $c->detach('/error404');
    }
}

1;
