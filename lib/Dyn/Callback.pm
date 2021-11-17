package Dyn::Callback 0.01 {
    use strict;
    use warnings;
    use 5.030;
    use XSLoader;
    XSLoader::load( __PACKAGE__, $Dyn::Callback::VERSION );
    use parent 'Exporter';
    our %EXPORT_TAGS = (
        dcb => [
            qw[ dcbNewCallback dcbInitCallback dcbFreeCallback dcbGetUserData
            ]
        ]
    );
    @{ $EXPORT_TAGS{all} } = our @EXPORT_OK = map { @{ $EXPORT_TAGS{$_} } } keys %EXPORT_TAGS;
};
1;
__END__

=encoding utf-8

=head1 NAME

Dyn::Callback - dyncall Backed FFI

=head1 SYNOPSIS

    use Dyn; # Exports nothing by default

    my $lib = Dyn::Load::LoadLibrary( 'path/to/lib.so' );
    my $ptr = Dyn::Load::FindSymbol( $lib, 'add' );
    my $cvm = Dyn::Call::NewCallVM(1024);
    Dyn::Call::Mode( $cvm, 0 );
    Dyn::Call::Reset( $cvm );
    Dyn::Call::ArgInt( $cvm, 5 );
    Dyn::Call::ArgInt( $cvm, 6 );
    Dyn::Call::CallInt( $cvm, $ptr ); #  '5 + 6 == 11';

=head1 DESCRIPTION

Dyn::Callback has an interface to create callback objects that can be passed to
functions as callback arguments. In other words, a pointer to the callback
object can be "called", directly. The callback handler then allows iterating
dynamically over the arguments once called back.

=head1 Functions

These may be imported by name or called directly.

=head2 C<new( ... )>




=head2 C<dcbNewCallback( ... )>



=head2 C<dcbInitCallback( ... )>

=head2 C<dcbFreeCallback( ... )>

=head2 C<dcbGetUserData( ... )>





=head1 LICENSE

Copyright (C) Sanko Robinson.

This library is free software; you can redistribute it and/or modify it under
the terms found in the Artistic License 2. Other copyrights, terms, and
conditions may apply to data transmitted through this module.

=head1 AUTHOR

Sanko Robinson E<lt>sanko@cpan.orgE<gt>

=begin stopwords


=end stopwords

=cut
