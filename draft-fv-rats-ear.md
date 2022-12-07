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
pi: [toc, sortrefs, symrefs]

author:
- name: Thomas Fossati
  org: Arm Limited
  email: thomas.fossati@arm.com
- name: Eric Voit
  org: Cisco
  email: evoit@cisco.com
- name: Sergei Trofimov
  org: Arm Limited
  email: sergei.trofimov@arm.com

normative:
  RFC7519: jwt
  RFC8392: cwt
  RFC8610: cddl
  STD94:
    -: cbor
    =: RFC8949
  STD96:
    -: cose
    =: RFC9052
  I-D.ietf-rats-ar4si: ar4si
  I-D.ietf-rats-architecture: rats-arch
  I-D.ietf-rats-eat: eat

informative:
  RFC7942: impl-status
  RFC4151: tag-uri

entity:
  SELF: "RFCthis"

--- abstract

This document defines the EAT Attestation Result (EAR) message format.

EAR is used by a verifier to encode the result of the appraisal over an
attester's evidence.
It embeds an AR4SI's "trustworthiness vector" to present a normalized view of
the evaluation results, thus easing the task of defining and computing
authorization policies by relying parties.
Alongside the trustworthiness vector, EAR provides contextual information bound
to the appraisal process.
This allows a relying party (or an auditor) to reconstruct the frame of
reference in which the trustworthiness vector was originally computed.
EAR can also accommodate per-application and per-deployment extensions.
It can be serialized and protected using either CWT or JWT.

--- middle

# Introduction

This document defines the EAT {{-eat}} Attestation Result (EAR) message format.

EAR is used by a verifier to encode the result of the appraisal over an
attester's evidence.
It embeds an AR4SI's "trustworthiness vector" {{-ar4si}} to present a
normalized view of the evaluation results, thus easing the task of defining and
computing authorization policies by relying parties.
Alongside the trustworthiness vector, EAR provides contextual information bound
to the appraisal process.
This allows a relying party (or an auditor) to reconstruct the frame of
reference in which the trustworthiness vector was originally computed.
EAR can also accommodate per-application and per-deployment extensions.
It can be serialized and protected using either CWT {{-cwt}} or JWT {{-jwt}}.

# Conventions and Definitions

This document uses terms and concepts defined by the RATS architecture.
For a complete glossary see {{Section 4 of -rats-arch}}.

The terminology from CBOR {{-cbor}}, CDDL {{-cddl}} and COSE {{-cose}} applies;
in particular, CBOR diagnostic notation is defined in {{Section 8 of -cbor}}
and {{Section G of -cddl}}.

{::boilerplate bcp14-tagged}

# EAT Attestation Result {#sec-ear}

EAR is an EAT token which can be serialized as JWT {{-jwt}} or CWT {{-cwt}}.

The EAR claims-set is as follows:

~~~cddl
{::include cddl/attestation-result.cddl}
~~~
{: #fig-cddl-ear title="EAR (CDDL Definition)" }

Where:

{:vspace}
`ear.status` (mandatory)
: The overall appraisal status represented as one of the four trustworthiness tiers ({{sec-trusttiers}}).
If the `ear.trustworthiness-vector` claim is also present, the value of this claim MUST be set to the tier corresponding to the worst trustworthiness claim across the entire trustworthiness vector.

`eat_profile` (mandatory)
: The EAT profile ({{Section 6 of -eat}}) associated with the EAR claims-set and encodings defined by this document.
It MUST be the following tag URI ({{-tag-uri}}) `tag:github.com,2022:veraison/ear`.

`ear.trustworthiness-vector` (optional)
: The AR4SI trustworthiness vector providing the breakdown of the appraisal.
See {{sec-tvector}} for the details.

`ear.raw-evidence` (optional)
: The unabridged evidence submitted for appraisal.

`iat` (mandatory)
: The time at which the EAR is issued.
See {{Section 4.1.6 of -jwt}} and {{Section 4.3.1 of -eat}} for the EAT-specific encoding restrictions (i.e., disallowing the floating point representation).

`ear.appraisal-policy-id` (optional)
: An unique identifier of the appraisal policy used to compute the attestation result.

`$$ear-extension` (optional)
: Any application- or deployment-specific extension.
An EAR extension MUST be a map.
See {{sec-extensions}} for further details.

## Trustworthiness Vector {#sec-tvector}

The `ar4si-trustworthiness-vector` claim is an embodiment of the AR4SI trustworthiness vector ({{Section 2.3.5 of -ar4si}}) and it is defined as follows:

~~~cddl
{::include cddl/trustworthiness-vector.cddl}
~~~
{: #fig-cddl-tvec title="Trustworthiness Vector (CDDL Definition)" }

It contains an entry for each one of the eight AR4SI appraisals that have been conducted on the submitted evidence ({{Section 2.3.4 of -ar4si}}).
The value of each entry is chosen in the -128..127 range according to the rules described in {{Sections 2.3.3 and 2.3.4 of -ar4si}}.
All categories are optional.
A missing entry means that the verifier makes no claim about this specific appraisal facet because the category is not applicable to the submitted evidence.
As required by the `non-empty` macro, at least one entry MUST be present in the vector.

## Trust Tiers {#sec-trusttiers}

The trust tier type represents one of the equivalency classes in which the `$ar4si-trustworthiness-claim` space is partitioned.
See {{Section 2.3.2 of -ar4si}} for the details.
The allowed values for the type are as follows:

~~~cddl
{::include cddl/trust-tiers.cddl}
~~~
{: #fig-cddl-ttiers title="Trustworthiness Tiers (CDDL Definition)" }

## JSON Serialisation

To serialize the EAR claims-set in JSON format, the following substitutions are applied to the encoding-agnostic CDDL definitions in {{sec-ear}}, {{sec-tvector}} and {{sec-trusttiers}}:

~~~cddl
{::include cddl/json-labels.cddl}
~~~

### Examples

The example in {{fig-ex-json-1}} shows an EAR claims-set corresponding to a "contraindicated" appraisal, meaning the verifier has found some problems with the attester's state reported in the submitted evidence.
Specifically, the identified issue is related to unauthorized code or configuration loaded in runtime memory (i.e., value 96 in the executables category).

~~~cbor-diag
{::include cddl/examples/ear-json-1.diag}
~~~
{: #fig-ex-json-1 title="JSON claims-set: contraindicated appraisal" }

The breakdown of the trustworthiness vector is as follows:

* Instance Identity (affirming): recognized and not compromised
* Configuration (warning): known vulnerabilities
* Executables (contraindicated): contraindicated run-time
* File System (none): no claim being made
* Hardware (affirming): genuine
* Runtime Opaque (none): no claim being made
* Storage Opaque (none): no claim being made
* Sourced Data (none): no claim being made

The example in {{fig-ex-json-2}} is a minimalist (successful) attestation result that doesn't carry a trustworthiness vector.

~~~cbor-diag
{::include cddl/examples/ear-json-2.diag}
~~~
{: #fig-ex-json-2 title="JSON claims-set: simple affirming appraisal" }

## CBOR Serialisation

~~~cddl
{::include cddl/cbor-labels.cddl}
~~~

### Examples

~~~cbor-diag
{::include cddl/examples/ear-cbor-1.diag}
~~~

## Extensions {#sec-extensions}

TODO

# Implementation Status

This section records the status of known implementations of the protocol
defined by this specification at the time of posting of this Internet-Draft,
and is based on a proposal described in {{-impl-status}}.
The description of implementations in this section is intended to assist the
IETF in its decision processes in progressing drafts to RFCs.
Please note that the listing of any individual implementation here does not
imply endorsement by the IETF.
Furthermore, no effort has been spent to verify the information presented here
that was supplied by IETF contributors.
This is not intended as, and must not be construed to be, a catalog of
available implementations or their features.
Readers are advised to note that other implementations may exist.

According to {{-impl-status}}, "this will allow reviewers and working groups to
assign due consideration to documents that have the benefit of running code,
which may serve as evidence of valuable experimentation and feedback that have
made the implemented protocols more mature.
It is up to the individual working groups to use this information as they see
fit".

## `github.com/veraison/ear`

The organization responsible for this implementation is Veraison, a Linux
Foundation project hosted at the Confidential Computing Consortium.
The software, hosted at [](https://github.com/veraison/ear), provides a Golang
package that allows encoding, decoding, signing and verification of EAR
payloads together with a CLI (`arc`) to create, verify and visualize EARs on
the command line.
The maturity level is currently alpha, and only the JWT serialization is
implemented.
The license is Apache 2.0.
The developers can be contacted on the Zulip channel:
[](https://veraison.zulipchat.com/#narrow/stream/357929-EAR/).
The package is used by the Veraison verifier to produce attestation results.

# Security Considerations

TODO Security

# IANA Considerations

This document has no IANA actions.

--- back

# Acknowledgments
{:numbered="false"}

TODO acknowledge.
