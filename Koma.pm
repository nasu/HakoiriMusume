package Koma;
use Dot;
use constant +{
};
sub new {
    my ($class) = @_;
    return bless +[], $class;
}
sub push {
    my ($self, $x, $y) = @_;
    CORE::push(@$self, Dot->new($x, $y));
    return $self;
}
sub around {
    my ($self, $map) = @_;
    my @around;
    for (@$self) {
        CORE::push(@around, +[Dot->new($_->x - 1, $_->y), +BOTTOM]);
        CORE::push(@around, +[Dot->new($_->x + 1, $_->y), +TOP]);
        CORE::push(@around, +[Dot->new($_->x, $_->y - 1), +RIGHT]);
        CORE::push(@around, +[Dot->new($_->x, $_->y + 1), +LEFT]);
    }
    return grep {$_->[0] =~ /^\d$/} map {+[$map->[$_->[0]->x]->[$_->[0]->y], $_->[1]]} @around;
}
sub slide {
    my ($self, $direct, $map) = @_;
    for my $my (@$self) {
        my $ne = $my->clone($direct);
        use Data::Dump;
        my $ne_name = $map->[$ne->x]->[$ne->y];
        return 0 unless ($ne_name eq +E || $ne_name eq $my->koma);
        ($map->[$my->x]->[$my->y], $map->[$ne->x]->[$ne->y]) = 
            ($map->[$ne->x]->[$ne->y], $map->[$my->x]->[$my->y]);
    }
    return 1;
}
1;
