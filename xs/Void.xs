#include "xshelper.h"

#define MY_CXT_KEY "Void::_guts" XS_VERSION
typedef struct {
    SV* hintkey_sv;
    int (*next_keyword_plugin)(pTHX_ char *, STRLEN, OP **);
} my_cxt_t;
START_MY_CXT

#define parse_keyword() THX_parse_keyword(aTHX)
static OP*
THX_parse_keyword(pTHX) {
    OP* const o = parse_fullstmt(0);
    return NULL;
}


/* the following stuff are stolen from perl/ext/XS-APITest-RPNKeyword */

#define keyword_active(hintkey_sv) THX_keyword_active(aTHX_ hintkey_sv)
static int THX_keyword_active(pTHX_ SV *hintkey_sv)
{
	HE *he;
	if(!GvHV(PL_hintgv)) return 0;
	he = hv_fetch_ent(GvHV(PL_hintgv), hintkey_sv, 0,
				SvSHARED_HASH(hintkey_sv));
	return he && SvTRUE(HeVAL(he));
}

#define keyword_enable(hintkey_sv) THX_keyword_enable(aTHX_ hintkey_sv)
static void THX_keyword_enable(pTHX_ SV *hintkey_sv)
{
	SV *val_sv = newSViv(1);
	HE *he;
	PL_hints |= HINT_LOCALIZE_HH;
	gv_HVadd(PL_hintgv);
	he = hv_store_ent(GvHV(PL_hintgv),
		hintkey_sv, val_sv, SvSHARED_HASH(hintkey_sv));
	if(he) {
		SV *val = HeVAL(he);
		SvSETMAGIC(val);
	} else {
		SvREFCNT_dec(val_sv);
	}
}

#define keyword_disable(hintkey_sv) THX_keyword_disable(aTHX_ hintkey_sv)
static void THX_keyword_disable(pTHX_ SV *hintkey_sv)
{
	if(GvHV(PL_hintgv)) {
		PL_hints |= HINT_LOCALIZE_HH;
		(void)hv_delete_ent(GvHV(PL_hintgv),
			hintkey_sv, G_DISCARD, SvSHARED_HASH(hintkey_sv));
	}
}

static int my_keyword_plugin(pTHX_
	char *keyword_ptr, STRLEN keyword_len, OP **op_ptr)
{
    dMY_CXT;
	if(keyword_len == strlen("void") &&
			strEQ(keyword_ptr, "void") &&
			keyword_active(MY_CXT.hintkey_sv)) {
		*op_ptr = parse_keyword();
		return KEYWORD_PLUGIN_STMT;
	} else {
		return MY_CXT.next_keyword_plugin(aTHX_
				keyword_ptr, keyword_len, op_ptr);
	}
}

static void
my_cxt_initialize(pTHX_ pMY_CXT) {
	MY_CXT.hintkey_sv = newSVpvs_share("Void/void");
	MY_CXT.next_keyword_plugin = PL_keyword_plugin;
	PL_keyword_plugin          = my_keyword_plugin;
}

MODULE = Void    PACKAGE = Void

PROTOTYPES: DISABLE

BOOT:
{
    MY_CXT_INIT;
    my_cxt_initialize(aTHX_ aMY_CXT);
}

#ifdef USE_ITHREADS

void
CLONE(...)
CODE:
{
    MY_CXT_CLONE;
    my_cxt_initialize(aTHX_ aMY_CXT);
    PERL_UNUSED_VAR(items);
}

#endif

void
import(classname)
PPCODE:
{
    dMY_CXT;
    keyword_enable(MY_CXT.hintkey_sv);
}

void
unimport(classname)
PPCODE:
{
    dMY_CXT;
    keyword_disable(MY_CXT.hintkey_sv);
}

