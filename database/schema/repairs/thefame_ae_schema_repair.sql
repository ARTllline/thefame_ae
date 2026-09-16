-- TheFame AE production schema recovery plan
-- Generated: 2026-08-11T14:43:31+00:00
-- Source of truth: AE migrations materialized in database/schema/ae_expected_schema.json
-- Target snapshot audited locally: thefame_ae
--
-- SAFETY: every ALTER below is commented out intentionally.
-- 1. Export a full SQL backup with structure + data before doing anything.
-- 2. Run the preflight SELECT statements and require zero blocking rows.
-- 3. Un-comment and execute ONE ALTER at a time, table by table.
-- 4. Re-run php artisan db:audit-schema (or verification SELECTs) after each table.
-- 5. Never delete orphan or duplicate rows merely to make a constraint pass.

SELECT DATABASE() AS connected_database, VERSION() AS mysql_version, @@sql_mode AS sql_mode;
-- Expected database for this snapshot: thefame_ae

-- ============================================================
-- PREFLIGHT: read-only compatibility checks
-- ============================================================

-- [PASS] abouts.id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `abouts` WHERE `id` IS NULL;

-- [PASS] abouts.id.auto_increment_values (snapshot count: 0)
-- AUTO_INCREMENT requires non-null, positive and unique integer values
SELECT COUNT(*) AS aggregate FROM `abouts` WHERE `id` IS NULL OR TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) = '0' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^[0-9]+$';

-- [PASS] abouts.id.auto_increment_duplicates (snapshot count: 0)
-- AUTO_INCREMENT/PRIMARY KEY requires unique values
SELECT COUNT(*) AS aggregate FROM (SELECT `id` FROM `abouts` GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_ids;

-- [PASS] abouts.id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `abouts` WHERE `id` IS NOT NULL AND (TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] abouts.code.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `abouts` WHERE `code` IS NULL;

-- [PASS] abouts.code.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `abouts` WHERE `code` IS NOT NULL AND CHAR_LENGTH(CAST(`code` AS CHAR)) > 255;

-- [PASS] abouts.text_ua.valid_json (snapshot count: 0)
-- TEXT to JSON conversion requires every non-null value to be valid JSON
SELECT COUNT(*) AS aggregate FROM `abouts` WHERE `text_ua` IS NOT NULL AND JSON_VALID(CAST(`text_ua` AS CHAR)) = 0;

-- [PASS] abouts.text_dubai.valid_json (snapshot count: 0)
-- TEXT to JSON conversion requires every non-null value to be valid JSON
SELECT COUNT(*) AS aggregate FROM `abouts` WHERE `text_dubai` IS NOT NULL AND JSON_VALID(CAST(`text_dubai` AS CHAR)) = 0;

-- [PASS] abouts.accent_ua.valid_json (snapshot count: 0)
-- TEXT to JSON conversion requires every non-null value to be valid JSON
SELECT COUNT(*) AS aggregate FROM `abouts` WHERE `accent_ua` IS NOT NULL AND JSON_VALID(CAST(`accent_ua` AS CHAR)) = 0;

-- [PASS] abouts.accent_dubai.valid_json (snapshot count: 0)
-- TEXT to JSON conversion requires every non-null value to be valid JSON
SELECT COUNT(*) AS aggregate FROM `abouts` WHERE `accent_dubai` IS NOT NULL AND JSON_VALID(CAST(`accent_dubai` AS CHAR)) = 0;

-- [PASS] abouts.created_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `abouts` WHERE `created_at` IS NOT NULL AND (TRIM(CAST(`created_at` AS CHAR)) = '' OR TRIM(CAST(`created_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`created_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] abouts.updated_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `abouts` WHERE `updated_at` IS NOT NULL AND (TRIM(CAST(`updated_at` AS CHAR)) = '' OR TRIM(CAST(`updated_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`updated_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] abouts.label_dubai.valid_json (snapshot count: 0)
-- TEXT to JSON conversion requires every non-null value to be valid JSON
SELECT COUNT(*) AS aggregate FROM `abouts` WHERE `label_dubai` IS NOT NULL AND JSON_VALID(CAST(`label_dubai` AS CHAR)) = 0;

-- [BLOCKED] action_events.id.not_null (snapshot count: 188)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `action_events` WHERE `id` IS NULL;

-- [BLOCKED] action_events.id.auto_increment_values (snapshot count: 188)
-- AUTO_INCREMENT requires non-null, positive and unique integer values
SELECT COUNT(*) AS aggregate FROM `action_events` WHERE `id` IS NULL OR TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) = '0' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^[0-9]+$';

-- [BLOCKED] action_events.id.auto_increment_duplicates (snapshot count: 1)
-- AUTO_INCREMENT/PRIMARY KEY requires unique values
SELECT COUNT(*) AS aggregate FROM (SELECT `id` FROM `action_events` GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_ids;

-- [PASS] action_events.id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `action_events` WHERE `id` IS NOT NULL AND (TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] action_events.batch_id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `action_events` WHERE `batch_id` IS NULL;

-- [PASS] action_events.batch_id.max_length (snapshot count: 0)
-- Values must fit the expected char(36)
SELECT COUNT(*) AS aggregate FROM `action_events` WHERE `batch_id` IS NOT NULL AND CHAR_LENGTH(CAST(`batch_id` AS CHAR)) > 36;

-- [PASS] action_events.user_id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `action_events` WHERE `user_id` IS NULL;

-- [PASS] action_events.user_id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `action_events` WHERE `user_id` IS NOT NULL AND (TRIM(CAST(`user_id` AS CHAR)) = '' OR TRIM(CAST(`user_id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`user_id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`user_id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] action_events.name.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `action_events` WHERE `name` IS NULL;

-- [PASS] action_events.name.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `action_events` WHERE `name` IS NOT NULL AND CHAR_LENGTH(CAST(`name` AS CHAR)) > 255;

-- [PASS] action_events.actionable_type.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `action_events` WHERE `actionable_type` IS NULL;

-- [PASS] action_events.actionable_type.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `action_events` WHERE `actionable_type` IS NOT NULL AND CHAR_LENGTH(CAST(`actionable_type` AS CHAR)) > 255;

-- [PASS] action_events.actionable_id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `action_events` WHERE `actionable_id` IS NULL;

-- [PASS] action_events.actionable_id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `action_events` WHERE `actionable_id` IS NOT NULL AND (TRIM(CAST(`actionable_id` AS CHAR)) = '' OR TRIM(CAST(`actionable_id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`actionable_id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`actionable_id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] action_events.target_type.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `action_events` WHERE `target_type` IS NULL;

-- [PASS] action_events.target_type.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `action_events` WHERE `target_type` IS NOT NULL AND CHAR_LENGTH(CAST(`target_type` AS CHAR)) > 255;

-- [PASS] action_events.target_id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `action_events` WHERE `target_id` IS NULL;

-- [PASS] action_events.target_id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `action_events` WHERE `target_id` IS NOT NULL AND (TRIM(CAST(`target_id` AS CHAR)) = '' OR TRIM(CAST(`target_id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`target_id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`target_id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] action_events.model_type.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `action_events` WHERE `model_type` IS NULL;

-- [PASS] action_events.model_type.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `action_events` WHERE `model_type` IS NOT NULL AND CHAR_LENGTH(CAST(`model_type` AS CHAR)) > 255;

-- [PASS] action_events.model_id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `action_events` WHERE `model_id` IS NOT NULL AND (TRIM(CAST(`model_id` AS CHAR)) = '' OR TRIM(CAST(`model_id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`model_id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`model_id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] action_events.fields.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `action_events` WHERE `fields` IS NULL;

-- [PASS] action_events.status.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `action_events` WHERE `status` IS NULL;

-- [PASS] action_events.status.max_length (snapshot count: 0)
-- Values must fit the expected varchar(25)
SELECT COUNT(*) AS aggregate FROM `action_events` WHERE `status` IS NOT NULL AND CHAR_LENGTH(CAST(`status` AS CHAR)) > 25;

-- [PASS] action_events.exception.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `action_events` WHERE `exception` IS NULL;

-- [PASS] action_events.created_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `action_events` WHERE `created_at` IS NOT NULL AND (TRIM(CAST(`created_at` AS CHAR)) = '' OR TRIM(CAST(`created_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`created_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] action_events.updated_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `action_events` WHERE `updated_at` IS NOT NULL AND (TRIM(CAST(`updated_at` AS CHAR)) = '' OR TRIM(CAST(`updated_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`updated_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [BLOCKED] appointments.id.not_null (snapshot count: 16)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `appointments` WHERE `id` IS NULL;

-- [BLOCKED] appointments.id.auto_increment_values (snapshot count: 16)
-- AUTO_INCREMENT requires non-null, positive and unique integer values
SELECT COUNT(*) AS aggregate FROM `appointments` WHERE `id` IS NULL OR TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) = '0' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^[0-9]+$';

-- [BLOCKED] appointments.id.auto_increment_duplicates (snapshot count: 1)
-- AUTO_INCREMENT/PRIMARY KEY requires unique values
SELECT COUNT(*) AS aggregate FROM (SELECT `id` FROM `appointments` GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_ids;

-- [PASS] appointments.id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `appointments` WHERE `id` IS NOT NULL AND (TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] appointments.name.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `appointments` WHERE `name` IS NOT NULL AND CHAR_LENGTH(CAST(`name` AS CHAR)) > 255;

-- [PASS] appointments.phone.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `appointments` WHERE `phone` IS NOT NULL AND CHAR_LENGTH(CAST(`phone` AS CHAR)) > 255;

-- [REVIEW] appointments.phone.numeric_to_text_review (snapshot count: -)
-- Manual review: the damaged numeric column may already have lost formatting such as leading zeroes or plus signs

-- [PASS] appointments.region.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `appointments` WHERE `region` IS NOT NULL AND CHAR_LENGTH(CAST(`region` AS CHAR)) > 255;

-- [PASS] appointments.utm_source.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `appointments` WHERE `utm_source` IS NOT NULL AND CHAR_LENGTH(CAST(`utm_source` AS CHAR)) > 255;

-- [PASS] appointments.utm_medium.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `appointments` WHERE `utm_medium` IS NOT NULL AND CHAR_LENGTH(CAST(`utm_medium` AS CHAR)) > 255;

-- [PASS] appointments.utm_campaign.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `appointments` WHERE `utm_campaign` IS NOT NULL AND CHAR_LENGTH(CAST(`utm_campaign` AS CHAR)) > 255;

-- [PASS] appointments.utm_term.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `appointments` WHERE `utm_term` IS NOT NULL AND CHAR_LENGTH(CAST(`utm_term` AS CHAR)) > 255;

-- [PASS] appointments.utm_content.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `appointments` WHERE `utm_content` IS NOT NULL AND CHAR_LENGTH(CAST(`utm_content` AS CHAR)) > 255;

-- [PASS] appointments.email.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `appointments` WHERE `email` IS NOT NULL AND CHAR_LENGTH(CAST(`email` AS CHAR)) > 255;

-- [PASS] appointments.goal.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `appointments` WHERE `goal` IS NOT NULL AND CHAR_LENGTH(CAST(`goal` AS CHAR)) > 255;

-- [PASS] appointments.from_page.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `appointments` WHERE `from_page` IS NOT NULL AND CHAR_LENGTH(CAST(`from_page` AS CHAR)) > 255;

-- [PASS] appointments.created_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `appointments` WHERE `created_at` IS NOT NULL AND (TRIM(CAST(`created_at` AS CHAR)) = '' OR TRIM(CAST(`created_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`created_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] appointments.updated_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `appointments` WHERE `updated_at` IS NOT NULL AND (TRIM(CAST(`updated_at` AS CHAR)) = '' OR TRIM(CAST(`updated_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`updated_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] banners.id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `banners` WHERE `id` IS NULL;

-- [PASS] banners.id.auto_increment_values (snapshot count: 0)
-- AUTO_INCREMENT requires non-null, positive and unique integer values
SELECT COUNT(*) AS aggregate FROM `banners` WHERE `id` IS NULL OR TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) = '0' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^[0-9]+$';

-- [PASS] banners.id.auto_increment_duplicates (snapshot count: 0)
-- AUTO_INCREMENT/PRIMARY KEY requires unique values
SELECT COUNT(*) AS aggregate FROM (SELECT `id` FROM `banners` GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_ids;

-- [PASS] banners.id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `banners` WHERE `id` IS NOT NULL AND (TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] banners.title.valid_json (snapshot count: 0)
-- TEXT to JSON conversion requires every non-null value to be valid JSON
SELECT COUNT(*) AS aggregate FROM `banners` WHERE `title` IS NOT NULL AND JSON_VALID(CAST(`title` AS CHAR)) = 0;

-- [PASS] banners.is_show.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `banners` WHERE `is_show` IS NULL;

-- [PASS] banners.is_show.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers restricted to 0/1
SELECT COUNT(*) AS aggregate FROM `banners` WHERE `is_show` IS NOT NULL AND (TRIM(CAST(`is_show` AS CHAR)) = '' OR TRIM(CAST(`is_show` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`is_show` AS CHAR)) AS DECIMAL(65,0)) < -128 OR CAST(TRIM(CAST(`is_show` AS CHAR)) AS DECIMAL(65,0)) > 127 OR TRIM(CAST(`is_show` AS CHAR)) NOT IN ('0', '1'));

-- [PASS] banners.created_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `banners` WHERE `created_at` IS NOT NULL AND (TRIM(CAST(`created_at` AS CHAR)) = '' OR TRIM(CAST(`created_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`created_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] banners.updated_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `banners` WHERE `updated_at` IS NOT NULL AND (TRIM(CAST(`updated_at` AS CHAR)) = '' OR TRIM(CAST(`updated_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`updated_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] call_us.id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `call_us` WHERE `id` IS NULL;

-- [PASS] call_us.id.auto_increment_values (snapshot count: 0)
-- AUTO_INCREMENT requires non-null, positive and unique integer values
SELECT COUNT(*) AS aggregate FROM `call_us` WHERE `id` IS NULL OR TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) = '0' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^[0-9]+$';

-- [PASS] call_us.id.auto_increment_duplicates (snapshot count: 0)
-- AUTO_INCREMENT/PRIMARY KEY requires unique values
SELECT COUNT(*) AS aggregate FROM (SELECT `id` FROM `call_us` GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_ids;

-- [PASS] call_us.id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `call_us` WHERE `id` IS NOT NULL AND (TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] call_us.text.valid_json (snapshot count: 0)
-- TEXT to JSON conversion requires every non-null value to be valid JSON
SELECT COUNT(*) AS aggregate FROM `call_us` WHERE `text` IS NOT NULL AND JSON_VALID(CAST(`text` AS CHAR)) = 0;

-- [PASS] call_us.phone_ua.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `call_us` WHERE `phone_ua` IS NOT NULL AND CHAR_LENGTH(CAST(`phone_ua` AS CHAR)) > 255;

-- [PASS] call_us.email_ua.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `call_us` WHERE `email_ua` IS NOT NULL AND CHAR_LENGTH(CAST(`email_ua` AS CHAR)) > 255;

-- [PASS] call_us.phone_dubai.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `call_us` WHERE `phone_dubai` IS NOT NULL AND CHAR_LENGTH(CAST(`phone_dubai` AS CHAR)) > 255;

-- [PASS] call_us.email_dubai.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `call_us` WHERE `email_dubai` IS NOT NULL AND CHAR_LENGTH(CAST(`email_dubai` AS CHAR)) > 255;

-- [PASS] call_us.created_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `call_us` WHERE `created_at` IS NOT NULL AND (TRIM(CAST(`created_at` AS CHAR)) = '' OR TRIM(CAST(`created_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`created_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] call_us.updated_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `call_us` WHERE `updated_at` IS NOT NULL AND (TRIM(CAST(`updated_at` AS CHAR)) = '' OR TRIM(CAST(`updated_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`updated_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] categories.id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `categories` WHERE `id` IS NULL;

-- [PASS] categories.id.auto_increment_values (snapshot count: 0)
-- AUTO_INCREMENT requires non-null, positive and unique integer values
SELECT COUNT(*) AS aggregate FROM `categories` WHERE `id` IS NULL OR TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) = '0' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^[0-9]+$';

-- [PASS] categories.id.auto_increment_duplicates (snapshot count: 0)
-- AUTO_INCREMENT/PRIMARY KEY requires unique values
SELECT COUNT(*) AS aggregate FROM (SELECT `id` FROM `categories` GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_ids;

-- [PASS] categories.id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `categories` WHERE `id` IS NOT NULL AND (TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] categories.title.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `categories` WHERE `title` IS NULL;

-- [PASS] categories.title.valid_json (snapshot count: 0)
-- TEXT to JSON conversion requires every non-null value to be valid JSON
SELECT COUNT(*) AS aggregate FROM `categories` WHERE `title` IS NOT NULL AND JSON_VALID(CAST(`title` AS CHAR)) = 0;

-- [PASS] categories.description.valid_json (snapshot count: 0)
-- TEXT to JSON conversion requires every non-null value to be valid JSON
SELECT COUNT(*) AS aggregate FROM `categories` WHERE `description` IS NOT NULL AND JSON_VALID(CAST(`description` AS CHAR)) = 0;

-- [PASS] categories.order.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `categories` WHERE `order` IS NULL;

-- [PASS] categories.order.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `categories` WHERE `order` IS NOT NULL AND (TRIM(CAST(`order` AS CHAR)) = '' OR TRIM(CAST(`order` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`order` AS CHAR)) AS DECIMAL(65,0)) < -2147483648 OR CAST(TRIM(CAST(`order` AS CHAR)) AS DECIMAL(65,0)) > 2147483647);

-- [PASS] categories.created_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `categories` WHERE `created_at` IS NOT NULL AND (TRIM(CAST(`created_at` AS CHAR)) = '' OR TRIM(CAST(`created_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`created_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] categories.updated_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `categories` WHERE `updated_at` IS NOT NULL AND (TRIM(CAST(`updated_at` AS CHAR)) = '' OR TRIM(CAST(`updated_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`updated_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] categories.seo_text.valid_json (snapshot count: 0)
-- TEXT to JSON conversion requires every non-null value to be valid JSON
SELECT COUNT(*) AS aggregate FROM `categories` WHERE `seo_text` IS NOT NULL AND JSON_VALID(CAST(`seo_text` AS CHAR)) = 0;

-- [PASS] contacts.id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `contacts` WHERE `id` IS NULL;

-- [PASS] contacts.id.auto_increment_values (snapshot count: 0)
-- AUTO_INCREMENT requires non-null, positive and unique integer values
SELECT COUNT(*) AS aggregate FROM `contacts` WHERE `id` IS NULL OR TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) = '0' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^[0-9]+$';

-- [PASS] contacts.id.auto_increment_duplicates (snapshot count: 0)
-- AUTO_INCREMENT/PRIMARY KEY requires unique values
SELECT COUNT(*) AS aggregate FROM (SELECT `id` FROM `contacts` GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_ids;

-- [PASS] contacts.id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `contacts` WHERE `id` IS NOT NULL AND (TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] contacts.email.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `contacts` WHERE `email` IS NOT NULL AND CHAR_LENGTH(CAST(`email` AS CHAR)) > 255;

-- [PASS] contacts.phone.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `contacts` WHERE `phone` IS NOT NULL AND CHAR_LENGTH(CAST(`phone` AS CHAR)) > 255;

-- [PASS] contacts.address.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `contacts` WHERE `address` IS NOT NULL AND CHAR_LENGTH(CAST(`address` AS CHAR)) > 255;

-- [PASS] contacts.map_point.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `contacts` WHERE `map_point` IS NOT NULL AND CHAR_LENGTH(CAST(`map_point` AS CHAR)) > 255;

-- [PASS] contacts.order.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `contacts` WHERE `order` IS NULL;

-- [PASS] contacts.order.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `contacts` WHERE `order` IS NOT NULL AND (TRIM(CAST(`order` AS CHAR)) = '' OR TRIM(CAST(`order` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`order` AS CHAR)) AS DECIMAL(65,0)) < -9223372036854775808 OR CAST(TRIM(CAST(`order` AS CHAR)) AS DECIMAL(65,0)) > 9223372036854775807);

-- [PASS] contacts.created_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `contacts` WHERE `created_at` IS NOT NULL AND (TRIM(CAST(`created_at` AS CHAR)) = '' OR TRIM(CAST(`created_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`created_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] contacts.updated_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `contacts` WHERE `updated_at` IS NOT NULL AND (TRIM(CAST(`updated_at` AS CHAR)) = '' OR TRIM(CAST(`updated_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`updated_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [BLOCKED] devices.id.not_null (snapshot count: 4)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `devices` WHERE `id` IS NULL;

-- [BLOCKED] devices.id.auto_increment_values (snapshot count: 4)
-- AUTO_INCREMENT requires non-null, positive and unique integer values
SELECT COUNT(*) AS aggregate FROM `devices` WHERE `id` IS NULL OR TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) = '0' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^[0-9]+$';

-- [BLOCKED] devices.id.auto_increment_duplicates (snapshot count: 1)
-- AUTO_INCREMENT/PRIMARY KEY requires unique values
SELECT COUNT(*) AS aggregate FROM (SELECT `id` FROM `devices` GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_ids;

-- [PASS] devices.id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `devices` WHERE `id` IS NOT NULL AND (TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] devices.region_id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `devices` WHERE `region_id` IS NOT NULL AND (TRIM(CAST(`region_id` AS CHAR)) = '' OR TRIM(CAST(`region_id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`region_id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`region_id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] devices.code.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `devices` WHERE `code` IS NOT NULL AND CHAR_LENGTH(CAST(`code` AS CHAR)) > 255;

-- [PASS] devices.title.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `devices` WHERE `title` IS NULL;

-- [PASS] devices.title.valid_json (snapshot count: 0)
-- TEXT to JSON conversion requires every non-null value to be valid JSON
SELECT COUNT(*) AS aggregate FROM `devices` WHERE `title` IS NOT NULL AND JSON_VALID(CAST(`title` AS CHAR)) = 0;

-- [PASS] devices.description.valid_json (snapshot count: 0)
-- TEXT to JSON conversion requires every non-null value to be valid JSON
SELECT COUNT(*) AS aggregate FROM `devices` WHERE `description` IS NOT NULL AND JSON_VALID(CAST(`description` AS CHAR)) = 0;

-- [PASS] devices.order.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `devices` WHERE `order` IS NULL;

-- [PASS] devices.order.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `devices` WHERE `order` IS NOT NULL AND (TRIM(CAST(`order` AS CHAR)) = '' OR TRIM(CAST(`order` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`order` AS CHAR)) AS DECIMAL(65,0)) < -2147483648 OR CAST(TRIM(CAST(`order` AS CHAR)) AS DECIMAL(65,0)) > 2147483647);

-- [PASS] devices.created_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `devices` WHERE `created_at` IS NOT NULL AND (TRIM(CAST(`created_at` AS CHAR)) = '' OR TRIM(CAST(`created_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`created_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] devices.updated_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `devices` WHERE `updated_at` IS NOT NULL AND (TRIM(CAST(`updated_at` AS CHAR)) = '' OR TRIM(CAST(`updated_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`updated_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] failed_jobs.id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `failed_jobs` WHERE `id` IS NULL;

-- [PASS] failed_jobs.id.auto_increment_values (snapshot count: 0)
-- AUTO_INCREMENT requires non-null, positive and unique integer values
SELECT COUNT(*) AS aggregate FROM `failed_jobs` WHERE `id` IS NULL OR TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) = '0' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^[0-9]+$';

-- [PASS] failed_jobs.id.auto_increment_duplicates (snapshot count: 0)
-- AUTO_INCREMENT/PRIMARY KEY requires unique values
SELECT COUNT(*) AS aggregate FROM (SELECT `id` FROM `failed_jobs` GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_ids;

-- [PASS] failed_jobs.id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `failed_jobs` WHERE `id` IS NOT NULL AND (TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] failed_jobs.uuid.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `failed_jobs` WHERE `uuid` IS NULL;

-- [PASS] failed_jobs.uuid.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `failed_jobs` WHERE `uuid` IS NOT NULL AND CHAR_LENGTH(CAST(`uuid` AS CHAR)) > 255;

-- [PASS] failed_jobs.connection.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `failed_jobs` WHERE `connection` IS NULL;

-- [PASS] failed_jobs.queue.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `failed_jobs` WHERE `queue` IS NULL;

-- [PASS] failed_jobs.payload.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `failed_jobs` WHERE `payload` IS NULL;

-- [PASS] failed_jobs.exception.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `failed_jobs` WHERE `exception` IS NULL;

-- [PASS] failed_jobs.failed_at.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `failed_jobs` WHERE `failed_at` IS NULL;

-- [PASS] failed_jobs.failed_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `failed_jobs` WHERE `failed_at` IS NOT NULL AND (TRIM(CAST(`failed_at` AS CHAR)) = '' OR TRIM(CAST(`failed_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`failed_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] galleries.id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `galleries` WHERE `id` IS NULL;

-- [PASS] galleries.id.auto_increment_values (snapshot count: 0)
-- AUTO_INCREMENT requires non-null, positive and unique integer values
SELECT COUNT(*) AS aggregate FROM `galleries` WHERE `id` IS NULL OR TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) = '0' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^[0-9]+$';

-- [PASS] galleries.id.auto_increment_duplicates (snapshot count: 0)
-- AUTO_INCREMENT/PRIMARY KEY requires unique values
SELECT COUNT(*) AS aggregate FROM (SELECT `id` FROM `galleries` GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_ids;

-- [PASS] galleries.id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `galleries` WHERE `id` IS NOT NULL AND (TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] galleries.title.valid_json (snapshot count: 0)
-- TEXT to JSON conversion requires every non-null value to be valid JSON
SELECT COUNT(*) AS aggregate FROM `galleries` WHERE `title` IS NOT NULL AND JSON_VALID(CAST(`title` AS CHAR)) = 0;

-- [PASS] galleries.is_show.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `galleries` WHERE `is_show` IS NULL;

-- [PASS] galleries.is_show.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers restricted to 0/1
SELECT COUNT(*) AS aggregate FROM `galleries` WHERE `is_show` IS NOT NULL AND (TRIM(CAST(`is_show` AS CHAR)) = '' OR TRIM(CAST(`is_show` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`is_show` AS CHAR)) AS DECIMAL(65,0)) < -128 OR CAST(TRIM(CAST(`is_show` AS CHAR)) AS DECIMAL(65,0)) > 127 OR TRIM(CAST(`is_show` AS CHAR)) NOT IN ('0', '1'));

-- [PASS] galleries.region_id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `galleries` WHERE `region_id` IS NOT NULL AND (TRIM(CAST(`region_id` AS CHAR)) = '' OR TRIM(CAST(`region_id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`region_id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`region_id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] galleries.created_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `galleries` WHERE `created_at` IS NOT NULL AND (TRIM(CAST(`created_at` AS CHAR)) = '' OR TRIM(CAST(`created_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`created_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] galleries.updated_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `galleries` WHERE `updated_at` IS NOT NULL AND (TRIM(CAST(`updated_at` AS CHAR)) = '' OR TRIM(CAST(`updated_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`updated_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] ingredients.id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `ingredients` WHERE `id` IS NULL;

-- [PASS] ingredients.id.auto_increment_values (snapshot count: 0)
-- AUTO_INCREMENT requires non-null, positive and unique integer values
SELECT COUNT(*) AS aggregate FROM `ingredients` WHERE `id` IS NULL OR TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) = '0' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^[0-9]+$';

-- [PASS] ingredients.id.auto_increment_duplicates (snapshot count: 0)
-- AUTO_INCREMENT/PRIMARY KEY requires unique values
SELECT COUNT(*) AS aggregate FROM (SELECT `id` FROM `ingredients` GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_ids;

-- [PASS] ingredients.id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `ingredients` WHERE `id` IS NOT NULL AND (TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] ingredients.name.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `ingredients` WHERE `name` IS NULL;

-- [PASS] ingredients.name.valid_json (snapshot count: 0)
-- TEXT to JSON conversion requires every non-null value to be valid JSON
SELECT COUNT(*) AS aggregate FROM `ingredients` WHERE `name` IS NOT NULL AND JSON_VALID(CAST(`name` AS CHAR)) = 0;

-- [PASS] ingredients.is_active.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `ingredients` WHERE `is_active` IS NULL;

-- [PASS] ingredients.is_active.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers restricted to 0/1
SELECT COUNT(*) AS aggregate FROM `ingredients` WHERE `is_active` IS NOT NULL AND (TRIM(CAST(`is_active` AS CHAR)) = '' OR TRIM(CAST(`is_active` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`is_active` AS CHAR)) AS DECIMAL(65,0)) < -128 OR CAST(TRIM(CAST(`is_active` AS CHAR)) AS DECIMAL(65,0)) > 127 OR TRIM(CAST(`is_active` AS CHAR)) NOT IN ('0', '1'));

-- [PASS] ingredients.is_show_filter.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `ingredients` WHERE `is_show_filter` IS NULL;

-- [PASS] ingredients.is_show_filter.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers restricted to 0/1
SELECT COUNT(*) AS aggregate FROM `ingredients` WHERE `is_show_filter` IS NOT NULL AND (TRIM(CAST(`is_show_filter` AS CHAR)) = '' OR TRIM(CAST(`is_show_filter` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`is_show_filter` AS CHAR)) AS DECIMAL(65,0)) < -128 OR CAST(TRIM(CAST(`is_show_filter` AS CHAR)) AS DECIMAL(65,0)) > 127 OR TRIM(CAST(`is_show_filter` AS CHAR)) NOT IN ('0', '1'));

-- [PASS] ingredients.order.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `ingredients` WHERE `order` IS NULL;

-- [PASS] ingredients.order.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `ingredients` WHERE `order` IS NOT NULL AND (TRIM(CAST(`order` AS CHAR)) = '' OR TRIM(CAST(`order` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`order` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`order` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] ingredients.created_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `ingredients` WHERE `created_at` IS NOT NULL AND (TRIM(CAST(`created_at` AS CHAR)) = '' OR TRIM(CAST(`created_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`created_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] ingredients.updated_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `ingredients` WHERE `updated_at` IS NOT NULL AND (TRIM(CAST(`updated_at` AS CHAR)) = '' OR TRIM(CAST(`updated_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`updated_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] ingredients.seo_text.valid_json (snapshot count: 0)
-- TEXT to JSON conversion requires every non-null value to be valid JSON
SELECT COUNT(*) AS aggregate FROM `ingredients` WHERE `seo_text` IS NOT NULL AND JSON_VALID(CAST(`seo_text` AS CHAR)) = 0;

-- [PASS] ingredients.slug.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `ingredients` WHERE `slug` IS NOT NULL AND CHAR_LENGTH(CAST(`slug` AS CHAR)) > 255;

-- [PASS] ingredients.is_show_nav.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `ingredients` WHERE `is_show_nav` IS NULL;

-- [PASS] ingredients.is_show_nav.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers restricted to 0/1
SELECT COUNT(*) AS aggregate FROM `ingredients` WHERE `is_show_nav` IS NOT NULL AND (TRIM(CAST(`is_show_nav` AS CHAR)) = '' OR TRIM(CAST(`is_show_nav` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`is_show_nav` AS CHAR)) AS DECIMAL(65,0)) < -128 OR CAST(TRIM(CAST(`is_show_nav` AS CHAR)) AS DECIMAL(65,0)) > 127 OR TRIM(CAST(`is_show_nav` AS CHAR)) NOT IN ('0', '1'));

-- [PASS] locations.id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `locations` WHERE `id` IS NULL;

-- [PASS] locations.id.auto_increment_values (snapshot count: 0)
-- AUTO_INCREMENT requires non-null, positive and unique integer values
SELECT COUNT(*) AS aggregate FROM `locations` WHERE `id` IS NULL OR TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) = '0' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^[0-9]+$';

-- [PASS] locations.id.auto_increment_duplicates (snapshot count: 0)
-- AUTO_INCREMENT/PRIMARY KEY requires unique values
SELECT COUNT(*) AS aggregate FROM (SELECT `id` FROM `locations` GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_ids;

-- [PASS] locations.id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `locations` WHERE `id` IS NOT NULL AND (TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] locations.title.valid_json (snapshot count: 0)
-- TEXT to JSON conversion requires every non-null value to be valid JSON
SELECT COUNT(*) AS aggregate FROM `locations` WHERE `title` IS NOT NULL AND JSON_VALID(CAST(`title` AS CHAR)) = 0;

-- [PASS] locations.subtitle.valid_json (snapshot count: 0)
-- TEXT to JSON conversion requires every non-null value to be valid JSON
SELECT COUNT(*) AS aggregate FROM `locations` WHERE `subtitle` IS NOT NULL AND JSON_VALID(CAST(`subtitle` AS CHAR)) = 0;

-- [PASS] locations.phone.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `locations` WHERE `phone` IS NOT NULL AND CHAR_LENGTH(CAST(`phone` AS CHAR)) > 255;

-- [PASS] locations.email.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `locations` WHERE `email` IS NOT NULL AND CHAR_LENGTH(CAST(`email` AS CHAR)) > 255;

-- [PASS] locations.created_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `locations` WHERE `created_at` IS NOT NULL AND (TRIM(CAST(`created_at` AS CHAR)) = '' OR TRIM(CAST(`created_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`created_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] locations.updated_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `locations` WHERE `updated_at` IS NOT NULL AND (TRIM(CAST(`updated_at` AS CHAR)) = '' OR TRIM(CAST(`updated_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`updated_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] media.id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `media` WHERE `id` IS NULL;

-- [PASS] media.id.auto_increment_values (snapshot count: 0)
-- AUTO_INCREMENT requires non-null, positive and unique integer values
SELECT COUNT(*) AS aggregate FROM `media` WHERE `id` IS NULL OR TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) = '0' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^[0-9]+$';

-- [PASS] media.id.auto_increment_duplicates (snapshot count: 0)
-- AUTO_INCREMENT/PRIMARY KEY requires unique values
SELECT COUNT(*) AS aggregate FROM (SELECT `id` FROM `media` GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_ids;

-- [PASS] media.id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `media` WHERE `id` IS NOT NULL AND (TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] media.model_type.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `media` WHERE `model_type` IS NULL;

-- [PASS] media.model_type.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `media` WHERE `model_type` IS NOT NULL AND CHAR_LENGTH(CAST(`model_type` AS CHAR)) > 255;

-- [PASS] media.model_id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `media` WHERE `model_id` IS NULL;

-- [PASS] media.model_id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `media` WHERE `model_id` IS NOT NULL AND (TRIM(CAST(`model_id` AS CHAR)) = '' OR TRIM(CAST(`model_id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`model_id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`model_id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] media.uuid.max_length (snapshot count: 0)
-- Values must fit the expected char(36)
SELECT COUNT(*) AS aggregate FROM `media` WHERE `uuid` IS NOT NULL AND CHAR_LENGTH(CAST(`uuid` AS CHAR)) > 36;

-- [PASS] media.collection_name.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `media` WHERE `collection_name` IS NULL;

-- [PASS] media.collection_name.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `media` WHERE `collection_name` IS NOT NULL AND CHAR_LENGTH(CAST(`collection_name` AS CHAR)) > 255;

-- [PASS] media.name.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `media` WHERE `name` IS NULL;

-- [PASS] media.name.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `media` WHERE `name` IS NOT NULL AND CHAR_LENGTH(CAST(`name` AS CHAR)) > 255;

-- [PASS] media.file_name.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `media` WHERE `file_name` IS NULL;

-- [PASS] media.file_name.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `media` WHERE `file_name` IS NOT NULL AND CHAR_LENGTH(CAST(`file_name` AS CHAR)) > 255;

-- [PASS] media.mime_type.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `media` WHERE `mime_type` IS NOT NULL AND CHAR_LENGTH(CAST(`mime_type` AS CHAR)) > 255;

-- [PASS] media.disk.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `media` WHERE `disk` IS NULL;

-- [PASS] media.disk.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `media` WHERE `disk` IS NOT NULL AND CHAR_LENGTH(CAST(`disk` AS CHAR)) > 255;

-- [PASS] media.conversions_disk.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `media` WHERE `conversions_disk` IS NOT NULL AND CHAR_LENGTH(CAST(`conversions_disk` AS CHAR)) > 255;

-- [PASS] media.size.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `media` WHERE `size` IS NULL;

-- [PASS] media.size.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `media` WHERE `size` IS NOT NULL AND (TRIM(CAST(`size` AS CHAR)) = '' OR TRIM(CAST(`size` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`size` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`size` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] media.manipulations.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `media` WHERE `manipulations` IS NULL;

-- [PASS] media.manipulations.valid_json (snapshot count: 0)
-- TEXT to JSON conversion requires every non-null value to be valid JSON
SELECT COUNT(*) AS aggregate FROM `media` WHERE `manipulations` IS NOT NULL AND JSON_VALID(CAST(`manipulations` AS CHAR)) = 0;

-- [PASS] media.custom_properties.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `media` WHERE `custom_properties` IS NULL;

-- [PASS] media.custom_properties.valid_json (snapshot count: 0)
-- TEXT to JSON conversion requires every non-null value to be valid JSON
SELECT COUNT(*) AS aggregate FROM `media` WHERE `custom_properties` IS NOT NULL AND JSON_VALID(CAST(`custom_properties` AS CHAR)) = 0;

-- [PASS] media.generated_conversions.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `media` WHERE `generated_conversions` IS NULL;

-- [PASS] media.generated_conversions.valid_json (snapshot count: 0)
-- TEXT to JSON conversion requires every non-null value to be valid JSON
SELECT COUNT(*) AS aggregate FROM `media` WHERE `generated_conversions` IS NOT NULL AND JSON_VALID(CAST(`generated_conversions` AS CHAR)) = 0;

-- [PASS] media.responsive_images.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `media` WHERE `responsive_images` IS NULL;

-- [PASS] media.responsive_images.valid_json (snapshot count: 0)
-- TEXT to JSON conversion requires every non-null value to be valid JSON
SELECT COUNT(*) AS aggregate FROM `media` WHERE `responsive_images` IS NOT NULL AND JSON_VALID(CAST(`responsive_images` AS CHAR)) = 0;

-- [PASS] media.order_column.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `media` WHERE `order_column` IS NOT NULL AND (TRIM(CAST(`order_column` AS CHAR)) = '' OR TRIM(CAST(`order_column` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`order_column` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`order_column` AS CHAR)) AS DECIMAL(65,0)) > 4294967295);

-- [PASS] media.created_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `media` WHERE `created_at` IS NOT NULL AND (TRIM(CAST(`created_at` AS CHAR)) = '' OR TRIM(CAST(`created_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`created_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] media.updated_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `media` WHERE `updated_at` IS NOT NULL AND (TRIM(CAST(`updated_at` AS CHAR)) = '' OR TRIM(CAST(`updated_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`updated_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] migrations.id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `migrations` WHERE `id` IS NULL;

-- [PASS] migrations.id.auto_increment_values (snapshot count: 0)
-- AUTO_INCREMENT requires non-null, positive and unique integer values
SELECT COUNT(*) AS aggregate FROM `migrations` WHERE `id` IS NULL OR TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) = '0' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^[0-9]+$';

-- [PASS] migrations.id.auto_increment_duplicates (snapshot count: 0)
-- AUTO_INCREMENT/PRIMARY KEY requires unique values
SELECT COUNT(*) AS aggregate FROM (SELECT `id` FROM `migrations` GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_ids;

-- [PASS] migrations.id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `migrations` WHERE `id` IS NOT NULL AND (TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) > 4294967295);

-- [PASS] migrations.migration.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `migrations` WHERE `migration` IS NULL;

-- [PASS] migrations.migration.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `migrations` WHERE `migration` IS NOT NULL AND CHAR_LENGTH(CAST(`migration` AS CHAR)) > 255;

-- [PASS] migrations.batch.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `migrations` WHERE `batch` IS NULL;

-- [PASS] migrations.batch.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `migrations` WHERE `batch` IS NOT NULL AND (TRIM(CAST(`batch` AS CHAR)) = '' OR TRIM(CAST(`batch` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`batch` AS CHAR)) AS DECIMAL(65,0)) < -2147483648 OR CAST(TRIM(CAST(`batch` AS CHAR)) AS DECIMAL(65,0)) > 2147483647);

-- [PASS] nova_field_attachments.id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `nova_field_attachments` WHERE `id` IS NULL;

-- [PASS] nova_field_attachments.id.auto_increment_values (snapshot count: 0)
-- AUTO_INCREMENT requires non-null, positive and unique integer values
SELECT COUNT(*) AS aggregate FROM `nova_field_attachments` WHERE `id` IS NULL OR TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) = '0' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^[0-9]+$';

-- [PASS] nova_field_attachments.id.auto_increment_duplicates (snapshot count: 0)
-- AUTO_INCREMENT/PRIMARY KEY requires unique values
SELECT COUNT(*) AS aggregate FROM (SELECT `id` FROM `nova_field_attachments` GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_ids;

-- [PASS] nova_field_attachments.id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `nova_field_attachments` WHERE `id` IS NOT NULL AND (TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) > 4294967295);

-- [PASS] nova_field_attachments.attachable_type.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `nova_field_attachments` WHERE `attachable_type` IS NULL;

-- [PASS] nova_field_attachments.attachable_type.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `nova_field_attachments` WHERE `attachable_type` IS NOT NULL AND CHAR_LENGTH(CAST(`attachable_type` AS CHAR)) > 255;

-- [PASS] nova_field_attachments.attachable_id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `nova_field_attachments` WHERE `attachable_id` IS NULL;

-- [PASS] nova_field_attachments.attachable_id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `nova_field_attachments` WHERE `attachable_id` IS NOT NULL AND (TRIM(CAST(`attachable_id` AS CHAR)) = '' OR TRIM(CAST(`attachable_id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`attachable_id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`attachable_id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] nova_field_attachments.attachment.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `nova_field_attachments` WHERE `attachment` IS NULL;

-- [PASS] nova_field_attachments.attachment.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `nova_field_attachments` WHERE `attachment` IS NOT NULL AND CHAR_LENGTH(CAST(`attachment` AS CHAR)) > 255;

-- [PASS] nova_field_attachments.disk.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `nova_field_attachments` WHERE `disk` IS NULL;

-- [PASS] nova_field_attachments.disk.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `nova_field_attachments` WHERE `disk` IS NOT NULL AND CHAR_LENGTH(CAST(`disk` AS CHAR)) > 255;

-- [PASS] nova_field_attachments.url.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `nova_field_attachments` WHERE `url` IS NULL;

-- [PASS] nova_field_attachments.url.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `nova_field_attachments` WHERE `url` IS NOT NULL AND CHAR_LENGTH(CAST(`url` AS CHAR)) > 255;

-- [PASS] nova_field_attachments.created_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `nova_field_attachments` WHERE `created_at` IS NOT NULL AND (TRIM(CAST(`created_at` AS CHAR)) = '' OR TRIM(CAST(`created_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`created_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] nova_field_attachments.updated_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `nova_field_attachments` WHERE `updated_at` IS NOT NULL AND (TRIM(CAST(`updated_at` AS CHAR)) = '' OR TRIM(CAST(`updated_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`updated_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] nova_notifications.id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `nova_notifications` WHERE `id` IS NULL;

-- [PASS] nova_notifications.id.max_length (snapshot count: 0)
-- Values must fit the expected char(36)
SELECT COUNT(*) AS aggregate FROM `nova_notifications` WHERE `id` IS NOT NULL AND CHAR_LENGTH(CAST(`id` AS CHAR)) > 36;

-- [PASS] nova_notifications.type.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `nova_notifications` WHERE `type` IS NULL;

-- [PASS] nova_notifications.type.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `nova_notifications` WHERE `type` IS NOT NULL AND CHAR_LENGTH(CAST(`type` AS CHAR)) > 255;

-- [PASS] nova_notifications.notifiable_type.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `nova_notifications` WHERE `notifiable_type` IS NULL;

-- [PASS] nova_notifications.notifiable_type.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `nova_notifications` WHERE `notifiable_type` IS NOT NULL AND CHAR_LENGTH(CAST(`notifiable_type` AS CHAR)) > 255;

-- [PASS] nova_notifications.notifiable_id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `nova_notifications` WHERE `notifiable_id` IS NULL;

-- [PASS] nova_notifications.notifiable_id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `nova_notifications` WHERE `notifiable_id` IS NOT NULL AND (TRIM(CAST(`notifiable_id` AS CHAR)) = '' OR TRIM(CAST(`notifiable_id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`notifiable_id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`notifiable_id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] nova_notifications.data.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `nova_notifications` WHERE `data` IS NULL;

-- [PASS] nova_notifications.read_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `nova_notifications` WHERE `read_at` IS NOT NULL AND (TRIM(CAST(`read_at` AS CHAR)) = '' OR TRIM(CAST(`read_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`read_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] nova_notifications.created_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `nova_notifications` WHERE `created_at` IS NOT NULL AND (TRIM(CAST(`created_at` AS CHAR)) = '' OR TRIM(CAST(`created_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`created_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] nova_notifications.updated_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `nova_notifications` WHERE `updated_at` IS NOT NULL AND (TRIM(CAST(`updated_at` AS CHAR)) = '' OR TRIM(CAST(`updated_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`updated_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] nova_notifications.deleted_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `nova_notifications` WHERE `deleted_at` IS NOT NULL AND (TRIM(CAST(`deleted_at` AS CHAR)) = '' OR TRIM(CAST(`deleted_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`deleted_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] nova_pending_field_attachments.id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `nova_pending_field_attachments` WHERE `id` IS NULL;

-- [PASS] nova_pending_field_attachments.id.auto_increment_values (snapshot count: 0)
-- AUTO_INCREMENT requires non-null, positive and unique integer values
SELECT COUNT(*) AS aggregate FROM `nova_pending_field_attachments` WHERE `id` IS NULL OR TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) = '0' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^[0-9]+$';

-- [PASS] nova_pending_field_attachments.id.auto_increment_duplicates (snapshot count: 0)
-- AUTO_INCREMENT/PRIMARY KEY requires unique values
SELECT COUNT(*) AS aggregate FROM (SELECT `id` FROM `nova_pending_field_attachments` GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_ids;

-- [PASS] nova_pending_field_attachments.id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `nova_pending_field_attachments` WHERE `id` IS NOT NULL AND (TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) > 4294967295);

-- [PASS] nova_pending_field_attachments.draft_id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `nova_pending_field_attachments` WHERE `draft_id` IS NULL;

-- [PASS] nova_pending_field_attachments.draft_id.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `nova_pending_field_attachments` WHERE `draft_id` IS NOT NULL AND CHAR_LENGTH(CAST(`draft_id` AS CHAR)) > 255;

-- [PASS] nova_pending_field_attachments.attachment.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `nova_pending_field_attachments` WHERE `attachment` IS NULL;

-- [PASS] nova_pending_field_attachments.attachment.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `nova_pending_field_attachments` WHERE `attachment` IS NOT NULL AND CHAR_LENGTH(CAST(`attachment` AS CHAR)) > 255;

-- [PASS] nova_pending_field_attachments.disk.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `nova_pending_field_attachments` WHERE `disk` IS NULL;

-- [PASS] nova_pending_field_attachments.disk.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `nova_pending_field_attachments` WHERE `disk` IS NOT NULL AND CHAR_LENGTH(CAST(`disk` AS CHAR)) > 255;

-- [PASS] nova_pending_field_attachments.created_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `nova_pending_field_attachments` WHERE `created_at` IS NOT NULL AND (TRIM(CAST(`created_at` AS CHAR)) = '' OR TRIM(CAST(`created_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`created_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] nova_pending_field_attachments.updated_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `nova_pending_field_attachments` WHERE `updated_at` IS NOT NULL AND (TRIM(CAST(`updated_at` AS CHAR)) = '' OR TRIM(CAST(`updated_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`updated_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] order_items.id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `order_items` WHERE `id` IS NULL;

-- [PASS] order_items.id.auto_increment_values (snapshot count: 0)
-- AUTO_INCREMENT requires non-null, positive and unique integer values
SELECT COUNT(*) AS aggregate FROM `order_items` WHERE `id` IS NULL OR TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) = '0' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^[0-9]+$';

-- [PASS] order_items.id.auto_increment_duplicates (snapshot count: 0)
-- AUTO_INCREMENT/PRIMARY KEY requires unique values
SELECT COUNT(*) AS aggregate FROM (SELECT `id` FROM `order_items` GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_ids;

-- [PASS] order_items.id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `order_items` WHERE `id` IS NOT NULL AND (TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] order_items.order_id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `order_items` WHERE `order_id` IS NULL;

-- [PASS] order_items.order_id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `order_items` WHERE `order_id` IS NOT NULL AND (TRIM(CAST(`order_id` AS CHAR)) = '' OR TRIM(CAST(`order_id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`order_id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`order_id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] order_items.product_id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `order_items` WHERE `product_id` IS NOT NULL AND (TRIM(CAST(`product_id` AS CHAR)) = '' OR TRIM(CAST(`product_id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`product_id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`product_id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] order_items.title.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `order_items` WHERE `title` IS NOT NULL AND CHAR_LENGTH(CAST(`title` AS CHAR)) > 255;

-- [PASS] order_items.quantity.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `order_items` WHERE `quantity` IS NULL;

-- [PASS] order_items.quantity.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `order_items` WHERE `quantity` IS NOT NULL AND (TRIM(CAST(`quantity` AS CHAR)) = '' OR TRIM(CAST(`quantity` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`quantity` AS CHAR)) AS DECIMAL(65,0)) < -2147483648 OR CAST(TRIM(CAST(`quantity` AS CHAR)) AS DECIMAL(65,0)) > 2147483647);

-- [PASS] order_items.price.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `order_items` WHERE `price` IS NULL;

-- [PASS] order_items.price.valid_decimal (snapshot count: 0)
-- DECIMAL(8,2) conversion requires values within precision and scale
SELECT COUNT(*) AS aggregate FROM `order_items` WHERE `price` IS NOT NULL AND (TRIM(CAST(`price` AS CHAR)) = '' OR TRIM(CAST(`price` AS CHAR)) NOT REGEXP '^-?[0-9]{1,6}(?:[.][0-9]{1,2})?$');

-- [PASS] order_items.created_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `order_items` WHERE `created_at` IS NOT NULL AND (TRIM(CAST(`created_at` AS CHAR)) = '' OR TRIM(CAST(`created_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`created_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] order_items.updated_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `order_items` WHERE `updated_at` IS NOT NULL AND (TRIM(CAST(`updated_at` AS CHAR)) = '' OR TRIM(CAST(`updated_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`updated_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] orders.id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `orders` WHERE `id` IS NULL;

-- [PASS] orders.id.auto_increment_values (snapshot count: 0)
-- AUTO_INCREMENT requires non-null, positive and unique integer values
SELECT COUNT(*) AS aggregate FROM `orders` WHERE `id` IS NULL OR TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) = '0' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^[0-9]+$';

-- [PASS] orders.id.auto_increment_duplicates (snapshot count: 0)
-- AUTO_INCREMENT/PRIMARY KEY requires unique values
SELECT COUNT(*) AS aggregate FROM (SELECT `id` FROM `orders` GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_ids;

-- [PASS] orders.id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `orders` WHERE `id` IS NOT NULL AND (TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] orders.order_number.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `orders` WHERE `order_number` IS NULL;

-- [PASS] orders.order_number.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `orders` WHERE `order_number` IS NOT NULL AND CHAR_LENGTH(CAST(`order_number` AS CHAR)) > 255;

-- [PASS] orders.status.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `orders` WHERE `status` IS NULL;

-- [PASS] orders.status.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `orders` WHERE `status` IS NOT NULL AND CHAR_LENGTH(CAST(`status` AS CHAR)) > 255;

-- [PASS] orders.fname.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `orders` WHERE `fname` IS NOT NULL AND CHAR_LENGTH(CAST(`fname` AS CHAR)) > 255;

-- [PASS] orders.lname.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `orders` WHERE `lname` IS NOT NULL AND CHAR_LENGTH(CAST(`lname` AS CHAR)) > 255;

-- [PASS] orders.phone.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `orders` WHERE `phone` IS NOT NULL AND CHAR_LENGTH(CAST(`phone` AS CHAR)) > 255;

-- [REVIEW] orders.phone.numeric_to_text_review (snapshot count: -)
-- Manual review: the damaged numeric column may already have lost formatting such as leading zeroes or plus signs

-- [PASS] orders.email.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `orders` WHERE `email` IS NOT NULL AND CHAR_LENGTH(CAST(`email` AS CHAR)) > 255;

-- [PASS] orders.products_total.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `orders` WHERE `products_total` IS NULL;

-- [PASS] orders.products_total.valid_decimal (snapshot count: 0)
-- DECIMAL(14,2) conversion requires values within precision and scale
SELECT COUNT(*) AS aggregate FROM `orders` WHERE `products_total` IS NOT NULL AND (TRIM(CAST(`products_total` AS CHAR)) = '' OR TRIM(CAST(`products_total` AS CHAR)) NOT REGEXP '^-?[0-9]{1,12}(?:[.][0-9]{1,2})?$');

-- [PASS] orders.total.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `orders` WHERE `total` IS NULL;

-- [PASS] orders.total.valid_decimal (snapshot count: 0)
-- DECIMAL(14,2) conversion requires values within precision and scale
SELECT COUNT(*) AS aggregate FROM `orders` WHERE `total` IS NOT NULL AND (TRIM(CAST(`total` AS CHAR)) = '' OR TRIM(CAST(`total` AS CHAR)) NOT REGEXP '^-?[0-9]{1,12}(?:[.][0-9]{1,2})?$');

-- [PASS] orders.total_items.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `orders` WHERE `total_items` IS NULL;

-- [PASS] orders.total_items.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `orders` WHERE `total_items` IS NOT NULL AND (TRIM(CAST(`total_items` AS CHAR)) = '' OR TRIM(CAST(`total_items` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`total_items` AS CHAR)) AS DECIMAL(65,0)) < -2147483648 OR CAST(TRIM(CAST(`total_items` AS CHAR)) AS DECIMAL(65,0)) > 2147483647);

-- [PASS] orders.currency.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `orders` WHERE `currency` IS NULL;

-- [PASS] orders.currency.max_length (snapshot count: 0)
-- Values must fit the expected varchar(3)
SELECT COUNT(*) AS aggregate FROM `orders` WHERE `currency` IS NOT NULL AND CHAR_LENGTH(CAST(`currency` AS CHAR)) > 3;

-- [PASS] orders.created_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `orders` WHERE `created_at` IS NOT NULL AND (TRIM(CAST(`created_at` AS CHAR)) = '' OR TRIM(CAST(`created_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`created_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] orders.updated_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `orders` WHERE `updated_at` IS NOT NULL AND (TRIM(CAST(`updated_at` AS CHAR)) = '' OR TRIM(CAST(`updated_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`updated_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] password_reset_tokens.email.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `password_reset_tokens` WHERE `email` IS NULL;

-- [PASS] password_reset_tokens.email.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `password_reset_tokens` WHERE `email` IS NOT NULL AND CHAR_LENGTH(CAST(`email` AS CHAR)) > 255;

-- [PASS] password_reset_tokens.token.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `password_reset_tokens` WHERE `token` IS NULL;

-- [PASS] password_reset_tokens.token.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `password_reset_tokens` WHERE `token` IS NOT NULL AND CHAR_LENGTH(CAST(`token` AS CHAR)) > 255;

-- [PASS] password_reset_tokens.created_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `password_reset_tokens` WHERE `created_at` IS NOT NULL AND (TRIM(CAST(`created_at` AS CHAR)) = '' OR TRIM(CAST(`created_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`created_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] personal_access_tokens.id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `personal_access_tokens` WHERE `id` IS NULL;

-- [PASS] personal_access_tokens.id.auto_increment_values (snapshot count: 0)
-- AUTO_INCREMENT requires non-null, positive and unique integer values
SELECT COUNT(*) AS aggregate FROM `personal_access_tokens` WHERE `id` IS NULL OR TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) = '0' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^[0-9]+$';

-- [PASS] personal_access_tokens.id.auto_increment_duplicates (snapshot count: 0)
-- AUTO_INCREMENT/PRIMARY KEY requires unique values
SELECT COUNT(*) AS aggregate FROM (SELECT `id` FROM `personal_access_tokens` GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_ids;

-- [PASS] personal_access_tokens.id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `personal_access_tokens` WHERE `id` IS NOT NULL AND (TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] personal_access_tokens.tokenable_type.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `personal_access_tokens` WHERE `tokenable_type` IS NULL;

-- [PASS] personal_access_tokens.tokenable_type.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `personal_access_tokens` WHERE `tokenable_type` IS NOT NULL AND CHAR_LENGTH(CAST(`tokenable_type` AS CHAR)) > 255;

-- [PASS] personal_access_tokens.tokenable_id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `personal_access_tokens` WHERE `tokenable_id` IS NULL;

-- [PASS] personal_access_tokens.tokenable_id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `personal_access_tokens` WHERE `tokenable_id` IS NOT NULL AND (TRIM(CAST(`tokenable_id` AS CHAR)) = '' OR TRIM(CAST(`tokenable_id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`tokenable_id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`tokenable_id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] personal_access_tokens.name.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `personal_access_tokens` WHERE `name` IS NULL;

-- [PASS] personal_access_tokens.name.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `personal_access_tokens` WHERE `name` IS NOT NULL AND CHAR_LENGTH(CAST(`name` AS CHAR)) > 255;

-- [PASS] personal_access_tokens.token.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `personal_access_tokens` WHERE `token` IS NULL;

-- [PASS] personal_access_tokens.token.max_length (snapshot count: 0)
-- Values must fit the expected varchar(64)
SELECT COUNT(*) AS aggregate FROM `personal_access_tokens` WHERE `token` IS NOT NULL AND CHAR_LENGTH(CAST(`token` AS CHAR)) > 64;

-- [PASS] personal_access_tokens.last_used_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `personal_access_tokens` WHERE `last_used_at` IS NOT NULL AND (TRIM(CAST(`last_used_at` AS CHAR)) = '' OR TRIM(CAST(`last_used_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`last_used_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] personal_access_tokens.expires_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `personal_access_tokens` WHERE `expires_at` IS NOT NULL AND (TRIM(CAST(`expires_at` AS CHAR)) = '' OR TRIM(CAST(`expires_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`expires_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] personal_access_tokens.created_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `personal_access_tokens` WHERE `created_at` IS NOT NULL AND (TRIM(CAST(`created_at` AS CHAR)) = '' OR TRIM(CAST(`created_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`created_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] personal_access_tokens.updated_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `personal_access_tokens` WHERE `updated_at` IS NOT NULL AND (TRIM(CAST(`updated_at` AS CHAR)) = '' OR TRIM(CAST(`updated_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`updated_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] product_brands.id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `product_brands` WHERE `id` IS NULL;

-- [PASS] product_brands.id.auto_increment_values (snapshot count: 0)
-- AUTO_INCREMENT requires non-null, positive and unique integer values
SELECT COUNT(*) AS aggregate FROM `product_brands` WHERE `id` IS NULL OR TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) = '0' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^[0-9]+$';

-- [PASS] product_brands.id.auto_increment_duplicates (snapshot count: 0)
-- AUTO_INCREMENT/PRIMARY KEY requires unique values
SELECT COUNT(*) AS aggregate FROM (SELECT `id` FROM `product_brands` GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_ids;

-- [PASS] product_brands.id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `product_brands` WHERE `id` IS NOT NULL AND (TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] product_brands.name.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `product_brands` WHERE `name` IS NULL;

-- [PASS] product_brands.name.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `product_brands` WHERE `name` IS NOT NULL AND CHAR_LENGTH(CAST(`name` AS CHAR)) > 255;

-- [PASS] product_brands.slug.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `product_brands` WHERE `slug` IS NULL;

-- [PASS] product_brands.slug.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `product_brands` WHERE `slug` IS NOT NULL AND CHAR_LENGTH(CAST(`slug` AS CHAR)) > 255;

-- [PASS] product_brands.is_active.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `product_brands` WHERE `is_active` IS NULL;

-- [PASS] product_brands.is_active.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers restricted to 0/1
SELECT COUNT(*) AS aggregate FROM `product_brands` WHERE `is_active` IS NOT NULL AND (TRIM(CAST(`is_active` AS CHAR)) = '' OR TRIM(CAST(`is_active` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`is_active` AS CHAR)) AS DECIMAL(65,0)) < -128 OR CAST(TRIM(CAST(`is_active` AS CHAR)) AS DECIMAL(65,0)) > 127 OR TRIM(CAST(`is_active` AS CHAR)) NOT IN ('0', '1'));

-- [PASS] product_brands.order.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `product_brands` WHERE `order` IS NULL;

-- [PASS] product_brands.order.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `product_brands` WHERE `order` IS NOT NULL AND (TRIM(CAST(`order` AS CHAR)) = '' OR TRIM(CAST(`order` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`order` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`order` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] product_brands.created_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `product_brands` WHERE `created_at` IS NOT NULL AND (TRIM(CAST(`created_at` AS CHAR)) = '' OR TRIM(CAST(`created_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`created_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] product_brands.updated_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `product_brands` WHERE `updated_at` IS NOT NULL AND (TRIM(CAST(`updated_at` AS CHAR)) = '' OR TRIM(CAST(`updated_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`updated_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] product_brands.seo_text.valid_json (snapshot count: 0)
-- TEXT to JSON conversion requires every non-null value to be valid JSON
SELECT COUNT(*) AS aggregate FROM `product_brands` WHERE `seo_text` IS NOT NULL AND JSON_VALID(CAST(`seo_text` AS CHAR)) = 0;

-- [PASS] product_brands.is_show_nav.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `product_brands` WHERE `is_show_nav` IS NULL;

-- [PASS] product_brands.is_show_nav.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers restricted to 0/1
SELECT COUNT(*) AS aggregate FROM `product_brands` WHERE `is_show_nav` IS NOT NULL AND (TRIM(CAST(`is_show_nav` AS CHAR)) = '' OR TRIM(CAST(`is_show_nav` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`is_show_nav` AS CHAR)) AS DECIMAL(65,0)) < -128 OR CAST(TRIM(CAST(`is_show_nav` AS CHAR)) AS DECIMAL(65,0)) > 127 OR TRIM(CAST(`is_show_nav` AS CHAR)) NOT IN ('0', '1'));

-- [PASS] product_categories.id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `product_categories` WHERE `id` IS NULL;

-- [PASS] product_categories.id.auto_increment_values (snapshot count: 0)
-- AUTO_INCREMENT requires non-null, positive and unique integer values
SELECT COUNT(*) AS aggregate FROM `product_categories` WHERE `id` IS NULL OR TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) = '0' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^[0-9]+$';

-- [PASS] product_categories.id.auto_increment_duplicates (snapshot count: 0)
-- AUTO_INCREMENT/PRIMARY KEY requires unique values
SELECT COUNT(*) AS aggregate FROM (SELECT `id` FROM `product_categories` GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_ids;

-- [PASS] product_categories.id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `product_categories` WHERE `id` IS NOT NULL AND (TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] product_categories.name.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `product_categories` WHERE `name` IS NULL;

-- [PASS] product_categories.name.valid_json (snapshot count: 0)
-- TEXT to JSON conversion requires every non-null value to be valid JSON
SELECT COUNT(*) AS aggregate FROM `product_categories` WHERE `name` IS NOT NULL AND JSON_VALID(CAST(`name` AS CHAR)) = 0;

-- [PASS] product_categories.is_active.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `product_categories` WHERE `is_active` IS NULL;

-- [PASS] product_categories.is_active.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers restricted to 0/1
SELECT COUNT(*) AS aggregate FROM `product_categories` WHERE `is_active` IS NOT NULL AND (TRIM(CAST(`is_active` AS CHAR)) = '' OR TRIM(CAST(`is_active` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`is_active` AS CHAR)) AS DECIMAL(65,0)) < -128 OR CAST(TRIM(CAST(`is_active` AS CHAR)) AS DECIMAL(65,0)) > 127 OR TRIM(CAST(`is_active` AS CHAR)) NOT IN ('0', '1'));

-- [PASS] product_categories.order.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `product_categories` WHERE `order` IS NULL;

-- [PASS] product_categories.order.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `product_categories` WHERE `order` IS NOT NULL AND (TRIM(CAST(`order` AS CHAR)) = '' OR TRIM(CAST(`order` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`order` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`order` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] product_categories.created_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `product_categories` WHERE `created_at` IS NOT NULL AND (TRIM(CAST(`created_at` AS CHAR)) = '' OR TRIM(CAST(`created_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`created_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] product_categories.updated_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `product_categories` WHERE `updated_at` IS NOT NULL AND (TRIM(CAST(`updated_at` AS CHAR)) = '' OR TRIM(CAST(`updated_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`updated_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] product_categories.seo_text.valid_json (snapshot count: 0)
-- TEXT to JSON conversion requires every non-null value to be valid JSON
SELECT COUNT(*) AS aggregate FROM `product_categories` WHERE `seo_text` IS NOT NULL AND JSON_VALID(CAST(`seo_text` AS CHAR)) = 0;

-- [PASS] product_categories.slug.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `product_categories` WHERE `slug` IS NOT NULL AND CHAR_LENGTH(CAST(`slug` AS CHAR)) > 255;

-- [PASS] product_categories.is_show_nav.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `product_categories` WHERE `is_show_nav` IS NULL;

-- [PASS] product_categories.is_show_nav.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers restricted to 0/1
SELECT COUNT(*) AS aggregate FROM `product_categories` WHERE `is_show_nav` IS NOT NULL AND (TRIM(CAST(`is_show_nav` AS CHAR)) = '' OR TRIM(CAST(`is_show_nav` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`is_show_nav` AS CHAR)) AS DECIMAL(65,0)) < -128 OR CAST(TRIM(CAST(`is_show_nav` AS CHAR)) AS DECIMAL(65,0)) > 127 OR TRIM(CAST(`is_show_nav` AS CHAR)) NOT IN ('0', '1'));

-- [PASS] product_ingredients.id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `product_ingredients` WHERE `id` IS NULL;

-- [PASS] product_ingredients.id.auto_increment_values (snapshot count: 0)
-- AUTO_INCREMENT requires non-null, positive and unique integer values
SELECT COUNT(*) AS aggregate FROM `product_ingredients` WHERE `id` IS NULL OR TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) = '0' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^[0-9]+$';

-- [PASS] product_ingredients.id.auto_increment_duplicates (snapshot count: 0)
-- AUTO_INCREMENT/PRIMARY KEY requires unique values
SELECT COUNT(*) AS aggregate FROM (SELECT `id` FROM `product_ingredients` GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_ids;

-- [PASS] product_ingredients.id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `product_ingredients` WHERE `id` IS NOT NULL AND (TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] product_ingredients.product_id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `product_ingredients` WHERE `product_id` IS NULL;

-- [PASS] product_ingredients.product_id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `product_ingredients` WHERE `product_id` IS NOT NULL AND (TRIM(CAST(`product_id` AS CHAR)) = '' OR TRIM(CAST(`product_id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`product_id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`product_id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] product_ingredients.ingredient_id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `product_ingredients` WHERE `ingredient_id` IS NULL;

-- [PASS] product_ingredients.ingredient_id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `product_ingredients` WHERE `ingredient_id` IS NOT NULL AND (TRIM(CAST(`ingredient_id` AS CHAR)) = '' OR TRIM(CAST(`ingredient_id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`ingredient_id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`ingredient_id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] product_ingredients.order.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `product_ingredients` WHERE `order` IS NULL;

-- [PASS] product_ingredients.order.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `product_ingredients` WHERE `order` IS NOT NULL AND (TRIM(CAST(`order` AS CHAR)) = '' OR TRIM(CAST(`order` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`order` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`order` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] product_ingredients.created_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `product_ingredients` WHERE `created_at` IS NOT NULL AND (TRIM(CAST(`created_at` AS CHAR)) = '' OR TRIM(CAST(`created_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`created_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] product_ingredients.updated_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `product_ingredients` WHERE `updated_at` IS NOT NULL AND (TRIM(CAST(`updated_at` AS CHAR)) = '' OR TRIM(CAST(`updated_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`updated_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] product_variants.id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `product_variants` WHERE `id` IS NULL;

-- [PASS] product_variants.id.auto_increment_values (snapshot count: 0)
-- AUTO_INCREMENT requires non-null, positive and unique integer values
SELECT COUNT(*) AS aggregate FROM `product_variants` WHERE `id` IS NULL OR TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) = '0' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^[0-9]+$';

-- [PASS] product_variants.id.auto_increment_duplicates (snapshot count: 0)
-- AUTO_INCREMENT/PRIMARY KEY requires unique values
SELECT COUNT(*) AS aggregate FROM (SELECT `id` FROM `product_variants` GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_ids;

-- [PASS] product_variants.id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `product_variants` WHERE `id` IS NOT NULL AND (TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] product_variants.product_id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `product_variants` WHERE `product_id` IS NULL;

-- [PASS] product_variants.product_id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `product_variants` WHERE `product_id` IS NOT NULL AND (TRIM(CAST(`product_id` AS CHAR)) = '' OR TRIM(CAST(`product_id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`product_id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`product_id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] product_variants.variant_id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `product_variants` WHERE `variant_id` IS NULL;

-- [PASS] product_variants.variant_id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `product_variants` WHERE `variant_id` IS NOT NULL AND (TRIM(CAST(`variant_id` AS CHAR)) = '' OR TRIM(CAST(`variant_id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`variant_id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`variant_id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] product_variants.order.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `product_variants` WHERE `order` IS NULL;

-- [PASS] product_variants.order.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `product_variants` WHERE `order` IS NOT NULL AND (TRIM(CAST(`order` AS CHAR)) = '' OR TRIM(CAST(`order` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`order` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`order` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] product_variants.created_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `product_variants` WHERE `created_at` IS NOT NULL AND (TRIM(CAST(`created_at` AS CHAR)) = '' OR TRIM(CAST(`created_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`created_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] product_variants.updated_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `product_variants` WHERE `updated_at` IS NOT NULL AND (TRIM(CAST(`updated_at` AS CHAR)) = '' OR TRIM(CAST(`updated_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`updated_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] products.id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `products` WHERE `id` IS NULL;

-- [PASS] products.id.auto_increment_values (snapshot count: 0)
-- AUTO_INCREMENT requires non-null, positive and unique integer values
SELECT COUNT(*) AS aggregate FROM `products` WHERE `id` IS NULL OR TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) = '0' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^[0-9]+$';

-- [PASS] products.id.auto_increment_duplicates (snapshot count: 0)
-- AUTO_INCREMENT/PRIMARY KEY requires unique values
SELECT COUNT(*) AS aggregate FROM (SELECT `id` FROM `products` GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_ids;

-- [PASS] products.id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `products` WHERE `id` IS NOT NULL AND (TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] products.article.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `products` WHERE `article` IS NOT NULL AND (TRIM(CAST(`article` AS CHAR)) = '' OR TRIM(CAST(`article` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`article` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`article` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] products.code.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `products` WHERE `code` IS NOT NULL AND (TRIM(CAST(`code` AS CHAR)) = '' OR TRIM(CAST(`code` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`code` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`code` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] products.name.valid_json (snapshot count: 0)
-- TEXT to JSON conversion requires every non-null value to be valid JSON
SELECT COUNT(*) AS aggregate FROM `products` WHERE `name` IS NOT NULL AND JSON_VALID(CAST(`name` AS CHAR)) = 0;

-- [PASS] products.slug.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `products` WHERE `slug` IS NOT NULL AND CHAR_LENGTH(CAST(`slug` AS CHAR)) > 255;

-- [PASS] products.volume.max_length (snapshot count: 0)
-- Values must fit the expected varchar(50)
SELECT COUNT(*) AS aggregate FROM `products` WHERE `volume` IS NOT NULL AND CHAR_LENGTH(CAST(`volume` AS CHAR)) > 50;

-- [PASS] products.price_ua.valid_decimal (snapshot count: 0)
-- DECIMAL(8,2) conversion requires values within precision and scale
SELECT COUNT(*) AS aggregate FROM `products` WHERE `price_ua` IS NOT NULL AND (TRIM(CAST(`price_ua` AS CHAR)) = '' OR TRIM(CAST(`price_ua` AS CHAR)) NOT REGEXP '^-?[0-9]{1,6}(?:[.][0-9]{1,2})?$');

-- [PASS] products.price_eu.valid_decimal (snapshot count: 0)
-- DECIMAL(8,2) conversion requires values within precision and scale
SELECT COUNT(*) AS aggregate FROM `products` WHERE `price_eu` IS NOT NULL AND (TRIM(CAST(`price_eu` AS CHAR)) = '' OR TRIM(CAST(`price_eu` AS CHAR)) NOT REGEXP '^-?[0-9]{1,6}(?:[.][0-9]{1,2})?$');

-- [PASS] products.created_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `products` WHERE `created_at` IS NOT NULL AND (TRIM(CAST(`created_at` AS CHAR)) = '' OR TRIM(CAST(`created_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`created_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] products.updated_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `products` WHERE `updated_at` IS NOT NULL AND (TRIM(CAST(`updated_at` AS CHAR)) = '' OR TRIM(CAST(`updated_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`updated_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] products.product_category_id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `products` WHERE `product_category_id` IS NOT NULL AND (TRIM(CAST(`product_category_id` AS CHAR)) = '' OR TRIM(CAST(`product_category_id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`product_category_id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`product_category_id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] products.product_brand_id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `products` WHERE `product_brand_id` IS NOT NULL AND (TRIM(CAST(`product_brand_id` AS CHAR)) = '' OR TRIM(CAST(`product_brand_id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`product_brand_id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`product_brand_id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] products.order.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `products` WHERE `order` IS NULL;

-- [PASS] products.order.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `products` WHERE `order` IS NOT NULL AND (TRIM(CAST(`order` AS CHAR)) = '' OR TRIM(CAST(`order` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`order` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`order` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] products.short_description.valid_json (snapshot count: 0)
-- TEXT to JSON conversion requires every non-null value to be valid JSON
SELECT COUNT(*) AS aggregate FROM `products` WHERE `short_description` IS NOT NULL AND JSON_VALID(CAST(`short_description` AS CHAR)) = 0;

-- [PASS] products.subtitle.valid_json (snapshot count: 0)
-- TEXT to JSON conversion requires every non-null value to be valid JSON
SELECT COUNT(*) AS aggregate FROM `products` WHERE `subtitle` IS NOT NULL AND JSON_VALID(CAST(`subtitle` AS CHAR)) = 0;

-- [PASS] products.description.valid_json (snapshot count: 0)
-- TEXT to JSON conversion requires every non-null value to be valid JSON
SELECT COUNT(*) AS aggregate FROM `products` WHERE `description` IS NOT NULL AND JSON_VALID(CAST(`description` AS CHAR)) = 0;

-- [PASS] products.is_active.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `products` WHERE `is_active` IS NULL;

-- [PASS] products.is_active.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers restricted to 0/1
SELECT COUNT(*) AS aggregate FROM `products` WHERE `is_active` IS NOT NULL AND (TRIM(CAST(`is_active` AS CHAR)) = '' OR TRIM(CAST(`is_active` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`is_active` AS CHAR)) AS DECIMAL(65,0)) < -128 OR CAST(TRIM(CAST(`is_active` AS CHAR)) AS DECIMAL(65,0)) > 127 OR TRIM(CAST(`is_active` AS CHAR)) NOT IN ('0', '1'));

-- [PASS] products.position.max_length (snapshot count: 0)
-- Values must fit the expected varchar(20)
SELECT COUNT(*) AS aggregate FROM `products` WHERE `position` IS NOT NULL AND CHAR_LENGTH(CAST(`position` AS CHAR)) > 20;

-- [PASS] promo_banners.id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `promo_banners` WHERE `id` IS NULL;

-- [PASS] promo_banners.id.auto_increment_values (snapshot count: 0)
-- AUTO_INCREMENT requires non-null, positive and unique integer values
SELECT COUNT(*) AS aggregate FROM `promo_banners` WHERE `id` IS NULL OR TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) = '0' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^[0-9]+$';

-- [PASS] promo_banners.id.auto_increment_duplicates (snapshot count: 0)
-- AUTO_INCREMENT/PRIMARY KEY requires unique values
SELECT COUNT(*) AS aggregate FROM (SELECT `id` FROM `promo_banners` GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_ids;

-- [PASS] promo_banners.id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `promo_banners` WHERE `id` IS NOT NULL AND (TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] promo_banners.content.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `promo_banners` WHERE `content` IS NULL;

-- [PASS] promo_banners.content.valid_json (snapshot count: 0)
-- TEXT to JSON conversion requires every non-null value to be valid JSON
SELECT COUNT(*) AS aggregate FROM `promo_banners` WHERE `content` IS NOT NULL AND JSON_VALID(CAST(`content` AS CHAR)) = 0;

-- [PASS] promo_banners.link.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `promo_banners` WHERE `link` IS NOT NULL AND CHAR_LENGTH(CAST(`link` AS CHAR)) > 255;

-- [REVIEW] promo_banners.link.character_set_review (snapshot count: -)
-- Manual review: character set conversion from latin1 to utf8mb4 can preserve already-misdecoded text

-- [PASS] promo_banners.is_active.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `promo_banners` WHERE `is_active` IS NULL;

-- [PASS] promo_banners.is_active.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers restricted to 0/1
SELECT COUNT(*) AS aggregate FROM `promo_banners` WHERE `is_active` IS NOT NULL AND (TRIM(CAST(`is_active` AS CHAR)) = '' OR TRIM(CAST(`is_active` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`is_active` AS CHAR)) AS DECIMAL(65,0)) < -128 OR CAST(TRIM(CAST(`is_active` AS CHAR)) AS DECIMAL(65,0)) > 127 OR TRIM(CAST(`is_active` AS CHAR)) NOT IN ('0', '1'));

-- [PASS] promo_banners.created_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `promo_banners` WHERE `created_at` IS NOT NULL AND (TRIM(CAST(`created_at` AS CHAR)) = '' OR TRIM(CAST(`created_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`created_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] promo_banners.updated_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `promo_banners` WHERE `updated_at` IS NOT NULL AND (TRIM(CAST(`updated_at` AS CHAR)) = '' OR TRIM(CAST(`updated_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`updated_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] regions.id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `regions` WHERE `id` IS NULL;

-- [PASS] regions.id.auto_increment_values (snapshot count: 0)
-- AUTO_INCREMENT requires non-null, positive and unique integer values
SELECT COUNT(*) AS aggregate FROM `regions` WHERE `id` IS NULL OR TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) = '0' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^[0-9]+$';

-- [PASS] regions.id.auto_increment_duplicates (snapshot count: 0)
-- AUTO_INCREMENT/PRIMARY KEY requires unique values
SELECT COUNT(*) AS aggregate FROM (SELECT `id` FROM `regions` GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_ids;

-- [PASS] regions.id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `regions` WHERE `id` IS NOT NULL AND (TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] regions.code.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `regions` WHERE `code` IS NULL;

-- [PASS] regions.code.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `regions` WHERE `code` IS NOT NULL AND CHAR_LENGTH(CAST(`code` AS CHAR)) > 255;

-- [PASS] regions.name.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `regions` WHERE `name` IS NULL;

-- [PASS] regions.name.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `regions` WHERE `name` IS NOT NULL AND CHAR_LENGTH(CAST(`name` AS CHAR)) > 255;

-- [PASS] regions.currency_code.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `regions` WHERE `currency_code` IS NULL;

-- [PASS] regions.currency_code.max_length (snapshot count: 0)
-- Values must fit the expected varchar(6)
SELECT COUNT(*) AS aggregate FROM `regions` WHERE `currency_code` IS NOT NULL AND CHAR_LENGTH(CAST(`currency_code` AS CHAR)) > 6;

-- [PASS] regions.created_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `regions` WHERE `created_at` IS NOT NULL AND (TRIM(CAST(`created_at` AS CHAR)) = '' OR TRIM(CAST(`created_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`created_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] regions.updated_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `regions` WHERE `updated_at` IS NOT NULL AND (TRIM(CAST(`updated_at` AS CHAR)) = '' OR TRIM(CAST(`updated_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`updated_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] service_categories.id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `service_categories` WHERE `id` IS NULL;

-- [PASS] service_categories.id.auto_increment_values (snapshot count: 0)
-- AUTO_INCREMENT requires non-null, positive and unique integer values
SELECT COUNT(*) AS aggregate FROM `service_categories` WHERE `id` IS NULL OR TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) = '0' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^[0-9]+$';

-- [PASS] service_categories.id.auto_increment_duplicates (snapshot count: 0)
-- AUTO_INCREMENT/PRIMARY KEY requires unique values
SELECT COUNT(*) AS aggregate FROM (SELECT `id` FROM `service_categories` GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_ids;

-- [PASS] service_categories.id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `service_categories` WHERE `id` IS NOT NULL AND (TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] service_categories.service_id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `service_categories` WHERE `service_id` IS NULL;

-- [PASS] service_categories.service_id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `service_categories` WHERE `service_id` IS NOT NULL AND (TRIM(CAST(`service_id` AS CHAR)) = '' OR TRIM(CAST(`service_id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`service_id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`service_id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] service_categories.category_id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `service_categories` WHERE `category_id` IS NOT NULL AND (TRIM(CAST(`category_id` AS CHAR)) = '' OR TRIM(CAST(`category_id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`category_id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`category_id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] service_categories.order.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `service_categories` WHERE `order` IS NULL;

-- [PASS] service_categories.order.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `service_categories` WHERE `order` IS NOT NULL AND (TRIM(CAST(`order` AS CHAR)) = '' OR TRIM(CAST(`order` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`order` AS CHAR)) AS DECIMAL(65,0)) < -2147483648 OR CAST(TRIM(CAST(`order` AS CHAR)) AS DECIMAL(65,0)) > 2147483647);

-- [PASS] service_categories.created_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `service_categories` WHERE `created_at` IS NOT NULL AND (TRIM(CAST(`created_at` AS CHAR)) = '' OR TRIM(CAST(`created_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`created_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] service_categories.updated_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `service_categories` WHERE `updated_at` IS NOT NULL AND (TRIM(CAST(`updated_at` AS CHAR)) = '' OR TRIM(CAST(`updated_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`updated_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] service_variant_prices.id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `service_variant_prices` WHERE `id` IS NULL;

-- [PASS] service_variant_prices.id.auto_increment_values (snapshot count: 0)
-- AUTO_INCREMENT requires non-null, positive and unique integer values
SELECT COUNT(*) AS aggregate FROM `service_variant_prices` WHERE `id` IS NULL OR TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) = '0' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^[0-9]+$';

-- [PASS] service_variant_prices.id.auto_increment_duplicates (snapshot count: 0)
-- AUTO_INCREMENT/PRIMARY KEY requires unique values
SELECT COUNT(*) AS aggregate FROM (SELECT `id` FROM `service_variant_prices` GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_ids;

-- [PASS] service_variant_prices.id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `service_variant_prices` WHERE `id` IS NOT NULL AND (TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] service_variant_prices.variant_id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `service_variant_prices` WHERE `variant_id` IS NULL;

-- [PASS] service_variant_prices.variant_id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `service_variant_prices` WHERE `variant_id` IS NOT NULL AND (TRIM(CAST(`variant_id` AS CHAR)) = '' OR TRIM(CAST(`variant_id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`variant_id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`variant_id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] service_variant_prices.name.valid_json (snapshot count: 0)
-- TEXT to JSON conversion requires every non-null value to be valid JSON
SELECT COUNT(*) AS aggregate FROM `service_variant_prices` WHERE `name` IS NOT NULL AND JSON_VALID(CAST(`name` AS CHAR)) = 0;

-- [PASS] service_variant_prices.price.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `service_variant_prices` WHERE `price` IS NULL;

-- [PASS] service_variant_prices.price.valid_decimal (snapshot count: 0)
-- DECIMAL(10,2) conversion requires values within precision and scale
SELECT COUNT(*) AS aggregate FROM `service_variant_prices` WHERE `price` IS NOT NULL AND (TRIM(CAST(`price` AS CHAR)) = '' OR TRIM(CAST(`price` AS CHAR)) NOT REGEXP '^-?[0-9]{1,8}(?:[.][0-9]{1,2})?$');

-- [PASS] service_variant_prices.currency_code.max_length (snapshot count: 0)
-- Values must fit the expected varchar(6)
SELECT COUNT(*) AS aggregate FROM `service_variant_prices` WHERE `currency_code` IS NOT NULL AND CHAR_LENGTH(CAST(`currency_code` AS CHAR)) > 6;

-- [PASS] service_variant_prices.order.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `service_variant_prices` WHERE `order` IS NULL;

-- [PASS] service_variant_prices.order.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `service_variant_prices` WHERE `order` IS NOT NULL AND (TRIM(CAST(`order` AS CHAR)) = '' OR TRIM(CAST(`order` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`order` AS CHAR)) AS DECIMAL(65,0)) < -2147483648 OR CAST(TRIM(CAST(`order` AS CHAR)) AS DECIMAL(65,0)) > 2147483647);

-- [PASS] service_variant_prices.created_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `service_variant_prices` WHERE `created_at` IS NOT NULL AND (TRIM(CAST(`created_at` AS CHAR)) = '' OR TRIM(CAST(`created_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`created_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] service_variant_prices.updated_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `service_variant_prices` WHERE `updated_at` IS NOT NULL AND (TRIM(CAST(`updated_at` AS CHAR)) = '' OR TRIM(CAST(`updated_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`updated_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] service_variants.id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `service_variants` WHERE `id` IS NULL;

-- [PASS] service_variants.id.auto_increment_values (snapshot count: 0)
-- AUTO_INCREMENT requires non-null, positive and unique integer values
SELECT COUNT(*) AS aggregate FROM `service_variants` WHERE `id` IS NULL OR TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) = '0' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^[0-9]+$';

-- [PASS] service_variants.id.auto_increment_duplicates (snapshot count: 0)
-- AUTO_INCREMENT/PRIMARY KEY requires unique values
SELECT COUNT(*) AS aggregate FROM (SELECT `id` FROM `service_variants` GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_ids;

-- [PASS] service_variants.id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `service_variants` WHERE `id` IS NOT NULL AND (TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] service_variants.service_id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `service_variants` WHERE `service_id` IS NULL;

-- [PASS] service_variants.service_id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `service_variants` WHERE `service_id` IS NOT NULL AND (TRIM(CAST(`service_id` AS CHAR)) = '' OR TRIM(CAST(`service_id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`service_id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`service_id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] service_variants.code.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `service_variants` WHERE `code` IS NOT NULL AND CHAR_LENGTH(CAST(`code` AS CHAR)) > 255;

-- [PASS] service_variants.title.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `service_variants` WHERE `title` IS NULL;

-- [PASS] service_variants.title.valid_json (snapshot count: 0)
-- TEXT to JSON conversion requires every non-null value to be valid JSON
SELECT COUNT(*) AS aggregate FROM `service_variants` WHERE `title` IS NOT NULL AND JSON_VALID(CAST(`title` AS CHAR)) = 0;

-- [PASS] service_variants.description.valid_json (snapshot count: 0)
-- TEXT to JSON conversion requires every non-null value to be valid JSON
SELECT COUNT(*) AS aggregate FROM `service_variants` WHERE `description` IS NOT NULL AND JSON_VALID(CAST(`description` AS CHAR)) = 0;

-- [PASS] service_variants.order.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `service_variants` WHERE `order` IS NULL;

-- [PASS] service_variants.order.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `service_variants` WHERE `order` IS NOT NULL AND (TRIM(CAST(`order` AS CHAR)) = '' OR TRIM(CAST(`order` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`order` AS CHAR)) AS DECIMAL(65,0)) < -2147483648 OR CAST(TRIM(CAST(`order` AS CHAR)) AS DECIMAL(65,0)) > 2147483647);

-- [PASS] service_variants.created_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `service_variants` WHERE `created_at` IS NOT NULL AND (TRIM(CAST(`created_at` AS CHAR)) = '' OR TRIM(CAST(`created_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`created_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] service_variants.updated_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `service_variants` WHERE `updated_at` IS NOT NULL AND (TRIM(CAST(`updated_at` AS CHAR)) = '' OR TRIM(CAST(`updated_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`updated_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] services.id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `services` WHERE `id` IS NULL;

-- [PASS] services.id.auto_increment_values (snapshot count: 0)
-- AUTO_INCREMENT requires non-null, positive and unique integer values
SELECT COUNT(*) AS aggregate FROM `services` WHERE `id` IS NULL OR TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) = '0' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^[0-9]+$';

-- [PASS] services.id.auto_increment_duplicates (snapshot count: 0)
-- AUTO_INCREMENT/PRIMARY KEY requires unique values
SELECT COUNT(*) AS aggregate FROM (SELECT `id` FROM `services` GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_ids;

-- [PASS] services.id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `services` WHERE `id` IS NOT NULL AND (TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] services.region_id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `services` WHERE `region_id` IS NULL;

-- [PASS] services.region_id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `services` WHERE `region_id` IS NOT NULL AND (TRIM(CAST(`region_id` AS CHAR)) = '' OR TRIM(CAST(`region_id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`region_id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`region_id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] services.code.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `services` WHERE `code` IS NOT NULL AND CHAR_LENGTH(CAST(`code` AS CHAR)) > 255;

-- [PASS] services.title.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `services` WHERE `title` IS NULL;

-- [PASS] services.title.valid_json (snapshot count: 0)
-- TEXT to JSON conversion requires every non-null value to be valid JSON
SELECT COUNT(*) AS aggregate FROM `services` WHERE `title` IS NOT NULL AND JSON_VALID(CAST(`title` AS CHAR)) = 0;

-- [PASS] services.description.valid_json (snapshot count: 0)
-- TEXT to JSON conversion requires every non-null value to be valid JSON
SELECT COUNT(*) AS aggregate FROM `services` WHERE `description` IS NOT NULL AND JSON_VALID(CAST(`description` AS CHAR)) = 0;

-- [PASS] services.order.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `services` WHERE `order` IS NULL;

-- [PASS] services.order.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `services` WHERE `order` IS NOT NULL AND (TRIM(CAST(`order` AS CHAR)) = '' OR TRIM(CAST(`order` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`order` AS CHAR)) AS DECIMAL(65,0)) < -9223372036854775808 OR CAST(TRIM(CAST(`order` AS CHAR)) AS DECIMAL(65,0)) > 9223372036854775807);

-- [PASS] services.created_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `services` WHERE `created_at` IS NOT NULL AND (TRIM(CAST(`created_at` AS CHAR)) = '' OR TRIM(CAST(`created_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`created_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] services.updated_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `services` WHERE `updated_at` IS NOT NULL AND (TRIM(CAST(`updated_at` AS CHAR)) = '' OR TRIM(CAST(`updated_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`updated_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] site_settings.id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `site_settings` WHERE `id` IS NULL;

-- [PASS] site_settings.id.auto_increment_values (snapshot count: 0)
-- AUTO_INCREMENT requires non-null, positive and unique integer values
SELECT COUNT(*) AS aggregate FROM `site_settings` WHERE `id` IS NULL OR TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) = '0' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^[0-9]+$';

-- [PASS] site_settings.id.auto_increment_duplicates (snapshot count: 0)
-- AUTO_INCREMENT/PRIMARY KEY requires unique values
SELECT COUNT(*) AS aggregate FROM (SELECT `id` FROM `site_settings` GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_ids;

-- [PASS] site_settings.id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `site_settings` WHERE `id` IS NOT NULL AND (TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] site_settings.key.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `site_settings` WHERE `key` IS NULL;

-- [PASS] site_settings.key.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `site_settings` WHERE `key` IS NOT NULL AND CHAR_LENGTH(CAST(`key` AS CHAR)) > 255;

-- [PASS] site_settings.value.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `site_settings` WHERE `value` IS NULL;

-- [PASS] site_settings.created_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `site_settings` WHERE `created_at` IS NOT NULL AND (TRIM(CAST(`created_at` AS CHAR)) = '' OR TRIM(CAST(`created_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`created_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] site_settings.updated_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `site_settings` WHERE `updated_at` IS NOT NULL AND (TRIM(CAST(`updated_at` AS CHAR)) = '' OR TRIM(CAST(`updated_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`updated_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] social_links.id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `social_links` WHERE `id` IS NULL;

-- [PASS] social_links.id.auto_increment_values (snapshot count: 0)
-- AUTO_INCREMENT requires non-null, positive and unique integer values
SELECT COUNT(*) AS aggregate FROM `social_links` WHERE `id` IS NULL OR TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) = '0' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^[0-9]+$';

-- [PASS] social_links.id.auto_increment_duplicates (snapshot count: 0)
-- AUTO_INCREMENT/PRIMARY KEY requires unique values
SELECT COUNT(*) AS aggregate FROM (SELECT `id` FROM `social_links` GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_ids;

-- [PASS] social_links.id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `social_links` WHERE `id` IS NOT NULL AND (TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] social_links.platform.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `social_links` WHERE `platform` IS NULL;

-- [PASS] social_links.platform.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `social_links` WHERE `platform` IS NOT NULL AND CHAR_LENGTH(CAST(`platform` AS CHAR)) > 255;

-- [PASS] social_links.url.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `social_links` WHERE `url` IS NULL;

-- [PASS] social_links.url.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `social_links` WHERE `url` IS NOT NULL AND CHAR_LENGTH(CAST(`url` AS CHAR)) > 255;

-- [PASS] social_links.icon.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `social_links` WHERE `icon` IS NOT NULL AND CHAR_LENGTH(CAST(`icon` AS CHAR)) > 255;

-- [PASS] social_links.order.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `social_links` WHERE `order` IS NULL;

-- [PASS] social_links.order.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `social_links` WHERE `order` IS NOT NULL AND (TRIM(CAST(`order` AS CHAR)) = '' OR TRIM(CAST(`order` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`order` AS CHAR)) AS DECIMAL(65,0)) < -9223372036854775808 OR CAST(TRIM(CAST(`order` AS CHAR)) AS DECIMAL(65,0)) > 9223372036854775807);

-- [PASS] social_links.created_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `social_links` WHERE `created_at` IS NOT NULL AND (TRIM(CAST(`created_at` AS CHAR)) = '' OR TRIM(CAST(`created_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`created_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] social_links.updated_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `social_links` WHERE `updated_at` IS NOT NULL AND (TRIM(CAST(`updated_at` AS CHAR)) = '' OR TRIM(CAST(`updated_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`updated_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] social_links.region_id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `social_links` WHERE `region_id` IS NOT NULL AND (TRIM(CAST(`region_id` AS CHAR)) = '' OR TRIM(CAST(`region_id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`region_id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`region_id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] special_offers.id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `special_offers` WHERE `id` IS NULL;

-- [PASS] special_offers.id.auto_increment_values (snapshot count: 0)
-- AUTO_INCREMENT requires non-null, positive and unique integer values
SELECT COUNT(*) AS aggregate FROM `special_offers` WHERE `id` IS NULL OR TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) = '0' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^[0-9]+$';

-- [PASS] special_offers.id.auto_increment_duplicates (snapshot count: 0)
-- AUTO_INCREMENT/PRIMARY KEY requires unique values
SELECT COUNT(*) AS aggregate FROM (SELECT `id` FROM `special_offers` GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_ids;

-- [PASS] special_offers.id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `special_offers` WHERE `id` IS NOT NULL AND (TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] special_offers.region_id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `special_offers` WHERE `region_id` IS NOT NULL AND (TRIM(CAST(`region_id` AS CHAR)) = '' OR TRIM(CAST(`region_id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`region_id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`region_id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] special_offers.code.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `special_offers` WHERE `code` IS NOT NULL AND CHAR_LENGTH(CAST(`code` AS CHAR)) > 255;

-- [PASS] special_offers.title.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `special_offers` WHERE `title` IS NULL;

-- [PASS] special_offers.title.valid_json (snapshot count: 0)
-- TEXT to JSON conversion requires every non-null value to be valid JSON
SELECT COUNT(*) AS aggregate FROM `special_offers` WHERE `title` IS NOT NULL AND JSON_VALID(CAST(`title` AS CHAR)) = 0;

-- [PASS] special_offers.subtitle.valid_json (snapshot count: 0)
-- TEXT to JSON conversion requires every non-null value to be valid JSON
SELECT COUNT(*) AS aggregate FROM `special_offers` WHERE `subtitle` IS NOT NULL AND JSON_VALID(CAST(`subtitle` AS CHAR)) = 0;

-- [PASS] special_offers.description.valid_json (snapshot count: 0)
-- TEXT to JSON conversion requires every non-null value to be valid JSON
SELECT COUNT(*) AS aggregate FROM `special_offers` WHERE `description` IS NOT NULL AND JSON_VALID(CAST(`description` AS CHAR)) = 0;

-- [PASS] special_offers.price.valid_decimal (snapshot count: 0)
-- DECIMAL(10,2) conversion requires values within precision and scale
SELECT COUNT(*) AS aggregate FROM `special_offers` WHERE `price` IS NOT NULL AND (TRIM(CAST(`price` AS CHAR)) = '' OR TRIM(CAST(`price` AS CHAR)) NOT REGEXP '^-?[0-9]{1,8}(?:[.][0-9]{1,2})?$');

-- [PASS] special_offers.old_price.valid_decimal (snapshot count: 0)
-- DECIMAL(10,2) conversion requires values within precision and scale
SELECT COUNT(*) AS aggregate FROM `special_offers` WHERE `old_price` IS NOT NULL AND (TRIM(CAST(`old_price` AS CHAR)) = '' OR TRIM(CAST(`old_price` AS CHAR)) NOT REGEXP '^-?[0-9]{1,8}(?:[.][0-9]{1,2})?$');

-- [PASS] special_offers.about_title.valid_json (snapshot count: 0)
-- TEXT to JSON conversion requires every non-null value to be valid JSON
SELECT COUNT(*) AS aggregate FROM `special_offers` WHERE `about_title` IS NOT NULL AND JSON_VALID(CAST(`about_title` AS CHAR)) = 0;

-- [PASS] special_offers.about_text.valid_json (snapshot count: 0)
-- TEXT to JSON conversion requires every non-null value to be valid JSON
SELECT COUNT(*) AS aggregate FROM `special_offers` WHERE `about_text` IS NOT NULL AND JSON_VALID(CAST(`about_text` AS CHAR)) = 0;

-- [PASS] special_offers.order.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `special_offers` WHERE `order` IS NULL;

-- [PASS] special_offers.order.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `special_offers` WHERE `order` IS NOT NULL AND (TRIM(CAST(`order` AS CHAR)) = '' OR TRIM(CAST(`order` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`order` AS CHAR)) AS DECIMAL(65,0)) < -2147483648 OR CAST(TRIM(CAST(`order` AS CHAR)) AS DECIMAL(65,0)) > 2147483647);

-- [PASS] special_offers.created_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `special_offers` WHERE `created_at` IS NOT NULL AND (TRIM(CAST(`created_at` AS CHAR)) = '' OR TRIM(CAST(`created_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`created_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] special_offers.updated_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `special_offers` WHERE `updated_at` IS NOT NULL AND (TRIM(CAST(`updated_at` AS CHAR)) = '' OR TRIM(CAST(`updated_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`updated_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] team_members.name.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `team_members` WHERE `name` IS NULL;

-- [PASS] team_members.name.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `team_members` WHERE `name` IS NOT NULL AND CHAR_LENGTH(CAST(`name` AS CHAR)) > 255;

-- [PASS] team_members.position.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `team_members` WHERE `position` IS NULL;

-- [PASS] team_members.position.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `team_members` WHERE `position` IS NOT NULL AND CHAR_LENGTH(CAST(`position` AS CHAR)) > 255;

-- [PASS] team_members.order.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `team_members` WHERE `order` IS NULL;

-- [PASS] team_members.order.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `team_members` WHERE `order` IS NOT NULL AND (TRIM(CAST(`order` AS CHAR)) = '' OR TRIM(CAST(`order` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`order` AS CHAR)) AS DECIMAL(65,0)) < -9223372036854775808 OR CAST(TRIM(CAST(`order` AS CHAR)) AS DECIMAL(65,0)) > 9223372036854775807);

-- [PASS] team_members.created_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `team_members` WHERE `created_at` IS NOT NULL AND (TRIM(CAST(`created_at` AS CHAR)) = '' OR TRIM(CAST(`created_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`created_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] team_members.updated_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `team_members` WHERE `updated_at` IS NOT NULL AND (TRIM(CAST(`updated_at` AS CHAR)) = '' OR TRIM(CAST(`updated_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`updated_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] team_members.region_id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `team_members` WHERE `region_id` IS NOT NULL AND (TRIM(CAST(`region_id` AS CHAR)) = '' OR TRIM(CAST(`region_id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`region_id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`region_id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] users.id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `users` WHERE `id` IS NULL;

-- [PASS] users.id.auto_increment_values (snapshot count: 0)
-- AUTO_INCREMENT requires non-null, positive and unique integer values
SELECT COUNT(*) AS aggregate FROM `users` WHERE `id` IS NULL OR TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) = '0' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^[0-9]+$';

-- [PASS] users.id.auto_increment_duplicates (snapshot count: 0)
-- AUTO_INCREMENT/PRIMARY KEY requires unique values
SELECT COUNT(*) AS aggregate FROM (SELECT `id` FROM `users` GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_ids;

-- [PASS] users.id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `users` WHERE `id` IS NOT NULL AND (TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] users.name.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `users` WHERE `name` IS NULL;

-- [PASS] users.name.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `users` WHERE `name` IS NOT NULL AND CHAR_LENGTH(CAST(`name` AS CHAR)) > 255;

-- [BLOCKED] users.email.not_null (snapshot count: 8)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `users` WHERE `email` IS NULL;

-- [PASS] users.email.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `users` WHERE `email` IS NOT NULL AND CHAR_LENGTH(CAST(`email` AS CHAR)) > 255;

-- [PASS] users.email_verified_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `users` WHERE `email_verified_at` IS NOT NULL AND (TRIM(CAST(`email_verified_at` AS CHAR)) = '' OR TRIM(CAST(`email_verified_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`email_verified_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [BLOCKED] users.password.not_null (snapshot count: 8)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `users` WHERE `password` IS NULL;

-- [PASS] users.password.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `users` WHERE `password` IS NOT NULL AND CHAR_LENGTH(CAST(`password` AS CHAR)) > 255;

-- [PASS] users.remember_token.max_length (snapshot count: 0)
-- Values must fit the expected varchar(100)
SELECT COUNT(*) AS aggregate FROM `users` WHERE `remember_token` IS NOT NULL AND CHAR_LENGTH(CAST(`remember_token` AS CHAR)) > 100;

-- [PASS] users.created_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `users` WHERE `created_at` IS NOT NULL AND (TRIM(CAST(`created_at` AS CHAR)) = '' OR TRIM(CAST(`created_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`created_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] users.updated_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `users` WHERE `updated_at` IS NOT NULL AND (TRIM(CAST(`updated_at` AS CHAR)) = '' OR TRIM(CAST(`updated_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`updated_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [BLOCKED] users.telegram_id.not_null (snapshot count: 1)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `users` WHERE `telegram_id` IS NULL;

-- [PASS] users.telegram_id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `users` WHERE `telegram_id` IS NOT NULL AND (TRIM(CAST(`telegram_id` AS CHAR)) = '' OR TRIM(CAST(`telegram_id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`telegram_id` AS CHAR)) AS DECIMAL(65,0)) < -9223372036854775808 OR CAST(TRIM(CAST(`telegram_id` AS CHAR)) AS DECIMAL(65,0)) > 9223372036854775807);

-- [PASS] users.telegram_login.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `users` WHERE `telegram_login` IS NOT NULL AND CHAR_LENGTH(CAST(`telegram_login` AS CHAR)) > 255;

-- [PASS] users.telegram_name.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `users` WHERE `telegram_name` IS NOT NULL AND CHAR_LENGTH(CAST(`telegram_name` AS CHAR)) > 255;

-- [BLOCKED] users.is_appointment_ua.not_null (snapshot count: 1)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `users` WHERE `is_appointment_ua` IS NULL;

-- [PASS] users.is_appointment_ua.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers restricted to 0/1
SELECT COUNT(*) AS aggregate FROM `users` WHERE `is_appointment_ua` IS NOT NULL AND (TRIM(CAST(`is_appointment_ua` AS CHAR)) = '' OR TRIM(CAST(`is_appointment_ua` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`is_appointment_ua` AS CHAR)) AS DECIMAL(65,0)) < -128 OR CAST(TRIM(CAST(`is_appointment_ua` AS CHAR)) AS DECIMAL(65,0)) > 127 OR TRIM(CAST(`is_appointment_ua` AS CHAR)) NOT IN ('0', '1'));

-- [BLOCKED] users.is_appointment_dubai.not_null (snapshot count: 1)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `users` WHERE `is_appointment_dubai` IS NULL;

-- [PASS] users.is_appointment_dubai.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers restricted to 0/1
SELECT COUNT(*) AS aggregate FROM `users` WHERE `is_appointment_dubai` IS NOT NULL AND (TRIM(CAST(`is_appointment_dubai` AS CHAR)) = '' OR TRIM(CAST(`is_appointment_dubai` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`is_appointment_dubai` AS CHAR)) AS DECIMAL(65,0)) < -128 OR CAST(TRIM(CAST(`is_appointment_dubai` AS CHAR)) AS DECIMAL(65,0)) > 127 OR TRIM(CAST(`is_appointment_dubai` AS CHAR)) NOT IN ('0', '1'));

-- [PASS] variants.id.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `variants` WHERE `id` IS NULL;

-- [PASS] variants.id.auto_increment_values (snapshot count: 0)
-- AUTO_INCREMENT requires non-null, positive and unique integer values
SELECT COUNT(*) AS aggregate FROM `variants` WHERE `id` IS NULL OR TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) = '0' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^[0-9]+$';

-- [PASS] variants.id.auto_increment_duplicates (snapshot count: 0)
-- AUTO_INCREMENT/PRIMARY KEY requires unique values
SELECT COUNT(*) AS aggregate FROM (SELECT `id` FROM `variants` GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_ids;

-- [PASS] variants.id.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `variants` WHERE `id` IS NOT NULL AND (TRIM(CAST(`id` AS CHAR)) = '' OR TRIM(CAST(`id` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`id` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] variants.slug.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `variants` WHERE `slug` IS NULL;

-- [PASS] variants.slug.max_length (snapshot count: 0)
-- Values must fit the expected varchar(255)
SELECT COUNT(*) AS aggregate FROM `variants` WHERE `slug` IS NOT NULL AND CHAR_LENGTH(CAST(`slug` AS CHAR)) > 255;

-- [PASS] variants.name.valid_json (snapshot count: 0)
-- TEXT to JSON conversion requires every non-null value to be valid JSON
SELECT COUNT(*) AS aggregate FROM `variants` WHERE `name` IS NOT NULL AND JSON_VALID(CAST(`name` AS CHAR)) = 0;

-- [PASS] variants.short_description.valid_json (snapshot count: 0)
-- TEXT to JSON conversion requires every non-null value to be valid JSON
SELECT COUNT(*) AS aggregate FROM `variants` WHERE `short_description` IS NOT NULL AND JSON_VALID(CAST(`short_description` AS CHAR)) = 0;

-- [PASS] variants.description.valid_json (snapshot count: 0)
-- TEXT to JSON conversion requires every non-null value to be valid JSON
SELECT COUNT(*) AS aggregate FROM `variants` WHERE `description` IS NOT NULL AND JSON_VALID(CAST(`description` AS CHAR)) = 0;

-- [PASS] variants.is_active.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `variants` WHERE `is_active` IS NULL;

-- [PASS] variants.is_active.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers restricted to 0/1
SELECT COUNT(*) AS aggregate FROM `variants` WHERE `is_active` IS NOT NULL AND (TRIM(CAST(`is_active` AS CHAR)) = '' OR TRIM(CAST(`is_active` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`is_active` AS CHAR)) AS DECIMAL(65,0)) < -128 OR CAST(TRIM(CAST(`is_active` AS CHAR)) AS DECIMAL(65,0)) > 127 OR TRIM(CAST(`is_active` AS CHAR)) NOT IN ('0', '1'));

-- [PASS] variants.order.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `variants` WHERE `order` IS NULL;

-- [PASS] variants.order.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers
SELECT COUNT(*) AS aggregate FROM `variants` WHERE `order` IS NOT NULL AND (TRIM(CAST(`order` AS CHAR)) = '' OR TRIM(CAST(`order` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`order` AS CHAR)) AS DECIMAL(65,0)) < 0 OR CAST(TRIM(CAST(`order` AS CHAR)) AS DECIMAL(65,0)) > 18446744073709551615);

-- [PASS] variants.created_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `variants` WHERE `created_at` IS NOT NULL AND (TRIM(CAST(`created_at` AS CHAR)) = '' OR TRIM(CAST(`created_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`created_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] variants.updated_at.valid_datetime (snapshot count: 0)
-- TIMESTAMP conversion rejects empty, zero-date and non-canonical values
SELECT COUNT(*) AS aggregate FROM `variants` WHERE `updated_at` IS NOT NULL AND (TRIM(CAST(`updated_at` AS CHAR)) = '' OR TRIM(CAST(`updated_at` AS CHAR)) = '0000-00-00 00:00:00' OR TRIM(CAST(`updated_at` AS CHAR)) NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$');

-- [PASS] variants.seo_text.valid_json (snapshot count: 0)
-- TEXT to JSON conversion requires every non-null value to be valid JSON
SELECT COUNT(*) AS aggregate FROM `variants` WHERE `seo_text` IS NOT NULL AND JSON_VALID(CAST(`seo_text` AS CHAR)) = 0;

-- [PASS] variants.is_show_nav.not_null (snapshot count: 0)
-- NULL values conflict with NOT NULL
SELECT COUNT(*) AS aggregate FROM `variants` WHERE `is_show_nav` IS NULL;

-- [PASS] variants.is_show_nav.valid_integer (snapshot count: 0)
-- Integer conversion requires canonical in-range whole numbers restricted to 0/1
SELECT COUNT(*) AS aggregate FROM `variants` WHERE `is_show_nav` IS NOT NULL AND (TRIM(CAST(`is_show_nav` AS CHAR)) = '' OR TRIM(CAST(`is_show_nav` AS CHAR)) NOT REGEXP '^-?[0-9]+$' OR CAST(TRIM(CAST(`is_show_nav` AS CHAR)) AS DECIMAL(65,0)) < -128 OR CAST(TRIM(CAST(`is_show_nav` AS CHAR)) AS DECIMAL(65,0)) > 127 OR TRIM(CAST(`is_show_nav` AS CHAR)) NOT IN ('0', '1'));

-- [PASS] abouts.abouts_code_unique.unique (snapshot count: 0)
-- UNIQUE index requires no duplicate non-null tuples
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `abouts` WHERE `code` IS NOT NULL GROUP BY `code` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] abouts.PRIMARY.unique (snapshot count: 0)
-- PRIMARY KEY requires unique non-null values
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `abouts` WHERE `id` IS NOT NULL GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] action_events.PRIMARY.unique (snapshot count: 0)
-- PRIMARY KEY requires unique non-null values
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `action_events` WHERE `id` IS NOT NULL GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] appointments.PRIMARY.unique (snapshot count: 0)
-- PRIMARY KEY requires unique non-null values
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `appointments` WHERE `id` IS NOT NULL GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] banners.PRIMARY.unique (snapshot count: 0)
-- PRIMARY KEY requires unique non-null values
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `banners` WHERE `id` IS NOT NULL GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] call_us.PRIMARY.unique (snapshot count: 0)
-- PRIMARY KEY requires unique non-null values
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `call_us` WHERE `id` IS NOT NULL GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] categories.PRIMARY.unique (snapshot count: 0)
-- PRIMARY KEY requires unique non-null values
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `categories` WHERE `id` IS NOT NULL GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] contacts.PRIMARY.unique (snapshot count: 0)
-- PRIMARY KEY requires unique non-null values
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `contacts` WHERE `id` IS NOT NULL GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] devices.PRIMARY.unique (snapshot count: 0)
-- PRIMARY KEY requires unique non-null values
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `devices` WHERE `id` IS NOT NULL GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] devices.devices_region_id_foreign.orphans (snapshot count: 0)
-- Foreign key requires every non-null child value to reference an existing parent row
SELECT COUNT(*) AS aggregate FROM `devices` child LEFT JOIN `regions` parent ON child.`region_id` = parent.`id` WHERE child.`region_id` IS NOT NULL AND parent.`id` IS NULL;

-- [PASS] failed_jobs.failed_jobs_uuid_unique.unique (snapshot count: 0)
-- UNIQUE index requires no duplicate non-null tuples
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `failed_jobs` WHERE `uuid` IS NOT NULL GROUP BY `uuid` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] failed_jobs.PRIMARY.unique (snapshot count: 0)
-- PRIMARY KEY requires unique non-null values
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `failed_jobs` WHERE `id` IS NOT NULL GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] galleries.PRIMARY.unique (snapshot count: 0)
-- PRIMARY KEY requires unique non-null values
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `galleries` WHERE `id` IS NOT NULL GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] galleries.galleries_region_id_foreign.orphans (snapshot count: 0)
-- Foreign key requires every non-null child value to reference an existing parent row
SELECT COUNT(*) AS aggregate FROM `galleries` child LEFT JOIN `regions` parent ON child.`region_id` = parent.`id` WHERE child.`region_id` IS NOT NULL AND parent.`id` IS NULL;

-- [PASS] ingredients.ingredients_slug_unique.unique (snapshot count: 0)
-- UNIQUE index requires no duplicate non-null tuples
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `ingredients` WHERE `slug` IS NOT NULL GROUP BY `slug` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] ingredients.PRIMARY.unique (snapshot count: 0)
-- PRIMARY KEY requires unique non-null values
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `ingredients` WHERE `id` IS NOT NULL GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] locations.PRIMARY.unique (snapshot count: 0)
-- PRIMARY KEY requires unique non-null values
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `locations` WHERE `id` IS NOT NULL GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] media.media_uuid_unique.unique (snapshot count: 0)
-- UNIQUE index requires no duplicate non-null tuples
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `media` WHERE `uuid` IS NOT NULL GROUP BY `uuid` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] media.PRIMARY.unique (snapshot count: 0)
-- PRIMARY KEY requires unique non-null values
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `media` WHERE `id` IS NOT NULL GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] migrations.PRIMARY.unique (snapshot count: 0)
-- PRIMARY KEY requires unique non-null values
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `migrations` WHERE `id` IS NOT NULL GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] nova_field_attachments.PRIMARY.unique (snapshot count: 0)
-- PRIMARY KEY requires unique non-null values
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `nova_field_attachments` WHERE `id` IS NOT NULL GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] nova_notifications.PRIMARY.unique (snapshot count: 0)
-- PRIMARY KEY requires unique non-null values
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `nova_notifications` WHERE `id` IS NOT NULL GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] nova_pending_field_attachments.PRIMARY.unique (snapshot count: 0)
-- PRIMARY KEY requires unique non-null values
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `nova_pending_field_attachments` WHERE `id` IS NOT NULL GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] order_items.PRIMARY.unique (snapshot count: 0)
-- PRIMARY KEY requires unique non-null values
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `order_items` WHERE `id` IS NOT NULL GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [BLOCKED] order_items.order_items_order_id_foreign.orphans (snapshot count: 23)
-- Foreign key requires every non-null child value to reference an existing parent row
SELECT COUNT(*) AS aggregate FROM `order_items` child LEFT JOIN `orders` parent ON child.`order_id` = parent.`id` WHERE child.`order_id` IS NOT NULL AND parent.`id` IS NULL;

-- [BLOCKED] order_items.order_items_product_id_foreign.orphans (snapshot count: 23)
-- Foreign key requires every non-null child value to reference an existing parent row
SELECT COUNT(*) AS aggregate FROM `order_items` child LEFT JOIN `products` parent ON child.`product_id` = parent.`id` WHERE child.`product_id` IS NOT NULL AND parent.`id` IS NULL;

-- [PASS] orders.orders_order_number_unique.unique (snapshot count: 0)
-- UNIQUE index requires no duplicate non-null tuples
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `orders` WHERE `order_number` IS NOT NULL GROUP BY `order_number` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] orders.PRIMARY.unique (snapshot count: 0)
-- PRIMARY KEY requires unique non-null values
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `orders` WHERE `id` IS NOT NULL GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] password_reset_tokens.PRIMARY.unique (snapshot count: 0)
-- PRIMARY KEY requires unique non-null values
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `password_reset_tokens` WHERE `email` IS NOT NULL GROUP BY `email` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] personal_access_tokens.personal_access_tokens_token_unique.unique (snapshot count: 0)
-- UNIQUE index requires no duplicate non-null tuples
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `personal_access_tokens` WHERE `token` IS NOT NULL GROUP BY `token` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] personal_access_tokens.PRIMARY.unique (snapshot count: 0)
-- PRIMARY KEY requires unique non-null values
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `personal_access_tokens` WHERE `id` IS NOT NULL GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] product_brands.PRIMARY.unique (snapshot count: 0)
-- PRIMARY KEY requires unique non-null values
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `product_brands` WHERE `id` IS NOT NULL GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] product_brands.product_brands_name_unique.unique (snapshot count: 0)
-- UNIQUE index requires no duplicate non-null tuples
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `product_brands` WHERE `name` IS NOT NULL GROUP BY `name` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] product_brands.product_brands_slug_unique.unique (snapshot count: 0)
-- UNIQUE index requires no duplicate non-null tuples
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `product_brands` WHERE `slug` IS NOT NULL GROUP BY `slug` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] product_categories.PRIMARY.unique (snapshot count: 0)
-- PRIMARY KEY requires unique non-null values
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `product_categories` WHERE `id` IS NOT NULL GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] product_categories.product_categories_slug_unique.unique (snapshot count: 0)
-- UNIQUE index requires no duplicate non-null tuples
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `product_categories` WHERE `slug` IS NOT NULL GROUP BY `slug` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] product_ingredients.PRIMARY.unique (snapshot count: 0)
-- PRIMARY KEY requires unique non-null values
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `product_ingredients` WHERE `id` IS NOT NULL GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] product_ingredients.product_ingredients_product_id_ingredient_id_unique.unique (snapshot count: 0)
-- UNIQUE index requires no duplicate non-null tuples
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `product_ingredients` WHERE `product_id` IS NOT NULL AND `ingredient_id` IS NOT NULL GROUP BY `product_id`, `ingredient_id` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] product_ingredients.product_ingredients_ingredient_id_foreign.orphans (snapshot count: 0)
-- Foreign key requires every non-null child value to reference an existing parent row
SELECT COUNT(*) AS aggregate FROM `product_ingredients` child LEFT JOIN `ingredients` parent ON child.`ingredient_id` = parent.`id` WHERE child.`ingredient_id` IS NOT NULL AND parent.`id` IS NULL;

-- [BLOCKED] product_ingredients.product_ingredients_product_id_foreign.orphans (snapshot count: 18)
-- Foreign key requires every non-null child value to reference an existing parent row
SELECT COUNT(*) AS aggregate FROM `product_ingredients` child LEFT JOIN `products` parent ON child.`product_id` = parent.`id` WHERE child.`product_id` IS NOT NULL AND parent.`id` IS NULL;

-- [PASS] product_variants.PRIMARY.unique (snapshot count: 0)
-- PRIMARY KEY requires unique non-null values
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `product_variants` WHERE `id` IS NOT NULL GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] product_variants.product_variants_product_id_variant_id_unique.unique (snapshot count: 0)
-- UNIQUE index requires no duplicate non-null tuples
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `product_variants` WHERE `product_id` IS NOT NULL AND `variant_id` IS NOT NULL GROUP BY `product_id`, `variant_id` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [BLOCKED] product_variants.product_variants_product_id_foreign.orphans (snapshot count: 84)
-- Foreign key requires every non-null child value to reference an existing parent row
SELECT COUNT(*) AS aggregate FROM `product_variants` child LEFT JOIN `products` parent ON child.`product_id` = parent.`id` WHERE child.`product_id` IS NOT NULL AND parent.`id` IS NULL;

-- [PASS] product_variants.product_variants_variant_id_foreign.orphans (snapshot count: 0)
-- Foreign key requires every non-null child value to reference an existing parent row
SELECT COUNT(*) AS aggregate FROM `product_variants` child LEFT JOIN `variants` parent ON child.`variant_id` = parent.`id` WHERE child.`variant_id` IS NOT NULL AND parent.`id` IS NULL;

-- [PASS] products.PRIMARY.unique (snapshot count: 0)
-- PRIMARY KEY requires unique non-null values
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `products` WHERE `id` IS NOT NULL GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] products.products_article_unique.unique (snapshot count: 0)
-- UNIQUE index requires no duplicate non-null tuples
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `products` WHERE `article` IS NOT NULL GROUP BY `article` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] products.products_code_unique.unique (snapshot count: 0)
-- UNIQUE index requires no duplicate non-null tuples
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `products` WHERE `code` IS NOT NULL GROUP BY `code` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] products.products_slug_unique.unique (snapshot count: 0)
-- UNIQUE index requires no duplicate non-null tuples
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `products` WHERE `slug` IS NOT NULL GROUP BY `slug` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] products.products_product_brand_id_foreign.orphans (snapshot count: 0)
-- Foreign key requires every non-null child value to reference an existing parent row
SELECT COUNT(*) AS aggregate FROM `products` child LEFT JOIN `product_brands` parent ON child.`product_brand_id` = parent.`id` WHERE child.`product_brand_id` IS NOT NULL AND parent.`id` IS NULL;

-- [PASS] products.products_product_category_id_foreign.orphans (snapshot count: 0)
-- Foreign key requires every non-null child value to reference an existing parent row
SELECT COUNT(*) AS aggregate FROM `products` child LEFT JOIN `product_categories` parent ON child.`product_category_id` = parent.`id` WHERE child.`product_category_id` IS NOT NULL AND parent.`id` IS NULL;

-- [PASS] regions.PRIMARY.unique (snapshot count: 0)
-- PRIMARY KEY requires unique non-null values
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `regions` WHERE `id` IS NOT NULL GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] regions.regions_code_unique.unique (snapshot count: 0)
-- UNIQUE index requires no duplicate non-null tuples
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `regions` WHERE `code` IS NOT NULL GROUP BY `code` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] service_categories.PRIMARY.unique (snapshot count: 0)
-- PRIMARY KEY requires unique non-null values
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `service_categories` WHERE `id` IS NOT NULL GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] service_categories.service_categories_category_id_foreign.orphans (snapshot count: 0)
-- Foreign key requires every non-null child value to reference an existing parent row
SELECT COUNT(*) AS aggregate FROM `service_categories` child LEFT JOIN `categories` parent ON child.`category_id` = parent.`id` WHERE child.`category_id` IS NOT NULL AND parent.`id` IS NULL;

-- [BLOCKED] service_categories.service_categories_service_id_foreign.orphans (snapshot count: 33)
-- Foreign key requires every non-null child value to reference an existing parent row
SELECT COUNT(*) AS aggregate FROM `service_categories` child LEFT JOIN `services` parent ON child.`service_id` = parent.`id` WHERE child.`service_id` IS NOT NULL AND parent.`id` IS NULL;

-- [PASS] service_variant_prices.PRIMARY.unique (snapshot count: 0)
-- PRIMARY KEY requires unique non-null values
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `service_variant_prices` WHERE `id` IS NOT NULL GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] service_variant_prices.service_variant_prices_variant_id_foreign.orphans (snapshot count: 0)
-- Foreign key requires every non-null child value to reference an existing parent row
SELECT COUNT(*) AS aggregate FROM `service_variant_prices` child LEFT JOIN `service_variants` parent ON child.`variant_id` = parent.`id` WHERE child.`variant_id` IS NOT NULL AND parent.`id` IS NULL;

-- [PASS] service_variants.PRIMARY.unique (snapshot count: 0)
-- PRIMARY KEY requires unique non-null values
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `service_variants` WHERE `id` IS NOT NULL GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [BLOCKED] service_variants.service_variants_service_id_foreign.orphans (snapshot count: 120)
-- Foreign key requires every non-null child value to reference an existing parent row
SELECT COUNT(*) AS aggregate FROM `service_variants` child LEFT JOIN `services` parent ON child.`service_id` = parent.`id` WHERE child.`service_id` IS NOT NULL AND parent.`id` IS NULL;

-- [PASS] services.PRIMARY.unique (snapshot count: 0)
-- PRIMARY KEY requires unique non-null values
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `services` WHERE `id` IS NOT NULL GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] services.services_region_id_foreign.orphans (snapshot count: 0)
-- Foreign key requires every non-null child value to reference an existing parent row
SELECT COUNT(*) AS aggregate FROM `services` child LEFT JOIN `regions` parent ON child.`region_id` = parent.`id` WHERE child.`region_id` IS NOT NULL AND parent.`id` IS NULL;

-- [PASS] site_settings.PRIMARY.unique (snapshot count: 0)
-- PRIMARY KEY requires unique non-null values
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `site_settings` WHERE `id` IS NOT NULL GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] site_settings.site_settings_key_unique.unique (snapshot count: 0)
-- UNIQUE index requires no duplicate non-null tuples
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `site_settings` WHERE `key` IS NOT NULL GROUP BY `key` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] social_links.PRIMARY.unique (snapshot count: 0)
-- PRIMARY KEY requires unique non-null values
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `social_links` WHERE `id` IS NOT NULL GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] social_links.social_links_region_id_foreign.orphans (snapshot count: 0)
-- Foreign key requires every non-null child value to reference an existing parent row
SELECT COUNT(*) AS aggregate FROM `social_links` child LEFT JOIN `regions` parent ON child.`region_id` = parent.`id` WHERE child.`region_id` IS NOT NULL AND parent.`id` IS NULL;

-- [PASS] special_offers.PRIMARY.unique (snapshot count: 0)
-- PRIMARY KEY requires unique non-null values
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `special_offers` WHERE `id` IS NOT NULL GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] special_offers.special_offers_region_id_foreign.orphans (snapshot count: 0)
-- Foreign key requires every non-null child value to reference an existing parent row
SELECT COUNT(*) AS aggregate FROM `special_offers` child LEFT JOIN `regions` parent ON child.`region_id` = parent.`id` WHERE child.`region_id` IS NOT NULL AND parent.`id` IS NULL;

-- [PASS] team_members.team_members_region_id_foreign.orphans (snapshot count: 0)
-- Foreign key requires every non-null child value to reference an existing parent row
SELECT COUNT(*) AS aggregate FROM `team_members` child LEFT JOIN `regions` parent ON child.`region_id` = parent.`id` WHERE child.`region_id` IS NOT NULL AND parent.`id` IS NULL;

-- [PASS] users.PRIMARY.unique (snapshot count: 0)
-- PRIMARY KEY requires unique non-null values
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `users` WHERE `id` IS NOT NULL GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] users.users_email_unique.unique (snapshot count: 0)
-- UNIQUE index requires no duplicate non-null tuples
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `users` WHERE `email` IS NOT NULL GROUP BY `email` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] users.users_telegram_id_unique.unique (snapshot count: 0)
-- UNIQUE index requires no duplicate non-null tuples
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `users` WHERE `telegram_id` IS NOT NULL GROUP BY `telegram_id` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] variants.PRIMARY.unique (snapshot count: 0)
-- PRIMARY KEY requires unique non-null values
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `variants` WHERE `id` IS NOT NULL GROUP BY `id` HAVING COUNT(*) > 1) AS duplicate_keys;

-- [PASS] variants.variants_slug_unique.unique (snapshot count: 0)
-- UNIQUE index requires no duplicate non-null tuples
SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM `variants` WHERE `slug` IS NOT NULL GROUP BY `slug` HAVING COUNT(*) > 1) AS duplicate_keys;

-- ============================================================
-- REPAIR: all statements remain commented until verified
-- ============================================================

-- ------------------------------------------------------------
-- TABLE abouts
-- ------------------------------------------------------------

-- STEP 1 [SAFE] column: accent_dubai
-- Restore the expected column definition
-- Requires abouts.accent_dubai.valid_json = 0; snapshot result: 0
-- ALTER TABLE `abouts` MODIFY COLUMN `accent_dubai` json NULL DEFAULT NULL;

-- STEP 2 [SAFE] column: accent_ua
-- Restore the expected column definition
-- Requires abouts.accent_ua.valid_json = 0; snapshot result: 0
-- ALTER TABLE `abouts` MODIFY COLUMN `accent_ua` json NULL DEFAULT NULL;

-- STEP 3 [SAFE] column: code
-- Restore the expected column definition
-- Requires abouts.code.not_null = 0; snapshot result: 0
-- Requires abouts.code.max_length = 0; snapshot result: 0
-- ALTER TABLE `abouts` MODIFY COLUMN `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- STEP 4 [SAFE] column: created_at
-- Restore the expected column definition
-- Requires abouts.created_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `abouts` MODIFY COLUMN `created_at` timestamp NULL DEFAULT NULL;

-- STEP 5 [SAFE] column: id
-- Normalize the ID column before adding its primary key
-- Requires abouts.id.not_null = 0; snapshot result: 0
-- Requires abouts.id.auto_increment_values = 0; snapshot result: 0
-- Requires abouts.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires abouts.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `abouts` MODIFY COLUMN `id` bigint unsigned NOT NULL;

-- STEP 6 [SAFE] column: label_dubai
-- Restore the expected column definition
-- Requires abouts.label_dubai.valid_json = 0; snapshot result: 0
-- ALTER TABLE `abouts` MODIFY COLUMN `label_dubai` json NULL DEFAULT NULL;

-- STEP 7 [SAFE] column: text_dubai
-- Restore the expected column definition
-- Requires abouts.text_dubai.valid_json = 0; snapshot result: 0
-- ALTER TABLE `abouts` MODIFY COLUMN `text_dubai` json NULL DEFAULT NULL;

-- STEP 8 [SAFE] column: text_ua
-- Restore the expected column definition
-- Requires abouts.text_ua.valid_json = 0; snapshot result: 0
-- ALTER TABLE `abouts` MODIFY COLUMN `text_ua` json NULL DEFAULT NULL;

-- STEP 9 [SAFE] column: updated_at
-- Restore the expected column definition
-- Requires abouts.updated_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `abouts` MODIFY COLUMN `updated_at` timestamp NULL DEFAULT NULL;

-- ------------------------------------------------------------
-- TABLE action_events
-- ------------------------------------------------------------

-- STEP 10 [SAFE] column: actionable_id
-- Restore the expected column definition
-- Requires action_events.actionable_id.not_null = 0; snapshot result: 0
-- Requires action_events.actionable_id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `action_events` MODIFY COLUMN `actionable_id` bigint unsigned NOT NULL;

-- STEP 11 [SAFE] column: actionable_type
-- Restore the expected column definition
-- Requires action_events.actionable_type.not_null = 0; snapshot result: 0
-- Requires action_events.actionable_type.max_length = 0; snapshot result: 0
-- ALTER TABLE `action_events` MODIFY COLUMN `actionable_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- STEP 12 [SAFE] column: batch_id
-- Restore the expected column definition
-- Requires action_events.batch_id.not_null = 0; snapshot result: 0
-- Requires action_events.batch_id.max_length = 0; snapshot result: 0
-- ALTER TABLE `action_events` MODIFY COLUMN `batch_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- STEP 13 [SAFE] column: changes
-- Restore the expected column definition
-- ALTER TABLE `action_events` MODIFY COLUMN `changes` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- STEP 14 [SAFE] column: created_at
-- Restore the expected column definition
-- Requires action_events.created_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `action_events` MODIFY COLUMN `created_at` timestamp NULL DEFAULT NULL;

-- STEP 15 [SAFE] column: exception
-- Restore the expected column definition
-- Requires action_events.exception.not_null = 0; snapshot result: 0
-- ALTER TABLE `action_events` MODIFY COLUMN `exception` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- STEP 16 [SAFE] column: fields
-- Restore the expected column definition
-- Requires action_events.fields.not_null = 0; snapshot result: 0
-- ALTER TABLE `action_events` MODIFY COLUMN `fields` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- STEP 17 [BLOCKED] column: id
-- Normalize the ID column before adding its primary key
-- Requires action_events.id.not_null = 0; snapshot result: 188
-- Requires action_events.id.auto_increment_values = 0; snapshot result: 188
-- Requires action_events.id.auto_increment_duplicates = 0; snapshot result: 1
-- Requires action_events.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `action_events` MODIFY COLUMN `id` bigint unsigned NOT NULL;

-- STEP 18 [SAFE] column: model_id
-- Restore the expected column definition
-- Requires action_events.model_id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `action_events` MODIFY COLUMN `model_id` bigint unsigned NULL DEFAULT NULL;

-- STEP 19 [SAFE] column: model_type
-- Restore the expected column definition
-- Requires action_events.model_type.not_null = 0; snapshot result: 0
-- Requires action_events.model_type.max_length = 0; snapshot result: 0
-- ALTER TABLE `action_events` MODIFY COLUMN `model_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- STEP 20 [SAFE] column: name
-- Restore the expected column definition
-- Requires action_events.name.not_null = 0; snapshot result: 0
-- Requires action_events.name.max_length = 0; snapshot result: 0
-- ALTER TABLE `action_events` MODIFY COLUMN `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- STEP 21 [SAFE] column: original
-- Restore the expected column definition
-- ALTER TABLE `action_events` MODIFY COLUMN `original` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- STEP 22 [SAFE] column: status
-- Restore the expected column definition
-- Requires action_events.status.not_null = 0; snapshot result: 0
-- Requires action_events.status.max_length = 0; snapshot result: 0
-- ALTER TABLE `action_events` MODIFY COLUMN `status` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'running';

-- STEP 23 [SAFE] column: target_id
-- Restore the expected column definition
-- Requires action_events.target_id.not_null = 0; snapshot result: 0
-- Requires action_events.target_id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `action_events` MODIFY COLUMN `target_id` bigint unsigned NOT NULL;

-- STEP 24 [SAFE] column: target_type
-- Restore the expected column definition
-- Requires action_events.target_type.not_null = 0; snapshot result: 0
-- Requires action_events.target_type.max_length = 0; snapshot result: 0
-- ALTER TABLE `action_events` MODIFY COLUMN `target_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- STEP 25 [SAFE] column: updated_at
-- Restore the expected column definition
-- Requires action_events.updated_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `action_events` MODIFY COLUMN `updated_at` timestamp NULL DEFAULT NULL;

-- STEP 26 [SAFE] column: user_id
-- Restore the expected column definition
-- Requires action_events.user_id.not_null = 0; snapshot result: 0
-- Requires action_events.user_id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `action_events` MODIFY COLUMN `user_id` bigint unsigned NOT NULL;

-- ------------------------------------------------------------
-- TABLE appointments
-- ------------------------------------------------------------

-- STEP 27 [SAFE] column: created_at
-- Restore the expected column definition
-- Requires appointments.created_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `appointments` MODIFY COLUMN `created_at` timestamp NULL DEFAULT NULL;

-- STEP 28 [SAFE] column: email
-- Restore the expected column definition
-- Requires appointments.email.max_length = 0; snapshot result: 0
-- ALTER TABLE `appointments` MODIFY COLUMN `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- STEP 29 [SAFE] column: from_page
-- Restore the expected column definition
-- Requires appointments.from_page.max_length = 0; snapshot result: 0
-- ALTER TABLE `appointments` MODIFY COLUMN `from_page` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- STEP 30 [SAFE] column: goal
-- Restore the expected column definition
-- Requires appointments.goal.max_length = 0; snapshot result: 0
-- ALTER TABLE `appointments` MODIFY COLUMN `goal` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- STEP 31 [BLOCKED] column: id
-- Normalize the ID column before adding its primary key
-- Requires appointments.id.not_null = 0; snapshot result: 16
-- Requires appointments.id.auto_increment_values = 0; snapshot result: 16
-- Requires appointments.id.auto_increment_duplicates = 0; snapshot result: 1
-- Requires appointments.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `appointments` MODIFY COLUMN `id` bigint unsigned NOT NULL;

-- STEP 32 [SAFE] column: name
-- Restore the expected column definition
-- Requires appointments.name.max_length = 0; snapshot result: 0
-- ALTER TABLE `appointments` MODIFY COLUMN `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- STEP 33 [REVIEW] column: phone
-- Restore the expected column definition
-- Requires appointments.phone.max_length = 0; snapshot result: 0
-- Requires appointments.phone.numeric_to_text_review = 0; snapshot result: manual review
-- ALTER TABLE `appointments` MODIFY COLUMN `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- STEP 34 [SAFE] column: referrer
-- Restore the expected column definition
-- ALTER TABLE `appointments` MODIFY COLUMN `referrer` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- STEP 35 [SAFE] column: region
-- Restore the expected column definition
-- Requires appointments.region.max_length = 0; snapshot result: 0
-- ALTER TABLE `appointments` MODIFY COLUMN `region` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- STEP 36 [SAFE] column: treatment
-- Restore the expected column definition
-- ALTER TABLE `appointments` MODIFY COLUMN `treatment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- STEP 37 [SAFE] column: updated_at
-- Restore the expected column definition
-- Requires appointments.updated_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `appointments` MODIFY COLUMN `updated_at` timestamp NULL DEFAULT NULL;

-- STEP 38 [SAFE] column: utm_campaign
-- Restore the expected column definition
-- Requires appointments.utm_campaign.max_length = 0; snapshot result: 0
-- ALTER TABLE `appointments` MODIFY COLUMN `utm_campaign` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- STEP 39 [SAFE] column: utm_content
-- Restore the expected column definition
-- Requires appointments.utm_content.max_length = 0; snapshot result: 0
-- ALTER TABLE `appointments` MODIFY COLUMN `utm_content` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- STEP 40 [SAFE] column: utm_medium
-- Restore the expected column definition
-- Requires appointments.utm_medium.max_length = 0; snapshot result: 0
-- ALTER TABLE `appointments` MODIFY COLUMN `utm_medium` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- STEP 41 [SAFE] column: utm_source
-- Restore the expected column definition
-- Requires appointments.utm_source.max_length = 0; snapshot result: 0
-- ALTER TABLE `appointments` MODIFY COLUMN `utm_source` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- STEP 42 [SAFE] column: utm_term
-- Restore the expected column definition
-- Requires appointments.utm_term.max_length = 0; snapshot result: 0
-- ALTER TABLE `appointments` MODIFY COLUMN `utm_term` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- ------------------------------------------------------------
-- TABLE banners
-- ------------------------------------------------------------

-- STEP 43 [SAFE] column: created_at
-- Restore the expected column definition
-- Requires banners.created_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `banners` MODIFY COLUMN `created_at` timestamp NULL DEFAULT NULL;

-- STEP 44 [SAFE] column: id
-- Normalize the ID column before adding its primary key
-- Requires banners.id.not_null = 0; snapshot result: 0
-- Requires banners.id.auto_increment_values = 0; snapshot result: 0
-- Requires banners.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires banners.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `banners` MODIFY COLUMN `id` bigint unsigned NOT NULL;

-- STEP 45 [SAFE] column: is_show
-- Restore the expected column definition
-- Requires banners.is_show.not_null = 0; snapshot result: 0
-- Requires banners.is_show.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `banners` MODIFY COLUMN `is_show` tinyint(1) NOT NULL DEFAULT '0';

-- STEP 46 [SAFE] column: title
-- Restore the expected column definition
-- Requires banners.title.valid_json = 0; snapshot result: 0
-- ALTER TABLE `banners` MODIFY COLUMN `title` json NULL DEFAULT NULL;

-- STEP 47 [SAFE] column: updated_at
-- Restore the expected column definition
-- Requires banners.updated_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `banners` MODIFY COLUMN `updated_at` timestamp NULL DEFAULT NULL;

-- ------------------------------------------------------------
-- TABLE call_us
-- ------------------------------------------------------------

-- STEP 48 [SAFE] column: created_at
-- Restore the expected column definition
-- Requires call_us.created_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `call_us` MODIFY COLUMN `created_at` timestamp NULL DEFAULT NULL;

-- STEP 49 [SAFE] column: email_dubai
-- Restore the expected column definition
-- Requires call_us.email_dubai.max_length = 0; snapshot result: 0
-- ALTER TABLE `call_us` MODIFY COLUMN `email_dubai` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- STEP 50 [SAFE] column: email_ua
-- Restore the expected column definition
-- Requires call_us.email_ua.max_length = 0; snapshot result: 0
-- ALTER TABLE `call_us` MODIFY COLUMN `email_ua` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- STEP 51 [SAFE] column: id
-- Normalize the ID column before adding its primary key
-- Requires call_us.id.not_null = 0; snapshot result: 0
-- Requires call_us.id.auto_increment_values = 0; snapshot result: 0
-- Requires call_us.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires call_us.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `call_us` MODIFY COLUMN `id` bigint unsigned NOT NULL;

-- STEP 52 [SAFE] column: phone_dubai
-- Restore the expected column definition
-- Requires call_us.phone_dubai.max_length = 0; snapshot result: 0
-- ALTER TABLE `call_us` MODIFY COLUMN `phone_dubai` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- STEP 53 [SAFE] column: phone_ua
-- Restore the expected column definition
-- Requires call_us.phone_ua.max_length = 0; snapshot result: 0
-- ALTER TABLE `call_us` MODIFY COLUMN `phone_ua` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- STEP 54 [SAFE] column: text
-- Restore the expected column definition
-- Requires call_us.text.valid_json = 0; snapshot result: 0
-- ALTER TABLE `call_us` MODIFY COLUMN `text` json NULL DEFAULT NULL;

-- STEP 55 [SAFE] column: updated_at
-- Restore the expected column definition
-- Requires call_us.updated_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `call_us` MODIFY COLUMN `updated_at` timestamp NULL DEFAULT NULL;

-- ------------------------------------------------------------
-- TABLE categories
-- ------------------------------------------------------------

-- STEP 56 [SAFE] column: created_at
-- Restore the expected column definition
-- Requires categories.created_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `categories` MODIFY COLUMN `created_at` timestamp NULL DEFAULT NULL;

-- STEP 57 [SAFE] column: description
-- Restore the expected column definition
-- Requires categories.description.valid_json = 0; snapshot result: 0
-- ALTER TABLE `categories` MODIFY COLUMN `description` json NULL DEFAULT NULL;

-- STEP 58 [SAFE] column: id
-- Normalize the ID column before adding its primary key
-- Requires categories.id.not_null = 0; snapshot result: 0
-- Requires categories.id.auto_increment_values = 0; snapshot result: 0
-- Requires categories.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires categories.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `categories` MODIFY COLUMN `id` bigint unsigned NOT NULL;

-- STEP 59 [SAFE] column: order
-- Restore the expected column definition
-- Requires categories.order.not_null = 0; snapshot result: 0
-- Requires categories.order.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `categories` MODIFY COLUMN `order` int NOT NULL DEFAULT '0';

-- STEP 60 [SAFE] column: seo_text
-- Restore the expected column definition
-- Requires categories.seo_text.valid_json = 0; snapshot result: 0
-- ALTER TABLE `categories` MODIFY COLUMN `seo_text` json NULL DEFAULT NULL;

-- STEP 61 [SAFE] column: title
-- Restore the expected column definition
-- Requires categories.title.not_null = 0; snapshot result: 0
-- Requires categories.title.valid_json = 0; snapshot result: 0
-- ALTER TABLE `categories` MODIFY COLUMN `title` json NOT NULL;

-- STEP 62 [SAFE] column: updated_at
-- Restore the expected column definition
-- Requires categories.updated_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `categories` MODIFY COLUMN `updated_at` timestamp NULL DEFAULT NULL;

-- ------------------------------------------------------------
-- TABLE contacts
-- ------------------------------------------------------------

-- STEP 63 [SAFE] column: address
-- Restore the expected column definition
-- Requires contacts.address.max_length = 0; snapshot result: 0
-- ALTER TABLE `contacts` MODIFY COLUMN `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- STEP 64 [SAFE] column: created_at
-- Restore the expected column definition
-- Requires contacts.created_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `contacts` MODIFY COLUMN `created_at` timestamp NULL DEFAULT NULL;

-- STEP 65 [SAFE] column: email
-- Restore the expected column definition
-- Requires contacts.email.max_length = 0; snapshot result: 0
-- ALTER TABLE `contacts` MODIFY COLUMN `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- STEP 66 [SAFE] column: id
-- Normalize the ID column before adding its primary key
-- Requires contacts.id.not_null = 0; snapshot result: 0
-- Requires contacts.id.auto_increment_values = 0; snapshot result: 0
-- Requires contacts.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires contacts.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `contacts` MODIFY COLUMN `id` bigint unsigned NOT NULL;

-- STEP 67 [SAFE] column: map_point
-- Restore the expected column definition
-- Requires contacts.map_point.max_length = 0; snapshot result: 0
-- ALTER TABLE `contacts` MODIFY COLUMN `map_point` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- STEP 68 [SAFE] column: order
-- Restore the expected column definition
-- Requires contacts.order.not_null = 0; snapshot result: 0
-- Requires contacts.order.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `contacts` MODIFY COLUMN `order` bigint NOT NULL DEFAULT '0';

-- STEP 69 [SAFE] column: phone
-- Restore the expected column definition
-- Requires contacts.phone.max_length = 0; snapshot result: 0
-- ALTER TABLE `contacts` MODIFY COLUMN `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- STEP 70 [SAFE] column: updated_at
-- Restore the expected column definition
-- Requires contacts.updated_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `contacts` MODIFY COLUMN `updated_at` timestamp NULL DEFAULT NULL;

-- ------------------------------------------------------------
-- TABLE devices
-- ------------------------------------------------------------

-- STEP 71 [SAFE] column: code
-- Restore the expected column definition
-- Requires devices.code.max_length = 0; snapshot result: 0
-- ALTER TABLE `devices` MODIFY COLUMN `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- STEP 72 [SAFE] column: created_at
-- Restore the expected column definition
-- Requires devices.created_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `devices` MODIFY COLUMN `created_at` timestamp NULL DEFAULT NULL;

-- STEP 73 [SAFE] column: description
-- Restore the expected column definition
-- Requires devices.description.valid_json = 0; snapshot result: 0
-- ALTER TABLE `devices` MODIFY COLUMN `description` json NULL DEFAULT NULL;

-- STEP 74 [BLOCKED] column: id
-- Normalize the ID column before adding its primary key
-- Requires devices.id.not_null = 0; snapshot result: 4
-- Requires devices.id.auto_increment_values = 0; snapshot result: 4
-- Requires devices.id.auto_increment_duplicates = 0; snapshot result: 1
-- Requires devices.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `devices` MODIFY COLUMN `id` bigint unsigned NOT NULL;

-- STEP 75 [SAFE] column: link
-- Restore the expected column definition
-- ALTER TABLE `devices` MODIFY COLUMN `link` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- STEP 76 [SAFE] column: order
-- Restore the expected column definition
-- Requires devices.order.not_null = 0; snapshot result: 0
-- Requires devices.order.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `devices` MODIFY COLUMN `order` int NOT NULL DEFAULT '0';

-- STEP 77 [SAFE] column: region_id
-- Restore the expected column definition
-- Requires devices.region_id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `devices` MODIFY COLUMN `region_id` bigint unsigned NULL DEFAULT NULL;

-- STEP 78 [SAFE] column: title
-- Restore the expected column definition
-- Requires devices.title.not_null = 0; snapshot result: 0
-- Requires devices.title.valid_json = 0; snapshot result: 0
-- ALTER TABLE `devices` MODIFY COLUMN `title` json NOT NULL;

-- STEP 79 [SAFE] column: updated_at
-- Restore the expected column definition
-- Requires devices.updated_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `devices` MODIFY COLUMN `updated_at` timestamp NULL DEFAULT NULL;

-- ------------------------------------------------------------
-- TABLE failed_jobs
-- ------------------------------------------------------------

-- STEP 80 [SAFE] column: connection
-- Restore the expected column definition
-- Requires failed_jobs.connection.not_null = 0; snapshot result: 0
-- ALTER TABLE `failed_jobs` MODIFY COLUMN `connection` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- STEP 81 [SAFE] column: exception
-- Restore the expected column definition
-- Requires failed_jobs.exception.not_null = 0; snapshot result: 0
-- ALTER TABLE `failed_jobs` MODIFY COLUMN `exception` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- STEP 82 [SAFE] column: failed_at
-- Restore the expected column definition
-- Requires failed_jobs.failed_at.not_null = 0; snapshot result: 0
-- Requires failed_jobs.failed_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `failed_jobs` MODIFY COLUMN `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP;

-- STEP 83 [SAFE] column: id
-- Normalize the ID column before adding its primary key
-- Requires failed_jobs.id.not_null = 0; snapshot result: 0
-- Requires failed_jobs.id.auto_increment_values = 0; snapshot result: 0
-- Requires failed_jobs.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires failed_jobs.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `failed_jobs` MODIFY COLUMN `id` bigint unsigned NOT NULL;

-- STEP 84 [SAFE] column: payload
-- Restore the expected column definition
-- Requires failed_jobs.payload.not_null = 0; snapshot result: 0
-- ALTER TABLE `failed_jobs` MODIFY COLUMN `payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- STEP 85 [SAFE] column: queue
-- Restore the expected column definition
-- Requires failed_jobs.queue.not_null = 0; snapshot result: 0
-- ALTER TABLE `failed_jobs` MODIFY COLUMN `queue` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- STEP 86 [SAFE] column: uuid
-- Restore the expected column definition
-- Requires failed_jobs.uuid.not_null = 0; snapshot result: 0
-- Requires failed_jobs.uuid.max_length = 0; snapshot result: 0
-- ALTER TABLE `failed_jobs` MODIFY COLUMN `uuid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- ------------------------------------------------------------
-- TABLE galleries
-- ------------------------------------------------------------

-- STEP 87 [SAFE] column: created_at
-- Restore the expected column definition
-- Requires galleries.created_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `galleries` MODIFY COLUMN `created_at` timestamp NULL DEFAULT NULL;

-- STEP 88 [SAFE] column: id
-- Normalize the ID column before adding its primary key
-- Requires galleries.id.not_null = 0; snapshot result: 0
-- Requires galleries.id.auto_increment_values = 0; snapshot result: 0
-- Requires galleries.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires galleries.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `galleries` MODIFY COLUMN `id` bigint unsigned NOT NULL;

-- STEP 89 [SAFE] column: is_show
-- Restore the expected column definition
-- Requires galleries.is_show.not_null = 0; snapshot result: 0
-- Requires galleries.is_show.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `galleries` MODIFY COLUMN `is_show` tinyint(1) NOT NULL DEFAULT '0';

-- STEP 90 [SAFE] column: region_id
-- Restore the expected column definition
-- Requires galleries.region_id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `galleries` MODIFY COLUMN `region_id` bigint unsigned NULL DEFAULT NULL;

-- STEP 91 [SAFE] column: title
-- Restore the expected column definition
-- Requires galleries.title.valid_json = 0; snapshot result: 0
-- ALTER TABLE `galleries` MODIFY COLUMN `title` json NULL DEFAULT NULL;

-- STEP 92 [SAFE] column: updated_at
-- Restore the expected column definition
-- Requires galleries.updated_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `galleries` MODIFY COLUMN `updated_at` timestamp NULL DEFAULT NULL;

-- ------------------------------------------------------------
-- TABLE ingredients
-- ------------------------------------------------------------

-- STEP 93 [SAFE] column: created_at
-- Restore the expected column definition
-- Requires ingredients.created_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `ingredients` MODIFY COLUMN `created_at` timestamp NULL DEFAULT NULL;

-- STEP 94 [SAFE] column: id
-- Normalize the ID column before adding its primary key
-- Requires ingredients.id.not_null = 0; snapshot result: 0
-- Requires ingredients.id.auto_increment_values = 0; snapshot result: 0
-- Requires ingredients.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires ingredients.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `ingredients` MODIFY COLUMN `id` bigint unsigned NOT NULL;

-- STEP 95 [SAFE] column: is_active
-- Restore the expected column definition
-- Requires ingredients.is_active.not_null = 0; snapshot result: 0
-- Requires ingredients.is_active.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `ingredients` MODIFY COLUMN `is_active` tinyint(1) NOT NULL DEFAULT '1';

-- STEP 96 [SAFE] column: is_show_filter
-- Restore the expected column definition
-- Requires ingredients.is_show_filter.not_null = 0; snapshot result: 0
-- Requires ingredients.is_show_filter.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `ingredients` MODIFY COLUMN `is_show_filter` tinyint(1) NOT NULL DEFAULT '0';

-- STEP 97 [SAFE] column: is_show_nav
-- Restore the expected column definition
-- Requires ingredients.is_show_nav.not_null = 0; snapshot result: 0
-- Requires ingredients.is_show_nav.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `ingredients` MODIFY COLUMN `is_show_nav` tinyint(1) NOT NULL DEFAULT '1';

-- STEP 98 [SAFE] column: name
-- Restore the expected column definition
-- Requires ingredients.name.not_null = 0; snapshot result: 0
-- Requires ingredients.name.valid_json = 0; snapshot result: 0
-- ALTER TABLE `ingredients` MODIFY COLUMN `name` json NOT NULL;

-- STEP 99 [SAFE] column: order
-- Restore the expected column definition
-- Requires ingredients.order.not_null = 0; snapshot result: 0
-- Requires ingredients.order.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `ingredients` MODIFY COLUMN `order` bigint unsigned NOT NULL DEFAULT '0';

-- STEP 100 [SAFE] column: seo_text
-- Restore the expected column definition
-- Requires ingredients.seo_text.valid_json = 0; snapshot result: 0
-- ALTER TABLE `ingredients` MODIFY COLUMN `seo_text` json NULL DEFAULT NULL;

-- STEP 101 [SAFE] column: slug
-- Restore the expected column definition
-- Requires ingredients.slug.max_length = 0; snapshot result: 0
-- ALTER TABLE `ingredients` MODIFY COLUMN `slug` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- STEP 102 [SAFE] column: updated_at
-- Restore the expected column definition
-- Requires ingredients.updated_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `ingredients` MODIFY COLUMN `updated_at` timestamp NULL DEFAULT NULL;

-- ------------------------------------------------------------
-- TABLE locations
-- ------------------------------------------------------------

-- STEP 103 [SAFE] column: created_at
-- Restore the expected column definition
-- Requires locations.created_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `locations` MODIFY COLUMN `created_at` timestamp NULL DEFAULT NULL;

-- STEP 104 [SAFE] column: email
-- Restore the expected column definition
-- Requires locations.email.max_length = 0; snapshot result: 0
-- ALTER TABLE `locations` MODIFY COLUMN `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- STEP 105 [SAFE] column: id
-- Normalize the ID column before adding its primary key
-- Requires locations.id.not_null = 0; snapshot result: 0
-- Requires locations.id.auto_increment_values = 0; snapshot result: 0
-- Requires locations.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires locations.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `locations` MODIFY COLUMN `id` bigint unsigned NOT NULL;

-- STEP 106 [SAFE] column: map
-- Restore the expected column definition
-- ALTER TABLE `locations` MODIFY COLUMN `map` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- STEP 107 [SAFE] column: phone
-- Restore the expected column definition
-- Requires locations.phone.max_length = 0; snapshot result: 0
-- ALTER TABLE `locations` MODIFY COLUMN `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- STEP 108 [SAFE] column: subtitle
-- Restore the expected column definition
-- Requires locations.subtitle.valid_json = 0; snapshot result: 0
-- ALTER TABLE `locations` MODIFY COLUMN `subtitle` json NULL DEFAULT NULL;

-- STEP 109 [SAFE] column: title
-- Restore the expected column definition
-- Requires locations.title.valid_json = 0; snapshot result: 0
-- ALTER TABLE `locations` MODIFY COLUMN `title` json NULL DEFAULT NULL;

-- STEP 110 [SAFE] column: updated_at
-- Restore the expected column definition
-- Requires locations.updated_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `locations` MODIFY COLUMN `updated_at` timestamp NULL DEFAULT NULL;

-- ------------------------------------------------------------
-- TABLE media
-- ------------------------------------------------------------

-- STEP 111 [SAFE] column: collection_name
-- Restore the expected column definition
-- Requires media.collection_name.not_null = 0; snapshot result: 0
-- Requires media.collection_name.max_length = 0; snapshot result: 0
-- ALTER TABLE `media` MODIFY COLUMN `collection_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- STEP 112 [SAFE] column: conversions_disk
-- Restore the expected column definition
-- Requires media.conversions_disk.max_length = 0; snapshot result: 0
-- ALTER TABLE `media` MODIFY COLUMN `conversions_disk` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- STEP 113 [SAFE] column: created_at
-- Restore the expected column definition
-- Requires media.created_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `media` MODIFY COLUMN `created_at` timestamp NULL DEFAULT NULL;

-- STEP 114 [SAFE] column: custom_properties
-- Restore the expected column definition
-- Requires media.custom_properties.not_null = 0; snapshot result: 0
-- Requires media.custom_properties.valid_json = 0; snapshot result: 0
-- ALTER TABLE `media` MODIFY COLUMN `custom_properties` json NOT NULL;

-- STEP 115 [SAFE] column: disk
-- Restore the expected column definition
-- Requires media.disk.not_null = 0; snapshot result: 0
-- Requires media.disk.max_length = 0; snapshot result: 0
-- ALTER TABLE `media` MODIFY COLUMN `disk` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- STEP 116 [SAFE] column: file_name
-- Restore the expected column definition
-- Requires media.file_name.not_null = 0; snapshot result: 0
-- Requires media.file_name.max_length = 0; snapshot result: 0
-- ALTER TABLE `media` MODIFY COLUMN `file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- STEP 117 [SAFE] column: generated_conversions
-- Restore the expected column definition
-- Requires media.generated_conversions.not_null = 0; snapshot result: 0
-- Requires media.generated_conversions.valid_json = 0; snapshot result: 0
-- ALTER TABLE `media` MODIFY COLUMN `generated_conversions` json NOT NULL;

-- STEP 118 [SAFE] column: id
-- Normalize the ID column before adding its primary key
-- Requires media.id.not_null = 0; snapshot result: 0
-- Requires media.id.auto_increment_values = 0; snapshot result: 0
-- Requires media.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires media.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `media` MODIFY COLUMN `id` bigint unsigned NOT NULL;

-- STEP 119 [SAFE] column: manipulations
-- Restore the expected column definition
-- Requires media.manipulations.not_null = 0; snapshot result: 0
-- Requires media.manipulations.valid_json = 0; snapshot result: 0
-- ALTER TABLE `media` MODIFY COLUMN `manipulations` json NOT NULL;

-- STEP 120 [SAFE] column: mime_type
-- Restore the expected column definition
-- Requires media.mime_type.max_length = 0; snapshot result: 0
-- ALTER TABLE `media` MODIFY COLUMN `mime_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- STEP 121 [SAFE] column: model_id
-- Restore the expected column definition
-- Requires media.model_id.not_null = 0; snapshot result: 0
-- Requires media.model_id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `media` MODIFY COLUMN `model_id` bigint unsigned NOT NULL;

-- STEP 122 [SAFE] column: model_type
-- Restore the expected column definition
-- Requires media.model_type.not_null = 0; snapshot result: 0
-- Requires media.model_type.max_length = 0; snapshot result: 0
-- ALTER TABLE `media` MODIFY COLUMN `model_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- STEP 123 [SAFE] column: name
-- Restore the expected column definition
-- Requires media.name.not_null = 0; snapshot result: 0
-- Requires media.name.max_length = 0; snapshot result: 0
-- ALTER TABLE `media` MODIFY COLUMN `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- STEP 124 [SAFE] column: order_column
-- Restore the expected column definition
-- Requires media.order_column.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `media` MODIFY COLUMN `order_column` int unsigned NULL DEFAULT NULL;

-- STEP 125 [SAFE] column: responsive_images
-- Restore the expected column definition
-- Requires media.responsive_images.not_null = 0; snapshot result: 0
-- Requires media.responsive_images.valid_json = 0; snapshot result: 0
-- ALTER TABLE `media` MODIFY COLUMN `responsive_images` json NOT NULL;

-- STEP 126 [SAFE] column: size
-- Restore the expected column definition
-- Requires media.size.not_null = 0; snapshot result: 0
-- Requires media.size.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `media` MODIFY COLUMN `size` bigint unsigned NOT NULL;

-- STEP 127 [SAFE] column: updated_at
-- Restore the expected column definition
-- Requires media.updated_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `media` MODIFY COLUMN `updated_at` timestamp NULL DEFAULT NULL;

-- STEP 128 [SAFE] column: uuid
-- Restore the expected column definition
-- Requires media.uuid.max_length = 0; snapshot result: 0
-- ALTER TABLE `media` MODIFY COLUMN `uuid` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- ------------------------------------------------------------
-- TABLE migrations
-- ------------------------------------------------------------

-- STEP 129 [SAFE] column: batch
-- Restore the expected column definition
-- Requires migrations.batch.not_null = 0; snapshot result: 0
-- Requires migrations.batch.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `migrations` MODIFY COLUMN `batch` int NOT NULL;

-- STEP 130 [SAFE] column: id
-- Normalize the ID column before adding its primary key
-- Requires migrations.id.not_null = 0; snapshot result: 0
-- Requires migrations.id.auto_increment_values = 0; snapshot result: 0
-- Requires migrations.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires migrations.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `migrations` MODIFY COLUMN `id` int unsigned NOT NULL;

-- STEP 131 [SAFE] column: migration
-- Restore the expected column definition
-- Requires migrations.migration.not_null = 0; snapshot result: 0
-- Requires migrations.migration.max_length = 0; snapshot result: 0
-- ALTER TABLE `migrations` MODIFY COLUMN `migration` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- ------------------------------------------------------------
-- TABLE nova_field_attachments
-- ------------------------------------------------------------

-- STEP 132 [SAFE] column: attachable_id
-- Restore the expected column definition
-- Requires nova_field_attachments.attachable_id.not_null = 0; snapshot result: 0
-- Requires nova_field_attachments.attachable_id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `nova_field_attachments` MODIFY COLUMN `attachable_id` bigint unsigned NOT NULL;

-- STEP 133 [SAFE] column: attachable_type
-- Restore the expected column definition
-- Requires nova_field_attachments.attachable_type.not_null = 0; snapshot result: 0
-- Requires nova_field_attachments.attachable_type.max_length = 0; snapshot result: 0
-- ALTER TABLE `nova_field_attachments` MODIFY COLUMN `attachable_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- STEP 134 [SAFE] column: attachment
-- Restore the expected column definition
-- Requires nova_field_attachments.attachment.not_null = 0; snapshot result: 0
-- Requires nova_field_attachments.attachment.max_length = 0; snapshot result: 0
-- ALTER TABLE `nova_field_attachments` MODIFY COLUMN `attachment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- STEP 135 [SAFE] column: created_at
-- Restore the expected column definition
-- Requires nova_field_attachments.created_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `nova_field_attachments` MODIFY COLUMN `created_at` timestamp NULL DEFAULT NULL;

-- STEP 136 [SAFE] column: disk
-- Restore the expected column definition
-- Requires nova_field_attachments.disk.not_null = 0; snapshot result: 0
-- Requires nova_field_attachments.disk.max_length = 0; snapshot result: 0
-- ALTER TABLE `nova_field_attachments` MODIFY COLUMN `disk` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- STEP 137 [SAFE] column: id
-- Normalize the ID column before adding its primary key
-- Requires nova_field_attachments.id.not_null = 0; snapshot result: 0
-- Requires nova_field_attachments.id.auto_increment_values = 0; snapshot result: 0
-- Requires nova_field_attachments.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires nova_field_attachments.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `nova_field_attachments` MODIFY COLUMN `id` int unsigned NOT NULL;

-- STEP 138 [SAFE] column: updated_at
-- Restore the expected column definition
-- Requires nova_field_attachments.updated_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `nova_field_attachments` MODIFY COLUMN `updated_at` timestamp NULL DEFAULT NULL;

-- STEP 139 [SAFE] column: url
-- Restore the expected column definition
-- Requires nova_field_attachments.url.not_null = 0; snapshot result: 0
-- Requires nova_field_attachments.url.max_length = 0; snapshot result: 0
-- ALTER TABLE `nova_field_attachments` MODIFY COLUMN `url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- ------------------------------------------------------------
-- TABLE nova_notifications
-- ------------------------------------------------------------

-- STEP 140 [SAFE] column: created_at
-- Restore the expected column definition
-- Requires nova_notifications.created_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `nova_notifications` MODIFY COLUMN `created_at` timestamp NULL DEFAULT NULL;

-- STEP 141 [SAFE] column: data
-- Restore the expected column definition
-- Requires nova_notifications.data.not_null = 0; snapshot result: 0
-- ALTER TABLE `nova_notifications` MODIFY COLUMN `data` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- STEP 142 [SAFE] column: deleted_at
-- Restore the expected column definition
-- Requires nova_notifications.deleted_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `nova_notifications` MODIFY COLUMN `deleted_at` timestamp NULL DEFAULT NULL;

-- STEP 143 [SAFE] column: id
-- Restore the expected column definition
-- Requires nova_notifications.id.not_null = 0; snapshot result: 0
-- Requires nova_notifications.id.max_length = 0; snapshot result: 0
-- ALTER TABLE `nova_notifications` MODIFY COLUMN `id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- STEP 144 [SAFE] column: notifiable_id
-- Restore the expected column definition
-- Requires nova_notifications.notifiable_id.not_null = 0; snapshot result: 0
-- Requires nova_notifications.notifiable_id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `nova_notifications` MODIFY COLUMN `notifiable_id` bigint unsigned NOT NULL;

-- STEP 145 [SAFE] column: notifiable_type
-- Restore the expected column definition
-- Requires nova_notifications.notifiable_type.not_null = 0; snapshot result: 0
-- Requires nova_notifications.notifiable_type.max_length = 0; snapshot result: 0
-- ALTER TABLE `nova_notifications` MODIFY COLUMN `notifiable_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- STEP 146 [SAFE] column: read_at
-- Restore the expected column definition
-- Requires nova_notifications.read_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `nova_notifications` MODIFY COLUMN `read_at` timestamp NULL DEFAULT NULL;

-- STEP 147 [SAFE] column: type
-- Restore the expected column definition
-- Requires nova_notifications.type.not_null = 0; snapshot result: 0
-- Requires nova_notifications.type.max_length = 0; snapshot result: 0
-- ALTER TABLE `nova_notifications` MODIFY COLUMN `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- STEP 148 [SAFE] column: updated_at
-- Restore the expected column definition
-- Requires nova_notifications.updated_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `nova_notifications` MODIFY COLUMN `updated_at` timestamp NULL DEFAULT NULL;

-- ------------------------------------------------------------
-- TABLE nova_pending_field_attachments
-- ------------------------------------------------------------

-- STEP 149 [SAFE] column: attachment
-- Restore the expected column definition
-- Requires nova_pending_field_attachments.attachment.not_null = 0; snapshot result: 0
-- Requires nova_pending_field_attachments.attachment.max_length = 0; snapshot result: 0
-- ALTER TABLE `nova_pending_field_attachments` MODIFY COLUMN `attachment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- STEP 150 [SAFE] column: created_at
-- Restore the expected column definition
-- Requires nova_pending_field_attachments.created_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `nova_pending_field_attachments` MODIFY COLUMN `created_at` timestamp NULL DEFAULT NULL;

-- STEP 151 [SAFE] column: disk
-- Restore the expected column definition
-- Requires nova_pending_field_attachments.disk.not_null = 0; snapshot result: 0
-- Requires nova_pending_field_attachments.disk.max_length = 0; snapshot result: 0
-- ALTER TABLE `nova_pending_field_attachments` MODIFY COLUMN `disk` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- STEP 152 [SAFE] column: draft_id
-- Restore the expected column definition
-- Requires nova_pending_field_attachments.draft_id.not_null = 0; snapshot result: 0
-- Requires nova_pending_field_attachments.draft_id.max_length = 0; snapshot result: 0
-- ALTER TABLE `nova_pending_field_attachments` MODIFY COLUMN `draft_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- STEP 153 [SAFE] column: id
-- Normalize the ID column before adding its primary key
-- Requires nova_pending_field_attachments.id.not_null = 0; snapshot result: 0
-- Requires nova_pending_field_attachments.id.auto_increment_values = 0; snapshot result: 0
-- Requires nova_pending_field_attachments.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires nova_pending_field_attachments.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `nova_pending_field_attachments` MODIFY COLUMN `id` int unsigned NOT NULL;

-- STEP 154 [SAFE] column: updated_at
-- Restore the expected column definition
-- Requires nova_pending_field_attachments.updated_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `nova_pending_field_attachments` MODIFY COLUMN `updated_at` timestamp NULL DEFAULT NULL;

-- ------------------------------------------------------------
-- TABLE order_items
-- ------------------------------------------------------------

-- STEP 155 [SAFE] column: created_at
-- Restore the expected column definition
-- Requires order_items.created_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `order_items` MODIFY COLUMN `created_at` timestamp NULL DEFAULT NULL;

-- STEP 156 [SAFE] column: id
-- Normalize the ID column before adding its primary key
-- Requires order_items.id.not_null = 0; snapshot result: 0
-- Requires order_items.id.auto_increment_values = 0; snapshot result: 0
-- Requires order_items.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires order_items.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `order_items` MODIFY COLUMN `id` bigint unsigned NOT NULL;

-- STEP 157 [SAFE] column: order_id
-- Restore the expected column definition
-- Requires order_items.order_id.not_null = 0; snapshot result: 0
-- Requires order_items.order_id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `order_items` MODIFY COLUMN `order_id` bigint unsigned NOT NULL;

-- STEP 158 [SAFE] column: price
-- Restore the expected column definition
-- Requires order_items.price.not_null = 0; snapshot result: 0
-- Requires order_items.price.valid_decimal = 0; snapshot result: 0
-- ALTER TABLE `order_items` MODIFY COLUMN `price` decimal(8,2) NOT NULL DEFAULT '0.00';

-- STEP 159 [SAFE] column: product_id
-- Restore the expected column definition
-- Requires order_items.product_id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `order_items` MODIFY COLUMN `product_id` bigint unsigned NULL DEFAULT NULL;

-- STEP 160 [SAFE] column: quantity
-- Restore the expected column definition
-- Requires order_items.quantity.not_null = 0; snapshot result: 0
-- Requires order_items.quantity.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `order_items` MODIFY COLUMN `quantity` int NOT NULL DEFAULT '1';

-- STEP 161 [SAFE] column: title
-- Restore the expected column definition
-- Requires order_items.title.max_length = 0; snapshot result: 0
-- ALTER TABLE `order_items` MODIFY COLUMN `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- STEP 162 [SAFE] column: updated_at
-- Restore the expected column definition
-- Requires order_items.updated_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `order_items` MODIFY COLUMN `updated_at` timestamp NULL DEFAULT NULL;

-- ------------------------------------------------------------
-- TABLE orders
-- ------------------------------------------------------------

-- STEP 163 [SAFE] column: created_at
-- Restore the expected column definition
-- Requires orders.created_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `orders` MODIFY COLUMN `created_at` timestamp NULL DEFAULT NULL;

-- STEP 164 [SAFE] column: currency
-- Restore the expected column definition
-- Requires orders.currency.not_null = 0; snapshot result: 0
-- Requires orders.currency.max_length = 0; snapshot result: 0
-- ALTER TABLE `orders` MODIFY COLUMN `currency` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'UAH';

-- STEP 165 [SAFE] column: email
-- Restore the expected column definition
-- Requires orders.email.max_length = 0; snapshot result: 0
-- ALTER TABLE `orders` MODIFY COLUMN `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- STEP 166 [SAFE] column: fname
-- Restore the expected column definition
-- Requires orders.fname.max_length = 0; snapshot result: 0
-- ALTER TABLE `orders` MODIFY COLUMN `fname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- STEP 167 [SAFE] column: id
-- Normalize the ID column before adding its primary key
-- Requires orders.id.not_null = 0; snapshot result: 0
-- Requires orders.id.auto_increment_values = 0; snapshot result: 0
-- Requires orders.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires orders.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `orders` MODIFY COLUMN `id` bigint unsigned NOT NULL;

-- STEP 168 [SAFE] column: lname
-- Restore the expected column definition
-- Requires orders.lname.max_length = 0; snapshot result: 0
-- ALTER TABLE `orders` MODIFY COLUMN `lname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- STEP 169 [SAFE] column: order_number
-- Restore the expected column definition
-- Requires orders.order_number.not_null = 0; snapshot result: 0
-- Requires orders.order_number.max_length = 0; snapshot result: 0
-- ALTER TABLE `orders` MODIFY COLUMN `order_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- STEP 170 [REVIEW] column: phone
-- Restore the expected column definition
-- Requires orders.phone.max_length = 0; snapshot result: 0
-- Requires orders.phone.numeric_to_text_review = 0; snapshot result: manual review
-- ALTER TABLE `orders` MODIFY COLUMN `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- STEP 171 [SAFE] column: products_total
-- Restore the expected column definition
-- Requires orders.products_total.not_null = 0; snapshot result: 0
-- Requires orders.products_total.valid_decimal = 0; snapshot result: 0
-- ALTER TABLE `orders` MODIFY COLUMN `products_total` decimal(14,2) NOT NULL DEFAULT '0.00';

-- STEP 172 [SAFE] column: status
-- Restore the expected column definition
-- Requires orders.status.not_null = 0; snapshot result: 0
-- Requires orders.status.max_length = 0; snapshot result: 0
-- ALTER TABLE `orders` MODIFY COLUMN `status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending' COMMENT 'pending, paid, cancelled, refunded';

-- STEP 173 [SAFE] column: total
-- Restore the expected column definition
-- Requires orders.total.not_null = 0; snapshot result: 0
-- Requires orders.total.valid_decimal = 0; snapshot result: 0
-- ALTER TABLE `orders` MODIFY COLUMN `total` decimal(14,2) NOT NULL DEFAULT '0.00';

-- STEP 174 [SAFE] column: total_items
-- Restore the expected column definition
-- Requires orders.total_items.not_null = 0; snapshot result: 0
-- Requires orders.total_items.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `orders` MODIFY COLUMN `total_items` int NOT NULL DEFAULT '0';

-- STEP 175 [SAFE] column: updated_at
-- Restore the expected column definition
-- Requires orders.updated_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `orders` MODIFY COLUMN `updated_at` timestamp NULL DEFAULT NULL;

-- ------------------------------------------------------------
-- TABLE password_reset_tokens
-- ------------------------------------------------------------

-- STEP 176 [SAFE] column: created_at
-- Restore the expected column definition
-- Requires password_reset_tokens.created_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `password_reset_tokens` MODIFY COLUMN `created_at` timestamp NULL DEFAULT NULL;

-- STEP 177 [SAFE] column: email
-- Restore the expected column definition
-- Requires password_reset_tokens.email.not_null = 0; snapshot result: 0
-- Requires password_reset_tokens.email.max_length = 0; snapshot result: 0
-- ALTER TABLE `password_reset_tokens` MODIFY COLUMN `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- STEP 178 [SAFE] column: token
-- Restore the expected column definition
-- Requires password_reset_tokens.token.not_null = 0; snapshot result: 0
-- Requires password_reset_tokens.token.max_length = 0; snapshot result: 0
-- ALTER TABLE `password_reset_tokens` MODIFY COLUMN `token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- ------------------------------------------------------------
-- TABLE personal_access_tokens
-- ------------------------------------------------------------

-- STEP 179 [SAFE] column: abilities
-- Restore the expected column definition
-- ALTER TABLE `personal_access_tokens` MODIFY COLUMN `abilities` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- STEP 180 [SAFE] column: created_at
-- Restore the expected column definition
-- Requires personal_access_tokens.created_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `personal_access_tokens` MODIFY COLUMN `created_at` timestamp NULL DEFAULT NULL;

-- STEP 181 [SAFE] column: expires_at
-- Restore the expected column definition
-- Requires personal_access_tokens.expires_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `personal_access_tokens` MODIFY COLUMN `expires_at` timestamp NULL DEFAULT NULL;

-- STEP 182 [SAFE] column: id
-- Normalize the ID column before adding its primary key
-- Requires personal_access_tokens.id.not_null = 0; snapshot result: 0
-- Requires personal_access_tokens.id.auto_increment_values = 0; snapshot result: 0
-- Requires personal_access_tokens.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires personal_access_tokens.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `personal_access_tokens` MODIFY COLUMN `id` bigint unsigned NOT NULL;

-- STEP 183 [SAFE] column: last_used_at
-- Restore the expected column definition
-- Requires personal_access_tokens.last_used_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `personal_access_tokens` MODIFY COLUMN `last_used_at` timestamp NULL DEFAULT NULL;

-- STEP 184 [SAFE] column: name
-- Restore the expected column definition
-- Requires personal_access_tokens.name.not_null = 0; snapshot result: 0
-- Requires personal_access_tokens.name.max_length = 0; snapshot result: 0
-- ALTER TABLE `personal_access_tokens` MODIFY COLUMN `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- STEP 185 [SAFE] column: token
-- Restore the expected column definition
-- Requires personal_access_tokens.token.not_null = 0; snapshot result: 0
-- Requires personal_access_tokens.token.max_length = 0; snapshot result: 0
-- ALTER TABLE `personal_access_tokens` MODIFY COLUMN `token` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- STEP 186 [SAFE] column: tokenable_id
-- Restore the expected column definition
-- Requires personal_access_tokens.tokenable_id.not_null = 0; snapshot result: 0
-- Requires personal_access_tokens.tokenable_id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `personal_access_tokens` MODIFY COLUMN `tokenable_id` bigint unsigned NOT NULL;

-- STEP 187 [SAFE] column: tokenable_type
-- Restore the expected column definition
-- Requires personal_access_tokens.tokenable_type.not_null = 0; snapshot result: 0
-- Requires personal_access_tokens.tokenable_type.max_length = 0; snapshot result: 0
-- ALTER TABLE `personal_access_tokens` MODIFY COLUMN `tokenable_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- STEP 188 [SAFE] column: updated_at
-- Restore the expected column definition
-- Requires personal_access_tokens.updated_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `personal_access_tokens` MODIFY COLUMN `updated_at` timestamp NULL DEFAULT NULL;

-- ------------------------------------------------------------
-- TABLE product_brands
-- ------------------------------------------------------------

-- STEP 189 [SAFE] column: created_at
-- Restore the expected column definition
-- Requires product_brands.created_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `product_brands` MODIFY COLUMN `created_at` timestamp NULL DEFAULT NULL;

-- STEP 190 [SAFE] column: id
-- Normalize the ID column before adding its primary key
-- Requires product_brands.id.not_null = 0; snapshot result: 0
-- Requires product_brands.id.auto_increment_values = 0; snapshot result: 0
-- Requires product_brands.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires product_brands.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `product_brands` MODIFY COLUMN `id` bigint unsigned NOT NULL;

-- STEP 191 [SAFE] column: is_active
-- Restore the expected column definition
-- Requires product_brands.is_active.not_null = 0; snapshot result: 0
-- Requires product_brands.is_active.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `product_brands` MODIFY COLUMN `is_active` tinyint(1) NOT NULL DEFAULT '1';

-- STEP 192 [SAFE] column: is_show_nav
-- Restore the expected column definition
-- Requires product_brands.is_show_nav.not_null = 0; snapshot result: 0
-- Requires product_brands.is_show_nav.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `product_brands` MODIFY COLUMN `is_show_nav` tinyint(1) NOT NULL DEFAULT '1';

-- STEP 193 [SAFE] column: name
-- Restore the expected column definition
-- Requires product_brands.name.not_null = 0; snapshot result: 0
-- Requires product_brands.name.max_length = 0; snapshot result: 0
-- ALTER TABLE `product_brands` MODIFY COLUMN `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- STEP 194 [SAFE] column: order
-- Restore the expected column definition
-- Requires product_brands.order.not_null = 0; snapshot result: 0
-- Requires product_brands.order.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `product_brands` MODIFY COLUMN `order` bigint unsigned NOT NULL DEFAULT '0';

-- STEP 195 [SAFE] column: seo_text
-- Restore the expected column definition
-- Requires product_brands.seo_text.valid_json = 0; snapshot result: 0
-- ALTER TABLE `product_brands` MODIFY COLUMN `seo_text` json NULL DEFAULT NULL;

-- STEP 196 [SAFE] column: slug
-- Restore the expected column definition
-- Requires product_brands.slug.not_null = 0; snapshot result: 0
-- Requires product_brands.slug.max_length = 0; snapshot result: 0
-- ALTER TABLE `product_brands` MODIFY COLUMN `slug` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- STEP 197 [SAFE] column: updated_at
-- Restore the expected column definition
-- Requires product_brands.updated_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `product_brands` MODIFY COLUMN `updated_at` timestamp NULL DEFAULT NULL;

-- ------------------------------------------------------------
-- TABLE product_categories
-- ------------------------------------------------------------

-- STEP 198 [SAFE] column: created_at
-- Restore the expected column definition
-- Requires product_categories.created_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `product_categories` MODIFY COLUMN `created_at` timestamp NULL DEFAULT NULL;

-- STEP 199 [SAFE] column: id
-- Normalize the ID column before adding its primary key
-- Requires product_categories.id.not_null = 0; snapshot result: 0
-- Requires product_categories.id.auto_increment_values = 0; snapshot result: 0
-- Requires product_categories.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires product_categories.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `product_categories` MODIFY COLUMN `id` bigint unsigned NOT NULL;

-- STEP 200 [SAFE] column: is_active
-- Restore the expected column definition
-- Requires product_categories.is_active.not_null = 0; snapshot result: 0
-- Requires product_categories.is_active.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `product_categories` MODIFY COLUMN `is_active` tinyint(1) NOT NULL DEFAULT '1';

-- STEP 201 [SAFE] column: is_show_nav
-- Restore the expected column definition
-- Requires product_categories.is_show_nav.not_null = 0; snapshot result: 0
-- Requires product_categories.is_show_nav.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `product_categories` MODIFY COLUMN `is_show_nav` tinyint(1) NOT NULL DEFAULT '1';

-- STEP 202 [SAFE] column: name
-- Restore the expected column definition
-- Requires product_categories.name.not_null = 0; snapshot result: 0
-- Requires product_categories.name.valid_json = 0; snapshot result: 0
-- ALTER TABLE `product_categories` MODIFY COLUMN `name` json NOT NULL;

-- STEP 203 [SAFE] column: order
-- Restore the expected column definition
-- Requires product_categories.order.not_null = 0; snapshot result: 0
-- Requires product_categories.order.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `product_categories` MODIFY COLUMN `order` bigint unsigned NOT NULL DEFAULT '0';

-- STEP 204 [SAFE] column: seo_text
-- Restore the expected column definition
-- Requires product_categories.seo_text.valid_json = 0; snapshot result: 0
-- ALTER TABLE `product_categories` MODIFY COLUMN `seo_text` json NULL DEFAULT NULL;

-- STEP 205 [SAFE] column: slug
-- Restore the expected column definition
-- Requires product_categories.slug.max_length = 0; snapshot result: 0
-- ALTER TABLE `product_categories` MODIFY COLUMN `slug` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- STEP 206 [SAFE] column: updated_at
-- Restore the expected column definition
-- Requires product_categories.updated_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `product_categories` MODIFY COLUMN `updated_at` timestamp NULL DEFAULT NULL;

-- ------------------------------------------------------------
-- TABLE product_ingredients
-- ------------------------------------------------------------

-- STEP 207 [SAFE] column: created_at
-- Restore the expected column definition
-- Requires product_ingredients.created_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `product_ingredients` MODIFY COLUMN `created_at` timestamp NULL DEFAULT NULL;

-- STEP 208 [SAFE] column: id
-- Normalize the ID column before adding its primary key
-- Requires product_ingredients.id.not_null = 0; snapshot result: 0
-- Requires product_ingredients.id.auto_increment_values = 0; snapshot result: 0
-- Requires product_ingredients.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires product_ingredients.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `product_ingredients` MODIFY COLUMN `id` bigint unsigned NOT NULL;

-- STEP 209 [SAFE] column: ingredient_id
-- Restore the expected column definition
-- Requires product_ingredients.ingredient_id.not_null = 0; snapshot result: 0
-- Requires product_ingredients.ingredient_id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `product_ingredients` MODIFY COLUMN `ingredient_id` bigint unsigned NOT NULL;

-- STEP 210 [SAFE] column: order
-- Restore the expected column definition
-- Requires product_ingredients.order.not_null = 0; snapshot result: 0
-- Requires product_ingredients.order.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `product_ingredients` MODIFY COLUMN `order` bigint unsigned NOT NULL DEFAULT '0';

-- STEP 211 [SAFE] column: product_id
-- Restore the expected column definition
-- Requires product_ingredients.product_id.not_null = 0; snapshot result: 0
-- Requires product_ingredients.product_id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `product_ingredients` MODIFY COLUMN `product_id` bigint unsigned NOT NULL;

-- STEP 212 [SAFE] column: updated_at
-- Restore the expected column definition
-- Requires product_ingredients.updated_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `product_ingredients` MODIFY COLUMN `updated_at` timestamp NULL DEFAULT NULL;

-- ------------------------------------------------------------
-- TABLE product_variants
-- ------------------------------------------------------------

-- STEP 213 [SAFE] column: created_at
-- Restore the expected column definition
-- Requires product_variants.created_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `product_variants` MODIFY COLUMN `created_at` timestamp NULL DEFAULT NULL;

-- STEP 214 [SAFE] column: id
-- Normalize the ID column before adding its primary key
-- Requires product_variants.id.not_null = 0; snapshot result: 0
-- Requires product_variants.id.auto_increment_values = 0; snapshot result: 0
-- Requires product_variants.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires product_variants.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `product_variants` MODIFY COLUMN `id` bigint unsigned NOT NULL;

-- STEP 215 [SAFE] column: order
-- Restore the expected column definition
-- Requires product_variants.order.not_null = 0; snapshot result: 0
-- Requires product_variants.order.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `product_variants` MODIFY COLUMN `order` bigint unsigned NOT NULL DEFAULT '0';

-- STEP 216 [SAFE] column: product_id
-- Restore the expected column definition
-- Requires product_variants.product_id.not_null = 0; snapshot result: 0
-- Requires product_variants.product_id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `product_variants` MODIFY COLUMN `product_id` bigint unsigned NOT NULL;

-- STEP 217 [SAFE] column: updated_at
-- Restore the expected column definition
-- Requires product_variants.updated_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `product_variants` MODIFY COLUMN `updated_at` timestamp NULL DEFAULT NULL;

-- STEP 218 [SAFE] column: variant_id
-- Restore the expected column definition
-- Requires product_variants.variant_id.not_null = 0; snapshot result: 0
-- Requires product_variants.variant_id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `product_variants` MODIFY COLUMN `variant_id` bigint unsigned NOT NULL;

-- ------------------------------------------------------------
-- TABLE products
-- ------------------------------------------------------------

-- STEP 219 [SAFE] column: article
-- Restore the expected column definition
-- Requires products.article.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `products` MODIFY COLUMN `article` bigint unsigned NULL DEFAULT NULL;

-- STEP 220 [SAFE] column: code
-- Restore the expected column definition
-- Requires products.code.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `products` MODIFY COLUMN `code` bigint unsigned NULL DEFAULT NULL;

-- STEP 221 [SAFE] column: created_at
-- Restore the expected column definition
-- Requires products.created_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `products` MODIFY COLUMN `created_at` timestamp NULL DEFAULT NULL;

-- STEP 222 [SAFE] column: description
-- Restore the expected column definition
-- Requires products.description.valid_json = 0; snapshot result: 0
-- ALTER TABLE `products` MODIFY COLUMN `description` json NULL DEFAULT NULL;

-- STEP 223 [SAFE] column: id
-- Normalize the ID column before adding its primary key
-- Requires products.id.not_null = 0; snapshot result: 0
-- Requires products.id.auto_increment_values = 0; snapshot result: 0
-- Requires products.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires products.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `products` MODIFY COLUMN `id` bigint unsigned NOT NULL;

-- STEP 224 [SAFE] column: is_active
-- Restore the expected column definition
-- Requires products.is_active.not_null = 0; snapshot result: 0
-- Requires products.is_active.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `products` MODIFY COLUMN `is_active` tinyint(1) NOT NULL DEFAULT '1';

-- STEP 225 [SAFE] column: name
-- Restore the expected column definition
-- Requires products.name.valid_json = 0; snapshot result: 0
-- ALTER TABLE `products` MODIFY COLUMN `name` json NULL DEFAULT NULL;

-- STEP 226 [SAFE] column: order
-- Restore the expected column definition
-- Requires products.order.not_null = 0; snapshot result: 0
-- Requires products.order.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `products` MODIFY COLUMN `order` bigint unsigned NOT NULL DEFAULT '0';

-- STEP 227 [SAFE] column: position
-- Restore the expected column definition
-- Requires products.position.max_length = 0; snapshot result: 0
-- ALTER TABLE `products` MODIFY COLUMN `position` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '2x2, 2x1,1x2';

-- STEP 228 [SAFE] column: price_eu
-- Restore the expected column definition
-- Requires products.price_eu.valid_decimal = 0; snapshot result: 0
-- ALTER TABLE `products` MODIFY COLUMN `price_eu` decimal(8,2) NULL DEFAULT NULL;

-- STEP 229 [SAFE] column: price_ua
-- Restore the expected column definition
-- Requires products.price_ua.valid_decimal = 0; snapshot result: 0
-- ALTER TABLE `products` MODIFY COLUMN `price_ua` decimal(8,2) NULL DEFAULT NULL;

-- STEP 230 [SAFE] column: product_brand_id
-- Restore the expected column definition
-- Requires products.product_brand_id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `products` MODIFY COLUMN `product_brand_id` bigint unsigned NULL DEFAULT NULL;

-- STEP 231 [SAFE] column: product_category_id
-- Restore the expected column definition
-- Requires products.product_category_id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `products` MODIFY COLUMN `product_category_id` bigint unsigned NULL DEFAULT NULL;

-- STEP 232 [SAFE] column: short_description
-- Restore the expected column definition
-- Requires products.short_description.valid_json = 0; snapshot result: 0
-- ALTER TABLE `products` MODIFY COLUMN `short_description` json NULL DEFAULT NULL;

-- STEP 233 [SAFE] column: slug
-- Restore the expected column definition
-- Requires products.slug.max_length = 0; snapshot result: 0
-- ALTER TABLE `products` MODIFY COLUMN `slug` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- STEP 234 [SAFE] column: subtitle
-- Restore the expected column definition
-- Requires products.subtitle.valid_json = 0; snapshot result: 0
-- ALTER TABLE `products` MODIFY COLUMN `subtitle` json NULL DEFAULT NULL;

-- STEP 235 [SAFE] column: updated_at
-- Restore the expected column definition
-- Requires products.updated_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `products` MODIFY COLUMN `updated_at` timestamp NULL DEFAULT NULL;

-- STEP 236 [SAFE] column: volume
-- Restore the expected column definition
-- Requires products.volume.max_length = 0; snapshot result: 0
-- ALTER TABLE `products` MODIFY COLUMN `volume` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- ------------------------------------------------------------
-- TABLE promo_banners
-- ------------------------------------------------------------

-- STEP 237 [SAFE] column: content
-- Restore the expected column definition
-- Requires promo_banners.content.not_null = 0; snapshot result: 0
-- Requires promo_banners.content.valid_json = 0; snapshot result: 0
-- ALTER TABLE `promo_banners` MODIFY COLUMN `content` json NOT NULL;

-- STEP 238 [SAFE] column: created_at
-- Restore the expected column definition
-- Requires promo_banners.created_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `promo_banners` MODIFY COLUMN `created_at` timestamp NULL DEFAULT NULL;

-- STEP 239 [SAFE] column: id
-- Restore the expected column definition
-- Requires promo_banners.id.not_null = 0; snapshot result: 0
-- Requires promo_banners.id.auto_increment_values = 0; snapshot result: 0
-- Requires promo_banners.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires promo_banners.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `promo_banners` MODIFY COLUMN `id` bigint unsigned NOT NULL auto_increment;

-- STEP 240 [SAFE] column: is_active
-- Restore the expected column definition
-- Requires promo_banners.is_active.not_null = 0; snapshot result: 0
-- Requires promo_banners.is_active.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `promo_banners` MODIFY COLUMN `is_active` tinyint(1) NOT NULL DEFAULT '0';

-- STEP 241 [REVIEW] column: link
-- Restore the expected column definition
-- Requires promo_banners.link.max_length = 0; snapshot result: 0
-- Requires promo_banners.link.character_set_review = 0; snapshot result: manual review
-- ALTER TABLE `promo_banners` MODIFY COLUMN `link` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- STEP 242 [SAFE] column: updated_at
-- Restore the expected column definition
-- Requires promo_banners.updated_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `promo_banners` MODIFY COLUMN `updated_at` timestamp NULL DEFAULT NULL;

-- ------------------------------------------------------------
-- TABLE regions
-- ------------------------------------------------------------

-- STEP 243 [SAFE] column: code
-- Restore the expected column definition
-- Requires regions.code.not_null = 0; snapshot result: 0
-- Requires regions.code.max_length = 0; snapshot result: 0
-- ALTER TABLE `regions` MODIFY COLUMN `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- STEP 244 [SAFE] column: created_at
-- Restore the expected column definition
-- Requires regions.created_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `regions` MODIFY COLUMN `created_at` timestamp NULL DEFAULT NULL;

-- STEP 245 [SAFE] column: currency_code
-- Restore the expected column definition
-- Requires regions.currency_code.not_null = 0; snapshot result: 0
-- Requires regions.currency_code.max_length = 0; snapshot result: 0
-- ALTER TABLE `regions` MODIFY COLUMN `currency_code` varchar(6) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- STEP 246 [SAFE] column: id
-- Normalize the ID column before adding its primary key
-- Requires regions.id.not_null = 0; snapshot result: 0
-- Requires regions.id.auto_increment_values = 0; snapshot result: 0
-- Requires regions.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires regions.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `regions` MODIFY COLUMN `id` bigint unsigned NOT NULL;

-- STEP 247 [SAFE] column: name
-- Restore the expected column definition
-- Requires regions.name.not_null = 0; snapshot result: 0
-- Requires regions.name.max_length = 0; snapshot result: 0
-- ALTER TABLE `regions` MODIFY COLUMN `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- STEP 248 [SAFE] column: updated_at
-- Restore the expected column definition
-- Requires regions.updated_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `regions` MODIFY COLUMN `updated_at` timestamp NULL DEFAULT NULL;

-- ------------------------------------------------------------
-- TABLE service_categories
-- ------------------------------------------------------------

-- STEP 249 [SAFE] column: category_id
-- Restore the expected column definition
-- Requires service_categories.category_id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `service_categories` MODIFY COLUMN `category_id` bigint unsigned NULL DEFAULT NULL;

-- STEP 250 [SAFE] column: created_at
-- Restore the expected column definition
-- Requires service_categories.created_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `service_categories` MODIFY COLUMN `created_at` timestamp NULL DEFAULT NULL;

-- STEP 251 [SAFE] column: id
-- Normalize the ID column before adding its primary key
-- Requires service_categories.id.not_null = 0; snapshot result: 0
-- Requires service_categories.id.auto_increment_values = 0; snapshot result: 0
-- Requires service_categories.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires service_categories.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `service_categories` MODIFY COLUMN `id` bigint unsigned NOT NULL;

-- STEP 252 [SAFE] column: order
-- Restore the expected column definition
-- Requires service_categories.order.not_null = 0; snapshot result: 0
-- Requires service_categories.order.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `service_categories` MODIFY COLUMN `order` int NOT NULL DEFAULT '0';

-- STEP 253 [SAFE] column: service_id
-- Restore the expected column definition
-- Requires service_categories.service_id.not_null = 0; snapshot result: 0
-- Requires service_categories.service_id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `service_categories` MODIFY COLUMN `service_id` bigint unsigned NOT NULL;

-- STEP 254 [SAFE] column: updated_at
-- Restore the expected column definition
-- Requires service_categories.updated_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `service_categories` MODIFY COLUMN `updated_at` timestamp NULL DEFAULT NULL;

-- ------------------------------------------------------------
-- TABLE service_variant_prices
-- ------------------------------------------------------------

-- STEP 255 [SAFE] column: created_at
-- Restore the expected column definition
-- Requires service_variant_prices.created_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `service_variant_prices` MODIFY COLUMN `created_at` timestamp NULL DEFAULT NULL;

-- STEP 256 [SAFE] column: currency_code
-- Restore the expected column definition
-- Requires service_variant_prices.currency_code.max_length = 0; snapshot result: 0
-- ALTER TABLE `service_variant_prices` MODIFY COLUMN `currency_code` varchar(6) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- STEP 257 [SAFE] column: id
-- Normalize the ID column before adding its primary key
-- Requires service_variant_prices.id.not_null = 0; snapshot result: 0
-- Requires service_variant_prices.id.auto_increment_values = 0; snapshot result: 0
-- Requires service_variant_prices.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires service_variant_prices.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `service_variant_prices` MODIFY COLUMN `id` bigint unsigned NOT NULL;

-- STEP 258 [SAFE] column: name
-- Restore the expected column definition
-- Requires service_variant_prices.name.valid_json = 0; snapshot result: 0
-- ALTER TABLE `service_variant_prices` MODIFY COLUMN `name` json NULL DEFAULT NULL;

-- STEP 259 [SAFE] column: order
-- Restore the expected column definition
-- Requires service_variant_prices.order.not_null = 0; snapshot result: 0
-- Requires service_variant_prices.order.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `service_variant_prices` MODIFY COLUMN `order` int NOT NULL DEFAULT '0';

-- STEP 260 [SAFE] column: price
-- Restore the expected column definition
-- Requires service_variant_prices.price.not_null = 0; snapshot result: 0
-- Requires service_variant_prices.price.valid_decimal = 0; snapshot result: 0
-- ALTER TABLE `service_variant_prices` MODIFY COLUMN `price` decimal(10,2) NOT NULL;

-- STEP 261 [SAFE] column: updated_at
-- Restore the expected column definition
-- Requires service_variant_prices.updated_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `service_variant_prices` MODIFY COLUMN `updated_at` timestamp NULL DEFAULT NULL;

-- STEP 262 [SAFE] column: variant_id
-- Restore the expected column definition
-- Requires service_variant_prices.variant_id.not_null = 0; snapshot result: 0
-- Requires service_variant_prices.variant_id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `service_variant_prices` MODIFY COLUMN `variant_id` bigint unsigned NOT NULL;

-- ------------------------------------------------------------
-- TABLE service_variants
-- ------------------------------------------------------------

-- STEP 263 [SAFE] column: code
-- Restore the expected column definition
-- Requires service_variants.code.max_length = 0; snapshot result: 0
-- ALTER TABLE `service_variants` MODIFY COLUMN `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- STEP 264 [SAFE] column: created_at
-- Restore the expected column definition
-- Requires service_variants.created_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `service_variants` MODIFY COLUMN `created_at` timestamp NULL DEFAULT NULL;

-- STEP 265 [SAFE] column: description
-- Restore the expected column definition
-- Requires service_variants.description.valid_json = 0; snapshot result: 0
-- ALTER TABLE `service_variants` MODIFY COLUMN `description` json NULL DEFAULT NULL;

-- STEP 266 [SAFE] column: id
-- Normalize the ID column before adding its primary key
-- Requires service_variants.id.not_null = 0; snapshot result: 0
-- Requires service_variants.id.auto_increment_values = 0; snapshot result: 0
-- Requires service_variants.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires service_variants.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `service_variants` MODIFY COLUMN `id` bigint unsigned NOT NULL;

-- STEP 267 [SAFE] column: order
-- Restore the expected column definition
-- Requires service_variants.order.not_null = 0; snapshot result: 0
-- Requires service_variants.order.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `service_variants` MODIFY COLUMN `order` int NOT NULL DEFAULT '0';

-- STEP 268 [SAFE] column: service_id
-- Restore the expected column definition
-- Requires service_variants.service_id.not_null = 0; snapshot result: 0
-- Requires service_variants.service_id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `service_variants` MODIFY COLUMN `service_id` bigint unsigned NOT NULL;

-- STEP 269 [SAFE] column: title
-- Restore the expected column definition
-- Requires service_variants.title.not_null = 0; snapshot result: 0
-- Requires service_variants.title.valid_json = 0; snapshot result: 0
-- ALTER TABLE `service_variants` MODIFY COLUMN `title` json NOT NULL;

-- STEP 270 [SAFE] column: updated_at
-- Restore the expected column definition
-- Requires service_variants.updated_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `service_variants` MODIFY COLUMN `updated_at` timestamp NULL DEFAULT NULL;

-- ------------------------------------------------------------
-- TABLE services
-- ------------------------------------------------------------

-- STEP 271 [SAFE] column: code
-- Restore the expected column definition
-- Requires services.code.max_length = 0; snapshot result: 0
-- ALTER TABLE `services` MODIFY COLUMN `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- STEP 272 [SAFE] column: created_at
-- Restore the expected column definition
-- Requires services.created_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `services` MODIFY COLUMN `created_at` timestamp NULL DEFAULT NULL;

-- STEP 273 [SAFE] column: description
-- Restore the expected column definition
-- Requires services.description.valid_json = 0; snapshot result: 0
-- ALTER TABLE `services` MODIFY COLUMN `description` json NULL DEFAULT NULL;

-- STEP 274 [SAFE] column: id
-- Normalize the ID column before adding its primary key
-- Requires services.id.not_null = 0; snapshot result: 0
-- Requires services.id.auto_increment_values = 0; snapshot result: 0
-- Requires services.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires services.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `services` MODIFY COLUMN `id` bigint unsigned NOT NULL;

-- STEP 275 [SAFE] column: order
-- Restore the expected column definition
-- Requires services.order.not_null = 0; snapshot result: 0
-- Requires services.order.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `services` MODIFY COLUMN `order` bigint NOT NULL DEFAULT '0';

-- STEP 276 [SAFE] column: region_id
-- Restore the expected column definition
-- Requires services.region_id.not_null = 0; snapshot result: 0
-- Requires services.region_id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `services` MODIFY COLUMN `region_id` bigint unsigned NOT NULL;

-- STEP 277 [SAFE] column: title
-- Restore the expected column definition
-- Requires services.title.not_null = 0; snapshot result: 0
-- Requires services.title.valid_json = 0; snapshot result: 0
-- ALTER TABLE `services` MODIFY COLUMN `title` json NOT NULL;

-- STEP 278 [SAFE] column: updated_at
-- Restore the expected column definition
-- Requires services.updated_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `services` MODIFY COLUMN `updated_at` timestamp NULL DEFAULT NULL;

-- ------------------------------------------------------------
-- TABLE site_settings
-- ------------------------------------------------------------

-- STEP 279 [SAFE] column: created_at
-- Restore the expected column definition
-- Requires site_settings.created_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `site_settings` MODIFY COLUMN `created_at` timestamp NULL DEFAULT NULL;

-- STEP 280 [SAFE] column: id
-- Normalize the ID column before adding its primary key
-- Requires site_settings.id.not_null = 0; snapshot result: 0
-- Requires site_settings.id.auto_increment_values = 0; snapshot result: 0
-- Requires site_settings.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires site_settings.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `site_settings` MODIFY COLUMN `id` bigint unsigned NOT NULL;

-- STEP 281 [SAFE] column: key
-- Restore the expected column definition
-- Requires site_settings.key.not_null = 0; snapshot result: 0
-- Requires site_settings.key.max_length = 0; snapshot result: 0
-- ALTER TABLE `site_settings` MODIFY COLUMN `key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- STEP 282 [SAFE] column: updated_at
-- Restore the expected column definition
-- Requires site_settings.updated_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `site_settings` MODIFY COLUMN `updated_at` timestamp NULL DEFAULT NULL;

-- STEP 283 [SAFE] column: value
-- Restore the expected column definition
-- Requires site_settings.value.not_null = 0; snapshot result: 0
-- ALTER TABLE `site_settings` MODIFY COLUMN `value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- ------------------------------------------------------------
-- TABLE social_links
-- ------------------------------------------------------------

-- STEP 284 [SAFE] column: created_at
-- Restore the expected column definition
-- Requires social_links.created_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `social_links` MODIFY COLUMN `created_at` timestamp NULL DEFAULT NULL;

-- STEP 285 [SAFE] column: icon
-- Restore the expected column definition
-- Requires social_links.icon.max_length = 0; snapshot result: 0
-- ALTER TABLE `social_links` MODIFY COLUMN `icon` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- STEP 286 [SAFE] column: id
-- Normalize the ID column before adding its primary key
-- Requires social_links.id.not_null = 0; snapshot result: 0
-- Requires social_links.id.auto_increment_values = 0; snapshot result: 0
-- Requires social_links.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires social_links.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `social_links` MODIFY COLUMN `id` bigint unsigned NOT NULL;

-- STEP 287 [SAFE] column: order
-- Restore the expected column definition
-- Requires social_links.order.not_null = 0; snapshot result: 0
-- Requires social_links.order.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `social_links` MODIFY COLUMN `order` bigint NOT NULL DEFAULT '0';

-- STEP 288 [SAFE] column: platform
-- Restore the expected column definition
-- Requires social_links.platform.not_null = 0; snapshot result: 0
-- Requires social_links.platform.max_length = 0; snapshot result: 0
-- ALTER TABLE `social_links` MODIFY COLUMN `platform` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- STEP 289 [SAFE] column: region_id
-- Restore the expected column definition
-- Requires social_links.region_id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `social_links` MODIFY COLUMN `region_id` bigint unsigned NULL DEFAULT NULL;

-- STEP 290 [SAFE] column: updated_at
-- Restore the expected column definition
-- Requires social_links.updated_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `social_links` MODIFY COLUMN `updated_at` timestamp NULL DEFAULT NULL;

-- STEP 291 [SAFE] column: url
-- Restore the expected column definition
-- Requires social_links.url.not_null = 0; snapshot result: 0
-- Requires social_links.url.max_length = 0; snapshot result: 0
-- ALTER TABLE `social_links` MODIFY COLUMN `url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- ------------------------------------------------------------
-- TABLE special_offers
-- ------------------------------------------------------------

-- STEP 292 [SAFE] column: about_text
-- Restore the expected column definition
-- Requires special_offers.about_text.valid_json = 0; snapshot result: 0
-- ALTER TABLE `special_offers` MODIFY COLUMN `about_text` json NULL DEFAULT NULL;

-- STEP 293 [SAFE] column: about_title
-- Restore the expected column definition
-- Requires special_offers.about_title.valid_json = 0; snapshot result: 0
-- ALTER TABLE `special_offers` MODIFY COLUMN `about_title` json NULL DEFAULT NULL;

-- STEP 294 [SAFE] column: code
-- Restore the expected column definition
-- Requires special_offers.code.max_length = 0; snapshot result: 0
-- ALTER TABLE `special_offers` MODIFY COLUMN `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- STEP 295 [SAFE] column: created_at
-- Restore the expected column definition
-- Requires special_offers.created_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `special_offers` MODIFY COLUMN `created_at` timestamp NULL DEFAULT NULL;

-- STEP 296 [SAFE] column: description
-- Restore the expected column definition
-- Requires special_offers.description.valid_json = 0; snapshot result: 0
-- ALTER TABLE `special_offers` MODIFY COLUMN `description` json NULL DEFAULT NULL;

-- STEP 297 [SAFE] column: id
-- Normalize the ID column before adding its primary key
-- Requires special_offers.id.not_null = 0; snapshot result: 0
-- Requires special_offers.id.auto_increment_values = 0; snapshot result: 0
-- Requires special_offers.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires special_offers.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `special_offers` MODIFY COLUMN `id` bigint unsigned NOT NULL;

-- STEP 298 [SAFE] column: old_price
-- Restore the expected column definition
-- Requires special_offers.old_price.valid_decimal = 0; snapshot result: 0
-- ALTER TABLE `special_offers` MODIFY COLUMN `old_price` decimal(10,2) NULL DEFAULT NULL;

-- STEP 299 [SAFE] column: order
-- Restore the expected column definition
-- Requires special_offers.order.not_null = 0; snapshot result: 0
-- Requires special_offers.order.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `special_offers` MODIFY COLUMN `order` int NOT NULL DEFAULT '0';

-- STEP 300 [SAFE] column: price
-- Restore the expected column definition
-- Requires special_offers.price.valid_decimal = 0; snapshot result: 0
-- ALTER TABLE `special_offers` MODIFY COLUMN `price` decimal(10,2) NULL DEFAULT NULL;

-- STEP 301 [SAFE] column: region_id
-- Restore the expected column definition
-- Requires special_offers.region_id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `special_offers` MODIFY COLUMN `region_id` bigint unsigned NULL DEFAULT NULL;

-- STEP 302 [SAFE] column: subtitle
-- Restore the expected column definition
-- Requires special_offers.subtitle.valid_json = 0; snapshot result: 0
-- ALTER TABLE `special_offers` MODIFY COLUMN `subtitle` json NULL DEFAULT NULL;

-- STEP 303 [SAFE] column: title
-- Restore the expected column definition
-- Requires special_offers.title.not_null = 0; snapshot result: 0
-- Requires special_offers.title.valid_json = 0; snapshot result: 0
-- ALTER TABLE `special_offers` MODIFY COLUMN `title` json NOT NULL;

-- STEP 304 [SAFE] column: updated_at
-- Restore the expected column definition
-- Requires special_offers.updated_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `special_offers` MODIFY COLUMN `updated_at` timestamp NULL DEFAULT NULL;

-- ------------------------------------------------------------
-- TABLE team_members
-- ------------------------------------------------------------

-- STEP 305 [SAFE] column: created_at
-- Restore the expected column definition
-- Requires team_members.created_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `team_members` MODIFY COLUMN `created_at` timestamp NULL DEFAULT NULL;

-- STEP 306 [SAFE] column: link
-- Restore the expected column definition
-- ALTER TABLE `team_members` MODIFY COLUMN `link` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- STEP 307 [SAFE] column: name
-- Restore the expected column definition
-- Requires team_members.name.not_null = 0; snapshot result: 0
-- Requires team_members.name.max_length = 0; snapshot result: 0
-- ALTER TABLE `team_members` MODIFY COLUMN `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- STEP 308 [SAFE] column: order
-- Restore the expected column definition
-- Requires team_members.order.not_null = 0; snapshot result: 0
-- Requires team_members.order.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `team_members` MODIFY COLUMN `order` bigint NOT NULL DEFAULT '0';

-- STEP 309 [SAFE] column: position
-- Restore the expected column definition
-- Requires team_members.position.not_null = 0; snapshot result: 0
-- Requires team_members.position.max_length = 0; snapshot result: 0
-- ALTER TABLE `team_members` MODIFY COLUMN `position` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- STEP 310 [SAFE] column: region_id
-- Restore the expected column definition
-- Requires team_members.region_id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `team_members` MODIFY COLUMN `region_id` bigint unsigned NULL DEFAULT NULL;

-- STEP 311 [SAFE] column: updated_at
-- Restore the expected column definition
-- Requires team_members.updated_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `team_members` MODIFY COLUMN `updated_at` timestamp NULL DEFAULT NULL;

-- ------------------------------------------------------------
-- TABLE users
-- ------------------------------------------------------------

-- STEP 312 [SAFE] column: created_at
-- Restore the expected column definition
-- Requires users.created_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `users` MODIFY COLUMN `created_at` timestamp NULL DEFAULT NULL;

-- STEP 313 [BLOCKED] column: email
-- Restore the expected column definition
-- Requires users.email.not_null = 0; snapshot result: 8
-- Requires users.email.max_length = 0; snapshot result: 0
-- ALTER TABLE `users` MODIFY COLUMN `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- STEP 314 [SAFE] column: email_verified_at
-- Restore the expected column definition
-- Requires users.email_verified_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `users` MODIFY COLUMN `email_verified_at` timestamp NULL DEFAULT NULL;

-- STEP 315 [SAFE] column: id
-- Normalize the ID column before adding its primary key
-- Requires users.id.not_null = 0; snapshot result: 0
-- Requires users.id.auto_increment_values = 0; snapshot result: 0
-- Requires users.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires users.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `users` MODIFY COLUMN `id` bigint unsigned NOT NULL;

-- STEP 316 [BLOCKED] column: is_appointment_dubai
-- Restore the expected column definition
-- Requires users.is_appointment_dubai.not_null = 0; snapshot result: 1
-- Requires users.is_appointment_dubai.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `users` MODIFY COLUMN `is_appointment_dubai` tinyint(1) NOT NULL DEFAULT '0';

-- STEP 317 [BLOCKED] column: is_appointment_ua
-- Restore the expected column definition
-- Requires users.is_appointment_ua.not_null = 0; snapshot result: 1
-- Requires users.is_appointment_ua.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `users` MODIFY COLUMN `is_appointment_ua` tinyint(1) NOT NULL DEFAULT '0';

-- STEP 318 [SAFE] column: name
-- Restore the expected column definition
-- Requires users.name.not_null = 0; snapshot result: 0
-- Requires users.name.max_length = 0; snapshot result: 0
-- ALTER TABLE `users` MODIFY COLUMN `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- STEP 319 [BLOCKED] column: password
-- Restore the expected column definition
-- Requires users.password.not_null = 0; snapshot result: 8
-- Requires users.password.max_length = 0; snapshot result: 0
-- ALTER TABLE `users` MODIFY COLUMN `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- STEP 320 [SAFE] column: remember_token
-- Restore the expected column definition
-- Requires users.remember_token.max_length = 0; snapshot result: 0
-- ALTER TABLE `users` MODIFY COLUMN `remember_token` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- STEP 321 [BLOCKED] column: telegram_id
-- Restore the expected column definition
-- Requires users.telegram_id.not_null = 0; snapshot result: 1
-- Requires users.telegram_id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `users` MODIFY COLUMN `telegram_id` bigint NOT NULL;

-- STEP 322 [SAFE] column: telegram_login
-- Restore the expected column definition
-- Requires users.telegram_login.max_length = 0; snapshot result: 0
-- ALTER TABLE `users` MODIFY COLUMN `telegram_login` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- STEP 323 [SAFE] column: telegram_name
-- Restore the expected column definition
-- Requires users.telegram_name.max_length = 0; snapshot result: 0
-- ALTER TABLE `users` MODIFY COLUMN `telegram_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

-- STEP 324 [SAFE] column: updated_at
-- Restore the expected column definition
-- Requires users.updated_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `users` MODIFY COLUMN `updated_at` timestamp NULL DEFAULT NULL;

-- ------------------------------------------------------------
-- TABLE variants
-- ------------------------------------------------------------

-- STEP 325 [SAFE] column: created_at
-- Restore the expected column definition
-- Requires variants.created_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `variants` MODIFY COLUMN `created_at` timestamp NULL DEFAULT NULL;

-- STEP 326 [SAFE] column: description
-- Restore the expected column definition
-- Requires variants.description.valid_json = 0; snapshot result: 0
-- ALTER TABLE `variants` MODIFY COLUMN `description` json NULL DEFAULT NULL;

-- STEP 327 [SAFE] column: id
-- Normalize the ID column before adding its primary key
-- Requires variants.id.not_null = 0; snapshot result: 0
-- Requires variants.id.auto_increment_values = 0; snapshot result: 0
-- Requires variants.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires variants.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `variants` MODIFY COLUMN `id` bigint unsigned NOT NULL;

-- STEP 328 [SAFE] column: is_active
-- Restore the expected column definition
-- Requires variants.is_active.not_null = 0; snapshot result: 0
-- Requires variants.is_active.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `variants` MODIFY COLUMN `is_active` tinyint(1) NOT NULL DEFAULT '0';

-- STEP 329 [SAFE] column: is_show_nav
-- Restore the expected column definition
-- Requires variants.is_show_nav.not_null = 0; snapshot result: 0
-- Requires variants.is_show_nav.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `variants` MODIFY COLUMN `is_show_nav` tinyint(1) NOT NULL DEFAULT '1';

-- STEP 330 [SAFE] column: name
-- Restore the expected column definition
-- Requires variants.name.valid_json = 0; snapshot result: 0
-- ALTER TABLE `variants` MODIFY COLUMN `name` json NULL DEFAULT NULL;

-- STEP 331 [SAFE] column: order
-- Restore the expected column definition
-- Requires variants.order.not_null = 0; snapshot result: 0
-- Requires variants.order.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `variants` MODIFY COLUMN `order` bigint unsigned NOT NULL DEFAULT '0';

-- STEP 332 [SAFE] column: seo_text
-- Restore the expected column definition
-- Requires variants.seo_text.valid_json = 0; snapshot result: 0
-- ALTER TABLE `variants` MODIFY COLUMN `seo_text` json NULL DEFAULT NULL;

-- STEP 333 [SAFE] column: short_description
-- Restore the expected column definition
-- Requires variants.short_description.valid_json = 0; snapshot result: 0
-- ALTER TABLE `variants` MODIFY COLUMN `short_description` json NULL DEFAULT NULL;

-- STEP 334 [SAFE] column: slug
-- Restore the expected column definition
-- Requires variants.slug.not_null = 0; snapshot result: 0
-- Requires variants.slug.max_length = 0; snapshot result: 0
-- ALTER TABLE `variants` MODIFY COLUMN `slug` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- STEP 335 [SAFE] column: updated_at
-- Restore the expected column definition
-- Requires variants.updated_at.valid_datetime = 0; snapshot result: 0
-- ALTER TABLE `variants` MODIFY COLUMN `updated_at` timestamp NULL DEFAULT NULL;

-- ------------------------------------------------------------
-- TABLE abouts
-- ------------------------------------------------------------

-- STEP 336 [SAFE] index: PRIMARY
-- Restore the primary key
-- Requires abouts.PRIMARY.unique = 0; snapshot result: 0
-- ALTER TABLE `abouts` ADD PRIMARY KEY (`id`);

-- STEP 337 [SAFE] index: abouts_code_unique
-- Restore the expected index
-- Requires abouts.abouts_code_unique.unique = 0; snapshot result: 0
-- ALTER TABLE `abouts` ADD UNIQUE INDEX `abouts_code_unique` (`code`);

-- ------------------------------------------------------------
-- TABLE action_events
-- ------------------------------------------------------------

-- STEP 338 [SAFE] index: PRIMARY
-- Restore the primary key
-- Requires action_events.PRIMARY.unique = 0; snapshot result: 0
-- ALTER TABLE `action_events` ADD PRIMARY KEY (`id`);

-- STEP 339 [SAFE] index: action_events_actionable_type_actionable_id_index
-- Restore the expected index
-- ALTER TABLE `action_events` ADD INDEX `action_events_actionable_type_actionable_id_index` (`actionable_type`, `actionable_id`);

-- STEP 340 [SAFE] index: action_events_batch_id_model_type_model_id_index
-- Restore the expected index
-- ALTER TABLE `action_events` ADD INDEX `action_events_batch_id_model_type_model_id_index` (`batch_id`, `model_type`, `model_id`);

-- STEP 341 [SAFE] index: action_events_target_type_target_id_index
-- Restore the expected index
-- ALTER TABLE `action_events` ADD INDEX `action_events_target_type_target_id_index` (`target_type`, `target_id`);

-- STEP 342 [SAFE] index: action_events_user_id_index
-- Restore the expected index
-- ALTER TABLE `action_events` ADD INDEX `action_events_user_id_index` (`user_id`);

-- ------------------------------------------------------------
-- TABLE appointments
-- ------------------------------------------------------------

-- STEP 343 [SAFE] index: PRIMARY
-- Restore the primary key
-- Requires appointments.PRIMARY.unique = 0; snapshot result: 0
-- ALTER TABLE `appointments` ADD PRIMARY KEY (`id`);

-- ------------------------------------------------------------
-- TABLE banners
-- ------------------------------------------------------------

-- STEP 344 [SAFE] index: PRIMARY
-- Restore the primary key
-- Requires banners.PRIMARY.unique = 0; snapshot result: 0
-- ALTER TABLE `banners` ADD PRIMARY KEY (`id`);

-- ------------------------------------------------------------
-- TABLE call_us
-- ------------------------------------------------------------

-- STEP 345 [SAFE] index: PRIMARY
-- Restore the primary key
-- Requires call_us.PRIMARY.unique = 0; snapshot result: 0
-- ALTER TABLE `call_us` ADD PRIMARY KEY (`id`);

-- ------------------------------------------------------------
-- TABLE categories
-- ------------------------------------------------------------

-- STEP 346 [SAFE] index: PRIMARY
-- Restore the primary key
-- Requires categories.PRIMARY.unique = 0; snapshot result: 0
-- ALTER TABLE `categories` ADD PRIMARY KEY (`id`);

-- ------------------------------------------------------------
-- TABLE contacts
-- ------------------------------------------------------------

-- STEP 347 [SAFE] index: PRIMARY
-- Restore the primary key
-- Requires contacts.PRIMARY.unique = 0; snapshot result: 0
-- ALTER TABLE `contacts` ADD PRIMARY KEY (`id`);

-- ------------------------------------------------------------
-- TABLE devices
-- ------------------------------------------------------------

-- STEP 348 [SAFE] index: PRIMARY
-- Restore the primary key
-- Requires devices.PRIMARY.unique = 0; snapshot result: 0
-- ALTER TABLE `devices` ADD PRIMARY KEY (`id`);

-- STEP 349 [SAFE] index: devices_region_id_foreign
-- Restore the expected index
-- Requires devices.devices_region_id_foreign.orphans = 0; snapshot result: 0
-- ALTER TABLE `devices` ADD INDEX `devices_region_id_foreign` (`region_id`);

-- ------------------------------------------------------------
-- TABLE failed_jobs
-- ------------------------------------------------------------

-- STEP 350 [SAFE] index: PRIMARY
-- Restore the primary key
-- Requires failed_jobs.PRIMARY.unique = 0; snapshot result: 0
-- ALTER TABLE `failed_jobs` ADD PRIMARY KEY (`id`);

-- STEP 351 [SAFE] index: failed_jobs_uuid_unique
-- Restore the expected index
-- Requires failed_jobs.failed_jobs_uuid_unique.unique = 0; snapshot result: 0
-- ALTER TABLE `failed_jobs` ADD UNIQUE INDEX `failed_jobs_uuid_unique` (`uuid`);

-- ------------------------------------------------------------
-- TABLE galleries
-- ------------------------------------------------------------

-- STEP 352 [SAFE] index: PRIMARY
-- Restore the primary key
-- Requires galleries.PRIMARY.unique = 0; snapshot result: 0
-- ALTER TABLE `galleries` ADD PRIMARY KEY (`id`);

-- STEP 353 [SAFE] index: galleries_region_id_foreign
-- Restore the expected index
-- Requires galleries.galleries_region_id_foreign.orphans = 0; snapshot result: 0
-- ALTER TABLE `galleries` ADD INDEX `galleries_region_id_foreign` (`region_id`);

-- ------------------------------------------------------------
-- TABLE ingredients
-- ------------------------------------------------------------

-- STEP 354 [SAFE] index: PRIMARY
-- Restore the primary key
-- Requires ingredients.PRIMARY.unique = 0; snapshot result: 0
-- ALTER TABLE `ingredients` ADD PRIMARY KEY (`id`);

-- STEP 355 [SAFE] index: ingredients_slug_unique
-- Restore the expected index
-- Requires ingredients.ingredients_slug_unique.unique = 0; snapshot result: 0
-- ALTER TABLE `ingredients` ADD UNIQUE INDEX `ingredients_slug_unique` (`slug`);

-- ------------------------------------------------------------
-- TABLE locations
-- ------------------------------------------------------------

-- STEP 356 [SAFE] index: PRIMARY
-- Restore the primary key
-- Requires locations.PRIMARY.unique = 0; snapshot result: 0
-- ALTER TABLE `locations` ADD PRIMARY KEY (`id`);

-- ------------------------------------------------------------
-- TABLE media
-- ------------------------------------------------------------

-- STEP 357 [SAFE] index: PRIMARY
-- Restore the primary key
-- Requires media.PRIMARY.unique = 0; snapshot result: 0
-- ALTER TABLE `media` ADD PRIMARY KEY (`id`);

-- STEP 358 [SAFE] index: media_model_type_model_id_index
-- Restore the expected index
-- ALTER TABLE `media` ADD INDEX `media_model_type_model_id_index` (`model_type`, `model_id`);

-- STEP 359 [SAFE] index: media_order_column_index
-- Restore the expected index
-- ALTER TABLE `media` ADD INDEX `media_order_column_index` (`order_column`);

-- STEP 360 [SAFE] index: media_uuid_unique
-- Restore the expected index
-- Requires media.media_uuid_unique.unique = 0; snapshot result: 0
-- ALTER TABLE `media` ADD UNIQUE INDEX `media_uuid_unique` (`uuid`);

-- ------------------------------------------------------------
-- TABLE migrations
-- ------------------------------------------------------------

-- STEP 361 [SAFE] index: PRIMARY
-- Restore the primary key
-- Requires migrations.PRIMARY.unique = 0; snapshot result: 0
-- ALTER TABLE `migrations` ADD PRIMARY KEY (`id`);

-- ------------------------------------------------------------
-- TABLE nova_field_attachments
-- ------------------------------------------------------------

-- STEP 362 [SAFE] index: PRIMARY
-- Restore the primary key
-- Requires nova_field_attachments.PRIMARY.unique = 0; snapshot result: 0
-- ALTER TABLE `nova_field_attachments` ADD PRIMARY KEY (`id`);

-- STEP 363 [SAFE] index: nova_field_attachments_attachable_type_attachable_id_index
-- Restore the expected index
-- ALTER TABLE `nova_field_attachments` ADD INDEX `nova_field_attachments_attachable_type_attachable_id_index` (`attachable_type`, `attachable_id`);

-- STEP 364 [SAFE] index: nova_field_attachments_url_index
-- Restore the expected index
-- ALTER TABLE `nova_field_attachments` ADD INDEX `nova_field_attachments_url_index` (`url`);

-- ------------------------------------------------------------
-- TABLE nova_notifications
-- ------------------------------------------------------------

-- STEP 365 [SAFE] index: PRIMARY
-- Restore the primary key
-- Requires nova_notifications.PRIMARY.unique = 0; snapshot result: 0
-- ALTER TABLE `nova_notifications` ADD PRIMARY KEY (`id`);

-- STEP 366 [SAFE] index: nova_notifications_notifiable_type_notifiable_id_index
-- Restore the expected index
-- ALTER TABLE `nova_notifications` ADD INDEX `nova_notifications_notifiable_type_notifiable_id_index` (`notifiable_type`, `notifiable_id`);

-- ------------------------------------------------------------
-- TABLE nova_pending_field_attachments
-- ------------------------------------------------------------

-- STEP 367 [SAFE] index: PRIMARY
-- Restore the primary key
-- Requires nova_pending_field_attachments.PRIMARY.unique = 0; snapshot result: 0
-- ALTER TABLE `nova_pending_field_attachments` ADD PRIMARY KEY (`id`);

-- STEP 368 [SAFE] index: nova_pending_field_attachments_draft_id_index
-- Restore the expected index
-- ALTER TABLE `nova_pending_field_attachments` ADD INDEX `nova_pending_field_attachments_draft_id_index` (`draft_id`);

-- ------------------------------------------------------------
-- TABLE order_items
-- ------------------------------------------------------------

-- STEP 369 [SAFE] index: PRIMARY
-- Restore the primary key
-- Requires order_items.PRIMARY.unique = 0; snapshot result: 0
-- ALTER TABLE `order_items` ADD PRIMARY KEY (`id`);

-- STEP 370 [SAFE] index: order_items_order_id_index
-- Restore the expected index
-- ALTER TABLE `order_items` ADD INDEX `order_items_order_id_index` (`order_id`);

-- STEP 371 [SAFE] index: order_items_product_id_index
-- Restore the expected index
-- ALTER TABLE `order_items` ADD INDEX `order_items_product_id_index` (`product_id`);

-- ------------------------------------------------------------
-- TABLE orders
-- ------------------------------------------------------------

-- STEP 372 [SAFE] index: PRIMARY
-- Restore the primary key
-- Requires orders.PRIMARY.unique = 0; snapshot result: 0
-- ALTER TABLE `orders` ADD PRIMARY KEY (`id`);

-- STEP 373 [SAFE] index: orders_order_number_unique
-- Restore the expected index
-- Requires orders.orders_order_number_unique.unique = 0; snapshot result: 0
-- ALTER TABLE `orders` ADD UNIQUE INDEX `orders_order_number_unique` (`order_number`);

-- STEP 374 [SAFE] index: orders_status_index
-- Restore the expected index
-- ALTER TABLE `orders` ADD INDEX `orders_status_index` (`status`);

-- ------------------------------------------------------------
-- TABLE password_reset_tokens
-- ------------------------------------------------------------

-- STEP 375 [SAFE] index: PRIMARY
-- Restore the primary key
-- Requires password_reset_tokens.PRIMARY.unique = 0; snapshot result: 0
-- ALTER TABLE `password_reset_tokens` ADD PRIMARY KEY (`email`);

-- ------------------------------------------------------------
-- TABLE personal_access_tokens
-- ------------------------------------------------------------

-- STEP 376 [SAFE] index: PRIMARY
-- Restore the primary key
-- Requires personal_access_tokens.PRIMARY.unique = 0; snapshot result: 0
-- ALTER TABLE `personal_access_tokens` ADD PRIMARY KEY (`id`);

-- STEP 377 [SAFE] index: personal_access_tokens_token_unique
-- Restore the expected index
-- Requires personal_access_tokens.personal_access_tokens_token_unique.unique = 0; snapshot result: 0
-- ALTER TABLE `personal_access_tokens` ADD UNIQUE INDEX `personal_access_tokens_token_unique` (`token`);

-- STEP 378 [SAFE] index: personal_access_tokens_tokenable_type_tokenable_id_index
-- Restore the expected index
-- ALTER TABLE `personal_access_tokens` ADD INDEX `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`, `tokenable_id`);

-- ------------------------------------------------------------
-- TABLE product_brands
-- ------------------------------------------------------------

-- STEP 379 [SAFE] index: PRIMARY
-- Restore the primary key
-- Requires product_brands.PRIMARY.unique = 0; snapshot result: 0
-- ALTER TABLE `product_brands` ADD PRIMARY KEY (`id`);

-- STEP 380 [SAFE] index: product_brands_name_unique
-- Restore the expected index
-- Requires product_brands.product_brands_name_unique.unique = 0; snapshot result: 0
-- ALTER TABLE `product_brands` ADD UNIQUE INDEX `product_brands_name_unique` (`name`);

-- STEP 381 [SAFE] index: product_brands_slug_unique
-- Restore the expected index
-- Requires product_brands.product_brands_slug_unique.unique = 0; snapshot result: 0
-- ALTER TABLE `product_brands` ADD UNIQUE INDEX `product_brands_slug_unique` (`slug`);

-- ------------------------------------------------------------
-- TABLE product_categories
-- ------------------------------------------------------------

-- STEP 382 [SAFE] index: PRIMARY
-- Restore the primary key
-- Requires product_categories.PRIMARY.unique = 0; snapshot result: 0
-- ALTER TABLE `product_categories` ADD PRIMARY KEY (`id`);

-- STEP 383 [SAFE] index: product_categories_slug_unique
-- Restore the expected index
-- Requires product_categories.product_categories_slug_unique.unique = 0; snapshot result: 0
-- ALTER TABLE `product_categories` ADD UNIQUE INDEX `product_categories_slug_unique` (`slug`);

-- ------------------------------------------------------------
-- TABLE product_ingredients
-- ------------------------------------------------------------

-- STEP 384 [SAFE] index: PRIMARY
-- Restore the primary key
-- Requires product_ingredients.PRIMARY.unique = 0; snapshot result: 0
-- ALTER TABLE `product_ingredients` ADD PRIMARY KEY (`id`);

-- STEP 385 [SAFE] index: product_ingredients_ingredient_id_index
-- Restore the expected index
-- ALTER TABLE `product_ingredients` ADD INDEX `product_ingredients_ingredient_id_index` (`ingredient_id`);

-- STEP 386 [SAFE] index: product_ingredients_product_id_ingredient_id_unique
-- Restore the expected index
-- Requires product_ingredients.product_ingredients_product_id_ingredient_id_unique.unique = 0; snapshot result: 0
-- ALTER TABLE `product_ingredients` ADD UNIQUE INDEX `product_ingredients_product_id_ingredient_id_unique` (`product_id`, `ingredient_id`);

-- ------------------------------------------------------------
-- TABLE product_variants
-- ------------------------------------------------------------

-- STEP 387 [SAFE] index: PRIMARY
-- Restore the primary key
-- Requires product_variants.PRIMARY.unique = 0; snapshot result: 0
-- ALTER TABLE `product_variants` ADD PRIMARY KEY (`id`);

-- STEP 388 [SAFE] index: product_variants_product_id_variant_id_unique
-- Restore the expected index
-- Requires product_variants.product_variants_product_id_variant_id_unique.unique = 0; snapshot result: 0
-- ALTER TABLE `product_variants` ADD UNIQUE INDEX `product_variants_product_id_variant_id_unique` (`product_id`, `variant_id`);

-- STEP 389 [SAFE] index: product_variants_variant_id_product_id_index
-- Restore the expected index
-- ALTER TABLE `product_variants` ADD INDEX `product_variants_variant_id_product_id_index` (`variant_id`, `product_id`);

-- ------------------------------------------------------------
-- TABLE products
-- ------------------------------------------------------------

-- STEP 390 [SAFE] index: PRIMARY
-- Restore the primary key
-- Requires products.PRIMARY.unique = 0; snapshot result: 0
-- ALTER TABLE `products` ADD PRIMARY KEY (`id`);

-- STEP 391 [SAFE] index: products_article_unique
-- Restore the expected index
-- Requires products.products_article_unique.unique = 0; snapshot result: 0
-- ALTER TABLE `products` ADD UNIQUE INDEX `products_article_unique` (`article`);

-- STEP 392 [SAFE] index: products_code_unique
-- Restore the expected index
-- Requires products.products_code_unique.unique = 0; snapshot result: 0
-- ALTER TABLE `products` ADD UNIQUE INDEX `products_code_unique` (`code`);

-- STEP 393 [SAFE] index: products_product_brand_id_foreign
-- Restore the expected index
-- Requires products.products_product_brand_id_foreign.orphans = 0; snapshot result: 0
-- ALTER TABLE `products` ADD INDEX `products_product_brand_id_foreign` (`product_brand_id`);

-- STEP 394 [SAFE] index: products_product_category_id_product_brand_id_index
-- Restore the expected index
-- ALTER TABLE `products` ADD INDEX `products_product_category_id_product_brand_id_index` (`product_category_id`, `product_brand_id`);

-- STEP 395 [SAFE] index: products_slug_index
-- Restore the expected index
-- ALTER TABLE `products` ADD INDEX `products_slug_index` (`slug`);

-- STEP 396 [SAFE] index: products_slug_unique
-- Restore the expected index
-- Requires products.products_slug_unique.unique = 0; snapshot result: 0
-- ALTER TABLE `products` ADD UNIQUE INDEX `products_slug_unique` (`slug`);

-- ------------------------------------------------------------
-- TABLE regions
-- ------------------------------------------------------------

-- STEP 397 [SAFE] index: PRIMARY
-- Restore the primary key
-- Requires regions.PRIMARY.unique = 0; snapshot result: 0
-- ALTER TABLE `regions` ADD PRIMARY KEY (`id`);

-- STEP 398 [SAFE] index: regions_code_unique
-- Restore the expected index
-- Requires regions.regions_code_unique.unique = 0; snapshot result: 0
-- ALTER TABLE `regions` ADD UNIQUE INDEX `regions_code_unique` (`code`);

-- ------------------------------------------------------------
-- TABLE service_categories
-- ------------------------------------------------------------

-- STEP 399 [SAFE] index: PRIMARY
-- Restore the primary key
-- Requires service_categories.PRIMARY.unique = 0; snapshot result: 0
-- ALTER TABLE `service_categories` ADD PRIMARY KEY (`id`);

-- STEP 400 [SAFE] index: service_categories_category_id_foreign
-- Restore the expected index
-- Requires service_categories.service_categories_category_id_foreign.orphans = 0; snapshot result: 0
-- ALTER TABLE `service_categories` ADD INDEX `service_categories_category_id_foreign` (`category_id`);

-- STEP 401 [BLOCKED] index: service_categories_service_id_foreign
-- Restore the expected index
-- Requires service_categories.service_categories_service_id_foreign.orphans = 0; snapshot result: 33
-- ALTER TABLE `service_categories` ADD INDEX `service_categories_service_id_foreign` (`service_id`);

-- ------------------------------------------------------------
-- TABLE service_variant_prices
-- ------------------------------------------------------------

-- STEP 402 [SAFE] index: PRIMARY
-- Restore the primary key
-- Requires service_variant_prices.PRIMARY.unique = 0; snapshot result: 0
-- ALTER TABLE `service_variant_prices` ADD PRIMARY KEY (`id`);

-- STEP 403 [SAFE] index: service_variant_prices_variant_id_foreign
-- Restore the expected index
-- Requires service_variant_prices.service_variant_prices_variant_id_foreign.orphans = 0; snapshot result: 0
-- ALTER TABLE `service_variant_prices` ADD INDEX `service_variant_prices_variant_id_foreign` (`variant_id`);

-- ------------------------------------------------------------
-- TABLE service_variants
-- ------------------------------------------------------------

-- STEP 404 [SAFE] index: PRIMARY
-- Restore the primary key
-- Requires service_variants.PRIMARY.unique = 0; snapshot result: 0
-- ALTER TABLE `service_variants` ADD PRIMARY KEY (`id`);

-- STEP 405 [BLOCKED] index: service_variants_service_id_foreign
-- Restore the expected index
-- Requires service_variants.service_variants_service_id_foreign.orphans = 0; snapshot result: 120
-- ALTER TABLE `service_variants` ADD INDEX `service_variants_service_id_foreign` (`service_id`);

-- ------------------------------------------------------------
-- TABLE services
-- ------------------------------------------------------------

-- STEP 406 [SAFE] index: PRIMARY
-- Restore the primary key
-- Requires services.PRIMARY.unique = 0; snapshot result: 0
-- ALTER TABLE `services` ADD PRIMARY KEY (`id`);

-- STEP 407 [SAFE] index: services_region_id_foreign
-- Restore the expected index
-- Requires services.services_region_id_foreign.orphans = 0; snapshot result: 0
-- ALTER TABLE `services` ADD INDEX `services_region_id_foreign` (`region_id`);

-- ------------------------------------------------------------
-- TABLE site_settings
-- ------------------------------------------------------------

-- STEP 408 [SAFE] index: PRIMARY
-- Restore the primary key
-- Requires site_settings.PRIMARY.unique = 0; snapshot result: 0
-- ALTER TABLE `site_settings` ADD PRIMARY KEY (`id`);

-- STEP 409 [SAFE] index: site_settings_key_unique
-- Restore the expected index
-- Requires site_settings.site_settings_key_unique.unique = 0; snapshot result: 0
-- ALTER TABLE `site_settings` ADD UNIQUE INDEX `site_settings_key_unique` (`key`);

-- ------------------------------------------------------------
-- TABLE social_links
-- ------------------------------------------------------------

-- STEP 410 [SAFE] index: PRIMARY
-- Restore the primary key
-- Requires social_links.PRIMARY.unique = 0; snapshot result: 0
-- ALTER TABLE `social_links` ADD PRIMARY KEY (`id`);

-- STEP 411 [SAFE] index: social_links_region_id_foreign
-- Restore the expected index
-- Requires social_links.social_links_region_id_foreign.orphans = 0; snapshot result: 0
-- ALTER TABLE `social_links` ADD INDEX `social_links_region_id_foreign` (`region_id`);

-- ------------------------------------------------------------
-- TABLE special_offers
-- ------------------------------------------------------------

-- STEP 412 [SAFE] index: PRIMARY
-- Restore the primary key
-- Requires special_offers.PRIMARY.unique = 0; snapshot result: 0
-- ALTER TABLE `special_offers` ADD PRIMARY KEY (`id`);

-- STEP 413 [SAFE] index: special_offers_region_id_foreign
-- Restore the expected index
-- Requires special_offers.special_offers_region_id_foreign.orphans = 0; snapshot result: 0
-- ALTER TABLE `special_offers` ADD INDEX `special_offers_region_id_foreign` (`region_id`);

-- ------------------------------------------------------------
-- TABLE team_members
-- ------------------------------------------------------------

-- STEP 414 [SAFE] index: team_members_region_id_foreign
-- Restore the expected index
-- Requires team_members.team_members_region_id_foreign.orphans = 0; snapshot result: 0
-- ALTER TABLE `team_members` ADD INDEX `team_members_region_id_foreign` (`region_id`);

-- ------------------------------------------------------------
-- TABLE users
-- ------------------------------------------------------------

-- STEP 415 [SAFE] index: PRIMARY
-- Restore the primary key
-- Requires users.PRIMARY.unique = 0; snapshot result: 0
-- ALTER TABLE `users` ADD PRIMARY KEY (`id`);

-- STEP 416 [SAFE] index: users_email_unique
-- Restore the expected index
-- Requires users.users_email_unique.unique = 0; snapshot result: 0
-- ALTER TABLE `users` ADD UNIQUE INDEX `users_email_unique` (`email`);

-- STEP 417 [SAFE] index: users_telegram_id_unique
-- Restore the expected index
-- Requires users.users_telegram_id_unique.unique = 0; snapshot result: 0
-- ALTER TABLE `users` ADD UNIQUE INDEX `users_telegram_id_unique` (`telegram_id`);

-- ------------------------------------------------------------
-- TABLE variants
-- ------------------------------------------------------------

-- STEP 418 [SAFE] index: PRIMARY
-- Restore the primary key
-- Requires variants.PRIMARY.unique = 0; snapshot result: 0
-- ALTER TABLE `variants` ADD PRIMARY KEY (`id`);

-- STEP 419 [SAFE] index: variants_slug_unique
-- Restore the expected index
-- Requires variants.variants_slug_unique.unique = 0; snapshot result: 0
-- ALTER TABLE `variants` ADD UNIQUE INDEX `variants_slug_unique` (`slug`);

-- ------------------------------------------------------------
-- TABLE abouts
-- ------------------------------------------------------------

-- STEP 420 [SAFE] auto_increment: id
-- Enable AUTO_INCREMENT after the primary key exists; MySQL derives the next value from MAX(id)
-- Requires abouts.id.not_null = 0; snapshot result: 0
-- Requires abouts.id.auto_increment_values = 0; snapshot result: 0
-- Requires abouts.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires abouts.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `abouts` MODIFY COLUMN `id` bigint unsigned NOT NULL auto_increment;

-- ------------------------------------------------------------
-- TABLE action_events
-- ------------------------------------------------------------

-- STEP 421 [BLOCKED] auto_increment: id
-- Enable AUTO_INCREMENT after the primary key exists; MySQL derives the next value from MAX(id)
-- Requires action_events.id.not_null = 0; snapshot result: 188
-- Requires action_events.id.auto_increment_values = 0; snapshot result: 188
-- Requires action_events.id.auto_increment_duplicates = 0; snapshot result: 1
-- Requires action_events.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `action_events` MODIFY COLUMN `id` bigint unsigned NOT NULL auto_increment;

-- ------------------------------------------------------------
-- TABLE appointments
-- ------------------------------------------------------------

-- STEP 422 [BLOCKED] auto_increment: id
-- Enable AUTO_INCREMENT after the primary key exists; MySQL derives the next value from MAX(id)
-- Requires appointments.id.not_null = 0; snapshot result: 16
-- Requires appointments.id.auto_increment_values = 0; snapshot result: 16
-- Requires appointments.id.auto_increment_duplicates = 0; snapshot result: 1
-- Requires appointments.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `appointments` MODIFY COLUMN `id` bigint unsigned NOT NULL auto_increment;

-- ------------------------------------------------------------
-- TABLE banners
-- ------------------------------------------------------------

-- STEP 423 [SAFE] auto_increment: id
-- Enable AUTO_INCREMENT after the primary key exists; MySQL derives the next value from MAX(id)
-- Requires banners.id.not_null = 0; snapshot result: 0
-- Requires banners.id.auto_increment_values = 0; snapshot result: 0
-- Requires banners.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires banners.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `banners` MODIFY COLUMN `id` bigint unsigned NOT NULL auto_increment;

-- ------------------------------------------------------------
-- TABLE call_us
-- ------------------------------------------------------------

-- STEP 424 [SAFE] auto_increment: id
-- Enable AUTO_INCREMENT after the primary key exists; MySQL derives the next value from MAX(id)
-- Requires call_us.id.not_null = 0; snapshot result: 0
-- Requires call_us.id.auto_increment_values = 0; snapshot result: 0
-- Requires call_us.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires call_us.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `call_us` MODIFY COLUMN `id` bigint unsigned NOT NULL auto_increment;

-- ------------------------------------------------------------
-- TABLE categories
-- ------------------------------------------------------------

-- STEP 425 [SAFE] auto_increment: id
-- Enable AUTO_INCREMENT after the primary key exists; MySQL derives the next value from MAX(id)
-- Requires categories.id.not_null = 0; snapshot result: 0
-- Requires categories.id.auto_increment_values = 0; snapshot result: 0
-- Requires categories.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires categories.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `categories` MODIFY COLUMN `id` bigint unsigned NOT NULL auto_increment;

-- ------------------------------------------------------------
-- TABLE contacts
-- ------------------------------------------------------------

-- STEP 426 [SAFE] auto_increment: id
-- Enable AUTO_INCREMENT after the primary key exists; MySQL derives the next value from MAX(id)
-- Requires contacts.id.not_null = 0; snapshot result: 0
-- Requires contacts.id.auto_increment_values = 0; snapshot result: 0
-- Requires contacts.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires contacts.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `contacts` MODIFY COLUMN `id` bigint unsigned NOT NULL auto_increment;

-- ------------------------------------------------------------
-- TABLE devices
-- ------------------------------------------------------------

-- STEP 427 [BLOCKED] auto_increment: id
-- Enable AUTO_INCREMENT after the primary key exists; MySQL derives the next value from MAX(id)
-- Requires devices.id.not_null = 0; snapshot result: 4
-- Requires devices.id.auto_increment_values = 0; snapshot result: 4
-- Requires devices.id.auto_increment_duplicates = 0; snapshot result: 1
-- Requires devices.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `devices` MODIFY COLUMN `id` bigint unsigned NOT NULL auto_increment;

-- ------------------------------------------------------------
-- TABLE failed_jobs
-- ------------------------------------------------------------

-- STEP 428 [SAFE] auto_increment: id
-- Enable AUTO_INCREMENT after the primary key exists; MySQL derives the next value from MAX(id)
-- Requires failed_jobs.id.not_null = 0; snapshot result: 0
-- Requires failed_jobs.id.auto_increment_values = 0; snapshot result: 0
-- Requires failed_jobs.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires failed_jobs.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `failed_jobs` MODIFY COLUMN `id` bigint unsigned NOT NULL auto_increment;

-- ------------------------------------------------------------
-- TABLE galleries
-- ------------------------------------------------------------

-- STEP 429 [SAFE] auto_increment: id
-- Enable AUTO_INCREMENT after the primary key exists; MySQL derives the next value from MAX(id)
-- Requires galleries.id.not_null = 0; snapshot result: 0
-- Requires galleries.id.auto_increment_values = 0; snapshot result: 0
-- Requires galleries.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires galleries.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `galleries` MODIFY COLUMN `id` bigint unsigned NOT NULL auto_increment;

-- ------------------------------------------------------------
-- TABLE ingredients
-- ------------------------------------------------------------

-- STEP 430 [SAFE] auto_increment: id
-- Enable AUTO_INCREMENT after the primary key exists; MySQL derives the next value from MAX(id)
-- Requires ingredients.id.not_null = 0; snapshot result: 0
-- Requires ingredients.id.auto_increment_values = 0; snapshot result: 0
-- Requires ingredients.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires ingredients.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `ingredients` MODIFY COLUMN `id` bigint unsigned NOT NULL auto_increment;

-- ------------------------------------------------------------
-- TABLE locations
-- ------------------------------------------------------------

-- STEP 431 [SAFE] auto_increment: id
-- Enable AUTO_INCREMENT after the primary key exists; MySQL derives the next value from MAX(id)
-- Requires locations.id.not_null = 0; snapshot result: 0
-- Requires locations.id.auto_increment_values = 0; snapshot result: 0
-- Requires locations.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires locations.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `locations` MODIFY COLUMN `id` bigint unsigned NOT NULL auto_increment;

-- ------------------------------------------------------------
-- TABLE media
-- ------------------------------------------------------------

-- STEP 432 [SAFE] auto_increment: id
-- Enable AUTO_INCREMENT after the primary key exists; MySQL derives the next value from MAX(id)
-- Requires media.id.not_null = 0; snapshot result: 0
-- Requires media.id.auto_increment_values = 0; snapshot result: 0
-- Requires media.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires media.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `media` MODIFY COLUMN `id` bigint unsigned NOT NULL auto_increment;

-- ------------------------------------------------------------
-- TABLE migrations
-- ------------------------------------------------------------

-- STEP 433 [SAFE] auto_increment: id
-- Enable AUTO_INCREMENT after the primary key exists; MySQL derives the next value from MAX(id)
-- Requires migrations.id.not_null = 0; snapshot result: 0
-- Requires migrations.id.auto_increment_values = 0; snapshot result: 0
-- Requires migrations.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires migrations.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `migrations` MODIFY COLUMN `id` int unsigned NOT NULL auto_increment;

-- ------------------------------------------------------------
-- TABLE nova_field_attachments
-- ------------------------------------------------------------

-- STEP 434 [SAFE] auto_increment: id
-- Enable AUTO_INCREMENT after the primary key exists; MySQL derives the next value from MAX(id)
-- Requires nova_field_attachments.id.not_null = 0; snapshot result: 0
-- Requires nova_field_attachments.id.auto_increment_values = 0; snapshot result: 0
-- Requires nova_field_attachments.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires nova_field_attachments.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `nova_field_attachments` MODIFY COLUMN `id` int unsigned NOT NULL auto_increment;

-- ------------------------------------------------------------
-- TABLE nova_pending_field_attachments
-- ------------------------------------------------------------

-- STEP 435 [SAFE] auto_increment: id
-- Enable AUTO_INCREMENT after the primary key exists; MySQL derives the next value from MAX(id)
-- Requires nova_pending_field_attachments.id.not_null = 0; snapshot result: 0
-- Requires nova_pending_field_attachments.id.auto_increment_values = 0; snapshot result: 0
-- Requires nova_pending_field_attachments.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires nova_pending_field_attachments.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `nova_pending_field_attachments` MODIFY COLUMN `id` int unsigned NOT NULL auto_increment;

-- ------------------------------------------------------------
-- TABLE order_items
-- ------------------------------------------------------------

-- STEP 436 [SAFE] auto_increment: id
-- Enable AUTO_INCREMENT after the primary key exists; MySQL derives the next value from MAX(id)
-- Requires order_items.id.not_null = 0; snapshot result: 0
-- Requires order_items.id.auto_increment_values = 0; snapshot result: 0
-- Requires order_items.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires order_items.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `order_items` MODIFY COLUMN `id` bigint unsigned NOT NULL auto_increment;

-- ------------------------------------------------------------
-- TABLE orders
-- ------------------------------------------------------------

-- STEP 437 [SAFE] auto_increment: id
-- Enable AUTO_INCREMENT after the primary key exists; MySQL derives the next value from MAX(id)
-- Requires orders.id.not_null = 0; snapshot result: 0
-- Requires orders.id.auto_increment_values = 0; snapshot result: 0
-- Requires orders.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires orders.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `orders` MODIFY COLUMN `id` bigint unsigned NOT NULL auto_increment;

-- ------------------------------------------------------------
-- TABLE personal_access_tokens
-- ------------------------------------------------------------

-- STEP 438 [SAFE] auto_increment: id
-- Enable AUTO_INCREMENT after the primary key exists; MySQL derives the next value from MAX(id)
-- Requires personal_access_tokens.id.not_null = 0; snapshot result: 0
-- Requires personal_access_tokens.id.auto_increment_values = 0; snapshot result: 0
-- Requires personal_access_tokens.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires personal_access_tokens.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `personal_access_tokens` MODIFY COLUMN `id` bigint unsigned NOT NULL auto_increment;

-- ------------------------------------------------------------
-- TABLE product_brands
-- ------------------------------------------------------------

-- STEP 439 [SAFE] auto_increment: id
-- Enable AUTO_INCREMENT after the primary key exists; MySQL derives the next value from MAX(id)
-- Requires product_brands.id.not_null = 0; snapshot result: 0
-- Requires product_brands.id.auto_increment_values = 0; snapshot result: 0
-- Requires product_brands.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires product_brands.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `product_brands` MODIFY COLUMN `id` bigint unsigned NOT NULL auto_increment;

-- ------------------------------------------------------------
-- TABLE product_categories
-- ------------------------------------------------------------

-- STEP 440 [SAFE] auto_increment: id
-- Enable AUTO_INCREMENT after the primary key exists; MySQL derives the next value from MAX(id)
-- Requires product_categories.id.not_null = 0; snapshot result: 0
-- Requires product_categories.id.auto_increment_values = 0; snapshot result: 0
-- Requires product_categories.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires product_categories.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `product_categories` MODIFY COLUMN `id` bigint unsigned NOT NULL auto_increment;

-- ------------------------------------------------------------
-- TABLE product_ingredients
-- ------------------------------------------------------------

-- STEP 441 [SAFE] auto_increment: id
-- Enable AUTO_INCREMENT after the primary key exists; MySQL derives the next value from MAX(id)
-- Requires product_ingredients.id.not_null = 0; snapshot result: 0
-- Requires product_ingredients.id.auto_increment_values = 0; snapshot result: 0
-- Requires product_ingredients.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires product_ingredients.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `product_ingredients` MODIFY COLUMN `id` bigint unsigned NOT NULL auto_increment;

-- ------------------------------------------------------------
-- TABLE product_variants
-- ------------------------------------------------------------

-- STEP 442 [SAFE] auto_increment: id
-- Enable AUTO_INCREMENT after the primary key exists; MySQL derives the next value from MAX(id)
-- Requires product_variants.id.not_null = 0; snapshot result: 0
-- Requires product_variants.id.auto_increment_values = 0; snapshot result: 0
-- Requires product_variants.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires product_variants.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `product_variants` MODIFY COLUMN `id` bigint unsigned NOT NULL auto_increment;

-- ------------------------------------------------------------
-- TABLE products
-- ------------------------------------------------------------

-- STEP 443 [SAFE] auto_increment: id
-- Enable AUTO_INCREMENT after the primary key exists; MySQL derives the next value from MAX(id)
-- Requires products.id.not_null = 0; snapshot result: 0
-- Requires products.id.auto_increment_values = 0; snapshot result: 0
-- Requires products.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires products.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `products` MODIFY COLUMN `id` bigint unsigned NOT NULL auto_increment;

-- ------------------------------------------------------------
-- TABLE regions
-- ------------------------------------------------------------

-- STEP 444 [SAFE] auto_increment: id
-- Enable AUTO_INCREMENT after the primary key exists; MySQL derives the next value from MAX(id)
-- Requires regions.id.not_null = 0; snapshot result: 0
-- Requires regions.id.auto_increment_values = 0; snapshot result: 0
-- Requires regions.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires regions.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `regions` MODIFY COLUMN `id` bigint unsigned NOT NULL auto_increment;

-- ------------------------------------------------------------
-- TABLE service_categories
-- ------------------------------------------------------------

-- STEP 445 [SAFE] auto_increment: id
-- Enable AUTO_INCREMENT after the primary key exists; MySQL derives the next value from MAX(id)
-- Requires service_categories.id.not_null = 0; snapshot result: 0
-- Requires service_categories.id.auto_increment_values = 0; snapshot result: 0
-- Requires service_categories.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires service_categories.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `service_categories` MODIFY COLUMN `id` bigint unsigned NOT NULL auto_increment;

-- ------------------------------------------------------------
-- TABLE service_variant_prices
-- ------------------------------------------------------------

-- STEP 446 [SAFE] auto_increment: id
-- Enable AUTO_INCREMENT after the primary key exists; MySQL derives the next value from MAX(id)
-- Requires service_variant_prices.id.not_null = 0; snapshot result: 0
-- Requires service_variant_prices.id.auto_increment_values = 0; snapshot result: 0
-- Requires service_variant_prices.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires service_variant_prices.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `service_variant_prices` MODIFY COLUMN `id` bigint unsigned NOT NULL auto_increment;

-- ------------------------------------------------------------
-- TABLE service_variants
-- ------------------------------------------------------------

-- STEP 447 [SAFE] auto_increment: id
-- Enable AUTO_INCREMENT after the primary key exists; MySQL derives the next value from MAX(id)
-- Requires service_variants.id.not_null = 0; snapshot result: 0
-- Requires service_variants.id.auto_increment_values = 0; snapshot result: 0
-- Requires service_variants.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires service_variants.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `service_variants` MODIFY COLUMN `id` bigint unsigned NOT NULL auto_increment;

-- ------------------------------------------------------------
-- TABLE services
-- ------------------------------------------------------------

-- STEP 448 [SAFE] auto_increment: id
-- Enable AUTO_INCREMENT after the primary key exists; MySQL derives the next value from MAX(id)
-- Requires services.id.not_null = 0; snapshot result: 0
-- Requires services.id.auto_increment_values = 0; snapshot result: 0
-- Requires services.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires services.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `services` MODIFY COLUMN `id` bigint unsigned NOT NULL auto_increment;

-- ------------------------------------------------------------
-- TABLE site_settings
-- ------------------------------------------------------------

-- STEP 449 [SAFE] auto_increment: id
-- Enable AUTO_INCREMENT after the primary key exists; MySQL derives the next value from MAX(id)
-- Requires site_settings.id.not_null = 0; snapshot result: 0
-- Requires site_settings.id.auto_increment_values = 0; snapshot result: 0
-- Requires site_settings.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires site_settings.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `site_settings` MODIFY COLUMN `id` bigint unsigned NOT NULL auto_increment;

-- ------------------------------------------------------------
-- TABLE social_links
-- ------------------------------------------------------------

-- STEP 450 [SAFE] auto_increment: id
-- Enable AUTO_INCREMENT after the primary key exists; MySQL derives the next value from MAX(id)
-- Requires social_links.id.not_null = 0; snapshot result: 0
-- Requires social_links.id.auto_increment_values = 0; snapshot result: 0
-- Requires social_links.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires social_links.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `social_links` MODIFY COLUMN `id` bigint unsigned NOT NULL auto_increment;

-- ------------------------------------------------------------
-- TABLE special_offers
-- ------------------------------------------------------------

-- STEP 451 [SAFE] auto_increment: id
-- Enable AUTO_INCREMENT after the primary key exists; MySQL derives the next value from MAX(id)
-- Requires special_offers.id.not_null = 0; snapshot result: 0
-- Requires special_offers.id.auto_increment_values = 0; snapshot result: 0
-- Requires special_offers.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires special_offers.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `special_offers` MODIFY COLUMN `id` bigint unsigned NOT NULL auto_increment;

-- ------------------------------------------------------------
-- TABLE users
-- ------------------------------------------------------------

-- STEP 452 [SAFE] auto_increment: id
-- Enable AUTO_INCREMENT after the primary key exists; MySQL derives the next value from MAX(id)
-- Requires users.id.not_null = 0; snapshot result: 0
-- Requires users.id.auto_increment_values = 0; snapshot result: 0
-- Requires users.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires users.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `users` MODIFY COLUMN `id` bigint unsigned NOT NULL auto_increment;

-- ------------------------------------------------------------
-- TABLE variants
-- ------------------------------------------------------------

-- STEP 453 [SAFE] auto_increment: id
-- Enable AUTO_INCREMENT after the primary key exists; MySQL derives the next value from MAX(id)
-- Requires variants.id.not_null = 0; snapshot result: 0
-- Requires variants.id.auto_increment_values = 0; snapshot result: 0
-- Requires variants.id.auto_increment_duplicates = 0; snapshot result: 0
-- Requires variants.id.valid_integer = 0; snapshot result: 0
-- ALTER TABLE `variants` MODIFY COLUMN `id` bigint unsigned NOT NULL auto_increment;

-- ------------------------------------------------------------
-- TABLE devices
-- ------------------------------------------------------------

-- STEP 454 [SAFE] foreign_key: devices_region_id_foreign
-- Restore a foreign key explicitly declared by AE migrations
-- Requires devices.devices_region_id_foreign.orphans = 0; snapshot result: 0
-- ALTER TABLE `devices` ADD CONSTRAINT `devices_region_id_foreign` FOREIGN KEY (`region_id`) REFERENCES `regions` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE;

-- ------------------------------------------------------------
-- TABLE galleries
-- ------------------------------------------------------------

-- STEP 455 [SAFE] foreign_key: galleries_region_id_foreign
-- Restore a foreign key explicitly declared by AE migrations
-- Requires galleries.galleries_region_id_foreign.orphans = 0; snapshot result: 0
-- ALTER TABLE `galleries` ADD CONSTRAINT `galleries_region_id_foreign` FOREIGN KEY (`region_id`) REFERENCES `regions` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE;

-- ------------------------------------------------------------
-- TABLE order_items
-- ------------------------------------------------------------

-- STEP 456 [BLOCKED] foreign_key: order_items_order_id_foreign
-- Restore a foreign key explicitly declared by AE migrations
-- Requires order_items.order_items_order_id_foreign.orphans = 0; snapshot result: 23
-- ALTER TABLE `order_items` ADD CONSTRAINT `order_items_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE;

-- STEP 457 [BLOCKED] foreign_key: order_items_product_id_foreign
-- Restore a foreign key explicitly declared by AE migrations
-- Requires order_items.order_items_product_id_foreign.orphans = 0; snapshot result: 23
-- ALTER TABLE `order_items` ADD CONSTRAINT `order_items_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON UPDATE NO ACTION ON DELETE SET NULL;

-- ------------------------------------------------------------
-- TABLE product_ingredients
-- ------------------------------------------------------------

-- STEP 458 [SAFE] foreign_key: product_ingredients_ingredient_id_foreign
-- Restore a foreign key explicitly declared by AE migrations
-- Requires product_ingredients.product_ingredients_ingredient_id_foreign.orphans = 0; snapshot result: 0
-- ALTER TABLE `product_ingredients` ADD CONSTRAINT `product_ingredients_ingredient_id_foreign` FOREIGN KEY (`ingredient_id`) REFERENCES `ingredients` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE;

-- STEP 459 [BLOCKED] foreign_key: product_ingredients_product_id_foreign
-- Restore a foreign key explicitly declared by AE migrations
-- Requires product_ingredients.product_ingredients_product_id_foreign.orphans = 0; snapshot result: 18
-- ALTER TABLE `product_ingredients` ADD CONSTRAINT `product_ingredients_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE;

-- ------------------------------------------------------------
-- TABLE product_variants
-- ------------------------------------------------------------

-- STEP 460 [BLOCKED] foreign_key: product_variants_product_id_foreign
-- Restore a foreign key explicitly declared by AE migrations
-- Requires product_variants.product_variants_product_id_foreign.orphans = 0; snapshot result: 84
-- ALTER TABLE `product_variants` ADD CONSTRAINT `product_variants_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE;

-- STEP 461 [SAFE] foreign_key: product_variants_variant_id_foreign
-- Restore a foreign key explicitly declared by AE migrations
-- Requires product_variants.product_variants_variant_id_foreign.orphans = 0; snapshot result: 0
-- ALTER TABLE `product_variants` ADD CONSTRAINT `product_variants_variant_id_foreign` FOREIGN KEY (`variant_id`) REFERENCES `variants` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE;

-- ------------------------------------------------------------
-- TABLE products
-- ------------------------------------------------------------

-- STEP 462 [SAFE] foreign_key: products_product_brand_id_foreign
-- Restore a foreign key explicitly declared by AE migrations
-- Requires products.products_product_brand_id_foreign.orphans = 0; snapshot result: 0
-- ALTER TABLE `products` ADD CONSTRAINT `products_product_brand_id_foreign` FOREIGN KEY (`product_brand_id`) REFERENCES `product_brands` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE;

-- STEP 463 [SAFE] foreign_key: products_product_category_id_foreign
-- Restore a foreign key explicitly declared by AE migrations
-- Requires products.products_product_category_id_foreign.orphans = 0; snapshot result: 0
-- ALTER TABLE `products` ADD CONSTRAINT `products_product_category_id_foreign` FOREIGN KEY (`product_category_id`) REFERENCES `product_categories` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE;

-- ------------------------------------------------------------
-- TABLE service_categories
-- ------------------------------------------------------------

-- STEP 464 [SAFE] foreign_key: service_categories_category_id_foreign
-- Restore a foreign key explicitly declared by AE migrations
-- Requires service_categories.service_categories_category_id_foreign.orphans = 0; snapshot result: 0
-- ALTER TABLE `service_categories` ADD CONSTRAINT `service_categories_category_id_foreign` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE;

-- STEP 465 [BLOCKED] foreign_key: service_categories_service_id_foreign
-- Restore a foreign key explicitly declared by AE migrations
-- Requires service_categories.service_categories_service_id_foreign.orphans = 0; snapshot result: 33
-- ALTER TABLE `service_categories` ADD CONSTRAINT `service_categories_service_id_foreign` FOREIGN KEY (`service_id`) REFERENCES `services` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE;

-- ------------------------------------------------------------
-- TABLE service_variant_prices
-- ------------------------------------------------------------

-- STEP 466 [SAFE] foreign_key: service_variant_prices_variant_id_foreign
-- Restore a foreign key explicitly declared by AE migrations
-- Requires service_variant_prices.service_variant_prices_variant_id_foreign.orphans = 0; snapshot result: 0
-- ALTER TABLE `service_variant_prices` ADD CONSTRAINT `service_variant_prices_variant_id_foreign` FOREIGN KEY (`variant_id`) REFERENCES `service_variants` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE;

-- ------------------------------------------------------------
-- TABLE service_variants
-- ------------------------------------------------------------

-- STEP 467 [BLOCKED] foreign_key: service_variants_service_id_foreign
-- Restore a foreign key explicitly declared by AE migrations
-- Requires service_variants.service_variants_service_id_foreign.orphans = 0; snapshot result: 120
-- ALTER TABLE `service_variants` ADD CONSTRAINT `service_variants_service_id_foreign` FOREIGN KEY (`service_id`) REFERENCES `services` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE;

-- ------------------------------------------------------------
-- TABLE services
-- ------------------------------------------------------------

-- STEP 468 [SAFE] foreign_key: services_region_id_foreign
-- Restore a foreign key explicitly declared by AE migrations
-- Requires services.services_region_id_foreign.orphans = 0; snapshot result: 0
-- ALTER TABLE `services` ADD CONSTRAINT `services_region_id_foreign` FOREIGN KEY (`region_id`) REFERENCES `regions` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE;

-- ------------------------------------------------------------
-- TABLE social_links
-- ------------------------------------------------------------

-- STEP 469 [SAFE] foreign_key: social_links_region_id_foreign
-- Restore a foreign key explicitly declared by AE migrations
-- Requires social_links.social_links_region_id_foreign.orphans = 0; snapshot result: 0
-- ALTER TABLE `social_links` ADD CONSTRAINT `social_links_region_id_foreign` FOREIGN KEY (`region_id`) REFERENCES `regions` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE;

-- ------------------------------------------------------------
-- TABLE special_offers
-- ------------------------------------------------------------

-- STEP 470 [SAFE] foreign_key: special_offers_region_id_foreign
-- Restore a foreign key explicitly declared by AE migrations
-- Requires special_offers.special_offers_region_id_foreign.orphans = 0; snapshot result: 0
-- ALTER TABLE `special_offers` ADD CONSTRAINT `special_offers_region_id_foreign` FOREIGN KEY (`region_id`) REFERENCES `regions` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE;

-- ------------------------------------------------------------
-- TABLE team_members
-- ------------------------------------------------------------

-- STEP 471 [SAFE] foreign_key: team_members_region_id_foreign
-- Restore a foreign key explicitly declared by AE migrations
-- Requires team_members.team_members_region_id_foreign.orphans = 0; snapshot result: 0
-- ALTER TABLE `team_members` ADD CONSTRAINT `team_members_region_id_foreign` FOREIGN KEY (`region_id`) REFERENCES `regions` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE;

-- ------------------------------------------------------------
-- TABLE abouts
-- ------------------------------------------------------------

-- STEP 472 [SAFE] table_default_collation: collation
-- Changes the table default only; existing textual columns are normalized by their individual MODIFY steps
-- ALTER TABLE `abouts` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- TABLE action_events
-- ------------------------------------------------------------

-- STEP 473 [SAFE] table_default_collation: collation
-- Changes the table default only; existing textual columns are normalized by their individual MODIFY steps
-- ALTER TABLE `action_events` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- TABLE appointments
-- ------------------------------------------------------------

-- STEP 474 [SAFE] table_default_collation: collation
-- Changes the table default only; existing textual columns are normalized by their individual MODIFY steps
-- ALTER TABLE `appointments` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- TABLE banners
-- ------------------------------------------------------------

-- STEP 475 [SAFE] table_default_collation: collation
-- Changes the table default only; existing textual columns are normalized by their individual MODIFY steps
-- ALTER TABLE `banners` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- TABLE call_us
-- ------------------------------------------------------------

-- STEP 476 [SAFE] table_default_collation: collation
-- Changes the table default only; existing textual columns are normalized by their individual MODIFY steps
-- ALTER TABLE `call_us` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- TABLE categories
-- ------------------------------------------------------------

-- STEP 477 [SAFE] table_default_collation: collation
-- Changes the table default only; existing textual columns are normalized by their individual MODIFY steps
-- ALTER TABLE `categories` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- TABLE contacts
-- ------------------------------------------------------------

-- STEP 478 [SAFE] table_default_collation: collation
-- Changes the table default only; existing textual columns are normalized by their individual MODIFY steps
-- ALTER TABLE `contacts` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- TABLE devices
-- ------------------------------------------------------------

-- STEP 479 [SAFE] table_default_collation: collation
-- Changes the table default only; existing textual columns are normalized by their individual MODIFY steps
-- ALTER TABLE `devices` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- TABLE failed_jobs
-- ------------------------------------------------------------

-- STEP 480 [SAFE] table_default_collation: collation
-- Changes the table default only; existing textual columns are normalized by their individual MODIFY steps
-- ALTER TABLE `failed_jobs` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- TABLE galleries
-- ------------------------------------------------------------

-- STEP 481 [SAFE] table_default_collation: collation
-- Changes the table default only; existing textual columns are normalized by their individual MODIFY steps
-- ALTER TABLE `galleries` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- TABLE ingredients
-- ------------------------------------------------------------

-- STEP 482 [SAFE] table_default_collation: collation
-- Changes the table default only; existing textual columns are normalized by their individual MODIFY steps
-- ALTER TABLE `ingredients` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- TABLE locations
-- ------------------------------------------------------------

-- STEP 483 [SAFE] table_default_collation: collation
-- Changes the table default only; existing textual columns are normalized by their individual MODIFY steps
-- ALTER TABLE `locations` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- TABLE media
-- ------------------------------------------------------------

-- STEP 484 [SAFE] table_default_collation: collation
-- Changes the table default only; existing textual columns are normalized by their individual MODIFY steps
-- ALTER TABLE `media` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- TABLE migrations
-- ------------------------------------------------------------

-- STEP 485 [SAFE] table_default_collation: collation
-- Changes the table default only; existing textual columns are normalized by their individual MODIFY steps
-- ALTER TABLE `migrations` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- TABLE nova_field_attachments
-- ------------------------------------------------------------

-- STEP 486 [SAFE] table_default_collation: collation
-- Changes the table default only; existing textual columns are normalized by their individual MODIFY steps
-- ALTER TABLE `nova_field_attachments` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- TABLE nova_notifications
-- ------------------------------------------------------------

-- STEP 487 [SAFE] table_default_collation: collation
-- Changes the table default only; existing textual columns are normalized by their individual MODIFY steps
-- ALTER TABLE `nova_notifications` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- TABLE nova_pending_field_attachments
-- ------------------------------------------------------------

-- STEP 488 [SAFE] table_default_collation: collation
-- Changes the table default only; existing textual columns are normalized by their individual MODIFY steps
-- ALTER TABLE `nova_pending_field_attachments` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- TABLE order_items
-- ------------------------------------------------------------

-- STEP 489 [SAFE] table_default_collation: collation
-- Changes the table default only; existing textual columns are normalized by their individual MODIFY steps
-- ALTER TABLE `order_items` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- TABLE orders
-- ------------------------------------------------------------

-- STEP 490 [SAFE] table_default_collation: collation
-- Changes the table default only; existing textual columns are normalized by their individual MODIFY steps
-- ALTER TABLE `orders` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- TABLE password_reset_tokens
-- ------------------------------------------------------------

-- STEP 491 [SAFE] table_default_collation: collation
-- Changes the table default only; existing textual columns are normalized by their individual MODIFY steps
-- ALTER TABLE `password_reset_tokens` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- TABLE personal_access_tokens
-- ------------------------------------------------------------

-- STEP 492 [SAFE] table_default_collation: collation
-- Changes the table default only; existing textual columns are normalized by their individual MODIFY steps
-- ALTER TABLE `personal_access_tokens` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- TABLE product_brands
-- ------------------------------------------------------------

-- STEP 493 [SAFE] table_default_collation: collation
-- Changes the table default only; existing textual columns are normalized by their individual MODIFY steps
-- ALTER TABLE `product_brands` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- TABLE product_categories
-- ------------------------------------------------------------

-- STEP 494 [SAFE] table_default_collation: collation
-- Changes the table default only; existing textual columns are normalized by their individual MODIFY steps
-- ALTER TABLE `product_categories` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- TABLE product_ingredients
-- ------------------------------------------------------------

-- STEP 495 [SAFE] table_default_collation: collation
-- Changes the table default only; existing textual columns are normalized by their individual MODIFY steps
-- ALTER TABLE `product_ingredients` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- TABLE product_variants
-- ------------------------------------------------------------

-- STEP 496 [SAFE] table_default_collation: collation
-- Changes the table default only; existing textual columns are normalized by their individual MODIFY steps
-- ALTER TABLE `product_variants` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- TABLE products
-- ------------------------------------------------------------

-- STEP 497 [SAFE] table_default_collation: collation
-- Changes the table default only; existing textual columns are normalized by their individual MODIFY steps
-- ALTER TABLE `products` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- TABLE promo_banners
-- ------------------------------------------------------------

-- STEP 498 [SAFE] table_default_collation: collation
-- Changes the table default only; existing textual columns are normalized by their individual MODIFY steps
-- ALTER TABLE `promo_banners` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- TABLE regions
-- ------------------------------------------------------------

-- STEP 499 [SAFE] table_default_collation: collation
-- Changes the table default only; existing textual columns are normalized by their individual MODIFY steps
-- ALTER TABLE `regions` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- TABLE service_categories
-- ------------------------------------------------------------

-- STEP 500 [SAFE] table_default_collation: collation
-- Changes the table default only; existing textual columns are normalized by their individual MODIFY steps
-- ALTER TABLE `service_categories` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- TABLE service_variant_prices
-- ------------------------------------------------------------

-- STEP 501 [SAFE] table_default_collation: collation
-- Changes the table default only; existing textual columns are normalized by their individual MODIFY steps
-- ALTER TABLE `service_variant_prices` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- TABLE service_variants
-- ------------------------------------------------------------

-- STEP 502 [SAFE] table_default_collation: collation
-- Changes the table default only; existing textual columns are normalized by their individual MODIFY steps
-- ALTER TABLE `service_variants` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- TABLE services
-- ------------------------------------------------------------

-- STEP 503 [SAFE] table_default_collation: collation
-- Changes the table default only; existing textual columns are normalized by their individual MODIFY steps
-- ALTER TABLE `services` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- TABLE site_settings
-- ------------------------------------------------------------

-- STEP 504 [SAFE] table_default_collation: collation
-- Changes the table default only; existing textual columns are normalized by their individual MODIFY steps
-- ALTER TABLE `site_settings` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- TABLE social_links
-- ------------------------------------------------------------

-- STEP 505 [SAFE] table_default_collation: collation
-- Changes the table default only; existing textual columns are normalized by their individual MODIFY steps
-- ALTER TABLE `social_links` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- TABLE special_offers
-- ------------------------------------------------------------

-- STEP 506 [SAFE] table_default_collation: collation
-- Changes the table default only; existing textual columns are normalized by their individual MODIFY steps
-- ALTER TABLE `special_offers` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- TABLE team_members
-- ------------------------------------------------------------

-- STEP 507 [SAFE] table_default_collation: collation
-- Changes the table default only; existing textual columns are normalized by their individual MODIFY steps
-- ALTER TABLE `team_members` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- TABLE users
-- ------------------------------------------------------------

-- STEP 508 [SAFE] table_default_collation: collation
-- Changes the table default only; existing textual columns are normalized by their individual MODIFY steps
-- ALTER TABLE `users` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- TABLE variants
-- ------------------------------------------------------------

-- STEP 509 [SAFE] table_default_collation: collation
-- Changes the table default only; existing textual columns are normalized by their individual MODIFY steps
-- ALTER TABLE `variants` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ============================================================
-- VERIFICATION
-- ============================================================
-- Confirm every AUTO_INCREMENT will continue above current IDs:
SELECT TABLE_NAME, AUTO_INCREMENT FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() ORDER BY TABLE_NAME;
-- Confirm primary/unique/index definitions:
SELECT TABLE_NAME, INDEX_NAME, NON_UNIQUE, SEQ_IN_INDEX, COLUMN_NAME, INDEX_TYPE
FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = DATABASE()
ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;
-- Confirm foreign keys:
SELECT TABLE_NAME, CONSTRAINT_NAME, COLUMN_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE CONSTRAINT_SCHEMA = DATABASE() AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, CONSTRAINT_NAME, ORDINAL_POSITION;

-- Re-run the Laravel audit after finishing. Expected result: zero critical differences.
