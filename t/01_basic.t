use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";

use Test::More;

BEGIN { use_ok('TestApp'); }

my $testapp = new_ok ( 'TestApp' );

my $controller = $testapp->controller('Resource::Artist');

is (
    $controller->{'catalyst_component_name'},
    'TestApp::Controller::Resource::Artist',
    'Injected controller has correct class name'
);

for my $action_name (qw/base list show delete create edit/) {
    my $action = $controller->action_for($action_name);
    ok ( defined($action), "Controller has '$action_name' action." );
}

can_ok ( $controller, 'form' );


$controller = $testapp->controller('Resource::Album');

is (
    $controller->{'catalyst_component_name'},
    'TestApp::Controller::Resource::Album',
    'Injected controller has correct class name'
);

for my $action_name (qw/base list show create edit/) {
    my $action = $controller->action_for($action_name);
    ok ( defined($action), "Controller has '$action_name' action." );
}

# Delete trait has been removed in TestApp.pm
ok ( !$controller->can('delete') );

can_ok ( $controller, 'form' );

done_testing();
