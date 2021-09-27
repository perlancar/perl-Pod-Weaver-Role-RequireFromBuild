package Pod::Weaver::Role::RequireFromBuild;

use 5.010001;
use Moose::Role;

# AUTHORITY
# DATE
# DIST
# VERSION

sub require_from_build {
    my ($self, $input, $name) = @_;

    my $zilla = $input->{zilla} or die "Can't get Dist::Zilla object";

    if ($name =~ /::/) {
        $name =~ s!::!/!g;
        $name .= ".pm";
    }

    return if exists $INC{$name};

    my @files = grep { $_->name eq "lib/$name" } @{ $zilla->files };
    @files    = grep { $_->name eq $name }       @{ $zilla->files }
        unless @files;
    die "Can't find $name in lib/ or ./ in build files" unless @files;

    my $file = $files[0];
    my $filename = $file->name;
    eval "# line 1 \"$filename (from dist build)\"\n" . $file->encoded_content;
    die if $@;
    $INC{$name} = "(set by ".__PACKAGE__.", from build files)";
}

no Moose::Role;
1;
# ABSTRACT: Role to require() from Dist::Zilla build files

=head1 SYNOPSIS

 $self->require_from_build($input, 'Foo/Bar.pm');
 $self->require_from_build($input, 'Baz::Quux');


=head1 DESCRIPTION


=head1 PROVIDED METHODS

=head2 require_from_build


=head1 SEE ALSO

L<Dist::Zilla::Plugin::TableData>
