# Security Policy

## Supported Versions

The supported security scope for `docs-002` is the current default branch, `main`. Older commits, tags, branches, forks, demos, and generated artifacts are not actively supported unless the repository explicitly marks them as maintained.

Project summary: No GitHub description is currently set.

## Reporting a Vulnerability

Please report suspected vulnerabilities through GitHub's private vulnerability reporting or by opening a draft GitHub Security Advisory for `garethpaul/docs-002` when that option is available. If GitHub does not show a private reporting option for this repository, contact the repository owner through GitHub and avoid posting exploit details publicly until the issue can be assessed.

Do not open a public issue that includes exploit code, secrets, personal data, or detailed reproduction steps for an unpatched vulnerability.

## What to Include

Helpful reports include:

- the affected file, endpoint, permission, dependency, or workflow
- a concise impact statement explaining what an attacker could do
- reproduction steps using test data and accounts you control
- the branch, commit SHA, platform version, device, runtime, or dependency versions used
- logs, screenshots, or proof-of-concept snippets that demonstrate impact without exposing private data

## Project Security Posture

- This repository appears to be a JavaScript web application or frontend sample. The active security scope is the code and documentation on the default branch.
- Review found authentication, token, or session-related code paths; changes in those areas should receive security-focused review before merge.
- Review found external API integrations or credential-adjacent configuration; changes in those areas should receive security-focused review before merge.
- Review found network clients, sockets, web APIs, or service endpoints; changes in those areas should receive security-focused review before merge.
- Review found file, document, data, or media parsing flows; changes in those areas should receive security-focused review before merge.
- Review found database, model, query, or persistence-related code; changes in those areas should receive security-focused review before merge.
- Dependency manifests detected: package.json, package-lock.json. Dependency updates should preserve lockfiles when present and avoid introducing packages without a clear maintenance reason.
- The spend-capable execute route must default to disabled and requires
  `DOCS_EXECUTE_ENABLED=true`. This interlock does not replace authentication or
  rate limiting for a public deployment.
- Enabled OpenAI calls use a 30-second timeout with automatic SDK retries
  disabled so one request cannot multiply provider attempts or run indefinitely.
- A process-local fixed-window budget admits ten provider-eligible attempts per
  minute. Only locally valid, configured requests consume capacity, and excess
  eligible traffic receives `429` with `Retry-After` before provider setup.
  Public multi-instance deployments still require shared upstream
  authentication and rate limiting.
- Ambiguous multi-value Content-Type headers are rejected before request-body
  normalization, including arrays where one value names JSON.
- Execute API responses set `Cache-Control: no-store` so submitted code,
  provider output, and route errors are not intentionally cached.
- Browser, deployment, and provider claims require the exact-head integration
  matrix with synthetic requests and sanitized evidence; portable checks do
  not establish public authentication or shared rate-limit enforcement.
- GitHub Actions runs `make check` after `npm ci` on Node 20, 22, and 24 with
  commit-pinned actions, read-only repository access, and a moderate-severity
  audit gate so execute API and dependency guardrails stay enforced before
  merge. It does not persist checkout credentials after source retrieval.

## Service and API Notes

For web services, APIs, sockets, or scraping workflows, prioritize reports involving authentication bypass, authorization errors, injection, server-side request forgery, unsafe deserialization, credential leakage, data exposure, or denial-of-service conditions. Use test accounts and minimal proof-of-concept traffic only.

## Dependency and Supply Chain Security

Dependency updates should come from trusted package managers and should keep lockfiles in sync when lockfiles exist. Do not commit credentials, private keys, tokens, generated secrets, or machine-local configuration. If a vulnerability depends on a compromised package, typosquatting risk, insecure transitive dependency, or unsafe build step, include the package name, affected version, and the path through which it is used.

## Safe Research Guidelines

Good-faith research is welcome when it stays within these boundaries:

- use only accounts, devices, data, and infrastructure that you own or have explicit permission to test
- avoid destructive actions, persistence, spam, phishing, social engineering, or denial-of-service testing
- minimize access to personal data and stop testing immediately if private data is exposed
- do not exfiltrate secrets or third-party data; report the minimum evidence needed to verify impact
- keep vulnerability details confidential until the maintainer has assessed the report

## Maintainer Response

The maintainer will review complete reports as availability allows, prioritize issues by exploitability and impact, and coordinate a fix or mitigation when the affected code is still maintained. For sample, archived, or educational repositories, the likely remediation may be documentation, dependency updates, or clearly marking unsupported code rather than a production-style patch release.
