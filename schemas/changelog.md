**Version 1.0.1**

---
Changes to supplier_api_spec.yaml
1. Fixed FHIR ServiceRequest Structure
   - Added missing status property with FHIR-standard enum values
   - Added text field to code (CodeableConcept) for human-readable representation
   - Moved patient demographics from custom fields to a FHIR-compliant contained Patient resource
     Changed from custom fields (firstName, lastName, phone, address.line1/line2/postcode, etc.)
     To FHIR datatypes: name (HumanName), telecom (ContactPoint), address (Address with postalCode), birthDate
   - Made subject a minimal Reference pointing to #patient-1 (contained resource)
2. Updated FHIRObservation
   - Added text field to code (CodeableConcept)
   - Removed valueQuantity (numeric results)
   - Added interpretation field with FHIR ObservationInterpretation CodeableConcept
   - Kept valueCodeableConcept for actual test results
3. Made /results Strictly FHIR
   - Changed 200 response from custom {results: []} to FHIR Bundle (type: searchset)
   - Added FHIRBundleSearchsetObservations schema
   - Changed 400 error from application/problem+json to application/fhir+json with OperationOutcome
   - Changed 404 error to return OperationOutcome
4. Updated All Error Responses to FHIR
   - Replaced BadRequest (400) from RFC 7807 to FHIR OperationOutcome
   - Replaced UnprocessableEntity (422) from RFC 7807 to FHIR OperationOutcome
   - All errors now use application/fhir+json consistently
5. Made Success Responses FHIR-Compliant
   - Changed POST /order 201 response from custom JSON {order_uid, order_status, estimated_delivery_date} to return the FHIR ServiceRequest resource

----

Changes to home-test-supplier-api.yaml
1. Fixed FHIRTask Status
   - Changed status enum from custom values [`order-received`, `dispatched`, `received-at-lab`, `complete`]
   - To FHIR-standard values: [`draft`, `requested`, `received`, `accepted`, `rejected`, `ready`, `cancelled`, `in-progress`, `on-hold`, `failed`, `completed`, `entered-in-error`]
     > [!NOTE]
     > We will map these FHIR status from our agreed status and update later
   - Updated businessStatus description to indicate it holds domain-specific statuses
2. Updated FHIRObservation
   - Added text field to code (CodeableConcept)
   - Removed valueQuantity (numeric results)
   - Added interpretation field with FHIR ObservationInterpretation CodeableConcept
   - Kept valueCodeableConcept for actual test results
3. Added FHIROperationOutcome Schema
   - Full FHIR-compliant OperationOutcome resource definition
4. Updated All Error Responses to FHIR
   - Replaced BadRequest (400) from RFC 7807 to FHIR OperationOutcome
   - Replaced Unauthorized (401) from RFC 7807 to FHIR OperationOutcome
   - Replaced NotFound (404) from RFC 7807 to FHIR OperationOutcome
   - All errors now use application/fhir+json consistently
5. Made Success Responses FHIR-Compliant
   - Changed POST /result 201 response from custom JSON {order_uid, result_status, timestamp} to return the FHIR Observation resource

---

**Version 1.0.2 - January 26, 2026 - Additional FHIR Compliance Updates**

Changes to both supplier_api_spec.yaml and home-test-supplier-api.yaml:

1. Added FHIRReference Reusable Schema
   - Created FHIRReference component schema for proper FHIR Reference datatype
   - Schema includes:
       - reference (required): Literal reference, Relative, internal or absolute URL
       - type (optional): Type the reference refers to (e.g., "Organization")
       - display (optional): Text alternative for the resource
   - Ensures proper typing for code generation (TypeScript/Java/C#)

2. Updated All Reference Fields in supplier_api_spec.yaml
   - ServiceRequest.subject: Changed from inline object to use FHIRReference with allOf
   - ServiceRequest.requester: Changed from inline object to use FHIRReference with allOf
   - ServiceRequest.performer: Changed from inline object array to FHIRReference array
   - Observation.basedOn: Changed from inline object array to FHIRReference array
   - Observation.subject: Changed from inline object to use FHIRReference with allOf
   - Observation.performer: Changed from inline object array to FHIRReference array

3. Updated All Reference Fields in home-test-supplier-api.yaml
   - Observation.basedOn: Changed from inline object array to FHIRReference array
   - Observation.subject: Changed from inline object to use FHIRReference with allOf
   - Observation.performer: Changed from inline object array to FHIRReference array
   - Task.basedOn: Changed from inline object array to FHIRReference array
   - Task.for: Changed from inline object to use FHIRReference with allOf
   - Task.requester: Changed from inline object to use FHIRReference with allOf
   - Task.owner: Changed from inline object to use FHIRReference with allOf

4. Fixed FHIRTask FHIR R4 Compliance
   - Added required intent field with enum values: [`unknown`, `proposal`, `plan`, `order`, `original-order`, `reflex-order`, `filler-order`, `instance-order`, `option`]
   - Updated required fields to include: resourceType, status, intent, basedOn

5. Added FHIRCodeableConcept Reusable Schema
   - Created FHIRCodeableConcept component schema for proper FHIR CodeableConcept datatype
   - Schema includes:
       - coding (optional): Array of Coding objects with system, code, and display
       - text (optional): Plain text representation of the concept
   - Ensures proper typing for code generation and consistency across all coded values

6. Updated All CodeableConcept Fields in supplier-api-spec.yaml
   - ServiceRequest.code: Changed from inline object to use FHIRCodeableConcept with allOf
   - Observation.code: Changed from inline object to use FHIRCodeableConcept with allOf
   - Observation.interpretation: Changed from inline object array to FHIRCodeableConcept array
   - Observation.valueCodeableConcept: Changed from inline object to use FHIRCodeableConcept with allOf

7. Updated All CodeableConcept Fields in home-test-supplier-api.yaml
   - Observation.code: Changed from inline object to use FHIRCodeableConcept with allOf
   - Observation.interpretation: Changed from inline object array to FHIRCodeableConcept array
   - Observation.valueCodeableConcept: Changed from inline object to use FHIRCodeableConcept with allOf
   - Task.statusReason: Changed from inline object to use FHIRCodeableConcept with allOf
   - Task.businessStatus: Changed from inline object to use FHIRCodeableConcept with allOf

8. Added Reusable FHIR Datatype Schemas
   - Created FHIRCoding component schema for proper FHIR Coding datatype
       - Properties: system, code, display
       - Used within FHIRCodeableConcept.coding arrays
   - Created FHIRIdentifier component schema for proper FHIR Identifier datatype
       - Properties: system, value, use
       - Used in Task.identifier arrays
   - Created FHIRHumanName component schema for proper FHIR HumanName datatype
       - Properties: use, family, given, text
       - Used in Patient.name arrays (supplier-api-spec only)
   - Created FHIRContactPoint component schema for proper FHIR ContactPoint datatype
       - Properties: system, value, use
       - Used in Patient.telecom arrays (supplier-api-spec only)
   - Created FHIRAddress component schema for proper FHIR Address datatype
       - Properties: use, type, line, city, postalCode, country
       - Used in Patient.address arrays (supplier-api-spec only)

9. Updated All Inline Datatype Usages in supplier-api-spec.yaml
   - FHIRCodeableConcept.coding: Changed from inline Coding objects to FHIRCoding array
   - Patient.name (contained): Changed from inline HumanName objects to FHIRHumanName array
   - Patient.telecom (contained): Changed from inline ContactPoint objects to FHIRContactPoint array
   - Patient.address (contained): Changed from inline Address objects to FHIRAddress array
   - OperationOutcome.issue.details: Changed from inline CodeableConcept to FHIRCodeableConcept

10. Updated All Inline Datatype Usages in home-test-supplier-api.yaml
    - FHIRCodeableConcept.coding: Changed from inline Coding objects to FHIRCoding array
    - Task.identifier: Changed from inline Identifier objects to FHIRIdentifier array
    - OperationOutcome.issue.details: Changed from inline CodeableConcept to FHIRCodeableConcept

Renamed supplier-api-spec.yaml for conformity

---

**Version 1.0.3 - January 27, 2026 - FHIR R4 Validation and UUID Corrections**

Changes to both supplier-api-spec.yaml and home-test-supplier-api.yaml:

1. Fixed UUID Validation Issues in Observation Resources
   - **supplier-api-spec.yaml**: Changed FHIRObservation.id example from "550e8400-e29b-41d4-a716-446655440000" to "550e8400-e29b-41d4-a716-446655440001"
       - Reason: Observation ID conflicted with ServiceRequest ID causing reference validation errors
       - Ensures unique UUIDs across all resources to prevent FHIR reference mismatches
   - **home-test-supplier-api.yaml**: Observation.id example already correctly set to "550e8400-e29b-41d4-a716-446655440001"
   - **supplier-api-spec.yaml**: Updated FHIRBundleSearchsetObservations.entry.fullUrl example to "urn:uuid:550e8400-e29b-41d4-a716-446655440001"
       - Ensures Bundle fullUrl matches the Observation resource ID
       - Critical for FHIR Bundle validation where fullUrl must reference the correct resource


---

**Version 1.0.4 - January 27, 2026 - Business-Critical Required Fields (FHIR Profiling)**

Changes to both supplier-api-spec.yaml and home-test-supplier-api.yaml:
Added Required Fields for Business Operations (FHIR Constrained Profile)

1. FHIRServiceRequest Required Fields Added (supplier-api-spec.yaml only)
   - Made `contained` required (minItems: 1) - Patient demographics are mandatory for order fulfillment
   - Made contained Patient properties required:
     - `resourceType` - Required for FHIR resource type identification
     - `id` - Required for contained resource reference (#patient-1)
     - `name` - Required (patient identification for order processing)
     - `telecom` - Required (contact information for delivery and follow-up)
     - `address` - Required (shipping address for test kit delivery)

2. FHIRObservation Required Fields Added (both APIs)
   - Made `basedOn` required - Links Observation to originating ServiceRequest (critical for order tracking)
   - Made `valueCodeableConcept` required - The actual test result must be present (core purpose of Observation)

3. FHIRTask Required Fields Added (home-test-supplier-api.yaml only)
   - Made `identifier` required - Essential for tracking order status across systems

4. FHIR Datatype Required Fields Added (supplier-api-spec.yaml only)
   - FHIRHumanName: Made `family` required - Last name is mandatory for patient identification
   - FHIRContactPoint: Made `value` required - Contact method is useless without actual contact value
   - FHIRAddress: Made `line` and `postalCode` required - Minimum address information for UK deliveries

5. Patient Telecom Cardinality Constraint Added (supplier-api-spec.yaml only)
   - Made Patient.telecom `minItems: 2` - Requires at least 2 contact points
   - Updated description to clarify both phone and email are required
   - **Business Rationale**: Both phone (for delivery contact) and email are essential for order fulfillment and customer communication
   - **Implementation Note**: Application validation should verify one telecom has `system: 'phone'` and one has `system: 'email'`

---

**Version 1.0.5 - March 10, 2026 - Example and Required Field Corrections**

Changes to home-test-supplier-api.yaml:

1. Fixed basedOn Example Values
- FHIRObservation.basedOn: Changed items from bare `$ref` to `allOf` with context-specific example, replacing inherited `Organization/SUP001` example with correct `ServiceRequest/550e8400-e29b-41d4-a716-446655440000`
- FHIRTask.basedOn: Same fix applied - updated description to "Reference to the ServiceRequest this task fulfills" and added correct ServiceRequest example

2. Added Required Fields to FHIRTask
- Made `for` required - Patient beneficiary must be identified on every status update
- Made `lastModified` required - Timestamp of the status change is mandatory for audit and ordering

Changes to examples/fhir/task_update_dispatched.example.json:

3. Fixed task_update_dispatched Example
- Corrected `status` from `"dispatched"` (invalid FHIR value) to `"in-progress"`
- Added missing required `intent` field with value `"order"`
- Added missing required `for` field referencing `Patient/123e4567-e89b-12d3-a456-426614174000`
- Added missing required `lastModified` field with value `"2025-11-04T10:35:00Z"`
- Added `use: "official"` to identifier entry for consistency with schema example

---

**Version 1.0.6 - March 20, 2026 - Status Endpoint Method Update**

Changes to home-test-supplier-api.yaml
1. Updated /test-order/status endpoint
   - Changed the method from PUT to POST

---

**Version 1.0.7 - April 8, 2026 - Performer Example Update**

Changes to schemas/supplier-api-spec.yaml
Added Example to clarify required Performer fields
1. Updated Performer Organisation
   - Added Example to Performer Organisation

**Version 1.0.8 - April 16, 2026 - Addition of order-accepted and test-processed statuses**

1. Updated status-transitions.md documentation
   - Added the two new statuses of order-accepted and test-processed
   - Clarified that order-received and complete are not expected to be sent from a supplier system.
2. Documentation-only changes to schemas/supplier-api-spec.yaml
   - Added order-accepted and test-processed to the description of bussinessStatus within FHIRTask
   - Removed order-received and complete from businessStatus description, as they should not be sent by suppliers.

**Version 1.0.9- April 24, 2026 - Change results to use a Bundle of DiagnosticReport,Observation and Communication**

1. Results are now expected to be sent in a Bundle, consisting of a DiagnosticReport, an Observation and a Communcaiton.
   - Updated OpenAPI specs to reflect the new format.
   - Added examples for non-reactive, reactive-with-contact, and reactive-without-contact.
2. Documentation changes to clarify and provide context around how DiagnosticReport, Observation and Communication should be populated.
