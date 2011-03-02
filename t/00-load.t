#!perl

use Test::More tests => 1;

BEGIN {
	use_ok( 'Tapper::Model' );
}

diag( "Testing Tapper::Model $Tapper::Model::VERSION, Perl $], $^X" );
