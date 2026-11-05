-- Indexes: speed up lookups on the columns we join and filter on
CREATE INDEX IF NOT EXISTS idx_tweet_id  ON tweets(tweet_id);
CREATE INDEX IF NOT EXISTS idx_in_reply  ON tweets(in_response_to_tweet_id);
CREATE INDEX IF NOT EXISTS idx_author    ON tweets(author_id);

-- Airline-only table: airline tweets + customer tweets linked to them
DROP TABLE IF EXISTS airline_tweets;
CREATE TABLE airline_tweets AS
WITH airline_side AS (
  SELECT * FROM tweets
  WHERE author_id IN ('AirAsiaSupport','AlaskaAir','AmericanAir','British_Airways',
                      'Delta','JetBlue','SouthwestAir','VirginAmerica','VirginAtlantic')
)
-- 1. The airlines' own tweets
SELECT co.*, co.author_id AS airline
FROM airline_side co
UNION
-- 2. Customer tweets the airline replied to
SELECT cust.*, co.author_id AS airline
FROM tweets cust
JOIN airline_side co ON cust.tweet_id = co.in_response_to_tweet_id
WHERE cust.inbound = 'True'
UNION
-- 3. Customer tweets replying to the airline
SELECT cust.*, co.author_id AS airline
FROM tweets cust
JOIN airline_side co ON cust.in_response_to_tweet_id = co.tweet_id
WHERE cust.inbound = 'True';