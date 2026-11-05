-- Repeat contacts: same customer + same airline, next conversation
-- between 1 hour and 7 days later
-- Excludes multi-customer threads (~3%) to avoid false repeats
-- Minimum 1-hour gap: spot-checks showed shorter gaps were the same
--   conversation split across threads, not real returns
DROP TABLE IF EXISTS repeat_pairs;
CREATE TABLE repeat_pairs AS
WITH ordered AS (
  SELECT
    customer_id,
    airline,
    conversation_id,
    start_ts,
    LEAD(conversation_id) OVER w AS next_conversation_id,
    LEAD(start_ts)        OVER w AS next_start_ts
  FROM conversations
  WHERE customer_id IS NOT NULL
    AND n_customers = 1
  WINDOW w AS (PARTITION BY customer_id, airline ORDER BY start_ts)
)
SELECT
  customer_id,
  airline,
  conversation_id      AS first_conversation_id,
  start_ts             AS first_start_ts,
  next_conversation_id AS repeat_conversation_id,
  next_start_ts        AS repeat_start_ts,
  ROUND((julianday(next_start_ts) - julianday(start_ts)) * 24, 1) AS gap_hours
FROM ordered
WHERE start_ts BETWEEN '2017-10-01' AND '2017-11-26 23:59:59'
  AND next_start_ts IS NOT NULL
  AND julianday(next_start_ts) - julianday(start_ts) >= 1.0 / 24
  AND julianday(next_start_ts) - julianday(start_ts) <= 7;