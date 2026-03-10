
# Idempotency Rules

**Scope:** Applies to all write operations using `X-Correlation-ID`:
- `POST /order` (Supplier API)
- `PUT /test-order/status` (Home Test Supplier API)
- `POST /result` (Home Test Supplier API)

## Principle
For any request with the **same** `X-Correlation-ID` and **logically identical** payload:
- The server **MUST** ensure a single side-effect.
- A retried request **MUST** return either the original success response or a 2xx/409 indicating the operation already applied.

## Requirements
1. `X-Correlation-ID` **MUST** be a UUID (v4 recommended).
2. Servers **SHOULD** include an idempotency key store with a TTL ≥ 24h for transient network retries.
3. Duplicate submissions **MUST NOT** create duplicate Tasks, Observations, or Orders.

## Error Handling
- If a duplicate with a **different** payload is received for the same `X-Correlation-ID`, the server **MUST** return `409 Conflict` with an `OperationOutcome`/`problem+json` explaining the mismatch.

## Observability
- Log the correlation ID on receipt and completion.
- Propagate the ID to downstream calls.
