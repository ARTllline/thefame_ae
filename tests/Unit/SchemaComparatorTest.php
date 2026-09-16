<?php

namespace Tests\Unit;

use App\Support\DatabaseSchema\SchemaComparator;
use PHPUnit\Framework\TestCase;

class SchemaComparatorTest extends TestCase
{
    public function test_identical_manifests_have_no_schema_issues(): void
    {
        $manifest = $this->manifest();

        $this->assertSame([], (new SchemaComparator())->compare($manifest, $manifest));
    }

    public function test_missing_primary_key_and_changed_column_are_reported_separately(): void
    {
        $expected = $this->manifest();
        $actual = $expected;
        $actual['tables']['appointments']['columns']['id']['column_type'] = 'int';
        $actual['tables']['appointments']['columns']['id']['extra'] = '';
        unset($actual['tables']['appointments']['indexes']['PRIMARY']);

        $issues = (new SchemaComparator())->compare($expected, $actual);

        $this->assertContains('column_column_type', array_column($issues, 'category'));
        $this->assertContains('column_extra', array_column($issues, 'category'));
        $this->assertContains('missing_index', array_column($issues, 'category'));
    }

    private function manifest(): array
    {
        return [
            'branch' => 'thefame_ae',
            'tables' => [
                'appointments' => [
                    'engine' => 'InnoDB',
                    'collation' => 'utf8mb4_unicode_ci',
                    'columns' => [
                        'id' => [
                            'column_type' => 'bigint unsigned',
                            'nullable' => false,
                            'default' => null,
                            'extra' => 'auto_increment',
                            'character_set' => null,
                            'collation' => null,
                            'generation_expression' => '',
                        ],
                    ],
                    'indexes' => [
                        'PRIMARY' => [
                            'unique' => true,
                            'type' => 'BTREE',
                            'columns' => [['name' => 'id', 'sub_part' => null, 'order' => 'ASC']],
                        ],
                    ],
                    'foreign_keys' => [],
                ],
            ],
        ];
    }
}
