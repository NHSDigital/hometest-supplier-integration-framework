# FHIR Communication Resource for HIV Test Results

## Overview
The FHIR Communication resource is used in HomeTest to represent a clinical communication, such as a phone call or text message, that establishes patient contact for delivering HIV test results. It is vital that this resource is populated correctly as part of the test results Bundle where clinical contact is required, so that patients with reactive or inconclusive results are guided through the next steps with a clinician.
For non-reactive results, or results where clinical contact is not required, this resource must be sent with a status of `not-done`.
For HIV, we are expecting the Communication resource to be populated and sent with all result types.

## Fields used with HomeTest
### Status
HomeTest uses this field to determine if patient contact was made succesfully.
A value of `completed` indicates that patient contact has successfully been made, and so a reactive or inconclusive result can be revealed by the HomeTest platform within the NHS App.
A value of `on-hold` indicates that clinical contact has been attempted (usually multiple times), but for whatever reason has not been successful. In this instance, HomeTest will not reveal the result to the user, and will instead show a page urging them to make contact with the relevant test supplier's clinical team.
Finally, a value of `not-done` indicates that clinical contact was not required. This will lead to the result being revealed to the patient, and is expected for non-reactive results, or where there was an error in processing the test.
### ReasonReference
This field is used to relate the communication to the 'Observation' that led to clinical contact being necessary.
