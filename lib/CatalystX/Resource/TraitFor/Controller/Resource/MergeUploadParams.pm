package CatalystX::Resource::TraitFor::Controller::Resource::MergeUploadParams;

use MooseX::MethodAttributes::Role;
use namespace::autoclean;

# ABSTRACT: merge upload params into request params

requires qw/
    form
/;

=head1 METHOD MODIFIERS

=head2 before 'form'

merge $c->req->uploads into $c->req->params

Makes Catalyst::Request::Upload objects available in
HTML::FormHandler::params

You might need this if you are using HTML::FormHandler
and DBIx::Class::InflateColumn::FS

=cut

before 'form' => sub {
    my ( $self, $c, $activate_fields ) = @_;

    # for each upload put the Catalyst::Request::Upload object into $params
    if ( $c->req->method eq 'POST' ) {
        while (my ($param_name, $upload) = each %{$c->req->uploads}) {
            $c->req->params->{$param_name} = $upload;
        }
    }
};

1;
