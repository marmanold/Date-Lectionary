#!perl -T
use v5.22;
use strict;
use warnings;
use Test::More tests => 6;
use Test::Exception;

use Time::Piece;
use Date::Lectionary;

my $sunday = Date::Lectionary->new(
    'date' => Time::Piece->strptime( "2017-02-02", "%Y-%m-%d" ) );
is(
    $sunday->day->alt,
    "The Presentation of Christ in the Temple",
'Validating that 2017-02-02 returns [The Presentation of Christ in the Temple].'
);

$sunday = Date::Lectionary->new(
    'date'       => Time::Piece->strptime( "2017-02-02", "%Y-%m-%d" ),
    'lectionary' => 'rcl'
);
is(
    $sunday->day->alt,
    "Presentation of the Lord",
    'Validating that 2017-02-02 returns [Presentation of the Lord].'
);

$sunday = Date::Lectionary->new(
    'date'       => Time::Piece->strptime( "2017-02-24", "%Y-%m-%d" ),
    'lectionary' => 'acna'
);
is( $sunday->day->alt,
    "St. Matthias", 'Validating that 2017-02-24 returns [St. Matthias].' );

$sunday = Date::Lectionary->new(
    'date'       => Time::Piece->strptime( "2017-02-24", "%Y-%m-%d" ),
    'lectionary' => 'rcl'
);
is(
    $sunday->day->alt,
    "Friday, February 24, 2017",
    'Validating that 2017-02-24 returns nothing.'
);

$sunday = Date::Lectionary->new(
    'date' => Time::Piece->strptime( "2015-01-11", "%Y-%m-%d" ) );
is(
    $sunday->day->alt,
    "Baptism of our Lord",
'Validating that 2015-01-11 returns [Baptism of our Lord] for the ACNA lectionary.'
);

$sunday = Date::Lectionary->new(
    'date'       => Time::Piece->strptime( "2015-01-11", "%Y-%m-%d" ),
    'lectionary' => 'rcl'
);
is(
    $sunday->day->alt,
    "Ordinary/Lectionary 1",
'Validating that 2015-01-11 returns [Ordinary/Lectionary 1] for the RCL lectionary.'
);
