package App::xspf2m3u::Command::convert;

use strict;
use warnings;
use autodie;
use 5.016;

use Path::Tiny qw/ path /;

use App::xspf2m3u -command;
use XML::XSPF ();

{
    no warnings 'redefine';
    *XML::XSPF::_isValidURI = sub { return 1; };
}
sub abstract { "convert .xspf playlists to .m3u ones" }

sub description { return abstract(); }

sub opt_spec
{
    return ( [ "output|o=s", "Output path" ], );
}

sub validate_args
{
    my ( $self, $opt, $args ) = @_;

    $self->usage_error("args required") if not @$args;
    if (0)
    {
        $self->usage_error("can only accept one path") if @$args != 1;
    }
}

sub execute
{
    my ( $self, $opt, $args ) = @_;

    my $text = '';
    foreach my $fn (@$args)
    {
        my $playlist = XML::XSPF->parse($fn);

        foreach my $track ( $playlist->trackList )
        {
            if ( my $loc = $track->location )
            {
                if ( $loc =~ /[\n\r]/ )
                {
                    die "Invalid newline in location <<$loc>>!";
                }
                $text .= "$loc\n";
            }
        }
    }
    path( $opt->{output} )->spew_utf8($text);

    return;
}

1;
