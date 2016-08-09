#!perl -T
use v5.22;
use strict;
use warnings;
use Test::More tests=>10;
use Test::Exception;

use Time::Piece;
use Date::Lectionary;

my $christmas = Date::Lectionary->new('date'=>Time::Piece->strptime("2016-12-25", "%Y-%m-%d"));
is(
	$christmas->day,
	'Christmas Day',
	'Ensure that December 25, 2016 is Christmas Day'
);

my $ashWednesday = Date::Lectionary->new('date'=>Time::Piece->strptime("2016-02-10", "%Y-%m-%d"));
is(
	$ashWednesday->day,
	'Ash Wednesday',
	'Ensure that February 10, 2016 is Ash Wednesday'
);

my $easter = Date::Lectionary->new('date'=>Time::Piece->strptime("2016-03-27", "%Y-%m-%d"));
is(
	$easter->day,
	'Easter Day',
	'Ensure that March 27, 2016 is Easter Day'
);

my $holySat = Date::Lectionary->new('date'=>Time::Piece->strptime("2016-03-26", "%Y-%m-%d"));
is(
	$holySat->day,
	'Holy Saturday',
	'Ensure that March 26, 2016 is Holy Saturday'
);

my $easterTuesday = Date::Lectionary->new('date'=>Time::Piece->strptime("2016-03-29", "%Y-%m-%d"));
is(
	$easterTuesday->day,
	'Tuesday of Easter Week',
	'Ensure that March 29, 2016 is Tuesday of Easter Week'
);

my $ascension = Date::Lectionary->new('date'=>Time::Piece->strptime("2016-05-05", "%Y-%m-%d"));
is(
	$ascension->day,
	'Ascension Day',
	'Ensure that May 05, 2016 is Ascension Day'
);

my $pentecost = Date::Lectionary->new('date'=>Time::Piece->strptime("2016-05-15", "%Y-%m-%d"));
is(
	$pentecost->day,
	'Pentecost',
	'Ensure that May 15, 2016 is Pentecost'
);

my $st_luke = Date::Lectionary->new('date'=>Time::Piece->strptime("2016-10-18", "%Y-%m-%d"));
is(
	$st_luke->day,
	'St. Luke',
	'Ensure that October 10, 2016 is St. Luke'
);

my $christTheKing = Date::Lectionary->new('date'=>Time::Piece->strptime("2016-11-20", "%Y-%m-%d"));
is(
	$christTheKing->day,
	'Christ the King',
	'Ensure that November 20, 2016 is Christ the King'
);

my $regularDay = Date::Lectionary->new('date'=>Time::Piece->strptime("2016-11-19", "%Y-%m-%d"));
is(
	$regularDay->day,
	'Christ the King [2016-11-20]',
	'Ensure that November 19, 2016 is Christ the King [2016-11-20]'
);
