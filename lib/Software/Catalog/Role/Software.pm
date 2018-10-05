package Software::Catalog::Role::Software;

# DATE
# VERSION

use Role::Tiny;

requires 'canon2native_arch_map';
requires 'get_latest_version';
requires 'get_download_url';
requires 'get_archive_info';

# versioning scheme
requires qw(is_valid_version cmp_version);

sub _canon2native_arch {
    my ($self, $arch) = @_;

    my $map = $self->canon2native_arch_map;
    my $rmap = {reverse %$map};
    if ($map->{$arch}) {
        return $map->{$arch};
    } elsif ($rmap->{$arch}) {
        return $arch;
    } else {
        die "Unknown arch '$arch'";
    }
}

sub _native2canon_arch {
    my ($self, $arch) = @_;

    my $map = $self->canon2native_arch_map;
    my $rmap = {reverse %$map};
    if ($rmap->{$arch}) {
        return $rmap->{$arch};
    } elsif ($map->{$arch}) {
        return $arch;
    } else {
        die "Unknown arch '$arch'";
    }
}

1;
# ABSTRACT: Role for software
