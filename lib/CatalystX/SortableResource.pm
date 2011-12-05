package CatalystX::TraitFor::Controller::SortableResource;

use MooseX::MethodAttributes::Role;
use namespace::autoclean;
#
## rename _msg from CatalystX::TraitFor::Controller::Resource to _msg
## so we can provide our own _msg method (which calls __msg if needed)
#with 'CatalystX::TraitFor::Controller::Resource' => {
#    -alias    => { _msg => '__msg' },
#    -excludes => '_msg',
#};
#
## ABSTRACT: a Sortable CRUD Role for your Controller
#
#=head1 SYNOPSIS
#
#see L<CatalystX::TraitFor::Controller::Resource>
#
#=head1 DESCRIPTION
#
#adds these paths to your Controller which call move_previous/move_next
#on your resource item as provided by L<DBIx::Class::Ordered>
#
#    /resource/*/move_previous
#    /resource/*/move_next
#
#the following action tree will be created
#
#    base
#        index
#        create
#        base_with_id
#            show
#            edit
#            delete
#            move_previous
#            move_next
#
#=head2 move_previous
#    
#    will switch the resource with the previous one
#
#=head2 move_next
#    
#    will switch the resource with the next one
#
#=cut
#
#sub move_next : Chained('base_with_id') PathPart('move_next') Args(0) {
#    my ( $self, $c ) = @_;
#    my $resource = $c->stash->{ $self->resource_key };
#    $resource->move_next;
#    $c->flash( msg => $self->_msg( $c, 'move_next' ) );
#    $self->_redirect($c);
#}
#
#sub move_previous : Chained('base_with_id') PathPart('move_previous') Args(0)
#{
#    my ( $self, $c ) = @_;
#    my $resource = $c->stash->{ $self->resource_key };
#    $resource->move_previous;
#    $c->flash( msg => $self->_msg( $c, 'move_previous' ) );
#    $self->_redirect($c);
#}
#
#sub _msg {
#    my ( $self, $c, $action, $id ) = @_;
#
#    if ( $action eq 'move_next' ) {
#        return $c->can('loc')
#            ? $c->loc( 'resources.moved_next', $self->_name($c) )
#            : $self->_name($c) . " moved next.";
#    }
#    elsif ( $action eq 'move_previous' ) {
#        return $c->can('loc')
#            ? $c->loc( 'resources.moved_previous', $self->_name($c) )
#            : $self->_name($c) . " moved previous.";
#    }
#
#    return $self->__msg( $c, $action, $id );
#}
#
1;
