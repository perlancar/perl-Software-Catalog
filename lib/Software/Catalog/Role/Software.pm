package Software::Catalog::Role::Software;

# AUTHORITY
# DATE
# DIST
# VERSION

use Role::Tiny;

use PerlX::Maybe;

sub available_platform_labels {
    my $self = shift;
    sort keys %{ $self->platform_labels_to_specs };
}

sub first_matching_platform_label {
    require Devel::Platform::Info;
    require Devel::Platform::Match;

    my ($self, $platform_info) = @_;
    if (!defined($platform_info)) {
        $platform_info = Devel::Platform::Info->new->get_info;
    }

    my $platform_labels_to_specs = $self->platform_labels_to_specs;
    for my $platform_label (keys %$platform_labels_to_specs) {
        my $platform_spec = $platform_labels_to_specs->{$platform_label};
        if (Devel::Platform::Match::match_platform_bool($platform_spec, $platform_info)) {
            return $platform_label;
        }
    }
    undef;
}

requires 'archive_info';

around archive_info => sub {
    my $orig = shift;
    my ($self, %args) = @_;

    # supply default for 'platform_label' argument
    if (!defined $args{platform_label}) {
        $args{platform_label} = $self->first_matching_platform_label or
        return [412, "Platform not supported"];
    }

    # supply default for 'version' argument
    if (!defined $args{version}) {
        my $verres = $self->latest_version(maybe platform_label => $args{platform_label});
        return [500, "Can't get latest version: $verres->[0] - $verres->[1]"]
            unless $verres->[0] == 200;
        $args{version} = $verres->[2];
        $args{alternate_version} = $verres->[3]{'func.alternate_version'}
            if defined $verres->[3]{'func.alternate_version'};
    }

    $orig->($self, %args);
};

requires 'available_versions';

around available_versions => sub {
    my $orig = shift;
    my ($self, %args) = @_;

    # supply default for 'platform_label' argument
    if (!defined $args{platform_label}) {
        $args{platform_label} = $self->first_matching_platform_label or
        return [412, "Platform not supported"];
    }

    $orig->($self, %args);
};

requires 'cmp_version'; # usually from versioning scheme role

requires 'homepage_url';

requires 'is_dedicated_profile';

requires 'is_valid_version'; # usually from versioning scheme role

requires 'latest_version';

around latest_version => sub {
    my $orig = shift;
    my ($self, %args) = @_;

    # supply default for 'platform_label' argument
    if (!defined $args{platform_label}) {
        $args{platform_label} = $self->first_matching_platform_label or
        return [412, "Platform not supported"];
    }

    $orig->($self, %args);
};

requires 'platform_labels_to_specs';

requires 'download_url';

around download_url => sub {
    my $orig = shift;
    my ($self, %args) = @_;

    # supply default for 'platform_label' argument
    if (!defined $args{platform_label}) {
        $args{platform_label} = $self->first_matching_platform_label or
        return [412, "Platform not supported"];
    }

    # supply default for 'version' argument
    if (!defined $args{version}) {
        my $verres = $self->latest_version(maybe platform_label => $args{platform_label});
        return [500, "Can't get latest version: $verres->[0] - $verres->[1]"]
            unless $verres->[0] == 200;
        $args{version} = $verres->[2];
        $args{alternate_version} = $verres->[3]{'func.alternate_version'}
            if defined $verres->[3]{'func.alternate_version'};
    }

    $orig->($self, %args);
};

requires 'release_note';

around release_note => sub {
    my $orig = shift;
    my ($self, %args) = @_;

    # supply default for 'platform_label' argument
    if (!defined $args{platform_label}) {
        $args{platform_label} = $self->first_matching_platform_label or
        return [412, "Platform not supported"];
    }

    # supply default for 'version' argument
    if (!defined $args{version}) {
        my $verres = $self->latest_version(maybe platform_label => $args{platform_label});
        return [500, "Can't get latest version: $verres->[0] - $verres->[1]"]
            unless $verres->[0] == 200;
        $args{version} = $verres->[2];
        $args{alternate_version} = $verres->[3]{'func.alternate_version'}
            if defined $verres->[3]{'func.alternate_version'};
    }

    $orig->($self, %args);
};

1;
# ABSTRACT: Role for software

=head1 REQUIRED METHODS

=head2 archive_info

Get information about an archive of software download.

Usage:

 my $envres = $swobj->archive_info(%args);
 # sample result:
 # [200, "OK", {
 #   programs => [
 #     {name=>"firefox", path=>"/"},
 #   ],
 # }]

Return L<enveloped result|Rinci::function/"Enveloped result">. The payload is a
hash that can contain these keys: C<programs> which is an array of C<<
{name=>"PROGRAM_NAME", path=>"/PATH/"} >> records.

Arguments:

=over

=item * platform_label

Str, ...

=item * format

Str, optional. If software provides several archive formats that might differ in
structure or other aspects (e.g. ".zip" and ".tar.gz"), the user can choose
which by passing this argument.

=item * version

Str. Optional. If not specified, this role's method modifier will supply
the default from L</latest_version>.

=back

=head2 available_versions

List all available versions of a software. This usually means versions available
for download. It does not always equate all known versions.

Usage:

 my $envres = $swobj->available_versions(%args);

Return L<enveloped result|Rinci::function/"Enveloped result">.

Arguments:

=over

=item * platform_label

Str, ...

=back

If you do not want to provide this functionality, you can return something like:

 [501, "Not implemented"]

=head2 cmp_version

Compare two version strings and return -1|0|1 like Perl's C<cmp()> operator.

Usage:

 my $cmp = $swobj->cmp_version($v1, $v2); # -1, 0, or 1

This method can often be supplied by a L<Versioning::Scheme>::* role if your
software follows a scheme that is supported.

=head2 download_url

Get download URL.

Usage:

 my $envres = $swobj->download_url(%args);
 # sample result:
 # [200, "OK", "https://www.example.org/foo-1.23.tar.gz"]

Return L<enveloped result|Rinci::function/"Enveloped result">.

Arguments:

=over

=item * platform_label

Str, ....

=item * version

Str. Optional. If not specified, this role's method modifier will supply
the default from L</latest_version>.

=back

=head2 homepage_url

Return the homepage URL.

Arguments: none.

=head2 is_dedicated_profile

Check whether the software uses "dedicated profile".

Usage:

 my $is_dedicated = $swobj->is_dedicated_profile;

This method is created to support Firefox 67+ but can be used by other software
too. If C<is_dedicated_profile> returns a true value, it means the software
checks program location for profile and we should not use symlink for latest
version, e.g. /opt/firefox -> /opt/firefox-70.0 but should copy
/opt/firefox-70.0 (or later version) to /opt/firefox instead, to avoid changing
of program location whenever there's a new version.

Arguments: none.

=head2 is_valid_version

Check whether a version string is a syntactically valid version string for a
particular software. This does not mean that the said version actually exists,
just that the syntax is valid.

Usage:

 my $is_valid = $swobj->is_valid_version;

This method can often be supplied by a L<Versioning::Scheme>::* role if your
software follows a scheme that is supported.

=head2 latest_version

Get latest version information.

Usage:

 my $envres = $swobj->latest_version;
 # sample result:
 # [200, "OK", "80.0.1"]

Return L<enveloped result|Rinci::function/"Enveloped result">.

Arguments:

=over

=item * platform_label

Str, ....

=item * version

Str. Optional. If not specified, this role's method modifier will supply
the default from L</latest_version>.

=back

=head2 platform_label_to_spec

List supporter platforms. Must return a hashref of platform labels as key and
platform specifications as values (see L<Devel::Platform::Match>).

=head2 release_note

Get release note.

Usage:

 my $envres = $swobj->release_note(%args);
 # sample result:
 # [200, "OK", "..."]

Return L<enveloped result|Rinci::function/"Enveloped result">.

Arguments:

=over

=item * platform_label

Str, ...

=item * format

Str, optional. If software provides several release note formats, the user can
choose which by passing this argument. A sane default will be chosen.

=item * version

Str. Optional. If not specified, this role's method modifier will supply
the default from L</latest_version>.

=back


=head1 PROVIDED METHODS

=head2 available_platform_labels

Return a sorted list of available platforms for a software.

 my @platform_labels = $swobj->available_platform_labels;

This information is retrieved from L</platform_label_to_spec>.
