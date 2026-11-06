# From Prototype to Production

This prototype shows an AI tool that automatically evaluates customer
service conversations: it finds repeat contacts, classifies why each
customer came back and who owns the fix, and measures its own accuracy
against human labels. It ran once on a fixed public dataset.

This document describes how it would run on an ongoing basis in a real
support operation: pulling new data on a schedule, evaluating every
repeat contact, showing results on a dashboard, routing findings to
owners, and measuring whether fixes work.

*Production details are assumptions about a typical large support
operation, not based on internal knowledge of any company.*

## 1. How it would run continuously

| Stage | Prototype | Production |
|---|---|---|
| Data | One Kaggle file | Scheduled job (daily/weekly) pulling new contacts from the data warehouse: chat and call transcripts, case records |
| Find repeats | SQL files, run once | Same SQL logic, run automatically on each new batch |
| Classify | 120-pair sample | Every repeat, classified via an LLM API, labels written to a table |
| Check AI quality | 30 hand-labeled pairs, once | Small human-reviewed sample every week; agreement tracked over time, with an alert if it drops |
| Visualize | Two charts in a README | Operations dashboard (views listed below) |
| Action | A report | Tickets created in each owner's project management tool (e.g. Jira) when a pattern crosses a set threshold, with volume, trend and example conversations attached; tracked through to closure |
| Measure | Not applicable | Each ticket's fix is tracked through to a before-and-after repeat rate (see section 4) |
| Change the prompt | Guide refined by hand | Changes tested against a fixed "golden set" of labeled examples before release |

**Dashboard views:**
- **Repeat types:** volume and share of each return reason, and how
  each is trending.
- **Owners:** volume and share of real repeats by fix owner, and how
  each is trending.
- **Repeat rate over time:** overall 7-day repeat rate, week over week.
- **Top patterns:** the most common specific issues (e.g. "promised
  follow-up not delivered"), and any that are rising quickly.
- **Fix tracking:** open tickets by owner, status, and before-and-after
  impact of completed fixes.
- **AI accuracy:** weekly agreement between AI labels and human review.
- **Filters and drill-down:** date range, channel and product; click
  through to example conversations behind any number.

**Two loops run together:**
- **Operations loop:** classify → dashboard → ticket to owner → owner
  fixes → measure impact → repeat.
- **Classifier loop:** review a sample → find error patterns → update the
  guide and prompt → retest on the golden set → release.

**What success looks like:** each week, leaders see the repeat rate by
reason and owner across all contacts, not a sample. Each owner has a
ranked list of their top repeat drivers in their own backlog. Every fix
has a measured before-and-after. AI accuracy is a tracked number, not an
assumption.

## 2. How it guides priorities

| Metric | Answers |
|---|---|
| Repeat volume by owner and reason | What's failing most, and whose fix is it? |
| Trend over time | Getting better or worse? |
| Estimated cost (repeats × cost per contact) | How much is it worth fixing? |
| Controllability | Can this owner actually act on it? |
| Specific patterns | What's the concrete fix? (e.g. "promised follow-up not delivered") |

Priority combines volume, cost and controllability. In this prototype,
operations caused 60% of real repeats, but support can't fix delays;
the 24% owned by support is smaller but directly actionable.

## 3. How the definition would change with real data

| | Twitter prototype | Real support operation |
|---|---|---|
| Customer identity | Anonymized handles; threads rebuilt from replies | Account and booking/itinerary ID |
| Same issue? | Inferred from text | Matched on the same booking |
| Channels | Twitter only | Phone, chat, email, AI virtual agent, across channels |
| Case status | None | Open/closed status, resolution codes |
| Key question | Why did they come back? | Also: did the AI agent resolve it, or did the traveler come back to a human? |
| Trigger | Any contact | Event-based groups, e.g. contacts after a cancellation |
| Fix owners | Includes airline operations | Suppliers (airlines, hotels) route to partner management |

Standard metrics: **repeat contact rate** and **first contact resolution (FCR)**.

## 4. Measuring whether a fix worked

**Example:** support adds a rule that promised follow-ups (claims,
customer relations) get a status update within 48 hours.

1. **Success metric, defined before launch:** 7-day repeat rate for
   contacts labeled `unresolved_issue` / `support_response`.
2. **Baseline:** the same metric over the 4–8 weeks before launch.
3. **Comparison:** ideally roll out to some teams or markets first and
   compare with the rest. If not possible, compare against repeat
   categories the fix shouldn't affect, to separate the fix's effect
   from seasonal swings.
4. **Guardrails:** customer satisfaction, handle time, and total
   contact volume. A fix that lowers repeats by pushing contacts to
   another channel isn't a real improvement.
5. **Keep the classifier fixed during measurement:** if the prompt or
   model changes mid-test, a change in the numbers could come from
   labeling, not the fix.
6. **Decision rule:** agree in advance what size of drop counts as
   success, and how long to measure.

## 5. Safeguards

**Already in the prototype**
- **Prompt injection:** the AI is told to treat tweet text as data only
  and ignore any instructions inside it.
- **Cost and code control:** AI tagging ran with no scripts or API calls,
  so no unreviewed code ran and no unexpected costs were possible.
- **Raw data kept out of the repo:** the full dataset stays local; the
  repo holds queries, labels and results.
- **Human check before trust:** AI accuracy was measured against blind
  human labels before its output was used.

**Needed in production**
- **Customer privacy:** mask names, booking numbers, emails and payment
  details before text goes to an LLM; use only approved AI vendors with
  agreed data-retention terms; limit who can view raw transcripts.
- **Security:** keep the prompt-injection guard, log what the system
  processed and produced, and give the pipeline only the data access
  it needs.
- **AI stays advisory:** labels guide analysis and priorities. They
  don't trigger customer-facing actions (e.g. denying a refund or
  closing a case) on their own.
- **Ongoing monitoring:** weekly accuracy checks (section 1) catch a
  drop in label quality before it misleads decisions.