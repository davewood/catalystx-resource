package CatalystX::Resource;
use Moose::Role;
use CatalystX::InjectComponent;
use namespace::autoclean;

# ABSTRACT: Provide CRUD functionality to your Controllers

=head1 SYNOPSIS

=head1 DESCRIPTION

CatalystX::TraitFor::Controller::Resource enhances the consuming Controller with CRUD
functionality. It supports nested Resources and File Uploads.

    base
        index
        create
        base_with_id

=cut

after 'setup_components' => sub {
    my $class = shift;
    my $controllers = $class->config->{'CatalystX::Resource'}{'controllers'};
    for my $controller (@$controllers) {
        CatalystX::InjectComponent->inject(
            into => $class,
            component => 'CatalystX::Resource::Controller::Resource',
            as => 'Controller::Resource::' . $controller,
        );
    }
};

1;
