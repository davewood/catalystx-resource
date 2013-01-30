package CatalystX::Resource;
use Moose::Role;
use CatalystX::InjectComponent;
use namespace::autoclean;
use 5.010;

# ABSTRACT: Provide CRUD functionality to your Controllers

=head1 SYNOPSIS

    use Catalyst qw/
        +CatalystX::Resource
    /;

    __PACKAGE__->config(
        'Controller::Resource::Artist' => {
            resultset_key => 'artists_rs',
            resources_key => 'artists',
            resource_key => 'artist',
            form_class => 'TestApp::Form::Resource::Artist',
            model => 'DB::Resource::Artist',
            error_path => '/error',
            actions => {
                base => {
                    PathPart => 'artists',
                },
            },
        },
        'CatalystX::Resource' => {
            controllers => [ qw/ Artist / ],
         },
     );

=head1 DESCRIPTION

CatalystX::Resource enhances your App with CRUD functionality.

After creating files for HTML::FormHandler, DBIx::Class
and Template Toolkit templates you get create/edit/delete/show/list
actions for free.

Resources can be nested.
(e.g.: Artist has_many Albums)

=head2 traits

default traits:
    List
    Show
    Delete
    Form
    Create
    Edit

optional traits:
    Sortable
    MergeUploadParams

You can remove actions if you don't need them.

Example, you don't need the edit action:
    'Controller::Resource::Artist' => {
        ...,
        traits => ['-Edit'],
    },

Use the Sortable trait to make your resources sortable:
    'Controller::Resource::Artist' => {
        ...,
        traits => ['Sortable'],
    },

=head1 CONFIG

=head2 controllers

array ref of controller names which will be injected into your app

=head2 error_path

CatalystX::Resource detaches to $self->error_path if a resource cannot be found.
Make sure you implement this action in your App. (default: '/default')

=head1 CAVEAT

=head2 Using Moose Method Modifiers on your Resource Controller

If you want to apply Method Modifiers to a resource controller you have to
subclass from CatalystX::Resource::Controller::Resource and apply the roles in
a BEGIN block.

The following example loads the B<List> trait via B<with> in order to apply a
B<before> method modifier.

    package MyApp::Controller::Foo;
    use Moose;
    use namespace::autoclean;

    __PACKAGE__->config(
        resultset_key => 'artists_rs',
        resources_key => 'artists',
        resource_key  => 'artist',
        form_class    => 'TestApp::Form::Resource::Artist',
        model         => 'DB::Resource::Artist',
        traits        => [qw/ MergeUploadParams -Delete /],
        error_path    => '/error',
        actions       => {
            base => {
                PathPart => 'artists',
            },
        },
    );

    BEGIN {
        extends 'CatalystX::Resource::Controller::Resource';
        with 'CatalystX::Resource::TraitFor::Controller::Resource::List';
        with 'CatalystX::Resource::TraitFor::Controller::Resource::Show';
        with 'CatalystX::Resource::TraitFor::Controller::Resource::Form';
        with 'CatalystX::Resource::TraitFor::Controller::Resource::Create';
        with 'CatalystX::Resource::TraitFor::Controller::Resource::Edit';
        with 'CatalystX::Resource::TraitFor::Controller::Resource::Sortable';
    }

    before 'list' => sub { ... }

    1;

Because of a bug in L<MooseX::MethodAttributes>
L<CatalystX::Resource::TraitFor::Controller::Resource::MergeUploadParams> is not
applied correctly if you include it via C<with> in the C<BEGIN> block of the
subclassed controller.

Including it via C<traits =E<gt> ['MergeUploadParams']> works around this.

MergeUploadParams is different from the other roles. The other roles add a subroutine
whereas MergeUploadParams uses a Moose Method Modifier.

=head1 SEE ALSO

Check out L<Catalyst::Controller::DBIC::API> if you want to provide your data
as a web service.

=cut

after 'setup_components' => sub {
    my $class = shift;

    my $config      = $class->config->{'CatalystX::Resource'};
    my $controllers = $config->{controllers};

    for my $controller (@$controllers) {
        my $controller_name = 'Controller::' . $controller;
        $class->config->{$controller_name}{error_path} = $config->{error_path}
            if exists $config->{error_path};
        CatalystX::InjectComponent->inject(
            into      => $class,
            component => 'CatalystX::Resource::Controller::Resource',
            as        => $controller_name,
        );
    }
};

1;
