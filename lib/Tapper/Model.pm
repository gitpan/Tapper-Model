package Tapper::Model;

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

our $VERSION   = '3.000001';
our @EXPORT_OK = qw(model get_hardware_overview get_systems_id_for_hostname);


=begin model

Returns a connected schema, depending on the environment (live,
development, test).

@param 1. $schema_basename - optional, default is "Tests", meaning the
          Schema "Tapper::Schema::Tests"

@return $schema

=end model

=cut

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
        eval {
                # maybe no TestrunSchedulings in DB yet
                $model->resultset('TestrunScheduling')->first->gen_schema_functions if $schema_basename eq 'TestrunDB';
        };
        return $model;
}


=head2 get_or_create_user

Search a user based on login name. Create a user with this login name if
not found.

@param string - login name

@return success - id (primary key of user table)
@return error   - undef

=cut 

sub get_or_create_user {
        my ($login) = @_;
        my $user_search = model('TestrunDB')->resultset('User')->search({ login => $login });
        my $user_id;
        if (not $user_search) {
                my $user = model('TestrunDB')->resultset('User')->new({ login => $login });
                $user->insert;
                return user->id;
        } else {
                my $user = $user_search->first;
                return $user ? $user->id : 0;
                
        }
        return;
}


sub free_hosts_with_features
{
        my $hosts =  model('TestrunDB')->resultset("Host")->free_hosts;
        my @hosts_with_features;
        while (my $host = $hosts->next) {
                my $features = get_hardware_overview($host->id);
                $features->{hostname} = $host->name;
                my $queues = [];
#                $queues = [ map {$_->queue->id } $host->queuehosts->all ];
                push @hosts_with_features, {host => $host, features => $features, queues => $queues};
        }
        return \@hosts_with_features;
}


=head2 get_hardware_overview

Returns an overview of a given machine revision.

@param int - machine lid

@return success - hash ref
@return error   - undef

=cut

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

=head1 NAME

Tapper::Model - Tapper - Context sensitive connected DBIC schema

=head1 SYNOPSIS

    use Tapper::Model 'model';
    my $testrun = model->schema('Testrun')->find(12);  # defaults to "TestrunDB"
    my $testrun = model('ReportsDB')->schema('Report')->find(7343);


=head1 EXPORT

=head2 model

Returns a connected schema.

=head1 COPYRIGHT & LICENSE

Copyright 2008-2011 AMD OSRC Tapper Team, all rights reserved.

This program is released under the following license: freebsd


=cut

1; # End of Tapper::Model
