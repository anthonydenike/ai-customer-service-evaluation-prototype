-- =====================================================================
-- Validation checks: what was checked at each step, and the result
-- Run any single query with: sqlite3 -box data/twcs.db "<query>"
-- =====================================================================

-- ---------------------------------------------------------------------
-- Step: Load raw CSV into SQLite
-- Check: all rows imported
-- Result: 2,811,774 tweets
-- ---------------------------------------------------------------------
SELECT COUNT(*) FROM tweets;

-- ---------------------------------------------------------------------
-- Step: Identify airline accounts
-- Check: full list of company accounts, reviewed by hand (not keyword search)
-- Result: 108 company accounts; 9 airlines:
--   AirAsiaSupport, AlaskaAir, AmericanAir, British_Airways, Delta,
--   JetBlue, SouthwestAir, VirginAmerica, VirginAtlantic
-- Excluded look-alikes: SW_Help (South Western Railway), GWRHelp,
--   LondonMidland, VirginTrains, nationalrailenq, TfL (UK rail/transit),
--   VMUcare (Virgin Mobile). United is not in the dataset.
-- ---------------------------------------------------------------------
SELECT DISTINCT author_id FROM tweets WHERE inbound = 'False' ORDER BY author_id;

-- ---------------------------------------------------------------------
-- Step: 01_airline_tweets.sql
-- Check: airline tweet counts match the source exactly (none dropped/duplicated)
-- Result: matched for all 9 airlines (e.g. Delta 42,253)
--   Totals: 172,815 airline tweets + 188,970 customer tweets = 361,785
-- ---------------------------------------------------------------------
SELECT airline, inbound, COUNT(*) AS n
FROM airline_tweets GROUP BY airline, inbound ORDER BY airline;

-- ---------------------------------------------------------------------
-- Step: 02_conversation_tweets.sql
-- Check: every tweet labeled with a conversation; dates converted
-- Result: 361,785 tweets (all labeled), 113,360 conversations,
--   dates 2008-05-08 to 2017-12-03 in YYYY-MM-DD format
-- ---------------------------------------------------------------------
SELECT COUNT(DISTINCT conversation_id) AS conversations, COUNT(*) AS tweets,
       MIN(created_ts) AS earliest, MAX(created_ts) AS latest
FROM conversation_tweets;

-- ---------------------------------------------------------------------
-- Check: where the data actually falls in time
-- Result: Oct 2017 174,015 | Nov 2017 171,652 | Dec 1-3 2017 14,575
--   Before Oct 2017: 1,543 stray tweets (<0.5%), pulled in by replies
-- Decision: first contacts limited to Oct 1 - Nov 26, 2017, so each has
--   a full 7-day follow-up window before data ends Dec 3 (avoids right-censoring)
-- ---------------------------------------------------------------------
SELECT substr(created_ts, 1, 7) AS month, COUNT(*) AS tweets
FROM conversation_tweets GROUP BY month ORDER BY month;

-- ---------------------------------------------------------------------
-- Step: 03_conversations.sql
-- Check: conversation summary table size and eligible first contacts
-- Result: 113,891 conversations | 113,885 with a customer |
--   100,198 first contacts in window (Oct 1 - Nov 26), before
--   excluding multi-customer threads
-- Note: 113,891 vs 113,360 above = 531 conversations (~0.5%) involving
--   two airlines (grouped by conversation + airline)
-- ---------------------------------------------------------------------
SELECT COUNT(*) AS conversations,
       SUM(customer_id IS NOT NULL) AS with_customer,
       SUM(start_ts BETWEEN '2017-10-01' AND '2017-11-26 23:59:59') AS first_contact_window
FROM conversations;

-- ---------------------------------------------------------------------
-- Step: 04_repeat_pairs.sql (first pass, 7-day window only)
-- Result: 10,649 pairs | 10.6% repeat rate (of 100,198)
--   Under 1 hour: 1,855 | 1-24 hours: 3,831 | 1-7 days: 4,963
-- Open question at the time: were under-1-hour pairs real repeats?
-- Note: 04 has since been updated (see below), so rerunning this
--   query now returns final-rule numbers, not these
-- ---------------------------------------------------------------------
SELECT COUNT(*) AS pairs,
       SUM(gap_hours < 1) AS under_1h,
       SUM(gap_hours >= 1 AND gap_hours < 24) AS h1_to_24,
       SUM(gap_hours >= 24) AS d1_to_7
FROM repeat_pairs;

-- ---------------------------------------------------------------------
-- Check: spot-check of under-1-hour repeats (05_spot_check_short_gaps.sql)
-- Result: 10 random pairs read; 0 were real repeats. All were the same
--   conversation split across threads, or compliment exchanges.
-- Also found: one pair mixed two different customers in one thread
-- Decision: minimum 1-hour gap between first contact and repeat
-- ---------------------------------------------------------------------

-- ---------------------------------------------------------------------
-- Check: conversations with more than one customer replying
-- Result: 3,391 of 113,891 conversations (~3%)
-- Decision: excluded from repeat analysis (n_customers = 1), since
--   mixed threads created false repeats and would confuse AI tagging
-- ---------------------------------------------------------------------
SELECT COUNT(*) AS multi_customer_convs
FROM (SELECT conversation_id, airline FROM conversation_tweets
      WHERE inbound = 'True' GROUP BY conversation_id, airline
      HAVING COUNT(DISTINCT author_id) > 1);

-- ---------------------------------------------------------------------
-- Step: 04_repeat_pairs.sql (final rules)
-- Rules: same customer + airline, next conversation 1 hour to 7 days
--   later, first contact Oct 1 - Nov 26, single-customer threads only
-- Result: 8,475 repeats / 97,327 eligible first contacts = 8.7%
--   (first pass, before these rules: 10,649 / 100,198 = 10.6%)
-- ---------------------------------------------------------------------
SELECT pairs, eligible, ROUND(pairs * 100.0 / eligible, 1) AS repeat_rate_pct
FROM (SELECT (SELECT COUNT(*) FROM repeat_pairs) AS pairs,
             (SELECT COUNT(*) FROM conversations
              WHERE n_customers = 1
                AND start_ts BETWEEN '2017-10-01' AND '2017-11-26 23:59:59') AS eligible);