# FHIR Communication Resource for HIV Test Results

## Overview
The FHIR Communication resource is used in HomeTest to represent a clinical communication, such as a phone call or text message, that establishes patient contact for delivering HIV test results. It is vital that this resource is populated correctly as part of the test results Bundle where clinical contact is required, so that patients with reactive or inconclusive results are guided through the next steps with a clinician.
For non-reactive results, or results where no clinical contact is made, this resource can either be omitted, or sent with a status of `not-done`.

## Fields used with HomeTest
### Status
HomeTest uses this field to determine if patient contact was made succesfully.
A value of `completed` indicates that patient contact has successfully been made, and so a reactive or inconclusive result can be revealed by the HomeTest platform within the NHS App.
A value of `on-hold` indicates that clinical contact has been attempted (usually multiple times), but for whatever reason has not been successful. In this instance, HomeTest will not reveal the result to the user, and will instead show a page urging them to make contact with the relevant test supplier's clinical team.
Finally, a value of `not-done` indicates that clinical contact was not required, and is processed the same as if the Communication was absent from the bundle.
### ReasonReference
This field is used to relate the communication to the 'Observation' that led to clinical contact being necessary.


- **Category**: Coded to specify the type of communication (e.g., `phone` or `telecommunication`).
- **Subject**: References the Patient resource for the individual whose HIV test results are being communicated.
- **Recipient**: References the Practitioner or Organization initiating or receiving the call.
- **Sender**: References the entity sending the communication (e.g., lab or healthcare provider).
- **Sent**: Timestamp of when the communication was sent or initiated.
- **Received**: Timestamp of when the communication was received.
- **Reason Code**: Coded reason for the communication (e.g., `notification` or `results-delivery`).
- **Payload**: Contains the content of the communication, such as a reference to DiagnosticReport for HIV test results or free text summarizing the call.

## Relevant FHIR Resources
- **Patient**: The subject of the communication.
- **DiagnosticReport**: Referenced in payload for test results.
- **Practitioner**: Involved as sender or recipient.

This summary focuses on the Communication resource's application to phone-based patient contact for HIV testing outcomes.
