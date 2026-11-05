-- One row per conversation: who, which airline, when, how long
-- n_customers flags threads where more than one customer replied
DROP TABLE IF EXISTS conversations;
CREATE TABLE conversations AS
SELECT
  conversation_id,
  airline,
  MAX(CASE WHEN inbound = 'True' THEN author_id END)                   AS customer_id,
  COUNT(DISTINCT CASE WHEN inbound = 'True' THEN author_id END)        AS n_customers,
  MIN(CASE WHEN inbound = 'True' THEN created_ts END)                  AS start_ts,
  MAX(created_ts)                                                      AS end_ts,
  COUNT(*)                                                             AS n_tweets,
  SUM(inbound = 'True')                                                AS customer_tweets
FROM conversation_tweets
GROUP BY conversation_id, airline;