
# Status Transitions (FHIR Task.status)

**Allowed business statuses:**
- `order-received`
- `order-accepted`
- `dispatched`
- `received-at-lab`
- `test-processed`
- `complete`

## Allowed Transitions
```
order-received -> order-accepted -> dispatched -> received-at-lab -> test-processed -> complete
```

## Rules
1. **Monotonic progression**: transitions **MUST** move forward only.
2. **Idempotent updates**: re-sending the same status is allowed and **MUST NOT** error.
3. **No skips**: skipping intermediate states is **SHOULD NOT**. If a supplier cannot emit all states, they **MUST** document and obtain approval.
4. **Terminal**: `complete` is terminal; no further transitions allowed.

## Error Semantics
- Invalid backward transition: return `409 Conflict` with `OperationOutcome` (code `business-rule`) detailing attempted transition.
- Unknown `status`: return `422 Unprocessable Entity` with details.
