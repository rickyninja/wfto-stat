#!/usr/bin/env perl

use strict;
use warnings;
use File::Temp qw(tempfile);
use YAML qw(LoadFile);
use Data::Dumper;
use Term::Prompt;

binmode STDOUT, ":utf8";
my $stats = LoadFile("$ENV{HOME}/yaml/stats.yml");
my @dlcs = grep { $_ ne 'none' } sort keys %$stats;
my $i = prompt('m', {
    prompt => 'select dlc',
    items => \@dlcs,
}, '', '');
my $dlc = $dlcs[$i];
my @levels = ();
for (my $i = 0; $i < scalar(@{ $stats->{ $dlc } }); $i++) {
    push @levels, $stats->{ $dlc }->[$i]->{name};
}
$i = prompt('m', {
    prompt => 'select level',
    items => \@levels,
}, '', '');
my @ach = @{ $stats->{ $dlc }->[$i]->{achievements} };
my $list = prompt('m', {
    prompt => 'select achievements',
    items => \@ach,
    accept_multiple_selections => 1,
}, '', '');
my @resets = @{ $stats->{ $dlc }->[$i]->{achievements}}[ @$list ];

my $file = "$ENV{HOME}/GOG Games/War for the Overworld/game/WFTOGame_Data/GameData/stat.txt";

open my $in, '<', $file or die "Failed to open $file: $!";
binmode $in, ":utf8";

my ($tmp, $tmpname) = tempfile();
binmode $tmp, ":utf8";

while (my $line = <$in>) {
    for my $ach (@resets) {
        $line =~ s/\Q$ach\E=true/$ach=/;
    }
    print $tmp $line or die "Failed write to $tmpname: $!";
}
close $in;
close $tmp;
#print scalar qx{grep '=\$' $tmpname}; exit;
rename($tmpname, $file);
exec qq("$ENV{HOME}/GOG Games/War for the Overworld/start.sh");
