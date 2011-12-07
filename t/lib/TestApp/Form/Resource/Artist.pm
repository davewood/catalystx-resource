package TestApp::Form::Resource::Artist;
use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';

has '+item_class' => ( default => 'Resource::Artist' );

has_field 'name' => (
    type => 'Text',
    required => 1,
    size => 40,
);

has_field 'submit' => ( type => 'Submit', value => 'Submit' );

no HTML::FormHandler::Moose;
1;
