use strict;
use warnings;
use lib '../lib', '../blib/arch', '../blib/lib';
use Dyn qw[:sugar];
$|++;
#
sub GetSystemMetrics : Native('C:\Windows\System32\user32.dll') : Signature('(i)i');
#
CORE::say 'width = ' . GetSystemMetrics(0);
CORE::say 'height = ' . GetSystemMetrics(1);
CORE::say 'number of monitors = ' . GetSystemMetrics(80);
