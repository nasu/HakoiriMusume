#!/usr/bin/env perl
use strict;
use lib qw/./;
use Data::Dump;
use Time::HiRes qw/sleep/;
use Conf;
use Map;
use Dot;
sub input {
    my @map;
    while (my $line = <STDIN>) {
        chomp $line;
        push(@map, +[split //, $line]);
    }
    return Map->new(\@map);
}
sub solve {
    push my @queue, +{map => @_[0], path => +[@_[0]]};
    my %memo;
    SOLVE: while (1) {
        my $cur = shift @queue;
        my ($map, $path) = ($cur->{map}, $cur->{path});
        #print scalar(@$path) . "@" . scalar(@queue) . "\n";
        #$map->snapshot;
        #use Data::Dump; dd %memo;
        #sleep(0.3);

        my @goal_around = grep {
            $map->dot($_->[0]) eq '0'
        } map {
            +[$_ + BOTTOM, $_],
            +[$_ + TOP,    $_],
            +[$_ + RIGHT,  $_],
            +[$_ + LEFT,   $_],
        } $map->goals;
        for (@goal_around) {
            my $new_map = $map->slide($_->[0], $_->[1], direct => +S);
            if ($new_map) {
                print "CLEAR! n=" . scalar(@$path) . "\n";
                $_->snapshot for @$path;
                last SOLVE;
            }
        }

        my @empty_around = grep {
            $map->dot($_->[0]) ne +E &&
            $map->dot($_->[0]) ne +S &&
            $map->dot($_->[0]) ne +W &&
            $map->dot($_->[0]) ne undef
        } map {
            +[$_ + BOTTOM, $_],
            +[$_ + TOP,    $_],
            +[$_ + RIGHT,  $_],
            +[$_ + LEFT,   $_],
        } $map->empties;
        for (@empty_around) {
            my $new_map = $map->slide($_->[0], $_->[1]);
            next unless $new_map;
            next if exists $memo{$new_map->flatten};
            $memo{$new_map->flatten} = 1;
            push(@queue, +{
                map => $new_map,
                path => +[@$path, $new_map],
            });
        }
        last unless scalar @queue;
    }
}

MAIN: {
solve(input);
};
