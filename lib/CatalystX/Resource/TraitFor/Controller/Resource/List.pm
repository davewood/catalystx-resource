package CatalystX::Resource::TraitFor::Controller::Resource::List;

use MooseX::MethodAttributes::Role;
use namespace::autoclean;

# ABSTRACT: a list action for your resource

=head1 ACTIONS

=head2 list

display list (index) of all resources

=cut

sub list : Method('GET') Chained('base') PathPart('list') Args(0) {}

1;
