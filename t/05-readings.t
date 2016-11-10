#!perl -T
use v5.22;
use strict;
use warnings;
use Test::More tests => 4;
use Test::Exception;

use Time::Piece;
use Date::Lectionary;

use Data::Dumper;

my $testReading = Date::Lectionary->new(
    'date' => Time::Piece->strptime( "2016-11-13", "%Y-%m-%d" ) );
is(
    ${ $testReading->readings }[0],
    'Mal 3:13-4:6',
'The first reading for the Sunday closest to November 16 in the default ACNA lectionary for year C should be Mal 3:13-4:6.'
);

$testReading = Date::Lectionary->new(
    'date'       => Time::Piece->strptime( "2016-11-13", "%Y-%m-%d" ),
    'lectionary' => 'acna'
);
is(
    ${ $testReading->readings }[1],
    'Ps 98',
'The second reading for the Sunday closest to November 16 in the ACNA lectionary for year C should be Ps 98.'
);

$testReading = Date::Lectionary->new(
    'date'       => Time::Piece->strptime( "2016-11-13", "%Y-%m-%d" ),
    'lectionary' => 'acna'
);
is(
    ${ $testReading->readings }[2],
    '2 Thess 3:6-16',
'The third reading for the Sunday closest to November 16 in the ACNA lectionary for year C should be 2 Thess 3:6-16.'
);

$testReading = Date::Lectionary->new(
    'date'       => Time::Piece->strptime( "2016-11-13", "%Y-%m-%d" ),
    'lectionary' => 'acna'
);
is(
    ${ $testReading->readings }[3],
    'Lk 21:5-19',
'The fourth reading for the Sunday closest to November 16 in the ACNA lectionary for year C should be Lk 21:5-19.'
);
