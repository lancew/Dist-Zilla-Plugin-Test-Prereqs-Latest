use strict;
use warnings;
package Dist::Zilla::Plugin::Test::Prereqs::Latest;

# ABSTRACT: Tests your module has up to date dependencies
# VERSION

use 5.008;

use Moose;
extends 'Dist::Zilla::Plugin::InlineFiles';
with 'Dist::Zilla::Role::FilePruner';

=pod

=encoding UTF-8

=head1 NAME

Dist::Zilla::Plugin::Test::Prereqs::Current - Dzil plugin to check prereqs are up to date

=head1 DESCRIPTION

Tests that the versions in the [Prereqs] setion of the dist.ini are up to date

=head1 SYNOPSIS

To be written.

=head1 SUBLASSES / INTERFACES / ATTRIBUTES


=head2 prune_files

Stub for docs

=head1 AUTHOR

Lance Wicks <lancew@cpan.org>

=head1 CONTRIBUTORS

=head1 COPYRIGHT

This software is Copyright (c) 2022 by Lance Wicks.

=head1 LICENSE

This is free software; you can redistribute it and/or modify it under the same terms as the Perl 5 programming language system itself.
See the LICENSE file in the distribution on CPAN for full text.

=cut

sub prune_files
{
  my $self = shift;

  my $files = $self->zilla->files;

  unless (grep { $_->name eq 'dist.ini' } @$files) {
    $self->log("WARNING: dist.ini not found, removing xt/author/prereqs_latest.t");
    @$files = grep { $_->name ne 'xt/author/prereqs_latest.t' } @$files;
  } # end unless META.json

  return;
} # end prune_files

no Moose;
__PACKAGE__->meta->make_immutable;
1;
__DATA__
___[ xt/author/prereqs_latest.t ]___
use strict;
use warnings;

use App::UpdateCPANfile::PackageDetails;
use Dist::Zilla::Util::ParsePrereqsFromDistIni qw(parse_prereqs_from_dist_ini);
use Test::More;

my $prereqs = parse_prereqs_from_dist_ini(path => 'dist.ini');
my $checker = App::UpdateCPANfile::PackageDetails->new;

for my $key (sort keys %$prereqs) {
    for my $req (sort keys %{$prereqs->{$key}->{requires}}) {
        my $current_version = $prereqs->{$key}->{requires}->{$req};
        $current_version =~ s/v//g;
        my $latest_version = $checker->latest_version_for_package($req) || '0';
        my $out_of_date = ($latest_version <= $current_version);

        ok( $out_of_date,"$req: Current:$current_version, Latest:$latest_version");
    }
}
done_testing();
__END__
