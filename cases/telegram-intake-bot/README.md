# Telegram Intake Bot

## 1. Business Problem
Small businesses often receive incoming requests through Telegram messages that are unstructured.  
This leads to lost leads, slow response times, and inconsistent processing.

## 2. Target User
Small business owner or support operator who receives requests via Telegram.

## 3. Scenario
A user sends a message to the Telegram bot describing a request.  
The system captures the message, validates that it contains text, structures the request, and forwards it into an internal workflow.

The user receives confirmation that the request has been received.

## 4. Input
Telegram message text.

Metadata automatically captured:

- chat_id
- username
- first_name
- timestamp

## 5. Output
Structured intake record:

- source = telegram
- received_at
- chat_id
- username
- message_text
- status = new
- route = intake

## 6. Workflow Logic

1. Telegram Trigger receives message
2. Check that message text exists
3. Extract metadata
4. Create structured intake object
5. Send confirmation to user
6. Pass structured object to next workflow step

## 7. Telegram Interface

User sends message to bot.

Future commands:

/start  
/help  
/status  

## 8. Human Override

Operator can manually review incoming requests and route them to the correct internal workflow.

## 9. Failure Paths

Possible failures:

- empty message
- malformed payload
- Telegram delivery error
- n8n workflow failure
- duplicate submission

## 10. Test Cases

### Happy Path

User sends a normal message.  
System captures it, structures it, and returns confirmation.

### Failure Path

User sends empty message.

System responds:

"Сообщение пустое. Пожалуйста отправьте текст заявки."

## 11. Artifacts

- n8n workflow export
- README documentation
- test notes

## 12. Commercial Framing

Businesses need a simple way to collect incoming requests in a structured format.  
This automation prevents lost leads and speeds up processing.

## 13. MVP

Minimal system:

Telegram → validation → structured object → confirmation message.

## 14. Roadmap

Future improvements:

- routing to CRM
- AI classification of request
- priority detection
- operator dashboard


## Data Contract

### Required Input Fields

- source: string
- received_at: datetime
- chat_id: integer
- username: string
- first_name: string
- text: string
- status: string
- route: string

### Validation Rules

- text must not be empty
- chat_id must exist
- source must be telegram
- status defaults to new
- route defaults to intake

### Output Object

{
  "source": "telegram",
  "received_at": "ISO datetime",
  "chat_id": 123456789,
  "username": "user",
  "first_name": "Alex",
  "text": "request text",
  "status": "new",
  "route": "intake"
}


## Failure Path Handling

### Failure Cases

1. Empty message  
If the incoming Telegram message has no usable text, the workflow must stop and return a clear error message.

2. Missing sender metadata  
If `chat_id` or sender metadata is missing, the payload should be marked invalid and routed to manual review.

3. Malformed payload  
If the Telegram payload structure is incomplete or unexpected, the workflow should not continue normal intake processing.

4. Duplicate submission  
If the same request is submitted repeatedly in a short interval, it should be flagged for operator review.

5. Downstream workflow failure  
If the next internal processing step fails, the intake record should remain visible for manual recovery.

### Fallback Responses

- Empty message → ask user to send a valid request text
- Missing required field → route to manual review
- Malformed payload → stop processing and log incident
- Duplicate request → flag for operator review
- Downstream failure → preserve intake object and escalate manually

### Human Override

An operator must be able to:
- inspect failed intake records
- re-route a request manually
- re-send a request into the next workflow
- close false duplicate flags manually

### Monitoring Notes

The system should log:
- validation failure reason
- missing field name
- duplicate detection event
- downstream failure event
- manual override action


## Monitoring and Operator Visibility

### Key Events to Log

- message received
- validation passed
- validation failed
- route assigned
- duplicate detected
- downstream workflow started
- downstream workflow failed
- manual override applied

### Minimum Monitoring Fields

- event_time
- chat_id
- username
- request_status
- route
- failure_reason
- operator_action

### Operator Alerts

The operator should be able to notice:

- repeated validation failures
- repeated duplicate requests
- downstream workflow failures
- requests waiting for manual review
- requests re-routed manually

### Operational Use

Monitoring should help answer:

- how many requests were received
- how many failed validation
- how many required manual review
- how many failed in downstream processing
- how many were recovered manually

