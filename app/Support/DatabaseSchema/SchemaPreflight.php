<?php

namespace App\Support\DatabaseSchema;

use Illuminate\Database\ConnectionInterface;
use InvalidArgumentException;

class SchemaPreflight
{
    public function __construct(private readonly ConnectionInterface $connection)
    {
    }

    public function run(array $expected, array $actual, array $issues): array
    {
        $schema = $actual['database'];
        $checks = [];
        $changedColumns = [];

        foreach ($issues as $issue) {
            if (str_starts_with($issue['category'], 'column_') && $issue['object'] !== null) {
                $changedColumns[$issue['table']][$issue['object']] = true;
            }
        }

        foreach ($changedColumns as $table => $columns) {
            foreach (array_keys($columns) as $column) {
                $definition = $expected['tables'][$table]['columns'][$column] ?? null;
                $actualDefinition = $actual['tables'][$table]['columns'][$column] ?? null;
                if ($definition === null || $actualDefinition === null) {
                    continue;
                }
                array_push($checks, ...$this->columnChecks($schema, $table, $column, $definition, $actualDefinition));
            }
        }

        foreach ($issues as $issue) {
            if ($issue['category'] === 'missing_index') {
                array_push(
                    $checks,
                    ...$this->indexChecks($schema, $issue['table'], $issue['object'], $issue['expected'])
                );
            }
            if ($issue['category'] === 'missing_foreign_key') {
                $checks[] = $this->foreignKeyCheck(
                    $schema,
                    $issue['table'],
                    $issue['object'],
                    $issue['expected']
                );
            }
        }

        $unique = [];
        foreach ($checks as $check) {
            $unique[$check['id']] = $check;
        }

        return array_values($unique);
    }

    private function columnChecks(
        string $schema,
        string $table,
        string $column,
        array $expected,
        array $actual
    ): array {
        $checks = [];
        $qualified = $this->qualified($schema, $table);
        $quotedColumn = $this->quoteIdentifier($column);
        $nonNull = "{$quotedColumn} IS NOT NULL";
        $asText = "TRIM(CAST({$quotedColumn} AS CHAR))";
        $type = strtolower($expected['data_type']);

        if (! $expected['nullable']) {
            $checks[] = $this->countCheck(
                "{$table}.{$column}.not_null",
                $table,
                $column,
                'NULL values conflict with NOT NULL',
                "SELECT COUNT(*) AS aggregate FROM {$qualified} WHERE {$quotedColumn} IS NULL"
            );
        }

        if (str_contains((string) $expected['extra'], 'auto_increment')) {
            $checks[] = $this->countCheck(
                "{$table}.{$column}.auto_increment_values",
                $table,
                $column,
                'AUTO_INCREMENT requires non-null, positive and unique integer values',
                "SELECT COUNT(*) AS aggregate FROM {$qualified} WHERE {$quotedColumn} IS NULL OR {$asText} = '' OR {$asText} = '0' OR {$asText} NOT REGEXP '^[0-9]+$'"
            );
            $checks[] = $this->countCheck(
                "{$table}.{$column}.auto_increment_duplicates",
                $table,
                $column,
                'AUTO_INCREMENT/PRIMARY KEY requires unique values',
                "SELECT COUNT(*) AS aggregate FROM (SELECT {$quotedColumn} FROM {$qualified} GROUP BY {$quotedColumn} HAVING COUNT(*) > 1) AS duplicate_ids"
            );
        }

        if ($type === 'json') {
            $checks[] = $this->countCheck(
                "{$table}.{$column}.valid_json",
                $table,
                $column,
                'TEXT to JSON conversion requires every non-null value to be valid JSON',
                "SELECT COUNT(*) AS aggregate FROM {$qualified} WHERE {$nonNull} AND JSON_VALID(CAST({$quotedColumn} AS CHAR)) = 0"
            );
        } elseif (in_array($type, ['timestamp', 'datetime', 'date'], true)) {
            $pattern = $type === 'date'
                ? '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
                : '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$';
            $zero = $type === 'date' ? '0000-00-00' : '0000-00-00 00:00:00';
            $checks[] = $this->countCheck(
                "{$table}.{$column}.valid_datetime",
                $table,
                $column,
                strtoupper($type).' conversion rejects empty, zero-date and non-canonical values',
                "SELECT COUNT(*) AS aggregate FROM {$qualified} WHERE {$nonNull} AND ({$asText} = '' OR {$asText} = '{$zero}' OR {$asText} NOT REGEXP '{$pattern}')"
            );
        } elseif ($type === 'enum') {
            $values = $this->enumValues($expected['column_type']);
            $quotedValues = implode(', ', array_map(fn (string $value) => $this->connection->getPdo()->quote($value), $values));
            $checks[] = $this->countCheck(
                "{$table}.{$column}.valid_enum",
                $table,
                $column,
                'ENUM conversion requires all values to belong to the expected set',
                "SELECT COUNT(*) AS aggregate FROM {$qualified} WHERE {$nonNull} AND CAST({$quotedColumn} AS CHAR) NOT IN ({$quotedValues})"
            );
        } elseif (in_array($type, ['tinyint', 'smallint', 'mediumint', 'int', 'integer', 'bigint'], true)) {
            $checks[] = $this->integerCheck($schema, $table, $column, $expected);
        } elseif (in_array($type, ['decimal', 'numeric'], true)) {
            $checks[] = $this->decimalCheck($schema, $table, $column, $expected);
        } elseif (in_array($type, ['char', 'varchar'], true) && $expected['character_maximum_length'] !== null) {
            $limit = (int) $expected['character_maximum_length'];
            $checks[] = $this->countCheck(
                "{$table}.{$column}.max_length",
                $table,
                $column,
                "Values must fit the expected {$type}({$limit})",
                "SELECT COUNT(*) AS aggregate FROM {$qualified} WHERE {$nonNull} AND CHAR_LENGTH(CAST({$quotedColumn} AS CHAR)) > {$limit}"
            );
        }

        if ($this->isNumericType($actual['data_type']) && in_array($type, ['char', 'varchar', 'text'], true)) {
            $checks[] = [
                'id' => "{$table}.{$column}.numeric_to_text_review",
                'table' => $table,
                'object' => $column,
                'description' => 'Manual review: the damaged numeric column may already have lost formatting such as leading zeroes or plus signs',
                'query' => null,
                'blocking_count' => null,
                'status' => 'review',
            ];
        }

        if ($expected['character_set'] !== null
            && $actual['character_set'] !== null
            && $expected['character_set'] !== $actual['character_set']) {
            $checks[] = [
                'id' => "{$table}.{$column}.character_set_review",
                'table' => $table,
                'object' => $column,
                'description' => "Manual review: character set conversion from {$actual['character_set']} to {$expected['character_set']} can preserve already-misdecoded text",
                'query' => null,
                'blocking_count' => null,
                'status' => 'review',
            ];
        }

        if ($type === 'json'
            && $actual['character_set'] !== null
            && ! in_array(strtolower($actual['character_set']), ['utf8', 'utf8mb3', 'utf8mb4'], true)) {
            $checks[] = [
                'id' => "{$table}.{$column}.json_character_set_review",
                'table' => $table,
                'object' => $column,
                'description' => "Manual review: JSON text currently uses {$actual['character_set']}; verify multilingual content before UTF-8 JSON conversion",
                'query' => null,
                'blocking_count' => null,
                'status' => 'review',
            ];
        }

        return array_values(array_filter($checks));
    }

    private function integerCheck(string $schema, string $table, string $column, array $expected): array
    {
        $qualified = $this->qualified($schema, $table);
        $quotedColumn = $this->quoteIdentifier($column);
        $asText = "TRIM(CAST({$quotedColumn} AS CHAR))";
        $bounds = $this->integerBounds($expected['data_type'], str_contains($expected['column_type'], 'unsigned'));
        $booleanClause = $expected['column_type'] === 'tinyint(1)' ? " OR {$asText} NOT IN ('0', '1')" : '';

        return $this->countCheck(
            "{$table}.{$column}.valid_integer",
            $table,
            $column,
            'Integer conversion requires canonical in-range whole numbers'.($booleanClause ? ' restricted to 0/1' : ''),
            "SELECT COUNT(*) AS aggregate FROM {$qualified} WHERE {$quotedColumn} IS NOT NULL AND ({$asText} = '' OR {$asText} NOT REGEXP '^-?[0-9]+$' OR CAST({$asText} AS DECIMAL(65,0)) < {$bounds[0]} OR CAST({$asText} AS DECIMAL(65,0)) > {$bounds[1]}{$booleanClause})"
        );
    }

    private function decimalCheck(string $schema, string $table, string $column, array $expected): array
    {
        $qualified = $this->qualified($schema, $table);
        $quotedColumn = $this->quoteIdentifier($column);
        $asText = "TRIM(CAST({$quotedColumn} AS CHAR))";
        $precision = (int) $expected['numeric_precision'];
        $scale = (int) $expected['numeric_scale'];
        $integerDigits = $precision - $scale;
        $sign = str_contains($expected['column_type'], 'unsigned') ? '' : '-?';
        $pattern = "^{$sign}[0-9]{1,{$integerDigits}}(?:[.][0-9]{1,{$scale}})?$";

        return $this->countCheck(
            "{$table}.{$column}.valid_decimal",
            $table,
            $column,
            "DECIMAL({$precision},{$scale}) conversion requires values within precision and scale",
            "SELECT COUNT(*) AS aggregate FROM {$qualified} WHERE {$quotedColumn} IS NOT NULL AND ({$asText} = '' OR {$asText} NOT REGEXP '{$pattern}')"
        );
    }

    private function indexChecks(string $schema, string $table, string $name, array $definition): array
    {
        if (! $definition['unique']) {
            return [];
        }

        $columns = array_column($definition['columns'], 'name');
        $quoted = array_map(fn (string $column) => $this->quoteIdentifier($column), $columns);
        $where = implode(' AND ', array_map(fn (string $column) => "{$column} IS NOT NULL", $quoted));
        $group = implode(', ', $quoted);

        return [$this->countCheck(
            "{$table}.{$name}.unique",
            $table,
            $name,
            $name === 'PRIMARY' ? 'PRIMARY KEY requires unique non-null values' : 'UNIQUE index requires no duplicate non-null tuples',
            'SELECT COUNT(*) AS aggregate FROM (SELECT 1 FROM '.$this->qualified($schema, $table)
                .($where ? " WHERE {$where}" : '')." GROUP BY {$group} HAVING COUNT(*) > 1) AS duplicate_keys"
        )];
    }

    private function foreignKeyCheck(string $schema, string $table, string $name, array $definition): array
    {
        $localColumns = array_map(fn (string $column) => $this->quoteIdentifier($column), $definition['columns']);
        $remoteColumns = array_map(
            fn (string $column) => $this->quoteIdentifier($column),
            $definition['referenced_columns']
        );
        $joins = [];
        foreach ($localColumns as $position => $column) {
            $joins[] = "child.{$column} = parent.{$remoteColumns[$position]}";
        }
        $nonNull = implode(' AND ', array_map(fn (string $column) => "child.{$column} IS NOT NULL", $localColumns));
        $missing = "parent.{$remoteColumns[0]} IS NULL";

        return $this->countCheck(
            "{$table}.{$name}.orphans",
            $table,
            $name,
            'Foreign key requires every non-null child value to reference an existing parent row',
            'SELECT COUNT(*) AS aggregate FROM '.$this->qualified($schema, $table).' child LEFT JOIN '
                .$this->qualified($schema, $definition['referenced_table']).' parent ON '.implode(' AND ', $joins)
                ." WHERE {$nonNull} AND {$missing}"
        );
    }

    private function countCheck(
        string $id,
        string $table,
        string $object,
        string $description,
        string $query
    ): array {
        $count = (int) $this->connection->selectOne($query)->aggregate;

        return [
            'id' => $id,
            'table' => $table,
            'object' => $object,
            'description' => $description,
            'query' => $query,
            'blocking_count' => $count,
            'status' => $count === 0 ? 'pass' : 'blocked',
        ];
    }

    private function qualified(string $schema, string $table): string
    {
        return $this->quoteIdentifier($schema).'.'.$this->quoteIdentifier($table);
    }

    private function quoteIdentifier(string $identifier): string
    {
        if (! preg_match('/^[A-Za-z0-9_$-]+$/', $identifier)) {
            throw new InvalidArgumentException("Unsafe SQL identifier [{$identifier}].");
        }

        return '`'.str_replace('`', '``', $identifier).'`';
    }

    private function enumValues(string $columnType): array
    {
        preg_match_all("/'((?:[^'\\\\]|\\\\.)*)'/", $columnType, $matches);

        return array_map(static fn (string $value) => stripcslashes($value), $matches[1]);
    }

    private function isNumericType(string $type): bool
    {
        return in_array(strtolower($type), [
            'tinyint', 'smallint', 'mediumint', 'int', 'integer', 'bigint',
            'decimal', 'numeric', 'float', 'double', 'real',
        ], true);
    }

    private function integerBounds(string $type, bool $unsigned): array
    {
        $bits = match ($type) {
            'tinyint' => 8,
            'smallint' => 16,
            'mediumint' => 24,
            'int', 'integer' => 32,
            default => 64,
        };

        if ($unsigned) {
            return ['0', $bits === 64 ? '18446744073709551615' : (string) (2 ** $bits - 1)];
        }

        if ($bits === 64) {
            return ['-9223372036854775808', '9223372036854775807'];
        }

        $max = 2 ** ($bits - 1) - 1;

        return [(string) (-$max - 1), (string) $max];
    }
}
