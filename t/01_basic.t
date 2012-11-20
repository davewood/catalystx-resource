use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";

use Test::More;
use Test::Moose;

BEGIN { use_ok('TestApp'); }

my $testapp = new_ok ( 'TestApp' );

{
    my $controller = $testapp->controller('Resource::Artist');

    is (
        $controller->{'catalyst_component_name'},
        'TestApp::Controller::Resource::Artist',
        'Injected controller has correct class name'
    );

    does_ok($controller, 'CatalystX::Resource::TraitFor::Controller::Resource::Form');
    does_ok($controller, 'CatalystX::Resource::TraitFor::Controller::Resource::List');
    does_ok($controller, 'CatalystX::Resource::TraitFor::Controller::Resource::Show');
    does_ok($controller, 'CatalystX::Resource::TraitFor::Controller::Resource::Create');
    does_ok($controller, 'CatalystX::Resource::TraitFor::Controller::Resource::Edit');
    does_ok($controller, 'CatalystX::Resource::TraitFor::Controller::Resource::Sortable');
    does_ok($controller, 'CatalystX::Resource::TraitFor::Controller::Resource::Delete');
    does_ok($controller, 'CatalystX::Resource::TraitFor::Controller::Resource::MergeUploadParams');

    for my $action_name (qw/base list show delete create edit/) {
        my $action = $controller->action_for($action_name);
        ok ( defined($action), "Controller has '$action_name' action." );
    }

    can_ok ( $controller, 'form' );
}

{
    my $controller = $testapp->controller('Resource::Concert');

    is (
        $controller->{'catalyst_component_name'},
        'TestApp::Controller::Resource::Concert',
        'Injected controller has correct class name'
    );

    does_ok($controller, 'CatalystX::Resource::TraitFor::Controller::Resource::Form');
    does_ok($controller, 'CatalystX::Resource::TraitFor::Controller::Resource::List');
    does_ok($controller, 'CatalystX::Resource::TraitFor::Controller::Resource::Show');
    does_ok($controller, 'CatalystX::Resource::TraitFor::Controller::Resource::Create');
    does_ok($controller, 'CatalystX::Resource::TraitFor::Controller::Resource::Edit');

    ok(!$controller->does('CatalystX::Resource::TraitFor::Controller::Resource::Delete'), 'Controller does not consume CatalystX::Resource::TraitFor::Controller::Resource::Delete');

    for my $action_name (qw/base list show create edit/) {
        my $action = $controller->action_for($action_name);
        ok ( defined($action), "Controller has '$action_name' action." );
    }

    ok (
        !$controller->does('CatalystX::Resource::TraitFor::Controller::Resource::Delete'),
        'Delete trait not available'
    );

    can_ok ( $controller, 'form' );
}

{
    my $controller = $testapp->controller('Resource::Song');

    is (
        $controller->{'catalyst_component_name'},
        'TestApp::Controller::Resource::Song',
        'Injected controller has correct class name'
    );

    does_ok($controller, 'CatalystX::Resource::TraitFor::Controller::Resource::Form');
    does_ok($controller, 'CatalystX::Resource::TraitFor::Controller::Resource::List');
    does_ok($controller, 'CatalystX::Resource::TraitFor::Controller::Resource::Show');
    does_ok($controller, 'CatalystX::Resource::TraitFor::Controller::Resource::Create');
    does_ok($controller, 'CatalystX::Resource::TraitFor::Controller::Resource::Edit');
    does_ok($controller, 'CatalystX::Resource::TraitFor::Controller::Resource::Delete');
    does_ok($controller, 'CatalystX::Resource::TraitFor::Controller::Resource::Sortable');

    for my $action_name (qw/base list show delete create edit move_next move_previous/) {
        my $action = $controller->action_for($action_name);
        ok ( defined($action), "Controller has '$action_name' action." );
    }

    can_ok ( $controller, 'form' );
}

done_testing();
