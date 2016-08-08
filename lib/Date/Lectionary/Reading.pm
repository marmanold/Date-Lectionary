package Date::Lectionary::Reading;

use v5.22;
use strict;
use warnings;

use Moose;
use Carp;
use Try::Tiny;
use namespace::autoclean;
use Moose::Util::TypeConstraints;

=head1 NAME

Date::Lectionary::Reading - The great new Date::Lectionary::Reading!

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

enum 'Testament', [qw(OT NT)];
enum 'ReadingType', [qw(OT Psalm Epistle Gospel)];
no Moose::Util::TypeConstraints;

=head1 SUBROUTINES/METHODS

=cut

has 'book'  	=> (
	is 			=> 'ro', 
	isa 		=> 'Str',
	required 	=> 1, 
);

has 'begin'  	=> (
	is 			=> 'ro', 
	isa 		=> 'Str',
	required 	=> 1, 
);

has 'end'  		=> (
	is 			=> 'ro', 
	isa 		=> 'Str',
	required	=> 1,
);

has 'testament' => (
	is 			=> 'ro', 
	isa			=> 'Testament', 
	builder 	=> '_buildTestament',
);

has 'type'  	=> (
	is 			=> 'ro', 
	isa 		=> 'ReadingType',
	builder 	=> '_buildType'
);

sub _buildTestament {
	my $self = shift;

	return 'OT';
}

sub _buildType {
	my $self = shift;

	return 'OT';
}

=head1 AUTHOR

Michael Wayne Arnold, C<< <marmanold at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-date-lectionary at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Date-Lectionary-Reading>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Date::Lectionary


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Date-Lectionary-Reading>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Date-Lectionary-Reading>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Date-Lectionary-Reading>

=item * Search CPAN

L<http://search.cpan.org/dist/Date-Lectionary-Reading/>

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

1; # End of Date::Lectionary::Reading