use v5.22;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'Date::Lectionary',
    AUTHOR           => q{Michael Wayne Arnold <marmanold@cpan.org>},
    VERSION_FROM     => 'lib/Date/Lectionary.pm',
    ABSTRACT         => 'Date::Lectionary',
    LICENSE          => 'perl_5',
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.022000,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => '1.302040',
        'Test::CheckManifest' => '0.9',
        'Test::Exception' => '0.43',
    },
    PREREQ_PM => {
        'Carp' => '1.38',
        'Try::Tiny' => '0.24',
        'Time::Piece' => '1.31',
        'Time::Seconds' => '1.31',
        'Moose' => '2.1804',
        'Moose::Util::TypeConstraints' => '2.1804',
        'MooseX::Aliases' => '0.11',
        'Date::Advent' => '1.20160727',
        'Date::Easter' => '1.22',
        'Date::Lectionary::Time' => '1.20160809',
        'namespace::autoclean' => '0.28',
    },
    META_ADD => {
      resources => {
        repository => {
            type => 'git',
            url => 'git://github.com/marmanold/Date-Lectionary.git',
            web => 'https://github.com/marmanold/Date-Lectionary',
        },
      },
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Date-Lectionary-*' },
);
