<?php

namespace App\Console\Commands;

use App\Support\DatabaseSchema\SchemaComparator;
use App\Support\DatabaseSchema\SchemaInspector;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use RuntimeException;

class AuditDatabaseSchema extends Command
{
    protected $signature = 'db:audit-schema
        {--schema= : Database to inspect; defaults to the active Laravel database}
        {--manifest=database/schema/ae_expected_schema.json : Expected AE schema manifest}
        {--json : Emit machine-readable JSON}
        {--summary-only : Do not print the full issue table to the console}
        {--output= : Also write the full report to a file relative to the project root}';

    protected $description = 'Compare the active TheFame AE MySQL schema with the expected schema without changing data';

    public function handle(SchemaInspector $inspector, SchemaComparator $comparator): int
    {
        $expected = $this->loadManifest((string) $this->option('manifest'));
        $schema = $this->option('schema') ?: DB::connection()->getDatabaseName();
        $actual = $inspector->inspect($schema);
        $issues = $comparator->compare($expected, $actual);
        $report = [
            'generated_at' => now()->toIso8601String(),
            'expected_manifest' => (string) $this->option('manifest'),
            'actual_database' => $schema,
            'read_only' => true,
            'summary' => $this->summary($issues),
            'issues' => $issues,
        ];

        if ($this->option('json')) {
            $this->line(json_encode($report, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
        } else {
            $this->renderSummary($report, (bool) $this->option('summary-only'));
        }

        if ($output = $this->option('output')) {
            $path = base_path((string) $output);
            $directory = dirname($path);
            if (! is_dir($directory) && ! mkdir($directory, 0755, true) && ! is_dir($directory)) {
                throw new RuntimeException("Cannot create report directory [{$directory}].");
            }
            file_put_contents(
                $path,
                json_encode($report, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE).PHP_EOL
            );
            $this->info('Full JSON report written to '.$path);
        }

        return $issues === [] ? self::SUCCESS : 2;
    }

    private function loadManifest(string $relativePath): array
    {
        $path = base_path($relativePath);
        if (! is_file($path)) {
            throw new RuntimeException("Expected schema manifest not found: {$path}");
        }

        $manifest = json_decode((string) file_get_contents($path), true, flags: JSON_THROW_ON_ERROR);
        if (($manifest['branch'] ?? null) !== 'thefame_ae' || ! isset($manifest['tables'])) {
            throw new RuntimeException('The schema manifest is not a valid TheFame AE manifest.');
        }

        return $manifest;
    }

    private function summary(array $issues): array
    {
        $summary = ['total' => count($issues), 'critical' => 0, 'warning' => 0, 'by_category' => []];
        foreach ($issues as $issue) {
            $summary[$issue['severity']]++;
            $summary['by_category'][$issue['category']] = ($summary['by_category'][$issue['category']] ?? 0) + 1;
        }
        ksort($summary['by_category']);

        return $summary;
    }

    private function renderSummary(array $report, bool $summaryOnly): void
    {
        $summary = $report['summary'];
        $this->info("Read-only schema audit: {$report['actual_database']}");
        $this->line("Differences: {$summary['total']} ({$summary['critical']} critical, {$summary['warning']} warnings)");

        $rows = [];
        foreach ($summary['by_category'] as $category => $count) {
            $rows[] = [$category, $count];
        }
        $this->table(['Category', 'Count'], $rows);

        if ($summaryOnly) {
            $this->comment('Full issue details are available in the JSON output file.');
            $this->comment('This command executed information_schema/metadata SELECT queries only.');

            return;
        }

        $details = array_map(static function (array $issue): array {
            return [
                strtoupper($issue['severity']),
                $issue['category'],
                $issue['table'],
                $issue['object'] ?? '-',
                self::shortValue($issue['expected']),
                self::shortValue($issue['actual']),
            ];
        }, $report['issues']);

        $this->table(['Severity', 'Category', 'Table', 'Object', 'Expected', 'Actual'], $details);
        $this->comment('This command executed information_schema/metadata SELECT queries only.');
    }

    private static function shortValue(mixed $value): string
    {
        if (is_bool($value)) {
            return $value ? 'true' : 'false';
        }
        if ($value === null) {
            return 'NULL';
        }
        if (is_scalar($value)) {
            return mb_strimwidth((string) $value, 0, 42, '...');
        }

        return mb_strimwidth(json_encode($value, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES), 0, 42, '...');
    }
}
