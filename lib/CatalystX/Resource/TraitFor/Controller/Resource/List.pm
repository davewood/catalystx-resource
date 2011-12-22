package CatalystX::Resource::TraitFor::Controller::Resource::List;

use MooseX::MethodAttributes::Role;
use namespace::autoclean;

# ABSTRACT: a list action for your resource

requires qw/
    resources_key
    resultset_key
/;

=head1 ACTIONS

=head2 list

display list (index) of all resources

=cut

sub list : Method('GET') Chained('base') PathPart('list') Args(0) {
    my ( $self, $c ) = @_;
    $c->stash(
        $self->resources_key => [ $c->stash->{ $self->resultset_key }->all ]
    );
}

1;
