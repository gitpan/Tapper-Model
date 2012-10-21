
use strict;
use warnings;

use 5.010;

use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "Tapper - Context sensitive connected DBIC schema",
  "AUTHOR" => "AMD OSRC Tapper Team <tapper\@amd64.org>",
  "BUILD_REQUIRES" => {
    "Data::DPath" => 0,
    "Data::Dumper" => 0,
    "Tapper::Schema::TestTools" => 0,
    "Test::Fixture::DBIC::Schema" => 0,
    "Test::More" => 0
  },
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Tapper-Model",
  "EXE_FILES" => [],
  "LICENSE" => "open_source",
  "NAME" => "Tapper::Model",
  "PREREQ_PM" => {
    "Carp" => 0,
    "Class::C3" => 0,
    "Exporter" => 0,
    "MRO::Compat" => 0,
    "Memoize" => 0,
    "Tapper::Config" => 0,
    "Tapper::Schema" => "v4.1.0",
    "parent" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "VERSION" => "4.1.1",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



