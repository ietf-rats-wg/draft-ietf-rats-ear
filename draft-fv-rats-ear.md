---
title: "EAT Attestation Results"
abbrev: "EAR"
category: std

docname: draft-fv-rats-ear-latest
submissiontype: IETF
number:
date:
consensus: true
v: 3
area: "Security"
workgroup: "Remote ATtestation ProcedureS"
keyword:
 - EAT
 - attestation result
 - attestation verifier
 - AR4SI
venue:
  group: "Remote ATtestation ProcedureS"
  type: "Working Group"
  mail: "rats@ietf.org"
  arch: "https://mailarchive.ietf.org/arch/browse/rats/"
  github: "thomas-fossati/draft-ear"
  latest: "https://thomas-fossati.github.io/draft-ear/draft-fv-rats-ear.html"

author:
 -
    fullname: Thomas Fossati
    organization: ARM Limited
    email: thomas.fossati@arm.com
 -
    fullname: Eric Voit
    organization: Cisco
    email: evoit@cisco.com

normative:

informative:

--- abstract

TODO Abstract

--- middle

# Introduction

TODO Introduction

# Conventions and Definitions

{::boilerplate bcp14-tagged}

# EAT Attestation Result

~~~cddl
{::include cddl/attestation-result.cddl}
~~~

## JSON Serialisation

~~~cddl
{::include cddl/json-labels.cddl}
~~~

### Examples

~~~cbor-diag
{::include cddl/examples/ear-json-1.diag}
~~~

## CBOR Serialisation

~~~cddl
{::include cddl/cbor-labels.cddl}
~~~

### Examples

~~~cbor-diag
{::include cddl/examples/ear-cbor-1.diag}
~~~

## Extensions

TODO

# Security Considerations

TODO Security

# IANA Considerations

This document has no IANA actions.

--- back

# Acknowledgments
{:numbered="false"}

TODO acknowledge.
