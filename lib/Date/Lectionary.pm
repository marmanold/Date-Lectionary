package Date::Lectionary;

use v5.22;
use strict;
use warnings;

use Moose;
use Carp;
use Try::Tiny;
use Time::Piece;
use Time::Seconds;
use Date::Advent;
use Date::Easter;
use Date::Lectionary::Time qw(nextSunday prevSunday);
use Date::Lectionary::Reading;
use namespace::autoclean;
use Moose::Util::TypeConstraints;

=head1 NAME

Date::Lectionary - The great new Date::Lectionary!

=head1 VERSION

Version 1.20160807

=cut

our $VERSION = '1.20160807';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Date::Lectionary;

    my $foo = Date::Lectionary->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=cut

enum 'litCycleYear', [qw(A B C)];
no Moose::Util::TypeConstraints;

=head1 SUBROUTINES/METHODS

=cut

has 'date' => (
	is			=> 'ro', 
	isa			=> 'Time::Piece',
	required 	=> 1,
);

has 'day' => (
	is 			=> 'ro', 
	isa 		=> 'Str',
	writer 		=> '_setDay', 
	init_arg 	=> undef,
);

has 'year' => (
	is 			=> 'ro', 
	isa 		=> 'litCycleYear',
	writer 		=> '_setYear', 
	init_arg	=> undef,
);

has 'readings' => (
	is 			=> 'ro', 
	isa 		=> 'ArrayRef[Date::Lectionary::Reading]',
	writer 		=> '_setReadings', 
	init_arg 	=> undef, 
);

sub BUILD {
	my $self = shift;

	my $advent = _buildAdvent($self->date);
	my $easter = _buildEaster($advent->firstSunday->year+1);

	$self->_setYear(_determineYear($advent->firstSunday->year));

	$self->_setDay(_determineDay($self->date, $advent, $easter));

	$self->_setReadings(_buildReadings());
}

sub _buildAdvent {
	my $date = shift;

	my $advent = undef;

	try{
		$advent = Date::Advent->new(date => $date);
		return $advent;
	}
	catch{
		confess "Could not calculate Advent for the given date [". $date->ymd ."].";
	}
}

sub _buildEaster {
	my $easterYear = shift;

	my $easter = undef;

	try{
		my ($easterMonth, $easterDay) = easter($easterYear);
		$easter = Time::Piece->strptime($easterYear."-".$easterMonth."-".$easterDay, "%Y-%m-%d");
		return $easter;
	}
	catch{
		confess "Could not calculate Easter for the year [". $easterYear ."]";
	}
}

=head2 _buildAshWednesday

	Ash Wednesday is the start of Lent.  It occurs 46 days before Easter for the given year.

=cut
sub _determineAshWednesday {
	my $easter = shift;

	my $ashWednesday = undef;

	try{
		my $secondsToSubtract = 46 * ONE_DAY;
		$ashWednesday = $easter - $secondsToSubtract;
		return $ashWednesday;
	}
	catch{
		confess "Could not calculate Ash Wednesday for Easter [". $easter->ymd ."].";
	}
}

sub _determineHolyWeek {
	my $date = shift;
	my $easter = shift;

	my $dateMark = $easter - ONE_DAY;
	if ($date == $dateMark) {
		return "Holy Saturday";
	}

	$dateMark = $dateMark - ONE_DAY;
	if ($date == $dateMark) {
		return "Good Friday";
	}

	$dateMark = $dateMark - ONE_DAY;
	if ($date == $dateMark) {
		return "Maundy Thursday";
	}

	$dateMark = $dateMark - ONE_DAY;
	if ($date == $dateMark) {
		return "Wednesday in Holy Week";
	}

	$dateMark = $dateMark - ONE_DAY;
	if ($date == $dateMark) {
		return "Tuesday in Holy Week";
	}

	$dateMark = $dateMark - ONE_DAY;
	if ($date == $dateMark) {
		return "Monday in Holy Week";
	}

	return undef;
}

sub _determineEasterWeek {
	my $date = shift;
	my $easter = shift;

	my $dateMark = $easter + ONE_DAY;
	if ($date == $dateMark) {
		return "Monday of Easter Week";
	}

	$dateMark = $dateMark + ONE_DAY;
	if ($date == $dateMark) {
		return "Tuesday of Easter Week";
	}

	$dateMark = $dateMark + ONE_DAY;
	if ($date == $dateMark) {
		return "Wednesday of Easter Week";
	}

	$dateMark = $dateMark + ONE_DAY;
	if ($date == $dateMark) {
		return "Thursday of Easter Week";
	}

	$dateMark = $dateMark + ONE_DAY;
	if ($date == $dateMark) {
		return "Friday of Easter Week";
	}

	$dateMark = $dateMark + ONE_DAY;
	if ($date == $dateMark) {
		return "Saturday of Easter Week";
	}

	return undef;
}


sub _buildFixedDays {
	my $date = shift;

	#Fixed holidays in January
	if($date->mon == 1) {

	}
	#Fixed holidays in February
	elsif($date->mon == 2) {

	}
	#Fixed holidays in March
	elsif($date->mon == 3) {

	}
	#Fixed holidays in April
	elsif($date->mon == 4) {

	}
	#Fixed holidays in May
	elsif($date->mon == 5) {

	}
	#Fixed holidays in June
	elsif($date->mon == 6) {

	}
	#Fixed holidays in July
	elsif($date->mon == 7) {

	}
	#Fixed holidays in August
	elsif($date->mon == 8) {

	}
	#Fixed holidays in September
	elsif($date->mon == 9) {

	}
	#Fixed holidays in October
	elsif($date->mon == 10) {

	}
	#Fixed holidays in November
	elsif($date->mon == 11) {

	}
	#Fixed holidays in December
	elsif($date->mon == 12) {
		if ($date->mday == 25) { return "Christmas Day";}
	}
	else {
		confess "Date [". $date->ymd . "] is not a known or valid date.";
	}
}

sub _determineChristmasEpiphany {
	my $date = shift;

	my $advent = shift;

	#Is the date in Christmastide?
	my $dateMarker = nextSunday($advent->fourthSunday);
	if ($date == $dateMarker) {
		return "The First Sunday of Christmas";
	}

	$dateMarker = nextSunday($dateMarker);
	if ($date == $dateMarker) {
		return "The Second Sunday of Christmas";
	}

	#Is the date in Epiphany?
	$dateMarker = nextSunday($dateMarker);
	if ($date == $dateMarker) {
		return "The First Sunday of Epiphany";
	}

	$dateMarker = nextSunday($dateMarker);
	if ($date == $dateMarker) {
		return "The Second Sunday of Epiphany";
	}

	$dateMarker = nextSunday($dateMarker);
	if ($date == $dateMarker) {
		return "The Third Sunday of Epiphany";
	}

	$dateMarker = nextSunday($dateMarker);
	if ($date == $dateMarker) {
		return "The Fourth Sunday of Epiphany";
	}

	$dateMarker = nextSunday($dateMarker);
	if ($date == $dateMarker) {
		return "The Fifth Sunday of Epiphany";
	}

	$dateMarker = nextSunday($dateMarker);
	if ($date == $dateMarker) {
		return "The Sixth Sunday of Epiphany";
	}

	$dateMarker = nextSunday($dateMarker);
	if ($date == $dateMarker) {
		return "The Seventh Sunday of Epiphany";
	}

	$dateMarker = nextSunday($dateMarker);
	if ($date == $dateMarker) {
		return "The Second to Last Sunday after Epiphany";
	}

	$dateMarker = nextSunday($dateMarker);
	if ($date == $dateMarker) {
		return "The Last Sunday after Epiphany";
	}

	croak "There are no further Sundays of Christmastide or Epiphany.";
}

sub _determineLentHolyWeek {
	my $date = shift;
	my $ashWednesday = shift;

	my $dateMarker = nextSunday($ashWednesday);
	if ($date == $dateMarker) {
		return "The First Sunday in Lent";
	}

	$dateMarker = nextSunday($dateMarker);
	if ($date == $dateMarker) {
		return "The Second Sunday in Lent";
	}

	$dateMarker = nextSunday($dateMarker);
	if ($date == $dateMarker) {
		return "The Third Sunday in Lent";
	}

	$dateMarker = nextSunday($dateMarker);
	if ($date == $dateMarker) {
		return "The Fourth Sunday in Lent";
	}

	$dateMarker = nextSunday($dateMarker);
	if ($date == $dateMarker) {
		return "The Fifth Sunday in Lent";
	}

	$dateMarker = nextSunday($dateMarker);
	if ($date == $dateMarker) {
		return "The Fifth Sunday in Lent";
	}

	$dateMarker = nextSunday($dateMarker);
	if ($date == $dateMarker) {
		return "Palm Sunday";
	}

	croak "There are no further Sundays in Lent";
}

sub _determineYear {
	my $calYear = shift;

	if ($calYear%3 == 0) {
		return 'A';
	}
	elsif (($calYear-1)%3 == 0) {
		return 'B';
	}
	elsif (($calYear-2)%3 == 0) {
		return 'C';
	}

	return undef;
}

sub _buildReadings {
	my @readings;

	push(@readings, Date::Lectionary::Reading->new(book=>'Gen', begin=>'1:1', end=>'1:5'));

	return \@readings;
}

sub _determineDay {
	my $date = shift;

	my $advent = shift;
	my $easter = shift;

	#Is the date in Advent?
	if ($date == $advent->firstSunday) {
		return "The First Sunday in Advent";
	}
	elsif ($date == $advent->secondSunday) {
		return "The Second Sunday in Advent";
	}
	elsif ($date == $advent->thirdSunday) {
		return "The Third Sunday in Advent";
	}
	elsif ($date == $advent->fourthSunday) {
		return "The Fourth Sunday in Advent";
	}

	#Is the date Easter Sunday?
	if ($date == $easter) {
		return "Easter Day";
	}

	#Determine when Ash Wednesday is
	my $ashWednesday = _determineAshWednesday($easter);
	if ($date == $ashWednesday) {
		return "Ash Wednesday";
	}

	#Holy Week
	my $holyWeekDay = _determineHolyWeek($date, $easter);
	if ($holyWeekDay) {return $holyWeekDay;}

	#Easter WEek
	my $easterWeekDay = _determineEasterWeek($date, $easter);
	if ($easterWeekDay) {return $easterWeekDay;}

	#Fixed celebrations
	my $fixedDay = _buildFixedDays($date);
	if ($fixedDay) {return $fixedDay;}

	if($date->wday!=1) {
		my $nextSunday = nextSunday($date);
		$date = $nextSunday;
	}

	#Sundays of the Liturgical Year
	if($date < $ashWednesday) {
		return _determineChristmasEpiphany($date, $advent);
	}

	if($date < $easter) {
		return _determineLent($date, $ashWednesday);
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

1; # End of Date::Lectionary
