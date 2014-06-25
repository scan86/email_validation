#
#===============================================================================
#
#         FILE:  Emailprovider.pm
#
#  DESCRIPTION:
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Dmitriy Anikin (scan), danikin@creditnet.ru
#      COMPANY:  NKB
#      VERSION:  1.0
#      CREATED:  06/19/2014 01:30:16 PM
#     REVISION:  ---
#===============================================================================

package Emailprovider;

use strict;
use warnings;
use diagnostics;

use Log::Log4perl qw(get_logger);
use List::MoreUtils qw(uniq);

sub new {
    my $class = shift;

    my $self = { 'file' => shift, };

    bless $self, $class;
    return $self;
}

sub provide {
    my ( $self, $params ) = @_;
    my $log = get_logger();

    my $email_ref = load( $self->{'file'} );
    $log->debug( "Provided " . scalar( @{$email_ref} ) . " emails..." );
    return $email_ref;
}

sub load {
    my $file = shift;

    my @result;

    open( my $fh, '<', $file );

    while ( my $line = <$fh> ) {
        chomp($line);
		$line =~ tr/[A-Z]/[a-z]/;

        if ( $line =~ m/\,/ ) {
            my @email = split( /\,/, $line );
            foreach my $email (@email) {
                push @result, $email;
            }
            next;
        }

        push @result, $line;
    }

    close($fh);
    my @uniq = uniq(@result);
    return \@uniq;
}

1;

