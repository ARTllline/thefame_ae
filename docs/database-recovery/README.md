# TheFame AE safe production database recovery

## Ready local repaired copy

The original local snapshot `thefame_ae` was preserved. Repair was performed
only in `thefame_ae_repaired`. The checked structure-and-data dump is:

`C:\OSPanel\userdata\backups\thefame_ae\thefame_ae_repaired_ready_for_cpanel_20260811_180621.sql`

Do not import it over populated production tables. Import it into a new empty
cPanel database and switch only `DB_DATABASE` after verification. Six foreign
keys remain intentionally absent because existing orphan rows make them unsafe;
all other audited schema differences have been repaired. Full results and the
cPanel/rollback procedure are in
`docs/database-recovery/LOCAL_REPAIR_RESULT_2026-08-11.md`.

This runbook is for shared cPanel hosting without ordinary SSH. Data safety is
the priority. Do not run `migrate:fresh`, `db:wipe`, `TRUNCATE`, table drops, or
an unreviewed bulk SQL repair.

## Files supplied

- `database/schema/ae_expected_schema.json` — expected AE schema manifest.
- `database/schema/reports/thefame_ae_schema_audit.json` — full local audit.
- `database/schema/reports/thefame_ae_schema_preflight.json` — compatibility checks.
- `database/schema/repairs/thefame_ae_schema_repair.sql` — complete phpMyAdmin
  plan. All schema-changing statements are commented out.
- `database/schema/repairs/thefame_ae_blocked_data_preflight.sql` — blocked
  data checks and commented normalization examples.
- `docs/database-recovery/SCHEMA_AUDIT_2026-08-11.md` — human-readable findings.

## Mandatory backup

Do not begin repair without a new backup made immediately before maintenance.

1. In cPanel open **phpMyAdmin** and select the exact production AE database.
2. Open **Export → Custom**.
3. Select every table.
4. Format: **SQL**, not CSV.
5. Include both **Structure** and **Data**.
6. Enable `CREATE TABLE`, indexes, triggers if present, and `INSERT` data.
7. Use zipped or gzipped output if the database is large.
8. Download the file outside the hosting account.
9. Open the decompressed SQL locally and verify that it contains many
   `CREATE TABLE` and `INSERT INTO` statements, not only values or CSV rows.
10. Record file size, checksum and table row counts.
11. Preferably import the dump into a separate local/test database and verify
    that it opens before touching production.

An export is not considered a valid backup until structure and data have both
been confirmed.

## Recommended execution order

1. Put the application into maintenance mode.
2. Make and verify the backup above.
3. Run schema audit.
4. Run data preflight.
5. Resolve every `BLOCKED` result. Do not delete rows to force a green result.
6. Repair column definitions and parent-table primary keys first.
7. Add regular and unique indexes after column types are correct.
8. Restore missing parent data/ID mappings.
9. Add foreign keys last.
10. Run the audit again; require zero critical differences.
11. Run pending normal migrations only after the schema is stable.
12. Verify the application, then leave maintenance mode.

Because MySQL DDL auto-commits, treat each table as a checkpoint. Do not submit
all 500 repair steps in one phpMyAdmin request.

## Option A: cPanel Terminal

First find the project path and cPanel PHP binary. Common examples are `php`,
`/usr/local/bin/ea-php82`, or `/usr/local/bin/ea-php83`. Use the version that
satisfies the project Composer requirements.

```bash
cd /home/CPANEL_USER/path/to/thefame_ae
php artisan db:audit-schema --summary-only --output=storage/app/schema-audit.json
php artisan db:preflight-schema --summary-only --output=storage/app/schema-preflight.json
php artisan db:plan-schema-repair --output=storage/app/thefame_ae_schema_repair.sql
php artisan db:repair-schema --table=abouts
```

The last command is a dry run. It cannot change the database without `--apply`.
The audit exits with code `2` while schema differences exist; preflight/plan
exit with code `3` while blockers remain. These non-zero codes are deliberate
and do not mean that either command changed the database.

After backup verification, zero blockers, maintenance mode, and review of one
specific table, the guarded form is:

```bash
php artisan db:repair-schema --table=abouts --apply --backup-confirmed --acknowledge=THEFAME_AE_PRODUCTION_BACKUP_VERIFIED
```

The apply mode additionally requires `APP_ENV=production`, obtains a named
database lock, logs every statement, stops on the first error, and refuses any
table that still has a blocked/manual-review step. Start with one low-risk
table, re-audit it, and only then continue.

`--safe-only` is available for a deliberately partial repair. It applies only
steps whose current preflight status is `SAFE`, skips every blocker/review and
returns exit code `3` to signal that the schema is still incomplete. It must
not be treated as a successful final production repair.

## Option B: cPanel Cron Jobs

Use a one-time cron only when Terminal is unavailable. Substitute the actual
PHP binary and absolute project path:

```text
/usr/local/bin/ea-php83 /home/CPANEL_USER/path/to/thefame_ae/artisan db:audit-schema --summary-only --output=storage/app/schema-audit.json >> /home/CPANEL_USER/path/to/thefame_ae/storage/logs/schema-audit-cron.log 2>&1
```

Then run the preflight in the same way:

```text
/usr/local/bin/ea-php83 /home/CPANEL_USER/path/to/thefame_ae/artisan db:preflight-schema --summary-only --output=storage/app/schema-preflight.json >> /home/CPANEL_USER/path/to/thefame_ae/storage/logs/schema-preflight-cron.log 2>&1
```

Set the schedule for one near-future execution, verify the output files, and
delete the cron entry immediately afterward. Repair through cron should still
be limited to one explicitly named table and use the same guarded flags as the
Terminal command. phpMyAdmin is preferable when cron output cannot be observed
reliably.

## Option C: phpMyAdmin

1. Select the exact production database.
2. Open `thefame_ae_schema_repair.sql` locally.
3. Its active statements are read-only preflight/verification `SELECT`s. All
   `ALTER` statements are comments beginning with `--`.
4. Run the preflight section or the smaller
   `thefame_ae_blocked_data_preflight.sql` first.
5. Require zero for the checks attached to the next repair step.
6. Copy one commented `ALTER TABLE` statement into a new SQL tab, remove only
   its leading comment marker, execute it, and inspect the result.
7. Run `SHOW CREATE TABLE table_name` and repeat the relevant preflight.
8. Continue with the next step for that table.
9. Add foreign keys only after all orphan counts are zero.

The script is intentionally not a one-click bulk mutation. This makes it a
usable phpMyAdmin fallback while preventing an accidental full-database ALTER.

## No web repair endpoint

No `/fix-database` or other HTTP maintenance endpoint was added. Terminal,
Cron and phpMyAdmin cover the shared-hosting constraints without exposing a
production database mutation surface to the web.

## Rollback / restore

The safest rollback does not overwrite the partially repaired database:

1. Put the site into maintenance mode.
2. In cPanel create a new empty database such as `account_thefame_ae_restore`.
3. Grant the existing application DB user all required privileges to it.
4. Import the verified pre-repair SQL backup into the new database.
5. Compare table counts and inspect several `SHOW CREATE TABLE` results.
6. Update only `DB_DATABASE` in production `.env` to point to the restored
   database; preserve all credentials and other environment settings.
7. Clear Laravel configuration cache using cPanel Terminal/Cron if config is
   cached.
8. Verify login and one read-only page before leaving maintenance mode.
9. Keep the partially repaired database untouched for investigation.

If the hosting account cannot hold a second database, stop and involve hosting
support. Importing a full dump over populated tables can create duplicates or
require destructive drops and is not an automatic rollback.

## Application verification checklist

- `php artisan db:audit-schema --summary-only` reports zero critical issues.
- `SHOW CREATE TABLE` shows expected PK, `AUTO_INCREMENT`, indexes and FKs.
- For every auto-increment table, `AUTO_INCREMENT` is greater than `MAX(id)`;
  no script sets it to 1.
- Login and Nova authentication work.
- Nova lists and updates representative records without SQL errors.
- Main page, services, sorting and filters work.
- Eloquent relations return expected parents/children, especially services,
  product pivots and orders.
- Submit a clearly marked test appointment through the real form.
- The test appointment receives a non-null ID greater than the previous max.
- `created_at` and `updated_at` are real timestamp values.
- Email/Telegram notifications are delivered or their isolated delivery error
  is present in the Laravel log.
- Updating the test appointment works.
- `storage/logs/laravel.log` contains no new SQL/type/constraint exceptions.
- Remove the test record only through an approved application/admin workflow,
  not with an ad-hoc production DELETE.

## Correct database transfer in the future

Use phpMyAdmin **Custom SQL export** with Structure + Data. Never use CSV as a
database migration format. Import into an empty target database and verify the
dump contains `CREATE TABLE` definitions before import. Keep source and target
MySQL/MariaDB versions and collations compatible. After import, compare table
counts, `SHOW CREATE TABLE`, primary keys and foreign keys before switching the
application to the new database.
