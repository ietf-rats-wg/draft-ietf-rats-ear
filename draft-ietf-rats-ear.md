---
title: "EAT Attestation Results"
abbrev: "EAR"
category: std

docname: draft-ietf-rats-ear-latest
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
  org: Linaro
  email: thomas.fossati@linaro.org
- name: Eric Voit
  org: Cisco
  email: evoit@cisco.com
- name: Sergei Trofimov
  org: Arm Limited
  email: sergei.trofimov@arm.com
- name: Henk Birkholz
  org: Fraunhofer SIT
  email: henk.birkholz@ietf.contact
  street: Rheinstrasse 75
  code: '64295'
  city: Darmstadt
  country: Germany

normative:
  RFC7519: jwt
  RFC8392: cwt
  RFC8610: cddl
  RFC5280: pkix
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

`eat_profile` (mandatory)
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
See {{Section 3.3 of -ar4si}} for further details on its structure and serialization.

`ear.raw-evidence` (optional)
: The unabridged evidence submitted for appraisal, including any signed
container/envelope.
This field may be consumed by other Verifiers in multi-stage verification
scenarios or by auditors.
There are privacy considerations associated with this claim.  See
{{sec-priv-cons}}.

`submods` (mandatory)
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

`eat_nonce` (optional)
: A user supplied nonce that is echoed by the verifier to provide freshness.
The nonce is a sequence of bytes between 8 and 64 bytes long. When serialized
as JWT, the nonce MUST be base64 encoded, resulting in a string between 12 and
88 bytes long.
See {{Section 4.1 of -eat}}.

`$$ear-extension` (optional)
: Any registered or unregistered extension.
An EAR extension MUST be a map.
See {{sec-extensions}} for further details.

## EAR Appraisal Claims {#sec-ear-appraisal}

~~~cddl
{::include cddl/ear-appraisal.cddl}
~~~
{: #fig-cddl-ear-appraisal title="EAR Appraisal Claims (CDDL Definition)" }

{:vspace}
`ear.status` (mandatory)
: The overall appraisal status for this attester represented as one of the four
trustworthiness tiers ({{Section 3.2 of -ar4si}}).
The value of this claim MUST be set to a tier of no higher trust than the tier
corresponding to the worst trustworthiness claim across the entire
trustworthiness vector.

`ear.trustworthiness-vector` (optional)
: The AR4SI trustworthiness vector providing the breakdown of the appraisal for
this attester.
See {{Section 3.1 of -ar4si}} for the details.
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

## JSON Serialisation

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
Project Veraison Services), its claims MAY be registered.

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
{::include cddl/ext-teep.cddl}
~~~
{: #fig-cddl-teep title="TEEP Extension (CDDL Definition)" }

### JSON Serialization Example

~~~cddl
{::include cddl/examples/ext-teep-json-1.diag}
~~~

### CBOR Serialization Example

~~~cddl
{::include cddl/examples/ext-teep-cbor-1.diag}
~~~

## Project Veraison Extensions {#sec-extensions-veraison}

The Project Veraison verifier defines three private, application-specific
extensions:

{:vspace}
`ear.veraison.annotated-evidence`
: JSON representation of the evidence claims-set, including any annotations
provided by the Project Veraison verifier.
There are privacy considerations associated with this claim.  See
{{sec-priv-cons}}.

`ear.veraison.policy-claims`
: any extra claims added by the policy engine in the Project Veraison verifier.

`ear.veraison.key-attestation`
: contains the public key part of a successfully verified attested key.
The key is a DER encoded ASN.1 SubjectPublicKeyInfo structure ({{Section
4.1.2.7 of -pkix}}).

~~~cddl
{::include cddl/ext-veraison.cddl}
~~~
{: #fig-cddl-veraison title="Project Veraison Extensions (CDDL Definition)" }

### JSON Serialization Examples

~~~cbor-diag
{::include cddl/examples/ext-veraison-json-1.diag}
~~~

~~~cbor-diag
{::include cddl/examples/ext-veraison-json-2.diag}
~~~

### CBOR Serialization Example

~~~cbor-diag
{::include cddl/examples/ext-veraison-cbor-1.diag}
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

## Project Veraison

The organization responsible for this implementation is Project Veraison, a
Linux Foundation project hosted at the Confidential Computing Consortium.

The organization currently provides two separate implementations: one in Golang
another in C17.

The developers can be contacted on the Zulip channel:
[](https://veraison.zulipchat.com/#narrow/stream/357929-EAR/).

### `github.com/veraison/ear`

The software, hosted at [](https://github.com/veraison/ear), provides a Golang
package that allows encoding, decoding, signing and verification of EAR
payloads together with a CLI (`arc`) to create, verify and visualize EARs on
the command line.
The maturity level is currently alpha, and only the JWT serialization is
implemented.
The license is Apache 2.0.
The package is used by the Project Veraison verifier to produce attestation
results.

### `github.com/veraison/c-ear`

The software, hosted at [](https://github.com/veraison/c-ear), provides a C17
library that allows verification and partial decoding of EAR payloads.
The maturity level is currently pre-alpha, and only the JWT serialization is
implemented.
The license is Apache 2.0.
The library targets relying party applications that need to verify attestation
results.

### `github.com/veraison/rust-ear`

The software, hosted at [](https://github.com/veraison/rust-ear), provides a
Rust (2021 edition) library that allows verification and partial decoding of
EAR payloads. The maturity level is currently pre-alpha, with limitted
algorithm support.  Both JWT and COSE serializations are implemented.  The
license is Apache 2.0.  The library targets verifiers that need to produce
attestation results as well as relying party applications that need to verify
and consume attestation results.

# Security Considerations

TODO Security

# Privacy Considerations {#sec-priv-cons}

EAR is designed to expose as little identifying information as possible about
the attester.
However, certain EAR claims have direct privacy implications.
Implementations should therefore allow applying privacy-preserving techniques
to those claims, for example allowing their redaction, anonymisation or
outright removal.
Specifically:

* It SHOULD be possible to disable inclusion of the optional `ear.raw-evidence`
  claim
* It SHOULD be possible to disable inclusion of the optional
  `ear.veraison.annotated-evidence` claim
* It SHOULD be possible to allow redaction, anonymisation or removal of
  specific claims from the `ear.veraison.annotated-evidence` object

EAR is an EAT, therefore the privacy considerations in {{Section 8 of -eat}}
apply.

# IANA Considerations

## New EAT Claims {#sec-iana-ear-claims}

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
* Claim Key: 1000 (suggested)
* Claim Value Type(s): unsigned integer (0, 2, 32, 96)
* Change Controller: IESG
* Specification Document(s): {{sec-ear-appraisal}} of {{&SELF}}

### Trustworthiness Vector

* Claim Name: ear.trustworthiness-vector
* Claim Description: EAR Trustworthiness Vector
* JWT Claim Name: ear.trustworthiness-vector
* Claim Key: 1001 (suggested)
* Claim Value Type(s): map
* Change Controller: IESG
* Specification Document(s): {{sec-ear-appraisal}} of {{&SELF}}

### EAR Raw Evidence

* Claim Name: ear.raw-evidence
* Claim Description: EAR Raw Evidence
* JWT Claim Name: ear.raw-evidence
* Claim Key: 1002 (suggested)
* Claim Value Type(s): bytes
* Change Controller: IESG
* Specification Document(s): {{sec-ear}} of {{&SELF}}

### EAR Appraisal Policy Identifier

* Claim Name: ear.appraisal-policy-id
* Claim Description: EAR Appraisal Policy Identifier
* JWT Claim Name: ear.appraisal-policy-id
* Claim Key: 1003 (suggested)
* Claim Value Type(s): text
* Change Controller: IESG
* Specification Document(s): {{sec-ear-appraisal}} of {{&SELF}}

### Verifier Software Identifier

* Claim Name: ear.verifier-id
* Claim Description: AR4SI Verifier Software Identifier
* JWT Claim Name: ear.verifier-id
* Claim Key: 1004 (suggested)
* Claim Value Type(s): map
* Change Controller: IESG
* Specification Document(s): {{sec-ear}} of {{&SELF}}

### EAR TEEP Claims

TODO

--- back

# Common CDDL Types {#common-cddl-types}

{:vspace}
`non-empty`
: A CDDL generic that can be used to ensure the presence of at least one item
in an object with only optional fields.

~~~cddl
{::include cddl/generic-non-empty.cddl}
~~~

# Open Policy Agent Example

Open Policy Agent [OPA](https://www.openpolicyagent.org) is a popular and
flexible policy engine that is used in a variety of contexts, from cloud to
IoT.  OPA policies are written using a purpose-built, declarative programming
language called
[Rego](https://www.openpolicyagent.org/docs/latest/policy-language/).  Rego has
been designed to handle JSON claim-sets and their JWT envelopes as first class
objects, which makes it an excellent fit for dealing with JWT EARs.

The following example illustrates an OPA policy that a Relying Party would use
to make decisions based on a JWT EAR received from a trusted verifier.

~~~ rego
package ear

ear_appraisal = {
    "verified": signature_verified,
    "appraisal-status": status,
    "trustworthiness-vector": trust_vector,
} {
    # verify EAR signature is correct and from one of the known and
    # trusted verifiers
    signature_verified := io.jwt.verify_es256(
        input.ear_token,
        json.marshal(input.trusted_verifiers)
    )

    # extract the EAR claims-set
    [_, payload, _] := io.jwt.decode(input.ear_token)

    # access the attester-specific appraisal record
    app_rec := payload.submods.PARSEC_TPM
    status := app_rec["ear.status"] == "affirming"

    # extract the trustworhiness vector for further inspection
    trust_vector := app_rec["ear.trustworthiness-vector"]
}

# add further conditions on the trust_vector here
# ...
~~~

The result of the policy appraisal is the following JSON object:

~~~ json
{
    "ear_appraisal": {
        "appraisal-status": true,
        "trustworthiness-vector": {
            "executables": 2,
            "hardware": 2,
            "instance-identity": 2
        },
        "verified": true
    }
}
~~~

For completeness, the trusted verifier public key and the EAR JWT used in the
example are provided below.

~~~
=============== NOTE: '\' line wrapping per RFC 8792 ================
{
    "ear_token": "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9.eyJlYXIucmF3L\
WV2aWRlbmNlIjoiTnpRM01qWTVOek0yTlRZek56UUsiLCJlYXIudmVyaWZpZXItaWQiO\
nsiYnVpbGQiOiJ2dHMgMC4wLjEiLCJkZXZlbG9wZXIiOiJodHRwczovL3ZlcmFpc29uL\
XByb2plY3Qub3JnIn0sImVhdF9wcm9maWxlIjoidGFnOmdpdGh1Yi5jb20sMjAyMzp2Z\
XJhaXNvbi9lYXIiLCJpYXQiOjEuNjY2NTI5MTg0ZSswOSwianRpIjoiNTViOGIzZmFkO\
GRkMWQ4ZWFjNGU0OGYxMTdmZTUwOGIxMWY4NDRkOWYwMTg5YmZlZDliODc1MTVhNjc1N\
DI2NCIsIm5iZiI6MTY3NzI0Nzg3OSwic3VibW9kcyI6eyJQQVJTRUNfVFBNIjp7ImVhc\
i5hcHByYWlzYWwtcG9saWN5LWlkIjoiaHR0cHM6Ly92ZXJhaXNvbi5leGFtcGxlL3Bvb\
GljeS8xLzYwYTAwNjhkIiwiZWFyLnN0YXR1cyI6ImFmZmlybWluZyIsImVhci50cnVzd\
HdvcnRoaW5lc3MtdmVjdG9yIjp7ImV4ZWN1dGFibGVzIjoyLCJoYXJkd2FyZSI6Miwia\
W5zdGFuY2UtaWRlbnRpdHkiOjJ9LCJlYXIudmVyYWlzb24ua2V5LWF0dGVzdGF0aW9uI\
jp7ImFrcHViIjoiTUZrd0V3WUhLb1pJemowQ0FRWUlLb1pJemowREFRY0RRZ0FFY2pTc\
DhfTVdNM2d5OFR1Z1dPMVRwUVNqX3ZJa3NMcEMtZzhsNVMzbHBHYjdQV1dHb0NBakVQO\
F9BNTlWWndMWGd3b1p6TjBXeHVCUGpwYVdpV3NmQ1EifX19fQ.3Ym-f1LEgamxePUM7h\
6Y2RJDGh9eeL0xKor0n1wE9jdAnLNwm3rTKFV2S2LbqVFoDtK9QGalT2t5RnUdfwZNmg\
",
    "trusted_verifiers": {
        "keys": [
            {
                "alg": "ES256",
                "crv": "P-256",
                "kty": "EC",
                "x": "usWxHK2PmfnHKwXPS54m0kTcGJ90UiglWiGahtagnv8",
                "y": "IBOL-C3BttVivg-lSreASjpkttcsz-1rb7btKLv8EX4"
            }
        ]
    }
}
~~~

# Open Issues

<cref>Note to RFC Editor: please remove before publication.</cref>

The list of currently open issues for this documents can be found at
[](https://github.com/thomas-fossati/draft-ear/issues).

# Document History

<cref>Note to RFC Editor: please remove before publication.</cref>

## draft-fv-rats-ear-00

Initial release.

## draft-fv-rats-ear-01

* privacy considerations
* OPA policy example
* add rust-ear crate to the implementation status section

## draft-fv-rats-ear-02

* align JWT and CWT representations of eat_nonce

# Acknowledgments
{:numbered="false"}

Many thanks to
Dave Thaler,
Greg Kostal,
Simon Frost,
Yogesh Deshpande
for helpful comments and discussions that have shaped this document.
