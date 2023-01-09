.DEFAULT_GOAL := check

SHELL := /bin/bash

%.cbor: %.diag ; diag2cbor.rb $< > $@

include tools.mk

check:: check-ear-json check-ear-json-examples
check:: check-ear-cbor check-ear-cbor-examples

# $1: label
# $2: cddl fragments
# $3: (optional) diag test files
define cddl_check_template

check-$(1): $(1)-autogen.cddl
	$$(cddl) $$< g 1 | $$(diag2diag) -e

.PHONY: check-$(1)

$(1)-autogen.cddl: $(2)
	for f in $$^ ; do ( grep -v '^;' $$$$f ; echo ) ; done > $$@

CLEANFILES += $(1)-autogen.cddl

check-$(1)-examples: $(1)-autogen.cddl $(3:.diag=.cbor)
	@for f in $(3:.diag=.cbor); do \
		echo ">> validating $$$$f" ; \
		$$(cddl) $$< validate $$$$f || exit 1; \
	done

.PHONY: check-$(1)-examples

CLEANFILES += $(3:.diag=.cbor)

endef # cddl_check_template

include ear-json-frags.mk
include ear-cbor-frags.mk

$(eval $(call cddl_check_template,ear-json,$(EAR_JSON_FRAGS),$(EAR_JSON_EXAMPLES)))
$(eval $(call cddl_check_template,ear-cbor,$(EAR_CBOR_FRAGS),$(EAR_CBOR_EXAMPLES)))

clean: ; rm -f $(CLEANFILES)
