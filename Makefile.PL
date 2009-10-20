use inc::Module::Install;
name 'CGI-Emulate-PSGI';
all_from 'lib/CGI/Emulate/PSGI.pm';

requires 'HTTP::Response';
tests 't/*.t t/*/*.t t/*/*/*.t';
author_tests 'xt';

test_requires 'Test::More'       => 0.94;
build_requires 'Test::More';
auto_include;
WriteAll;
