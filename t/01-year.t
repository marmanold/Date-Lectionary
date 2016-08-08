#!perl -T
use v5.22;
use strict;
use warnings;
use Test::More tests=>6;
use Test::Exception;

use Time::Piece;
use Date::Lectionary;

my $lectYearA = Date::Lectionary->new('date'=>Time::Piece->strptime("2014-01-01", "%Y-%m-%d"));
is(
	$lectYearA->year, 
	'A', 
	'Test the liturgical cycle year for January 1, 2014.  It should be year A.'
);

my $lectYearB = Date::Lectionary->new('date'=>Time::Piece->strptime("2015-01-01", "%Y-%m-%d"));
is(
	$lectYearB->year, 
	'B', 
	'Test the liturgical cycle year for January 1, 2015.  It should be year B.'
);

my $lectYearC = Date::Lectionary->new('date'=>Time::Piece->strptime("2016-01-01", "%Y-%m-%d"));
is(
	$lectYearC->year, 
	'C', 
	'Test the liturgical cycle year for January 1, 2016.  It should be year C.'
);

my $lectYearA2 = Date::Lectionary->new('date'=>Time::Piece->strptime("2013-12-31", "%Y-%m-%d"));
is(
	$lectYearA2->year, 
	'A', 
	'Test the liturgical cycle year for December 31, 2013.  It should be year A.'
);

my $lectYearA3 = Date::Lectionary->new('date'=>Time::Piece->strptime("2016-12-31", "%Y-%m-%d"));
is(
	$lectYearA3->year, 
	'A', 
	'Test the liturgical cycle year for December 31, 2016.  It should be year A.'
);

my $lectYearC2 = Date::Lectionary->new('date'=>Time::Piece->strptime("2013-11-01", "%Y-%m-%d"));
is(
	$lectYearC2->year, 
	'C', 
	'Test the liturgical cycle year for November 1, 2013.  It should be year C.'
);