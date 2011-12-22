package CatalystX::Resource::TraitFor::Controller::Resource::Create;

use MooseX::MethodAttributes::Role;
use namespace::autoclean;

# ABSTRACT: a create action for your resource

requires qw/
    resultset_key
    resource_key
    form
/;

=head1 ATTRIBUTES

=head2 activate_fields_create

hashref of form fields to activate in the create form
e.g. ['password', 'password_confirm']
default = []
Can be overriden with $c->stash->{activate_form_fields}

Example: You only want admins to be able to change a field.
Disable field by default in HTML::FormHandler.

=cut

has 'activate_fields_create' => (
    is      => 'ro',
    isa     => 'ArrayRef',
    default => sub { [] },
);

=head1 ACTIONS

=head2 create

create a resource

=cut

sub create : Method('GET') Method('POST') Chained('base') PathPart('create') Args(0) {
    my ( $self, $c ) = @_;
    my $resource = $c->stash->{ $self->resultset_key }->new_result( {} );
    $c->stash(
        $self->resource_key => $resource,
        set_create_msg      => 1,
    );
    $self->form( $c, $self->activate_fields_create );
}

1;
