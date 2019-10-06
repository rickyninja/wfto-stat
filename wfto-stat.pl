#!/usr/bin/env perl

use strict;
use warnings;
use File::Temp qw(tempfile);

my $file = "$ENV{HOME}/GOG Games/War for the Overworld/game/WFTOGame_Data/GameData/stat.txt";

open my $in, '<', $file or die "Failed to open $file: $!";

my ($tmp, $tmpname) = tempfile();

while (my $line = <$in>) {
    $line =~ s/Rhoadblock=true/Rhoadblock=/;
    print $tmp $line or die "Failed write to $tmpname: $!";
}
close $in;
close $tmp;
#rename($file, $file."-".localtime());
rename($tmpname, $file);
exec q{"/home/jeremys/GOG Games/War for the Overworld/start.sh"};
