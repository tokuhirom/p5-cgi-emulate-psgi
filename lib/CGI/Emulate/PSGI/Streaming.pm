package CGI::Emulate::PSGI::Streaming;
use strict;
use warnings;
use parent 'CGI::Emulate::PSGI';
use CGI::Parse::PSGI;
use SelectSaver;
use Carp qw(croak);
use 5.008001;

our $VERSION = '0.21';

sub handler {
    my ($class, $code, ) = @_;

    return sub {
        my $env = shift;

        my $wrapped_app = sub {
            my ($stdout) = @_;
            my $saver = SelectSaver->new("::STDOUT");
            local %ENV = (%ENV, $class->emulate_environment($env));

            local *STDIN  = $env->{'psgi.input'};
            local *STDOUT = $stdout;
            local *STDERR = $env->{'psgi.errors'};

            $code->();
            close $stdout;
        };

        return sub {
            my ($responder) = @_;

            CGI::Parse::PSGI::parse_cgi_output_streaming($responder,$wrapped_app);
        };
    };
}

1;
