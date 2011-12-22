package CatalystX::Resource::TraitFor::Controller::Resource::Show;

use MooseX::MethodAttributes::Role;
use namespace::autoclean;

# ABSTRACT: a show action for your resource

=head1 ACTIONS

=head2 show

display the resource specified by its id, accessible as $c->stash->{resource}

=cut

sub show : Method('GET') Chained('base_with_id') PathPart('show') Args(0) {
    my ( $self, $c ) = @_;
}

1;
