---
title: "EAR & AR4SI Update"
footer: IETF 127, San Francisco, RATS WG
slidenumbers: true
slidecount: true
slidenumber-style: alignment(right)
autoscale: true
theme: Next
---

# EAR and AR4SI updates

## [draft-ietf-rats-ear-05](https://datatracker.ietf.org/doc/draft-ietf-rats-ear/05)
## [draft-ietf-rats-ar4si-11](https://datatracker.ietf.org/doc/draft-ietf-rats-ar4si/11)

### RATS WG, IETF 127

---

# AR4SI 11

---

## Status

- Added the "incomplete" tier
- Factored out common trustworthiness claims

---

## Next steps

- Mega editorial pass
  - align terminology with the rest of the RATS corpus
  - remove stale content
- Publish -12

---

## Some pending (hard) questions

- **[EAR impacting]** Split HW bucket into separate HW and FW? (See issue #TODO(tho))
- **[EAR impacting]** Add an "identity" claim in the DM?  It's tricky to model:
  - Could already pop up at different places (verifier claims-set, attester claims-set, transport key)
  - Could have different shapes (HW identifier, DNS name, X.509 certificate)
- Any appetite for describing use-case specific profiles (CC, IoT, Mobile)?

Need more discussion

---

# EAR 05

---

## Status

- Multi-verifier support:
  - `ear_status` += incomplete
  - `ear_device_topology` claim
  - recursive submods for Composite Attester / Verifier
- CoRIM verifier integration ("ACS" claims)
  - attester/verifier/RVP/endorser claims
  - related Veraison extns removal

---

## Status (cont'd)

- Misc new claims:
  - error/diagnostic: `ear_*_details` claims
  - request context binding: `ear_input_digest` claim
- Data model improvements
  - use CMW for `ear_raw_evidence`
- housekeeping: extension "rules" and rationale, IANA cleanup

---

## Next Steps

- Attester crypto keys
  - secrets release, key broker: `eat_secret_wrapping_keys`
  - attested secure channels: `eat_transport_identity_key`
- Complete Multi-verifier support
  - Composite attester binding assertions
- Terminology alignment (RFC9334, multi-verifier, CoRIM)
- The planned feature set is **complete** (modulo AR4SI opens)

---

## Next Steps (cont'd)

- publish -06 (_very_ soon)
- make IANA requests (Chairs, please assist)
- implement & deploy (Veraison, CoCo, Azure, NVIDIA)
- collect implementation & deployment feedback
- would be nice to have some end-to-end reviews from the WG

---

# Backup

---

## AR4SI: new "incomplete" tier

- The `none` tier was overloaded. It meant both "no assertion" and "the Verifier could not finish".
- Clearly split semantics by adding a fifth tier, `incomplete`, separate from `none`.
  - `none`: no assertion about this aspect of trustworthiness.
  - `incomplete`: the Verifier was unable to complete its appraisal of this aspect
- Per-claim enumerations are now grouped: generic values (`0`, `1`, `-1`, `31`, `95`, `99`, `127`) apply to every Trustworthiness Claim, plus claim-specific ones
- Minor editorial cleanup

---

## EAR: `ear_status` gains one more tier

*(`-05`, follows AR4SI)*

- `ear_status` can now be one of five tiers.
- `none` is the neutral element when rolling up status: it never changes the result, and MUST NOT be the value of `ear_status`.
- A submod the Verifier can't parse or verify counts as `incomplete`.
- The value `127` was added to the registered value types of `ear_status`

---

## CMW-wrapped raw evidence

*(`-04`)*

- `ear_raw_evidence` is now a CMW Record instead of a bare byte string.
  - The Evidence format is self-described: media type or CoAP content-format, plus the payload.
- Claim value type changes from `bytes` to `array`.

---

## Recursive and tunnelled submods

*(`-05`)*

- Added to support multi-verifier scenarios: the EAR mirrors the topology of cooperating Verifiers.
- A submod can now carry one of:
  - `EAR-appraisal`: the flat form, as before.
  - `EAR`: a sub-verifier's full claims-set, embedded in the same serialization.
  - `Nested-Token`: an independently signed EAR (JWT or CBOR), possibly in a different serialization.
- Maps onto the Hierarchical pattern of `draft-ietf-rats-multi-verifier`.
- Roll-up rule: `ear_status` is the worst status across all submods. A `Nested-Token` the lead Verifier can't parse or verify counts as `incomplete`.
- A Relying Party that only reads the top-level `ear_status` doesn't need any of this.

---

## Device topology

*(`-04`)*

- New `ear_device_topology` claim, added (with recursive EAR, previous slide) to support multi-verifier scenarios.
- Adjacency lists over the `submods` labels, describing how the attesters of a composite device relate (for example CPU, GPU and NIC).
- Less "natural" for a lead Verifier than recursive EAR, but may be easier for the Relying Party to consume: one flat view of the graph.
- Use it when a **single** Verifier appraises a composite attester.
- The map is non-empty if present.

---

## Planned: `ear_components_bound`

*(not yet in the draft; last planned item, targeted at `-06`)*

- New claim for multi-attester and multi-verifier scenarios.
- Semantics: whether the Evidence for all components is provably bound together: `true`, `false` or `unknown`.
- Why: per-component results (flat, nested or topology) say each component is trustworthy, but not that they belong to the same device or session.
- Pairs with `ear_device_topology` and recursive submods: the topology says how the components relate to each other, this says whether the Evidence proves it.
- `unknown`: the Verifier has no way to tell, for example because a sub-verifier's result carries no binding information.

---

## Claims by authority

*(`-04` and `-05`)*

- Replaces the Veraison-specific "annotated evidence" and "policy claims" extensions (removed in `-04`) with generic claims:

| Claim | Authority |
|-------|-----------|
| `ear_attester_claims` | claims extracted from the Evidence |
| `ear_verifier_claims` | claims added by the Verifier's policy |
| `ear_endorser_claims` | claims from Endorsements, keyed by supply-chain entity |
| `ear_reference_value_provider_claims` | claims corroborated by Reference Values, keyed by supply-chain entity |

- Entity identifiers are derived by the Verifier from the cryptographic identity of the signer (or via the CoRIM entity attribute), so Relying Parties never handle keys.
- Privacy section updated: redaction and removal apply to these maps.

---

## Details claims

*(`-05`)*

- `ear_status_details` and `ear_trustworthiness_vector_details`: arrays of human-readable reasons.
- Meant for values other than `affirming`: logs, diagnostics, support.
- Rules:
  - Text is **not** standardised, so a Relying Party MUST NOT base automated decisions on it.
  - It may echo Attester-controlled data, so treat it as untrusted input.
  - It SHOULD be possible to disable these claims (privacy).

---

## Input digest

*(`-05`)*

- New `ear_input_digest`: a digest of the exact wire bytes of the appraisal request.
- **Attack closed:** an on-path adversary swaps the Evidence but keeps the nonce. `eat_nonce` alone can't detect it.
- Both sides hash the raw bytes, so there is no canonicalisation and it works with any transport.
- CMW is RECOMMENDED as the request format.
- Applicability conditions: the request is in one self-delimiting encapsulation, and the sender retains the literal octets. Otherwise, don't use it.

---

## Transport identity key

*(on `main`, not yet published; planned for `-06`)*

- New `eat_transport_identity_key`: the key the Attester uses to authenticate in a secure channel, e.g. the TLS end-entity key (attested TLS).
- Value: DER `SubjectPublicKeyInfo`, or a digest of it.
- The Relying Party **MUST** compare it byte for byte with the key it authenticated in the channel. A mismatch is an attestation failure.
- The claim says the key lives in the Target Environment. Proof of possession comes from the channel (e.g. CertificateVerify).

---

## Secret wrapping keys

*(on `main`, not yet published; planned for `-06`)*

- New `eat_secret_wrapping_keys`: public keys a Relying Party can use to wrap a secret released to the Attester (secure key release).
- Value: JWK Set in JSON, COSE_KeySet in CBOR. Public keys only, and the set is non-empty.
- Key selection uses the key's own `alg`, `key_ops` and `kid`. The Relying Party **MUST NOT** use a key not marked for encryption, key wrapping or key agreement.
- The Verifier includes a key only if the Evidence binds it to the Attester. There is no proof of possession: using the key is the test.
- Security considerations: the Relying Party checks `eat_nonce` freshness and `ear_status` before releasing a secret.

---

## Extension rules

*(`-05`, and `main`)*

- Extensions no longer have to be maps. Any CBOR or JSON value is allowed.
- A new EAT profile identifier is needed only if an extension **must** be understood by all consumers. Optional extensions keep the existing profile identifier.
- Related claims to be registered SHOULD be grouped under one top-level key, to save public codepoints.
- **Veraison key attestation extension removed** (PR open): `ear_veraison_key_attestation` goes away now that the key claims above are in.

---

## IANA

New claims, all with suggested keys (Change Controller: IESG)

| Claim | Key |
|-------|-----|
| `ear_attester_claims` | 1005 |
| `ear_verifier_claims` | 1006 |
| `ear_device_topology` | 1007 |
| `ear_input_digest` | 1008 |
| `ear_components_bound` (planned) | 1009 |
| `ear_status_details` | 1010 |
| `ear_trustworthiness_vector_details` | 1011 |
| `eat_transport_identity_key` | 1012 |
| `eat_secret_wrapping_keys` | 1013 |
| `ear_endorser_claims` | 1014 |
| `ear_reference_value_provider_claims` | 1015 |

Existing: `ear_raw_evidence` is redefined as a CMW record. `ear_status` gains the value type 127.

