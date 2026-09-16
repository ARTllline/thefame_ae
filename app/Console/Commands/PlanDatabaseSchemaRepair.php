<?php

namespace App\Console\Commands;

use App\Support\DatabaseSchema\SchemaComparator;
use App\Support\DatabaseSchema\SchemaInspector;
use App\Support\DatabaseSchema\SchemaPreflight;
use App\Support\DatabaseSchema\SchemaRepairPlanner;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use RuntimeException;

class PlanDatabaseSchemaRepair extends Command
{
    protected $signature = 'db:plan-schema-repair
        {--schema= : Database to inspect; defaults to the active Laravel database}
        {--manifest=database/schema/ae_expected_schema.json : Expected AE schema manifest}
        {--output=database/schema/repairs/thefame_ae_schema_repair.sql : Generated phpMyAdmin SQL plan}';

    protected $description = 'Generate a commented, non-executing phpMyAdmin repair plan after read-only preflight';

    public function handle(
        SchemaInspector $inspector,
        SchemaComparator $comparator,
        SchemaPreflight $preflight,
        SchemaRepairPlanner $planner
    ): int {
        $manifestPath = base_path((string) $this->option('manifest'));
        if (! is_file($manifestPath)) {
            throw new RuntimeException("Expected schema manifest not found: {$manifestPath}");
        }
        $expected = json_decode((string) file_get_contents($manifestPath), true, flags: JSON_THROW_ON_ERROR);
        $schema = $this->option('schema') ?: DB::connection()->getDatabaseName();
        $actual = $inspector->inspect($schema);
        $issues = $comparator->compare($expected, $actual);
        $checks = $preflight->run($expected, $actual, $issues);
        $steps = $planner->plan($expected, $actual, $issues, $checks);
        $sql = $this->renderSql($schema, $issues, $checks, $steps);

        $path = base_path((string) $this->option('output'));
        $directory = dirname($path);
        if (! is_dir($directory) && ! mkdir($directory, 0755, true) && ! is_dir($directory)) {
            throw new RuntimeException("Cannot create repair directory [{$directory}].");
        }
        file_put_contents($path, $sql);

        $counts = array_count_values(array_column($steps, 'status'));
        $this->info('Commented phpMyAdmin plan written to '.$path);
        $this->line(sprintf(
            '%d safe steps, %d blocked steps, %d review steps. No ALTER/UPDATE was executed.',
            $counts['safe'] ?? 0,
            $counts['blocked'] ?? 0,
            $counts['review'] ?? 0
        ));

        return ($counts['blocked'] ?? 0) === 0 ? self::SUCCESS : 3;
    }

    private function renderSql(string $schema, array $issues, array $checks, array $steps): string
    {
        $lines = [
            '-- TheFame AE production schema recovery plan',
            '-- Generated: '.now()->toIso8601String(),
            '-- Source of truth: AE migrations materialized in database/schema/ae_expected_schema.json',
            '-- Target snapshot audited locally: '.$schema,
            '--',
            '-- SAFETY: every ALTER below is commented out intentionally.',
            '-- 1. Export a full SQL backup with structure + data before doing anything.',
            '-- 2. Run the preflight SELECT statements and require zero blocking rows.',
            '-- 3. Un-comment and execute ONE ALTER at a time, table by table.',
            '-- 4. Re-run php artisan db:audit-schema (or verification SELECTs) after each table.',
            '-- 5. Never delete orphan or duplicate rows merely to make a constraint pass.',
            '',
            'SELECT DATABASE() AS connected_database, VERSION() AS mysql_version, @@sql_mode AS sql_mode;',
            "-- Expected database for this snapshot: {$schema}",
            '',
            '-- ============================================================',
            '-- PREFLIGHT: read-only compatibility checks',
            '-- ============================================================',
        ];

        foreach ($checks as $check) {
            $count = $check['blocking_count'] === null ? '-' : (string) $check['blocking_count'];
            $lines[] = '';
            $lines[] = '-- ['.strtoupper($check['status'])."] {$check['id']} (snapshot count: {$count})";
            $lines[] = '-- '.$check['description'];
            if ($check['query']) {
                $portableQuery = str_replace('`'.$schema.'`.', '', $check['query']);
                $lines[] = rtrim($portableQuery, ';').';';
            }
        }

        $lines[] = '';
        $lines[] = '-- ============================================================';
        $lines[] = '-- REPAIR: all statements remain commented until verified';
        $lines[] = '-- ============================================================';

        $currentTable = null;
        foreach ($steps as $position => $step) {
            if ($step['table'] !== $currentTable) {
                $currentTable = $step['table'];
                $lines[] = '';
                $lines[] = '-- ------------------------------------------------------------';
                $lines[] = '-- TABLE '.$currentTable;
                $lines[] = '-- ------------------------------------------------------------';
            }
            $number = $position + 1;
            $lines[] = '';
            $lines[] = '-- STEP '.$number.' ['.strtoupper($step['status'])."] {$step['kind']}: {$step['object']}";
            $lines[] = '-- '.$step['reason'];
            foreach ($step['checks'] as $check) {
                $lines[] = "-- Requires {$check['id']} = 0; snapshot result: ".($check['blocking_count'] ?? 'manual review');
            }
            if ($step['sql']) {
                $lines[] = '-- '.rtrim($step['sql'], ';').';';
            } else {
                $lines[] = '-- No automatic SQL generated.';
            }
        }

        $lines = array_merge($lines, [
            '',
            '-- ============================================================',
            '-- VERIFICATION',
            '-- ============================================================',
            '-- Confirm every AUTO_INCREMENT will continue above current IDs:',
            "SELECT TABLE_NAME, AUTO_INCREMENT FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() ORDER BY TABLE_NAME;",
            '-- Confirm primary/unique/index definitions:',
            'SELECT TABLE_NAME, INDEX_NAME, NON_UNIQUE, SEQ_IN_INDEX, COLUMN_NAME, INDEX_TYPE',
            'FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = DATABASE()',
            'ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;',
            '-- Confirm foreign keys:',
            'SELECT TABLE_NAME, CONSTRAINT_NAME, COLUMN_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME',
            'FROM information_schema.KEY_COLUMN_USAGE',
            'WHERE CONSTRAINT_SCHEMA = DATABASE() AND REFERENCED_TABLE_NAME IS NOT NULL',
            'ORDER BY TABLE_NAME, CONSTRAINT_NAME, ORDINAL_POSITION;',
            '',
            '-- Re-run the Laravel audit after finishing. Expected result: zero critical differences.',
            '',
        ]);

        return implode(PHP_EOL, $lines);
    }
}
