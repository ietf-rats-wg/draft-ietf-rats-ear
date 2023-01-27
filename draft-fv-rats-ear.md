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
  I-D.ietf-rats-eat: eat
  I-D.ietf-teep-protocol: teep
  I-D.ietf-rats-eat-media-type: eat-media-type

informative:
  RFC9334: rats-arch
  RFC7942: impl-status
  RFC4151: tag-uri
  IANA.cwt:
  IANA.jwt:

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
EAR supports simple devices with one attester as well as composite devices that
are made of multiple attesters, allowing the state of each attester to be
separately examined.
EAR can also accommodate registered and unregistered extensions.
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
EAR supports simple devices with one attester as well as composite devices that
are made of multiple attesters (see {{Section 3.3 of -rats-arch}}) allowing the
state of each attester to be separately examined.
EAR can also accommodate registered and unregistered extensions.
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
{::include cddl/ear.cddl}
~~~
{: #fig-cddl-ear title="EAR (CDDL Definition)" }

Where:

`eat.profile` (mandatory)
: The EAT profile ({{Section 6 of -eat}}) associated with the EAR claims-set
and encodings defined by this document.
It MUST be the following tag URI ({{-tag-uri}})
`tag:github.com,2023:veraison/ear`.

`iat` (mandatory)
: "Issued At" claim -- the time at which the EAR is issued.
See {{Section 4.1.6 of -jwt}} and {{Section 4.3.1 of -eat}} for the
EAT-specific encoding restrictions (i.e., disallowing the floating point
representation).

`ear.verifier-id` (mandatory)
: Identifying information about the appraising verifier.
See {{sec-verifier-id}} for further details on its structure and serialization.

`ear.raw-evidence` (optional)
: The unabridged evidence submitted for appraisal, including any signed
container/envelope.

`eat.submods` (mandatory)
: A submodule map ({{Section 4.2.18 of -eat}}) holding one `EAR-appraisal` for
each separately appraised attester.
The map MUST contain at least one entry.
For each appraised attester the verifier chooses a unique label.
For example, when evidence is in EAT format, the label could be constructed
from the associated EAT profile.
A verifier SHOULD publicly and permanently document its labelling scheme for
each supported evidence type, unless EAR payloads are produced and consumed
entirely within a private deployment.
See {{sec-ear-appraisal}} for the details about the contents of an
`EAR-appraisal`.

`$$ear-extension` (optional)
: Any registered or unregistered extension.
An EAR extension MUST be a map.
See {{sec-extensions}} for further details.

## Verifier Software Identification {#sec-verifier-id}

{{Section 2.2.2 of -ar4si}} defines an information model for identifying the
software that runs the verifier.  The `ar4si.verifier-id` claim provides its
serialization as follows:

~~~cddl
{::include cddl/verifier-id.cddl}
~~~
{: #fig-cddl-verifier-id title="Verifier Software Identification Claim (CDDL Definition)" }

Where:

`build` (mandatory)
: A text string that uniquely identifies the software build running the verifier.

`developer` (mandatory)
: A text string that uniquely identifies the organizational unit responsible
for this `build`.

## EAR Appraisal Claims {#sec-ear-appraisal}

~~~cddl
{::include cddl/ear-appraisal.cddl}
~~~
{: #fig-cddl-ear-appraisal title="EAR Appraisal Claims (CDDL Definition)" }

{:vspace}
`ear.status` (mandatory)
: The overall appraisal status for this attester represented as one of the four
trustworthiness tiers ({{sec-trusttiers}}).
The value of this claim MUST be set to a tier of no higher trust than the tier
corresponding to the worst trustworthiness claim across the entire
trustworthiness vector.

`ear.trustworthiness-vector` (optional)
: The AR4SI trustworthiness vector providing the breakdown of the appraisal for
this attester.
See {{sec-tvector}} for the details.
This claim MUST be present unless the party requesting Evidence appraisal
explicitly asks for it to be dropped, e.g., via an API parameter or similar
arrangement.  Such consumer would therefore rely entirely on the semantics of
the `ear.status` claim.  This behaviour is NOT RECOMMENDED because of the
resulting loss of quality of the appraisal result.

`ear.appraisal-policy-id` (optional)
: An unique identifier of the appraisal policy used to evaluate the attestation
result.

`$$ear-appraisal-extension` (optional)
: Any registered or unregistered extension.
An EAR appraisal extension MUST be a map.
See {{sec-extensions}} for further details.

### Trustworthiness Vector {#sec-tvector}

The `ar4si-trustworthiness-vector` claim is an embodiment of the AR4SI
trustworthiness vector ({{Section 2.3.5 of -ar4si}}) and it is defined as
follows:

~~~cddl
{::include cddl/trustworthiness-vector.cddl}
~~~
{: #fig-cddl-tvec title="Trustworthiness Vector (CDDL Definition)" }

It contains an entry for each one of the eight AR4SI appraisals that have been
conducted on the submitted evidence ({{Section 2.3.4 of -ar4si}}).
The value of each entry is chosen in the -128..127 range according to the rules
described in {{Sections 2.3.3 and 2.3.4 of -ar4si}}.
All categories are optional.
A missing entry means that the verifier makes no claim about this specific
appraisal facet because the category is not applicable to the submitted
evidence.
As required by the `non-empty` macro, at least one entry MUST be present in the
vector.

### Trust Tiers {#sec-trusttiers}

The trust tier type represents one of the equivalency classes in which the
`$ar4si-trustworthiness-claim` space is partitioned.
See {{Section 2.3.2 of -ar4si}} for the details.
The allowed values for the type are as follows:

~~~cddl
{::include cddl/trust-tiers.cddl}
~~~
{: #fig-cddl-ttiers title="Trustworthiness Tiers (CDDL Definition)" }

## JSON Serialisation

To serialize the EAR claims-set in JSON format, the following substitutions are
applied to the encoding-agnostic CDDL definitions in {{sec-ear}},
{{sec-tvector}} and {{sec-trusttiers}}:

~~~cddl
{::include cddl/json-labels.cddl}
~~~

### Examples

The example in {{fig-ex-json-1}} shows an EAR claims-set corresponding to a
"contraindicated" appraisal, meaning the verifier has found some problems with
the attester's state reported in the submitted evidence.
Specifically, the identified issue is related to unauthorized code or
configuration loaded in runtime memory (i.e., value 96 in the executables
category).
The appraisal is for a device with one attester labelled "PSA".  Note that in
case there is only one attester, the labelling can be freely chosen because
there is no ambiguity.

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

The example in {{fig-ex-json-2}} contains the appraisal for a composite device
with two attesters named "CCA Platform" and "CCA Realm" respectively.
Both attesters have either "affirming" or (implicit) "none" values in their
associated trustworthiness vectors.
Note that the "none" values can refer to either an AR4SI category that is
unapplicable for the specific attester (ideally, the applicability should be
specified by the evidence format itself), or to the genuine lack of information
at the attester site regarding the specific category.  For example, the
reference values for the "CCA Realm" executables (i.e., the confidential
computing workload) may not be known to the CCA platform verifier.
In such cases, it is up to the downstream entity (typically, the relying party)
to complete the partial appraisal.

~~~cbor-diag
{::include cddl/examples/ear-json-2.diag}
~~~
{: #fig-ex-json-2 title="JSON claims-set: simple affirming appraisal" }

## CBOR Serialisation

~~~cddl
{::include cddl/cbor-labels.cddl}
~~~

### Examples

The example in {{fig-ex-cbor-1}} is semantically equivalent to that in
{{fig-ex-json-1}}.  It shows the same "contraindicated" appraisal using the
more compact CBOR serialization of the EAR claims-set.

~~~cbor-diag
{::include cddl/examples/ear-cbor-1.diag}
~~~
{: #fig-ex-cbor-1 title="CBOR claims-set: contraindicated appraisal" }


# EAR Extensions {#sec-extensions}

EAR provides core semantics for describing the result of appraising attestation
evidence.
However, a given application may offer extra functionality to its relying
parties, or tailor the attestation result to the needs of the application (e.g.,
TEEP {{-teep}}).
To accommodate such cases, both `EAR` and `EAR-appraisal` claims-sets can be
extended by plugging new claims into the `$$ear-extension` (or
`$$ear-appraisal-extension`, respectively) CDDL socket.

The rules that govern extensibility of EAR are those defined in {{-cwt}} and
{{-jwt}} for CWTs and JWTs respectively.

An extension MUST NOT change the semantics of the `EAR` and `EAR-appraisal`
claims-sets.

A receiver MUST ignore any unknown claim.

## Unregistered claims

An application-specific extension will normally mint its claim from the "private
space" - using integer values less than -65536 for CWT, and Public or
Private Claim Names as defined in {{Sections 4.2 and 4.3 of -jwt}} when
serializing to JWT.

It is RECOMMENDED that JWT EARs use Collision-Resistant Public Claim Names
({{Section 2 of -jwt}}) rather than Private Claim Names.

## Registered claims {#sec-registered-claims}

If an extension will be used across multiple applications, or is intended to be
used across multiple environments, the associated extension claims
SHOULD be registered in one, or both, the CWT and JWT claim registries.

In general, if the registration policy requires an accompanying specification
document (as it is the case for "specification required" and "standards
action"), such document SHOULD explicitly say that the extension is expected to
be used in EAR claims-sets identified by this profile.

An up-to-date view of the registered claims can be obtained via the
{{IANA.cwt}} and {{IANA.jwt}} registries.

## Choosing between registered and unregistered claims

If an extension supports functionality of a specific application (e.g.
Veraison Services), its claims MAY be registered.

If an extension supports a protocol that may be applicable across multiple
applications or environments (e.g., TEEP), its claims SHOULD be registered.

Since, in general, there is no guarantee that an application will be confined
within an environment, it is RECOMMENDED that extension claims that have
meaning outside the application's context are always registered.

It is also possible that claims that start out as application-specific acquire
a more stable meaning over time. In such cases, it is RECOMMENDED that new
equivalent claims are created in the "public space" and are registered as
described in {{sec-registered-claims}}. The original "private space" claims
SHOULD then be deprecated by the application.

## TEEP Extension {#sec-extensions-teep}

The TEEP protocol {{-teep}} specifies the required claims that an attestation
result must carry for a TAM (Trusted Application Manager) to make decisions on
how to remediate a TEE (Trusted Execution Environment) that is out of
compliance, or update a TEE that is requesting an authorized change.

The list is provided in {{Section 4.3.1 of -teep}}.

EAR defines a TEEP application extension for the purpose of conveying such claims.

~~~cddl
TODO
~~~
{: #fig-cddl-teep title="TEEP Extension (CDDL Definition)" }

### JSON Serialization

~~~cddl
TODO
~~~

Example:

~~~cddl
TODO
~~~

### CBOR Serialization

~~~cddl
TODO
~~~

Example:

~~~cddl
TODO
~~~

## Veraison Extensions {#sec-extensions-veraison}

The Veraison verifier defines two private, application-specific extensions:

{:vspace}
`ear.veraison.TODO1`
: TODO

`ear.veraison.TODO2`
: TODO

~~~cddl
TODO
~~~
{: #fig-cddl-veraison title="Veraison Extensions (CDDL Definition)" }

### JSON Serialization

~~~cddl
TODO
~~~

Example:

~~~cbor-diag
TODO
~~~

### CBOR Serialization

~~~cddl
TODO
~~~

Example:

~~~cbor-diag
TODO
~~~

# Media Types

Media types for EAR are automatically derived from the base EAT media type
{{-eat-media-type}} using the profile string defined in {{sec-ear}}.

For example, a JWT serialization would use:

~~~
application/eat-jwt; eat_profile="tag:github.com,2023:veraison/ear"
~~~

A CWT serialization would instead use:

~~~
application/eat-cwt; eat_profile="tag:github.com,2023:veraison/ear"
~~~

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

## New EAT Claims {#sec-iana-ear-claims}

This specification adds the following values to the "JSON Web Token Claims"
registry {{IANA.jwt}} and the "CBOR Web Token Claims" registry {{IANA.cwt}}.

Each entry below is an addition to both registries.

The "Claim Description", "Change Controller" and "Specification Documents" are
common and equivalent for the JWT and CWT registries.
The "Claim Key" and "Claim Value Types(s)" are for the CWT registry only.
The "Claim Name" is as defined for the CWT registry, not the JWT registry.
The "JWT Claim Name" is equivalent to the "Claim Name" in the JWT registry.

### EAR Status

* Claim Name: ear.status
* Claim Description: EAR Status
* JWT Claim Name: ear.status
* Claim Key: 1000
* Claim Value Type(s): unsigned integer (0, 2, 32, 96)
* Change Controller: IESG
* Specification Document(s): {{sec-ear-appraisal}} of {{&SELF}}

### EAR Trustworthiness Vector

* Claim Name: ear.trustworthiness-vector
* Claim Description: EAR Trustworthiness Vector
* JWT Claim Name: ear.trustworthiness-vector
* Claim Key: 1001
* Claim Value Type(s): map
* Change Controller: IESG
* Specification Document(s): {{sec-tvector}} of {{&SELF}}

### EAR Raw Evidence

* Claim Name: ear.raw-evidence
* Claim Description: EAR Raw Evidence
* JWT Claim Name: ear.raw-evidence
* Claim Key: 1002
* Claim Value Type(s): bytes
* Change Controller: IESG
* Specification Document(s): {{sec-ear}} of {{&SELF}}

### EAR Appraisal Policy Identifier

* Claim Name: ear.appraisal-policy-id
* Claim Description: EAR Appraisal Policy Identifier
* JWT Claim Name: ear.appraisal-policy-id
* Claim Key: 1003
* Claim Value Type(s): text
* Change Controller: IESG
* Specification Document(s): {{sec-ear-appraisal}} of {{&SELF}}

### EAR Verifier Software Identifier

* Claim Name: ear.verifier-id
* Claim Description: EAR Verifier Software Identifier
* JWT Claim Name: ear.verifier-id
* Claim Key: 1004
* Claim Value Type(s): map
* Change Controller: IESG
* Specification Document(s): {{sec-verifier-id}} of {{&SELF}}

### EAR TEEP Claims

TODO

--- back

# Common CDDL Types

{:vspace}
`non-empty`
: A CDDL generic that can be used to ensure the presence of at least one item
in an object with only optional fields.

~~~cddl
{::include cddl/generic-non-empty.cddl}
~~~

{:vspace}
`base64-url-text`
: string type representing a Base64 URL-encoded string (see {{Section 5 of
!RFC4648}}).

~~~cddl
{::include cddl/base64-url-text.cddl}
~~~

# Acknowledgments
{:numbered="false"}

Many thanks to
Dave Thaler,
Greg Kostal,
Simon Frost,
Yogesh Deshpande
for helpful comments and discussions that have shaped this document.
