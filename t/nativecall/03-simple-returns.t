use strict;
no warnings 'portable';
use Test::More 0.98;
BEGIN { chdir '../../' if !-d 't'; }
use lib '../lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
use Dyn qw[:all];
use File::Spec;
use t::nativecall;
use experimental 'signatures';
$|++;
#
compile_test_lib('03-simple-returns');
#
sub ReturnInt : Signature('()i') : Native('t/03-simple-returns') {...}
is ReturnInt(), 101, 'returning int works';
is ReturnInt(), 101, 'returning int works';
#
sub ReturnNegInt : Signature('()i') : Native('t/03-simple-returns') {...}
is ReturnNegInt(), -101, 'returning negative int works';
is ReturnNegInt(), -101, 'returning negative int works';
#
sub ReturnShort : Signature('()s') : Native('t/03-simple-returns') {...}
is ReturnShort(), 102, 'returning short works';
is ReturnShort(), 102, 'returning short works';
#
sub ReturnNegShort : Signature('()s') : Native('t/03-simple-returns') {...}
is ReturnNegShort(), -102, 'returning negative short works';
is ReturnNegShort(), -102, 'returning negative short works';
#
sub ReturnByte : Signature('()c') : Native('t/03-simple-returns') {...}
is ReturnByte(), -103, 'returning char works';
is ReturnByte(), -103, 'returning char works';
#
sub ReturnDouble : Signature('()d') : Native('t/03-simple-returns') {...}
is_approx ReturnDouble(), 99.9e0, 'returning double works';
#
sub ReturnFloat : Signature('()f') : Native('t/03-simple-returns') {...}
is_approx ReturnFloat(), -4.5e0, 'returning float works';
#
sub ReturnString : Signature('()Z') : Native('t/03-simple-returns') {...}
is ReturnString(), "epic cuteness", 'returning string works';
#
sub ReturnNullString : Native('t/03-simple-returns') : Signature('()Z') {...}
is ReturnNullString(), undef, 'returning null string pointer';
#
sub ReturnInt64 : Signature('()l') : Native('t/03-simple-returns') {...}
is ReturnInt64(), 0xFFFFFFFFFF, 'returning int64 works';
#
sub ReturnNegInt64 : Signature('()l') : Native('t/03-simple-returns') {...}
is ReturnNegInt64(), -0xFFFFFFFFFF, 'returning negative int64 works';
is ReturnNegInt64(), -0xFFFFFFFFFF, 'returning negative int64 works';
#
sub ReturnUint8 : Signature('()C') : Native('t/03-simple-returns') {...}
is ReturnUint8(), 0xFE, 'returning uint8 works';
#
sub ReturnUint16 : Signature('()S') : Native('t/03-simple-returns') {...}
is ReturnUint16(), 0xFFFE, 'returning uint16 works';
#
sub ReturnUint32 : Signature('()J') : Native('t/03-simple-returns') {...}
is ReturnUint32(), 0xFFFFFFFE, 'returning uint32 works';
#
done_testing;
