use strict;
use warnings;
use CGI;
use CGI::Emulate::PSGI;
use Test::More;

my $app_input = CGI::Emulate::PSGI->handler(
    sub {
        read(\*STDIN, undef, 0, 0);
    },
);

my $app_errors = CGI::Emulate::PSGI->handler(
    sub {
        print STDERR "TEST";
    },
);

my $stream_input = StreamInput->new;
$app_input->({ REQUEST_METHOD => 'GET', 'psgi.input' => $stream_input, 'psgi.errors' => \*STDERR });

is $stream_input->{CALLED}, 1;

my $stream_errors = StreamErrors->new;
$app_errors->({ REQUEST_METHOD => 'GET', 'psgi.input' => \*STDIN, 'psgi.errors' => $stream_errors });

is $stream_errors->{CALLED}, "TEST";

done_testing;

package StreamInput;
sub new { bless({}, shift) }
sub read { my $self = shift; $self->{CALLED} = 1 }

package StreamErrors;
sub new { bless({}, shift) }
sub print { my $self = shift; $self->{CALLED} = shift }
