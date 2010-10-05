#!perl -w
use strict;
use Test::More tests => 2;

use Void;

void fail '!!!';
void if(1) { fail '!'; fail '!!';  } pass;
pass;
done_testing;
