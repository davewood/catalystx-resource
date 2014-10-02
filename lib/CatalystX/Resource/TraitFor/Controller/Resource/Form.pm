package CatalystX::Resource::TraitFor::Controller::Resource::Form;

use MooseX::MethodAttributes::Role;
use MooseX::Types::LoadableClass qw/ LoadableClass /;
use namespace::autoclean;

# ABSTRACT: handles form related stuff

requires qw/
    resource_key
    _msg
    _redirect
/;

=head1 ATTRIBUTES

=head2 form_class

HTML::FormHandler class to use for this resource.

e.g.: 'MyApp::Form::Resources'

=cut

has 'form_class' => (
    is       => 'rw',
    required => 1,
    isa      => LoadableClass,
    coerce   => 1,
);

=head2 form_template

template file for HTML::FormHandler

optional, if you don't supply a form_template a stringified version will be used

=cut

has 'form_template' => (
    is        => 'ro',
    predicate => 'has_form_template',
);

=head1 METHODS

=head2 form

handle form validation, configuration of visible fields
and setting of notification messages

=cut

sub form {
    my ( $self, $c, $activate_fields ) = @_;

    my $resource = $c->stash->{ $self->resource_key };

    # activate_form_fields in stash overrides activate_fields from config
    my $activate_form_fields =
      exists $c->stash->{activate_form_fields}
      ? $c->stash->{activate_form_fields}
      : [@$activate_fields];

    my $form_attrs_new =
      exists $c->stash->{form_attrs_new} ? $c->stash->{form_attrs_new} : {};
    my $form_attrs_process =
      exists $c->stash->{form_attrs_process} ? $c->stash->{form_attrs_process} : {};

    my $form = $self->form_class->new(%$form_attrs_new);
    $form->process(
        active => $activate_form_fields,
        item   => $resource,
        params => $c->req->params,
        posted => ($c->req->method eq 'POST'),
       %$form_attrs_process,
    );

    if ( $self->has_form_template ) {
        $c->stash( template => $self->form_template, form => $form );
    }
    else {
        my $rendered_form = $form->render;
        $c->stash( template => \$rendered_form );
    }

    return unless $form->validated;

    if ( $c->stash->{set_create_msg} ) {
        $c->flash( msg => $self->_msg( $c, 'create' ) );
    }
    elsif ( $c->stash->{set_update_msg} ) {
        $c->flash( msg => $self->_msg( $c, 'update' ) );
    }

    $self->_redirect($c);
}

=head1 Catalyst stash variables

=head2 form_attrs_new

you can pass attributes to $form->new via $c->stash->{form_attrs_new}

  $c->stash->{form_attrs_new} = { #... };

=cut

=head2 form_attrs_process

you can pass attributes to $form->process via $c->stash->{form_attrs_process}

  $c->stash->{form_attrs_process} = { posted => 0 };

=cut

1;
