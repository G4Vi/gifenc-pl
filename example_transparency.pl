#!/usr/bin/perl
# Copyright (c) 2022 Gavin Hayes, see LICENSE in the root of the project
use strict;
use warnings;
use feature 'say';
use FindBin;
use lib "$FindBin::Bin";
use GIF::Encoder::PP;
use Devel::Peek;


#define MIN(a,b) 

sub MIN {
    my ($a, $b) = @_;
    return ((($a)<($b))?($a):($b));
}


sub add_frame {
    my ($gif, $delay) = @_;
    my $height = 100;
	my $width  = 100;

	for(my $i = 0; $i < $height; $i++) {
		for(my $j = 0; $j < $width; $j++) {
            my $char = vec($gif->{'frame'}, ($i*$width) + $j, 8) ? 'Z' : ' ';
			print $char;
		}
		print "\n";
	}

	print "\n";
	$gif->add_frame($delay);
}

scalar(@ARGV) == 1 or die("usage: $0 <file.gif> <disposal>");

my $gif = GIF::Encoder::PP->new($ARGV[0], 100, 100, pack('CCCCCC', 0xFF, 0xFF, 0xFF, 0xDA, 0x09, 0xFF), 1, 0, 0);
my $frameindex = 0;
for (my $t = 0; $t < 100; $t++)
{
	# clear the frame
    $gif->{'frame'} = pack('x10000');

	# add the giant rectange to the frame on the left
	for (my $i = 0; $i < 100; $i++) {
        for (my $j = 0; $j < 100; $j++) {
            vec($gif->{'frame'}, ($i*100)+$j, 8) = $i > 10 && $i < 90 && $j > 10 && $j < 50;
        }
    }
		
	# add the varying size right bar
	for (my $i = 50; $i > 0; $i--) {
        for (my $j = 60; $j < 65; $j++) {
            vec($gif->{'frame'}, ($i*100)+$j, 8) = $i > MIN($t, 100 - $t);
        }
    }
		
    print sprintf("frame %03d: \n", $frameindex++);
	add_frame($gif, 5);		
}
$gif->finish();
