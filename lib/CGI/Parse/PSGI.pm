package CGI::Parse::PSGI;
use strict;
use base qw(Exporter);
our @EXPORT_OK = qw( parse_cgi_output );

use IO::File; # perl bug: should be loaded to call ->getline etc. on filehandle/PerlIO
use HTTP::Response;

sub parse_cgi_output {
    my $output = shift;

    my $length;
    if (ref $output eq 'SCALAR') {
        $length = length $$output;
        open my $io, "<", $output;
        $output = $io;
    } else {
        binmode $output, ":raw";
        $length = -s $output;
    }

    my $headers;
    while ( my $line = $output->getline ) {
        $headers .= $line;
        last if $headers =~ /\x0d?\x0a\x0d?\x0a$/;
    }
    unless ( defined $headers ) {
        $headers = "HTTP/1.1 500 Internal Server Error\x0d\x0a";
    }

    unless ( $headers =~ /^HTTP/ ) {
        $headers = "HTTP/1.1 200 OK\x0d\x0a" . $headers;
    }

    my $response = HTTP::Response->parse($headers);
    $response->date( time() ) unless $response->date;

    my $status = $response->header('Status') || 200;
    $status =~ s/\s+.*$//; # remove ' OK' in '200 OK'

    my $remaining = $length - tell( $output );
    if ( $response->code == 500 && !$remaining ) {
        return [
            500,
            [ 'Content-Type' => 'text/html' ],
            [ $response->error_as_HTML ]
        ];
    }

    # TODO we can pass $output to the response body without buffering all?

    {
        my $length = 0;
        while ( $output->read( my $buffer, 4096 ) ) {
            $length += length($buffer);
            $response->add_content($buffer);
        }

        if ( $length && !$response->content_length ) {
            $response->content_length($length);
        }
    }

    return [
        $status,
        +[
            map {
                my $k = $_;
                map { ( $k => $_ ) } $response->headers->header($_);
            } $response->headers->header_field_names
        ],
        [$response->content],
    ];
}

1;

__END__

=head1 NAME

CGI::Parse::PSGI - Parses CGI output and creates PSGI response out of it

=head1 DESCRIPTION

  use CGI::Parse::PSGI qw(parse_cgi_output);

  my $output = YourApp->run;
  my $psgi_res = parse_cgi_output(\$output);

=head1 SYNOPSIS

CGI::Parse::PSGI exports one function C<parse_cgi_output> that takes a
filehandle or a reference to a string to read a CGI script output, and
creates a PSGI response (an array reference containing status code,
headers and a body) by reading the output.

Use L<CGI::Emulate::PSGI> if you have a CGI I<code> not the I<output>,
which takes care of automatically parsing the output, using this
module, from your callback code.

=head1 AUTHOR

Tatsuhiko Miyagawa

=head1 SEE ALSO

L<CGI::Emulate::PSGI>

=cut
