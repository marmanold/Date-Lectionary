package Date::Lectionary;

use v5.22;
use strict;
use warnings;

use Moose;
use Carp;
use Try::Tiny;
use Time::Piece;
use Date::Advent;
use Date::Lectionary::Time qw(nextSunday prevSunday);
use Date::Lectionary::Reading;
use namespace::autoclean;
use Moose::Util::TypeConstraints;

=head1 NAME

Date::Lectionary - The great new Date::Lectionary!

=head1 VERSION

Version 1.20160731

=cut

our $VERSION = '1.20160731';


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

	$self->_setYear(_determineYear($advent->firstSunday->year));

	$self->_setDay(_determineDay($self->date));

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

	return 'Christmas';
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
