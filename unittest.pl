#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  unittest.pl
#
#        USAGE:  ./unittest.pl
#
#  DESCRIPTION:
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Dmitriy Anikin (scan), danikin@creditnet.ru
#      COMPANY:  NKB
#      VERSION:  1.0
#      CREATED:  06/24/2014 03:44:30 PM
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;
use diagnostics;

use Test::More;
use Data::Dumper;
use Utils;

my @array;

for ( my $i = 0 ; $i < 1000 ; $i++ ) {
    push @array, $i;
}

ok( scalar(@array) == 1000 );

my %parts = Utils::getSplits( \@array, 2 );

ok( ( $parts{0}{'start'} == 0 ) &   ( $parts{0}{'stop'} == 499 ) );
ok( ( $parts{1}{'start'} == 500 ) & ( $parts{1}{'stop'} == 999 ) );

%parts = Utils::getSplits( \@array, 3 );

ok( ( $parts{0}{'start'} == 0 ) &   ( $parts{0}{'stop'} == 332 ) );
ok( ( $parts{1}{'start'} == 333 ) & ( $parts{1}{'stop'} == 665 ) );
ok( ( $parts{2}{'start'} == 666 ) & ( $parts{2}{'stop'} == 999 ) );

done_testing();

