use strict;
use warnings;

use inc::Module::Install;

name     'Tapper-Model';
all_from 'lib/Tapper/Model.pm';
author   'AMD OSRC Tapper Team <tapper@amd64.org>';
license  'freebsd';

build_requires 'Test::More'                  => 0;
build_requires 'Test::Perl::Critic'          => 0;
build_requires 'Test::Fixture::DBIC::Schema' => "0.02";
build_requires 'Tapper::Test'                => "3.000002";
build_requires 'Data::DPath'                 => "0.17";

author_requires 'Module::Install::WriteAll';

requires 'perl'                        => '5.010';
requires 'parent'                      => 0;
requires 'Memoize'                     => 0;
requires 'Tapper::Config'              => "3.000002";
requires 'Tapper::Schema'              => "3.000002";

WriteAll;
