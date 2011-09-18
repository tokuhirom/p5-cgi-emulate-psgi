use strict;
use Test::More;
use CGI::Parse::PSGI qw(parse_cgi_output);

{
    my $output = <<CGI;
Status: 302
Content-Type: text/html
X-Foo: bar
Location: http://localhost/

This is the body!
CGI

    my($r, $h) = _parse($output);
    is $r->[0], 302;

    is $h->content_length, 18;
    is $h->content_type, 'text/html';
    is $h->header('Location'), 'http://localhost/';

    is_deeply $r->[2], [ "This is the body!\n" ];
}

{
    # rfc3875 6.2.3
    my $output = <<CGI;
Location: http://google.com/

CGI
    my($r, $h) = _parse($output);
    is $r->[0], 302;
    is $h->header('Location'), 'http://google.com/';
}

{
    # rfc3875 6.2.4
    my $output = <<CGI;
Status: 301
Location: http://google.com/
Content-Type: text/html

Redirected
CGI
    my($r, $h) = _parse($output);
    is $r->[0], 301;
    is $h->header('Location'), 'http://google.com/';
    is $h->content_type, 'text/html';
    is_deeply $r->[2], [ "Redirected\n" ];
}

done_testing;

sub _parse {
    my $output = shift;
    my $r = parse_cgi_output(\$output);

    my $h = HTTP::Headers->new;
    while (my($k, $v) = splice @{$r->[1]}, 0, 2) {
        $h->header($k, $v);
    }
    return $r, $h;
}
