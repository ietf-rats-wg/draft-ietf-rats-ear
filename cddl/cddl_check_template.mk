include tools.mk

%.cbor: %.diag ; $(diag2cbor) $< > $@

# $1: label
# $2: cddl fragments
# $3: (optional) diag test files
define cddl_check_template

check-$(1): $(1)-autogen.cddl
	$$(cddl) $$< g 1 | $$(diag2diag) -e

.PHONY: check-$(1)

$(1)-autogen.cddl: $(2)
	$(cddlc) -u -2 -t cddl -i untagged-coswid -i rfc9393 -i rfc9711 $$^ > $$@

CLEANFILES += $(1)-autogen.cddl

check-$(1)-examples: $(1)-autogen.cddl $(3:.diag=.cbor)
	@for f in $(3:.diag=.cbor); do \
		echo ">> validating $$$$f" ; \
		$$(cddl) $$< validate $$$$f || exit 1; \
	done

.PHONY: check-$(1)-examples

CLEANFILES += $(3:.diag=.cbor)

endef # cddl_check_template
