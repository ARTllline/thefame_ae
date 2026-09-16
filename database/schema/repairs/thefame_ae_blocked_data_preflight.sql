-- TheFame AE: blocked-data preflight and normalization notes
--
-- This file is safe to run as-is: it contains SELECT statements only.
-- Every UPDATE/SET example is commented out intentionally.
-- Do not un-comment anything until a full structure+data backup has been
-- downloaded, inspected and test-restored into a separate database.

SELECT DATABASE() AS connected_database, VERSION() AS mysql_version, @@sql_mode AS sql_mode;

-- ============================================================
-- 1. Missing IDs: AUTO_INCREMENT and PRIMARY KEY are BLOCKED
-- ============================================================

SELECT 'action_events' AS table_name,
       COUNT(*) AS total_rows,
       SUM(id IS NULL) AS null_ids,
       COUNT(DISTINCT id) AS distinct_non_null_ids,
       MIN(id) AS min_id,
       MAX(id) AS max_id,
       COALESCE(MAX(id), 0) + 1 AS proposed_first_new_id
FROM action_events;

SELECT 'appointments' AS table_name,
       COUNT(*) AS total_rows,
       SUM(id IS NULL) AS null_ids,
       COUNT(DISTINCT id) AS distinct_non_null_ids,
       MIN(id) AS min_id,
       MAX(id) AS max_id,
       COALESCE(MAX(id), 0) + 1 AS proposed_first_new_id
FROM appointments;

SELECT 'devices' AS table_name,
       COUNT(*) AS total_rows,
       SUM(id IS NULL) AS null_ids,
       COUNT(DISTINCT id) AS distinct_non_null_ids,
       MIN(id) AS min_id,
       MAX(id) AS max_id,
       COALESCE(MAX(id), 0) + 1 AS proposed_first_new_id
FROM devices;

-- These queries must return zero rows before a PRIMARY KEY is added.
SELECT id, COUNT(*) AS duplicate_count
FROM action_events
WHERE id IS NOT NULL
GROUP BY id
HAVING COUNT(*) > 1;

SELECT id, COUNT(*) AS duplicate_count
FROM appointments
WHERE id IS NOT NULL
GROUP BY id
HAVING COUNT(*) > 1;

SELECT id, COUNT(*) AS duplicate_count
FROM devices
WHERE id IS NOT NULL
GROUP BY id
HAVING COUNT(*) > 1;

-- Potential normalization for action_events and appointments only.
-- These tables have no declared inbound foreign keys in AE migrations.
-- Keep the site in maintenance mode and execute one table per transaction.
--
-- START TRANSACTION;
-- SET @next_action_event_id := (SELECT COALESCE(MAX(id), 0) FROM action_events);
-- UPDATE action_events
-- SET id = (@next_action_event_id := @next_action_event_id + 1)
-- WHERE id IS NULL
-- ORDER BY created_at, batch_id, user_id;
-- SELECT ROW_COUNT() AS assigned_action_event_ids;
-- COMMIT;
--
-- START TRANSACTION;
-- SET @next_appointment_id := (SELECT COALESCE(MAX(id), 0) FROM appointments);
-- UPDATE appointments
-- SET id = (@next_appointment_id := @next_appointment_id + 1)
-- WHERE id IS NULL
-- ORDER BY created_at, phone, name;
-- SELECT ROW_COUNT() AS assigned_appointment_ids;
-- COMMIT;

-- Do not assign devices.id until media relations are reviewed. Spatie media
-- uses a polymorphic model_id rather than a declared SQL foreign key.
SELECT COUNT(*) AS orphan_device_media
FROM media AS m
LEFT JOIN devices AS d ON d.id = m.model_id
WHERE m.model_type = 'App\\Models\\Device'
  AND d.id IS NULL;

-- ============================================================
-- 2. Users: NOT NULL conversion is BLOCKED
-- ============================================================

SELECT
    COUNT(*) AS total_users,
    SUM(email IS NULL) AS null_email,
    SUM(password IS NULL) AS null_password,
    SUM(telegram_id IS NULL) AS null_telegram_id,
    SUM(is_appointment_ua IS NULL) AS null_appointment_ua,
    SUM(is_appointment_dubai IS NULL) AS null_appointment_dubai
FROM users;

-- Check whether generated Telegram email aliases would collide.
SELECT candidate_email, COUNT(*) AS duplicate_count
FROM (
    SELECT CONCAT('telegram_', COALESCE(telegram_id, id), '@telegram.local') AS candidate_email
    FROM users
    WHERE email IS NULL
) AS candidates
GROUP BY candidate_email
HAVING COUNT(*) > 1;

-- Review users that cannot be normalized as Telegram pseudo-users.
SELECT id, email, telegram_login, telegram_name
FROM users
WHERE telegram_id IS NULL;

-- Boolean NULL values can be normalized to the migration defaults only after
-- confirming that NULL did not carry a branch-specific meaning.
-- UPDATE users SET is_appointment_ua = 0 WHERE is_appointment_ua IS NULL;
-- UPDATE users SET is_appointment_dubai = 0 WHERE is_appointment_dubai IS NULL;

-- Do not create password hashes in phpMyAdmin. Use Laravel Hash::make through
-- a reviewed maintenance action or reset the affected accounts individually.
-- Do not place a shared plaintext/default password in SQL.

-- ============================================================
-- 3. Numeric phone columns: historical formatting may be lost
-- ============================================================

SELECT COUNT(*) AS appointments_with_phone,
       MIN(CHAR_LENGTH(CAST(phone AS CHAR))) AS min_length,
       MAX(CHAR_LENGTH(CAST(phone AS CHAR))) AS max_length
FROM appointments
WHERE phone IS NOT NULL;

SELECT COUNT(*) AS orders_with_phone,
       MIN(CHAR_LENGTH(CAST(phone AS CHAR))) AS min_length,
       MAX(CHAR_LENGTH(CAST(phone AS CHAR))) AS max_length
FROM orders
WHERE phone IS NOT NULL;

-- ALTER to VARCHAR preserves the numeric representation that still exists,
-- but cannot recover an already lost leading plus sign or leading zero.
-- Do not prepend a country code globally without a verified business rule.

-- ============================================================
-- 4. Foreign keys: orphaned rows BLOCK constraint creation
-- ============================================================

SELECT c.service_id, COUNT(*) AS orphan_rows
FROM service_categories AS c
LEFT JOIN services AS p ON p.id = c.service_id
WHERE c.service_id IS NOT NULL AND p.id IS NULL
GROUP BY c.service_id
ORDER BY c.service_id;

SELECT c.service_id, COUNT(*) AS orphan_rows
FROM service_variants AS c
LEFT JOIN services AS p ON p.id = c.service_id
WHERE c.service_id IS NOT NULL AND p.id IS NULL
GROUP BY c.service_id
ORDER BY c.service_id;

SELECT c.order_id, COUNT(*) AS orphan_rows
FROM order_items AS c
LEFT JOIN orders AS p ON p.id = c.order_id
WHERE c.order_id IS NOT NULL AND p.id IS NULL
GROUP BY c.order_id
ORDER BY c.order_id;

SELECT c.product_id, COUNT(*) AS orphan_rows
FROM order_items AS c
LEFT JOIN products AS p ON p.id = c.product_id
WHERE c.product_id IS NOT NULL AND p.id IS NULL
GROUP BY c.product_id
ORDER BY c.product_id;

SELECT c.product_id, COUNT(*) AS orphan_rows
FROM product_ingredients AS c
LEFT JOIN products AS p ON p.id = c.product_id
WHERE c.product_id IS NOT NULL AND p.id IS NULL
GROUP BY c.product_id
ORDER BY c.product_id;

SELECT c.product_id, COUNT(*) AS orphan_rows
FROM product_variants AS c
LEFT JOIN products AS p ON p.id = c.product_id
WHERE c.product_id IS NOT NULL AND p.id IS NULL
GROUP BY c.product_id
ORDER BY c.product_id;

-- No DELETE or guessed UPDATE is supplied for orphan rows. Restore the missing
-- parent records from a complete backup, or document an explicit business
-- decision for every key before adding the foreign key.

-- ============================================================
-- 5. JSON conversions confirmed by current AE code
-- ============================================================

SELECT 'ingredients.name' AS column_name,
       COUNT(*) AS total_rows,
       SUM(name IS NOT NULL AND JSON_VALID(CAST(name AS CHAR)) = 0) AS invalid_json,
       MAX(CHAR_LENGTH(CAST(name AS CHAR))) AS max_length
FROM ingredients
UNION ALL
SELECT 'product_categories.name',
       COUNT(*),
       SUM(name IS NOT NULL AND JSON_VALID(CAST(name AS CHAR)) = 0),
       MAX(CHAR_LENGTH(CAST(name AS CHAR)))
FROM product_categories
UNION ALL
SELECT 'abouts.label_dubai',
       COUNT(*),
       SUM(label_dubai IS NOT NULL AND JSON_VALID(CAST(label_dubai AS CHAR)) = 0),
       MAX(CHAR_LENGTH(CAST(label_dubai AS CHAR)))
FROM abouts
UNION ALL
SELECT 'categories.seo_text',
       COUNT(*),
       SUM(seo_text IS NOT NULL AND JSON_VALID(CAST(seo_text AS CHAR)) = 0),
       MAX(CHAR_LENGTH(CAST(seo_text AS CHAR)))
FROM categories;

-- ============================================================
-- 6. Final AUTO_INCREMENT verification
-- ============================================================

SELECT TABLE_NAME, AUTO_INCREMENT
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = DATABASE()
ORDER BY TABLE_NAME;

-- MySQL derives the next AUTO_INCREMENT value from MAX(id) when the repaired
-- column becomes AUTO_INCREMENT. The repair plan never sets AUTO_INCREMENT=1.
