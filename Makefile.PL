use strict;
use warnings;
use inc::Module::Install;
use Module::Install::AuthorTests;
use Module::Install::Repository;
use Module::Install::XSUtil 0.32;

all_from 'lib/Void.pm';

use_xshelper;
cc_warnings;
cc_src_paths 'xs';

test_requires 'Test::More' => '0.88';

auto_set_repository;

tests_recursive;
author_tests 'xt';


clean_files qw(
    Void-*
    *.stackdump
    cover_db *.gcov *.gcda *.gcno
    nytprof
    *.out
);

WriteAll(check_nmake => 0);
