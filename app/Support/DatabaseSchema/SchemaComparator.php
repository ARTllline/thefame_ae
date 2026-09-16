<?php

namespace App\Support\DatabaseSchema;

class SchemaComparator
{
    private const COLUMN_PROPERTIES = [
        'column_type',
        'nullable',
        'default',
        'extra',
        'character_set',
        'collation',
        'generation_expression',
    ];

    public function compare(array $expected, array $actual): array
    {
        $issues = [];

        foreach ($expected['tables'] as $table => $definition) {
            if (! isset($actual['tables'][$table])) {
                $issues[] = $this->issue('missing_table', 'critical', $table, null, $definition, null);
                continue;
            }

            $actualTable = $actual['tables'][$table];

            foreach (['engine', 'collation'] as $property) {
                if (($definition[$property] ?? null) !== ($actualTable[$property] ?? null)) {
                    $issues[] = $this->issue(
                        'table_'.$property,
                        $property === 'engine' ? 'critical' : 'warning',
                        $table,
                        $property,
                        $definition[$property] ?? null,
                        $actualTable[$property] ?? null
                    );
                }
            }

            $this->compareColumns($issues, $table, $definition, $actualTable);
            $this->compareNamedObjects($issues, $table, 'index', $definition['indexes'], $actualTable['indexes']);
            $this->compareNamedObjects(
                $issues,
                $table,
                'foreign_key',
                $definition['foreign_keys'],
                $actualTable['foreign_keys']
            );
        }

        foreach (array_diff_key($actual['tables'], $expected['tables']) as $table => $definition) {
            $issues[] = $this->issue('extra_table', 'warning', $table, null, null, $definition);
        }

        return $issues;
    }

    private function compareColumns(array &$issues, string $table, array $expected, array $actual): void
    {
        foreach ($expected['columns'] as $column => $definition) {
            if (! isset($actual['columns'][$column])) {
                $issues[] = $this->issue('missing_column', 'critical', $table, $column, $definition, null);
                continue;
            }

            foreach (self::COLUMN_PROPERTIES as $property) {
                if (($definition[$property] ?? null) !== ($actual['columns'][$column][$property] ?? null)) {
                    $issues[] = $this->issue(
                        'column_'.$property,
                        in_array($property, ['character_set', 'collation'], true) ? 'warning' : 'critical',
                        $table,
                        $column,
                        $definition[$property] ?? null,
                        $actual['columns'][$column][$property] ?? null
                    );
                }
            }
        }

        foreach (array_diff_key($actual['columns'], $expected['columns']) as $column => $definition) {
            $issues[] = $this->issue('extra_column', 'warning', $table, $column, null, $definition);
        }
    }

    private function compareNamedObjects(
        array &$issues,
        string $table,
        string $kind,
        array $expected,
        array $actual
    ): void {
        foreach ($expected as $name => $definition) {
            if (! isset($actual[$name])) {
                $issues[] = $this->issue('missing_'.$kind, 'critical', $table, $name, $definition, null);
                continue;
            }

            if ($definition !== $actual[$name]) {
                $issues[] = $this->issue('changed_'.$kind, 'critical', $table, $name, $definition, $actual[$name]);
            }
        }

        foreach (array_diff_key($actual, $expected) as $name => $definition) {
            $issues[] = $this->issue('extra_'.$kind, 'warning', $table, $name, null, $definition);
        }
    }

    private function issue(
        string $category,
        string $severity,
        string $table,
        ?string $object,
        mixed $expected,
        mixed $actual
    ): array {
        return compact('category', 'severity', 'table', 'object', 'expected', 'actual');
    }
}
