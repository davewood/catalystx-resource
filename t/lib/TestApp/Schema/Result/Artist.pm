package TestApp::Schema::Result::Artist;
use strict;
use warnings;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/ Core /);
__PACKAGE__->table('artist');
__PACKAGE__->add_columns(
    id => {
        data_type => 'int',
        is_auto_increment => 1
    },
    name => {
        data_type => 'varchar',
    },
);

__PACKAGE__->set_primary_key ('id');

1;
