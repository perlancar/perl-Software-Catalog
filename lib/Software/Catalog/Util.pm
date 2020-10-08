package Software::Catalog::Util;

# AUTHORITY
# DATE
# DIST
# VERSION

use 5.010001;
use strict;
use warnings;
use Log::ger;

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
        all => {
            schema => 'bool*',
        },
        agent => {
            schema => 'str*',
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
    state $orig_agent = $ua->agent;
    my %args = @_;

    $ua->agent( $args{agent} || $orig_agent);
    my $lwp_res = $ua->get($args{url});
    unless ($lwp_res->is_success) {
        return [$lwp_res->code, "Couldn't retrieve URL '$args{url}'" . (
            $lwp_res->message ? ": " . $lwp_res->message : "")];
    }

    my $res;
    if ($args{re}) {
        log_trace "Finding version from $args{url} using regex $args{re} ...";
        if ($args{all}) {
            my $content = $lwp_res->content;
            my %m;
            while ($content =~ /$args{re}/g) {
                $m{$1}++;
            }
            $res = [200, "OK (all)", [sort keys %m]];
        } else {
            if ($lwp_res->content =~ $args{re}) {
                $res = [200, "OK", $1];
            } else {
                $res = [543, "Couldn't match pattern $args{re} against ".
                            "content of URL '$args{url}'"];
            }
        }
    } else {
        log_trace "Finding version from $args{url} using code ...";
        $res = $args{code}->(
            content => $lwp_res->content, _lwp_res => $lwp_res);
    }
    log_trace "Result: %s", $res;
    $res;
}

1;
# ABSTRACT: Utility routines
