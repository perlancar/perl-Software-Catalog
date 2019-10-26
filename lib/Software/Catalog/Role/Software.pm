package Software::Catalog::Role::Software;

# DATE
# VERSION

use Role::Tiny;

requires 'canon2native_arch_map';
requires 'latest_version';

# requires 'homepage_url'; # optional for now.

# requires qw(available_versions); # optional for now. args: arch.

requires 'download_url';

# requires qw(release_note); # optional for now. args: arch, version

requires 'archive_info';

# versioning scheme
requires qw(is_valid_version cmp_version);

# dedicated_profile means the software checks program location for profile, like
# firefox 67+. this means, we should not use symlink for latest version, e.g.
# /opt/firefox -> /opt/firefox-70.0 but should copy /opt/firefox-70.0 (or later
# version) to /opt/firefox instead, to avoid changing of program location
# whenever there's a new version.
# requires 'dedicated_profile'; # optional for now

###

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
