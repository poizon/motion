#!/usr/bin/perl -w

use strict;
use warnings;
use feature qw(say);

use Data::Dumper;
use lib qw(.);

use Motion;

my $motion = Motion->new(key => 'SUBSRIBE_API_KEY_HERE');

my $dir = "./capture";# dir with pictures
# read manuall here
opendir DIR, $dir || die "$!";
my @files = grep {/\.jpg$/} readdir DIR;
closedir DIR;

for my $file(@files)
{
    # just dump
    say Dumper $motion->get_request($dir . '/' . $file);
}