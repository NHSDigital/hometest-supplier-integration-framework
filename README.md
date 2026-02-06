# HomeTest Supplier Integration Framework

A lightweight framework for defining and validating supplier integration contracts for HomeTest-style integrations. The repo is structured to make it easy to version, review, and automate checks against schemas and contractual changes over time.

## What’s in this repository

- **`schemas/`** — Version-controlled schema definitions that describe the integration contract(s).
- **`CHANGELOG.md`** — Human-readable record of notable changes between releases.

## Typical use cases

- **Contract-first integrations:** agree a stable interface with suppliers using schemas as the source of truth.
- **Validation in CI/CD:** automatically validate payloads/artifacts against the schemas.
- **Change control & governance:** track breaking vs non-breaking changes via PR review + changelog + versioning.

## Getting started

### Clone the repository

```text
git clone <REPO_URL>
cd hometest-supplier-integration-framework
```

## Working with schemas

### Where to put new schemas

- Add or update schema files under `schemas/`.
- Keep schema changes **small and reviewable**—prefer incremental PRs to large rewrites.

### Recommended workflow for changing contracts

1. **Create a branch** describing the change.
2. **Update schemas** in `schemas/`.
3. **Update `CHANGELOG.md`** with:
    - what changed,
    - why it changed,
    - impact (breaking/non-breaking),
    - any migration notes.
4. Open a PR and use the PR template to capture:
    - test evidence,
    - rollout/migration plan,
    - stakeholder sign-off if required.


## Contributing

Contributions are welcome via pull requests.

- Use the existing **issue templates** for bug reports/requests.
- Follow the **PR template** to ensure changes are auditable and easy to review.
- Keep changes focused: one contract change per PR where practical.
- Ensure documentation (especially `CHANGELOG.md`) is updated alongside schema changes.

## Licence

See **[`LICENCE.md`](./LICENCE.md)** for licensing details.

Any HTML or Markdown documentation is [© Crown Copyright](https://www.nationalarchives.gov.uk/information-management/re-using-public-sector-information/uk-government-licensing-framework/crown-copyright/) and available under the terms of the [Open Government Licence v3.0](https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/).
