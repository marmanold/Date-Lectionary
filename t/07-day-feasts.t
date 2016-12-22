#!perl -T
use v5.22;
use strict;
use warnings;
use Test::More tests => 36;
use Test::Exception;

use Time::Piece;
use Date::Lectionary;

my $sunday = Date::Lectionary->new(
    'date' => Time::Piece->strptime( "2017-02-02", "%Y-%m-%d" ) );
is(
    $sunday->day->name,
    "The Presentation of Christ in the Temple",
'Validating that 2017-02-02 returns [The Presentation of Christ in the Temple].'
);

$sunday = Date::Lectionary->new(
    'date'       => Time::Piece->strptime( "2017-02-02", "%Y-%m-%d" ),
    'lectionary' => 'rcl'
);
is(
    $sunday->day->name,
    "Presentation of the Lord",
    'Validating that 2017-02-02 returns [Presentation of the Lord].'
);

$sunday = Date::Lectionary->new(
    'date'       => Time::Piece->strptime( "2017-02-24", "%Y-%m-%d" ),
    'lectionary' => 'acna'
);
is( $sunday->day->name,
    "St. Matthias", 'Validating that 2017-02-24 returns [St. Matthias].' );

$sunday = Date::Lectionary->new(
    'date'       => Time::Piece->strptime( "2017-02-24", "%Y-%m-%d" ),
    'lectionary' => 'rcl'
);
is(
    $sunday->day->name,
    "Friday, February 24, 2017",
    'Validating that 2017-02-24 returns nothing.'
);

$sunday = Date::Lectionary->new(
    'date'       => Time::Piece->strptime( "2017-03-25", "%Y-%m-%d" ),
    'lectionary' => 'acna'
);
is(
    $sunday->day->name,
    "The Annunciation",
    'Validating that 2017-03-25 returns [The Annunciation].'
);

$sunday = Date::Lectionary->new(
    'date'       => Time::Piece->strptime( "2017-03-25", "%Y-%m-%d" ),
    'lectionary' => 'rcl'
);
is(
    $sunday->day->name,
    "The Annunciation",
    'Validating that 2017-03-25 returns [The Annunciation].'
);

$sunday = Date::Lectionary->new(
    'date'       => Time::Piece->strptime( "2017-04-25", "%Y-%m-%d" ),
    'lectionary' => 'acna'
);
is( $sunday->day->name,
    "St. Mark", 'Validating that 2017-02-24 returns [St. Mark].' );

$sunday = Date::Lectionary->new(
    'date'       => Time::Piece->strptime( "2017-04-25", "%Y-%m-%d" ),
    'lectionary' => 'rcl'
);
is(
    $sunday->day->name,
    "Tuesday, April 25, 2017",
    'Validating that 2017-04-25 returns nothing for the RCL.'
);

$sunday = Date::Lectionary->new(
    'date'       => Time::Piece->strptime( "2017-06-24", "%Y-%m-%d" ),
    'lectionary' => 'acna'
);
is(
    $sunday->day->name,
    "Nativity of St. John the Baptist",
    'Validating that 2017-06-24 returns [Nativity of St. John the Baptist].'
);

$sunday = Date::Lectionary->new(
    'date'       => Time::Piece->strptime( "2017-06-24", "%Y-%m-%d" ),
    'lectionary' => 'rcl'
);
is(
    $sunday->day->name,
    "Saturday, June 24, 2017",
    'Validating that 2017-06-24 returns nothing for the RCL.'
);

$sunday = Date::Lectionary->new(
    'date'       => Time::Piece->strptime( "2017-06-29", "%Y-%m-%d" ),
    'lectionary' => 'acna'
);
is(
    $sunday->day->name,
    "St. Peter & St. Paul",
    'Validating that 2017-06-29 returns [St. Peter & St. Paul].'
);

$sunday = Date::Lectionary->new(
    'date'       => Time::Piece->strptime( "2017-06-29", "%Y-%m-%d" ),
    'lectionary' => 'rcl'
);
is(
    $sunday->day->name,
    "Thursday, June 29, 2017",
    'Validating that 2017-06-29 returns nothing for the RCL.'
);

$sunday = Date::Lectionary->new(
    'date'       => Time::Piece->strptime( "2017-07-22", "%Y-%m-%d" ),
    'lectionary' => 'acna'
);
is(
    $sunday->day->name,
    "St. Mary of Magdala",
    'Validating that 2017-07-22 returns [St. Mary of Magdala].'
);

$sunday = Date::Lectionary->new(
    'date'       => Time::Piece->strptime( "2017-07-22", "%Y-%m-%d" ),
    'lectionary' => 'rcl'
);
is(
    $sunday->day->name,
    "Saturday, July 22, 2017",
    'Validating that 2017-07-22 returns nothing for the RCL.'
);

$sunday = Date::Lectionary->new(
    'date'       => Time::Piece->strptime( "2017-07-25", "%Y-%m-%d" ),
    'lectionary' => 'acna'
);
is( $sunday->day->name,
    "St. James", 'Validating that 2017-07-25 returns [St. James].' );

$sunday = Date::Lectionary->new(
    'date'       => Time::Piece->strptime( "2017-07-25", "%Y-%m-%d" ),
    'lectionary' => 'rcl'
);
is(
    $sunday->day->name,
    "Tuesday, July 25, 2017",
    'Validating that 2017-07-25 returns nothing for the RCL.'
);

$sunday = Date::Lectionary->new(
    'date'       => Time::Piece->strptime( "2017-08-15", "%Y-%m-%d" ),
    'lectionary' => 'acna'
);
is(
    $sunday->day->name,
    "St. Mary the Virgin",
    'Validating that 2017-08-15 returns [St. Mary the Virgin].'
);

$sunday = Date::Lectionary->new(
    'date'       => Time::Piece->strptime( "2017-08-15", "%Y-%m-%d" ),
    'lectionary' => 'rcl'
);
is(
    $sunday->day->name,
    "Tuesday, August 15, 2017",
    'Validating that 2017-08-15 returns nothing for the RCL.'
);

$sunday = Date::Lectionary->new(
    'date'       => Time::Piece->strptime( "2017-08-24", "%Y-%m-%d" ),
    'lectionary' => 'acna'
);
is(
    $sunday->day->name,
    "St. Bartholomew",
    'Validating that 2017-08-24 returns [St. Bartholomew].'
);

$sunday = Date::Lectionary->new(
    'date'       => Time::Piece->strptime( "2017-08-24", "%Y-%m-%d" ),
    'lectionary' => 'rcl'
);
is(
    $sunday->day->name,
    "Thursday, August 24, 2017",
    'Validating that 2017-08-24 returns nothing for the RCL.'
);

$sunday = Date::Lectionary->new(
    'date'       => Time::Piece->strptime( "2017-09-14", "%Y-%m-%d" ),
    'lectionary' => 'acna'
);
is(
    $sunday->day->name,
    "Holy Cross Day",
    'Validating that 2017-09-14 returns [Holy Cross Day].'
);

$sunday = Date::Lectionary->new(
    'date'       => Time::Piece->strptime( "2017-09-14", "%Y-%m-%d" ),
    'lectionary' => 'rcl'
);
is(
    $sunday->day->name,
    "Holy Cross Day",
    'Validating that 2017-09-14 returns [Holy Cross Day].'
);

$sunday = Date::Lectionary->new(
    'date'       => Time::Piece->strptime( "2017-09-21", "%Y-%m-%d" ),
    'lectionary' => 'acna'
);
is( $sunday->day->name, "St. Matthew",
    'Validating that 2017-09-21 returns [St. Matthew].' );

$sunday = Date::Lectionary->new(
    'date'       => Time::Piece->strptime( "2017-09-21", "%Y-%m-%d" ),
    'lectionary' => 'rcl'
);
is(
    $sunday->day->name,
    "Thursday, September 21, 2017",
    'Validating that 2017-09-21 returns nothing for the RCL.'
);

$sunday = Date::Lectionary->new(
    'date'       => Time::Piece->strptime( "2017-09-29", "%Y-%m-%d" ),
    'lectionary' => 'acna'
);
is(
    $sunday->day->name,
    "Holy Michael & All Angels",
    'Validating that 2017-09-29 returns [Holy Michael & All Angels].'
);

$sunday = Date::Lectionary->new(
    'date'       => Time::Piece->strptime( "2017-09-29", "%Y-%m-%d" ),
    'lectionary' => 'rcl'
);
is(
    $sunday->day->name,
    "Friday, September 29, 2017",
    'Validating that 2017-09-29 returns nothing for the RCL.'
);

$sunday = Date::Lectionary->new(
    'date'       => Time::Piece->strptime( "2017-11-30", "%Y-%m-%d" ),
    'lectionary' => 'acna'
);
is( $sunday->day->name, "St. Andrew",
    'Validating that 2017-11-30 returns [St. Andrew].' );

$sunday = Date::Lectionary->new(
    'date'       => Time::Piece->strptime( "2017-11-30", "%Y-%m-%d" ),
    'lectionary' => 'rcl'
);
is(
    $sunday->day->name,
    "Thursday, November 30, 2017",
    'Validating that 2017-11-30 returns nothing for the RCL.'
);

$sunday = Date::Lectionary->new(
    'date'       => Time::Piece->strptime( "2017-12-21", "%Y-%m-%d" ),
    'lectionary' => 'acna'
);
is( $sunday->day->name, "St. Thomas",
    'Validating that 2017-12-21 returns [St. Thomas].' );

$sunday = Date::Lectionary->new(
    'date'       => Time::Piece->strptime( "2017-12-21", "%Y-%m-%d" ),
    'lectionary' => 'rcl'
);
is(
    $sunday->day->name,
    "Thursday, December 21, 2017",
    'Validating that 2017-12-21 returns nothing for the RCL.'
);

$sunday = Date::Lectionary->new(
    'date'       => Time::Piece->strptime( "2017-12-26", "%Y-%m-%d" ),
    'lectionary' => 'acna'
);
is( $sunday->day->name, "St. Stephen",
    'Validating that 2017-12-26 returns [St. Stephen].' );

$sunday = Date::Lectionary->new(
    'date'       => Time::Piece->strptime( "2017-12-26", "%Y-%m-%d" ),
    'lectionary' => 'rcl'
);
is(
    $sunday->day->name,
    "Tuesday, December 26, 2017",
    'Validating that 2017-12-26 returns nothing for the RCL.'
);

$sunday = Date::Lectionary->new(
    'date'       => Time::Piece->strptime( "2017-12-28", "%Y-%m-%d" ),
    'lectionary' => 'acna'
);
is(
    $sunday->day->name,
    "Holy Innocents",
    'Validating that 2017-12-28 returns [Holy Innocents].'
);

$sunday = Date::Lectionary->new(
    'date'       => Time::Piece->strptime( "2017-12-28", "%Y-%m-%d" ),
    'lectionary' => 'rcl'
);
is(
    $sunday->day->name,
    "Thursday, December 28, 2017",
    'Validating that 2017-12-28 returns nothing for the RCL.'
);

$sunday = Date::Lectionary->new(
    'date'       => Time::Piece->strptime( "2018-01-06", "%Y-%m-%d" ),
    'lectionary' => 'acna'
);
is(
    $sunday->day->name,
    "The Epiphany",
    'Validating that 2018-01-06 returns [The Epiphany] for the ACNA lectionary.'
);

$sunday = Date::Lectionary->new(
    'date'       => Time::Piece->strptime( "2018-01-06", "%Y-%m-%d" ),
    'lectionary' => 'rcl'
);
is(
    $sunday->day->name,
    "Epiphany of the Lord",
'Validating that 2018-01-06 returns nothing [Epiphany of the Lord] for the RCL.'
);

#Good Friday

#Maundy Thursday

#Wednesday in Holy Week

#Tuesday in Holy Week

#Monday in Holy Week
