package CatalystX::Resource::TraitFor::Controller::Resource::Edit;

use MooseX::MethodAttributes::Role;
use namespace::autoclean;

requires qw/
    form
/;

=head2 edit

edit a specific resource

=cut

sub edit : Chained('base_with_id') PathPart('edit') Args(0) {
    my ( $self, $c ) = @_;
    $c->stash( set_update_msg => 1 );
    $self->form( $c, $self->activate_fields_edit );
}

=head2 activate_fields_edit

hashref of form fields to activate in the edit form
default = []
Can be overriden with $c->stash->{activate_form_fields}

=cut

has 'activate_fields_edit' => (
    is      => 'ro',
    isa     => 'ArrayRef',
    default => sub { [] },
);

1;
