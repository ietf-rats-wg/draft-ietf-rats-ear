.DEFAULT_GOAL := svgs

aasvg ?= $(shell command -v aasvg)
ifeq ($(strip $(aasvg)),)
$(error required aasvg not found. To install aasvg see https://github.com/martinthomson/aasvg#usage)
endif

%.svg: %.aa ; $(aasvg) < $< > $@

AA_FILES := $(wildcard *.aa)

SVG_FILES := $(AA_FILES:.aa=.svg)

svgs: $(SVG_FILES)

.PHONY: svgs

clean: ; $(RM) $(SVG_FILES)
