package CatalystX::Resource;
use Moose::Role;
use CatalystX::InjectComponent;
use namespace::autoclean;

# ABSTRACT: Provide CRUD functionality to your Controllers

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
