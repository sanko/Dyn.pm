use strict;
use warnings;
use lib '../lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib';
use Dyn qw[:sugar];
use Test::More;
use Config;
use File::Spec;
$|++;
#
my $lib;

# Build a library
use ExtUtils::CBuilder;
use File::Spec;
my ( $source_file, $object_file, $lib_file );
subtest 'ExtUtils::CBuilder' => sub {
    my $b = ExtUtils::CBuilder->new( quiet => 0 );
    ok $b, 'created EU::CB object';
    $source_file = File::Spec->catfile( ( -d 't' ? 't' : '.' ), 'libtest.cpp' );
    {
        open my $FH, '>', $source_file or die "Can't create $source_file: $!";
        print $FH <<'END'; close $FH;
#if defined(_WIN32) || defined(__WIN32__)
#  define LIB_EXPORT extern "C" __declspec(dllexport)
#else
#  define LIB_EXPORT extern "C"
#endif
LIB_EXPORT int add_i(int a, int b) { return a + b; }
END
    }
    ok -e $source_file, "generated '$source_file'";

    # Compile
    eval { $object_file = $b->compile( source => $source_file, 'C++' => 1 ) };
    is $@, q{}, 'no exception from compilation';
    ok -e $object_file, 'found object file';

    # Link
SKIP: {
        plan skip_all => 'error compiling source' unless -e $object_file;
        my @temps;
        eval {
            #$b->prelink(  );
            ( $lib_file, @temps ) = $b->link(
                objects      => $object_file,
                module_name  => 't::hello',
                dl_func_list => [qw[add_i]]
            );
        };
        is $@, q{}, 'no exception from linking';
        ok -e $lib_file, 'found library';

        #ok -x $lib_file, "executable file appears to be executable";
        if ( $^O eq 'os2' ) {    # Analogue of LDLOADPATH...

            # Actually, not needed now, since we do not link with the generated DLL
            my $old = OS2::extLibpath();    # [builtin function]
            $old = ";$old" if defined $old and length $old;

            # To pass the sanity check, components must have backslashes...
            OS2::extLibpath_set(".\\$old");
        }
    }
    subtest load_call => sub {
        my $add = Dyn::wrap( $lib_file, 'add_i', '(ii)i' );
        isa_ok $add, 'Dyn';
        is $add->( 2, 7 ), 9, '$add->( 2, 7 ) == 9 [bind with library name]';
        use Dyn::Load;
        my $lib = Dyn::Load::dlLoadLibrary($lib_file);
        isa_ok $lib, 'Dyn::DLLib';
        my $add_i = Dyn::wrap( $lib, 'add_i', '(ii)i' );
        isa_ok $add_i, 'Dyn';
        is $add_i->( 30, 6 ), 36, '$add_i->( 30, 6 ) == 36 [bind with library object]';
    };
    subtest attach => sub {
        Dyn::attach( $lib_file, 'add_i', '(ii)i', '__add_i' );
        is __add_i( 2, 7 ), 9, '__add_i( 2, 7 ) == 9 [attach with user defined name]';

        #diag Dyn::attach( $lib_file, 'add_i', '(ii)i' );
        #use Dyn::Load;
        #my $lib = Dyn::Load::dlLoadLibrary($lib_file);
        #isa_ok $lib, 'Dyn::DLLib';
        #my $add_i = Dyn::load( $lib, 'add_i', '(ii)i' );
        #isa_ok $add_i, 'Dyn';
        #is $add_i->call( 30, 6 ), 36, '$add_i->call( 30, 6 ) == 36 [bind with library object]';
    };
    subtest sugar => sub {
        diag $lib_file;
        use Config;
        diag( $Config{so} );
        sub add_i : Native( $lib_file ) : Signature('(ii)i');
        sub add : Native( $lib_file ) : Signature('(ii)i') : Symbol('add_i');
        is add_i( 30, 6 ), 36, 'add_i( 30, 6 ) == 36 [attach to symbol name]';
        is add( 2, 7 ),    9,  'add( 2, 7 ) == 9 [attach with user defined name]';
    };
    subtest synopsis => sub {
        use Dyn qw[:sugar];
        sub pow :
            Native( $^O eq 'MSWin32' ? 'ntdll.dll' : $^O eq 'darwin' ? 'libm.dylib' : 'libm', v6 )
            : Signature( '(dd)d' );
        is pow( 2, 10 ), 1024, 'pow(2, 10) portability test';
    };
};
done_testing;

# Cleanup
END {
    for ( grep { defined && -e } $source_file, $object_file, $lib_file ) {
        tr/"'//d;
        1 while unlink;
    }
    if ( $^O eq 'VMS' ) {
        1 while unlink 'LINKT.LIS';
        1 while unlink 'LINKT.OPT';
    }
}
