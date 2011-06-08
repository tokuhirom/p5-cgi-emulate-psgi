use strict;
use Test::More;
use CGI::Parse::PSGI qw(parse_cgi_output);

my $output = <<CGI;
Status: 302
Content-Type: text/html
X-Foo: bar
Location: http://localhost/

This is the body!
CGI

my $r = parse_cgi_output(\$output);
is $r->[0], 302;

my $h = HTTP::Headers->new;
while (my($k, $v) = splice @{$r->[1]}, 0, 2) {
    $h->header($k, $v);
}

is $h->content_length, 18;
is $h->content_type, 'text/html';
is $h->header('Location'), 'http://localhost/';

is_deeply $r->[2], [ "This is the body!\n" ];

done_testing;



