<?php

namespace App\Console\Commands;

use App\Support\DatabaseSchema\SchemaComparator;
use App\Support\DatabaseSchema\SchemaInspector;
use App\Support\DatabaseSchema\SchemaPreflight;
use App\Support\DatabaseSchema\SchemaRepairPlanner;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use RuntimeException;
use Throwable;

class RepairDatabaseSchema extends Command
{
    private const ACKNOWLEDGEMENT = 'THEFAME_AE_PRODUCTION_BACKUP_VERIFIED';

    protected $signature = 'db:repair-schema
        {--manifest=database/schema/ae_expected_schema.json : Expected AE schema manifest}
        {--table=* : Limit dry-run or repair to one or more exact tables}
        {--apply : Execute safe steps; without this flag the command is read-only}
        {--safe-only : With --apply, skip blocked/review steps and leave the audit intentionally incomplete}
        {--backup-confirmed : Confirm a full structure-and-data SQL backup was downloaded and checked}
        {--acknowledge= : Required exact acknowledgement for --apply}';

    protected $description = 'Dry-run or explicitly apply guarded, idempotent TheFame AE schema repair steps';

    public function handle(
        SchemaInspector $inspector,
        SchemaComparator $comparator,
        SchemaPreflight $preflight,
        SchemaRepairPlanner $planner
    ): int {
        $expected = $this->loadManifest();
        $schema = DB::connection()->getDatabaseName();
        $actual = $inspector->inspect($schema);
        $issues = $comparator->compare($expected, $actual);
        $checks = $preflight->run($expected, $actual, $issues);
        $steps = $planner->plan($expected, $actual, $issues, $checks);
        $steps = $this->filterTables($steps);

        $this->table(['Status', 'Kind', 'Table', 'Object', 'Reason'], array_map(static fn (array $step) => [
            strtoupper($step['status']),
            $step['kind'],
            $step['table'],
            $step['object'],
            mb_strimwidth($step['reason'], 0, 80, '...'),
        ], $steps));

        if (! $this->option('apply')) {
            $this->comment('DRY RUN ONLY: no ALTER/UPDATE/DELETE was executed.');

            return self::SUCCESS;
        }

        if (! app()->environment('production')) {
            $this->error('--apply is disabled unless APP_ENV=production.');

            return self::FAILURE;
        }
        if (! $this->option('backup-confirmed') || $this->option('acknowledge') !== self::ACKNOWLEDGEMENT) {
            $this->error('Repair refused: backup confirmation and exact acknowledgement are mandatory.');
            $this->line('Required: --backup-confirmed --acknowledge='.self::ACKNOWLEDGEMENT);

            return self::FAILURE;
        }
        if ($steps === []) {
            $this->info('No repair steps are required for the selected tables.');

            return self::SUCCESS;
        }

        $unsafe = array_filter($steps, fn (array $step) => $step['status'] !== 'safe');
        if ($unsafe !== [] && ! $this->option('safe-only')) {
            $this->error('Repair refused: blocked or manual-review steps remain. Resolve them and rerun preflight.');

            return 3;
        }

        $skipped = 0;
        if ($unsafe !== [] && $this->option('safe-only')) {
            $skipped = count($unsafe);
            $steps = array_values(array_filter($steps, fn (array $step) => $step['status'] === 'safe'));
            $this->warn("Safe-only mode: {$skipped} blocked/review steps will be skipped and remain in the audit.");
        }

        $lock = DB::selectOne("SELECT GET_LOCK('thefame_ae_schema_repair', 0) AS acquired");
        if ((int) $lock->acquired !== 1) {
            $this->error('Repair refused: another schema repair process holds the database lock.');

            return self::FAILURE;
        }

        try {
            foreach ($steps as $step) {
                $context = [
                    'database' => $schema,
                    'table' => $step['table'],
                    'object' => $step['object'],
                    'kind' => $step['kind'],
                    'sql' => $step['sql'],
                ];
                Log::warning('TheFame AE schema repair step starting', $context);
                $this->line("Applying {$step['table']}.{$step['object']}...");
                DB::statement($step['sql']);
                Log::warning('TheFame AE schema repair step completed', $context);
            }
        } catch (Throwable $exception) {
            Log::error('TheFame AE schema repair stopped on error', [
                'database' => $schema,
                'error' => $exception->getMessage(),
            ]);
            $this->error('Repair stopped immediately: '.$exception->getMessage());
            $this->warn('MySQL DDL auto-commits. Restore from backup if the partial state is not acceptable.');

            return self::FAILURE;
        } finally {
            DB::selectOne("SELECT RELEASE_LOCK('thefame_ae_schema_repair') AS released");
        }

        $this->info('Selected safe repair steps completed. Re-run db:audit-schema and application verification now.');

        return $skipped === 0 ? self::SUCCESS : 3;
    }

    private function loadManifest(): array
    {
        $path = base_path((string) $this->option('manifest'));
        if (! is_file($path)) {
            throw new RuntimeException("Expected schema manifest not found: {$path}");
        }
        $expected = json_decode((string) file_get_contents($path), true, flags: JSON_THROW_ON_ERROR);
        if (($expected['branch'] ?? null) !== 'thefame_ae') {
            throw new RuntimeException('Repair refused: manifest branch is not thefame_ae.');
        }

        return $expected;
    }

    private function filterTables(array $steps): array
    {
        $tables = array_values(array_filter((array) $this->option('table')));
        if ($tables === []) {
            return $steps;
        }

        return array_values(array_filter($steps, fn (array $step) => in_array($step['table'], $tables, true)));
    }
}
