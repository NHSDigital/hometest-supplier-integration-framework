# FHIR Resource Examples

This directory contains example FHIR R4 resources extracted from the OpenAPI specifications for validation purposes.

## Files

- **ServiceRequest.json** - Example test order (used in supplier-api-spec)
- **Observation.json** - Example test result (used in both APIs)
- **Task.json** - Example order status update (used in home-test-supplier-api)
- **OperationOutcome.json** - Example error response (used in both APIs)
- **Bundle.json** - Example search results bundle (used in supplier-api-spec)
- **Patient.json** - Example patient resource (contained in ServiceRequest)

## Validation

To validate these FHIR resources against FHIR R4 specification:

### Using HL7 FHIR Validator (Recommended)
Download from: https://github.com/hapifhir/org.hl7.fhir.core/releases

```bash
# Validate all files
java -jar validator_cli.jar schemas/fhir-schemas/*.json -version 4.0.1

# Validate individual file
java -jar validator_cli.jar schemas/fhir-schemas/ServiceRequest.json -version 4.0.1
```

### Using HAPI FHIR Validator
```bash
npm install -g fhir-validator-cli
fhir-validator schemas/fhir-schemas/ServiceRequest.json
```

### Using Online Validator
Visit: https://validator.fhir.org/

## Resource Mappings

### supplier-api-spec.json uses:
- **ServiceRequest** - POST /order request/response
- **Observation** - GET /results response (inside Bundle)
- **OperationOutcome** - Error responses (400, 409, 422, 404)
- **Bundle** - GET /results response wrapper
- **Patient** - Contained resource in ServiceRequest

### home-test-supplier-api.json uses:
- **Observation** - POST /result request/response
- **Task** - POST /test-order/status request/response
- **OperationOutcome** - Error responses (400, 401, 404)

## FHIR Version

All resources conform to FHIR R4 (4.0.1)

