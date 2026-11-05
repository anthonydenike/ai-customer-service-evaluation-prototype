-- Random sample of 120 repeat pairs for AI tagging + hand-labeling
-- Saved as a table so the sample stays fixed.
-- No DROP TABLE on purpose: rerunning this file errors instead of
--   silently drawing a new sample and invalidating labels.
CREATE TABLE sample_pairs AS
SELECT
  ROW_NUMBER() OVER () AS pair_id,
  sampled.*
FROM (
  SELECT * FROM repeat_pairs
  ORDER BY RANDOM()
  LIMIT 120
) sampled;