package Software::Catalog;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use Perinci::Sub::Gen::AccessTable qw(gen_read_table_func);

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(
                       get_software_info
                       list_software
               );

our %SPEC;

$SPEC{':package'} = {
    v => 1.1,
    summary => 'Software catalog',
};

# XXX import catalog from software-catalog
# (https://github.com/sharyanto/software-catalog)
my @software = (
    {
        id           => 'wordpress',
        debian_names => [qw/wordpress/],
        tags         => [qw/
                               implemented-in::php
                               interface::web
                               web::blog
                           /],
    },
    {
        id           => 'joomla',
        debian_names => undef,
        tags         => [qw/
                               implemented-in::php
                               interface::web
                               web::cms
                           /],
    },
    {
        id           => 'jquery',
        debian_names => [qw/libjs-jquery/],
        tags         => [qw/
                               implemented-in::javascript
                               devel::library
                           /],
    },
    {
        id           => 'nginx',
        debian_names => [qw/nginx/],
        tags         => [qw/
                               implemented-in::c
                               interface::daemon
                               protocol::http
                           /],
    },
);

our $swid_re = qr/\A[a-z]([a-z0-9_])*\z/;
our $deb_re  = qr/\A[a-z0-9]+(-[a-z0-9]+)*\z/;
our $tag_re  = qr/\A([a-z0-9]+(-[a-z0-9]+)*::)?[a-z0-9]+(-[a-z0-9]+)*\z/x;

my $table_spec = {
    fields => {
        id => {
            index      => 0,
            schema     => ['str*' => {
                match => $swid_re,
            }],
            searchable => 1,
        },
        debian_names => {
            index      => 2,
            schema     => ['array' => {
                of => ['str*' => {
                    match => $deb_re,
                }],
            }],
            sortable   => 0,
        },
        tags => {
            index      => 2,
            schema     => ['array' => {
                of => ['str*' => match => $tag_re],
            }],
            sortable   => 0,
        },
        # XXX field: summary (in various languages)
        # XXX field: description (in various languages)
        # XXX field: license
        # XXX field: url

        # for download_url and releases/latest release, see
        # Software::Release::Watch
    },
    pk => 'id',
};

my $res = gen_read_table_func(
    name => 'list_software',
    table_data => \@software,
    table_spec => $table_spec,
    langs => ['en_US'],
);
die "BUG: Can't generate func: $res->[0] - $res->[1]"
    unless $res->[0] == 200;

$SPEC{get_software_info} = {
    v => 1.1,
    summary => 'Get info on a software',
    args => {
        id => {
            summary  => $table_spec->{fields}{id}{summary},
            schema   => $table_spec->{fields}{id}{schema},
            req      => 1,
            pos      => 0,
        },
    },
};
sub get_software_info {
    my %args = @_;
    my $id = $args{id};

    my $res = list_software("id" => $id, detail=>1);
    return [404, "No such software"] unless @{$res->[2]};

    [200, "OK", $res->[2][0]];
}

# XXX get_software_XXX_info (if later on we need more specific info, or when
# retrieving all info becomes heavy).

1;
# ABSTRACT:

=head1 SYNOPSIS

 use Software::Catalog qw(list_software get_software_info);
 my $res = list_software();
 $res    = get_software_info(software_id => 'wordpress');


=head1 STATUS

Proof of concept. Incomplete catalog.


=head1 DESCRIPTION

This module contains catalog of software.

Currently the main use for this module is to establish a common name for a
software and find the Debian source package name(s) (and possibly others too in
the future, like Fedora package, FreeBSD port, etc) for it.

Eventually, if the project takes off, this will also contain
summary/description/URL/license for each software.


=head1 FAQ


=head1 SEE ALSO

L<Software::Release::Watch>

L<Software::Installation::Detect>

=cut
