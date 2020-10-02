package Software::Catalog::Util;

# DATE
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

$SPEC{detect_arch} = {
    v => 1.1,
};
sub detect_arch {
    require Config; Config->import;
    my $archname = do { no strict 'vars'; no warnings 'once'; $Config{archname} };
    if ($archname =~ /\Ax86-linux/) {
        return "linux-x86"; # linux i386
    } elsif ($archname =~ /\Ax86-linux/) {
    } elsif ($archname =~ /\Ax86_64-linux/) {
        return "linux-x86_64";
    } elsif ($archname =~ /\AMSWin32-x86(-|\z)/) {
        return "win32";
    } elsif ($archname =~ /\AMSWin32-x64(-|\z)/) {
        return "win64";
    } else {
        die "Unsupported arch '$archname'";
    }
}

1;
# ABSTRACT: Utility routines
