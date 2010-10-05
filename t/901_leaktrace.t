#!perl -w
use strict;
use Test::Requires { 'Test::LeakTrace' => 0.13 };
use Test::More;

use Void;

no_leaks_ok {
    # use Void here
};

done_testing;
