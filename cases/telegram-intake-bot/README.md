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
