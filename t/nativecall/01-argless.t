use strict;
use Test::More 0.98;
BEGIN { chdir '../../' if !-d 't'; }
use lib '../lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
use Dyn qw[:all];
use File::Spec;
use t::nativecall;
#
compile_test_lib('01-argless');
#
sub Nothing : Native('t/01-argless')                              {...}
sub Argless : Native('t/01-argless') : Signature('()i')           {...}
sub ArglessChar : Native('t/01-argless') : Signature('()c')       {...}
sub ArglessLongLong : Native('t/01-argless') : Signature('()l')   {...}
sub ArglessPointer : Native('t/01-argless') : Signature('()p')    {...}    # Pointer[int32]
sub ArglessUTF8String : Native('t/01-argless') : Signature('()Z') {...}
sub short : Native('t/01-argless') : Signature('()i') : Symbol('long_and_complicated_name') {...}
#
Nothing();
pass 'survived the call';
#
is Argless(),           2,               'called argless function returning int32';
is ArglessChar(),       2,               'called argless function returning char';
is ArglessLongLong(),   2,               'called argless function returning long long';
is ArglessPointer(),    "\2",            'called argless function returning pointer';
is ArglessUTF8String(), 'Just a string', 'called argless function returning string';
is short(),             3,               'called long_and_complicated_name';

#sub test_native_closure() {
#    my sub Argless :Native('t/01-argless') : Signature('()i') { ... }
#    is Argless(), 2, 'called argless closure';
#}
#test_native_closure();
#test_native_closure(); # again cause we may have created an optimized version to run
done_testing;
