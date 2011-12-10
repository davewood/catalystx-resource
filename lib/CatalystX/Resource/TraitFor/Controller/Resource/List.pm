package CatalystX::Resource::TraitFor::Controller::Resource::List;

use MooseX::MethodAttributes::Role;
use namespace::autoclean;

requires qw/
    resources_key
    resultset_key
/;

=head1 ACTIONS

=head2 list

a list of all resources is accessible as $c->stash->{resources}

=cut

sub list : Chained('base') PathPart('list') Args(0) {
    my ( $self, $c ) = @_;
    $c->stash(
        $self->resources_key => [ $c->stash->{ $self->resultset_key }->all ]
    );
}

1;
