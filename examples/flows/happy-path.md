
# Happy Path Flow
1. POST /order (supplier API) with ServiceRequest
2. POST /test-order/status (Home Test API) `order-received` → `dispatched` → `received-at-lab` → `complete`
3. POST /result (Home Test API) with Observation
