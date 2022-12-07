LIBDIR := lib
include $(LIBDIR)/main.mk

$(LIBDIR)/main.mk:
ifneq (,$(shell grep "path *= *$(LIBDIR)" .gitmodules 2>/dev/null))
	git submodule sync
	git submodule update $(CLONE_ARGS) --init
else
	git clone -q --depth 10 $(CLONE_ARGS) \
	    -b main https://github.com/martinthomson/i-d-template $(LIBDIR)
endif

include cddl/ear-json-frags.mk

define cddl_targets

$(drafts_xml):: cddl/$(1)-autogen.cddl

cddl/$(1)-autogen.cddl: $(addprefix cddl/,$(2)) $(addprefix cddl/examples/,$(3))
	$(MAKE) -C cddl check-$(1) check-$(1)-examples

endef # cddl_targets

$(eval $(call cddl_targets,ear-json,$(EAR_JSON_FRAGS),$(EAR_JSON_EXAMPLES)))

clean:: ; $(MAKE) -C cddl clean
