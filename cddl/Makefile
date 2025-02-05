.DEFAULT_GOAL := check

SHELL := /bin/bash

include cddl_check_template.mk

include base-files.mk
include ext-veraison-files.mk
include ext-teep-files.mk

check:: check-ear-base check-ear-base-examples
check:: check-ear-ext-veraison check-ear-ext-veraison-examples
check:: check-ear-ext-teep check-ear-ext-teep-examples

$(eval $(call cddl_check_template,ear-base,$(EAR_BASE_FRAGS),$(EAR_BASE_EXAMPLES)))
$(eval $(call cddl_check_template,ear-ext-veraison,$(EAR_EXT_VERAISON_FRAGS),$(EAR_EXT_VERAISON_EXAMPLES)))
$(eval $(call cddl_check_template,ear-ext-teep,$(EAR_EXT_TEEP_FRAGS),$(EAR_EXT_TEEP_EXAMPLES)))

clean: ; rm -f $(CLEANFILES)
