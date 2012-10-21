package Tapper::Model;
# git description: v4.1.0-1-g2dcb5e2

BEGIN {
  $Tapper::Model::AUTHORITY = 'cpan:AMD';
}
{
  $Tapper::Model::VERSION = '4.1.1';
}
# ABSTRACT: Tapper - Context sensitive connected DBIC schema

use warnings;
use strict;

use 5.010;

# avoid these warnings
#   Subroutine initialize redefined at /2home/ss5/perl510/lib/site_perl/5.10.0/Class/C3.pm line 70.
#   Subroutine uninitialize redefined at /2home/ss5/perl510/lib/site_perl/5.10.0/Class/C3.pm line 88.
#   Subroutine reinitialize redefined at /2home/ss5/perl510/lib/site_perl/5.10.0/Class/C3.pm line 101.
# by forcing correct load order.

use Class::C3;
use MRO::Compat;

use Memoize;
use Tapper::Config;
use parent 'Exporter';

our @EXPORT_OK = qw(model get_hardware_overview);


memoize('model');
sub model
{
        my ($schema_basename) = @_;

        $schema_basename ||= 'TestrunDB';

        my $schema_class = "Tapper::Schema::$schema_basename";

        # lazy load class
        eval "use $schema_class"; ## no critic (ProhibitStringyEval)
        if ($@) {
                print STDERR $@;
                return;
        }
        my $model =  $schema_class->connect(Tapper::Config->subconfig->{database}{$schema_basename}{dsn},
                                            Tapper::Config->subconfig->{database}{$schema_basename}{username},
                                            Tapper::Config->subconfig->{database}{$schema_basename}{password});
        return $model;
}


sub get_or_create_owner {
        my ($login) = @_;
        my $owner_search = model('TestrunDB')->resultset('Owner')->search({ login => $login });
        my $owner_id;
        if (not $owner_search->count) {
                my $owner = model('TestrunDB')->resultset('Owner')->new({ login => $login });
                $owner->insert;
                return $owner->id;
        } else {
                my $owner = $owner_search->search({}, {rows => 1})->first; # at least one owner
                return $owner->id;
        }
        return;
}




use Carp;

sub get_hardware_overview
{
        my ($host_id) = @_;

        my $host = model('TestrunDB')->resultset('Host')->find($host_id);
        return qq(Host with id '$host_id' not found) unless $host;

        my %all_features;

        foreach my $feature ($host->features) {
                $all_features{$feature->entry} = $feature->value;
        }
        return \%all_features;

}


1; # End of Tapper::Model

__END__
=pod

=encoding utf-8

=head1 NAME

Tapper::Model - Tapper - Context sensitive connected DBIC schema

=head1 SYNOPSIS

    use Tapper::Model 'model';
    my $testrun = model('TestrunDB')->schema('Testrun')->find(12);
    my $testrun = model('ReportsDB')->schema('Report')->find(7343);

=head2 model

Returns a connected schema, depending on the environment (live,
development, test).

@param 1. $schema_basename - optional, default is "Tests", meaning the
          Schema "Tapper::Schema::Tests"

@return $schema

=head2 get_or_create_owner

Search a owner based on login name. Create a owner with this login name if
not found.

@param string - login name

@return success - id (primary key of owner table)
@return error   - undef

=head2 free_hosts_with_features

Return list of free hosts with their features and queues.

=head2 get_hardware_overview

Returns an overview of a given machine revision.

@param int - machine lid

@return success - hash ref
@return error   - undef

=head1 AUTHOR

AMD OSRC Tapper Team <tapper@amd64.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by Advanced Micro Devices, Inc..

This is free software, licensed under:

  The (two-clause) FreeBSD License

=cut

