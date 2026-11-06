-- Compare human vs AI labels on the blind accuracy set (pairs 31–60)

-- Load both label files into the database (rebuilt on every run)
DROP TABLE IF EXISTS ai_labels;
.import --csv labels/ai_labels.csv ai_labels

DROP TABLE IF EXISTS human_labels_raw;
.import --csv labels/human_labels_raw.csv human_labels_raw

-- One row per pair: human label, AI label, and whether they match
DROP TABLE IF EXISTS label_comparison;
CREATE TABLE label_comparison AS
SELECT
  CAST(human.pair_id AS INT)                         AS pair_id,
  trim(human.return_reason)                          AS human_reason,
  trim(ai.return_reason)                             AS ai_reason,
  trim(human.fix_owner)                              AS human_owner,
  trim(ai.fix_owner)                                 AS ai_owner,
  trim(human.return_reason) = trim(ai.return_reason) AS reason_match,
  trim(human.fix_owner) = trim(ai.fix_owner)         AS owner_match,
  human.notes                                        AS human_notes,
  ai.rationale                                       AS ai_rationale
FROM human_labels_raw human
JOIN ai_labels ai ON CAST(ai.pair_id AS INT) = CAST(human.pair_id AS INT)
WHERE human.return_reason <> '';

-- Summary: agreement rates
.mode box
SELECT
  COUNT(*)                                                      AS pairs,
  SUM(reason_match)                                             AS reason_agree,
  ROUND(100.0 * SUM(reason_match) / COUNT(*), 1)                AS reason_pct,
  SUM(owner_match)                                              AS owner_agree,
  ROUND(100.0 * SUM(owner_match) / COUNT(*), 1)                 AS owner_pct,
  SUM(reason_match AND owner_match)                             AS both_agree,
  ROUND(100.0 * SUM(reason_match AND owner_match) / COUNT(*), 1) AS both_pct
FROM label_comparison;