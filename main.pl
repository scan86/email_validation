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

my $threads_num = 2;
my $p      = new Emailprovider("./testset");
my $ref    = $p->provide();
my %splits = Utils::getSplits( $ref, $threads_num );

my %result : shared;

sub worker {
    my ( $id, $elements_ref, $start_element, $stop_element, $result_ref ) = @_;
    my $log = get_logger();

    #$log->info( "Thread id $id strated with start element $start_element "
    #      . "and stop element $stop_element" );

    foreach ( my $i = $start_element ; $i < $stop_element + 1 ; $i++ ) {
        my $email = ${$elements_ref}[$i];
        print $id, " ", $email, "\n";
		
		my $status = check_email($email);
		my $result = last_check()->{'reason'};
		my $str = $status . "\t" . $result;
		$result_ref->{$email} = $str;
    }
}

# start
my @threads;
foreach my $t_id ( keys %splits ) {
    my $start = $splits{$t_id}{'start'};
    my $stop  = $splits{$t_id}{'stop'};
    push @threads, threads->create( \&worker, $t_id, $ref, $start, $stop, \%result );
}

foreach my $t (@threads) { $t->join(); }

foreach my $key ( keys %result) {
 print $key, " ", $result{$key}, " ", "\n";
}
