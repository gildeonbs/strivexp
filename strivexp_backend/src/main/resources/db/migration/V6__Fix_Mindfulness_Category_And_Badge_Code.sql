-- =========================================================
-- Fix Mindfulness category and badge code (MBW -> MMW)
-- =========================================================

-- ---------- CATEGORIES ----------
UPDATE categories
SET
    code = 'MMW',
    name = 'Mindfulness & Mental Wellness' 
WHERE code = 'MBW';


-- ---------- BADGES ----------

UPDATE badges
SET
    code = 'MMW'
WHERE code = 'MBW';


