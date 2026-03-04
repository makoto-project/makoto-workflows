# Signing Roadmap: L1 → L2

This document describes the migration path from **Makoto L1** (Provenance Exists) to **L2** (Authentic Provenance) for the DBOM demo.

## What We Have Now (L1)

At L1, attestations are **unsigned JSON documents** that accompany data artifacts:

- Machine-readable attestation exists (in-toto Statement v1 format)
- Origin and transforms are documented
- Content hashing (SHA-256) enables tamper detection
- **Threats addressed**: D1 (source impersonation, partial), D2 (data tampering, partial)

## What Changes at L2

At L2, attestations are **cryptographically signed and tamper-evident**:

| Requirement | Description |
|-------------|-------------|
| Signed attestations | Digital signatures using ECDSA P-256 or equivalent |
| Tamper-evident | Consumers can verify signature validity against known keys |
| Timestamp binding | Verifiable timestamps (RFC 3161 or similar) |
| Hash chaining | Each transform attestation references cryptographic hash of inputs |
| DSSE envelope | Attestations wrapped in [Dead Simple Signing Envelope](https://github.com/secure-systems-lab/dsse) |

### DSSE Envelope Format

```json
{
  "payloadType": "application/vnd.in-toto+json",
  "payload": "<base64-encoded attestation JSON>",
  "signatures": [{
    "keyid": "https://example.com/keys/signer-01",
    "sig": "MEUCIQD2qN3..."
  }]
}
```

### Threats Addressed at L2

| Threat | ID | Status |
|--------|----|--------|
| Source impersonation | D1 | ✓ Mitigated |
| Data tampering | D2 | ✓ Mitigated |
| Lineage falsification | D3 | ✓ Mitigated |
| Timestamp manipulation | D4 | ✓ Mitigated |
| Unauthorized attribution | D5 | ✓ Mitigated |
| Stream injection | D8 | ✓ Mitigated |

## Option A: Sigstore / cosign (Recommended)

**Keyless signing via OIDC** — lowest friction, no key management.

### How It Works

1. Developer authenticates via OIDC (GitHub, Google, Microsoft)
2. Sigstore's Fulcio CA issues a short-lived certificate
3. Attestation is signed with the ephemeral key
4. Signature + cert are recorded in Rekor transparency log
5. Verifiers check the Rekor log entry — no need to distribute keys

### Implementation Sketch

```bash
# Sign an attestation
cosign attest-blob \
  --predicate attestations/sample-metrics.origin.json \
  --type https://makoto.dev/origin/v1 \
  data/local/sample-metrics.csv

# Verify
cosign verify-blob-attestation \
  --certificate-identity user@example.com \
  --certificate-oidc-issuer https://github.com/login/oauth \
  --type https://makoto.dev/origin/v1 \
  data/local/sample-metrics.csv
```

### Trade-offs

| ✅ Pros | ❌ Cons |
|---------|---------|
| No key management | Requires network access for signing |
| Transparency log provides audit trail | Depends on Sigstore infrastructure |
| GitHub Actions OIDC integration works out of the box | Not suitable for air-gapped environments |
| Widely adopted in cloud-native ecosystem | |

### Integration Points

- **Justfile**: Add `sign` and `verify` recipes that wrap cosign
- **GitHub Actions**: Use `sigstore/cosign-installer` action; OIDC token available via `id-token: write` permission
- **Python**: Use `sigstore-python` package for programmatic signing

## Option B: GitHub GPG Key Signing

**Sign with user's existing GitHub GPG keys** — leverages existing identity infrastructure.

### How It Works

1. User's GPG public key is published at `https://github.com/<user>.gpg`
2. Attestation JSON is signed with `gpg --detach-sign`
3. Signature file (`.sig`) accompanies the attestation
4. Verifiers fetch the public key from GitHub and verify

### Implementation Sketch

```bash
# Sign
gpg --armor --detach-sign attestations/sample-metrics.origin.json

# Verify (fetch key from GitHub)
curl -sL https://github.com/asw101.gpg | gpg --import
gpg --verify attestations/sample-metrics.origin.json.asc
```

### Trade-offs

| ✅ Pros | ❌ Cons |
|---------|---------|
| Works with existing GitHub identity | Requires GPG key management |
| No external dependencies | No transparency log |
| Works offline / air-gapped | Key distribution is manual |
| Users already have keys if they sign commits | Not DSSE-compatible out of the box |

### Integration Points

- **Justfile**: Add `sign-gpg` recipe that signs and produces `.asc` sidecar
- **Verification**: Fetch key via GitHub API, verify signature
- **DSSE wrapping**: Would need a shim to convert GPG sig → DSSE envelope

## Option C: Notation / COSE Signatures

**OCI-native signing** — aligns with container registry workflows.

### How It Works

1. Attestation is stored as an OCI artifact in a container registry
2. Signed using [Notation](https://notaryproject.dev/) with COSE envelope
3. Verification uses trust policies pointing to signing certificates
4. Compatible with ORAS (OCI Registry as Storage)

### Trade-offs

| ✅ Pros | ❌ Cons |
|---------|---------|
| Native to container registries | Requires OCI registry infrastructure |
| Strong enterprise support (Microsoft, AWS) | More complex setup |
| Trust policy model is flexible | Less common outside container ecosystem |
| Works with existing cert infrastructure | Not directly compatible with in-toto/DSSE |

## Recommendation

**Start with Option A (Sigstore/cosign)** for the following reasons:

1. **Lowest friction**: Keyless signing means zero setup for developers
2. **GitHub-native**: OIDC tokens in GitHub Actions make CI signing trivial
3. **DSSE-compatible**: cosign produces in-toto/DSSE envelopes, matching the Makoto spec exactly
4. **Transparency**: Rekor log provides auditability without extra infrastructure
5. **Community alignment**: SLSA, OpenSSF, and the broader supply chain security ecosystem have converged on Sigstore

### Migration Steps

1. Add `sigstore-python` or `cosign` as a dependency
2. Update `generate_dbom.py` to optionally wrap attestations in DSSE envelopes
3. Update `validate_dbom.py` to verify DSSE signatures when present
4. Add `sign` / `verify` recipes to the Justfile
5. Update the GitHub Actions workflow to use `sigstore/cosign-installer` and `id-token: write`
6. Bump attestation `makotoLevel` from `"L1"` to `"L2"` in generated DBOMs

### Keep Option B as Fallback

GitHub GPG signing is a good fallback for offline/air-gapped environments. Consider supporting both — detect whether cosign is available, fall back to GPG.
