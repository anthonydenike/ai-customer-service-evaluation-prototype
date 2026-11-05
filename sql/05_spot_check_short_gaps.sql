-- Spot-check: read 5 random repeat pairs where the customer came back within 1 hour
WITH sample AS (
  SELECT * FROM repeat_pairs
  WHERE gap_hours < 1
  ORDER BY RANDOM()
  LIMIT 5
)
SELECT
  s.first_conversation_id AS pair,
  CASE WHEN ct.conversation_id = s.first_conversation_id THEN '1st' ELSE 'repeat' END AS conv,
  substr(ct.created_ts, 6, 11) AS time,
  CASE WHEN ct.inbound = 'True' THEN 'customer' ELSE ct.airline END AS who,
  substr(replace(ct.text, char(10), ' '), 1, 140) AS text
FROM sample s
JOIN conversation_tweets ct
  ON ct.conversation_id IN (s.first_conversation_id, s.repeat_conversation_id)
 AND ct.airline = s.airline
ORDER BY pair, ct.created_ts;