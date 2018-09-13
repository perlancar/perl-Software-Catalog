package Software::Catalog::Role::VersionScheme::SemVer;

# DATE
# VERSION

use 5.010001;
use Role::Tiny;

use SemVer;

sub _cmp_version {
    my ($self, $a, $b) = @_;
    SemVer->new($a) <=> SemVer->new($b);
}

1;
# ABSTRACT: Semantic versioning scheme

=head1 SEE ALSO

L<https://semver.org>
