package Dyn::Load 0.01 {
    use strict;
    use warnings;
    use 5.030;
    use XSLoader;
    XSLoader::load( __PACKAGE__, $Dyn::Load::VERSION );
    use parent 'Exporter';
    our %EXPORT_TAGS = (
        lib => [
            qw[ dlLoadLibrary dlFreeLibrary dlFindSymbol dlGetLibraryPath
                dlSymsInit dlSymsCount dlSymsName
            ]
        ]
    );
    @{ $EXPORT_TAGS{all} } = our @EXPORT_OK = map { @{ $EXPORT_TAGS{$_} } } keys %EXPORT_TAGS;
};
1;
__END__

=encoding utf-8

=head1 NAME

Dyn::Load - dyncall Backed FFI

=head1 SYNOPSIS

    use Dyn::Load qw[:all]; # Exports nothing by default
	use Dyn::Call;

    my $lib = dlLoadLibrary( 'path/to/lib.so' );
    my $ptr = dlFindSymbol( $lib, 'add' );
    my $cvm = Dyn::Call::dcNewCallVM(1024);
    Dyn::Call::dcMode( $cvm, 0 );
    Dyn::Call::dcReset( $cvm );
    Dyn::Call::dcArgInt( $cvm, 5 );
    Dyn::Call::dcArgInt( $cvm, 6 );
    Dyn::Call::dcCallInt( $cvm, $ptr ); #  '5 + 6 == 11';
	dlFreeSymbol( $lib );

=head1 DESCRIPTION

Dyn::Load wraps the C<dynload> library encapsulates dynamic loading mechanisms
and gives access to functions in foreign dynamic libraries and code modules.

=head1 Functions

Everything listed here may be imported by name or with the C<:all> tag.

=head2 C<dlLoadLibrary( ... )>

Loads a dynamic library at C<libpath> and returns a handle to it for use in L<<
C<dlFreeLibrary( ... )>|/C<dlFreeLibrary( ... )> >> and L<< C<dlFindSymbol( ...
)>|/C<dlFindSymbol( ... )> >> calls.

	my $lib = dlLoadLibrary( 'blah.dll' ); # Or .so, or just... "libmath", idk...

Passing C<undef> for the C<libpath> argument is valid, and returns a handle to
the main executable of the calling code. Also, searching libraries in library
paths (e.g. by just passing the library’s leaf name) should work, however,
they are OS specific. Returns a C<undef> on error.

Expected parameters include:

=over

=item C<libpath> - string

=back

=head2 C<dlFreeLibrary( ... )>

Frees the loaded library.

Expected parameters include:

=over

=item C<libhandle> - pointer returned by L<< C<dlLoadLibrary( ... )>|/C<dlLoadLibrary( ... )> >>

=back

=head2 C<dlFindSymbol( ... )>

This function returns a pointer to a symbol with name C<symbol> in the library
with handle C<libhandle>, or returns a C<undef> pointer if the symbol cannot be
found. The name is specified as it would appear in C source code (mangled if
C++, etc.).

Expected parameters include:

=over

=item C<libhandle> - pointer returned by L<< C<dlLoadLibrary( ... )>|/C<dlLoadLibrary( ... )> >>

=item C<symbol> - name of the symbol

=back

=head2 C<dlGetLibraryPath( ... )>

This function can be used to get a copy of the path to the library loaded with
handle C<libhandle>.

	dlGetLibraryPath()

The parameter C<sOut> is a pointer to a buffer of size C<bufSize> (in bytes),
to hold the output string.

Expected parameters include:

=over

=item C<libhandle> - pointer returned by L<< C<dlLoadLibrary( ... )>|/C<dlLoadLibrary( ... )> >>

=item C<sOut> - pointer to buffer

=item C<bufSize> - buffer size in bytes

=back

The return value is the size of the buffer (in bytes) needed to hold the
null-terminated string, or C<0> if it can’t be looked up. If C<< bufSize >=
return value >1 >>, a null-terminated string with the path to the library
should be in sOut. If it returns C<0>, the library name wasn't able to be
found. Please note that this might happen in some rare cases, so make sure to
always check.

=head2 C<dlSymsInit( ... )>




=head2 C<dlSymsCleanup( ... )>

=head2 C<dlSymsCount( ... )>

=head2 C<dlSymsName( ... )>

=head2 C<dlSymsNameFromValue( ... )>

=head1 LICENSE

Copyright (C) Sanko Robinson.

This library is free software; you can redistribute it and/or modify it under
the terms found in the Artistic License 2. Other copyrights, terms, and
conditions may apply to data transmitted through this module.

=head1 AUTHOR

Sanko Robinson E<lt>sanko@cpan.orgE<gt>

=begin stopwords

dynload sOut

=end stopwords

=cut
