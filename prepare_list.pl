#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  prepare_list.pl
#
#        USAGE:  cat file | ./prepare_list.pl
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
#      CREATED:  06/18/2014 05:29:11 PM
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;
use diagnostics;

while(<>) {

 #пустые строки
 next if m/^\s*$/;

 #строки где нет символа @
 next if not m/\@/;
 
 # пробелы и переносы
 s/^\s*(.+)$/$1/g;
 s/^(.+)\s*/$1/g;

 # заменяем возможныйе разредители
 s/\s*\;\s*/\,/g;
 s/\s*\,\s*/\,/g;
 
 print $_, "\n";
}

