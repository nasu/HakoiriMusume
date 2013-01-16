package Dot;
use strict;
use overload 
    '+' => \&add,
    '-' => \&sub,
    '==' => \&eq,
    '""' => \&str,
;
sub new {
    my ($class, $x, $y) = @_;
    return bless +[$x,$y], $class;
}
sub x {shift->[0]}
sub y {shift->[1]}
sub add {
    my ($self, $b) = @_;
    return (ref $self)->new($self->x + $b->x, $self->y + $b->y);
}
sub sub {
    my ($self, $b) = @_;
    return (ref $self)->new($self->x - $b->x, $self->y - $b->y);
}
sub eq {
    my ($self, $b) = @_;
    return ($self->x == $b->x && $self->y == $b->y);
}
sub str {
    my ($self) = @_;
    return $self;
}
1;
