-- Export the full text of both conversations for each sampled pair
-- Output: data/sample_pairs_text.csv (one row per tweet), input for AI tagging
.headers on
.mode csv
.output data/sample_pairs_text.csv

SELECT
  pair.pair_id,
  pair.airline,
  pair.gap_hours,
  CASE WHEN tweet.conversation_id = pair.first_conversation_id
       THEN 'first' ELSE 'repeat' END                AS conversation,
  tweet.created_ts,
  CASE WHEN tweet.inbound = 'True'
       THEN 'customer' ELSE 'airline' END             AS speaker,
  replace(tweet.text, char(10), ' ')                  AS text
FROM sample_pairs pair
JOIN conversation_tweets tweet
  ON tweet.conversation_id IN (pair.first_conversation_id, pair.repeat_conversation_id)
 AND tweet.airline = pair.airline
ORDER BY pair.pair_id, conversation, tweet.created_ts;

.output stdout