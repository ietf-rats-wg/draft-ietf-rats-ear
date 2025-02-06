cddl ?= $(shell command -v cddl)
ifeq ($(strip $(cddl)),)
$(error cddl not found. To install cddl: 'gem install cddl')
endif

cddlc ?= $(shell command -v cddlc)
ifeq ($(strip $(cddlc)),)
$(error cddlc not found. To install cddlc: 'gem install cddlc')
endif

diag2cbor ?= $(shell command -v diag2cbor.rb)
ifeq ($(strip $(diag2cbor)),)
$(error diag2cbor.rb not found. To install diag2cbor.rb: 'gem install cbor-diag')
endif

diag2diag ?= $(shell command -v diag2diag.rb)
ifeq ($(strip $(diag2diag)),)
$(error diag2diag.rb not found. To install diag2diag.rb: 'gem install cbor-diag')
endif
