#include <dyncall.h>
#include <dynload.h>

typedef struct
{
    DLLib *lib;
    void *syms;
    DCCallVM *cvm;
} Dyncall;

typedef struct
{
    const char *name;
    const char *sig;
    const char *ret;
    DCpointer *fptr;
    Dyncall *lib;
} DynXSub;
