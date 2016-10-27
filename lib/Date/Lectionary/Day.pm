package Date::Lectionary::Day;

use v5.22;
use strict;
use warnings;

use Moose;
use MooseX::Aliases;
use Carp;
use Try::Tiny;
use Time::Piece;
use Time::Seconds;
use Date::Advent;
use Date::Easter;
use Date::Lectionary::Time qw(nextSunday prevSunday closestSunday);
use namespace::autoclean;
use Moose::Util::TypeConstraints;

=head1 NAME

Date::Lectionary::Day

=head1 VERSION

Version 1.20161027

=cut

our $VERSION = '1.20161027';


=head1 SYNOPSIS

A helper object for Date::Lectionary to package together all the parts of a scripture reading.

=cut

=head1 SUBROUTINES/METHODS

=cut

has 'date' => (
	is				=> 'ro',
	isa				=> 'Time::Piece',
	required 	=> 1,
);

has 'tradition' => (
  is        => 'ro',
  isa       => 'Str',
  default   => 'ACNA',
);

has 'displayName' => (
	is 				=> 'ro',
	isa 			=> 'Str',
	writer 		=> '_setDisplayName',
	init_arg 	=> undef,
  alias     => 'name',
);

has 'commonName' => (
  is 				=> 'ro',
  isa 			=> 'Str',
  writer 		=> '_setCommonName',
  init_arg 	=> undef,
);

=head2 BUILD

Constructor for the Date::Lectionary object.  Takes a Time::Piect object, date, to create the object.

=cut

sub BUILD {
	my $self = shift;

	my $advent = _determineAdvent($self->date);
	my $easter = _determineEaster($advent->firstSunday->year+1);

  my $commonName = _determineDay($self->date, $advent, $easter);
	$self->_setCommonName($commonName);
  $self->_setDisplayName($commonName);
}

=head2 _determineAdvent

Private method that takes a Time::Piece date object to returns a Date::Advent object containing the dates for Advent of the current liturgical year.

=cut

sub _determineAdvent {
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

=head2 _determineEaster

Private method that takes a four-digit representation of a Common Era year and calculates the date for Easter as a Time::Piece object.

=cut

sub _determineEaster {
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

=head2 _determineFeasts

Private method that takes the Time::Piece date given at construction and determines if the date is one of many feasts in the liturgical calendar.  Feasts are taken from the Anglican Church in North America's revision of the revised common lectionary.

=cut

sub _determineFeasts {
	my $date = shift;
	my $yesterday = $date - ONE_DAY;

	if ($yesterday->wday==1) {
		return _buildMoveableDays($yesterday);
	}
	elsif ($date->wday==1) {
			return _buildFixedDays($date);
	}
	else {
		return _buildMoveableDays($date) ? _buildMoveableDays($date) : _buildFixedDays($date);
	}
}

=head2 _buildMoveableDays

Private method that takes the Time::Piece date given at construction and determines if the date is one of many moveable feasts in the liturgical calendar.  Feasts are taken from the Anglican Church in North America's revision of the revised common lectionary.

=cut

sub _buildMoveableDays {
	my $date = shift;

	#Moveable holidays in January
	if($date->mon == 1) {
		if($date->mday == 18) { return "Confession of St. Peter"; }
		if($date->mday == 25) { return "Conversion of St. Paul"; }
	}
	#Moveable holidays in February
	elsif($date->mon == 2) {
		if($date->mday == 2) { return "The Presentation of Christ in the Temple"; }
		if($date->mday == 24) { return "St. Matthias"; }
	}
	#Moveable holidays in March
	elsif($date->mon == 3) {
		if($date->mday == 19) { return "St. Joseph"; }
		if($date->mday == 25) { return "The Annunciation"; }
	}
	#Moveable holidays in April
	elsif($date->mon == 4) {
		if($date->mday == 25) { return "St. Mark"; }
	}
	#Moveable holidays in May
	elsif($date->mon == 5) {
		if($date->mday == 1) { return "St. Philip & St. James"; }
		if($date->mday == 31) { return "The Visitation"; }
	}
	#Moveable holidays in June
	elsif($date->mon == 6) {
		if($date->mday == 11) { return "St. Barnabas"; }
		if($date->mday == 24) { return "Nativity of St. John the Baptist"; }
		if($date->mday == 29) { return "St. Peter & St. Paul"; }
	}
	#Moveable holidays in July
	elsif($date->mon == 7) {
		if($date->mday == 22) { return "St. Mary of Magdala"; }
		if($date->mday == 25) { return "St. James"; }
	}
	#Moveable holidays in August
	elsif($date->mon == 8) {
		if($date->mday == 15) { return "St. Mary the Virgin"; }
		if($date->mday == 24) { return "St. Bartholomew"; }
	}
	#Moveable holidays in September
	elsif($date->mon == 9) {
		if($date->mday == 14) { return "Holy Cross Day"; }
		if($date->mday == 21) { return "St. Matthew"; }
		if($date->mday == 29) { return "Holy Michael & All Angels"; }
	}
	#Moveable holidays in October
	elsif($date->mon == 10) {
		if($date->mday == 18) { return "St. Luke"; }
		if($date->mday == 28) { return "St. Simon & St. Jude"; }
	}
	#Moveable holidays in November
	elsif($date->mon == 11) {
		if($date->mday == 30) { return "St. Andrew"; }
	}
	#Moveable holidays in December
	elsif($date->mon == 12) {
		if($date->mday == 21) { return "St. Thomas"; }
		if($date->mday == 26) { return "St. Stephen"; }
		if($date->mday == 27) { return "St. John"; }
		if($date->mday == 28) { return "Holy Innocents"; }
	}
	else {
		confess "Date [". $date->ymd . "] is not a known or valid date.";
	}
}

=head2 _buildFixedDays

Private method that takes the Time::Piece date given at construction and determines if the date is one of many fixed (non-moveable) feasts in the liturgical calendar.  Fixed feasts are taken from the Anglican Church in North America's revision of the revised common lectionary.

=cut

sub _buildFixedDays {
	my $date = shift;

	#Fixed holidays in January
	if($date->mon == 1) {
		if($date->mday == 1) { return "Holy Name"; }
		if($date->mday == 6) { return "The Epiphany"; }
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
		if($date->mday == 6) { return "The Transfiguration"; }
	}
	#Fixed holidays in September
	elsif($date->mon == 9) {
	}
	#Fixed holidays in October
	elsif($date->mon == 10) {
	}
	#Fixed holidays in November
	elsif($date->mon == 11) {
		if($date->mday == 1) { return "All Saints' Day"; }
	}
	#Fixed holidays in December
	elsif($date->mon == 12) {
		if($date->mday == 25) { return "Christmas Day"; }
	}
	else {
		confess "Date [". $date->ymd . "] is not a known or valid date.";
	}
}

=head2 _determineAshWednesday

	Private method that takes the Time::Piece date for Easter and determines the date for Ash Wednesday.  Ash Wednesday is the start of Lent.  It occurs 46 days before Easter for the given year.

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

=head2 _determineAscension

Private method that takes the Time::Piece date for Easter and determines the date for Ascension.  Ascension is forty days (inclusive) after Easter.

=cut

sub _determineAscension {
	my $easter = shift;

	my $ascension = undef;

	try{
		my $secondsToAdd = 39 * ONE_DAY;
		$ascension = $easter + $secondsToAdd;
		return $ascension;
	}
	catch{
		confess "Could not calculate Ascension for Easter [". $easter->ymd ."].";
	}
}

=head2 _determinePentecost

Private method the takes the Time::Piece date for Easter and determines the date for Pentecost.  Pentecost is fifty days (inclusive) after Easter.

=cut

sub _determinePentecost {
	my $easter = shift;

	my $pentecost = undef;

	try{
		my $secondsToAdd = 49 * ONE_DAY;
		$pentecost = $easter + $secondsToAdd;
		return $pentecost;
	}
	catch{
		confess "Could not calculate Pentecost for Easter [". $easter->ymd ."].";
	}
}

=head2 _determineHolyWeek

Private method used to return the names of various days within Holy Week.  Takes the Time::Piece date given at construction and the Time::Piece date for Easter.  Returns undef if the date given at construction is not found in Holy Week.

=cut

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

	$dateMark = $dateMark - ONE_DAY;
	if ($date == $dateMark) {
		return "Palm Sunday";
	}

	return undef;
}

=head2 _determineEasterWeek

Private method used to return the names of various days within Easter Week.  Takes the Time::Piece date given at construction and the Time::Piece date for Easter.  Returns undef if the date given at construction is not found in Easter Week.

=cut

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

=head2 _determineChristmasEpiphany

Private method that matches the date given at construction against the Sundays in Christmastide and Epiphany.  Returns a string representation of the name of the Sunday in the lectionary.

=cut

sub _determineChristmasEpiphany {
	my $date = shift;

	my $advent = shift;

	my $ashWednesday = shift;

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
	if ($date == $dateMarker && $date != prevSunday($ashWednesday)) {
		return "The Second to Last Sunday after Epiphany";
	}
	elsif ($date == $dateMarker && $date == prevSunday($ashWednesday)) {
		return "The Last Sunday after Epiphany";
	}

	$dateMarker = nextSunday($dateMarker);
	if ($date == $dateMarker) {
		return "The Last Sunday after Epiphany";
	}

	confess "There are no further Sundays of Christmastide or Epiphany.";
}

=head2 _determineLent

Private method that matches the date given at construction against the Sundays in Lent.  Returns a string representation of the name of the Sunday in the lectionary.

=cut

sub _determineLent {
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

	confess "There are no further Sundays in Lent";
}

=head2 _determineEasterSeason

Private method that matches the date given at construction against the Sundays in the Easter season.  Returns a string representation of the name of the Sunday in the lectionary.

=cut

sub _determineEasterSeason {
	my $date = shift;
	my $easter = shift;

	my $dateMarker = nextSunday($easter);
	if ($date == $dateMarker) {
		return "The Second Sunday of Easter";
	}

	$dateMarker = nextSunday($dateMarker);
	if ($date == $dateMarker) {
		return "The Third Sunday of Easter";
	}

	$dateMarker = nextSunday($dateMarker);
	if ($date == $dateMarker) {
		return "The Fourth Sunday of Easter";
	}

	$dateMarker = nextSunday($dateMarker);
	if ($date == $dateMarker) {
		return "The Fifth Sunday of Easter";
	}

	$dateMarker = nextSunday($dateMarker);
	if ($date == $dateMarker) {
		return "The Sixth Sunday of Easter";
	}

	$dateMarker = nextSunday($dateMarker);
	if ($date == $dateMarker) {
		return "The Sunday after Ascension Day";
	}

	confess "There are no further Sundays of Easter for [". $date->ymd ."].";
}

=head2 _determineOrdinary

Private method that matches the date given at construction against the Sundays in Ordinary time, e.g. Trinity Sunday and following Sundays.  Returns a string representation of the name of the Sunday in the lectionary.

=cut

sub _determineOrdinary {
	my $date = shift;
	my $pentecost = shift;

	my $trinitySunday = nextSunday($pentecost);
	if ($date == $trinitySunday) {
		return "Trinity Sunday";
	}

	my $dateMarker = closestSunday(Time::Piece->strptime($pentecost->year . "-05-25", "%Y-%m-%d"));
	if ($date == $dateMarker) {
		return "Ordinary 8";
	}

	$dateMarker = closestSunday(Time::Piece->strptime($pentecost->year . "-06-01", "%Y-%m-%d"));
	if ($date == $dateMarker) {
		return "Ordinary 9";
	}

	$dateMarker = closestSunday(Time::Piece->strptime($pentecost->year . "-06-08", "%Y-%m-%d"));
	if ($date == $dateMarker) {
		return "Ordinary 10";
	}

	$dateMarker = closestSunday(Time::Piece->strptime($pentecost->year . "-06-15", "%Y-%m-%d"));
	if ($date == $dateMarker) {
		return "Ordinary 11";
	}

	$dateMarker = closestSunday(Time::Piece->strptime($pentecost->year . "-06-22", "%Y-%m-%d"));
	if ($date == $dateMarker) {
		return "Ordinary 12";
	}

	$dateMarker = closestSunday(Time::Piece->strptime($pentecost->year . "-06-29", "%Y-%m-%d"));
	if ($date == $dateMarker) {
		return "Ordinary 13";
	}

	$dateMarker = closestSunday(Time::Piece->strptime($pentecost->year . "-07-06", "%Y-%m-%d"));
	if ($date == $dateMarker) {
		return "Ordinary 14";
	}

	$dateMarker = closestSunday(Time::Piece->strptime($pentecost->year . "-07-13", "%Y-%m-%d"));
	if ($date == $dateMarker) {
		return "Ordinary 15";
	}

	$dateMarker = closestSunday(Time::Piece->strptime($pentecost->year . "-07-20", "%Y-%m-%d"));
	if ($date == $dateMarker) {
		return "Ordinary 16";
	}

	$dateMarker = closestSunday(Time::Piece->strptime($pentecost->year . "-07-27", "%Y-%m-%d"));
	if ($date == $dateMarker) {
		return "Ordinary 17";
	}

	$dateMarker = closestSunday(Time::Piece->strptime($pentecost->year . "-08-03", "%Y-%m-%d"));
	if ($date == $dateMarker) {
		return "Ordinary 18";
	}

	$dateMarker = closestSunday(Time::Piece->strptime($pentecost->year . "-08-10", "%Y-%m-%d"));
	if ($date == $dateMarker) {
		return "Ordinary 19";
	}

	$dateMarker = closestSunday(Time::Piece->strptime($pentecost->year . "-08-17", "%Y-%m-%d"));
	if ($date == $dateMarker) {
		return "Ordinary 20";
	}

	$dateMarker = closestSunday(Time::Piece->strptime($pentecost->year . "-08-24", "%Y-%m-%d"));
	if ($date == $dateMarker) {
		return "Ordinary 21";
	}

	$dateMarker = closestSunday(Time::Piece->strptime($pentecost->year . "-08-31", "%Y-%m-%d"));
	if ($date == $dateMarker) {
		return "Ordinary 22";
	}

	$dateMarker = closestSunday(Time::Piece->strptime($pentecost->year . "-09-07", "%Y-%m-%d"));
	if ($date == $dateMarker) {
		return "Ordinary 23";
	}

	$dateMarker = closestSunday(Time::Piece->strptime($pentecost->year . "-09-14", "%Y-%m-%d"));
	if ($date == $dateMarker) {
		return "Ordinary 24";
	}

	$dateMarker = closestSunday(Time::Piece->strptime($pentecost->year . "-09-21", "%Y-%m-%d"));
	if ($date == $dateMarker) {
		return "Ordinary 25";
	}

	$dateMarker = closestSunday(Time::Piece->strptime($pentecost->year . "-09-28", "%Y-%m-%d"));
	if ($date == $dateMarker) {
		return "Ordinary 26";
	}

	$dateMarker = closestSunday(Time::Piece->strptime($pentecost->year . "-10-05", "%Y-%m-%d"));
	if ($date == $dateMarker) {
		return "Ordinary 27";
	}

	$dateMarker = closestSunday(Time::Piece->strptime($pentecost->year . "-10-12", "%Y-%m-%d"));
	if ($date == $dateMarker) {
		return "Ordinary 28";
	}

	$dateMarker = closestSunday(Time::Piece->strptime($pentecost->year . "-10-19", "%Y-%m-%d"));
	if ($date == $dateMarker) {
		return "Ordinary 29";
	}

	$dateMarker = closestSunday(Time::Piece->strptime($pentecost->year . "-10-26", "%Y-%m-%d"));
	if ($date == $dateMarker) {
		return "Ordinary 30";
	}

	$dateMarker = closestSunday(Time::Piece->strptime($pentecost->year . "-11-02", "%Y-%m-%d"));
	if ($date == $dateMarker) {
		return "Ordinary 31";
	}

	$dateMarker = closestSunday(Time::Piece->strptime($pentecost->year . "-11-09", "%Y-%m-%d"));
	if ($date == $dateMarker) {
		return "Ordinary 32";
	}

	$dateMarker = closestSunday(Time::Piece->strptime($pentecost->year . "-11-16", "%Y-%m-%d"));
	if ($date == $dateMarker) {
		return "Ordinary 33";
	}

	$dateMarker = closestSunday(Time::Piece->strptime($pentecost->year . "-11-23", "%Y-%m-%d"));
	if ($date == $dateMarker) {
		return "Christ the King";
	}

	confess "There are no further Sundays of Ordinary Time.";
}

=head2 _determineDay

Private method that takes the Time::Piece data given at construction and, using other private methods, determines the name of the Feast Day or Sunday in the lectionary.  If the date given at construction is a fix feast, that day will be returned.  If the date given is a special feast -- e.g. Easter, Ash Wednesday, etc. -- or a Sunday the name of that day will be returned.  If the date isn't a special feast or a Sunday the name of the upcoming Sunday will be returned with the date of the upcoming Sunday appended in square brackets.

=cut

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

	#Easter Week
	my $easterWeekDay = _determineEasterWeek($date, $easter);
	if ($easterWeekDay) {return $easterWeekDay;}

	#Ascension is 40 days after Easter
	my $ascension = _determineAscension($easter);
	if ($date == $ascension) {
		return "Ascension Day";
	}

	#Pentecost is 50 days after Easter
	my $pentecost = _determinePentecost($easter);
	if ($date == $pentecost) {
		return "Pentecost";
	}

	#Feast Day Celebrations
	my $feastDay = _determineFeasts($date);
	if ($feastDay) {return $feastDay;}

	#If the date isn't a Sunday and we've determined it is not a fixed holiday
	#move the date to the upcoming Sunday and determine readings for that day.
	if($date->wday!=1) {
		my $nextSunday = nextSunday($date);
		return _determineDay($nextSunday, $advent, $easter) . " [".$nextSunday->ymd."]";
	}

	#Sundays of the Liturgical Year
	if($date < $ashWednesday) {
		return _determineChristmasEpiphany($date, $advent, $ashWednesday);
	}

	if($date < $easter) {
		return _determineLent($date, $ashWednesday);
	}

	if ($date > $easter && $date < $pentecost) {
		return _determineEasterSeason($date, $easter);
	}

	if ($date > $pentecost) {
		return _determineOrdinary($date, $pentecost);
	}
}

=head1 AUTHOR

Michael Wayne Arnold, C<< <marmanold at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-date-lectionary at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Date-Lectionary-Day>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Date::Lectionary::Day


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Date-Lectionary-Day>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Date-Lectionary-Day>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Date-Lectionary-Day>

=item * Search CPAN

L<http://search.cpan.org/dist/Date-Lectionary-Day/>

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

1; # End of Date::Lectionary::Day