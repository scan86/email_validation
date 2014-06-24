#
#===============================================================================
#
#         FILE:  Utils.pm
#
#  DESCRIPTION:
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Dmitriy Anikin (scan), danikin@creditnet.ru
#      COMPANY:  NKB
#      VERSION:  1.0
#      CREATED:  06/20/2014 01:19:28 PM
#     REVISION:  ---
#===============================================================================

package Utils;

use strict;
use warnings;

use Log::Log4perl qw(get_logger);

sub getSplits {
    my ( $arr_ref, $num ) = @_;
    my $log = get_logger();

    my %result;

    my $cnt = scalar( @{$arr_ref} );

    my $last = 0;
    for ( my $part = 0 ; $part < $num ; $part++ ) {
        my $part_size = int( $cnt / $num );
        
		my $start = $last;
        my $stop;

        if ( ( $cnt - ( $last + $part_size ) ) >= $part_size ) {
            $stop = $start + $part_size - 1;
        }
        else {
            $stop = $cnt - 1;
        }

        $result{$part} = { 'start' => $start, 'stop' => $stop };

        $last = $stop + 1;

    }

    return %result;
}

1;
