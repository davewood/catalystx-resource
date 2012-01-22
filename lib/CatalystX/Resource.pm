package CatalystX::Resource;
use Moose::Role;
use CatalystX::InjectComponent;
use namespace::autoclean;

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

You can remove actions if you don't need them.

Example, you don't need the edit action:
    'Controller::Resource::Artist' => {
        ...,
        traits => ['-Edit'],
    },
    
Using the Sortable trait your resources are sortable:
    'Controller::Resource::Artist' => {
        ...,
        traits => ['Sortable'],
    },

=head1 CAVEAT

CatalystX::Resource detaches to '/error404' if a resource cannot be found.
Make sure you implement this action in your App.

=cut

after 'setup_components' => sub {
    my $class = shift;
    my $controllers = $class->config->{'CatalystX::Resource'}{'controllers'};
    for my $controller (@$controllers) {
        CatalystX::InjectComponent->inject(
            into => $class,
            component => 'CatalystX::Resource::Controller::Resource',
            as => 'Controller::' . $controller,
        );
    }
};

1;
