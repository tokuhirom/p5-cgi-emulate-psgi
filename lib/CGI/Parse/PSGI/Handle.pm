package CGI::Parse::PSGI::Handle;
use strict;
use warnings;
use POSIX 'SEEK_SET';
use parent 'Tie::Handle';

sub TIEHANDLE {
    my ($class,$callback) = @_;

    my $self = { cb => $callback, buffer => '' };
    open $self->{fh},'>',\($self->{buffer});
    return bless $self, $class;
}

sub BINMODE {
    my ($self, $layer) = @_;
    if (@_==2) {
        binmode $self->{fh},$layer;
    }
    else {
        binmode $self->{fh};
    }
}

sub WRITE {
    my ($self,$buf,$len,$offset) = @_;
    seek( $self->{fh}, 0, SEEK_SET );
    $self->{buffer}='';
    print {$self->{fh}} substr($buf, $offset, $len);

    $self->{cb}->($self->{buffer});
    return $len;
}

sub CLOSE {
    my ($self) = @_;
    close $self->{fh};
    $self->{cb}->();
    return 1;
}

1;
