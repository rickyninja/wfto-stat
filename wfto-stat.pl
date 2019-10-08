#!/usr/bin/env perl

use strict;
use warnings;
use File::Temp qw(tempfile);
use YAML qw(LoadFile);
use Data::Dumper;
use Term::Prompt;

my $statfile = "$ENV{HOME}/GOG Games/War for the Overworld/game/WFTOGame_Data/GameData/stat.txt";
binmode STDOUT, ":utf8";
my $stats = LoadFile("$ENV{HOME}/yaml/stats.yml");
my $dlc = ask_dlc($stats);
my $ilevel = ask_level($stats, $dlc);
my $st = get_stats($statfile);
my @resets = select_achievements($stats, $dlc, $ilevel);
update_statfile($statfile, \@resets);
exec qq("$ENV{HOME}/GOG Games/War for the Overworld/start.sh");

sub select_achievements {
    my $stats = shift || die 'missing stats';
    my $dlc = shift || die 'missing dlc';
    my $ilevel = shift || die 'missing dlc';

    my @ach = map { "$_ = " . ($st->{$_} ? 'true' : 'false') } @{ $stats->{ $dlc }->[$ilevel]->{achievements} };
    my $list = prompt('m', {
        prompt => 'select achievements',
        items => \@ach,
        accept_multiple_selections => 1,
    }, '', '');
    my @resets = @{ $stats->{ $dlc }->[$ilevel]->{achievements}}[ @$list ];
    return @resets;
}

sub ask_level {
    my $stats = shift || die 'missing stats';
    my $dlc = shift || die 'missing dlc';

    my @levels = ();
    for (my $i = 0; $i < scalar(@{ $stats->{ $dlc } }); $i++) {
        push @levels, $stats->{ $dlc }->[$i]->{name};
    }
    my $i = prompt('m', {
        prompt => 'select level',
        items => \@levels,
    }, '', '');
    return $i;
}

sub ask_dlc {
    my $stats = shift || die 'missing stats';

    my @dlcs = grep { $_ ne 'none' } sort keys %$stats;
    my $i = prompt('m', {
        prompt => 'select dlc',
        items => \@dlcs,
    }, '', '');
    my $dlc = $dlcs[$i];
    return $dlc;
}

sub update_statfile {
    my $file = shift || die 'missing file';
    my $resets = shift || die 'missing resets';

    open my $in, '<', $statfile or die "Failed to open $statfile: $!";
    binmode $in, ":utf8";

    my ($tmp, $tmpname) = tempfile();
    binmode $tmp, ":utf8";

    while (my $line = <$in>) {
        for my $ach (@$resets) {
            $line =~ s/\Q$ach\E=true/$ach=/;
        }
        print $tmp $line or die "Failed write to $tmpname: $!";
    }
    close $in;
    close $tmp;
    #print scalar qx{grep '=\$' $tmpname}; exit;
    rename($tmpname, $statfile);
}

sub get_stats {
    my $file = shift || die 'missing file';

    my %stat;
    open my $in, '<', $file or die "Failed to open $file: $!";
    binmode $in, ":utf8";
    while (my $line = <$in>) {
        chomp($line);
        my ($ach, $bool) = split /=/, $line;
        $stat{$ach} = $bool eq 'true' ? 1 : 0;
    }
    close $in;
    return \%stat
}
