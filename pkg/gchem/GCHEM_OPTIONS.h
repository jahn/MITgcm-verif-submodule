C $Header$
C $Name$

#ifndef GCHEM_OPTIONS_H
#define GCHEM_OPTIONS_H
#include "PACKAGES_CONFIG.h"
#ifdef ALLOW_GCHEM

#include "CPP_OPTIONS.h"

CBOP
C    !ROUTINE: GCHEM_OPTIONS.h
C    !INTERFACE:

C    !DESCRIPTION:
c options for biogeochemistry package
CEOP

#ifdef ALLOW_PTRACERS
#define PTRACERS_SEPARATE_FORCING
#endif
#define DIC_BIOTIC
#undef  ALLOW_CFC
#undef  ALLOW_FE

#endif /* ALLOW_GCHEM */
#endif /* GCHEM_OPTIONS_H */
