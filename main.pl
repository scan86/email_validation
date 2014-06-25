#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  main.pl
#
#        USAGE:  ./main.pl
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
#      CREATED:  06/19/2014 01:39:40 PM
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;
use diagnostics;

use threads;
use threads::shared;
use Log::Log4perl qw(get_logger);
use Data::Dumper;

use Emailprovider;
use Utils;

use Mail::CheckUser qw(check_email last_check);
$Mail::CheckUser::Skip_SYN              = 0;
$Mail::CheckUser::Timeout               = 10;
$Mail::CheckUser::Treat_Timeout_As_Fail = 1;
$Mail::CheckUser::Treat_Full_As_Fail    = 1;
$Mail::CheckUser::Debug                 = 0;
$Mail::CheckUser::Sender_Addr           = 'user@creditnet.ru';
$Mail::CheckUser::Helo_Domain           = 'mail.creditreform-iis.ru';

Log::Log4perl::init("log4perl.conf");

$| = 1;

my $threads_num = 10;
my $p           = new Emailprovider("./list1.raw.prepared");
my $ref         = $p->provide();
my %splits      = Utils::getSplits( $ref, $threads_num );

my %result : shared;

sub worker {
    my ( $id, $elements_ref, $start_element, $stop_element, $result_ref ) = @_;
    my $log = get_logger();

    $log->info( "Thread id $id strated with start element $start_element "
          . "and stop element $stop_element" );

    foreach ( my $i = $start_element ; $i < $stop_element + 1 ; $i++ ) {
        my $email = ${$elements_ref}[$i];

        $result_ref->{$email} = shared_clone(
            {
                'status' => check_email($email),
                'reason' => last_check()->{'reason'}
            }
        );
    }
    $log->info("Thread id $id done");
}

sub monitor {
    my ( $result_ref, $total_num, $interval ) = @_;
    my $log = get_logger();

    my $procecced_num = 0;

    while ( $procecced_num < $total_num ) {
        $log->info("Procecced $procecced_num \/ $total_num");
        sleep $interval;
        $procecced_num = scalar( keys %{$result_ref} );
    }
	$log->info("Monitor thread exited")

}

sub writeResult {
    my ( $result_ref, $good, $bad ) = @_;

    open( my $good_fd, '>', $good );
    open( my $bad_fd,  '>', $bad );

    foreach my $key ( keys %{$result_ref} ) {
        if ( ${$result_ref}{$key}{'status'} ) {
            print $good_fd $key, "\n";
            next;
        }
        my $reason = ${$result_ref}{$key}{'reason'};
        print $bad_fd $key, "\t", $reason, "\n";
    }

    close($bad_fd);
    close($good_fd);

}

# start
my @threads;
foreach my $t_id ( keys %splits ) {
    my $start = $splits{$t_id}{'start'};
    my $stop  = $splits{$t_id}{'stop'};
    push @threads,
      threads->create( \&worker, $t_id, $ref, $start, $stop, \%result );
}
push @threads, threads->create( \&monitor, \%result, scalar( @{$ref} ), 5 );
foreach my $t (@threads) { $t->join(); }

if ( !scalar( keys %result ) > 1 ) {
    exit 1;
}
writeResult( \%result, "./good", "./bad" );

