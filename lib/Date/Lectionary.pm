package Date::Lectionary;

use v5.22;
use strict;
use warnings;

use Moose;
use Carp;
use Try::Tiny;
use Time::Piece;
use Date::Advent;
use Date::Lectionary::Reading;
use Date::Lectionary::Year;
use Date::Lectionary::Day;
use namespace::autoclean;
use Moose::Util::TypeConstraints;

=head1 NAME

Date::Lectionary

=head1 VERSION

Version 1.20161027

=cut

our $VERSION = '1.20161027';

=head1 SYNOPSIS

Date::Lectionary takes a Time::Piece date and returns the liturgical day and associated readings for either the date or, if the date isn't a Sunday or Holiday, the next Sunday's readings.

	use Time::Piece;
	use Date::Lectionary;

	my $christmas = Date::Lectionary->new('date'=>Time::Piece->strptime("2016-12-25", "%Y-%m-%d"));
	say $christmas->day; #String representation of the name of the day in the liturgical calednar; e.g. Christmas Day

=cut

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

has 'readings' => (
    is       => 'ro',
    isa      => 'ArrayRef[Date::Lectionary::Reading]',
    writer   => '_setReadings',
    init_arg => undef,
);

=head2 BUILD

Constructor for the Date::Lectionary object.  Takes a Time::Piect object, date, to create the object.

=cut

sub BUILD {
    my $self = shift;

    my $advent = _determineAdvent( $self->date );

    $self->_setYear(
        Date::Lectionary::Year->new( 'year' => $advent->firstSunday->year ) );

    $self->_setDay( Date::Lectionary::Day->new( 'date' => $self->date ) );

    $self->_setReadings( _buildReadings() );
}

=head2 _buildReadings

Private method that returns an ArrayRef of Date::Lectionary::Reading objects for the lectionary readings associated with the date.

=cut

sub _buildReadings {
    my @readings;

    push(
        @readings,
        Date::Lectionary::Reading->new(
            book  => 'Gen',
            begin => '1:1',
            end   => '1:5'
        )
    );

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
        confess "Could not calculate Advent for the given date ["
          . $date->ymd . "].";
    }
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


=head1 LICENSE AND COPYRIGHT

Copyright 2016 Michael Wayne Arnold.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.


=cut

__PACKAGE__->meta->make_immutable;

1;    # End of Date::Lectionary
