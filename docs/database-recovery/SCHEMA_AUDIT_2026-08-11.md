# TheFame AE production schema audit

Audit date: 2026-08-11.

The imported production snapshot is the local MySQL database `thefame_ae`.
The expected schema is generated from current AE migrations and code into
`database/schema/ae_expected_schema.json`. The local `thefame_db` database was
used only to materialize those migrations; it is not the production snapshot.

No `ALTER`, `UPDATE`, `DELETE`, `INSERT`, `DROP` or migration was executed
against `thefame_ae` during this audit.

## Summary

- 38 of 38 tables differ from the expected AE schema.
- 1071 metadata differences were found: 652 critical and 419 warnings.
- 313 column type mismatches.
- 157 nullability mismatches.
- 43 default mismatches.
- 37 lost `AUTO_INCREMENT` properties.
- 84 missing indexes, including primary and unique indexes.
- 18 missing foreign keys declared by AE migrations.
- 38 table default collation mismatches.
- 139 character-set and 242 column-collation mismatches.
- Preflight ran 624 read-only data checks: 601 passed, 20 blocked repair,
  and 3 require manual review.

The complete machine-readable issue list, including every damaged column, is
in `database/schema/reports/thefame_ae_schema_audit.json`. The complete
preflight queries and counts are in
`database/schema/reports/thefame_ae_schema_preflight.json`.

## Affected tables

Every existing table is affected. The number is the metadata differences for
that table, not the row count.

| Table | Differences | Table | Differences |
|---|---:|---|---:|
| abouts | 30 | action_events | 49 |
| appointments | 36 | banners | 17 |
| call_us | 22 | categories | 23 |
| contacts | 26 | devices | 29 |
| failed_jobs | 27 | galleries | 20 |
| ingredients | 35 | locations | 22 |
| media | 58 | migrations | 9 |
| nova_field_attachments | 31 | nova_notifications | 30 |
| nova_pending_field_attachments | 23 | order_items | 25 |
| orders | 41 | password_reset_tokens | 11 |
| personal_access_tokens | 31 | product_brands | 31 |
| product_categories | 30 | product_ingredients | 22 |
| product_variants | 22 | products | 55 |
| promo_banners | 13 | regions | 21 |
| service_categories | 20 | service_variant_prices | 29 |
| service_variants | 29 | services | 27 |
| site_settings | 19 | social_links | 25 |
| special_offers | 38 | team_members | 20 |
| users | 39 | variants | 36 |

## Confirmed blockers

### IDs

- `action_events`: 1842 rows, 188 rows with `NULL id`.
- `appointments`: 391 rows, 16 rows with `NULL id`.
- `devices`: 15 rows, 4 rows with `NULL id`.

Primary keys and `AUTO_INCREMENT` must not be added to these tables until the
missing IDs are assigned under an approved normalization plan. Existing
non-null ID values are otherwise numeric and in range.

### Users

- 8 users have `NULL email`.
- 8 users have `NULL password`.
- 1 user has `NULL telegram_id`.
- 1 row has `NULL is_appointment_ua`.
- 1 row has `NULL is_appointment_dubai`.

The expected `NOT NULL` definitions cannot be applied until those rows are
reviewed. Passwords must be generated with Laravel hashing, never as a shared
plaintext value in phpMyAdmin.

### Missing parent records / orphan relations

- `order_items.order_id`: 23 orphan rows across 11 order IDs; `orders` is empty.
- `order_items.product_id`: 23 orphan rows across 6 product IDs; `products` is empty.
- `product_ingredients.product_id`: 18 orphan rows across 5 product IDs.
- `product_variants.product_id`: 84 orphan rows across 84 product IDs.
- `service_categories.service_id`: 33 orphan rows across IDs 4-65.
- `service_variants.service_id`: 120 orphan rows across IDs 4-65.

The 20 imported `services` rows currently have IDs 47-67, while child rows
still reference older IDs starting at 4. This is evidence of data-level
inconsistency in addition to the schema damage. No foreign key repair may run
until parent data or the correct ID mapping is recovered from a trusted source.

### Manual review

`appointments.phone` and `orders.phone` were imported as numeric columns even
though AE migrations require strings. Converting the current numeric values to
`VARCHAR` is structurally possible, but leading `+` or zeroes may already have
been lost and cannot be reconstructed safely without another source.

`promo_banners.link` is currently `latin1` while the expected AE schema is
`utf8mb4`. Review its text for existing mojibake before conversion; changing
the charset cannot repair text that was decoded incorrectly during import.

## Code-confirmed AE schema additions

Two fields existed in production and are actively used by AE code but were
missing from older AE migrations:

- `abouts.label_dubai` as nullable JSON;
- `categories.seo_text` as nullable JSON.

The corresponding AE migration was added. `ingredients.name` and
`product_categories.name` are also translatable in current AE models; all
local snapshot values are valid JSON, so the UA technical fix was adapted to
AE without copying UA-specific fields.

The UA migration that relaxes uniqueness of `products.code` was not copied:
AE migrations still declare it unique, the imported AE `products` table is
empty, and there is no AE evidence supporting a different business rule.

## Migration history

The imported production `migrations` table lacks the following current AE
migrations:

- `2026_08_10_000000_add_appointment_notification_settings`
- `2026_08_11_000000_migrate_legacy_telegram_notification_recipients`
- `2026_08_11_120000_add_missing_about_label_and_category_seo_text`
- `2026_08_11_121000_make_user_telegram_id_nullable`
- `2026_08_11_122000_use_json_for_translatable_names`
- `2026_08_11_124000_flatten_site_telegram_notification_recipients`
- `2026_08_11_124500_create_promo_banners_table`
- `2026_08_11_125000_add_treatment_to_appointments_table`

Do not run normal `artisan migrate` on the damaged production schema before
the repair audit is clean enough for these migrations to execute safely.

## Local repaired copy

The source snapshot `thefame_ae` was preserved. A separate clone,
`thefame_ae_repaired`, was normalized and repaired on 2026-08-11. Its final
audit has 6 differences, all intentionally absent foreign keys blocked by the
orphan rows listed above; there are no remaining column, primary key,
`AUTO_INCREMENT`, index, default/nullability, charset or collation differences.

See `docs/database-recovery/LOCAL_REPAIR_RESULT_2026-08-11.md` for exact backup
and dump paths, checksums, round-trip verification and cPanel deployment steps.

## Evidence about the cause

The exact import tool and options are not available, so the cause cannot be
named with certainty. The observed structure has a strong, specific pattern:

- virtually every textual value became `TEXT`;
- numeric-looking values became `INT` or `DOUBLE`;
- every column became nullable;
- primary, unique, regular and foreign indexes disappeared;
- `AUTO_INCREMENT` disappeared;
- table defaults changed to the database/server default collation;
- the migration names were imported as rows even though their DDL is absent.

A normal SQL structure-and-data dump containing `CREATE TABLE` statements does
not produce this pattern. It is consistent with CSV/spreadsheet import, a
data-only export followed by automatic table creation/type inference, or a
third-party transfer tool that reconstructed tables from values. The orphaned
IDs also indicate that not all related tables/rows came from one consistent
snapshot or that IDs were not preserved during import.
