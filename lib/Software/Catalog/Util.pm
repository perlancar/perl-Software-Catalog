package Software::Catalog::Util;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

our %SPEC;

use Exporter qw(import);
our @EXPORT_OK = qw(
                       extract_from_url
               );

$SPEC{extract_from_url} = {
    v => 1.1,
    args => {
        url => {
            schema => 'url*',
            req => 1,
            pos => 0,
        },
        re => {
            schema => 're*',
        },
        code => {
            schema => 'code*',
        },
    },
    args_rels => {
        req_one => [qw/re code/],
    },
};
sub extract_from_url {
    state $ua = do {
        require LWP::UserAgent;
        LWP::UserAgent->new;
    };
    my %args = @_;

    my $lwp_res = $ua->get($args{url});
    unless ($lwp_res->is_success) {
        return [$lwp_res->code, "Couldn't retrieve URL '$args{url}'" . (
            $lwp_res->message ? ": " . $lwp_res->message : "")];
    }

    if ($args{re}) {
        unless ($lwp_res->content =~ $args{re}) {
            return [543, "Couldn't match pattern $args{re} against ".
                        "content of URL '$args{url}'"];
        }
        return [200, "OK", $1];
    } else {
        return $args{code}->(
            content => $lwp_res->content, _lwp_res => $lwp_res);
    }
}

1;
# ABSTRACT: Utility routines
