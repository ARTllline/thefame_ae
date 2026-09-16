<?php

namespace App\Support\DatabaseSchema;

use Illuminate\Database\ConnectionInterface;
use InvalidArgumentException;

class SchemaRepairPlanner
{
    public function __construct(private readonly ConnectionInterface $connection)
    {
    }

    public function plan(array $expected, array $actual, array $issues, array $checks): array
    {
        $steps = [];
        $columnIssues = [];
        $missingPrimary = [];

        foreach ($issues as $issue) {
            if (in_array($issue['category'], ['missing_table', 'table_engine'], true)) {
                $steps[] = [
                    'kind' => $issue['category'],
                    'table' => $issue['table'],
                    'object' => $issue['object'] ?? '-',
                    'sql' => null,
                    'status' => 'blocked',
                    'reason' => $issue['category'] === 'missing_table'
                        ? 'Automatic table creation is prohibited during production recovery; reconcile migration history first'
                        : 'Automatic storage-engine conversion is prohibited; review table size, locks and hosting limits',
                    'checks' => [],
                ];
            }
            if ($issue['category'] === 'missing_index' && $issue['object'] === 'PRIMARY') {
                $missingPrimary[$issue['table']] = $issue;
            }
            if (str_starts_with($issue['category'], 'column_') && $issue['object'] !== null) {
                $columnIssues[$issue['table']][$issue['object']] = true;
            }
        }

        foreach ($columnIssues as $table => $columns) {
            foreach (array_keys($columns) as $column) {
                $definition = $expected['tables'][$table]['columns'][$column] ?? null;
                $actualDefinition = $actual['tables'][$table]['columns'][$column] ?? null;
                if ($definition === null || $actualDefinition === null) {
                    continue;
                }

                $autoIncrement = str_contains((string) $definition['extra'], 'auto_increment');
                $needsPrimary = isset($missingPrimary[$table])
                    && in_array($column, array_column($missingPrimary[$table]['expected']['columns'], 'name'), true);

                if ($autoIncrement && $needsPrimary) {
                    $withoutAutoIncrement = $definition;
                    $withoutAutoIncrement['extra'] = trim(str_replace('auto_increment', '', $withoutAutoIncrement['extra']));
                    $steps[] = $this->step(
                        'column',
                        $table,
                        $column,
                        "ALTER TABLE {$this->quoteIdentifier($table)} MODIFY COLUMN "
                            .$this->columnDefinition($column, $withoutAutoIncrement),
                        $checks,
                        'Normalize the ID column before adding its primary key'
                    );
                    continue;
                }

                $steps[] = $this->step(
                    'column',
                    $table,
                    $column,
                    "ALTER TABLE {$this->quoteIdentifier($table)} MODIFY COLUMN "
                        .$this->columnDefinition($column, $definition),
                    $checks,
                    'Restore the expected column definition'
                );
            }
        }

        foreach ($issues as $issue) {
            if ($issue['category'] === 'missing_column') {
                $steps[] = $this->step(
                    'column',
                    $issue['table'],
                    $issue['object'],
                    "ALTER TABLE {$this->quoteIdentifier($issue['table'])} ADD COLUMN "
                        .$this->columnDefinition($issue['object'], $issue['expected']),
                    $checks,
                    'Add a column present in the current AE migrations',
                    'review'
                );
            }
        }

        foreach ($issues as $issue) {
            if ($issue['category'] !== 'missing_index') {
                continue;
            }

            $steps[] = $this->step(
                'index',
                $issue['table'],
                $issue['object'],
                $this->addIndexSql($issue['table'], $issue['object'], $issue['expected']),
                $checks,
                $issue['object'] === 'PRIMARY' ? 'Restore the primary key' : 'Restore the expected index'
            );

            if ($issue['object'] === 'PRIMARY') {
                foreach ($issue['expected']['columns'] as $column) {
                    $definition = $expected['tables'][$issue['table']]['columns'][$column['name']] ?? null;
                    $actualDefinition = $actual['tables'][$issue['table']]['columns'][$column['name']] ?? null;
                    if ($definition !== null
                        && $actualDefinition !== null
                        && str_contains((string) $definition['extra'], 'auto_increment')
                        && ! str_contains((string) $actualDefinition['extra'], 'auto_increment')) {
                        $steps[] = $this->step(
                            'auto_increment',
                            $issue['table'],
                            $column['name'],
                            "ALTER TABLE {$this->quoteIdentifier($issue['table'])} MODIFY COLUMN "
                                .$this->columnDefinition($column['name'], $definition),
                            $checks,
                            'Enable AUTO_INCREMENT after the primary key exists; MySQL derives the next value from MAX(id)'
                        );
                    }
                }
            }
        }

        foreach ($issues as $issue) {
            if ($issue['category'] === 'missing_foreign_key') {
                $steps[] = $this->step(
                    'foreign_key',
                    $issue['table'],
                    $issue['object'],
                    $this->addForeignKeySql($issue['table'], $issue['object'], $issue['expected']),
                    $checks,
                    'Restore a foreign key explicitly declared by AE migrations'
                );
            }
            if (in_array($issue['category'], ['changed_index', 'changed_foreign_key'], true)) {
                $steps[] = [
                    'kind' => $issue['category'],
                    'table' => $issue['table'],
                    'object' => $issue['object'],
                    'sql' => null,
                    'status' => 'blocked',
                    'reason' => 'An existing constraint has the expected name but a different definition; automatic DROP is prohibited',
                    'checks' => [],
                ];
            }
        }

        foreach ($issues as $issue) {
            if ($issue['category'] === 'table_collation') {
                [$charset] = explode('_', (string) $issue['expected'], 2);
                $steps[] = [
                    'kind' => 'table_default_collation',
                    'table' => $issue['table'],
                    'object' => 'collation',
                    'sql' => "ALTER TABLE {$this->quoteIdentifier($issue['table'])} DEFAULT CHARACTER SET {$charset} COLLATE {$issue['expected']}",
                    'status' => 'safe',
                    'reason' => 'Changes the table default only; existing textual columns are normalized by their individual MODIFY steps',
                    'checks' => [],
                ];
            }
        }

        return $this->ordered($steps);
    }

    public function columnDefinition(string $column, array $definition): string
    {
        $sql = $this->quoteIdentifier($column).' '.$definition['column_type'];

        if ($definition['character_set']) {
            $sql .= ' CHARACTER SET '.$definition['character_set'];
        }
        if ($definition['collation']) {
            $sql .= ' COLLATE '.$definition['collation'];
        }

        $sql .= $definition['nullable'] ? ' NULL' : ' NOT NULL';

        if ($definition['default'] !== null) {
            $default = (string) $definition['default'];
            $sql .= preg_match('/^(CURRENT_TIMESTAMP(?:\(\d+\))?|NULL)$/i', $default)
                ? ' DEFAULT '.$default
                : ' DEFAULT '.$this->connection->getPdo()->quote($default);
        } elseif ($definition['nullable']) {
            $sql .= ' DEFAULT NULL';
        }

        $extra = trim(str_ireplace('DEFAULT_GENERATED', '', (string) $definition['extra']));
        if ($extra !== '') {
            $sql .= ' '.$extra;
        }
        if (($definition['comment'] ?? '') !== '') {
            $sql .= ' COMMENT '.$this->connection->getPdo()->quote($definition['comment']);
        }

        return $sql;
    }

    private function step(
        string $kind,
        string $table,
        string $object,
        string $sql,
        array $checks,
        string $reason,
        ?string $forcedStatus = null
    ): array {
        $relevant = array_values(array_filter(
            $checks,
            static function (array $check) use ($kind, $table, $object): bool {
                if ($check['table'] !== $table || $check['object'] !== $object) {
                    return false;
                }

                return match ($kind) {
                    'index' => str_ends_with($check['id'], '.unique'),
                    'foreign_key' => str_ends_with($check['id'], '.orphans'),
                    default => ! str_ends_with($check['id'], '.unique')
                        && ! str_ends_with($check['id'], '.orphans'),
                };
            }
        ));
        $status = $forcedStatus ?? 'safe';
        if (array_filter($relevant, fn (array $check) => $check['status'] === 'blocked')) {
            $status = 'blocked';
        } elseif (array_filter($relevant, fn (array $check) => $check['status'] === 'review')) {
            $status = 'review';
        }

        return compact('kind', 'table', 'object', 'sql', 'status', 'reason') + ['checks' => $relevant];
    }

    private function addIndexSql(string $table, string $name, array $definition): string
    {
        $columns = implode(', ', array_map(function (array $column): string {
            $sql = $this->quoteIdentifier($column['name']);
            if ($column['sub_part'] !== null) {
                $sql .= '('.(int) $column['sub_part'].')';
            }
            if (($column['order'] ?? 'ASC') === 'DESC') {
                $sql .= ' DESC';
            }

            return $sql;
        }, $definition['columns']));

        if ($name === 'PRIMARY') {
            return "ALTER TABLE {$this->quoteIdentifier($table)} ADD PRIMARY KEY ({$columns})";
        }

        $kind = $definition['unique'] ? 'UNIQUE INDEX' : 'INDEX';

        return "ALTER TABLE {$this->quoteIdentifier($table)} ADD {$kind} {$this->quoteIdentifier($name)} ({$columns})";
    }

    private function addForeignKeySql(string $table, string $name, array $definition): string
    {
        $columns = implode(', ', array_map(fn (string $column) => $this->quoteIdentifier($column), $definition['columns']));
        $referenced = implode(', ', array_map(
            fn (string $column) => $this->quoteIdentifier($column),
            $definition['referenced_columns']
        ));

        return "ALTER TABLE {$this->quoteIdentifier($table)} ADD CONSTRAINT {$this->quoteIdentifier($name)} "
            ."FOREIGN KEY ({$columns}) REFERENCES {$this->quoteIdentifier($definition['referenced_table'])} ({$referenced}) "
            ."ON UPDATE {$definition['update_rule']} ON DELETE {$definition['delete_rule']}";
    }

    private function ordered(array $steps): array
    {
        $order = [
            'column' => 10,
            'index' => 20,
            'auto_increment' => 30,
            'foreign_key' => 40,
            'table_default_collation' => 50,
        ];

        usort($steps, static fn (array $a, array $b) => [
            $order[$a['kind']] ?? 99,
            $a['table'],
            $a['object'],
        ] <=> [
            $order[$b['kind']] ?? 99,
            $b['table'],
            $b['object'],
        ]);

        return $steps;
    }

    private function quoteIdentifier(string $identifier): string
    {
        if (! preg_match('/^[A-Za-z0-9_$-]+$/', $identifier)) {
            throw new InvalidArgumentException("Unsafe SQL identifier [{$identifier}].");
        }

        return '`'.$identifier.'`';
    }
}
