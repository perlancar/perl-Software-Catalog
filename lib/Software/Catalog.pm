package Software::Catalog;

use 5.010;
use strict;
use warnings;

use Perinci::Sub::Gen::AccessTable 0.17 qw(gen_read_table_func);

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(list_software);

# XXX import catalog from software-catalog
# (https://github.com/sharyanto/software-catalog)
my @software = (
    {
        id           => 'wordpress',
        debian_names => [qw/wordpress/],
        lang         => 'php',
        tags         => [qw/webapp/],
    },
);

my $deb_re = qr/\A[a-z0-9]+(-[a-z0-9]+)*\z/;
my $tag_re = $deb_re;

my $res = gen_read_table_func(
    name => 'list_software',
    table_data => \@software,
    table_spec => {
        fields => {
            id => {
                index      => 0,
                schema     => ['str*' => {
                    match => $deb_re,
                }],
                searchable => 1,
            },
            debian_names => {
                index      => 2,
                schema     => ['array*' => {
                    of => ['str*' => {
                        match => $deb_re,
                    }],
                }],
                sortable   => 0,
            },
            tags => {
                index      => 2,
                schema     => ['array*' => {
                    of => ['str*' => match => $tag_re],
                }],
                sortable   => 0,
            },
            # XXX field: lang
            # XXX field: summary (in various languages)
            # XXX field: description (in various languages)
            # XXX field: license
            # XXX field: url
            # XXX field: download_url (see Software::Release::Watch)
        },
        pk => 'id',
    },
    langs => ['en_US'],
);
die "BUG: Can't generate func: $res->[0] - $res->[1]"
    unless $res->[0] == 200;

1;
# ABSTRACT: Software catalog

=head1 SYNOPSIS

 use Software::Catalog qw(list_software);
 my $res = list_software();


=head1 STATUS

Proof of concept. Incomplete catalog.


=head1 DESCRIPTION

This module contains catalog of software.

Currently the main use for this module is to establish a common name for a
software and find the Debian source package name(s) (and possibly others too in
the future, like Fedora package, FreeBSD port, etc) for it.


=head1 FAQ


=head1 SEE ALSO

L<Software::Release::Watch>

L<Software::Installation::Detect>

=cut

