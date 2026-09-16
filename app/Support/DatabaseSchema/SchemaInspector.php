<?php

namespace App\Support\DatabaseSchema;

use Illuminate\Database\ConnectionInterface;
use InvalidArgumentException;

class SchemaInspector
{
    public function __construct(private readonly ConnectionInterface $connection)
    {
    }

    public function inspect(?string $schema = null): array
    {
        $schema ??= $this->connection->getDatabaseName();
        $this->assertSchemaExists($schema);

        $manifest = [
            'format_version' => 1,
            'branch' => 'thefame_ae',
            'database' => $schema,
            'server_version' => (string) $this->connection->selectOne('SELECT VERSION() AS version')->version,
            'tables' => [],
        ];

        foreach ($this->tables($schema) as $row) {
            $manifest['tables'][$row->TABLE_NAME] = [
                'engine' => $row->ENGINE,
                'collation' => $row->TABLE_COLLATION,
                'columns' => [],
                'indexes' => [],
                'foreign_keys' => [],
            ];
        }

        foreach ($this->columns($schema) as $row) {
            if (! isset($manifest['tables'][$row->TABLE_NAME])) {
                continue;
            }

            $manifest['tables'][$row->TABLE_NAME]['columns'][$row->COLUMN_NAME] = [
                'position' => (int) $row->ORDINAL_POSITION,
                'data_type' => $row->DATA_TYPE,
                'column_type' => $row->COLUMN_TYPE,
                'nullable' => $row->IS_NULLABLE === 'YES',
                'default' => $row->COLUMN_DEFAULT,
                'extra' => $row->EXTRA,
                'character_set' => $row->CHARACTER_SET_NAME,
                'collation' => $row->COLLATION_NAME,
                'comment' => $row->COLUMN_COMMENT,
                'generation_expression' => $row->GENERATION_EXPRESSION,
                'numeric_precision' => $row->NUMERIC_PRECISION === null ? null : (int) $row->NUMERIC_PRECISION,
                'numeric_scale' => $row->NUMERIC_SCALE === null ? null : (int) $row->NUMERIC_SCALE,
                'character_maximum_length' => $row->CHARACTER_MAXIMUM_LENGTH === null
                    ? null
                    : (int) $row->CHARACTER_MAXIMUM_LENGTH,
                'datetime_precision' => $row->DATETIME_PRECISION === null ? null : (int) $row->DATETIME_PRECISION,
            ];
        }

        foreach ($this->indexes($schema) as $row) {
            if (! isset($manifest['tables'][$row->TABLE_NAME])) {
                continue;
            }

            $index = &$manifest['tables'][$row->TABLE_NAME]['indexes'][$row->INDEX_NAME];
            $index ??= [
                'unique' => (int) $row->NON_UNIQUE === 0,
                'type' => $row->INDEX_TYPE,
                'columns' => [],
            ];
            $index['columns'][] = [
                'name' => $row->COLUMN_NAME,
                'sub_part' => $row->SUB_PART === null ? null : (int) $row->SUB_PART,
                'order' => $row->COLLATION === 'D' ? 'DESC' : 'ASC',
            ];
            unset($index);
        }

        foreach ($this->foreignKeys($schema) as $row) {
            if (! isset($manifest['tables'][$row->TABLE_NAME])) {
                continue;
            }

            $foreign = &$manifest['tables'][$row->TABLE_NAME]['foreign_keys'][$row->CONSTRAINT_NAME];
            $foreign ??= [
                'columns' => [],
                'referenced_table' => $row->REFERENCED_TABLE_NAME,
                'referenced_columns' => [],
                'update_rule' => $row->UPDATE_RULE,
                'delete_rule' => $row->DELETE_RULE,
            ];
            $foreign['columns'][] = $row->COLUMN_NAME;
            $foreign['referenced_columns'][] = $row->REFERENCED_COLUMN_NAME;
            unset($foreign);
        }

        ksort($manifest['tables']);

        return $manifest;
    }

    private function assertSchemaExists(string $schema): void
    {
        if (! preg_match('/^[A-Za-z0-9_$-]+$/', $schema)) {
            throw new InvalidArgumentException('Unsafe database/schema name.');
        }

        $exists = $this->connection->selectOne(
            'SELECT COUNT(*) AS aggregate FROM information_schema.SCHEMATA WHERE SCHEMA_NAME = ?',
            [$schema]
        );

        if ((int) $exists->aggregate !== 1) {
            throw new InvalidArgumentException("Database/schema [{$schema}] does not exist or is not visible.");
        }
    }

    private function tables(string $schema): array
    {
        return $this->connection->select(<<<'SQL'
            SELECT TABLE_NAME, ENGINE, TABLE_COLLATION
            FROM information_schema.TABLES
            WHERE TABLE_SCHEMA = ? AND TABLE_TYPE = 'BASE TABLE'
            ORDER BY TABLE_NAME
        SQL, [$schema]);
    }

    private function columns(string $schema): array
    {
        return $this->connection->select(<<<'SQL'
            SELECT TABLE_NAME, COLUMN_NAME, ORDINAL_POSITION, DATA_TYPE, COLUMN_TYPE,
                   IS_NULLABLE, COLUMN_DEFAULT, EXTRA, CHARACTER_SET_NAME, COLLATION_NAME,
                   COLUMN_COMMENT, GENERATION_EXPRESSION, NUMERIC_PRECISION, NUMERIC_SCALE,
                   CHARACTER_MAXIMUM_LENGTH, DATETIME_PRECISION
            FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = ?
            ORDER BY TABLE_NAME, ORDINAL_POSITION
        SQL, [$schema]);
    }

    private function indexes(string $schema): array
    {
        return $this->connection->select(<<<'SQL'
            SELECT TABLE_NAME, INDEX_NAME, NON_UNIQUE, SEQ_IN_INDEX, COLUMN_NAME,
                   SUB_PART, INDEX_TYPE, COLLATION
            FROM information_schema.STATISTICS
            WHERE TABLE_SCHEMA = ?
            ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX
        SQL, [$schema]);
    }

    private function foreignKeys(string $schema): array
    {
        return $this->connection->select(<<<'SQL'
            SELECT k.TABLE_NAME, k.CONSTRAINT_NAME, k.COLUMN_NAME,
                   k.REFERENCED_TABLE_NAME, k.REFERENCED_COLUMN_NAME,
                   r.UPDATE_RULE, r.DELETE_RULE, k.ORDINAL_POSITION
            FROM information_schema.KEY_COLUMN_USAGE k
            JOIN information_schema.REFERENTIAL_CONSTRAINTS r
              ON r.CONSTRAINT_SCHEMA = k.CONSTRAINT_SCHEMA
             AND r.TABLE_NAME = k.TABLE_NAME
             AND r.CONSTRAINT_NAME = k.CONSTRAINT_NAME
            WHERE k.CONSTRAINT_SCHEMA = ?
              AND k.REFERENCED_TABLE_NAME IS NOT NULL
            ORDER BY k.TABLE_NAME, k.CONSTRAINT_NAME, k.ORDINAL_POSITION
        SQL, [$schema]);
    }
}
