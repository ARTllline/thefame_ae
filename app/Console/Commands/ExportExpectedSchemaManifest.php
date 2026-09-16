<?php

namespace App\Console\Commands;

use App\Support\DatabaseSchema\SchemaInspector;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use RuntimeException;

class ExportExpectedSchemaManifest extends Command
{
    protected $signature = 'db:export-schema-manifest
        {--schema= : Source database created from the current AE migrations}
        {--output=database/schema/ae_expected_schema.json : Destination relative to the project root}';

    protected $description = 'Export a read-only MySQL schema snapshot used by the AE schema audit';

    public function handle(): int
    {
        if (app()->environment('production')) {
            $this->error('Manifest export is intentionally disabled in production.');

            return self::FAILURE;
        }

        $schema = $this->option('schema') ?: DB::connection()->getDatabaseName();
        $output = base_path((string) $this->option('output'));
        $directory = dirname($output);

        if (! is_dir($directory) && ! mkdir($directory, 0755, true) && ! is_dir($directory)) {
            throw new RuntimeException("Cannot create directory [{$directory}].");
        }

        $manifest = app(SchemaInspector::class)->inspect($schema);
        $manifest['generated_at'] = now()->toIso8601String();
        $manifest['source'] = 'Current TheFame AE migrations materialized in an isolated local MySQL database';

        file_put_contents(
            $output,
            json_encode($manifest, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE).PHP_EOL
        );

        $this->info('Expected schema manifest written to '.$output);
        $this->line(count($manifest['tables']).' tables captured; no database changes were made.');

        return self::SUCCESS;
    }
}
