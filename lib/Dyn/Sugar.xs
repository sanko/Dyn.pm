#include "lib/xshelper.h"

#define dcAllocMem Newxz
#define dcFreeMem  Safefree

// Based on https://github.com/svn2github/dyncall/blob/master/bindings/ruby/rbdc/rbdc.c

#include <dynload.h>
#include <dyncall.h>
#include <dyncall_value.h>
#include <dyncall_callf.h>
#include <dyncall_signature.h>
#include <dyncall_callback.h>
//#include <dyncall/dyncall_signature.h>

#include "lib/types.h"

#ifdef OBJECT_PAD

struct ClassWrapper {
    DCCallVM * cvm;
    DCstruct * dcs;
    const char * hi;
};

#include "object_pad.h"
static bool struct_apply(pTHX_ ClassMeta *classmeta, SV *hookdata, SV **hookdata_ptr, void *_funcdata) {
  warn("struct_apply");

  struct ClassWrapper *data;
  Newx(data, 1, struct ClassWrapper);
  data->cvm = dcNewCallVM( 1024 );
    data->hi = "Fun!";

    _funcdata = data;

  //mop_class_apply_attribute(classmeta, "strict",  sv_2mortal(newSVpvs("params")));
  //mop_class_apply_attribute(classmeta, "Trigger", sv_2mortal(newSVpvs("params")));
  return TRUE;
}

static void struct_post_add_slot(pTHX_ ClassMeta *classmeta, SV *hookdata, void *_funcdata, SlotMeta *slotmeta)
{warn("struct_post_add_slot");

    struct ClassWrapper * clw = (struct ClassWrapper*) _funcdata;
    //warn("Here: %s", clw->hi);

  if(mop_slot_get_sigil(slotmeta) != '$')
    return;

  mop_slot_apply_attribute(slotmeta, "param", NULL);
  mop_slot_apply_attribute(slotmeta, "mutator", NULL);
}


static void final_post_construct(pTHX_ SlotMeta *slotmeta, SV *_hookdata, void *_funcdata, SV *slot)
{
    warn("final_post_construct");
  //SvREADONLY_on(slot);
}

static void final_seal(pTHX_ SlotMeta *slotmeta, SV *hookdata, void *_funcdata)
{
    warn("final_seal");
  if(mop_slot_get_attribute(slotmeta, "writer"))
    warn("Applying :Final attribute to slot %" SVf " which already has :writer", SVfARG(mop_slot_get_name(slotmeta)));
}

static const struct ClassHookFuncs struct_hooks = {
  .ver   = OBJECTPAD_ABIVERSION,
  .flags = OBJECTPAD_FLAG_ATTR_NO_VALUE,
  .permit_hintkey = "Dyn::Sugar/Native",

  .apply         = &struct_apply,
  .post_add_slot = &struct_post_add_slot
};

struct Data {
  unsigned int is_weak : 1;
  SV *slotname;
  SV *classname;
};

static int magic_set(pTHX_ SV *sv, MAGIC *mg)
{
  struct Data *data = (struct Data *)mg->mg_ptr;
  SV *savesv = mg->mg_obj;

  bool ok = sv_derived_from_sv(sv, data->classname, 0);

  if(ok) {
    sv_setsv(savesv, sv);
    if(data->is_weak)
      sv_rvweaken(savesv);
    return 1;
  }

  /* Restore last known-good value */
  sv_setsv_nomg(sv, savesv);
  if(data->is_weak)
    sv_rvweaken(sv);

  croak("Slot %" SVf " requires an object of type %" SVf,
    SVfARG(data->slotname), SVfARG(data->classname));

  return 1;
}

static const MGVTBL vtbl = {
  .svt_set = &magic_set,
};

static bool isa_apply(pTHX_ SlotMeta *slotmeta, SV *value, SV **hookdata_ptr, void *_funcdata)
{
  struct Data *data;
  Newx(data, 1, struct Data);

  data->is_weak   = false;
  data->slotname  = SvREFCNT_inc(mop_slot_get_name(slotmeta));
  data->classname = SvREFCNT_inc(value);

  *hookdata_ptr = (SV *)data;

  return TRUE;
}

static void isa_seal(pTHX_ SlotMeta *slotmeta, SV *hookdata, void *_funcdata)
{
  struct Data *data = (struct Data *)hookdata;

  if(mop_slot_get_attribute(slotmeta, "weak"))
    data->is_weak = true;
}

static void isa_post_initslot(pTHX_ SlotMeta *slotmeta, SV *hookdata, void *_funcdata, SV *slot)
{
  sv_magicext(slot, newSV(0), PERL_MAGIC_ext, &vtbl, (char *)hookdata, 0);
}

static const struct SlotHookFuncs isa_hooks = {
  .ver   = OBJECTPAD_ABIVERSION,
  .flags = OBJECTPAD_FLAG_ATTR_MUST_VALUE,
  .permit_hintkey = "Dyn::Sugar/Isa",

  .apply         = &isa_apply,
  .seal_slot     = &isa_seal,
  .post_initslot = &isa_post_initslot,
};

#endif

MODULE = Dyn::Sugar   PACKAGE = Dyn::Sugar

BOOT:
{
#ifdef OBJECT_PAD
    // TODO: Link with Windows
    register_slot_attribute("Isa", &isa_hooks, NULL);
    //register_slot_attribute("Trigger", &trigger_hooks, NULL);
    register_class_attribute("Native", &struct_hooks, NULL);
#endif
}

