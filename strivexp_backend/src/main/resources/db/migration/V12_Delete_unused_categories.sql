-- =========================================================
-- Delete unused categories
-- =========================================================

DELETE FROM challenges WHERE category_id = '37441b39-254a-41d8-9918-342bd7cfbdfe'; -- FIT
DELETE FROM challenges WHERE category_id = '830d9dbb-f941-4f52-bde1-1e532beabbe5'; -- MIN
DELETE FROM categories WHERE code = 'FIT';
DELETE FROM categories WHERE code = 'MIN';
