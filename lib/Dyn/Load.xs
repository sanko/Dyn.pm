#include "lib/xshelper.h"

#include <dynload.h>
#include <dyncall.h>
#include <dyncall_value.h>
#include <dyncall_callf.h>
#include <dyncall_signature.h>
#include <dyncall_callback.h>

#include "lib/types.h"

MODULE = Dyn::Load PACKAGE = Dyn::Load

DLLib *
dlLoadLibrary(const char * libpath)

void
dlFreeLibrary(DLLib * pLib)

DCpointer
dlFindSymbol(DLLib * pLib, const char * pSymbolName);

int
dlGetLibraryPath(DLLib * pLib, char * sOut, int bufSize);

DLSyms *
dlSymsInit(const char * libPath);

void
dlSymsCleanup(DLSyms * pSyms);

int
dlSymsCount(DLSyms * pSyms);

const char*
dlSymsName(DLSyms * pSyms, int index);

const char*
dlSymsNameFromValue(DLSyms * pSyms, void * value)
