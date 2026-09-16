<?php

namespace App\Console\Commands;

use App\Support\DatabaseSchema\SchemaComparator;
use App\Support\DatabaseSchema\SchemaInspector;
use App\Support\DatabaseSchema\SchemaPreflight;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use RuntimeException;

class PreflightDatabaseSchema extends Command
{
    protected $signature = 'db:preflight-schema
        {--schema= : Database to inspect; defaults to the active Laravel database}
        {--manifest=database/schema/ae_expected_schema.json : Expected AE schema manifest}
        {--summary-only : Do not print every compatibility check to the console}
        {--output=database/schema/reports/thefame_ae_schema_preflight.json : JSON report path}';

    protected $description = 'Run read-only data compatibility checks before any TheFame AE schema repair';

    public function handle(
        SchemaInspector $inspector,
        SchemaComparator $comparator,
        SchemaPreflight $preflight
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
        $report = [
            'generated_at' => now()->toIso8601String(),
            'actual_database' => $schema,
            'read_only' => true,
            'summary' => [
                'checks' => count($checks),
                'passed' => count(array_filter($checks, fn (array $check) => $check['status'] === 'pass')),
                'blocked' => count(array_filter($checks, fn (array $check) => $check['status'] === 'blocked')),
                'review' => count(array_filter($checks, fn (array $check) => $check['status'] === 'review')),
            ],
            'checks' => $checks,
        ];

        if (! $this->option('summary-only')) {
            $rows = array_map(static fn (array $check) => [
                strtoupper($check['status']),
                $check['table'],
                $check['object'],
                $check['blocking_count'] ?? '-',
                mb_strimwidth($check['description'], 0, 90, '...'),
            ], $checks);
            $this->table(['Status', 'Table', 'Object', 'Count', 'Check'], $rows);
        }

        $path = base_path((string) $this->option('output'));
        $directory = dirname($path);
        if (! is_dir($directory) && ! mkdir($directory, 0755, true) && ! is_dir($directory)) {
            throw new RuntimeException("Cannot create report directory [{$directory}].");
        }
        file_put_contents(
            $path,
            json_encode($report, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE).PHP_EOL
        );

        $summary = $report['summary'];
        $this->info("Preflight: {$summary['passed']} passed, {$summary['blocked']} blocked, {$summary['review']} manual review.");
        $this->line('Full report: '.$path);
        $this->comment('Only SELECT queries were executed. Any blocked check must be resolved manually before ALTER.');

        return $summary['blocked'] === 0 ? self::SUCCESS : 3;
    }
}
