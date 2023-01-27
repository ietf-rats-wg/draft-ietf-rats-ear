EAR_CBOR_FRAGS := ear.cddl
EAR_CBOR_FRAGS += ear-appraisal.cddl
EAR_CBOR_FRAGS += verifier-id.cddl
EAR_CBOR_FRAGS += trustworthiness-vector.cddl
EAR_CBOR_FRAGS += trust-tiers.cddl
EAR_CBOR_FRAGS += veraison.cddl
EAR_CBOR_FRAGS += veraison-cbor-labels.cddl
EAR_CBOR_FRAGS += teep.cddl
EAR_CBOR_FRAGS += cbor-labels.cddl
EAR_CBOR_FRAGS += teep-cbor-labels.cddl
EAR_CBOR_FRAGS += base64-url-text.cddl
EAR_CBOR_FRAGS += generic-non-empty.cddl
EAR_CBOR_FRAGS += coswid-version-scheme.cddl

EAR_CBOR_EXAMPLES := $(wildcard examples/*-cbor-*.diag)
