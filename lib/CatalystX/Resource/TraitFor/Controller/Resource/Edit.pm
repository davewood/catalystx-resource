package CatalystX::Resource::TraitFor::Controller::Resource::Edit;

use MooseX::MethodAttributes::Role;
use namespace::autoclean;

# ABSTRACT: a edit action for your resource

requires qw/
    form
/;


=head1 ATTRIBUTES

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

=head1 ACTIONS

=head2 edit

edit a specific resource

=cut

sub edit : Method('GET') Method('POST') Chained('base_with_id') PathPart('edit') Args(0) {
    my ( $self, $c ) = @_;
    $c->stash( set_update_msg => 1 );
    $self->form( $c, $self->activate_fields_edit );
}


1;
