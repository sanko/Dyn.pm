#include "lib/xshelper.h"

#include <dynload.h>
#include <dyncall.h>
#include <dyncall_value.h>
#include <dyncall_callf.h>
#include <dyncall_signature.h>
#include <dyncall_callback.h>


/*

#define DC_SIGCHAR_VOID         'v'
#define DC_SIGCHAR_BOOL         'B'
#define DC_SIGCHAR_CHAR         'c'
#define DC_SIGCHAR_UCHAR        'C'
#define DC_SIGCHAR_SHORT        's'
#define DC_SIGCHAR_USHORT       'S'
#define DC_SIGCHAR_INT          'i'
#define DC_SIGCHAR_UINT         'I'
#define DC_SIGCHAR_LONG         'j'
#define DC_SIGCHAR_ULONG        'J'
#define DC_SIGCHAR_LONGLONG     'l'
#define DC_SIGCHAR_ULONGLONG    'L'
#define DC_SIGCHAR_FLOAT        'f'
#define DC_SIGCHAR_DOUBLE       'd'
#define DC_SIGCHAR_POINTER      'p'
#define DC_SIGCHAR_STRING       'Z' /* in theory same as 'p', but convenient to disambiguate * /
#define DC_SIGCHAR_STRUCT       'T'
#define DC_SIGCHAR_ENDARG       ')' /* also works for end struct * /

/* calling convention / mode signatures * /

#define DC_SIGCHAR_CC_PREFIX           '_'
#define DC_SIGCHAR_CC_DEFAULT          ':'
#define DC_SIGCHAR_CC_ELLIPSIS         'e'
#define DC_SIGCHAR_CC_ELLIPSIS_VARARGS '.'
#define DC_SIGCHAR_CC_CDECL            'c'
#define DC_SIGCHAR_CC_STDCALL          's'
#define DC_SIGCHAR_CC_FASTCALL_MS      'F'
#define DC_SIGCHAR_CC_FASTCALL_GNU     'f'
#define DC_SIGCHAR_CC_THISCALL_MS      '+'
#define DC_SIGCHAR_CC_THISCALL_GNU     '#' /* GNU thiscalls are cdecl, but keep specific sig char for clarity * /
#define DC_SIGCHAR_CC_ARM_ARM          'A'
#define DC_SIGCHAR_CC_ARM_THUMB        'a'
#define DC_SIGCHAR_CC_SYSCALL          '$'

*/

#include "lib/types.h"

#ifdef USE_ITHREADS
static PerlInterpreter *my_perl; /***    The Perl interpreter    ***/
#endif

typedef struct _callback {
    SV * cb;
    const char * signature;
    char ret_type;
    SV * userdata;
} _callback;

static char callback_handler(DCCallback * cb, DCArgs * args, DCValue * result, void * userdata) {
    dTHX;
#ifdef USE_ITHREADS
    PERL_SET_CONTEXT(my_perl);
#endif
    char ret_type;
    {
    dSP;
    int count;

    _callback * container = ((_callback*) userdata);
    //int * ud = (int*) container->userdata;

    SV * cb_sv = container->cb;
    AV * av_args = (AV *) dcbArgPointer(args);

    ENTER;
    SAVETMPS;
    //warn("here at %s line %d.", __FILE__, __LINE__);
    PUSHMARK(SP);
    {   const char * signature = container->signature;
        //warn("signature == %s at %s line %d.", container->signature, __FILE__, __LINE__);
        int done, okay;
        SV * arg;
        int i;
        for (i = 0; signature[i+1] != '\0'; ++i ) {
            done = okay = 0;
            //warn("here at %s line %d.", __FILE__, __LINE__);
            //warn("signature[%d] == %s at %s line %d.", i, container->signature[i], __FILE__, __LINE__);
            arg = av_shift(av_args);
            switch(signature[i]) {
                case DC_SIGCHAR_VOID:
                    //okay = SvIOK(arg);
                    break;
                case DC_SIGCHAR_BOOL:
                case DC_SIGCHAR_CHAR:
                case DC_SIGCHAR_SHORT:
                case DC_SIGCHAR_INT:
                case DC_SIGCHAR_LONG:
                case DC_SIGCHAR_LONGLONG:
                    okay = SvIOK(arg);
                    break;
                case DC_SIGCHAR_FLOAT:
                case DC_SIGCHAR_DOUBLE:
                    okay = SvNOK(arg);
                    break;
                case DC_SIGCHAR_UCHAR:
                case DC_SIGCHAR_USHORT:
                case DC_SIGCHAR_UINT:
                case DC_SIGCHAR_ULONG:
                case DC_SIGCHAR_ULONGLONG:
                    okay = SvIOK_UV(arg);
                    break;
                case DC_SIGCHAR_STRING:
                    okay = SvPOK(arg);
                    break;
                case DC_SIGCHAR_ENDARG:
                    ret_type = signature[i+1];
                    done++;
                    break;
                case DC_SIGCHAR_POINTER:
                case DC_SIGCHAR_STRUCT:
                default:
                    warn("Unknown arg type");
                    break;
            };
            if (done)
                break;
            else if (okay)
                XPUSHs(arg);
            //warn("here at %s line %d.", __FILE__, __LINE__);
        }
        //warn("here at %s line %d.", __FILE__, __LINE__);
    }
    //warn("here at %s line %d.", __FILE__, __LINE__);

    XPUSHs(container->userdata);

    PUTBACK;

    //warn("here at %s line %d.", __FILE__, __LINE__);
    //SV ** signature = hv_fetch(container, "f_signature", 11, 0);
    //warn("here at %s line %d.", __FILE__, __LINE__);
    //warn("signature was %s", signature);

    count = call_sv(cb_sv, ret_type == 'v' ? G_VOID : G_SCALAR );

    SPAGAIN;

    switch(ret_type)     {
        case DC_SIGCHAR_VOID:
            break;
        case DC_SIGCHAR_BOOL:
            if (count != 1)
                croak("Unexpected return values");
            result->B = (bool) POPi;
            break;
        case DC_SIGCHAR_CHAR:
        case DC_SIGCHAR_UCHAR:
            warn("Unhandled type at %s line %d.", __FILE__, __LINE__);
            break;
        case DC_SIGCHAR_SHORT:
            if (count != 1)
                croak("Unexpected return values");
            result->s = (short) POPi;
            warn ("short == %d", result->s);
            break;
        case DC_SIGCHAR_USHORT:
            if (count != 1)
                croak("Unexpected return values");
            result->S = (u_short) POPi;
            break;
        case DC_SIGCHAR_INT: // int
            if (count != 1)
                croak("Unexpected return values");
            result->i = POPi;
            break;
        case DC_SIGCHAR_LONG: // long
            if (count != 1)
                croak("Unexpected return values");
            result->l = POPl;
            break;
        case DC_SIGCHAR_DOUBLE: // double
            if (count != 1)
                croak("Unexpected return values");
            result->l = POPn;
            break;
        case 'p': // string
            if (count != 1)
                croak("Unexpected return values");
            result->l = POPl;
            break;
        case 'u': // uint
            if (count != 1)
                croak("Unexpected return values");
            result->l = POPu;
            break;
        case DC_SIGCHAR_STRING:
            if (count != 1)
                croak("Unexpected return values");
            result->Z = POPpx;
            break;
        //case 'a':
        //    count = call_sv(cb_sv, G_ARRAY);
            //if (count != 2)
            //    croak("Big trouble\n");

    }

    PUTBACK;
    FREETMPS;
    LEAVE;
}

    return ret_type;
}

MODULE = Dyn::Callback PACKAGE = Dyn::Callback

BOOT:
#ifdef USE_ITHREADS
    my_perl = (PerlInterpreter *) PERL_GET_CONTEXT;
#endif

DCCallback *
dcbNewCallback(const char * signature, SV * funcptr, SV * userdata);
PREINIT:
    _callback * container;
    dTHX;
#ifdef USE_ITHREADS
    PERL_SET_CONTEXT(my_perl);
#endif
CODE:
    container = malloc(sizeof(_callback));
    if (!container) // OOM
        XSRETURN_UNDEF;
    //container->interval = interval;
    container->signature = signature;
    container->cb = SvREFCNT_inc(funcptr);
    container->userdata = SvREFCNT_inc(userdata);
    int i;
    for (i = 0; container->signature[i+1] != '\0'; ++i ) {
        //warn("here at %s line %d.", __FILE__, __LINE__);
        if (container->signature[i] == ')') {
            container->ret_type = container->signature[i+1];
            break;
        }
    }
    RETVAL = dcbNewCallback(signature, callback_handler, (void *) container);
OUTPUT:
    RETVAL

void
dcbInitCallback(DCCallback * pcb, const char * signature, DCCallbackHandler * funcptr, void * userdata);

void
dcbFreeCallback(DCCallback * pcb);

void
dcbGetUserData(DCCallback * pcb);

=pod

Less Perl, more C.

=cut

SV *
call(DCCallback * self, ... )
PREINIT:
    dTHX;
#ifdef USE_ITHREADS
    PERL_SET_CONTEXT(my_perl);
#endif
    AV * args = newAV();
CODE:
    _callback * container = ((_callback*) dcbGetUserData(self));
    int i;
    for (i = 1; i < items; ++i)
        av_push(args, ST(i));
    //AV * args = newSV();
    switch(container->ret_type) {
        case DC_SIGCHAR_VOID:
            ((void(*)(AV*))self)(args);
            XSRETURN_UNDEF;
            break;
        case DC_SIGCHAR_STRING:
            RETVAL = newSVpv(((const char *(*)(AV*))self)(args), 0);
            break;
        case DC_SIGCHAR_INT:
            RETVAL = newSViv(((int(*)(AV*))self)(args));
            break;
        case DC_SIGCHAR_SHORT:
            RETVAL = newSViv(((short(*)(AV*))self)(args));
            break;
        default:
            warn("Unhandled return type [%c] at %s line %d.", container->ret_type, __FILE__, __LINE__);
            XSRETURN_UNDEF;
            break;
    }
OUTPUT:
    RETVAL

void
Ximport( const char * package, ... )
CODE:
    const PERL_CONTEXT * cx_caller = caller_cx( 0, NULL );
    char *caller = HvNAME((HV*) CopSTASH(cx_caller->blk_oldcop));

    warn("Import from %s! items == %d", caller, items);

    int item;
    for (item = 1; item < items; ++item)
        warn("  item %d: %s", item, SvPV_nolen(ST(item)));

    //export_sub(ctx_stash, caller_stash, name);

=pod

OO version below

=cut

DCCallback *
Dyn::Callback::new(const char * signature, CV * funcptr, void * userdata)
CODE:
    //RETVAL = dcbNewCallback(signature, funcptr, userdata);
    RETVAL = dcbNewCallback(signature, callback_handler, userdata);
OUTPUT:
    RETVAL

void
userdata( DCCallback * self )
CODE:
    dcbGetUserData( self );

void
DESTROY(DCCallback * self)
CODE:
    dcbFreeCallback( self );
