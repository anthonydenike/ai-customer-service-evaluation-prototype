-- Indexes on the new table, for the joins below
CREATE INDEX IF NOT EXISTS idx_at_tweet ON airline_tweets(tweet_id);
CREATE INDEX IF NOT EXISTS idx_at_reply ON airline_tweets(in_response_to_tweet_id);

-- Label every tweet with the conversation it belongs to
DROP TABLE IF EXISTS conversation_tweets;
CREATE TABLE conversation_tweets AS
WITH RECURSIVE thread(tweet_id, conversation_id) AS (
  -- Start: tweets that don't reply to anything in our table (conversation openers)
  SELECT tweet_id, tweet_id
  FROM airline_tweets
  WHERE in_response_to_tweet_id = ''
     OR in_response_to_tweet_id NOT IN (SELECT tweet_id FROM airline_tweets)
  UNION
  -- Repeat: add each reply to a tweet already found, keeping the same conversation_id
  SELECT reply.tweet_id, thread.conversation_id
  FROM airline_tweets reply
  JOIN thread ON reply.in_response_to_tweet_id = thread.tweet_id
)
SELECT DISTINCT
  thread.conversation_id,
  t.tweet_id,
  t.airline,
  t.author_id,
  t.inbound,
  -- Convert 'Tue Oct 31 22:03:34 +0000 2017' into '2017-10-31 22:03:34'
  substr(t.created_at, 27, 4) || '-' ||
  CASE substr(t.created_at, 5, 3)
    WHEN 'Jan' THEN '01' WHEN 'Feb' THEN '02' WHEN 'Mar' THEN '03'
    WHEN 'Apr' THEN '04' WHEN 'May' THEN '05' WHEN 'Jun' THEN '06'
    WHEN 'Jul' THEN '07' WHEN 'Aug' THEN '08' WHEN 'Sep' THEN '09'
    WHEN 'Oct' THEN '10' WHEN 'Nov' THEN '11' WHEN 'Dec' THEN '12'
  END || '-' ||
  substr(t.created_at, 9, 2) || ' ' ||
  substr(t.created_at, 12, 8) AS created_ts,
  t.text
FROM thread
JOIN airline_tweets t ON t.tweet_id = thread.tweet_id;