# Evaluation Plan: AI Tagging Accuracy

## Goal
Measure how often the AI's labels match a human's, using the same
labeling guide (labeling_guide.md).

## Sets
| Pairs | Purpose |
|---|---|
| 116–120 | Pilot: hand-labeled first to find unclear guide definitions. Excluded from accuracy. |
| 31–60 | Accuracy set: hand-labeled blind. |
| All 120 | AI-labeled, in 4 batches of 30. |

## Blind labeling
Pairs 31–60 are hand-labeled without viewing the AI's labels for those
pairs. The accuracy set was originally pairs 1–30, but some AI
rationales for those pairs were viewed during batch checks, so it was
switched to 31–60 to keep the comparison independent.

## Method
1. Hand-label pairs 31–60 (return reason + fix owner).
2. Load human and AI labels into SQLite.
3. Report agreement separately for return reason and fix owner.
4. Review every disagreement and classify it: AI error, human error,
   or guide ambiguity.

## Guide issues found during AI tagging
Not applied yet: the guide stays unchanged until the accuracy check is
done, so human and AI labels use the same rules. Candidates for guide v2:

1. **Judge from before the return.** The return reason is based on the
   first conversation and the customer's opening repeat tweet, not on
   the airline's replies within the repeat conversation.
   (Found in pairs 78 and 97.)
2. **Promised follow-up not delivered.** If support promised a
   follow-up (claims team, customer relations) and the customer's
   return indicates it hadn't happened (e.g. "still waiting," "still
   getting the run around"), use unresolved_issue / support_response.
   support_response covers any response owed by support, including
   promised follow-ups, not only the first reply. (Found in pairs 63, 97.)
   ## Results

I hand-labeled 30 pairs (31–60) without seeing the AI's labels, then
compared. The AI used Sonnet 5 via Claude Code.

| Measure | Result |
|---|---|
| AI and human agreed on both labels | 23 of 30 (76.7%) |
| AI label judged acceptable after reviewing disagreements | 29 of 30 (96.7%) |

**What the 7 disagreements turned out to be:**
- 3 were my labeling mistakes (the AI was right)
- 3 were genuinely ambiguous: both labels were reasonable under the guide
- 1 was a clear AI error

**Main finding:** the AI's one consistent mistake was judging how the
airline replied *after* the customer came back, instead of *why* they
came back. It happened 3 times across all 120 pairs. A clearer rule in
the labeling guide would likely fix it.

Note: 30 pairs is a small sample, so treat the percentages as rough.
Full detail: `labels/disagreements.csv`.