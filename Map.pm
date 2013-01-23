package Map;
use strict;
use parent qw/Clone/;
use feature qw/switch/;
use List::AllUtils qw/any/;
use Conf;
sub new {
    my ($class, $map) = @_;
    return bless +[@$map], $class;
}
sub copy {shift->clone}
sub dot : lvalue {
    my ($self, $dot) = @_;
    $self->[$dot->x]->[$dot->y];
}
sub same {
    my ($self, $dot) = @_;
    my @same;
    for (my $i=0,my $im=scalar @$self; $i<$im; $i++) {
        for (my $j=0,my $jm=scalar @{$self->[$i]}; $j<$jm; $j++) {
            if ($self->dot($dot) eq $self->[$i]->[$j]) {
                next if $dot->x == $i && $dot->y == $j;
                push(@same, Dot->new($i,$j));
            }
        }
    }
    return @same;
}

sub snapshot {
    my ($self) = @_;
    local $\ = "\n";
    print @$_ for @$self;
}

sub flatten {
    my ($self) = @_;
    my $flat;
    my %mapping;
    for (my $i=0,my $im=scalar @$self; $i<$im; $i++) {
        for (my $j=0,my $jm=scalar @{$self->[$i]}; $j<$jm; $j++) {
            my $p = $self->[$i]->[$j];
            next if any {$p eq $_} +(+W, +S, +E, '0');
            given ($mapping{$p}) {
            when ('A') {
                my $dot = Dot->new($i,$j);
                my @same = $self->same($dot);
                given (scalar @same) {
                when (1) {
                    given ($same[0] - $dot) {
                    when (+[+LEFT, +RIGHT]) {$mapping{$p} = 'B'}
                    when (+[+TOP, +BOTTOM]) {$mapping{$p} = 'C'}
                    }
                }
                }
            }
            when (undef) {$mapping{$p} = 'A'}
            }
        }
    }
    $flat .= join('', map {
        $mapping{$_} || $_
    } grep {$_ ne +W && $_ ne +S} @$_) for @$self;
    #print $flat . "\n";
    return $flat;
}

sub empties {
    my ($self) = @_;
    my @empty;
    for (my $i=0,my $im=scalar @$self; $i<$im; $i++) {
        for (my $j=0,my $jm=scalar @{$self->[$i]}; $j<$jm; $j++) {
            push(@empty, Dot->new($i,$j)) if $self->[$i]->[$j] eq +E;
        }
    }
    return @empty;
}

sub goals {
    my ($self) = @_;
    my @goal;
    for (my $i=0,my $im=scalar @$self; $i<$im; $i++) {
        for (my $j=0,my $jm=scalar @{$self->[$i]}; $j<$jm; $j++) {
            push(@goal, Dot->new($i,$j)) if $self->[$i]->[$j] eq +S;
        }
    }
    return @goal;
}

sub slide {
    my ($self, $from, $to, %opt) = @_;
    if ($opt{without_copy}) {
        ($self->dot($from), $self->dot($to)) = ($self->dot($to), $self->dot($from));
        return $self;
    }
    $self = $self->copy;
    my @same = $self->same($from);
    ($self->dot($from), $self->dot($to)) = ($self->dot($to), $self->dot($from));
    my $direct = $to - $from;
    for (@same) {
        if ($self->dot($_ + $direct) eq ($opt{direct} || +E)) {
            $self = $self->slide($_, $_ + $direct, without_copy => 1);
        } elsif ($self->dot($_ + $direct) eq $self->dot($_)) {
            $self = $self->slide($_, $_ + $direct, without_copy => 1);
            push(@same, $_);
        } else {
            return;
        }
    }
    return $self;
}
1;
