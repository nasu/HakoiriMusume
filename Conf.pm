package Conf;
use strict;
use parent qw/Exporter/;
use Dot;
use constant +{
    W => '#', # wall
    E => '.', # empty
    S => ' ', # space
    BOTTOM => Dot->new( 1, 0),
    TOP    => Dot->new(-1, 0),
    RIGHT  => Dot->new( 0, 1),
    LEFT   => Dot->new( 0,-1),
};
our @EXPORT = qw/W E S BOTTOM TOP RIGHT LEFT/;
1;
