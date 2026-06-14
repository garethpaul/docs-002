# Execute Integration Verification Matrix

Use this matrix for exact-head evidence that cannot be inferred from portable
package checks. Use an isolated synthetic deployment and synthetic execute
requests. Record only sanitized outcomes; never retain API keys, authorization
values, submitted code, provider output, cookies, account identifiers,
screenshots, or logs.

Commit: pending implementation commit
Pull request: pending
Evidence status: not run

| # | Scenario | Boundary | Required sanitized evidence | Status |
|---|---|---|---|---|
| 1 | Isolated deployment setup | Deployment | Commit, runtime version, region class, and synthetic environment identifier | not run |
| 2 | Disabled execute route | Deployed route | Request class, response status, and disabled error class | not run |
| 3 | Missing provider configuration | Deployed route | Missing-variable class, response status, and provider-call count | not run |
| 4 | Method restriction | Deployed route | Method class, response status, and Allow header | not run |
| 5 | JSON media-type validation | Deployed route | Header shape, response status, and provider-call count | not run |
| 6 | Valid editor submission | Browser | Synthetic sample class, response status, and rendered result class | not run |
| 7 | Invalid editor submission | Browser | Invalid-input class, response status, and stable error class | not run |
| 8 | Provider success | Private provider sandbox | Model class, response status, choice count, and elapsed-time bucket | not run |
| 9 | Provider failure | Private provider sandbox | Failure class, response status, and stable error class | not run |
| 10 | Provider timeout | Private provider sandbox | Timeout class, response status, elapsed-time bucket, and attempt count | not run |
| 11 | Response cache boundary | Browser or deployed route | Response class and Cache-Control value | not run |
| 12 | Execute request budget | Deployed route | Window class, admitted count, rejection status, and Retry-After class | not run |
| 13 | Browser refresh behavior | Browser | Pre-refresh state, refresh result, and provider-call delta | not run |
| 14 | Public deployment controls | Deployment edge | Authentication and shared-rate-limit control classes and enforcement result | not run |

## Evidence Rules

- Replace the pending commit and pull-request fields with the exact tested head
  before recording any scenario as `pass`, `fail`, or `blocked`.
- Use only `pass`, `fail`, `blocked`, or `not run`; explain blockers without
  embedding secrets, provider payloads, private identifiers, or machine paths.
- Keep portable package checks, local route tests, browser evidence,
  deployment evidence, and live provider evidence separate.
- A parser test, source check, package build, or static contract cannot mark an
  integration scenario as passed.

No browser, deployed execute route, deployment edge, or live OpenAI provider
scenario was executed for this documentation-only change.
