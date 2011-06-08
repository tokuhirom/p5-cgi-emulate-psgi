sub readme_markdown_from { }
sub readme_from { }

use inc::Module::Install;
name 'CGI-Emulate-PSGI';
all_from 'lib/CGI/Emulate/PSGI.pm';

requires 'HTTP::Response';
tests 't/*.t t/*/*.t t/*/*/*.t';
author_tests 'xt';

readme_from 'lib/CGI/Emulate/PSGI.pm';
readme_markdown_from 'lib/CGI/Emulate/PSGI.pm';
build_requires 'Test::More'       => 0.94;
test_requires 'Test::Requires';
auto_include;
WriteAll;
