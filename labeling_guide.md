# Labeling Guide: Why Customers Came Back

Each item is a **pair**: a customer's first conversation with an airline,
and their next conversation with the same airline 1 hour to 7 days later.
Read both. Assign one **return reason** and one **fix owner**, plus a
one-sentence rationale.

Judge mainly from what the customer says at the start of the **repeat**
conversation. Use the first conversation for context.

## Return reason (pick one)

| Label | Use when | Example |
|---|---|---|
| `no_response` | The customer's last request in the first conversation got no reply before they came back. | First: customer asks for rebooking help; airline never replies. Repeat: "Still waiting on rebooking." |
| `inadequate_answer` | The airline replied, but the reply didn't address what was asked: generic, off-topic, or only "DM us / call us." | First: "Can I change my flight for free?" Airline: "DM us." Repeat: "Still need to know about changing my flight." |
| `wrong_information` | The airline gave information that turned out to be incorrect or contradicted by what happened. | First: "Your refund will post in 3 days." Repeat: "Agent says refunds take 3 weeks?" |
| `unresolved_issue` | The airline's reply addressed the request (action taken or promised), but the problem still wasn't fixed. | First: bag lost, airline opened a claim. Repeat: "Still no bag, no update." |
| `new_issue` | The repeat is about something unrelated to the first conversation. | First: seat selection. Repeat: baggage fee question on a different trip. |
| `not_issue` | The repeat conversation has no request or complaint: praise, thanks, chatter. | Repeat: "Thanks for getting me rebooked, great service!" |

**Quick test for the first four:**
1. Did the airline reply to the customer's last request? No → `no_response`
2. Did the reply address what was asked? No → `inadequate_answer`
3. Was the information wrong? Yes → `wrong_information`
4. Otherwise, if the problem persisted → `unresolved_issue`

**Clarifications from pilot:**
- `unresolved_issue` describes what happened, not who's at fault.
  If support did its job and the problem continued anyway, use
  `unresolved_issue` and let the fix owner show the cause
  (e.g. `airline_operations`).
- An estimate that later changed because the situation changed
  (a delay that kept growing) is not `wrong_information`.
  Use `wrong_information` only when the info was wrong when given.

## Fix owner (pick one)

| Label | Use when |
|---|---|
| `support_response` | The reply was missing, incomplete,