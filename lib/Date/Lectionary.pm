package Date::Lectionary;

use v5.22;
use strict;
use warnings;

use Try::Tiny::Tiny;

use Moose;
use MooseX::StrictConstructor;
use Carp;
use Try::Catch;
use XML::LibXML;
use File::Share ':all';
use Time::Piece;
use Date::Advent;
use Date::Lectionary::Year;
use Date::Lectionary::Day;
use namespace::autoclean;
use Moose::Util::TypeConstraints;

=head1 NAME

Date::Lectionary - Readings for the Christian Lectionary

=head1 VERSION

Version 1.20180313

=cut

our $VERSION = '1.20180313';

=head1 SYNOPSIS

    use Time::Piece;
    use Date::Lectionary;

    my $epiphany = Date::Lectionary->new('date'=>Time::Piece->strptime("2017-01-06", "%Y-%m-%d"));
    say $epiphany->day->name; #String representation of the name of the day in the liturgical calendar; e.g. 'The Epiphany'
    say $epiphany->year->name; #String representation of the name of the liturgical year; e.g. 'A'
    say ${$epiphany->readings}[0] #String representation of the first reading for the day.

=head1 DESCRIPTION

Date::Lectionary takes a Time::Piece date and returns the liturgical day and associated readings for the day.

=head2 ATTRIBUTES

=head3 date

The Time::Piece object date given at object construction.

=head3 lectionary

An optional attribute given at object creation time.  Valid values are 'acna' for the Anglican Church of North America lectionary and 'rcl' for the Revised Common Lectionary with complementary readings in ordinary time.  This attribute defaults to 'acna' if no value is given.

=head3 day

A Date::Lectionary::Day object containing attributes related to the liturgical day.

C<type>: Stores the type of liturgical day. 'fixedFeast' is returned for non-moveable feast days such as Christmas Day. 'moveableFeast' is returned for moveable feast days.  Moveable feasts move to a Monday when they occure on a Sunday. 'Sunday' is returned for non-fixed feast Sundays of the liturgical year.  'noLect' is returned for days with no feast day or Sunday readings.

C<name>: The name of the day in the lectionary.  For noLect days a String representation of the day is returned as the name.

C<alt>: The alternative name --- if one is given --- of the day in the lectionary.  If there is no alternative name for the day, then the empty string will be returned.

C<multiLect>: Returns 'yes' if the day has multiple services with readings associated with it.  (E.g. Christmas Day, Easter, etc.)  Returns 'no' if the day is a normal lectioanry day with only one service and one set of readings.

=head3 year

A Date::Lectionary::Year object containing attributes related to the liturgical year the date given at object construction resides in.

C<name>: Returns 'A', 'B', or 'C' depending on the liturgical year the date given at object construction resides in.

=head3 readings

Return an ArrayRef of the String representation of the day's readings if there are any.  Readings in the ArrayRef are ordered in the array according to the order the readings are given in the lectionary.  If mutliple readings exist for the day, an ArrayRef of HashRefs will be given.

  my $singleReading = Date::Lectionary->new(
      'date'       => Time::Piece->strptime( "2016-11-13", "%Y-%m-%d" ),
      'lectionary' => 'acna'
  );

  say ${ $testReading->readings }[1]; #Will print 'Ps 98', the second reading for the Sunday closest to November 16 in the default ACNA lectionary for year C.
  say $testReading->day->multiLect; #Will print 'no' because this day does not have multiple services in the lectionary.

  my $multiReading = Date::Lectionary->new(
      'date'       => Time::Piece->strptime( "2016-12-25", "%Y-%m-%d" ),
      'lectionary' => 'rcl'
  );

  say $multiReading->day->multiLect; #Will print 'yes' because this day does have multiple services in the lectionary.
  say ${ $multiReading->readings }[0]{name}; #Will print 'Christmas, Proper I', the first services of Christmas Day in the RCL
  say ${ $multiReading->readings }[1]{readings}[0]; #Will print 'Isaiah 62:6-12', the first reading of the second service 'Christmas, Proper II' on Christmas Day in the RCL.

=cut

enum 'LectionaryType', [qw(acna rcl)];
no Moose::Util::TypeConstraints;

=head1 SUBROUTINES/METHODS

=cut

has 'date' => (
    is       => 'ro',
    isa      => 'Time::Piece',
    required => 1,
);

has 'day' => (
    is       => 'ro',
    isa      => 'Date::Lectionary::Day',
    writer   => '_setDay',
    init_arg => undef,
);

has 'year' => (
    is       => 'ro',
    isa      => 'Date::Lectionary::Year',
    writer   => '_setYear',
    init_arg => undef,
);

has 'lectionary' => (
    is      => 'ro',
    isa     => 'LectionaryType',
    default => 'acna',
);

has 'readings' => (
    is       => 'ro',
    isa      => 'ArrayRef',
    writer   => '_setReadings',
    init_arg => undef,
);

=head2 BUILD

Constructor for the Date::Lectionary object.  Takes a Time::Piect object, C<date>, to create the object.

=cut

sub BUILD {
    my $self = shift;

    my $advent = _determineAdvent( $self->date );

    $self->_setYear( Date::Lectionary::Year->new( 'year' => $advent->firstSunday->year ) );

    $self->_setDay(
        Date::Lectionary::Day->new(
            'date'       => $self->date,
            'lectionary' => $self->lectionary
        )
    );

    if ( $self->day->multiLect eq 'yes' ) {
        $self->_setReadings( _buildMultiReadings( $self->day->subLects, $self->lectionary, $self->year->name ) );
    }
    else {
        $self->_setReadings( _buildReadings( $self->day->name, $self->lectionary, $self->year->name ) );
    }
}

=head2 _buildMultiReadings

Private method that returns an ArrayRef of HashRefs for the multiple services and lectionary readings associated with the date.

=cut

sub _buildMultiReadings {
    my $multiNames = shift;
    my $lectionary = shift;
    my $year       = shift;

    my @multiReadings;
    foreach my $name (@$multiNames) {

        my %lectPart = (
            name     => $name,
            readings => _buildReadings( $name, $lectionary, $year )
        );

        push( @multiReadings, \%lectPart );
    }

    return \@multiReadings;
}

=head2 _buildReadings

Private method that returns an ArrayRef of strings for the lectionary readings associated with the date.

=cut

sub _buildReadings {
    my $displayName = shift;
    my $lectionary  = shift;
    my $year        = shift;

    my $parser = XML::LibXML->new();
    my $data_location;
    my $readings;

    try {
        $data_location = dist_file( 'Date-Lectionary', $lectionary . '_lect.xml' );
        $readings = $parser->parse_file($data_location);
    }
    catch {
        carp "The readings database for the $lectionary lectionary could not be found or parsed.";
    };

    my $compiled_xpath = XML::LibXML::XPathExpression->new("/lectionary/year[\@name=\"$year\" or \@name=\"holidays\"]/day[\@name=\"$displayName\"]/lesson");

    my @readings;
    try {
        foreach my $lesson ( $readings->findnodes($compiled_xpath) ) {
            push( @readings, $lesson->to_literal );
        }
    }
    catch {
        carp "Readings for $displayName in year $year could not be parsed from the database.";
    };

    return \@readings;
}

=head2 _determineAdvent

Private method that takes a Time::Piece date object to returns a Date::Advent object containing the dates for Advent of the current liturgical year.

=cut

sub _determineAdvent {
    my $date = shift;

    my $advent = undef;

    try {
        $advent = Date::Advent->new( date => $date );
        return $advent;
    }
    catch {
        confess "Could not calculate Advent for the given date [" . $date->ymd . "].";
    };
}

=head1 AUTHOR

Michael Wayne Arnold, C<< <marmanold at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-date-lectionary at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Date-Lectionary>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Date::Lectionary


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Date-Lectionary>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Date-Lectionary>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Date-Lectionary>

=item * Search CPAN

L<http://search.cpan.org/dist/Date-Lectionary/>

=back


=head1 ACKNOWLEDGEMENTS

Many thanks to my beautiful wife, Jennifer, and my amazing daughter, Rosemary.  But, above all, SOLI DEO GLORIA!

=head1 LICENSE AND COPYRIGHT

Copyright 2016-2017 MICHAEL WAYNE ARNOLD

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

__PACKAGE__->meta->make_immutable;

1;    # End of Date::Lectionary
