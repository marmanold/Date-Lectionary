#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Date::Lectionary' ) || print "Bail out!\n";
}

diag( "Testing Date::Lectionary $Date::Lectionary::VERSION, Perl $], $^X" );
